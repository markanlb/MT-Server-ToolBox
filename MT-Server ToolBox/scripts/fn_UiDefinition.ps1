
# This script contains all the names and access to the different elements of the GUI
# Called and loaded into memory at start of Main Script
#============
# Get the parameters passed to the script
$Translations = $args[0]
#============

### UPPER BAR LABEL ON RIGHT ###########################################
$UBLabel1 = $Form.FindName("UpperBarLabel1")
$UBLabel2 = $Form.FindName("UpperBarLabel2")
$UBLabel1.Content = "$($Translations.UpperBarLabel1)"
$UBLabel2.Content = "$env:USERNAME"

### HAMBURGER MENU #####################################################
$HamburgerMenu  = $Form.FindName("HamburgerMenuControl")
$Items 			= $HamburgerMenu.ItemsSource
$OptionItems 	= $HamburgerMenu.OptionsItemsSource
$Items[0].Label = "$($Translations.LabelMenuHome)"
$Items[1].Label = "$($Translations.LabelMenuServerView)"
$Items[2].Label = "$($Translations.LabelMenuGameServerView)"
$Items[3].Label = "$($Translations.LabelMenugeoMap)"
$OptionItems[0].Label = "$($Translations.LabelMenuSettings)"
$OptionItems[1].Label = "$($Translations.LabelMenuAbout)"

### SERVER MANAGER #####################################################
# Label & TextBox
$SMMainLabel 			 = $SManagerXaml.FindName("SMMainLabel")
$SMMainLabel.Content 	 = "$($Translations.SMMainLabel)"
$SMlabel 				 = $SManagerXaml.FindName("SMlabel")
$SMlabel.Content 		 = "$ServerName $($Translations.SMlabel)"
$AutostatusLabel 		 = $SManagerXaml.FindName("AutostatusLabel")
$AutostatusLabel.Content = "$($Translations.AutostatusLabel)"
$Sname 					 = $SManagerXaml.FindName("Sname")
$Sname.Content 			 = "$($Translations.Sname)"
$domainLabel 			 = $SManagerXaml.FindName("domainLabel")
$domainLabel.Content 	 = "$($Translations.domainLabel)"
$SMlabelaction 			 = $SManagerXaml.FindName("SMlabelaction")
$SMlabelaction.Content	 = "$ServerName $($Translations.SMlabelaction)"
# TextBox for result
$AutostatusResult		= $SManagerXaml.FindName("AutostatusResult")
$nameResult				= $SManagerXaml.FindName("nameResult")
$domainResult			= $SManagerXaml.FindName("domainResult")
$ipResult				= $SManagerXaml.FindName("ipResult")
$macResult				= $SManagerXaml.FindName("macResult")
# Dialog type button
$btnWakeUp				= $SManagerXaml.FindName("btnWakeUp")
$btnWakeUp.Content  	= "$($Translations.btnWakeUp)"
$btnWakeUp.Tooltip  	= "$($Translations.btnWakeUpT)"
$btnQuickConn			= $SManagerXaml.FindName("btnQuickConn")
$btnQuickConn.Content	= "$($Translations.btnQuickConn)"
$btnQuickConn.Tooltip	= "$($Translations.btnQuickConnT)"
$btnRemoteConn			= $SManagerXaml.FindName("btnRemoteConn")
$btnRemoteConn.Content  = "$($Translations.btnRemoteConn)"
$btnRemoteConn.Tooltip  = "$($Translations.btnRemoteConnT)"
$btnShutDown			= $SManagerXaml.FindName("btnShutDown")
$btnShutDown.Content 	= "$($Translations.btnShutDown)"
$btnShutDown.Tooltip 	= "$($Translations.btnShutDownT)"
# Dialog type button Checkbox
$WakeUpProgressbar		= $SManagerXaml.FindName("WakeUpProgressbar")
# Dialog type button Checkbox
$chkbtnRemoteConn			= $SManagerXaml.FindName("chkbtnRemoteConn")
$chkbtnRemoteConn.Content	= "$($Translations.chkbtnRemoteConn)"
$chkbtnRemoteConn.Tooltip	= "$($Translations.chkbtnRemoteConnT)"
# Elispse for QuickConnAutostatus
$AutostatusIndicator = $SManagerXaml.FindName("AutostatusIndicator")
# TextBox button Result
$WakeUpstatusResult		= $SManagerXaml.FindName("WakeUpstatusResult")
$QuickConnstatusResult	= $SManagerXaml.FindName("QuickConnstatusResult")
$ShutDownstatusResult	= $SManagerXaml.FindName("ShutDownstatusResult")

