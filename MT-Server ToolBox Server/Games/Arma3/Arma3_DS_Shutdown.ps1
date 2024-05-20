### GAME SERVER SHUTDOWN SCRIPT #########################################################
# Get the parameters passed to the script
$ServerName = $args[0]

###====== Discord Info ======###
Write-Host "Shutdown $ServerName Dedicated Server" -ForegroundColor red
$fn_Script = & ".\scripts\fn_DiscordBotMessage.ps1" $webhookUrl ":video_game:`n:x: Arrêt du serveur dédié **$ServerName**"

###====== Process Checker ======###
# Process checker to avoid empty action
$processName = "arma3"
$process = Get-Process | Where-Object { $_.Name -like "$processName*" }
if (-not $process) {
	Write-Host " The server is not started" -ForegroundColor Yellow
	Exit # Only exit the script called with operator (&)
}

###====== Shutdown Method ======###
# Stop Process
Stop-Process -Id $process.Id

###====== UPnP Zone ======###
# Open UPnP
Write-Host "Closing UPnp Port"
upnpc -d 33000 udp
