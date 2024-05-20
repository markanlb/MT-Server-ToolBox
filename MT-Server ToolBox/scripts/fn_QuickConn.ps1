# Get the parameters passed to the script
$ip = $args[0]
$mstscport = $args[1]
$timeout = $args[2]
#============
	$QuickConnstatusResult.Text = ""
	[System.Windows.Forms.Application]::DoEvents()
	
	$tcpClient = New-Object System.Net.Sockets.TcpClient
	Write-Host "`n Quick connection test with ($ip2) on port ($mstscport)"
	try {
		$asyncResult = $tcpClient.BeginConnect($ip2, $mstscport, $null, $null)
		$waitHandle = $asyncResult.AsyncWaitHandle
		$waitHandle.WaitOne($timeout, $false)
    
		if ($tcpClient.Connected) {
			Write-Host " Connecting to the server seems to be possible. `n" -ForegroundColor Green
			$QuickConnstatusResult.Foreground = "Green"
			$QuickConnstatusResult.Text = "$($Translations.btnQuickConnRTrue)"
		}
		else {
			Write-Host " Connecting to the server seems to be impossible. `n" -ForegroundColor Red
			$QuickConnstatusResult.Foreground = "Red"
			$QuickConnstatusResult.Text = "$($Translations.btnQuickConnRFalse)"
		}
	}
	catch {
		Write-Host " An error occurred while trying to connect : `n" -ForegroundColor Yellow
		Write-Host $_.Exception.Message
		$QuickConnstatusResult.Foreground = "Yellow"
		$QuickConnstatusResult.Text = "$($Translations.btnQuickConnRError)"
	}
	finally {
		$tcpClient.Close()
	}
#============

# How to return Object
<#

# What should be in the called script

$Returnobject = [PSCustomObject]@{
	Param1 = $ip
	Param2 = $mstscport
	Param3 = $timeout
}
# Return object
return $Returnobject

#===

# What should be in the script that receives object

$param1M = $fn_Script.Param1
$param2M = $fn_Script.Param2
$param3M = $fn_Script.Param3

Write-Host " Parametre 1 modifié : $param1M"
Write-Host " Parametre 2 modifié : $param2M"
Write-Host " Parametre 3 modifié : $param3M"

#>