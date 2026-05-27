"""
Evalua SmolVLA en MuJoCo via lerobot-record.

Patches aplicados antes de importar lerobot_record:

1. make_policy rename_map:
   lerobot-record no pasa dataset.rename_map a make_policy(), lo que falla la
   validacion de camaras (realsense vs image). Este wrapper aplica el mismo
   rename_map que en modal_smolvla_finetune.py.

2. reset_scene entre episodios:
   lerobot-record no llama robot.restart_simulation() entre episodios; solo
   corre un loop vacio (reset_time_s=0) que genera warnings. Este patch
   intercepta ese loop vacio, llama restart_simulation() en su lugar, y
   suprime completamente los warnings de "No policy or teleoperator provided".
"""

from __future__ import annotations

import functools
import logging

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

# ─────────────────────────────────────────────────────────────────────────────
from lerobot.scripts.lerobot_record import main  # noqa: E402

if __name__ == "__main__":
    try:
        main()
    finally:
        policy_factory.make_policy = _orig_make_policy
        _lr.record_loop = _orig_record_loop
