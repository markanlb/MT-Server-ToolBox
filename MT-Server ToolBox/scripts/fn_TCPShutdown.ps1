# Get the parameters passed to the script
$ip2 = $args[0]
$tcpport = $args[1]
#============
# Definition of the confirmation dialog
	$ConfirmDialog = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::AffirmativeAndNegative
	$settings = [MahApps.Metro.Controls.Dialogs.MetroDialogSettings]::new()
	$settings.AffirmativeButtonText = "$($Translations.DialogYes)"
	$settings.NegativeButtonText = "$($Translations.DialogNo)"
#============
	Write-Host " Shutdown Request Init"
	$ShutDownstatusResult.Foreground = "White"
	$ShutDownstatusResult.Text = ""
	[System.Windows.Forms.Application]::DoEvents() # To force the rendering update

	try {
		$client = New-Object System.Net.Sockets.TcpClient
		$client.Connect($ip2, $tcpport)
		$writer = New-Object System.IO.StreamWriter($client.GetStream())
		$writer.WriteLine("Shutdown_Action")
		$writer.Flush()
		Write-Host " Shutdown Request sent"
		$ShutDownstatusResult.Text = "$($Translations.btnShutDownR0)"
		[System.Windows.Forms.Application]::DoEvents()

		$result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form, "$($Translations.DialogShutdown)", "$($Translations.DialogServerShutdown)",$ConfirmDialog, $settings)
		if ($result -eq "Affirmative") {
			$writer.WriteLine("Shutdown_Action_confirmation")
			$writer.Flush()
			Write-Host " Request Confirmation sent"
			$ShutDownstatusResult.Text = "$($Translations.btnShutDownR1)"
			[System.Windows.Forms.Application]::DoEvents()
			Start-Sleep -Seconds 1
			Write-Host " Server will Shutdown"
			$ShutDownstatusResult.Text = "$($Translations.btnShutDownR2)"
			[System.Windows.Forms.Application]::DoEvents()
			#===
			$AStimer.Start() # To restart $AutostatusResult
			Write-Host " Restarting Auto status Test"
		}
		else {
			$writer.Dispose()
			$client.Close()
			Write-Host " Shutdown Confirmation Canceled."
			$ShutDownstatusResult.Foreground = "Yellow"
			$ShutDownstatusResult.Text = "$($Translations.btnShutDownRCancel)"
		}
	}
	catch {
		Write-Host " Error connecting to server: $_"
		Write-Host " Shutdown Confirmation Failed."
		$ShutDownstatusResult.Foreground = "Red"
		$ShutDownstatusResult.Text = "$($Translations.btnShutDownRError)"
	}
	finally {
	$writer.Dispose()
	$client.Close()
	}
#============