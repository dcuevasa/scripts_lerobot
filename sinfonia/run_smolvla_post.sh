. dcuevas_hf_token.sh
rm -rf /home/sinfonia/.cache/huggingface/lerobot/local/eval_smovla_overfit_test
lerobot-record \
  --robot.type=so101_mujoco \
  --robot.randomize_scene=false \
  --robot.camera_pos_base='[0.8, 0.2, 0.6]' \
  --robot.camera_euler_base='[2.35619,0,-1.5708]' \
  --robot.starting_angles='{"shoulder_pan": 0.005, "shoulder_lift": -1.462, "elbow_flex": 1.371, "wrist_flex": 1.006, "wrist_roll": 1.422, "gripper": 0.0}' \
  --robot.enable_wrist_cam=false \
  --robot.enable_depth=false \
  --robot.enable_ee_pose=false \
  --dataset.repo_id=local/eval_smovla_overfit_test \
  --dataset.num_episodes=1 \
  --dataset.single_task="Put the block on the tray" \
  --dataset.push_to_hub=false \
  --policy.path=/home/sinfonia/Documents/experiments/python_experiments/mujoco_lerobot/scripts/outputs/train/smolvla_mujoco_pickplace/checkpoints/last/pretrained_model \
  --display_data=true