# Get the parameters passed to the script
$ip2 = $args[0]
$tcpport = $args[1]
$timeout = $args[2]
#============
$maxValue = $WakeUpProgressbar.Maximum # Retrieves the maximum value of the Progress Bar defined fn_WOL.ps1
Write-Host " Auto status Test" -ForegroundColor Yellow

	$AutostatusIndicator.Fill = "DarkGray"
	[System.Windows.Forms.Application]::DoEvents() # To force the rendering update
	
	try {
		$tcpClient = New-Object System.Net.Sockets.TcpClient
		$asyncResult = $tcpClient.BeginConnect($ip2, $tcpport, $null, $null)	
		$waitHandle = $asyncResult.AsyncWaitHandle
		$waitHandle.WaitOne($timeout, $false)
		if ($tcpClient.Connected) {
			$global:ServerStatus = $true
			$AutostatusResult.Foreground = "Green"
			$AutostatusResult.Text = "$($Translations.AutostatusResultON)"
			$AutostatusIndicator.Fill = "Green"
			$btnWakeUp.IsEnabled = $false
			$btnShutDown.IsEnabled = $true
			$WakeUpstatusResult.Text = "$($Translations.btnWakeUpRStatus)"
		} else {
			$global:ServerStatus = $false
			$AutostatusResult.Foreground = "Red"
			$AutostatusResult.Text = "$($Translations.AutostatusResultOFF)"
			$AutostatusIndicator.Fill = "Red"
			if ($WakeUpProgressbar.Value -ge 1 -and $WakeUpProgressbar.Value -lt $maxValue) { $btnWakeUp.IsEnabled = $false } else { $btnWakeUp.IsEnabled = $true; $btnShutDown.IsEnabled = $false}
			}
		}
	catch { $AutostatusResult.Foreground = "Yellow"
			$AutostatusResult.Text = "$($Translations.AutostatusResultERROR)"
			$AutostatusIndicator.Fill = "Yellow"
		}
	finally { $tcpClient.Close()
			  Write-Host " Auto status Result : $global:ServerStatus"
		}
#============