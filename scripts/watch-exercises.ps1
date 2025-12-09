# ==========================================
# Exercise Watcher - PowerShell Version
# Auto-activates exercises when uncommented
# ==========================================

$EXERCISE_DIR = "./exercises"
$TYK_APPS_DIR = "./gateway-configs/tyk/apps-active"
$TYK_GATEWAY_URL = "http://localhost:8080"
$KONG_ADMIN_URL = "http://localhost:8001"

Write-Host "API Gateway Exercise Watcher Started" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Monitoring: $EXERCISE_DIR"
Write-Host ""

# Create apps-active directory if it doesn't exist
New-Item -ItemType Directory -Force -Path $TYK_APPS_DIR | Out-Null

# Function to check if a file is uncommented
function Test-Uncommented {
    param ([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        return $false
    }

    $content = Get-Content $FilePath -Raw

    # For JSON files (Tyk)
    if ($FilePath -like "*.json") {
        # Check if file starts with { instead of //{
        if ($content -match "^\s*\{") {
            return $true
        }
    }

    # For shell scripts (Kong)
    if ($FilePath -like "*.sh") {
        # Check if file has uncommented curl commands
        if ($content -match "(?m)^curl") {
            return $true
        }
    }

    # For PowerShell scripts (Kong)
    if ($FilePath -like "*.ps1") {
        # Check if file has uncommented Invoke-RestMethod commands (or aliases like irm, iwr)
        # Regex updated to catch direct calls OR variable assignments (e.g., $res = irm ...)
        if ($content -match "(?m)^\s*(\$\w+\s*=\s*)?(Invoke-RestMethod|irm|iwr)") {
            return $true
        }
    }

    return $false
}

# Function to activate Tyk exercise
function Enable-TykExercise {
    param (
        [int]$ExerciseNum,
        [string]$ConfigFile
    )

    Write-Host "Activating Tyk Exercise $ExerciseNum..." -ForegroundColor Green

    # Copy config to active apps directory
    $fileName = Split-Path $ConfigFile -Leaf
    $targetFile = Join-Path $TYK_APPS_DIR "$ExerciseNum-$fileName"

    Copy-Item $ConfigFile $targetFile -Force

    Write-Host "   Config copied to: $targetFile"

    # Check if there's an activate.ps1 or activate.sh script and run it
    $exerciseDir = Split-Path $ConfigFile -Parent
    $activatePs1 = Join-Path $exerciseDir "activate.ps1"
    $activateSh = Join-Path $exerciseDir "activate.sh"

    if (Test-Path $activatePs1) {
        Write-Host "   Running activation script (PowerShell)..." -ForegroundColor Yellow
        try {
            Push-Location $exerciseDir
            & .\activate.ps1 2>&1 | Out-Null
            Pop-Location
        } catch {
            Pop-Location
            Write-Host "   Warning: Error running activation script" -ForegroundColor Yellow
        }
    } elseif ((Test-Path $activateSh) -and (Get-Command bash -ErrorAction SilentlyContinue)) {
        Write-Host "   Running activation script (Bash)..." -ForegroundColor Yellow
        try {
            Push-Location $exerciseDir
            bash activate.sh 2>&1 | Out-Null
            Pop-Location
        } catch {
            Pop-Location
            Write-Host "    Warning: Error running activation script" -ForegroundColor Yellow
        }
    } else {
        # Just reload Tyk if no activation script
        Write-Host "    Reloading Tyk Gateway..." -ForegroundColor Yellow
        try {
            $headers = @{
                "x-tyk-authorization" = "foo"
            }
            Invoke-RestMethod -Uri "$TYK_GATEWAY_URL/tyk/reload/group" -Headers $headers -Method Get -ErrorAction SilentlyContinue | Out-Null
        } catch {
            # Ignore errors
        }
    }

    Write-Host "    Tyk Exercise $ExerciseNum activated!" -ForegroundColor Green
    Write-Host ""
}

# Function to activate Kong exercise
function Enable-KongExercise {
    param (
        [int]$ExerciseNum,
        [string]$ScriptFile
    )

    Write-Host "Activating Kong Exercise $ExerciseNum..." -ForegroundColor Green

    # Execute the script
    Write-Host "   Running setup script..." -ForegroundColor Yellow
    $scriptDir = Split-Path $ScriptFile -Parent
    $scriptName = Split-Path $ScriptFile -Leaf

    try {
        Push-Location $scriptDir

        # Check if it's a PowerShell script
        if ($scriptName -like "*.ps1") {
            & ".\$scriptName" 2>&1 | Out-Null
        }
        # Or a Bash script (requires Git Bash or WSL)
        elseif ($scriptName -like "*.sh") {
            if (Get-Command bash -ErrorAction SilentlyContinue) {
                bash $scriptName 2>&1 | Out-Null
            } else {
                Write-Host "   Warning: bash not found. Please run the script manually or install Git Bash." -ForegroundColor Yellow
            }
        }

        Pop-Location
    } catch {
        Pop-Location
        Write-Host "   Warning: Error running setup script" -ForegroundColor Yellow
    }

    Write-Host "   Kong Exercise $ExerciseNum activated!" -ForegroundColor Green
    Write-Host ""
}

# Function to check and activate exercises
function Test-Exercises {
    # Check Tyk exercises
    for ($i = 1; $i -le 9; $i++) {
        $paddedNum = $i.ToString("00")
        $exDirs = Get-ChildItem -Path "$EXERCISE_DIR/tyk" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "$paddedNum-*" }

        foreach ($exDir in $exDirs) {
            $configFile = Join-Path $exDir.FullName "config.json"
            $markerFile = Join-Path $exDir.FullName ".activated"

            if ((Test-Path $configFile) -and (Test-Uncommented $configFile) -and (-not (Test-Path $markerFile))) {
                Enable-TykExercise $i $configFile
                New-Item -ItemType File -Force -Path $markerFile | Out-Null
            }
        }
    }

    # Check Kong exercises
    for ($i = 1; $i -le 9; $i++) {
        $paddedNum = $i.ToString("00")
        $exDirs = Get-ChildItem -Path "$EXERCISE_DIR/kong" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "$paddedNum-*" }

        foreach ($exDir in $exDirs) {
            $markerFile = Join-Path $exDir.FullName ".activated"
            $setupFile = $null # Stores the path of the script to execute

            # Skip if already activated
            if (Test-Path $markerFile) {
                continue
            }

            # ---------------------------------------------------------
            # UPDATED LOGIC: Check both, prioritize PowerShell
            # ---------------------------------------------------------

            # 1. Check setup.ps1 (Priority check for PowerShell environment)
            $ps1File = Join-Path $exDir.FullName "setup.ps1"
            if ((Test-Path $ps1File) -and (Test-Uncommented $ps1File)) {
                $setupFile = $ps1File
            }

            # 2. Check setup.sh (Fallback if PS1 is not chosen/available)
            if ($setupFile -eq $null) {
                $shFile = Join-Path $exDir.FullName "setup.sh"
                if ((Test-Path $shFile) -and (Test-Uncommented $shFile)) {
                    $setupFile = $shFile
                }
            }

            # If a file was found and uncommented, activate the exercise
            if ($setupFile -ne $null) {
                Enable-KongExercise $i $setupFile
                New-Item -ItemType File -Force -Path $markerFile | Out-Null
            }
        }
    }
}

# Initial check
Write-Host "Performing initial check..." -ForegroundColor Yellow
Test-Exercises

Write-Host "Now watching for changes..." -ForegroundColor Cyan
Write-Host "   Edit exercise files to activate them!" -ForegroundColor Cyan
Write-Host ""

# Watch loop
while ($true) {
    Start-Sleep -Seconds 5
    Test-Exercises
}