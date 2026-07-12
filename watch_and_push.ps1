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
                Write-Host "Changes detected at $(Get-Date -Format 'HH:mm:ss'). Syncing..."
                git add -A
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                git commit -m "Auto-sync changes: $timestamp"
                git push origin -u main
                Write-Host "Successfully pushed changes to GitHub."
            }
        }
    } catch {
        Write-Warning "Failed to auto-push changes: $_"
    }
    Start-Sleep -Seconds 60
}
