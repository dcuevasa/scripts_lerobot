. dcuevas_hf_token.sh
lerobot-train \
  --dataset.repo_id=bendca61/vla-mujoco-so101-cube_on_tray-leader-v1 \
  --dataset.revision=main \
  --policy.type=act \
  --wandb.enable=false \
  --output_dir=outputs/train/act_cube_on_tray_v1 \
  --job_name=act_cube_on_tray_v1 \
  --policy.device=cuda \
  --steps=8000 \
  --save_freq=2000 \
  --batch_size=8 \
  --num_workers=8 \
  --policy.use_amp=true \
  --policy.push_to_hub=true \
  --policy.repo_id=bendca61/act-so101-mujoco-cube_on_tray-v1 \
  --resume=true