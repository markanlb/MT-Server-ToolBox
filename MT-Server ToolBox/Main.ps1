#########################################################################
# MT-Server ToolBox Client Side, v0.7, 2024								#
# Author: Marcus														#
#########################################################################

### UNBLOCK ALL FILES ####
Get-ChildItem -Path $PSScriptRoot -Recurse -File | ForEach-Object {
    Unblock-File -Path $_.FullName
}
### HIDE PS CONSOLE ####
$debug = $true # Debug 'true' will also enable the login dialog
$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
if ($debug -eq $true) {
    $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 5) # 5 to Show console
	Write-Host "DEBUG WINDOW" -ForegroundColor Cyan
    Write-Host "Do not close this window; report any errors that appear during testing" -ForegroundColor Cyan
} else {
    $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0) # 0 to Hide console
}

#########################################################################
#								MAIN PROG								#
#########################################################################
$Host.UI.RawUI.WindowTitle = "MT-Server ToolBox Client"

### ADD SHARED_ASSEMBLIES #############################################
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\LiveCharts.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\LiveCharts.Wpf.dll') | out-null

### JSON SERVER SETTINGS LOADING ######################################
$ServerConfigPath = ".\ServerConfig.json"
$ServerConfig = Get-Content -Raw -Path $ServerConfigPath | ConvertFrom-Json

# JSON Server Config Loading
$ServerName		= $ServerConfig.Serverinfo.name
$ipLocal		= $ServerConfig.Serverinfo.ip
$ip1 			= $ServerConfig.WOLip_Local.ip
$ip1Domain		= $ServerConfig.WOLip_Local.domain
$ip2 			= $ServerConfig.WOLip_Net.ip
$ip2Domain 		= $ServerConfig.WOLip_Net.domain
$mac 			= $ServerConfig.mac.mac
$WOLport		= $ServerConfig.WOLport.port
$mstscport 		= $ServerConfig.remotedesk.port
$tcpport 		= $ServerConfig.tcpport.port
$timeout 		= $ServerConfig.timeout.timeout
$boottime 		= $ServerConfig.boottime.boottime

#### VARIABLES #########################################################
$LoginPassword		= "zz"

$global:ip 				= $ip2
$global:ipDomain 		= $ip2Domain
$global:mstscip			= $ip2
$global:ServerStatus	= $false

$AStimer = New-Object System.Windows.Forms.Timer
$global:AStickCount = 0

### LOAD MAIN PANEL ####################################################
$Global:pathPanel= split-path -parent $MyInvocation.MyCommand.Definition

