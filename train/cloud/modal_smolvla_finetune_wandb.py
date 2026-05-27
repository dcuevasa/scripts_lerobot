"""
Fine-tune SmolVLA en Modal (GPU en la nube) — equivalente a finetune_smolvla.sh
Con integración W&B para generar curvas de aprendizaje automáticamente.

Requisitos locales (solo para lanzar el job, no entrena en tu PC):
  pip install modal
  modal setup
  modal secret create huggingface HF_TOKEN=hf_...
  modal secret create wandb WANDB_API_KEY=...   # solo si WANDB_MODE=online

Curvas de entrenamiento:
  - Dashboard en tiempo real: URL que imprime lerobot-train al iniciar (o wandb.ai)
  - Al terminar el job: train/smolvla_merged_{RUN_TAG}/training_curves/learning_curves.png
    modal volume get smolvla-lerobot-outputs train/smolvla_merged_{RUN_TAG}/training_curves ./training_curves

Uso:
  cd scripts_lerobot
  modal run modal_smolvla_finetune_wandb.py

Descargar checkpoints del volumen Modal (sustituye el run tag por el tuyo, p. ej. 1000step_bs16_ep305):
  modal volume ls smolvla-lerobot-outputs
  modal volume get smolvla-lerobot-outputs train/smolvla_merged_{RUN_TAG}/checkpoints/last ./checkpoints_last

Docs Modal: https://modal.com/docs/guide
SmolVLA LeRobot: https://huggingface.co/docs/lerobot/smolvla
"""

from __future__ import annotations

import json
import shutil
import sys
from pathlib import Path

import modal

# --- Configuración (edita aquí) ------------------------------------------------
# STEPS, BATCH_SIZE y NUM_EPISODES: el resto de nombres (Hub, volumen Modal, job) se derivan solos.
STEPS = 3000
BATCH_SIZE = 16
NUM_EPISODES = 305  # total_episodes del dataset (meta/info.json en Hugging Face)

DATASET_REPO_ID = "CarlosMunoz0/vla-mujoco-so101-merged-v1"
_RUN_TAG = f"{STEPS}step_bs{BATCH_SIZE}_ep{NUM_EPISODES}"
OUTPUT_SUBDIR = f"train/smolvla_merged_{_RUN_TAG}"
JOB_NAME = f"smolvla_merged_{_RUN_TAG}"
HUB_REPO_ID = f"CarlosMunoz0/smolvla-so101-merged-{_RUN_TAG}-v1"

NUM_WORKERS = 4
GPU = "A100"  # alternativas: "A10G", "L40S", "H100"
PUSH_TO_HUB = True

# FRESH_RUN=True: borra salida previa en el volumen Modal para ESTE run (otros run tags no se tocan)
# FRESH_RUN=False: reanuda si existe checkpoints/last en la carpeta de este run
FRESH_RUN = True

RENAME_MAP = '{"observation.images.realsense": "observation.images.image"}'
INPUT_FEATURES = (
    '{"observation.images.image": {"type": "VISUAL", "shape": [3, 480, 640]}, '
    '"observation.state": {"type": "STATE", "shape": [6]}}'
)

VOLUME_NAME = "smolvla-lerobot-outputs"
APP_NAME = "lerobot-smolvla-finetune"
LEROBOT_VERSION = "0.5.0"

# Métricas / curvas (LeRobot → W&B; al terminar se exportan CSV+PNG al volumen)
WANDB_ENABLE = True
WANDB_PROJECT = "smolvla-so101"
WANDB_ENTITY = None  # ej. "mi-equipo" o None
WANDB_MODE = "online"  # "online" | "offline" (offline: sin API key; sync local después)
LOG_FREQ = 200  # puntos en la curva (~steps/200); menor = más detalle
EXPORT_CURVES_TO_VOLUME = True  # training_curves/metrics.csv + learning_curves.png
# -------------------------------------------------------------------------------

app = modal.App(APP_NAME)

