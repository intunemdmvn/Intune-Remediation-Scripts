
# GitHub API URL for the app manifest
$apiUrl = "https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/7/7zip/7zip"

# Fetch version folders then filter only version folders
$versions = Invoke-RestMethod -Uri $apiUrl -Headers @{ 'User-Agent' = 'PowerShell' }
$versionFolders = $versions | Where-Object { $_.type -eq "dir" }

# Extract and sort version numbers then get the latest version
$sortedVersions = $versionFolders | ForEach-Object { $_.name } | Sort-Object {[version]$_} -Descending -ErrorAction SilentlyContinue
$latestVersion = $sortedVersions[0]

# Get contents of the latest version folder then find the .installer.yaml file
$latestApiUrl = "$apiUrl/$latestVersion"
$latestFiles = Invoke-RestMethod -Uri $latestApiUrl -Headers @{ 'User-Agent' = 'PowerShell' }
$installerFile = $latestFiles | Where-Object { $_.name -like "*.installer.yaml" }

# Download and parse YAML content to get the Url of the latest installer file.
$yamlUrl = $installerFile.download_url
$yamlContent = Invoke-RestMethod -Uri $yamlUrl -Headers @{ 'User-Agent' = 'PowerShell' }
$installerUrl = ($yamlContent -join "`n") -match "InstallerUrl:\s+(http.*)" | ForEach-Object { $Matches[1] }

# Download the latest installer then starting update process.
if ($installedVersion -lt $latestVersion) {
    $webClient = [System.Net.WebClient]::new()
    $webClient.DownloadFile($installerUrl, "$env:TEMP\7-zip-latest.exe")

    $process = Get-Process -ProcessName *7z* -ErrorAction SilentlyContinue
    if ($process) {
        $process | Stop-Process -Force
    }

    Start-Process -FilePath "$env:TEMP\7-zip-latest.exe" -ArgumentList "/S" -Wait

    # Cleanup
    Remove-Item -Path "$env:TEMP\7-zip-latest.exe" -Force
    
}