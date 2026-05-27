SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/../juanchix_hf_token.sh"
python "$SCRIPT_DIR/../../FLAG-Embodied-data/lerobot_record_sim.py \
  --robot.type=so101_mujoco \
  --robot.randomize_scene=true \
  --robot.camera_pos_base='[0.8, 0.2, 0.6]' \
  --robot.camera_euler_base='[0.0, -2.35619, -1.5708]' \
  --robot.tray_pos_base='[0.35, 0.0, 0.01]' \
  --robot.tray_pos_delta='[0.05, 0.05, 0.0]' \
  --robot.tray_size_base='[0.12, 0.12, 0.01]' \
  --robot.tray_size_delta='[0.02, 0.02, 0.0]' \
  --robot.box_pos_base='[0.35, 0.0, 0.04]' \
  --robot.box_pos_delta='[0.04, 0.05, 0.0]' \
  --robot.box_size_base='[0.02, 0.02, 0.03]' \
  --robot.box_size_delta='[0.005, 0.005, 0.005]' \
  --teleop.type=so101_ik \
  --dataset.repo_id=Juanchix/so101_mujoco_mouse_take_out_box \
  --dataset.single_task="Take the block out of the tray" \
  --dataset.episode_time_s=25 \
  --dataset.num_episodes=10 \
  --reset_every_episode=true \
  --display_data=true \
  --resume=true