# pip_install + versión fija: uv a veces resuelve un lerobot sin paquete scripts/
image = (
    modal.Image.debian_slim(python_version="3.12")  # lerobot>=0.5 requiere Python 3.12+
    .apt_install("git", "ffmpeg", "libgl1", "libglib2.0-0")
    .pip_install(
        f"lerobot[smolvla]=={LEROBOT_VERSION}",
        "huggingface_hub",
        "wandb",
        "matplotlib",
        "pandas",
        # lerobot 0.5.0 + transformers>=5.4 rompe import de groot (issue #3232)
        "transformers>=5.3.0,<5.4.0",
    )
    .run_commands(
        f"python -c \"import lerobot; print('lerobot', lerobot.__version__)\"",
        "python -c \"from lerobot.scripts.lerobot_train import main; print('lerobot_train ok')\"",
    )
)

output_volume = modal.Volume.from_name(VOLUME_NAME, create_if_missing=True)


def _prepare_output_dir(out_dir: str) -> bool:
    """Devuelve si hay que pasar --resume=true a lerobot-train."""
    p = Path(out_dir)
    ckpt = p / "checkpoints" / "last" / "pretrained_model"

    if FRESH_RUN and p.exists():
        shutil.rmtree(p)
        print(f"FRESH_RUN: eliminado {out_dir}", flush=True)
        return False

    if ckpt.exists():
        print(f"Reanudando desde {ckpt}", flush=True)
        return True

    if p.exists():
        shutil.rmtree(p)
        print(f"Carpeta sin checkpoint válido, eliminada: {out_dir}", flush=True)
    return False


def _wandb_cli_args() -> list[str]:
    if not WANDB_ENABLE:
        return ["--wandb.enable=false"]
    args = [
        "--wandb.enable=true",
        f"--wandb.project={WANDB_PROJECT}",
        f"--wandb.mode={WANDB_MODE}",
    ]
    if WANDB_ENTITY:
        args.append(f"--wandb.entity={WANDB_ENTITY}")
    return args


def _train_cli_args(out_dir: str, *, resume: bool) -> list[str]:
    args = [
        f"--dataset.repo_id={DATASET_REPO_ID}",
        f"--output_dir={out_dir}",
        f"--job_name={JOB_NAME}",
        f"--resume={str(resume).lower()}",
        "--policy.path=lerobot/smolvla_base",
        f"--steps={STEPS}",
        f"--batch_size={BATCH_SIZE}",
        f"--num_workers={NUM_WORKERS}",
        f"--log_freq={LOG_FREQ}",
        "--policy.device=cuda",
        "--policy.use_amp=true",
        f"--rename_map={RENAME_MAP}",
        f"--policy.input_features={INPUT_FEATURES}",
        f"--policy.push_to_hub={str(PUSH_TO_HUB).lower()}",
        *_wandb_cli_args(),
    ]
    if PUSH_TO_HUB:
        args.append(f"--policy.repo_id={HUB_REPO_ID}")
    return args


def _find_wandb_history_file(out_dir: Path) -> Path | None:
    wandb_root = out_dir / "wandb"
    if not wandb_root.is_dir():
        return None

    candidates: list[Path] = []
    for run_dir in wandb_root.iterdir():
        if not run_dir.is_dir():
            continue
        history = run_dir / "files" / "wandb-history.jsonl"
        if history.is_file():
            candidates.append(history)

    if not candidates:
        return None
    return max(candidates, key=lambda p: p.stat().st_mtime)


def _pick_column(df_columns: list[str], *names: str) -> str | None:
    for name in names:
        if name in df_columns:
            return name
    return None


