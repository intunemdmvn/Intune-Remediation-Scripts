# Enable Device Guard
$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
Set-ItemProperty -Path $regKey -Name "EnableVirtualizationBasedSecurity" -Value 1
Set-ItemProperty -Path $regKey -Name "RequirePlatformSecurityFeatures" -Value 1
 
Write-Output "Device Guard has been enabled."      