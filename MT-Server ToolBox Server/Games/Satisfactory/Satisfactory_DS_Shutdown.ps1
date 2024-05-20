### GAME SERVER SHUTDOWN SCRIPT #########################################################
# Get the parameters passed to the script
$ServerName = $args[0]

###====== Discord Info ======###
Write-Host "Shutdown $ServerName Dedicated Server" -ForegroundColor red
$fn_Script = & ".\scripts\fn_DiscordBotMessage.ps1" $webhookUrl ":video_game:`n:x: Arrêt du serveur dédié **$ServerName**"

###====== Shutdown Method ======###

###====== UPnP Zone ======###
# Open UPnP
Write-Host "Closing UPnp Port"
upnpc -d 15777 udp 
upnpc -d 15000 udp
upnpc -d 7777 udp