def _export_training_curves(out_dir: str) -> Path | None:
    """Lee historial W&B local y guarda CSV + PNG en output_dir/training_curves/."""
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import pandas as pd

    root = Path(out_dir)
    history_path = _find_wandb_history_file(root)
    if history_path is None:
        print("EXPORT_CURVES: no hay wandb-history.jsonl (¿WANDB_ENABLE=true?)", flush=True)
        return None

    rows: list[dict] = []
    for line in history_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line:
            rows.append(json.loads(line))
    if not rows:
        print(f"EXPORT_CURVES: historial vacío en {history_path}", flush=True)
        return None

    raw = pd.DataFrame(rows)
    step_col = _pick_column(list(raw.columns), "_step", "train/steps", "steps")
    loss_col = _pick_column(list(raw.columns), "train/loss", "loss")
    grad_col = _pick_column(list(raw.columns), "train/grad_norm", "grad_norm")
    lr_col = _pick_column(list(raw.columns), "train/lr", "lr")

    if step_col is None or loss_col is None:
        print(f"EXPORT_CURVES: columnas no reconocidas: {list(raw.columns)}", flush=True)
        return None

    df = pd.DataFrame(
        {
            "step": raw[step_col].astype(int),
            "loss": raw[loss_col].astype(float),
        }
    )
    if grad_col:
        df["grad_norm"] = raw[grad_col].astype(float)
    if lr_col:
        df["lr"] = raw[lr_col].astype(float)
    df = df.sort_values("step").drop_duplicates(subset=["step"], keep="last")

    curves_dir = root / "training_curves"
    curves_dir.mkdir(parents=True, exist_ok=True)
    csv_path = curves_dir / "metrics.csv"
    png_path = curves_dir / "learning_curves.png"
    df.to_csv(csv_path, index=False)

    n_plots = 1 + int(grad_col is not None) + int(lr_col is not None)
    fig, axes = plt.subplots(n_plots, 1, figsize=(12, 3.5 * n_plots), sharex=True)
    if n_plots == 1:
        axes = [axes]

    axes[0].plot(df["step"], df["loss"], marker="o", ms=3)
    axes[0].set_ylabel("Loss")
    axes[0].set_title(f"Curvas — {JOB_NAME}")
    axes[0].grid(True, alpha=0.3)

    idx = 1
    if grad_col:
        axes[idx].plot(df["step"], df["grad_norm"], color="orange", marker="o", ms=3)
        axes[idx].set_ylabel("Gradient norm")
        axes[idx].grid(True, alpha=0.3)
        idx += 1
    if lr_col:
        axes[idx].plot(df["step"], df["lr"], color="green", marker="o", ms=3)
        axes[idx].set_ylabel("Learning rate")
        axes[idx].set_xlabel("Step")
        axes[idx].grid(True, alpha=0.3)
    else:
        axes[-1].set_xlabel("Step")

    plt.tight_layout()
    fig.savefig(png_path, dpi=150)
    plt.close(fig)

    print(f"Curvas guardadas: {csv_path} | {png_path}", flush=True)
    return curves_dir


def _run_lerobot_train(out_dir: str, *, resume: bool) -> None:
    """Invoca lerobot-train en proceso (sin depender de console_scripts en PATH)."""
    import os

    # Fuerza a W&B a guardar sus archivos locales dentro de out_dir,
    # para que _export_training_curves los encuentre al terminar.
    if WANDB_ENABLE:
        os.environ["WANDB_DIR"] = out_dir

    argv = ["lerobot-train", *_train_cli_args(out_dir, resume=resume)]
    print("Running:", " ".join(argv), flush=True)
    sys.argv = argv
    from lerobot.scripts.lerobot_train import main

    main()


def _modal_secrets() -> list[modal.Secret]:
    secrets = [modal.Secret.from_name("huggingface")]
    if WANDB_ENABLE and WANDB_MODE == "online":
        secrets.append(modal.Secret.from_name("wandb"))
    return secrets


@app.function(
    image=image,
    gpu=GPU,
    timeout=60 * 60 * 12,
    secrets=_modal_secrets(),
    volumes={"/outputs": output_volume},
)
def train_smolvla() -> None:
    out_dir = f"/outputs/{OUTPUT_SUBDIR}"
    print(
        f"Run: STEPS={STEPS} | batch={BATCH_SIZE} | episodes={NUM_EPISODES} | "
        f"job={JOB_NAME} | hub={HUB_REPO_ID} | wandb={WANDB_ENABLE}({WANDB_MODE}) | "
        f"volume_path={out_dir}",
        flush=True,
    )
    resume = _prepare_output_dir(out_dir)
    _run_lerobot_train(out_dir, resume=resume)

    if EXPORT_CURVES_TO_VOLUME and WANDB_ENABLE:
        _export_training_curves(out_dir)

    output_volume.commit()
    print(f"Done. Checkpoints under volume '{VOLUME_NAME}' -> {out_dir}", flush=True)
    if EXPORT_CURVES_TO_VOLUME and WANDB_ENABLE:
        print(f"Curvas: {out_dir}/training_curves/", flush=True)


@app.local_entrypoint()
def main() -> None:
    train_smolvla.remote()
