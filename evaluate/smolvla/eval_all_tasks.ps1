# ==============================================================================
# eval_all_tasks.ps1  --  Evaluacion batch: N modelos x 4 tareas
# ------------------------------------------------------------------------------
# Estructura de salida:
#   eval_results/
#     <model_short_name>/
#       cube_on_tray/        <- videos copiados aqui
#       stack_cube/
#       push_cube_to_tray/
#       take_out_box/
#
# Uso:
#   .\eval_all_tasks.ps1
#   .\eval_all_tasks.ps1 -N_EPISODES 10 -EPISODE_TIME_S 120
#   .\eval_all_tasks.ps1 -N_EPISODES 3 -Tasks @("cube_on_tray","stack_cube")
# ==============================================================================

param(
    [int]$N_EPISODES     = 5,
    [int]$EPISODE_TIME_S = 1000,
    [string[]]$Tasks     = @(),
    [string]$OutputRoot  = (Join-Path $PSScriptRoot "eval_results")
)

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------------------------
# 1. MODELOS A EVALUAR
#    Agrega o quita lineas segun los checkpoints entrenados.
#    Puede ser un Hub ID o una ruta local al pretrained_model.
# ------------------------------------------------------------------------------
$MODELS = @(
    "CarlosMunoz0/smolvla-so101-merged-4-tasks-30000step_bs16_ep400-v2.1"
    # "CarlosMunoz0/smolvla-so101-merged-4-tasks-30000step_bs16_ep400-v2.1"
    # "C:/ruta/local/checkpoints/last/pretrained_model"
)

