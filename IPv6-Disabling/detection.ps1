# Check if IPv6 is disabled using the DisabledComponents registry key
# Define the registry path and key
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
$registryName = "DisabledComponents"
$expectedValue = 255  # 0xFF means IPv6 is fully disabled

try {
    $currentValue = Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $registryName -ErrorAction SilentlyContinue
    if ($currentValue -eq $expectedValue) {
        Write-Output "IPv6 is disabled"
        exit 0 # Return compliant state
    } else {
        Write-Output "IPv6 is Enabled"
        exit 1 # Return non-compliant state
    }
} catch {
    Write-Output "IPv6 is Enabled"
    exit 1 # Return non-compliant state
}        