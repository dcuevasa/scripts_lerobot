rm -rf /home/sinfonia/.cache/huggingface/lerobot/bendca61/eval_svla_so101_mujoco_pickplace

DATASET_REPO="bendca61/svla_so101_mujoco_pickplace"
TASK="Put the block on the tray"
EPISODE_TIME_S=25
INFER_FPS=8
BOX_POS_DELTA='[0.15, 0.15, 0.0]'
MODEL_PATH="outputs/train/2026-03-27/15-35-32_smolvla/checkpoints/010000/pretrained_model"

python ../FLAG-Embodied-data/run_inference.py \
  --robot.type=so101_mujoco \
  --robot.randomize_scene=false \
  --robot.camera_pos_base='[0.8, 0.2, 0.6]' \
  --robot.camera_euler_base='[0.0, -2.35619, -1.5708]' \
  --robot.box_pos_delta="$BOX_POS_DELTA" \
  --policy.type=smolvla \
  --policy.pretrained_path="$MODEL_PATH" \
  --dataset.repo_id="$DATASET_REPO" \
  --dataset.single_task="$TASK" \
  --dataset.episode_time_s="$EPISODE_TIME_S" \
  --dataset.fps="$INFER_FPS" 