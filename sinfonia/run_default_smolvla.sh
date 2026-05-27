rm -rf /home/sinfonia/.cache/huggingface/lerobot/local/eval_DATASET_NAME_test
lerobot-record \
  --robot.type=so101_mujoco \
  --robot.randomize_scene=true \
  --robot.camera_pos_base='[0.8, 0.2, 0.6]' \
  --robot.camera_euler_base='[0.0, -2.35619, -1.5708]' \
  --dataset.single_task="Put the block on the tray" \
  --dataset.repo_id=local/eval_DATASET_NAME_test \
  --dataset.episode_time_s=50 \
  --dataset.push_to_hub=false \
  --dataset.num_episodes=10 \
  --dataset.streaming_encoding=true \
  --dataset.encoder_threads=2 \
  --policy.path=Sixym3/smolvla-so100-block-positioning-cubicle-collab-home # lerobot/smolvla_base