### GAME SERVER STARTUP SCRIPT #########################################################
# Get the parameters passed to the script
$ServerName = $args[0]

###====== Discord Info ======###
Write-Host "Starting $ServerName Dedicated Server" -ForegroundColor Green
$fn_Script = & ".\scripts\fn_DiscordBotMessage.ps1" $webhookUrl ":video_game:`n:white_check_mark: Démarrage du serveur dédié **$ServerName**"

###====== Process Checker ======###
# Process checker to avoid double triggering
$processName = "arma3"
$process = Get-Process | Where-Object { $_.Name -like "$processName*" }
if ($process) {
	Write-Host " The server is already started" -ForegroundColor Yellow
	Exit # Only exit the script called with operator (&)
}

###====== Launch Method ======###
# File Path
& "C:\Program Files (x86)\Steam\steamapps\common\Arma 3\arma3server_x64.exe" -profiles="C:\Users\Administrateur\AppData\Local\Arma 3" -name=MT-Server-Toolbox -cpuCount=8 -exThreads=7 -enableHT -malloc=mimalloc_v212 -hugePages -maxmem=16000 -maxvram=4096 -port=33000 -password=MT-001 "-cfg=C:\Program Files (x86)\Steam\steamapps\common\Arma 3\basic.cfg" "-config=C:\Program Files (x86)\Steam\steamapps\common\Arma 3\server.cfg" -loadMissionToMemory "-mod=WS;RF;curator;kart;heli;mark;expansion;jets;argo;orange;tacops;tank;enoch;aow;C:\Program Files (x86)\Steam\steamapps\common\Arma 3\!Workshop\@CBA_A3;C:\Program Files (x86)\Steam\steamapps\common\Arma 3\!Workshop\@Antistasi - The Mod"

###====== UPnP Zone ======###
# Open UPnP
Write-Host "Opening UPnp Port"
upnpc -e MT-Server_Arma3 -r 33000 33000 udp