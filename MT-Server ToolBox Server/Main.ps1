#########################################################################
# MT-Server ToolBox Server Side, v0.4, 2024								#
# Author: Marcus														#
#########################################################################

#########################################################################
#								MAIN PROG								#
#########################################################################

### JSON SETTINGS LOADING ######################################
###====== JSON server config ======###
$ServerConfigPath = ".\ServerConfig.json"
$ServerConfig 	= Get-Content -Raw -Path $ServerConfigPath | ConvertFrom-Json
$ip 			= $ServerConfig.ip_Net.ip
$tcpport 		= $ServerConfig.tcpport.port
$webhookUrl		= $ServerConfig.Discord.webhookUrl
###====== json Game config ======###
$GameConfigPath = ".\GameConfig.json"
$GameConfig = Get-Content -Path $GameConfigPath -Raw | ConvertFrom-Json

#### VARIABLES #########################################################
$Host.UI.RawUI.WindowTitle = "MT-Server ToolBox Server"

#########################################################################
#							FUNC & SCRIPTS								#
#########################################################################

### JSON GAME SETTINGS INIT ######################################
###====== Checking the config file ======###
# Check if User config file exists
if (-not (Test-Path $GameConfigPath)) {
	# If it doesn't exist, create default settings to show an example
	$DefaultConfig = @{
		GameServer01 = @{
			Name = "7 Days to Die"
			LaunchInfo = "Windows Powershell"
			description = "7 Days to die Survival Server"
			StartMethod = "C:\path\to\your\file\file.ps1" # In the JSON you will see two '\\' . It needs it to work correctly for paths of .exe,ps1...
			StopMethod = "C:\path\to\your\file\file.ps1"
		}
		GameServer02 = @{
			Name = "Satisfactory"
			LaunchInfo = "Windows .exe"
			description = "Satisfactory Sandbox Server"
			StartMethod = "C:\path\to\your\file\file.exe"
			StopMethod = "C:\path\to\your\file\file.exe"
		}
	}
	# Convert hashtable object to JSON and write it to configuration file
	# JSON is an unordered data format. The information will be created in random order
	$DefaultConfig | ConvertTo-Json | Out-File -FilePath $GameConfigPath -Encoding utf8
}
###====== Display config file ======###
# Loop through each game server in the configuration
foreach ($ServerName in $GameConfig.PSObject.Properties.Name) {
    $GameServer = $GameConfig.$ServerName
	Write-Host "Server Header: $ServerName"
	Write-Host "Game Server Name: $($GameServer.Name)"
	Write-Host "Launch Info: $($GameServer.LaunchInfo)"
	Write-Host "Description: $($GameServer.description)"
	Write-Host "Launch Method: $($GameServer.StartMethod)"
	Write-Host "Stop Method: $($GameServer.StopMethod)"
	Write-Host ""
}

### GLOBAL FUNCTION ###############################################
###====== TCP Shutdown ======###
function tcpShutdown {
    Write-Host " Valid request: Shutdown action. Waiting for confirmation..."
    $data = $reader.ReadLine()

    if ($data -eq "Shutdown_Action_confirmation") {
        Write-Host " Confirmation received. Shutting down the server"
		upnpc -N 0 65535 tcp # Closing all UPnP tcp Port
		upnpc -N 0 65535 udp # Closing all UPnP udp Port
        Start-Sleep -Seconds 1
		$fn_Script = & ".\scripts\fn_DiscordBotMessage.ps1" $webhookUrl ":red_circle: MT-Server Hors Ligne"
        Stop-Computer -ComputerName localhost -Force
        Exit
    } else {
        Write-Host " Request aborted for shutdown confirmation"
    }
}
###====== TCP Game Server START action ======###
function tcpStartGameServer {
	param (
		[string]$selection
	)
    Write-Host " Processing the Game Server action"
	
	# Check if the selected server exists in the configuration
	if ($GameConfig.$Selection) {
		$SelectedServer = $GameConfig.$Selection
		$StartMethod = $SelectedServer.StartMethod
		$ServerName = $SelectedServer.Name
		if ($StartMethod -like "*.exe") {
			# Start the process if the extension is .exe
			Write-Host " Starting $Selection with $StartMethod"
			Start-Process -FilePath $StartMethod $ServerName
		} elseif ($StartMethod -like "*.ps1") {
			# Start in PowerShell (hidden) if the extension is .ps1
			Write-Host " Starting $Selection with PowerShell script: $StartMethod"
			& "$StartMethod" $ServerName -Verb RunAs
		}
	} else {
		Write-Host " The server does not exist in the configuration" -ForegroundColor Yellow
	}
}
###====== TCP Game Server STOP action ======###
function tcpStopGameServer {
	param (
		[string]$selection
	)
    Write-Host " Processing the Game Server action"
	
	# Check if the selected server exists in the configuration
	if ($GameConfig.$Selection) {
		$SelectedServer = $GameConfig.$Selection
		$StopMethod = $SelectedServer.StopMethod
		$ServerName = $SelectedServer.Name
		if ($StopMethod -like "*.exe") {
			# Start the process if the extension is .exe
			Write-Host " Shutdown $Selection with $StopMethod"
			Start-Process -FilePath $StopMethod $ServerName -Verb RunAs
		} elseif ($StopMethod -like "*.ps1") {
			# Start in PowerShell (hidden) if the extension is .ps1
			Write-Host " Shutdown $Selection with PowerShell script: $StopMethod"
			& "$StopMethod" $ServerName -Verb RunAs
		}
	} else {
		Write-Host " The server does not exist in the configuration" -ForegroundColor Yellow
	}
}

#########################################################################
#						TCP LISTENING MANAGER							#
#########################################################################
# Main function to listen for queries and call appropriate functions
function Main {
    $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Any, $tcpport)
    $listener.Start()
    Write-Host " Listening and waiting to receive Data on $tcpport..." -ForegroundColor Green
    while ($true) {
        $connection = $listener.AcceptTcpClient()
        $stream = $connection.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $data = $reader.ReadLine()
		$action, $selection = $data -split ":", 2

        switch ($action) {
            "Shutdown_Action" {
                tcpShutdown
            }
            "Game_Server_Start_Action" {
                tcpStartGameServer -selection $selection
            }
			"Game_Server_Stop_Action" {
                tcpStopGameServer -selection $selection
            }
			"Game_Server_Config" {
                $fn_Script = & ".\scripts\fn_DiscordGameConfig.ps1" $webhookUrl $GameConfigPath
            }
			"Admin_Dev_Action" {
                $fn_Script = & ".\scripts\fn_UPnPOpen.ps1"
            }
            default {
                Write-Host " Invalid request"
            }
        }
		Write-Host " Listening and waiting to receive Data on $tcpport..." -ForegroundColor Green
        $stream.Close()
        $connection.Close()
    }
    $listener.Stop()
}

###====== UPnP Port opening ======###
# TCP Remote Command
upnpc -e MT-Server_TCPRemoteCom -r $tcpport $tcpport tcp

###====== Discord Bot Status ======###
$fn_Script = & ".\scripts\fn_DiscordBotMessage.ps1" $webhookUrl ":green_circle: MT-Server en Ligne"
# Arg [0] = Discord Webhook URL
# Arg [1] = Text to show

###====== Run Main Script ======###
Main