. dcuevas_hf_token.sh
rm -rf /home/sinfonia/.cache/huggingface/lerobot/local/eval_act_test

lerobot-record \
  --robot.type=so101_mujoco \
  --robot.randomize_scene=false \
  --robot.camera_pos_base='[0.8, 0.2, 0.6]' \
  --robot.camera_euler_base='[2.35619,0,-1.5708]' \
  --robot.enable_wrist_cam=false \
  --robot.enable_depth=false \
  --robot.enable_ee_pose=false \
  --dataset.repo_id=local/eval_act_test \
  --dataset.num_episodes=1 \
  --dataset.single_task="Put the block on the tray" \
  --dataset.push_to_hub=false \
  --policy.type=act \
  --policy.repo_id=/home/sinfonia/Documents/experiments/python_experiments/mujoco_lerobot/scripts/outputs/train/act_full_shift/checkpoints/002000/pretrained_model \
  --policy.device=cuda \
  --display_data=true