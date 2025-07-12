
# GitHub API URL for the app manifest
$apiUrl = "https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/7/7zip/7zip"

# Fetch version folders then filter only version folders
$versions = Invoke-RestMethod -Uri $apiUrl -Headers @{ 'User-Agent' = 'PowerShell' }
$versionFolders = $versions | Where-Object { $_.type -eq "dir" }

# Extract and sort version numbers then get the latest version
$sortedVersions = $versionFolders | ForEach-Object { $_.name } | Sort-Object {[version]$_} -Descending -ErrorAction SilentlyContinue
$latestVersion = $sortedVersions[0]

Try {
    # Get the installed version of WinRAR to the $installedVersion variable
    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($regPath in $regPaths) {
        $apps = Get-ChildItem $regPath -ErrorAction SilentlyContinue
        foreach ($app in $apps) {
            $props = Get-ItemProperty $app.PSPath
            if ($props.DisplayName -like "*7-zip*") {
                $installedVersion = $($props.DisplayVersion)
            }
        }
    }
    If ($installedVersion -ge $latestVersion){
        Write-Output "Compliant"
        Exit 0
    } 
    Write-Warning "Not Compliant"
    Exit 1
} 
Catch {
    Write-Warning "Not Compliant"
    Exit 1
}