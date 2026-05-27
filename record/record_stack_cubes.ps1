$env:HF_TOKEN = ""

python (Join-Path $PSScriptRoot "..\..\FLAG-Embodied-data\lerobot_record_sim.py") `
  --robot.type=so101_mujoco `
  --robot.randomize_scene=true `
  --robot.camera_pos_base="[0.5, 0.5, 0.6]" `
  --robot.camera_euler_base="[2.35619,0,-0.78539]" `
  --robot.box_pos_delta="[0.08, 0.08, 0.0]" `
  --robot.box_pos_base="[0.35, 0.2, 0.03]" `
  --robot.box2_pos_base="[0.45, 0.1, 0.03]" `
  --robot.tray_pos_base="[0.0, 0.0, -10.0]" `
  --robot.tray_pos_delta="[0.0, 0.0, 0.0]" `
  --robot.tray_size_base="[0.001, 0.001, 0.001]" `
  --robot.tray_size_delta="[0.0, 0.0, 0.0]" `
  --robot.tray_color_base="[0.0, 0.0, 0.0, 0.0]" `
  --robot.tray_color_delta="[0.0, 0.0, 0.0, 0.0]" `
  --robot.enable_rgb=true `
  --robot.show_cv2=false `
  --teleop.type=so101_ik `
  --dataset.repo_id="CarlosMunoz0/mujoco-so101-stack_cubes-so101_ik-v1" `
  --dataset.single_task="Stack the black cube on top of the blue cube" `
  --dataset.episode_time_s=30 `
  --dataset.num_episodes=10 `
  --reset_every_episode=true `
  --display_data=true 