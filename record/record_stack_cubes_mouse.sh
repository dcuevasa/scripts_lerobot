SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$SCRIPT_DIR/../dcuevas_hf_token.sh"
python "$SCRIPT_DIR/../../FLAG-Embodied-data/lerobot_record_sim.py \
  --robot.type=so101_mujoco \
  --robot.randomize_scene=true \
  --robot.camera_pos_base='[0.5, 0.5, 0.6]' \
  --robot.camera_euler_base='[2.35619,0,-0.78539]' \
  --robot.box_pos_base='[0.25, 0.08, 0.03]' \
  --robot.box_pos_delta='[0.05, 0.05, 0.0]' \
  --robot.box_color_delta='[0.0, 0.0, 0.0, 0.0]' \
  --robot.box2_pos_base='[0.40, 0.08, 0.03]' \
  --robot.box2_pos_delta='[0.05, 0.05, 0.0]' \
  --robot.box2_color_delta='[0.0, 0.0, 0.0, 0.0]' \
  --robot.enable_rgb=true \
  --robot.show_cv2=false \
  --teleop.type=so101_ik \
  --dataset.repo_id=CarlosMunoz0/mujoco-so101-stack_cubes-mouse-v1 \
  --dataset.single_task="Stack the black cube on top of the blue cube" \
  --dataset.episode_time_s=70 \
  --dataset.num_episodes=1 \
  --reset_every_episode=true \
  --dataset.push_to_hub=true \
  --display_data=false \
  --resume=false