function LoadXaml ($filename){
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

$XamlMainWindow=LoadXaml($pathPanel+"\MainWindow.xaml")
$reader = (New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form = [Windows.Markup.XamlReader]::Load($reader)

###====== Icon in Windows notification bar ======###
$iconPath = ".\MT-Server_Icon.ico"
$NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
$NotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
$NotifyIcon.Visible = $true

### HAMBURGER VIEWS ####################################################
###====== Target View ======###
$HamburgerMenuControl = $Form.FindName("HamburgerMenuControl")

$ControlView	= $Form.FindName("ControlView")
$ServerView		= $Form.FindName("ServerView")
$GameServerView	= $Form.FindName("GameServerView")
$GeoMapView		= $Form.FindName("GeoMapView")
$SettingsView	= $Form.FindName("SettingsView")
$AboutView		= $Form.FindName("AboutView")

###====== Load Other Views ======###
$viewFolder = $pathPanel +"\views"

$XamlChildWindow = LoadXaml($viewFolder+"\Home.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$HomeXaml        = [Windows.Markup.XamlReader]::Load($Childreader)

$XamlChildWindow = LoadXaml($viewFolder+"\ServerView.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$SManagerXaml    = [Windows.Markup.XamlReader]::Load($Childreader)

$XamlChildWindow = LoadXaml($viewFolder+"\GameServerView.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$GManagerXaml    = [Windows.Markup.XamlReader]::Load($Childreader)

$XamlChildWindow = LoadXaml($viewFolder+"\geoMap.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$GeoMapXaml      = [Windows.Markup.XamlReader]::Load($Childreader)

$XamlChildWindow = LoadXaml($viewFolder+"\Settings.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$SettingsXaml    = [Windows.Markup.XamlReader]::Load($Childreader)

$XamlChildWindow = LoadXaml($viewFolder+"\About.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$AboutXaml       = [Windows.Markup.XamlReader]::Load($Childreader)
#===
$ControlView.Children.Add($HomeXaml)		| Out-Null
$ServerView.Children.Add($SManagerXaml)		| Out-Null
$GameServerView.Children.Add($GManagerXaml)	| Out-Null
$GeoMapView.Children.Add($GeoMapXaml)		| Out-Null
$SettingsView.Children.Add($SettingsXaml)	| Out-Null
$AboutView.Children.Add($AboutXaml)			| Out-Null

###====== Initialize with the first value of Item Section ======###
$HamburgerMenuControl.SelectedItem = $HamburgerMenuControl.ItemsSource[0]

### JSON USER SETTINGS LOADING #########################################
$UserConfigPath = ".\UserConfig.json"

# Check if User config file exists
if (-not (Test-Path $UserConfigPath)) {
	# If it doesn't exist, create default settings to show an example
	# JSON is an unordered data format. The information will be created in random order
	$DefaultConfig = @{
		LocalMode = "false"
		RemoteDesktop = "false"
		Language = "English"
	}
	# Convert hashtable object to JSON and write it to configuration file
	$DefaultConfig | ConvertTo-Json | Out-File -FilePath $UserConfigPath -Encoding utf8
}

# Read the contents of the User config file
$UserConfig = Get-Content -Path $UserConfigPath -Raw | ConvertFrom-Json

### UI DEFINITION LOADING ##############################################
###====== .json Translation load ======###
$TranslationFilePath = ".\resources\Stringtable.json"
$TranslationFile = Get-Content -Path $TranslationFilePath -Encoding utf8 | ConvertFrom-Json 
###====== Import Ui definition ======###
Write-Host " Language Update"
$selectedLanguage = $UserConfig.Language
$Translations = $TranslationFile.$selectedLanguage
# dot-sourcing to load the script into memory
. ".\scripts\fn_UiDefinition.ps1" $Translations

#########################################################################
#							FUNC & SCRIPTS								#
#########################################################################

### HOME VIEW ##########################################################
###====== Test Zone ======###
$btnTest01 = $HomeXaml.FindName("btnTest01")
$btnTest02 = $HomeXaml.FindName("btnTest02")

$btnTest01.add_Click({
	# Test
	Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `".\scripts\fn_Test.ps1`"" -WindowStyle Hidden
})
$btnTest02.add_Click({
	# Test
	$fn_Script = & ".\scripts\fn_Test.ps1" $boottime
})

### SERVER MANAGER #####################################################
###====== Get TextBox Result ======###
# Hamburger event on click for ServerManager View
$HamburgerMenuControl.add_ItemClick({
	if ($HamburgerMenuControl.SelectedItem.Tag -eq $ServerView) {
		$global:AStickCount = 0
		$AStimer.Interval = 1000
		$AStimer.Start() #For $AutostatusResult
		
		$nameResult.Text = "$ServerName"
		$domainResult.Text = "$ipDomain"
		$ipResult.Text = "$ip"
		$macResult.Text = "$mac"
		
		$QuickConnstatusResult.Text = ""
		$WakeUpstatusResult.Text = ""
		$ShutDownstatusResult.Text = ""
	} else {
	$AStimer.Stop() 
	$AutostatusResult.Text = ""
	}
})
###====== Quick Connection Auto status ======###
# Timer Logic of $AutostatusResult
	$AStimer.add_Tick({
	$AStimer.Interval = 5000 # 5 second interval (in milliseconds)
	$global:AStickCount++
	QuickConnAutostatus
#===
	if ($global:AStickCount -eq 12) {
		$AStimer.Stop()
		$global:AStickCount = 0
		$AutostatusResult.Foreground = "Yellow"
		$AutostatusResult.Text = "$($Translations.AutostatusResultPAUSE)"
		$AutostatusIndicator.Fill = "Yellow"
		Write-Host " Stopping Auto status Test" -ForegroundColor Magenta
	}
})
#===
# QuickConnAutostatus for $AutostatusResult && $AutostatusIndicator
function QuickConnAutostatus
{
	$fn_Script = & ".\scripts\fn_Autostatus.ps1" $ip2 $tcpport $timeout
	# 'function QuickConnAutostatus' Also includes logic for the button '$btnWakeUp' && '$btnShutDown'
}
###====== Send WakeOnLan Button ======###
$btnWakeUp.add_Click({
	$btnWakeUp.IsEnabled = $false # Disable button
	$fn_Script = & ".\scripts\fn_WOL.ps1" $ip $mac $WOLport $boottime
	$btnWakeUp.IsEnabled = $true # Enable button after execution of the script
})
###====== Quick Connection Button ======###
$btnQuickConn.add_Click({
	$fn_Script = & ".\scripts\fn_QuickConn.ps1" $ip $mstscport $timeout
})
###====== Remote Desktop Button ======###
$btnRemoteConn.add_Click({
	$LocalMode = $UserConfig.LocalMode
	if ($LocalMode -eq "true") { Start-Process -FilePath "mstsc.exe" -ArgumentList "/v:$mstscip" } else { Start-Process -FilePath "mstsc.exe" -ArgumentList "/v:$mstscip`:$mstscport" }
	if ($chkbtnRemoteConn.IsChecked) { $Form.Close() }
})
###====== Remote Desktop Checkbox ======###
function ChkRemoteDeskUpdate {
Write-Host " RemoteDesktop Checkbox Update"
$chkRemoteDesk = $UserConfig.RemoteDesktop
	if ($chkRemoteDesk -eq "true") {
		$chkbtnRemoteConn.IsChecked = $true
	} else {
		$chkbtnRemoteConn.IsChecked = $false
	}
}
ChkRemoteDeskUpdate
#===
$chkbtnRemoteConn.Add_Click({
	if ($chkbtnRemoteConn.IsChecked) {
		Write-Host " Checkbox is on"
		$UserConfig.RemoteDesktop = "true"
		# Update UserConfig.json
		$fn_Script = & ".\scripts\fn_UpdateUserConfig.ps1" -ConfigData $UserConfig -UserPathData $UserConfigPath
		ChkRemoteDeskUpdate
	} else {
		Write-Host " Checkbox is off"
		$UserConfig.RemoteDesktop = "false"
		# Update UserConfig.json
		$fn_Script = & ".\scripts\fn_UpdateUserConfig.ps1" -ConfigData $UserConfig -UserPathData $UserConfigPath
		ChkRemoteDeskUpdate
	}
})
###====== Remote TCP Shutdown Button ======###
$btnShutDown.IsEnabled = $false
$btnShutDown.add_Click({
	$fn_Script = & ".\scripts\fn_TCPShutdown.ps1" $ip2 $tcpport
})

### GAME SERVER VIEW ################################################
# Hamburger event on click for ServerManager View
$HamburgerMenuControl.add_ItemClick({
	if ($HamburgerMenuControl.SelectedItem.Tag -eq $GameServerView) {
		$GServerActionResult.Text = ""
		$GetGServerResult.Text = ""
	}
})

###====== json Game config ======###
$GameConfigPath = ".\GameConfig.json"
$GameConfig = Get-Content -Path $GameConfigPath -Raw | ConvertFrom-Json

###====== Get Datagrid Result ======###
$btnGetGServer.add_Click({
	$fn_Script = .".\scripts\fn_GridGameServer.ps1" $GameConfig
	# Add datas to the datagrid
	$dataGamegrid.ItemsSource = $observableCollection
})

###====== Button Action Datagrid ======###
[System.Windows.RoutedEventHandler]$EventonDataGrid = {
	# Get name of event source
	$button =  $_.OriginalSource.Name
	# Return the Row Data available
	$resultObj = $dataGamegrid.SelectedItem.GServerHeader

	# Select the corresponding action
	If ( $button -match "GServerStart" ) {
		Write-Host " Game server Start action"
		$fn_Script = & ".\scripts\fn_TCPGameServerStart.ps1" $resultObj $ip2 $tcpport
	}
	ElseIf ($button -match "GServerStop" ) {
		Write-Host " Game server Stop action"
		$fn_Script = & ".\scripts\fn_TCPGameServerStop.ps1" $resultObj $ip2 $tcpport
	}
}
$dataGamegrid.AddHandler([System.Windows.Controls.Button]::ClickEvent, $EventonDataGrid)

### GEOMAP ##########################################################
$GeoMap.EnableZoomingAndPanning = $false
$DummyServer.Tooltip = "$ServerName"

$DummyServer.add_Click({
	# Test
	Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `".\scripts\fn_PinWars.ps1`"" -WindowStyle Hidden
	# Test
})

### SETTING PANEL + LOGIC ###########################################
###====== Local toggle switch button ======###
function LocalModeUpdate {
Write-Host " LocalMode Update"
$LocalMode = $UserConfig.LocalMode
	if ($LocalMode -eq "true") {
		$tglLocalMode.IsChecked = $true
		$global:ip = $ip1
		$global:ipDomain = $ip1Domain
		$global:mstscip = $ipLocal
	} else {
		$tglLocalMode.IsChecked = $false
		$global:ip = $ip2
		$global:ipDomain = $ip2Domain
		$global:mstscip = $ip2
	}
}
LocalModeUpdate
#===
$tglLocalMode.Add_Click({
	if ($tglLocalMode.IsChecked) {
		Write-Host " LocalMode is on"
		$UserConfig.LocalMode = "true"
		# Update UserConfig.json
		$fn_Script = & ".\scripts\fn_UpdateUserConfig.ps1" -ConfigData $UserConfig -UserPathData $UserConfigPath
		LocalModeUpdate
	} else {
		Write-Host " LocalMode is off"
		$UserConfig.LocalMode = "false"
		# Update UserConfig.json
		$fn_Script = & ".\scripts\fn_UpdateUserConfig.ps1" -ConfigData $UserConfig -UserPathData $UserConfigPath
		LocalModeUpdate
	}
})

###====== TCP Custom Button Action ======###
$btnTCPcustom.add_Click({
	if ($textboxTCPCustom.Text -eq "") {
		$CustomTCPResult.Foreground = "Yellow"
		$CustomTCPResult.Text = "$($Translations.btnTCPcustomRString)"
	} else {
		[System.Windows.Forms.Application]::DoEvents()
		$TCPcustom = $textboxTCPCustom.Text
		$fn_Script = & ".\scripts\fn_TCPCustomCommand.ps1" $TCPcustom $ip2 $tcpport
	}
})

###====== Combobox Language ======###
# Combobox Logic
# Dynamically load languages from JSON file
foreach ($lang in $translationFile.PSObject.Properties.Name) {
	$LangComboBox.Items.Add($lang)
}
#===
# Combobox Language selection event
$action_OnLanguageChange = {
	$selectedLanguage = $LangComboBox.SelectedItem.ToString()
	$Translations = $TranslationFile.$selectedLanguage
	
	Write-Host " Language is set to $selectedLanguage"
	$UserConfig.Language = $selectedLanguage
	# Update UserConfig.json
	$fn_Script = & ".\scripts\fn_UpdateUserConfig.ps1" -ConfigData $UserConfig -UserPathData $UserConfigPath
	
	# Definition of the PopUp dialog
	$PopUpDialog = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::Affirmative
	$result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form, "Restart required", "The application requires a Restart to apply the translation",$PopUpDialog)
}
# Attach the SelectionChanged event to the ComboBox
$LangComboBox.Add_SelectionChanged($action_OnLanguageChange)

### HAMBURGER EVENTS #################################################
# Items Section ======================
$HamburgerMenuControl.add_ItemClick({
   $HamburgerMenuControl.Content = $HamburgerMenuControl.SelectedItem
   $HamburgerMenuControl.IsPaneOpen = $false
})

# Options Section ======================
$HamburgerMenuControl.add_OptionsItemClick({

    $HamburgerMenuControl.Content = $HamburgerMenuControl.SelectedOptionsItem
    $HamburgerMenuControl.IsPaneOpen = $false
	
	$textboxTCPCustom.Text = ""
	$CustomTCPResult.Text = ""
})

### LOGIN EVENTS ####################################################
function ShowLoginDialog {
	$settings = [MahApps.Metro.Controls.Dialogs.LoginDialogSettings]::new()
	$settings.NegativeButtonVisibility = "Visible"
	$settings.ShouldHideUsername = "true"
	$settings.NegativeButtonText = "$($Translations.DialogLoginQuit)"

	$result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalLoginExternal($Form, "$($Translations.DialogLogin)", "$($Translations.DialogLoginPass)", $settings)
	return $result
}
<#
 .add_Loaded => execute on load
 .Add_ContentRendered => execute after Load
#>
###====== Login Dialog ======###
if ($debug -eq $false) {
 $Form.Add_ContentRendered({
	$success = $false
	while (-not $success) {
		$result = ShowLoginDialog
		if ($result -ne $null -and $result.Password -eq "$LoginPassword") {
			$success = $true
			[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form, "$($Translations.DialogLoginSuccess)", "$($Translations.DialogLoginSuccess2)")
		} elseif ($result -eq $null) {
			$Form.Close()
			break
		} else {
			[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form, "$($Translations.DialogLoginError)", "$($Translations.DialogLoginError2)")
		}
	}
 })
}
### SHOW DIALOG	+ CUSTOM ACTION ######################################
$Form.add_MouseLeftButtonDown({
   $_.handled=$true
   #$this.DragMove()
})
$Form.Add_Closing({
	$NotifyIcon.Dispose() # Delete icon from the notification bar (I noticed it sometimes remained)
})

$Form.ShowDialog() | Out-Null

#pause
