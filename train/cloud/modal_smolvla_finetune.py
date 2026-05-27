"""
Fine-tune SmolVLA en Modal (GPU en la nube) — equivalente a finetune_smolvla.sh

Requisitos locales (solo para lanzar el job, no entrena en tu PC):
  pip install modal
  modal setup
  modal secret create huggingface HF_TOKEN=hf_...

Uso:
  cd scripts_lerobot
  modal run modal_smolvla_finetune.py

Descargar checkpoints del volumen Modal (sustituye el run tag por el tuyo, p. ej. 1000step_bs16_ep305):
  modal volume ls smolvla-lerobot-outputs
  modal volume get smolvla-lerobot-outputs train/smolvla_merged_{RUN_TAG}/checkpoints/last ./checkpoints_last

Docs Modal: https://modal.com/docs/guide
SmolVLA LeRobot: https://huggingface.co/docs/lerobot/smolvla
"""

from __future__ import annotations

import shutil
import sys
from pathlib import Path

import modal

# --- Configuración (edita aquí) ------------------------------------------------
# STEPS, BATCH_SIZE y NUM_EPISODES: el resto de nombres (Hub, volumen Modal, job) se derivan solos.
STEPS = 100
BATCH_SIZE = 16
NUM_EPISODES = 400  # total_episodes del dataset (meta/info.json en Hugging Face)

DATASET_REPO_ID = "CarlosMunoz0/vla-mujoco-so101-merged-4-tasks-v2.1"
_RUN_TAG = f"{STEPS}step_bs{BATCH_SIZE}_ep{NUM_EPISODES}"
OUTPUT_SUBDIR = f"train/smolvla_merged_{_RUN_TAG}"
JOB_NAME = f"smolvla_merged_{_RUN_TAG}"
HUB_REPO_ID = f"CarlosMunoz0/smolvla-so101-merged-4-tasks-{_RUN_TAG}-v2.1"

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
# -------------------------------------------------------------------------------

app = modal.App(APP_NAME)

# pip_install + versión fija: uv a veces resuelve un lerobot sin paquete scripts/
image = (
    modal.Image.debian_slim(python_version="3.12")  # lerobot>=0.5 requiere Python 3.12+
    .apt_install("git", "ffmpeg", "libgl1", "libglib2.0-0")
    .pip_install(
        f"lerobot[smolvla]=={LEROBOT_VERSION}",
        "huggingface_hub",
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
        "--policy.device=cuda",
        "--policy.use_amp=true",
        f"--rename_map={RENAME_MAP}",
        f"--policy.input_features={INPUT_FEATURES}",
        f"--policy.push_to_hub={str(PUSH_TO_HUB).lower()}",
        "--wandb.enable=false",
    ]
    if PUSH_TO_HUB:
        args.append(f"--policy.repo_id={HUB_REPO_ID}")
    return args


def _run_lerobot_train(out_dir: str, *, resume: bool) -> None:
    """Invoca lerobot-train en proceso (sin depender de console_scripts en PATH)."""
    argv = ["lerobot-train", *_train_cli_args(out_dir, resume=resume)]
    print("Running:", " ".join(argv), flush=True)
    sys.argv = argv
    from lerobot.scripts.lerobot_train import main

    main()


@app.function(
    image=image,
    gpu=GPU,
    timeout=60 * 60 * 12,
    secrets=[modal.Secret.from_name("huggingface")],
    volumes={"/outputs": output_volume},
)
def train_smolvla() -> None:
    out_dir = f"/outputs/{OUTPUT_SUBDIR}"
    print(
        f"Run: STEPS={STEPS} | batch={BATCH_SIZE} | episodes={NUM_EPISODES} | "
        f"job={JOB_NAME} | hub={HUB_REPO_ID} | volume_path={out_dir}",
        flush=True,
    )
    resume = _prepare_output_dir(out_dir)
    _run_lerobot_train(out_dir, resume=resume)
    output_volume.commit()
    print(f"Done. Checkpoints under volume '{VOLUME_NAME}' -> {out_dir}", flush=True)


@app.local_entrypoint()
def main() -> None:
    train_smolvla.remote()
