rm -rf /home/sinfonia/.cache/huggingface/lerobot/local/so101_mujoco_test/
lerobot-record \
  --robot.type=so101_mujoco \
  --teleop.type=so101_ik \
  --dataset.repo_id=local/so101_mujoco_test \
  --dataset.single_task="reach the target" \
  --dataset.fps=30 \
  --dataset.num_episodes=2 \
  --dataset.push_to_hub=false \
  --dataset.streaming_encoding=true \
  --dataset.encoder_threads=2 \
  --dataset.vcodec=auto \
  --dataset.episode_time_s=5
