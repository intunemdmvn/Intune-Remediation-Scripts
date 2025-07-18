# Define the required time zone
$requiredTimeZone = "Pacific Standard Time"
 
# Set the time zone
Set-TimeZone -Id $requiredTimeZone
 
Write-Output "Time zone has been set to: $requiredTimeZone"  