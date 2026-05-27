sudo chmod  666 /dev/ttyACM0
lerobot-teleoperate \
  --robot.type=so101_mujoco \
  --robot.camera_pos_base='[0.5, 0.5, 0.6]' \
  --robot.camera_euler_base='[2.35619,0,-0.78539]' \
  --robot.box_pos_delta='[0.08, 0.08, 0.0]' \
  --robot.box_pos_base='[0.0, 0.35, 0.03]' \
  --teleop.type=so101_leader \
  --teleop.port=/dev/ttyACM0 \
  --teleop.id=negro_rojo \
  --display_data=true
