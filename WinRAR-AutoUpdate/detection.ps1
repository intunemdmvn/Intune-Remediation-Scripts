
# Get the latest version from the GitHub API URL for the app manifest.
    $apiUrl = "https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/r/RARLab/WinRAR"
    $versions = Invoke-RestMethod -Uri $apiUrl -Headers @{ 'User-Agent' = 'PowerShell' }
    $versionFolders = $versions | Where-Object { $_.type -eq "dir" }
    $sortedVersions = $versionFolders | ForEach-Object { $_.name } | Sort-Object {[version]$_} -Descending -ErrorAction SilentlyContinue
    $latestVersion = $sortedVersions[0]

# Check the installed version number of the app and store it to the $installedVersion variable.
    try {
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
        )

        foreach ($regPath in $regPaths) {
            $apps = Get-ChildItem $regPath -ErrorAction SilentlyContinue
            foreach ($app in $apps) {
                $props = Get-ItemProperty $app.PSPath
                if ($props.DisplayName -like "*WinRAR*") {
                    $installedVersion = $($props.DisplayVersion)
                }
            }
        }
        # If the installed version is greater than or equal the latest version. Return exit code exit 0 and the remediation script won't run.
        If ($installedVersion -ge $latestVersion){
            Write-Output "Compliant"
            exit 0
        }
        # Return exit code exit 1 and the remediation script will be executed.
        Write-Warning "Not Compliant"
        exit 1
    } 
    catch {
        Write-Warning "Not Compliant"
        exit 1
    }
