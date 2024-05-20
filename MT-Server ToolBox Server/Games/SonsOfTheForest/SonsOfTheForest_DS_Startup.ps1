### GAME SERVER STARTUP SCRIPT #########################################################
# Get the parameters passed to the script
$ServerName = $args[0]

###====== Discord Info ======###
Write-Host "Starting $ServerName Dedicated Server" -ForegroundColor Green
$fn_Script = & ".\scripts\fn_DiscordBotMessage.ps1" $webhookUrl ":video_game:`n:white_check_mark: Démarrage du serveur dédié **$ServerName**"

###====== Launch Method ======###

###====== UPnP Zone ======###
# Open UPnP
Write-Host "Opening UPnp Port"
upnpc -e MT-Server_SonsOfTheForest -r 8766 8766 udp 27016 27016 udp 9876 9876 udp