# Get the parameters passed to the script
param (
    [Parameter(Mandatory=$true)]
    [System.Object]$ConfigData,

    [Parameter(Mandatory=$true)]
    [System.Object]$UserPathData
)

# Convert object to JSON and write it to configuration file
$ConfigData | ConvertTo-Json | Out-File -FilePath $UserPathData -Encoding utf8