### GAME SERVER VIEW ################################################
# Label & TextBox
$GMMainLabel 			= $GManagerXaml.FindName("GMMainLabel")
$GMMainLabel.Content	= "$($Translations.GMMainLabel)"
$GMlabel				= $GManagerXaml.FindName("GMlabel")
$GMlabel.Content 		= "$ServerName $($Translations.GMlabel)"
$GMlabelaction 			= $GManagerXaml.FindName("GMlabelaction")
$GMlabelaction.Content  = "$ServerName $($Translations.GMlabelaction)"
# TextBox for result
$GetGServerResult		= $GManagerXaml.FindName("GetGServerResult")
$GServerActionResult	= $GManagerXaml.FindName("GServerActionResult")
# Dialog type button
$btnGetGServer 			= $GManagerXaml.FindName("btnGetGServer")
$btnGetGServer.Content	= "$($Translations.btnGetGServer)"
$btnGetGServer.Tooltip	= "$($Translations.btnGetGServerT)"
# Datagrid
$dataGamegrid = $GManagerXaml.FindName("GMgridLogs")
$Columns = $dataGamegrid.Columns
foreach ($Column in $Columns) {
	switch ($Column.Binding.Path.Path) {
		"GServerName"  { $Column.Header = "$($Translations.dataGamegridNAME)" }
		"GLaunchInfo"  { $Column.Header = "$($Translations.dataGamegridLAUNCH)" }
		"GDescription" { $Column.Header = "$($Translations.dataGamegridDESCRIPTION)" }
		"GStatus" { $Column.Header = "$($Translations.dataGamegridSTATUS)" }
	}
}

### GEOMAP ##########################################################
$GeoMap = $GeoMapXaml.FindName("GeoMap")
$DummyServer = $GeoMapXaml.FindName("DummyServer")

### SETTING PANEL ###########################################
# Label & TextBox
$SettingsMainLabel 			= $SettingsXaml.FindName("SettingsMainLabel")
$SettingsMainLabel.Content  = "$($Translations.SettingsMainLabel)"
$SettingsLabel 				= $SettingsXaml.FindName("SettingsLabel")
$SettingsLabel.Content 		= "$($Translations.SettingsLabel)"
$tbLangComboBox 			= $SettingsXaml.FindName("tbLanguage")
$tbLangComboBox.Text 		= "$($Translations.tbLanguage)"
$TCPlabel 					= $SettingsXaml.FindName("TCPlabel")
$TCPlabel.Content 			= "$ServerName $($Translations.TCPlabel)"
###====== Local toggle switch button ======###
$tglLocalMode			= $SettingsXaml.FindName("tglLocalMode")
$tglLocalMode.Header	= "$($Translations.tglLocalModeH)"
$tglLocalMode.Tooltip	= "$($Translations.tglLocalModeT)"
###====== TCP Custom Command ======###
$textboxTCPCustom		= $SettingsXaml.FindName("textboxTCPCustom")
$CustomTCPResult		= $SettingsXaml.FindName("CustomTCPResult")
$btnTCPcustom			= $SettingsXaml.FindName("btnTCPcustom")
$btnTCPcustom.Content	= "$($Translations.btnTCPcustom)"
$btnTCPcustom.Tooltip	= "$($Translations.btnTCPcustomT)"
###====== Combobox Language ======###
$LangComboBox = $SettingsXaml.FindName("cbLanguage")

### ABOUT PANEL ###########################################
# TextBox
$tbAbout 		= $AboutXaml.FindName("tbAbout")
$tbAbout.Text 	= "$($Translations.AboutText)"
$tbAbout2 		= $AboutXaml.FindName("tbAbout2")
$tbAbout2.Text 	= "$($Translations.AboutText2)"