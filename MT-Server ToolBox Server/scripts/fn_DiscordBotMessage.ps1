# Get the parameters passed to the script
$webhookUrl = $args[0]
$message = $args[1]
# Use "`n" to Jump a line in $message
#============

$jsonPayload = @{
    content = $message
} | ConvertTo-Json

Invoke-RestMethod -Uri $webhookUrl -Method POST -ContentType 'application/json' -Body $jsonPayload