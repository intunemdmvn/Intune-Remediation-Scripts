
# Get the latest version from the GitHub API URL for the app manifest.
    $apiUrl = "https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/7/7zip/7zip"
    $versions = Invoke-RestMethod -Uri $apiUrl -Headers @{ 'User-Agent' = 'PowerShell' }
    $versionFolders = $versions | Where-Object { $_.type -eq "dir" }
    $sortedVersions = $versionFolders | ForEach-Object { $_.name } | Sort-Object {[version]$_} -Descending -ErrorAction SilentlyContinue
    $latestVersion = $sortedVersions[0]

# Get contents of the latest version folder then find the .installer.yaml file.
    $latestApiUrl = "$apiUrl/$latestVersion"
    $latestFiles = Invoke-RestMethod -Uri $latestApiUrl -Headers @{ 'User-Agent' = 'PowerShell' }
    $installerFile = $latestFiles | Where-Object { $_.name -like "*.installer.yaml" }

# Download and parse YAML content to get the Url of the latest installer file.
    $yamlUrl = $installerFile.download_url
    $yamlContent = Invoke-RestMethod -Uri $yamlUrl -Headers @{ 'User-Agent' = 'PowerShell' }
    $yamlString = $yamlContent -join "`n"
    $installerUrls = [regex]::Matches($yamlString, "InstallerUrl:\s+(http[^\s]+)") | ForEach-Object { $_.Groups[1].Value }
    $installerUrl = $installerUrls[1]

# Download the latest installer to the temp folder.
    $webClient = [System.Net.WebClient]::new()
    $webClient.DownloadFile($installerUrl, "$env:TEMP\7-zip-latest.exe")

# If the app is running, stop it before processing the update.
    $process = Get-Process -ProcessName *7z* -ErrorAction SilentlyContinue
    if ($process) {
        $process | Stop-Process -Force
        Start-Sleep -Seconds 3
    }

# Start the update (install) process.
    Start-Process -FilePath "$env:TEMP\7-zip-latest.exe" -ArgumentList "/S" -Wait

# Cleanup resources.
    Remove-Item -Path "$env:TEMP\7-zip-latest.exe" -Force
