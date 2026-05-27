SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$SCRIPT_DIR/../dcuevas_hf_token.sh"
# 1. Wipe the old local folder completely
rm -rf ~/.cache/huggingface/lerobot/bendca61/vla-mujoco-so101-cube_on_tray-leader-v1
rm -rf ~/.cache/huggingface/hub/datasets--bendca61--vla-mujoco-so101-cube_on_tray-leader-v1
rm -rf ./temp_dataset_prune

# 2. Run the V3 script with the explicit cutoff flags
python "$SCRIPT_DIR/../../FLAG-Embodied-data/prune_dataset.py \
  --input_repo "bendca61/mujoco-so101-cube_on_tray-leader-v1" \
  --output_repo "bendca61/vla-mujoco-so101-cube_on_tray-leader-v1" \
  --drop_depth \
  --drop_ee