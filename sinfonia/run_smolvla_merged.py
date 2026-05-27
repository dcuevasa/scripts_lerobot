"""
Evalúa SmolVLA en MuJoCo vía lerobot-record.

lerobot-record no pasa dataset.rename_map a make_policy(), así que falla la
validación de cámaras (realsense vs image/camera1-3). Este wrapper aplica el
mismo rename_map que en modal_smolvla_finetune.py / finetune_smolvla.sh.

Importante: parchear factory.make_policy ANTES de importar lerobot_record, porque
ese módulo hace `from lerobot.policies.factory import make_policy` al cargarse.
"""

from __future__ import annotations

import functools

from lerobot.policies import factory as policy_factory

RENAME_MAP = {"observation.images.realsense": "observation.images.image"}

_orig_make_policy = policy_factory.make_policy


@functools.wraps(_orig_make_policy)
def _make_policy_with_rename_map(cfg, ds_meta=None, env_cfg=None, rename_map=None):
    if rename_map is None:
        rename_map = RENAME_MAP
    return _orig_make_policy(cfg, ds_meta=ds_meta, env_cfg=env_cfg, rename_map=rename_map)


policy_factory.make_policy = _make_policy_with_rename_map

from lerobot.scripts.lerobot_record import main  # noqa: E402

if __name__ == "__main__":
    try:
        main()
    finally:
        policy_factory.make_policy = _orig_make_policy
