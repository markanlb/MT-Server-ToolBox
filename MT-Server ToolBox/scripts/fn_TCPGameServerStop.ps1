# Get the parameters passed to the script
$resultObj = $args[0]
$ip2 = $args[1]
$tcpport = $args[2]
#============
# Definition of the confirmation dialog
	$ConfirmDialog = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::AffirmativeAndNegative
	$settings = [MahApps.Metro.Controls.Dialogs.MetroDialogSettings]::new()
	$settings.AffirmativeButtonText = "$($Translations.DialogYes)"
	$settings.NegativeButtonText = "$($Translations.DialogNo)"
#============
$result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form, "$($Translations.DialogShutdown)", "$($Translations.DialogGameServerShutdown)",$ConfirmDialog, $settings)
if ($result -eq "Affirmative") {
	Write-Host " Game Server Stop Request Init with $resultObj"
	$GServerActionResult.Foreground = "White"
	$GServerActionResult.Text = ""
	[System.Windows.Forms.Application]::DoEvents() # To force the rendering update

	try {
		$client = New-Object System.Net.Sockets.TcpClient
		$client.Connect($ip2, $tcpport)
		$writer = New-Object System.IO.StreamWriter($client.GetStream())
		$writer.WriteLine("Game_Server_Stop_Action:$resultObj")
		$writer.Flush()
		Write-Host " Game Server Stop Request sent for $resultObj"
		$GServerActionResult.Text = "$($Translations.GServerActionRStop)"
		[System.Windows.Forms.Application]::DoEvents()
	}
	catch {
		Write-Host " Error on Game Server Stop: $_"
		Write-Host " Game Server Stop Failed." -ForegroundColor Red
		$GServerActionResult.Foreground = "Red"
		$GServerActionResult.Text = "$($Translations.GServerActionRStopError)"
	}
	finally {
	$writer.Dispose()
	$client.Close()
	}
} else {
	Write-Host " Game Server Shutdown Canceled."
	$GServerActionResult.Foreground = "Yellow"
	$GServerActionResult.Text = "$($Translations.GServerActionRStopCancel)"
}
#============