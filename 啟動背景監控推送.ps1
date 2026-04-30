# File Monitor and Auto-Push (ASCII version for stability)
$path = $PSScriptRoot
$filter = '*.*'

$fsw = New-Object IO.FileSystemWatcher $path, $filter -Property @{
    IncludeSubdirectories = $true
    NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'
}

Write-Host ">>> [Monitoring] System is watching for changes in $path..." -ForegroundColor Cyan

$action = {
    $name = $Event.SourceEventArgs.Name
    if ($name -like "*.git*") { return }

    $changeType = $Event.SourceEventArgs.ChangeType
    Write-Host "[Change Detected] $name ($changeType)" -ForegroundColor Yellow
    
    # Wait 3 seconds for lock release
    Start-Sleep -Seconds 3
    
    cd $path
    git add .
    $status = git status --porcelain
    if ($status) {
        Write-Host "[1/2] Committing..."
        git commit -m "Auto-sync (Watcher): $name"
        Write-Host "[2/2] Pushing to GitHub..."
        git push origin main
        Write-Host "[Success] Synced to cloud!" -ForegroundColor Green
    } else {
        Write-Host "[Skip] No actual changes." -ForegroundColor Gray
    }
}

$handlers = @()
$handlers += Register-ObjectEvent $fsw Created -Action $action
$handlers += Register-ObjectEvent $fsw Changed -Action $action
$handlers += Register-ObjectEvent $fsw Deleted -Action $action
$handlers += Register-ObjectEvent $fsw Renamed -Action $action

try {
    while ($true) { Start-Sleep 5 }
} finally {
    $handlers | ForEach-Object { Unregister-Event -SourceIdentifier $_.Name }
}
