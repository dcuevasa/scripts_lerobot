# ── Grabación con control de gamepad (Xbox / PlayStation) ────────────────────
# Uso: .\record_stack_cubes_joystick.ps1
#
# Conecta el control ANTES de ejecutar este script.
# Controles en consola al iniciar (ver tabla impresa al conectar).

$env:HF_TOKEN = ""

python (Join-Path $PSScriptRoot "..\..\FLAG-Embodied-data\lerobot_record_sim.py") `
  --robot.type=so101_mujoco `
  --robot.randomize_scene=true `
  --robot.camera_pos_base="[0.5, 0.5, 0.6]" `
  --robot.camera_euler_base="[2.35619,0,-0.78539]" `
  --robot.box_pos_base="[0.25, 0.08, 0.03]" `
  --robot.box_pos_delta="[0.05, 0.05, 0.0]" `
  --robot.box_color_delta="[0.0, 0.0, 0.0, 0.0]" `
  --robot.box2_pos_base="[0.40, 0.08, 0.03]" `
  --robot.box2_pos_delta="[0.05, 0.05, 0.0]" `
  --robot.box2_color_delta="[0.0, 0.0, 0.0, 0.0]" `
  --robot.enable_rgb=true `
  --robot.show_cv2=false `
  --teleop.type=joystick `
  --teleop.linear_speed=0.003 `
  --teleop.angular_speed=0.025 `
  --teleop.gripper_speed=0.02 `
  --teleop.deadzone=0.08 `
  --teleop.show_viser=false `
  --dataset.repo_id="CarlosMunoz0/mujoco-so101-stack_cubes-joystick-v1" `
  --dataset.single_task="Stack the black cube on top of the blue cube" `
  --dataset.episode_time_s=70 `
  --dataset.num_episodes=2 `
  --reset_every_episode=true `
  --dataset.push_to_hub=true `
  --display_data=false `
  --resume=true
