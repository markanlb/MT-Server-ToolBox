# UPnP Port opening (MT-Server)
#============

Write-Host " Processing the Admin UPnp Port Opening"

# Port FTP
upnpc -e MT-Server_DEV_FTP -r 21 10004 tcp

# Port Remote Desktop
upnpc -e MT-Server_DEV_BureauDist -r 3389 10005 tcp