# ------------------------------------------------------------------------------
# 2. DEFINICION DE TAREAS
# ------------------------------------------------------------------------------
$TASK_DEFS = [ordered]@{

    cube_on_tray = @{
        Label     = "Put the cube on the tray"
        XmlPath   = "./robotstudio_so101/so101_cube_on_tray.xml"
        Randomize = "true"
        TaskArgs  = @(
            "--robot.camera_pos_base=[0.5, 0.5, 0.6]"
            "--robot.camera_euler_base=[2.35619,0,-0.78539]"
            "--robot.box_pos_base=[0.35, 0.2, 0.03]"
            "--robot.box_pos_delta=[0.05, 0.05, 0.0]"
            "--robot.box_size_base=[0.02, 0.02, 0.03]"
            "--robot.box_size_delta=[0.0, 0.0, 0.0]"
            "--robot.box_color_base=[0.1, 0.1, 0.1, 1.0]"
            "--robot.box_color_delta=[0.0, 0.0, 0.0, 0.0]"
            "--robot.tray_pos_base=[0.1, 0.35, 0.01]"
            "--robot.tray_pos_delta=[0.0, 0.0, 0.0]"
            "--robot.tray_size_base=[0.08, 0.08, 0.01]"
            "--robot.tray_size_delta=[0.0, 0.0, 0.0]"
            "--robot.tray_color_base=[0.8, 0.1, 0.1, 1.0]"
            "--robot.tray_color_delta=[0.0, 0.0, 0.0, 0.0]"
        )
    }

    stack_cube = @{
        Label     = "Stack the black cube on top of the blue cube"
        XmlPath   = "./robotstudio_so101/so101_stack_cube.xml"
        Randomize = "true"
        TaskArgs  = @(
            "--robot.camera_pos_base=[0.5, 0.5, 0.6]"
            "--robot.camera_euler_base=[2.35619,0,-0.78539]"
            "--robot.box_pos_base=[0.25, 0.08, 0.03]"
            "--robot.box_pos_delta=[0.06, 0.06, 0.0]"
            "--robot.box_size_base=[0.02, 0.02, 0.03]"
            "--robot.box_size_delta=[0.0, 0.0, 0.0]"
            "--robot.box_color_base=[0.1, 0.1, 0.1, 1.0]"
            "--robot.box_color_delta=[0.0, 0.0, 0.0, 0.0]"
            "--robot.box2_pos_base=[0.40, 0.05, 0.03]"
            "--robot.box2_pos_delta=[0.05, 0.05, 0.0]"
            "--robot.box2_size_base=[0.02, 0.02, 0.03]"
            "--robot.box2_size_delta=[0.0, 0.0, 0.0]"
            "--robot.box2_color_base=[0.1, 0.1, 0.8, 1.0]"
            "--robot.box2_color_delta=[0.0, 0.0, 0.0, 0.0]"
        )
    }

    push_cube_to_tray = @{
        Label     = "Push the block into the tray"
        XmlPath   = "./robotstudio_so101/so101_push_cube_to_tray.xml"
        Randomize = "true"
        TaskArgs  = @(
            "--robot.camera_pos_base=[0.5, 0.5, 0.6]"
            "--robot.camera_euler_base=[2.35619,0,-0.78539]"
            "--robot.box_pos_base=[0.35, 0.0, 0.04]"
            "--robot.box_pos_delta=[0.04, 0.05, 0.0]"
            "--robot.box_size_base=[0.02, 0.02, 0.03]"
            "--robot.box_size_delta=[0.005, 0.005, 0.005]"
            "--robot.box_color_base=[0.1, 0.1, 0.1, 1.0]"
            "--robot.box_color_delta=[0.0, 0.0, 0.0, 0.0]"
            "--robot.tray_pos_base=[0.35, 0.25, 0.01]"
            "--robot.tray_pos_delta=[0.05, 0.05, 0.0]"
            "--robot.tray_size_base=[0.12, 0.12, 0.001]"
            "--robot.tray_size_delta=[0.02, 0.02, 0.0]"
            "--robot.tray_color_base=[0.1, 0.8, 0.1, 1.0]"
            "--robot.tray_color_delta=[0.0, 0.0, 0.0, 0.0]"
        )
    }

    take_out_box = @{
        Label     = "Take the block out of the tray"
        XmlPath   = "./robotstudio_so101/so101_take_out_box.xml"
        Randomize = "true"
        TaskArgs  = @(
            "--robot.camera_pos_base=[0.5, 0.5, 0.6]"
            "--robot.camera_euler_base=[2.35619,0,-0.78539]"
            "--robot.tray_pos_base=[0.35, 0.0, 0.01]"
            "--robot.tray_pos_delta=[0.05, 0.05, 0.0]"
            "--robot.tray_size_base=[0.12, 0.12, 0.01]"
            "--robot.tray_size_delta=[0.02, 0.02, 0.0]"
            "--robot.tray_color_base=[0.7, 0.35, 0.1, 1.0]"
            "--robot.tray_color_delta=[0.0, 0.0, 0.0, 0.0]"
            "--robot.box_pos_base=[0.35, 0.0, 0.04]"
            "--robot.box_pos_delta=[0.04, 0.05, 0.0]"
            "--robot.box_size_base=[0.02, 0.02, 0.02]"
            "--robot.box_size_delta=[0.005, 0.005, 0.0025]"
            "--robot.box_color_base=[0.1, 0.1, 0.1, 1.0]"
            "--robot.box_color_delta=[0.0, 0.0, 0.0, 0.0]"
        )
    }
}

# Filtrar tareas si se especifico un subconjunto
$ActiveTasks = if ($Tasks.Count -gt 0) {
    $TASK_DEFS.Keys | Where-Object { $Tasks -contains $_ }
} else {
    $TASK_DEFS.Keys
}

# ------------------------------------------------------------------------------
# 3. HELPERS
# ------------------------------------------------------------------------------
function Get-ModelShortName([string]$modelPath) {
    if ($modelPath -match "/") { return $modelPath.Split("/")[-1] }
    return Split-Path $modelPath -Leaf
}

function Copy-Videos([string]$hfCache, [string]$destDir) {
    $videos = Get-ChildItem -Path $hfCache -Recurse -Filter "*.mp4" -ErrorAction SilentlyContinue
    if (-not $videos -or $videos.Count -eq 0) {
        Write-Warning "  No se encontraron MP4s en $hfCache"
        return 0
    }
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    foreach ($v in $videos) {
        Copy-Item -Path $v.FullName -Destination $destDir -Force
    }
    return $videos.Count
}

