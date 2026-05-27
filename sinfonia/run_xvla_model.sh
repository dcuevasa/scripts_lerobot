. dcuevas_hf_token.sh
rm -rf /home/sinfonia/.cache/huggingface/lerobot/local/eval_xvla_so101_test

lerobot-record \
  --robot.type=so101_mujoco \
  --robot.randomize_scene=true \
  --robot.camera_pos_base='[0.8, 0.2, 0.6]' \
  --robot.camera_euler_base='[2.35619,0,-1.5708]' \
  --robot.enable_wrist_cam=true \
  --robot.enable_depth=false \
  --robot.enable_ee_pose=false \
  --dataset.repo_id=local/eval_xvla_so101_test \
  --dataset.num_episodes=1 \
  --dataset.single_task="Put the block on the tray" \
  --dataset.push_to_hub=false \
  --policy.path=$(pwd)/outputs/train/xvla_so101_newdtst/checkpoints/last/pretrained_model \
  --display_data=true