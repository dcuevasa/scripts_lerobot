SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$SCRIPT_DIR/../dcuevas_hf_token.sh"
python "$SCRIPT_DIR/../../FLAG-Embodied-data/lerobot_record_sim.py \
  --robot.type=so101_mujoco \
  --robot.randomize_scene=true \
  --robot.camera_pos_base='[0.8, 0.2, 0.6]' \
  --robot.camera_euler_base='[0.0, -2.35619, -1.5708]' \
  --robot.box_pos_delta='[0.9, 0.9, 0.0]' \
  --robot.box_pos_base='[0.35, 0.2, 0.03]' \
  --robot.tray_pos_base='[0.1, 0.35, 0.01]' \
  --teleop.type=so101_ik \
  --dataset.repo_id=bendca61/svla_so101_mujoco_pickplace \
  --dataset.single_task="Put the block on the tray" \
  --dataset.episode_time_s=25 \
  --dataset.num_episodes=10 \
  --reset_every_episode=true \
  --display_data=true\
  --resume=true