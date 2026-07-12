# watch_and_push.ps1
# PowerShell script to automatically stage, commit, and push changes in background.

$repoPath = "d:\health_app\health_companion"
Set-Location $repoPath

Write-Host "Starting Git Auto-Push Watcher in $repoPath..."

while ($true) {
    try {
        if (Test-Path "$repoPath\.git") {
            $status = git status --porcelain
            if ($status) {
                $statusMsg = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Changes detected. Syncing..."
                Add-Content -Path "$repoPath\watch_and_push.log" -Value $statusMsg
                
                git add -A
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                git commit -m "Auto-sync changes: $timestamp"
                git push origin main
                
                $successMsg = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Successfully pushed changes to GitHub."
                Add-Content -Path "$repoPath\watch_and_push.log" -Value $successMsg
            }
        }
    } catch {
        $errMsg = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Failed to auto-push: $_"
        Add-Content -Path "$repoPath\watch_and_push.log" -Value $errMsg
    }
    Start-Sleep -Seconds 30
}
