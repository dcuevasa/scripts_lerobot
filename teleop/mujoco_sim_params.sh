lerobot-teleoperate \
  --robot.type=so101_mujoco \
  --robot.randomize_scene=false \
  --robot.camera_pos_base='[0.5, 0.5, 0.6]' \
  --robot.camera_euler_base='[2.35619,0,-0.78539]' \
  --robot.box_pos_delta='[0.09, 0.09, 0.0]' \
  --robot.box_pos_base='[0.35, 0.2, 0.03]' \
  --robot.tray_pos_base='[0.1, 0.35, 0.01]' \
  --teleop.type=keyboard \
  --display_data=true