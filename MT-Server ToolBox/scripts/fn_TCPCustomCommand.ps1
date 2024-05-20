# Get the parameters passed to the script
$TCPcustom = $args[0]
$ip2 = $args[1]
$tcpport = $args[2]
#============
	Write-Host " Custom TCP Command Request Init with $TCPcustom"
	$CustomTCPResult.Foreground = "White"
	$CustomTCPResult.Text = ""
	[System.Windows.Forms.Application]::DoEvents() # To force the rendering update

	try {
		$client = New-Object System.Net.Sockets.TcpClient
		$client.Connect($ip2, $tcpport)
		$writer = New-Object System.IO.StreamWriter($client.GetStream())
		$writer.WriteLine("$TCPcustom")
		$writer.Flush()
		Write-Host " Custom TCP Command sent for $TCPcustom"
		$CustomTCPResult.Text = "$($Translations.btnTCPcustomR0)"
		[System.Windows.Forms.Application]::DoEvents()
	}
	catch {
		Write-Host " Error on Custom TCP Command sending: $_"
		Write-Host " Custom TCP Command Failed." -ForegroundColor Red
		$CustomTCPResult.Foreground = "Red"
		$CustomTCPResult.Text = "$($Translations.btnTCPcustomRError)"
	}
	finally {
	$writer.Dispose()
	$client.Close()
	}
#============