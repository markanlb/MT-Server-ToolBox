# Script to launch MT-Server Toolbox
Start-Sleep -s 20 # Waiting for Windows network settings to start

# Path to the directory containing the .ps1 script
$scriptDirectory = "C:\MT-Server ToolBox Server"

# Vérifie si le répertoire existe
if (Test-Path $scriptDirectory) {
	# Change the current directory to the script directory
	Set-Location $scriptDirectory
	
	$scriptName = "Main.ps1"
	$scriptPath = Join-Path -Path $scriptDirectory -ChildPath $scriptName

	if (Test-Path $scriptPath) {
		Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -WindowStyle Hidden
	} else {
		Write-Host "The file $scriptPath does not exist"
	}
} else {
	Write-Host "The $scriptDirectory directory does not exist"
}
