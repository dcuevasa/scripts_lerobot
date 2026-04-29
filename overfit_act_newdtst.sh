. dcuevas_hf_token.sh

lerobot-train \
  --dataset.repo_id=bendca61/vla-mujoco-so101-cube_on_tray-leader-v1 \
  --dataset.revision=main \
  --dataset.episodes='[52]' \
  --policy.type=act \
  --wandb.enable=false \
  --output_dir=outputs/train/act_cube_on_tray_overfit \
  --job_name=act_cube_on_tray_overfit \
  --policy.device=cuda \
  --steps=5000 \
  --batch_size=8 \
  --num_workers=8 \
  --policy.use_amp=true \
  --policy.push_to_hub=true \
  --policy.repo_id=bendca61/act-so101-mujoco-cube_on_tray_overfit_5070 \
  --policy.input_features='{"observation.state":{"type":"STATE","shape":[6]},"observation.images.realsense":{"type":"VISUAL","shape":[3,480,640]},"observation.images.wrist_cam":{"type":"VISUAL","shape":[3,480,640]}}'