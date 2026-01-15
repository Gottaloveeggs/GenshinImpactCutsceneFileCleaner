# -----------------------------------------------------------------------------
# Script Name: Genshin Video Asset Cleaner
# Description: Deletes specific video assets based on user selection.
#              Sends files to Recycle Bin for safety.
# -----------------------------------------------------------------------------

# --- ADMIN CHECK ---
# Checks if the script is running as Administrator. If not, re-launches as Admin.
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    try {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        Exit
    }
    catch {
        Write-Host "Failed to elevate privileges. Please run as Administrator manually." -ForegroundColor Red
        Write-Host "Press Enter to exit..."
        $null = Read-Host
        Exit
    }
}

# --- CRASH PROTECTION ---
# This ensures the window stays open if an error occurs immediately
$ErrorActionPreference = "Stop"
trap {
    Write-Host ""
    Write-Host "An unexpected error occurred!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press Enter to exit..."
    $null = Read-Host
    Exit
}

# Load VisualBasic assembly to access Recycle Bin functionality
Add-Type -AssemblyName Microsoft.VisualBasic

# Define the target directory
$TargetDir = "C:\Program Files\Epic Games\GenshinImpact\games\Genshin Impact game\GenshinImpact_Data\StreamingAssets\VideoAssets\StandaloneWindows64"

# Check if directory exists
if (-not (Test-Path -Path $TargetDir)) {
    Write-Host "Error: Directory not found!" -ForegroundColor Red
    Write-Host "Path: $TargetDir" -ForegroundColor Yellow
    Write-Host "Please check your installation path."
    Write-Host "Press Enter to exit..."
    $null = Read-Host
    Exit
}

# Change location to the directory
Set-Location -Path $TargetDir

# Helper function to format file sizes (MB/GB)
function Format-Size {
    param ([long]$Bytes)
    if ($Bytes -gt 1GB) {
        return "{0:N2} GB" -f ($Bytes / 1GB)
    } elseif ($Bytes -gt 1MB) {
        return "{0:N2} MB" -f ($Bytes / 1MB)
    } else {
        return "{0:N2} KB" -f ($Bytes / 1KB)
    }
}

