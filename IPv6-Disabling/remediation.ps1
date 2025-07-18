# Remediation Script: Disable IPv6 using the DisabledComponents registry key
# This script sets the registry value to completely disable IPv6

# Define the registry path and key
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
$registryName = "DisabledComponents"
$expectedValue = 255  # 0xFF means IPv6 is fully disabled

try 
{
    # Check if the registry path exists
    if (!(Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }
    
    # Set the DisabledComponents registry key to disable IPv6 completely
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $expectedValue -Force
    
    Write-Output "IPv6 has been disabled. A system restart may be required."

    exit 0
} catch 
{
    Write-Error "Failed to disable IPv6: $_"
    exit 1
}        