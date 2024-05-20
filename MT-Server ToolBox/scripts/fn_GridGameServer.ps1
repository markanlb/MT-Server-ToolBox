# Get the parameters passed to the script
param (
	[Parameter(Mandatory=$true)]
	[object]$GameConfig
)
#============
$GetGServerResult.Text = "$($Translations.btnGetGServerR0)"
[System.Windows.Forms.Application]::DoEvents()

Write-Host " observableCollection Cleanup`n" -ForegroundColor Yellow
$dataGamegrid.ItemsSource = $null
$observableCollection = $null
[System.Windows.Forms.Application]::DoEvents()

$observableCollection = [System.Collections.ObjectModel.ObservableCollection[Object]]::new()

Start-Sleep -s 1
# Simulates data recovery from .json.
# Will need to be coded later to allow the Toolbox to receive the file from the server

# Loop through each game server in the configuration
foreach ($ServerName in $GameConfig.PSObject.Properties.Name) {
	$GameServer = $GameConfig.$ServerName

	$objArray = New-Object PSObject
	$objArray | Add-Member -type NoteProperty -name GServerHeader -value $ServerName
	$objArray | Add-Member -type NoteProperty -name GServerName -value $GameServer.Name
	$objArray | Add-Member -type NoteProperty -name GLaunchInfo -value $GameServer.LaunchInfo
	$objArray | Add-Member -type NoteProperty -name GDescription -value $GameServer.Description
	$objArray | Add-Member -type NoteProperty -name GStatus -value "*Missing" #($true) Should still require code to work

	# Add the objects to the ObservableCollection
	$observableCollection.Add($objArray) | Out-Null
}

###====== Display config file for Debug Window ======###
# Loop through each game server in the configuration
foreach ($ServerName in $GameConfig.PSObject.Properties.Name) {
    $GameServer = $GameConfig.$ServerName
	Write-Host "Server Header: $ServerName"
	Write-Host "Game Server Name: $($GameServer.Name)"
	Write-Host "Launch Info: $($GameServer.LaunchInfo)"
	Write-Host "Description: $($GameServer.description)"
	Write-Host ""
}
#============
$GetGServerResult.Text = "$($Translations.btnGetGServerR1)"
[System.Windows.Forms.Application]::DoEvents()