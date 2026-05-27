"""
Evalúa xVLA en MuJoCo vía lerobot-record.

xVLA usa max_action_dim=20 (padding fijo de arquitectura) pero el so101
solo tiene 6 DOF reales (output_features.action.shape = (6,)). Se aplican
tres patches:

1. make_policy rename_map:
   lerobot-record no pasa dataset.rename_map a make_policy(), lo que falla
   la validación de cámaras (realsense vs image).

2. reset_scene entre episodios:
   lerobot-record no llama robot.restart_simulation() entre episodios; solo
   corre un loop vacío (reset_time_s=0) que genera warnings. Este patch
   intercepta ese loop vacío, llama restart_simulation() en su lugar, y
   suprime completamente los warnings de "No policy or teleoperator provided".

3. Recortar acción antes del postprocessor:
   xVLA devuelve tensores de 20 dims desde select_action (max_action_dim=20),
   pero el normalizador solo tiene stats de 6 dims (el DOF real del robot).
   Este patch intercepta el postprocessor antes de que se ejecute y recorta
   la acción de 20 → 6 dims para que la normalización no falle.
"""

from __future__ import annotations

import functools

from lerobot.policies import factory as policy_factory

# ── Patch 1: rename_map en make_policy ────────────────────────────────────────
RENAME_MAP = {"observation.images.realsense": "observation.images.image"}

_orig_make_policy = policy_factory.make_policy


@functools.wraps(_orig_make_policy)
def _make_policy_with_rename_map(cfg, ds_meta=None, env_cfg=None, rename_map=None):
    if rename_map is None:
        rename_map = RENAME_MAP
    return _orig_make_policy(cfg, ds_meta=ds_meta, env_cfg=env_cfg, rename_map=rename_map)


policy_factory.make_policy = _make_policy_with_rename_map

# ── Patch 2: reset_scene entre episodios ──────────────────────────────────────
import lerobot.scripts.lerobot_record as _lr  # noqa: E402

_orig_record_loop = _lr.record_loop


@functools.wraps(_orig_record_loop)
def _patched_record_loop(
    robot,
    events,
    fps,
    policy=None,
    control_time_s=None,
    **kwargs,
):
    # Detectar el loop de reset: sin policy y tiempo <= 1 s (reset_time_s=0 o 1)
    is_reset_call = (policy is None and control_time_s is not None and control_time_s <= 1)

    if is_reset_call:
        if hasattr(robot, "restart_simulation"):
            robot.restart_simulation()
        # Saltar el loop completamente: cero warnings, cero espera
        return

    _orig_record_loop(
        robot=robot,
        events=events,
        fps=fps,
        policy=policy,
        control_time_s=control_time_s,
        **kwargs,
    )


_lr.record_loop = _patched_record_loop

# ── Patch 3: Recortar acción 20→6 antes del postprocessor ────────────────────
# xVLA devuelve max_action_dim=20 dims en su forward, pero el normalizador
# tiene stats de 6 dims (DOF real del robot). Interceptamos el postprocessor
# para recortar la acción antes de que intente normalizar.
import lerobot.utils.control_utils as _cu  # noqa: E402

_orig_predict_action = _cu.predict_action

ROBOT_ACTION_DIM = 6  # so101: 5 joints del brazo + 1 gripper


@functools.wraps(_orig_predict_action)
def _patched_predict_action(*args, **kwargs):
    postprocessor = kwargs.get("postprocessor")

    if postprocessor is not None:
        _orig_pp = postprocessor

        def _sliced_postprocessor(action):
            if hasattr(action, "shape") and action.shape[-1] > ROBOT_ACTION_DIM:
                action = action[..., :ROBOT_ACTION_DIM]
            return _orig_pp(action)

        kwargs["postprocessor"] = _sliced_postprocessor

    return _orig_predict_action(*args, **kwargs)


_cu.predict_action = _patched_predict_action
# lerobot_record.py hace `from control_utils import predict_action` (referencia local),
# por lo que también hay que parchear esa copia directamente.
_lr.predict_action = _patched_predict_action

# ─────────────────────────────────────────────────────────────────────────────
from lerobot.scripts.lerobot_record import main  # noqa: E402

if __name__ == "__main__":
    try:
        main()
    finally:
        policy_factory.make_policy = _orig_make_policy
        _lr.record_loop = _orig_record_loop
        _cu.predict_action = _orig_predict_action
        _lr.predict_action = _orig_predict_action
