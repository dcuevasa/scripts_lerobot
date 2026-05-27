lerobot-teleoperate \
  --robot.type=so101_mujoco \
  --robot.enable_ee_pose=false \
  --robot.starting_angles='{"shoulder_pan": 0.005, "shoulder_lift": -1.462, "elbow_flex": 1.371, "wrist_flex": 1.006, "wrist_roll": 1.422, "gripper": 0.0}' \
  --teleop.type=keyboard