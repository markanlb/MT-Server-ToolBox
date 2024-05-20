# Get the parameters passed to the script
$webhookUrl = $args[0]
$GameConfigPath = $args[1]
#============

# Read the contents of the JSON file
$JsonContent = Get-Content -Path $GameConfigPath -Raw | ConvertFrom-Json

# Remove unnecessary lines from each game server
$JsonContent.psobject.properties | ForEach-Object {
	$_.Value.PSObject.Properties.Remove('StartMethod')
	$_.Value.PSObject.Properties.Remove('StopMethod')
}

# Convert the modified JSON content back to string
$ModifiedJsonContent = $JsonContent | ConvertTo-Json -Depth 10

# Send modified JSON content to Discord webhook
$jsonPayload = @{
	content = "$ModifiedJsonContent"
}
#===
Write-Host " Sending Client Version of GameConfig.json"
Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $jsonPayload