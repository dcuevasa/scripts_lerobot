. dcuevas_hf_token.sh
rm -rf /home/sinfonia/.cache/huggingface/lerobot/local/eval_act_overfit_test
lerobot-record \
  --robot.type=so101_mujoco \
  --robot.randomize_scene=true \
  --robot.camera_pos_base='[0.8, 0.2, 0.6]' \
  --robot.camera_euler_base='[0.0, -2.35619, -1.5708]' \
  --dataset.repo_id=local/eval_act_overfit_test \
  --dataset.num_episodes=1 \
  --dataset.single_task="Put the block on the tray" \
  --dataset.push_to_hub=false \
  --policy.path=/home/sinfonia/Documents/experiments/python_experiments/mujoco_lerobot/scripts/outputs/train/act_overfit_test2/checkpoints/last/pretrained_model