# ------------------------------------------------------------------------------
# 4. LOOP PRINCIPAL
# ------------------------------------------------------------------------------
$totalRuns  = $MODELS.Count * @($ActiveTasks).Count
$currentRun = 0
$summary    = @()

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
$headerMsg = "  Eval batch: $($MODELS.Count) modelo(s) x $(@($ActiveTasks).Count) tarea(s) x $N_EPISODES ep x $EPISODE_TIME_S s"
Write-Host $headerMsg -ForegroundColor Cyan
Write-Host "  Salida: $OutputRoot" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

foreach ($modelPath in $MODELS) {
    $modelShort  = Get-ModelShortName $modelPath
    $modelOutDir = Join-Path $OutputRoot $modelShort

    Write-Host ">> Modelo: $modelShort" -ForegroundColor Yellow
    Write-Host "   Path:   $modelPath"
    Write-Host ""

    foreach ($taskName in $ActiveTasks) {
        $currentRun++
        $t = $TASK_DEFS[$taskName]

        $progressMsg = "[$currentRun/$totalRuns] Tarea: $taskName - $N_EPISODES episodios"
        Write-Host "   $progressMsg" -ForegroundColor Green

        $evalRepo  = "local/eval__${modelShort}__${taskName}"
        $hfCache   = Join-Path $env:USERPROFILE ".cache\huggingface\lerobot\$evalRepo"
        $taskOutDir = Join-Path $modelOutDir $taskName

        # Limpiar cache previa
        if (Test-Path $hfCache) {
            Remove-Item -LiteralPath $hfCache -Recurse -Force
        }

        # Construir lista de argumentos para python
        $pyArgs = @(
            (Join-Path $PSScriptRoot "run_smolvla_merged.py")
            "--robot.type=so101_mujoco"
            "--robot.xml_path=$($t.XmlPath)"
            "--robot.randomize_scene=$($t.Randomize)"
            "--robot.enable_rgb=true"
            "--robot.enable_depth=false"
            "--robot.enable_wrist_cam=false"
            "--robot.enable_ee_pose=false"
            "--robot.show_cv2=false"
        ) + $t.TaskArgs + @(
            "--dataset.repo_id=$evalRepo"
            "--dataset.single_task=$($t.Label)"
            "--dataset.episode_time_s=$EPISODE_TIME_S"
            "--dataset.num_episodes=$N_EPISODES"
            "--dataset.push_to_hub=false"
            '--dataset.rename_map={"observation.images.realsense": "observation.images.image"}'
            "--policy.path=$modelPath"
            "--display_data=false"
        )

        $exitCode = 0
        try {
            & python @pyArgs
            $exitCode = $LASTEXITCODE
        }
        catch {
            $exitCode = 1
            Write-Warning "  Excepcion al ejecutar python: $($_.Exception.Message)"
        }

        # Copiar videos a carpeta organizada
        $copiedCount = 0
        if ($exitCode -eq 0) {
            $copiedCount = Copy-Videos $hfCache $taskOutDir
            Write-Host "   Videos copiados: $copiedCount  -->  $taskOutDir"
        }
        else {
            Write-Warning "  Eval termino con codigo $exitCode - se omite copia de videos."
        }

        $summary += [PSCustomObject]@{
            Modelo    = $modelShort
            Tarea     = $taskName
            Episodios = $N_EPISODES
            Videos    = $copiedCount
            OK        = ($exitCode -eq 0)
        }

        Write-Host ""
    }

    Write-Host "   Modelo $modelShort listo --> $modelOutDir"
    Write-Host ""
}

# ------------------------------------------------------------------------------
# 5. RESUMEN FINAL
# ------------------------------------------------------------------------------
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  RESUMEN" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
$summary | Format-Table -AutoSize
Write-Host "Resultados en: $OutputRoot"
