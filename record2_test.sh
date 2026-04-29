. dcuevas_hf_token.sh
python ../FLAG-Embodied-data/lerobot_record2.py \
  --robot.type=so101_mujoco \
  --robot.randomize_scene=true \
  --robot.camera_pos_base='[0.8, 0.2, 0.6]' \
  --robot.camera_euler_base='[0.0, -2.35619, -1.5708]' \
  --teleop.type=so101_ik \
  --dataset.repo_id=bendca61/so101_mujoco_demo \
  --dataset.single_task="Put the block on the tray" \
  --dataset.episode_time_s=20 \
  --dataset.reset_time_s=5 \
  --dataset.num_episodes=5 \
  --reset_every_episode=true \
  --resume=true
