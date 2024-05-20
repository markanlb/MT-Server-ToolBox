# Get the parameters passed to the script
$ip = $args[0]
$mac = $args[1]
$port = $args[2]
$boottime = $args[3]
#============
if ($global:ServerStatus -eq $true) {
	$WakeUpstatusResult.Text = "$($Translations.btnWakeUpRStatus)"
	Exit # Only exit the script called with operator (&)
}
#============
function send-WOL
{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$True,Position=1)]
		[string]$mac,
		[string]$ip,
		[int]$port = $port
		)

	$mac = (($mac.replace(":","")).replace("-","")).replace(".","")
	$target = 0,2,4,6,8,10 | % {[convert]::ToByte($mac.substring($_,2),16)}
	$packet = (,[byte]255 * 6) + ($target * 16)
	$UDPclient = new-Object System.Net.Sockets.UdpClient
	$UDPclient.Connect($ip,$port)
	[void]$UDPclient.Send($packet, 102)
}
#============
	Write-Host " Selected IP address = $ipDescription : ($ip)"
	Write-Host " Sending magic packet to Remote Server to MAC: ($mac) with IP: ($ip) on Port: $port `n"
	$WakeUpstatusResult.Text = "$($Translations.btnWakeUpR0) MAC: ($mac) IP: ($ip) Port: $port"
	[System.Windows.Forms.Application]::DoEvents()
	send-WOL -mac $mac -ip $ip # Enter MAC- and Broadcast-Address and execute send-WOL Function
	Start-Sleep -m 500 # Wait between signals in milliseconds
	send-WOL -mac $mac -ip $ip # Second sending
	Start-Sleep -m 500
	Write-Host " Please wait for the Remote Server to boot..."
	[System.Windows.Forms.Application]::DoEvents()
#============
$WakeUpstatusResult.Text = "$($Translations.btnWakeUpR1)"
[System.Windows.Forms.Application]::DoEvents()
#===
$AStimer.Start() # To restart $AutostatusResult
$global:AStickCount = 0
Write-Host " Resetting Auto status Test" -ForegroundColor Magenta
#============
$WakeUpProgressbar.Value = 0 # Reset the Progress Bar
$WakeUpProgressbar.Maximum = $boottime # Maximum Value of Progress Bar

for ($i = 0; $i -le $WakeUpProgressbar.Maximum; $i++) {
	$WakeUpProgressbar.Value = $i
	Start-Sleep -Milliseconds 100
	if ($WakeUpProgressbar.Value -ge ($WakeUpProgressbar.Maximum / 3*2)) { $WakeUpstatusResult.Text = "$($Translations.btnWakeUpR2)" }
	if ($global:ServerStatus -eq $true) { 
		$WakeUpProgressbar.Value = $WakeUpProgressbar.Maximum
		$WakeUpstatusResult.Text = "$($Translations.btnWakeUpR3)"
		$AStimer.Stop()
		Write-Host " Stopping Auto status Test" -ForegroundColor Yellow
		break # Stop and Exit the "for" loop
		}
	[System.Windows.Forms.Application]::DoEvents() #To force the rendering update
}
#============
# '-eq' --> equal to
# '-gt' --> greater than
# '-lt' --> less than
# '-ge' --> greater than or equal to
# '-le' --> less than or equal to