# Function to safely recycle files
function Send-ToRecycleBin {
    param (
        [string]$FilePath
    )
    try {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($FilePath, 
            [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs, 
            [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin)
        Write-Host "Recycled: $FilePath" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Error recycling: $FilePath" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
    }
}

# --- MAIN APP LOOP ---
do {
    Clear-Host
    
    # Calculate Total Folder Size
    $allFiles = Get-ChildItem -Path $TargetDir -File
    $totalSizeObj = $allFiles | Measure-Object -Property Length -Sum
    $formattedTotal = Format-Size $totalSizeObj.Sum

    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "    GENSHIN IMPACT CUTSCENE FILE CLEANER    " -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "DISCLAIMER: Use at your own risk." -ForegroundColor Red
    Write-Host "NOTE: Updates or 'Verifying Integrity' will restore these files." -ForegroundColor Red
    Write-Host "Repo: https://github.com/YourUsername/GenshinCleaner" -ForegroundColor DarkGray
    Write-Host "------------------------------------------" -ForegroundColor DarkCyan
    Write-Host "Folder Total Size: $formattedTotal" -ForegroundColor White
    Write-Host ""
    Write-Host "What files do you want to delete?" -ForegroundColor Yellow
    Write-Host "1. Aether related files"
    Write-Host "2. Lumine related files"
    Write-Host "3. Mondstadt related files"
    Write-Host "4. Liyue related files"
    Write-Host "5. Inazuma related files"
    Write-Host "6. Sumeru related files"
    Write-Host "7. Fontaine related files"
    Write-Host "8. Natlan related files"
    Write-Host "9. Nod-Krai related files"
    Write-Host "10. Other/Misc files"
    Write-Host "11. Undo (Open Recycle Bin)"
    Write-Host "Q. Quit"
    Write-Host ""
    Write-Host "Tip: You can select multiple (e.g., '1, 2') or ranges (e.g., '3-5')" -ForegroundColor Gray
    
    $inputStr = Read-Host "Enter your choice(s)"

    # Check for Quit immediately
    if ($inputStr -match "Q" -or $inputStr -match "q") {
        Write-Host "Exiting..."
        break
    }

    # Process Multi-Selection and Ranges
    $rawParts = $inputStr -split '[, ]+' | Where-Object { $_ -ne "" }
    $selections = @()

    foreach ($part in $rawParts) {
        if ($part -match '^(\d+)-(\d+)$') {
            # Handle Range (e.g., 2-5)
            $start = [int]$matches[1]
            $end = [int]$matches[2]
            if ($start -le $end) {
                $start..$end | ForEach-Object { $selections += "$_" }
            }
        } else {
            # Single item
            $selections += $part
        }
    }
    
    # We will build a list of "Task Objects" to keep categories separate for display
    $searchTasks = @()
    $isUndo = $false

    foreach ($sel in $selections) {
        switch ($sel) {
            "1" { $searchTasks += [PSCustomObject]@{ Name="Aether"; Patterns=@("*boy*") } }
            "2" { $searchTasks += [PSCustomObject]@{ Name="Lumine"; Patterns=@("*girl*") } }
            "3" { $searchTasks += [PSCustomObject]@{ Name="Mondstadt"; Patterns=@("*MDA*", "*ChangeWeather*", "*Mengde*", "*VentiLegends*", "*Ambor_Readings*") } }
            "4" { $searchTasks += [PSCustomObject]@{ Name="Liyue"; Patterns=@("*LiYue*", "*Liyue*", "*Summon*", "*BeforeBattle*", "*AfterBattle*", "*GYPersonal*", "*ShenheBattle*", "*Yunjin*", "*NingGuang*", "*LongWangStroy*", "*XiaoPersonal*") } }
            "5" { $searchTasks += [PSCustomObject]@{ Name="Inazuma"; Patterns=@("*Inazuma*", "*ShougunBossPart*", "*SHG*", "*DaoQiDengdao*", "*Ayaka*", "*WanYeXianVideo*") } }
            "6" { $searchTasks += [PSCustomObject]@{ Name="Sumeru"; Patterns=@("*Sumeru*") } }
            "7" { $searchTasks += [PSCustomObject]@{ Name="Fontaine"; Patterns=@("*Fontaine*") } }
            "8" { $searchTasks += [PSCustomObject]@{ Name="Natlan"; Patterns=@("*Natlan*") } }
            "9" { $searchTasks += [PSCustomObject]@{ Name="Nod-Krai"; Patterns=@("*NodKrai*") } }
            "10" { $searchTasks += [PSCustomObject]@{ Name="Other/Misc"; Patterns=@("Video_Reunion_63.usm", "battlePass.usm", "*ShieldingResources*", "*Memories*") } }
            "11" { 
                Write-Host "Opening Recycle Bin..." -ForegroundColor Cyan
                Start-Process "explorer.exe" -ArgumentList "shell:RecycleBinFolder"
                $isUndo = $true
            }
            Default { 
                # Ignore invalid inputs
            }
        }
    }

    if ($isUndo) {
        Write-Host "Tip: You can restore deleted files by right-clicking them in the Recycle Bin."
        Write-Host "Press Enter to continue..."
        $null = Read-Host
        continue
    }

    if ($searchTasks.Count -eq 0) {
        Write-Host "No valid selections made. Please try again." -ForegroundColor Red
        Write-Host "Press Enter to continue..."
        $null = Read-Host
        continue
    }

    Write-Host ""
    Write-Host "--- Scanning Files ---" -ForegroundColor Yellow
    
    $masterDeleteList = @()
    $filesFoundAny = $false

    # Process each category separately to display them in groups
    foreach ($task in $searchTasks) {
        
        # Get files for this specific category
        $filesForCategory = Get-ChildItem -Path $TargetDir -File | Where-Object {
            $fileName = $_.Name
            foreach ($pat in $task.Patterns) {
                if ($fileName -like $pat) { return $true }
            }
            return $false
        }

        if ($filesForCategory.Count -gt 0) {
            $filesFoundAny = $true
            Write-Host ""
            Write-Host "--- $($task.Name) Files ---" -ForegroundColor Magenta
            
            # Show ALL files for this category (no shortening)
            $catSize = $filesForCategory | Measure-Object -Property Length -Sum
            Write-Host "Count: $($filesForCategory.Count) | Size: $(Format-Size $catSize.Sum)" -ForegroundColor Gray
            
            $filesForCategory | Select-Object Name, @{Name="Size";Expression={Format-Size $_.Length}} | Format-Table -AutoSize -HideTableHeaders
            
            # Add to master list
            $masterDeleteList += $filesForCategory
        }
    }

    # Deduplicate master list (in case a file matched two categories)
    if ($masterDeleteList.Count -gt 0) {
        $masterDeleteList = $masterDeleteList | Select-Object -Unique
    }

    # Confirm and Execute
    if ($filesFoundAny) {
        # Calculate TOTAL size of all selected files
        $totalSelectedSizeObj = $masterDeleteList | Measure-Object -Property Length -Sum
        $formattedSelected = Format-Size $totalSelectedSizeObj.Sum

        Write-Host ""
        Write-Host "------------------------------------------" -ForegroundColor DarkCyan
        Write-Host "TOTAL FILES TO DELETE: $($masterDeleteList.Count)" -ForegroundColor Green
        Write-Host "TOTAL SIZE TO RECLAIM: $formattedSelected" -ForegroundColor Green
        Write-Host "------------------------------------------" -ForegroundColor DarkCyan
        Write-Host ""
        
        $confirm = Read-Host "Are you sure you want to move these files to the Recycle Bin? (Y/N)"
        
        if ($confirm.ToUpper() -eq "Y") {
            foreach ($file in $masterDeleteList) {
                Send-ToRecycleBin -FilePath $file.FullName
            }
            Write-Host "Operation Complete." -ForegroundColor Green
            Write-Host "IMPORTANT: Empty your Recycle Bin to fully permanently delete these files!" -ForegroundColor Yellow
            Write-Host "Press Enter to return to menu..."
            $null = Read-Host
        } else {
            Write-Host "Operation Cancelled. Returning to menu..." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    } else {
        Write-Host "No files found matching your selection." -ForegroundColor Yellow
        Write-Host "Press Enter to return to menu..."
        $null = Read-Host
    }

} until ($false)