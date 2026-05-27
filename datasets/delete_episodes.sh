#!/usr/bin/env bash
# Borrar episodios (Linux/macOS). En Windows usa: .\delete_episodes.ps1
set -euo pipefail

# Mismo dataset que record_stack_cubes_joystick.ps1
REPO_ID="CarlosMunoz0/mujoco-so101-stack_cubes-joystick-v1"
# Índices 0-based, ej: EPISODES="[0, 2]"
EPISODES="[0]"

# export HF_TOKEN="hf_..."   # necesario si --push_to_hub true

lerobot-edit-dataset \
  --repo_id "$REPO_ID" \
  --new_repo_id "$REPO_ID" \
  --operation.type delete_episodes \
  --operation.episode_indices "$EPISODES" \
  --push_to_hub true