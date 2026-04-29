. dcuevas_hf_token.sh
sudo chmod  666 /dev/ttyACM0
python ../FLAG-Embodied-data/lerobot_record_sim.py \
  --robot.type=so101_mujoco \
  --robot.randomize_scene=true \
  --robot.camera_pos_base='[0.5, 0.5, 0.6]' \
  --robot.camera_euler_base='[2.35619,0,-0.78539]' \
  --robot.box_pos_delta='[0.08, 0.08, 0.0]' \
  --robot.box_pos_base='[0.35, 0.2, 0.03]' \
  --robot.tray_pos_base='[0.1, 0.35, 0.01]' \
  --teleop.type=so101_leader \
  --teleop.port=/dev/ttyACM0 \
  --teleop.id=negro_rojo \
  --dataset.repo_id=bendca61/mujoco-so101-cube_on_tray-leader-v1 \
  --dataset.single_task="Put the cube on the tray" \
  --dataset.episode_time_s=25 \
  --dataset.num_episodes=10 \
  --reset_every_episode=true \
  --display_data=true \
  --resume=true