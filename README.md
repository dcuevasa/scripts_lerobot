# scripts_lerobot

Scripts de grabación de datos, entrenamiento y evaluación de políticas de manipulación robótica con el simulador MuJoCo y el robot SO-101, usando el framework [LeRobot](https://github.com/huggingface/lerobot).

## Estructura

```
scripts_lerobot/
├── record/         # Teleoperación para capturar datasets (mouse, joystick, leader arm)
├── teleop/         # Teleoperación libre sin grabar
├── datasets/       # Procesado: merge, poda (prune), borrado de episodios
├── train/
│   ├── local/      # Entrenamiento en máquina local (ACT, SmolVLA, xVLA, pi0)
│   └── cloud/      # Fine-tuning en Modal (GPU A100 remota)
├── evaluate/
│   ├── smolvla/    # Evaluación SmolVLA en simulación (Windows PS1 + Python wrapper)
│   └── xvla/       # Evaluación xVLA (con adaptación 20→6 DOF)
├── analysis/       # Notebook de curvas de entrenamiento + logs
├── assets/         # Modelo MuJoCo (mjmodel.xml) y logs de simulación
└── sinfonia/       # Scripts legacy con rutas de la máquina Linux "sinfonia"
```

> Los scripts dependen del directorio hermano `FLAG-Embodied-data/` y del entorno `lerobot_venv/` ubicados en la carpeta padre `mlt/`.

---

## Tareas cubiertas

| Tarea | Descripción |
|---|---|
| `stack_cube` | Apilar el cubo negro sobre el cubo azul |
| `cube_on_tray` | Poner el cubo en la bandeja |
| `push_cube_to_tray` | Empujar el cubo hasta la bandeja |
| `take_out_box` | Sacar el cubo de la caja |

---

## Modelos entrenados

### SmolVLA — 305 episodios

| Steps | Modelo |
|---|---|
| 1 000 | [smolvla-so101-merged-1000step_bs16_ep305-v1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-1000step_bs16_ep305-v1) |
| 2 000 | [smolvla-so101-merged-2000step_bs16_ep305-v1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-2000step_bs16_ep305-v1) |
| 3 000 | [smolvla-so101-merged-3000step_bs16_ep305-v1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-3000step_bs16_ep305-v1) |
| 5 000 | [smolvla-so101-merged-5000step_bs16_ep305-v1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-5000step_bs16_ep305-v1) |
| 10 000 | [smolvla-so101-merged-10000step_bs16_ep305-v1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-10000step_bs16_ep305-v1) |
| 20 000 | [smolvla-so101-merged-20000step_bs16_ep305-v1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-20000step_bs16_ep305-v1) |
| 30 000 | [smolvla-so101-merged-30000step_bs16_ep305-v1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-30000step_bs16_ep305-v1) |

### SmolVLA — 400 episodios (v2.1)

| Steps | Modelo |
|---|---|
| 1 000 | [smolvla-so101-merged-4-tasks-1000step_bs16_ep400-v2.1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-4-tasks-1000step_bs16_ep400-v2.1) |
| 2 000 | [smolvla-so101-merged-4-tasks-2000step_bs16_ep400-v2.1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-4-tasks-2000step_bs16_ep400-v2.1) |
| 3 000 | [smolvla-so101-merged-4-tasks-3000step_bs16_ep400-v2.1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-4-tasks-3000step_bs16_ep400-v2.1) |
| 5 000 | [smolvla-so101-merged-4-tasks-5000step_bs16_ep400-v2.1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-4-tasks-5000step_bs16_ep400-v2.1) |
| 10 000 | [smolvla-so101-merged-4-tasks-10000step_bs16_ep400-v2.1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-4-tasks-10000step_bs16_ep400-v2.1) |
| 20 000 | [smolvla-so101-merged-4-tasks-20000step_bs16_ep400-v2.1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-4-tasks-20000step_bs16_ep400-v2.1) |
| 30 000 | [smolvla-so101-merged-4-tasks-30000step_bs16_ep400-v2.1](https://huggingface.co/CarlosMunoz0/smolvla-so101-merged-4-tasks-30000step_bs16_ep400-v2.1) |

### xVLA — 400 episodios (v1.0)

| Steps | Modelo |
|---|---|
| 1 000 | [xvla-so101-merged-4-tasks-1000step_bs16_ep400-v1.0](https://huggingface.co/Celeste-02/xvla-so101-merged-4-tasks-1000step_bs16_ep400-v1.0) |
| 2 000 | [xvla-so101-merged-4-tasks-2000step_bs16_ep400-v1.0](https://huggingface.co/Celeste-02/xvla-so101-merged-4-tasks-2000step_bs16_ep400-v1.0) |
| 3 000 | [xvla-so101-merged-4-tasks-3000step_bs16_ep400-v1.0](https://huggingface.co/Celeste-02/xvla-so101-merged-4-tasks-3000step_bs16_ep400-v1.0) |
| 5 000 | [xvla-so101-merged-4-tasks-5000step_bs16_ep400-v1.0](https://huggingface.co/Celeste-02/xvla-so101-merged-4-tasks-5000step_bs16_ep400-v1.0) |
| 10 000 | [xvla-so101-merged-4-tasks-10000step_bs16_ep400-v1.0](https://huggingface.co/Juanchix/xvla-so101-merged-4-tasks-10000step_bs16_ep400-v1.0) |
| 20 000 | [xvla-so101-merged-4-tasks-20000step_bs16_ep400-v1.0](https://huggingface.co/Celeste-02/xvla-so101-merged-4-tasks-20000step_bs16_ep400-v1.0) |
| 30 000 | [xvla-so101-merged-4-tasks-30000step_bs16_ep400-v1.0](https://huggingface.co/Juanchix/xvla-so101-merged-4-tasks-30000step_bs16_ep400-v1.0) |

---

## Datasets

### Datasets originales (crudos)

| Tarea | Dataset |
|---|---|
| stack\_cubes (joystick) | [CarlosMunoz0/mujoco-so101-stack_cubes-joystick-v2](https://huggingface.co/datasets/CarlosMunoz0/mujoco-so101-stack_cubes-joystick-v2) |
| stack\_cubes (mouse) | [Juanchix/mujoco-so101-stack_cubes-mouse-v1](https://huggingface.co/datasets/Juanchix/mujoco-so101-stack_cubes-mouse-v1) |
| push\_cube\_to\_tray | [Celeste-02/mujoco-so101-push_cube_to_tray](https://huggingface.co/datasets/Celeste-02/mujoco-so101-push_cube_to_tray) |
| take\_out\_box (mouse) | [Juanchix/mujoco-so101-take_out_box-mouse-v1.0](https://huggingface.co/datasets/Juanchix/mujoco-so101-take_out_box-mouse-v1.0) |
| cube\_on\_tray (mouse) | [Juanchix/mujoco-so101-cube_on_tray-mouse-v2](https://huggingface.co/datasets/Juanchix/mujoco-so101-cube_on_tray-mouse-v2) |
| cube\_on\_tray (joystick) | [Celeste-02/mujoco-so101-cube_on_tray-joystick-v1](https://huggingface.co/datasets/Celeste-02/mujoco-so101-cube_on_tray-joystick-v1) |

### Datasets podados para VLA (sin depth, sin EE pose)

| Tarea | Dataset |
|---|---|
| stack\_cubes (joystick) | [CarlosMunoz0/vla-mujoco-so101-stack_cubes-joystick-v2.1](https://huggingface.co/datasets/CarlosMunoz0/vla-mujoco-so101-stack_cubes-joystick-v2.1) |
| stack\_cubes (mouse) | [CarlosMunoz0/vla-mujoco-so101-stack_cubes-mouse-v2.1](https://huggingface.co/datasets/CarlosMunoz0/vla-mujoco-so101-stack_cubes-mouse-v2.1) |
| push\_cube\_to\_tray | [CarlosMunoz0/vla-mujoco-so101-push_cube_to_tray-v2.1](https://huggingface.co/datasets/CarlosMunoz0/vla-mujoco-so101-push_cube_to_tray-v2.1) |
| take\_out\_box (mouse) | [CarlosMunoz0/vla-mujoco-so101-take_out_box-mouse-v2.1](https://huggingface.co/datasets/CarlosMunoz0/vla-mujoco-so101-take_out_box-mouse-v2.1) |
| cube\_on\_tray (mouse) | [CarlosMunoz0/vla-mujoco-so101-cube_on_tray-mouse-v2.1](https://huggingface.co/datasets/CarlosMunoz0/vla-mujoco-so101-cube_on_tray-mouse-v2.1) |
| cube\_on\_tray (joystick) | [CarlosMunoz0/vla-mujoco-so101-cube_on_tray-joystick-v2.1](https://huggingface.co/datasets/CarlosMunoz0/vla-mujoco-so101-cube_on_tray-joystick-v2.1) |

### Dataset merged (4 tareas combinadas)

| Dataset |
|---|
| [CarlosMunoz0/vla-mujoco-so101-merged-4-tasks-v2.1](https://huggingface.co/datasets/CarlosMunoz0/vla-mujoco-so101-merged-4-tasks-v2.1) |
