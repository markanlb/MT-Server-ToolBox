# Get the parameters passed to the script
$resultObj = $args[0]
$ip2 = $args[1]
$tcpport = $args[2]
#============
	Write-Host " Game Server Launch Request Init with $resultObj"
	$GServerActionResult.Foreground = "White"
	$GServerActionResult.Text = ""
	[System.Windows.Forms.Application]::DoEvents() # To force the rendering update

	try {
		$client = New-Object System.Net.Sockets.TcpClient
		$client.Connect($ip2, $tcpport)
		$writer = New-Object System.IO.StreamWriter($client.GetStream())
		$writer.WriteLine("Game_Server_Start_Action:$resultObj")
		$writer.Flush()
		Write-Host " Game Server Launch Request sent for $resultObj"
		$GServerActionResult.Text = "$($Translations.GServerActionRStart)"
		[System.Windows.Forms.Application]::DoEvents()
	}
	catch {
		Write-Host " Error on Game Server Launch: $_"
		Write-Host " Game Server Launch Failed." -ForegroundColor Red
		$GServerActionResult.Foreground = "Red"
		$GServerActionResult.Text = "$($Translations.GServerActionRStartError)"
	}
	finally {
	$writer.Dispose()
	$client.Close()
	}
#============