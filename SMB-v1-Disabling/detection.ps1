$smbv1 = get-smbserverconfiguration | Select-Object -ExpandProperty EnableSMB1Protocol
if ($smbv1 -eq $false) {
    write-host "SMBv1 is disabled"
    exit 0
}
else {
    write-host "SMBv1 is enabled"
    exit 1
}  