. dcuevas_hf_token.sh
rm -rf /home/sinfonia/.cache/huggingface/lerobot/local/eval_act_test

lerobot-record \
  --robot.type=so101_mujoco \
  --robot.randomize_scene=true \
  --robot.camera_pos_base='[0.5, 0.5, 0.6]' \
  --robot.camera_euler_base='[2.35619,0,-0.78539]' \
  --robot.starting_angles='{"shoulder_pan": 0.005, "shoulder_lift": -1.462, "elbow_flex": 1.371, "wrist_flex": 1.006, "wrist_roll": 1.422, "gripper": 0.0}' \
  --robot.enable_wrist_cam=true \
  --robot.enable_depth=false \
  --robot.enable_ee_pose=false \
  --dataset.repo_id=local/eval_act_test \
  --dataset.num_episodes=1 \
  --dataset.single_task="Put the cube on the tray" \
  --dataset.push_to_hub=false \
  --policy.type=act \
  --policy.repo_id=/home/sinfonia/Documents/experiments/python_experiments/mujoco_lerobot/scripts/outputs/train/act_cube_on_tray_v1/checkpoints/005000/pretrained_model \
  --policy.device=cuda \
  --display_data=true