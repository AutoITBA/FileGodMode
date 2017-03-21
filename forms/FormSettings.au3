Func GUI_Settings($posX,$posY)
	Global $flagUpdateSettings=0
	$adminLBL=""
	if _CheckIfFGMAdmin() then $adminLBL="           Admin user"
	$formTitle="Settings FGM "& $adminLBL
	$formWidth=610
	$formHigh=460
	$posxis= _PosXaxis($formWidth,$posX)
	Local $__WsExStyle = 0
	Local $__style = BitOR($WS_BORDER,$LVS_SHOWSELALWAYS,$LVS_SINGLESEL);$LVS_SINGLESEL  $LVS_REPORT
	#region  ================================= Settings======================================
		$SettingsForm = GUICreate($formTitle, $formWidth,$formHigh ,$posxis, $posY)
			GUISetOnEvent($GUI_EVENT_CLOSE, "FormSettingsClose")

		$PageControl1 = GUICtrlCreateTab(8, 8, $formWidth-16, $formHigh-50)
			GUICtrlSetOnEvent(-1, "PageControl1Change")
			$hTab_PageControl1_servers = GUICtrlGetHandle($PageControl1)
		#region  ================================= Credential Settings======================================
			$tab_Credentials = GUICtrlCreateTabItem("Credentials")

			GUICtrlCreateLabel("Domain", 16, 40, 59, 18)
				GUICtrlSetFont(-1, 10, 400, 0, "Arial")
			$TXT_creddomain = GUICtrlCreateInput("", 92, 40, 201, 22)
				GUICtrlSetFont(-1, 10, 400, 0, "Arial")
				GUICtrlCreateLabel("use . (dot) or server name, for no domain", 300 ,40, 100, 42)

			GUICtrlCreateLabel("user", 16, 63, 26, 18)
				GUICtrlSetFont(-1, 10, 400, 0, "Arial")
			$TXT_creduser = GUICtrlCreateInput("", 92, 64, 201, 22)
				GUICtrlSetFont(-1, 10, 400, 0, "Arial")

			GUICtrlCreateLabel("Password", 16, 90, 74, 18)
				GUICtrlSetFont(-1, 10, 400, 0, "Arial")
			$TXT_credpassword = GUICtrlCreateInput("", 92, 88, 201, 22, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
				GUICtrlSetFont(-1, 10, 400, 0, "Arial")

			GUICtrlCreateLabel("Credentials",16, 170, 50, 17)
			$LST_CredManage = GUICtrlCreateListView("Domain     |UserName                               |.", 16, 190, 360, 200,$__style,$__WsExStyle)
			Local $__CtrlExStyle = BitOR($LVS_EX_GRIDLINES,$LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE)
			GUICtrlSendMsg(-1,$LVM_SETEXTENDEDLISTVIEWSTYLE,$__CtrlExStyle,$__CtrlExStyle)
			_GUICtrlListView_SetColumnWidth($LST_CredManage, 0, 100)
			_GUICtrlListView_SetColumnWidth($LST_CredManage, 1, 272)
			_GUICtrlListView_SetColumnWidth($LST_CredManage, 2, 10)

			$btn_credshowpass = GUICtrlCreateButton("Show", 300, 88, 65, 25)
				GUICtrlSetFont(-1, 10, 400, 0, "Arial")
				GUICtrlSetState($btn_credshowpass,$GUI_DISABLE)
				GUICtrlSetColor(-1, _color("black"))
				GUICtrlSetOnEvent(-1, "btn_credshowpassClick")
			$BTN_credAddChange = GUICtrlCreateButton("Add/ Change", 205, 120, 90, 25)
				GUICtrlSetFont(-1, 10, 400, 0, "Arial")
				GUICtrlSetColor(-1, _color("black"))
				GUICtrlSetOnEvent(-1, "BTN_credAddChangeClick")
			$BTN_CredDelete = GUICtrlCreateButton("Delete / Cancel", 92, 120, 105, 25)
				GUICtrlSetFont(-1, 10, 400, 0, "Arial")
				GUICtrlSetColor(-1, _color("black"))
				GUICtrlSetOnEvent(-1, "BTN_CredDeleteClick")
		#endregion
		#region  ================================= add server Settings======================================
			$Tab_serversadd = GUICtrlCreateTabItem("Server CRUD")

				GUICtrlCreateLabel("Server FQDN", 24, 53, 68, 17)
				$TXT_settings_FQDN = GUICtrlCreateInput("", 96, 50, 201, 21)

				GUICtrlCreateLabel("IP", 24, 77, 14, 17)
				$IPAddress1 = _GUICtrlIpAddress_Create($SettingsForm, 96, 75, 201, 21)
				_GUICtrlIpAddress_Set($IPAddress1, "0.0.0.0")
				_GUICtrlIpAddress_ShowHide ($IPAddress1, @SW_HIDE)

				$CMB_selectServerIP = GUICtrlCreateCombo("", 310, 75, 120, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
				GUICtrlSetState($CMB_selectServerIP,$GUI_HIDE)
				$LBL_selectServerIP =GUICtrlCreateLabel("Alternative Server IP's", 315, 100, 130, 17)
				GUICtrlSetState($LBL_selectServerIP,$GUI_HIDE)


				$BTN_Settings_ResetServers= GUICtrlCreateButton("Reset servers to project template", $formWidth-120, 50, 100, 40,$BS_MULTILINE)
				GUICtrlSetOnEvent(-1, "BTN_Settings_ResetServers")
;~ 				GUICtrlSetColor(-1, _color("black"))

				$BTN_Settings_KeepCustomServers= GUICtrlCreateButton("Delete servers, Keep only Customs", $formWidth-120, 100, 100, 40,$BS_MULTILINE)
				GUICtrlSetOnEvent(-1, "BTN_Settings_KeepCustomServers")
;~ 				GUICtrlSetColor(-1, _color("black"))

				$BTN_Settings_NSlookup= GUICtrlCreateButton("NSlookup", 96, 100, 120, 25)
				GUICtrlSetOnEvent(-1, "BTN_Settings_NSlookupClick")
				GUICtrlSetColor(-1, _color("black"))

				$BTN_settings_AddNewServer = GUICtrlCreateButton("Add", 248, 100, 49, 25)
				GUICtrlSetOnEvent(-1, "BTN_settings_AddNewServerClick")
				GUICtrlSetColor(-1, _color("black"))

				$LBL_Settings_DNSregistration = GUICtrlCreateLabel("No DNS Registration found", 96, 135, 250, 20)
				GUICtrlSetFont(-1, 10, 800, 0, "MS Sans Serif")
				GUICtrlSetState(-1,$GUI_HIDE)
				GUICtrlSetBkColor(-1,_color("RED"))

;~ 				$LST_settings_serversAdd = GUICtrlCreateListView("Server FQDN|IP|Group Membership|Custom|Project template", 16, 160, $formWidth-35, $formHigh-240,$__style,$__WsExStyle)
;~ 				Local $__CtrlExStyle = BitOR($LVS_EX_GRIDLINES,$LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE)
;~ 				GUICtrlSendMsg(-1,$LVM_SETEXTENDEDLISTVIEWSTYLE,$__CtrlExStyle,$__CtrlExStyle)

				$columnasnames="Server FQDN|IP|Group Membership|Custom|Project template"
				$LST_settings_serversAdd = GUICtrlCreateListView($columnasnames,16,160,$formWidth-35,$formHigh-240,$__style,0)
				_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
				_GUICtrlListView_SetColumnWidth(-1, 0, 200)
				GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback

				GUICtrlCreateLabel("Only 'Custom' or Not in 'Project template' servers can be deleted",  $formWidth-500, 390, 400, 18)
				$BTN_Settings_ServerRemove = GUICtrlCreateButton("Remove", $formWidth-90, 385, 65, 25)
				GUICtrlSetOnEvent(-1, "BTN_Settings_ServerRemoveClick")
				GUICtrlSetColor(-1, _color("black"))
				GUICtrlSetState($BTN_Settings_ServerRemove,$GUI_DISABLE)
		#EndRegion
		#region  ================================= Custom Groups Settings======================================
			$TAB_Servers = GUICtrlCreateTabItem("Groups and Shares")

				$Group1 = GUICtrlCreateGroup("Server groups", 16, 40, $formWidth-35, $formHigh-250)
				GUICtrlSetFont(-1, 8, 400, 0, "Arial")
					GUICtrlCreateLabel("Custom Group", 28, 67, 73, 18)
					$CMB_custselectgroup = GUICtrlCreateCombo("", 100, 63, 200, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))

					$BTN_custdeletegroup = GUICtrlCreateButton("Delete Group", 310, 61, 80, 23)
					GUICtrlSetOnEvent(-1, "BTN_custdeletegroupClick")
					GUICtrlSetState(-1,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

					GUICtrlCreateLabel("Select Server", 28, 88, 70, 18)
					$CMB_custselectserver = GUICtrlCreateCombo("", 100, 87, 200, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))

					$BTN_custaddcreategrp = GUICtrlCreateButton("Add / Create", 310, 86, 80, 23)
					GUICtrlSetOnEvent(-1, "BTN_custaddcreategrpClick")
					GUICtrlSetState(-1,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

;~ 					$LST_custsrvgrp = GUICtrlCreateListView("Group Name|Server Name", 24, 112,  $formWidth-153, $formHigh-330,$__style,$__WsExStyle)
;~ 					Local $__CtrlExStyle = BitOR($LVS_EX_GRIDLINES,$LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE)
;~ 					GUICtrlSendMsg(-1,$LVM_SETEXTENDEDLISTVIEWSTYLE,$__CtrlExStyle,$__CtrlExStyle)
;~ 					_GUICtrlListView_SetColumnWidth($LST_custsrvgrp, 0, 100)
;~ 					_GUICtrlListView_SetColumnWidth($LST_custsrvgrp, 1, 150)

					$columnasnames="Group Name|Server Name"
					$LST_custsrvgrp = GUICtrlCreateListView($columnasnames, 24, 112,  $formWidth-153, $formHigh-330,$__style,0)
					_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
					_GUICtrlListView_SetColumnWidth(-1, 0, 100)
					_GUICtrlListView_SetColumnWidth(-1, 1, 150)
					GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback

					$BTN_custlistdeletesrv = GUICtrlCreateButton("Delete selected", $formWidth-120, $formHigh-245, 91, 25)
					GUICtrlSetOnEvent(-1, "BTN_custlistdeletesrvClick")
					GUICtrlSetState(-1,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

				GUICtrlCreateGroup("", -99, -99, 1, 1)

				$Group2 = GUICtrlCreateGroup("Shares", 16, 255, $formWidth-35, 155)
					GUICtrlSetFont(-1, 8, 400, 0, "Arial")

					GUICtrlCreateLabel("Share Name", 28, 275, 75, 18)
					$TXT_custsharename = GUICtrlCreateInput("", 100, 275, $formWidth-197, 22)

					GUICtrlCreateLabel("Share Path", 28, 300, 75, 18)
					$TXT_custsharepath = GUICtrlCreateInput("", 100, 300, $formWidth-197, 22)

					$BTN_custaddshare = GUICtrlCreateButton("Add",  $formWidth-85,300, 57, 25)
					GUICtrlSetOnEvent(-1, "BTN_custaddshareClick")
					GUICtrlSetState(-1,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

;~ 					$LST_custshare = GUICtrlCreateListView("Share Name|Share Path", 24, 327, $formWidth-120, 76,$__style,$__WsExStyle)
;~ 					Local $__CtrlExStyle = BitOR($LVS_EX_GRIDLINES,$LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE)
;~ 					GUICtrlSendMsg(-1,$LVM_SETEXTENDEDLISTVIEWSTYLE,$__CtrlExStyle,$__CtrlExStyle)
;~ 					_GUICtrlListView_SetColumnWidth($LST_custshare, 0, 100)
;~ 		  			_GUICtrlListView_SetColumnWidth($LST_custshare, 1, 297)

					$columnasnames="Share Name|Share Path"
					$LST_custshare = GUICtrlCreateListView($columnasnames, 24, 327, $formWidth-120, 76,$__style,0)
					_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
					_GUICtrlListView_SetColumnWidth(-1, 0, 100)
		  			_GUICtrlListView_SetColumnWidth(-1, 1, 297)
					GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback

					$BTN_custdeleteshare = GUICtrlCreateButton("Delete Selected", $formWidth-85, 360, 57, 40,$BS_MULTILINE)
					GUICtrlSetOnEvent(-1, "BTN_custdeleteshareClick")
					GUICtrlSetState(-1,$GUI_DISABLE)
;~ 					GUICtrlSetColor(-1, _color("black"))

				GUICtrlCreateGroup("", -99, -99, 1, 1)
		#EndRegion
		#region  ================================= Forms preferences Settings======================================
		;-------------------   right column -------------------------------
			$Tab_import = GUICtrlCreateTabItem("Form preferences")
$top=40
$left=20
$leftIndent=$left+10
			#region Job Console defaults:
			GUICtrlCreateLabel("Job Console defaults:", $left, $top, 150, 17)
$top+=20
				$CK_settingspref_CleanConsoleEveryLines=GUICtrlCreateCheckbox("Clean console every x lines",$leftIndent, $top, 150, 21)
					GUICtrlSetState($CK_settingspref_CleanConsoleEveryLines,_GetAppSettings("CleanConsoleEveryLines",$GUI_UNCHECKED))
					GUICtrlSetOnEvent(-1, "CK_settingspref_CleanConsoleEveryLines")
				$CMB_settingspref_CleanConsoleEveryLinesvalue = GUICtrlCreateCombo("", $leftIndent+155, $top, 60, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
					GUICtrlSetData($CMB_settingspref_CleanConsoleEveryLinesvalue,"100|250|500|1000|1500|2000|3000|4000|5000|10000",_GetAppSettings("CleanConsoleEveryLinesvalue","1000"))
					GUICtrlSetOnEvent(-1, "CMB_settingspref_CleanConsoleEveryLinesvalue")
$top+=20
				$CK_settingspref_verbose=GUICtrlCreateCheckbox("Verbose (Quiet disabled)",$leftIndent, $top, 150, 21)
					GUICtrlSetState($CK_settingspref_verbose,_GetAppSettings("verbose",$GUI_CHECKED))
					GUICtrlSetOnEvent(-1, "CK_settingspref_verbose")
$top+=20
				$CK_settingspref_quiet=GUICtrlCreateCheckbox("Quiet (Counters only - No enumeration - errors.)",$leftIndent, $top, 230, 21)
					GUICtrlSetState($CK_settingspref_quiet,_GetAppSettings("ConsoleQuiet",$GUI_UNCHECKED))
					GUICtrlSetOnEvent(-1, "CK_settingspref_ConsoleQuiet")
$top+=20
				$CK_settingspref_logactivity=GUICtrlCreateCheckbox("Log Activity",$leftIndent, $top, 150, 21)
					GUICtrlSetState($CK_settingspref_logactivity,_GetAppSettings("logactivity",$GUI_CHECKED))
					GUICtrlSetOnEvent(-1, "CK_settingspref_logactivity")
$top+=20
				$CK_settingspref_showprogress=GUICtrlCreateCheckbox("Show progress",$leftIndent, $top, 150, 21)
					GUICtrlSetState($CK_settingspref_showprogress,_GetAppSettings("ShowProgress",$GUI_UNCHECKED))
					GUICtrlSetOnEvent(-1, "CK_settingspref_showprogress")
$top+=20
				$CK_settingspref_StopOnWarnings=GUICtrlCreateCheckbox("Stop on Warnings",$leftIndent, $top, 150, 21)
					GUICtrlSetState($CK_settingspref_StopOnWarnings,_GetAppSettings("StopOnWarnings",$GUI_CHECKED))
					GUICtrlSetOnEvent(-1, "CK_settingspref_StopOnWarnings")
			#EndRegion
$top+=20
			_lineaV($leftIndent-10,$top,270)
			#region ask creation form defaults:
$top+=5
				GUICtrlCreateLabel("Task creation form defaults:", $left, $top, 140, 17)
$top+=20
				$CK_settingspref_Recurse=GUICtrlCreateCheckbox("Source path 'Recurse'",$leftIndent, $top, 150, 17)
					GUICtrlSetState($CK_settingspref_Recurse,_GetAppSettings("Recurse",$GUI_CHECKED))
					GUICtrlSetOnEvent(-1, "CK_settingspref_Recurse")
$top+=20
				$CK_settingspref_TypeUpdate=GUICtrlCreateCheckbox("Auto Update Servers Type",$leftIndent, $top, 150, 17)
					GUICtrlSetState($CK_settingspref_TypeUpdate,_GetAppSettings("TypeUpdate",$GUI_UNCHECKED))
					GUICtrlSetOnEvent(-1, "CK_settingspref_TypeUpdate")
$top+=20
				GUICtrlCreateLabel("Copy behaviour", $leftIndent, $top+2, 80, 17)
;~ 				GUICtrlSetBkColor(-1,_color("RED"))
				$CMB_settingspref_copybehaviour = GUICtrlCreateCombo("", $leftIndent+85, $top, 140, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
					GUICtrlSetData(-1, "Overwrite|Skip on conflict|Rename on conflict|Prompt user on conflict", _GetAppSettings("CopyBehaviour","Prompt user on conflict"))
					GUICtrlSetOnEvent(-1, "CMB_settingspref_copybehaviour")
$top+=23
				$CK_settingspref_R=GUICtrlCreateCheckbox("",$leftIndent, $top, 150, 17)
;~ 					GUICtrlSetState($CK_settingspref_Recurse,_GetAppSettings("Recurse",$GUI_CHECKED))
;~ 					GUICtrlSetOnEvent(-1, "CK_settingspref_Recurse")
					GUICtrlSetstate(-1,$GUI_DISABLE)
					GUICtrlSetstate(-1,$GUI_HIDE)
$top+=19
				$CK_settingspref_R=GUICtrlCreateCheckbox("",$leftIndent, $top, 150, 17)
;~ 					GUICtrlSetState($CK_settingspref_Recurse,_GetAppSettings("Recurse",$GUI_CHECKED))
;~ 					GUICtrlSetOnEvent(-1, "CK_settingspref_Recurse")
					GUICtrlSetstate(-1,$GUI_DISABLE)
					GUICtrlSetstate(-1,$GUI_HIDE)
$top+=19
				$CK_settingspref_R=GUICtrlCreateCheckbox("",$leftIndent, $top, 150, 17)
;~ 					GUICtrlSetState($CK_settingspref_Recurse,_GetAppSettings("Recurse",$GUI_CHECKED))
;~ 					GUICtrlSetOnEvent(-1, "CK_settingspref_Recurse")
					GUICtrlSetstate(-1,$GUI_DISABLE)
					GUICtrlSetstate(-1,$GUI_HIDE)
			#EndRegion
$top+=25
;~ 			_lineaV($leftIndent-10,$top,270)
		;-------------------   left column -------------------------------
$top=40
$left=310
$leftIndent=$left+20
			#region Task Execution form defaults:
$top+=5
				GUICtrlCreateLabel("Task Execution form defaults:", $left, $top, 140, 17)
$top+=20
				GUICtrlCreateLabel("Default folder location for Executables", $left, $top, 250, 17)
				$TXT_settingspref_ExecutableFileFolderDefault = GUICtrlCreateInput("", $left, $top+17, 265, 21,BitOR($ES_READONLY,$ES_AUTOHSCROLL))
				GUICtrlSetData (-1,_GetAppSettings("ExecutableFileFolderDefault",@WorkingDir))
$top+=40
				$BTN_settingspref_ExecutableFileFolder_BrowseFile = GUICtrlCreateButton("Browse",$left+210, $top, 57, 25)
				GUICtrlSetOnEvent(-1, "BTN_settingspref_ExecutableFileFolder_BrowseFileClick")
				GUICtrlSetColor(-1, _color("black"))
$top+=30
				GUICtrlCreateLabel("Default remote Working folder (Will be created if missing)", $left, $top, 300, 17)
				$TXT_settingspref_ExecutableWorkingFolder = GUICtrlCreateInput("", $left, $top+17, 265, 21)
				GUICtrlSetData (-1,_GetAppSettings("ExecutableWorkingFolder","c:\temp",1))
			#EndRegion
$top+=40
			_lineaV($left-10,$top,280)

		#EndRegion
		#region  ================================= application preferences Settings======================================
			$Tab_import = GUICtrlCreateTabItem("Applicattion preferences")
$top=40
$left=20
$leftIndent=$left+10
			;-------------------   right column -------------------------------
			#region General options:
			GUICtrlCreateLabel("General options:", $left, $top, 150, 17)
$top+=20
				$CK_settingspref_CreateDesktopShortcut=GUICtrlCreateCheckbox("Create Desktop Shortcut",$leftIndent, $top, 150, 21)
					GUICtrlSetState($CK_settingspref_CreateDesktopShortcut,_GetAppSettings("CreateDesktopShortcut",$GUI_CHECKED))
					GUICtrlSetOnEvent(-1, "CK_settingspref_CreateDesktopShortcut")
$top+=22
				_lineaV($leftIndent-10,$top,270)
$top+=6
				GUICtrlCreateLabel("Activity Log Folder:", $left, $top, 200, 17)
				$TXT_settingspref_ActivityLogFolder = GUICtrlCreateInput("", $left, $top+17, 265, 21,BitOR($ES_READONLY,$ES_AUTOHSCROLL))
				GUICtrlSetData ($TXT_settingspref_ActivityLogFolder,_GetAppSettings("ActivityLogFolder",$ActivityLogFolder))
$top+=40
				$BTN_settingspref_ActivityLogFolder = GUICtrlCreateButton("Browse",$left+210, $top, 57, 25)
				GUICtrlSetOnEvent(-1, "BTN_settingspref_ActivityLogFolder")
				GUICtrlSetColor(-1, _color("black"))

				$BTN_settingspref_ActivityLogFolder_default = GUICtrlCreateButton("Default",$left+150, $top, 50, 25)
				GUICtrlSetOnEvent(-1, "BTN_settingspref_ActivityLogFolder_default")
				GUICtrlSetColor(-1, _color("black"))
			#EndRegion
$top+=26
			_lineaV($leftIndent-10,$top,270)

			#region Repo:
$top+=5
				GUICtrlCreateLabel("Projects database Repository:  Http / SMB: / Local Path", $left, $top, 300, 17)
$top+=20
				$TXT_settingspref_Repo = GUICtrlCreateInput("", $left, $top, 270, 21,$ES_AUTOHSCROLL)
				GUICtrlSetData ($TXT_settingspref_Repo,_GetAppSettings("RepoAddress",$RepoProjectDBDefault,1))
$top+=25
				$BTN_settingspref_repo_SaveClick = GUICtrlCreateButton("Save",$left+220, $top, 50, 25)
				GUICtrlSetstate($BTN_settingspref_repo_SaveClick,$GUI_DISABLE)
				GUICtrlSetOnEvent(-1, "BTN_settingspref_repo_SaveClick")
				GUICtrlSetColor(-1, _color("black"))

				$BTN_settingspref_repo_default = GUICtrlCreateButton("Default",$left+160, $top, 50, 25)
				GUICtrlSetOnEvent(-1, "BTN_settingspref_repo_default")
				GUICtrlSetColor(-1, _color("black"))

				$BTN_settingspref_repo_open = GUICtrlCreateButton("Open",$left+100, $top, 50, 25)
				GUICtrlSetOnEvent(-1, "BTN_settingspref_repo_open")
				GUICtrlSetstate($BTN_settingspref_repo_open,$GUI_Enable)
				GUICtrlSetColor(-1, _color("black"))

				$LBL_settingspref_repo_default=GUICtrlCreateLabel("", $leftIndent-10, $top, 90, 30)
;~ 				GUICtrlSetBkColor(-1,_color("RED"))

			#EndRegion
			;-------------------   left column -------------------------------
$top=40
$left=310
$leftIndent=$left+10
			#region proxy
$top+=15
				$CK_settingspref_Proxy=GUICtrlCreateCheckbox("Use Proxy",$left, $top, 75, 17)
					GUICtrlSetState($CK_settingspref_Proxy,_GetAppSettings("UseProxy",$GUI_UNCHECKED,1))
					GUICtrlSetOnEvent(-1, "CK_settingspref_Proxy")
;~ 					GUICtrlSetBkColor(-1,_color("RED"))

				$CK_settingspref_ProxyIE=GUICtrlCreateCheckbox("Use Proxy from Internet Explorer",$left + 100, $top, 180, 17)
					GUICtrlSetState($CK_settingspref_ProxyIE,_GetAppSettings("UseProxyIE",$GUI_UNCHECKED,1))
					GUICtrlSetOnEvent(-1, "CK_settingspref_ProxyIE")
;~ 					GUICtrlSetBkColor(-1,_color("orange"))

$top+=19
				GUICtrlCreateLabel("Proxy:Port"&@crlf&"(ie. proxyserver:8080)", $left, $top, 110, 28)
;~ 				GUICtrlSetBkColor(-1,_color("RED"))
				$TXT_settingspref_Proxy = GUICtrlCreateInput("", $left+110, $top, 155, 21,$ES_AUTOHSCROLL)
				GUICtrlSetData($TXT_settingspref_Proxy,_getproxyport())

$top+=30
				GUICtrlCreateLabel("Credentials", $left, $top, 90, 17)
				$CMB_Proxy_Cred = GUICtrlCreateCombo("", $left+110, $top, 150, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
			#endregion
$top+=26
			_lineaV($left-10,$top,280)
		#EndRegion
		#region  ================================= Database Maintenance Settings======================================
			$Tab_import = GUICtrlCreateTabItem("Database Maintenance")

			$BTN_settings_importExport = GUICtrlCreateButton("Jobs Import && Export", 100, 80, 160, 25)
				GUICtrlSetFont(-1, 10, 400, 0, "Arial")
				GUICtrlSetOnEvent(-1, "BTN_settings_importExport")
				GUICtrlSetColor(-1, _color("black"))

			$BTN_settings_BackupRestore = GUICtrlCreateButton("Backup && Restore", 100, 120, 160, 25)
				GUICtrlSetFont(-1, 10, 400, 0, "Arial")
				GUICtrlSetOnEvent(-1, "BTN_settings_BackupRestore")
				GUICtrlSetColor(-1, _color("black"))

			if _CheckIfFGMAdmin() then
				$BTN_settings_ExpImpProjectServers = GUICtrlCreateButton("Edit Project Database servers", 100, 160, 180, 25)
					GUICtrlSetFont(-1, 10, 400, 0, "Arial")
					GUICtrlSetOnEvent(-1, "BTN_settings_ExpImpProjectServers")
					GUICtrlSetColor(-1, _color("black"))
			endif

		#EndRegion
		#region  ================================= main form Settings======================================
			GUICtrlCreateTabItem("")
			$BTN_SettingsOK = GUICtrlCreateButton("&OK", $formWidth-170 , $formHigh-35, 75, 25)
				GUICtrlSetOnEvent(-1, "BTN_SettingsOKClick")
				GUICtrlSetColor(-1, _color("black"))
;~ 			$BTN_SettingsCancel = GUICtrlCreateButton("&Close", $formWidth-85 , $formHigh-35, 75, 25)
;~ 				GUICtrlSetOnEvent(-1, "BTN_SettingsCancelClick")
			$BTN_SettingsCancel = IconButton("&Close",$formWidth-85 , $formHigh-35, 75, 25, 16, $FgmDataFolderImages & "\Door2.ico")
				GUICtrlSetOnEvent(-1, "BTN_SettingsCancelClick")
				GUICtrlSetColor(-1, _color("black"))

			If Not @Compiled Then
				$BTN_exitClick = GUICtrlCreateButton("&Exit", 8, $formHigh-35, 89, 25)
				GUICtrlSetOnEvent($BTN_exitClick, "BTN_exitClick")
				GUICtrlSetColor($BTN_exitClick, _color("red"))
			EndIf

$formWidth=520
$formHigh=460

		#EndRegion
	#EndRegion
#EndRegion ### END Koda GUI section ###
#Region llenado de datos iniciales
;~ 	CK_settingspref_Proxy()
;~ 	CK_settingspref_ProxyIE()
	_CheckproxyportTXT()
	_FillSettingsFormData()

	if $GUI_UNCHECKED=_GetAppSettings("UseProxy",$GUI_UNCHECKED) then
		GUICtrlSetstate($TXT_settingspref_Proxy,$GUI_DISABLE)
		GUICtrlSetstate($CK_settingspref_ProxyIE,$GUI_DISABLE)
		GUICtrlSetstate($CMB_Proxy_Cred,$GUI_DISABLE)
		GUICtrlSetstate($CK_settingspref_ProxyIE,$GUI_UNCHECKED)
		GUICtrlSetBkColor($TXT_settingspref_Proxy, _color("white"))
	Else
		GUICtrlSetstate($TXT_settingspref_Proxy,$GUI_ENABLE)
		GUICtrlSetstate($CMB_Proxy_Cred,$GUI_ENABLE)
		$res=_GetAppSettings("ProxyUser","")
		ControlCommand ($SettingsForm, "", $CMB_Proxy_Cred, "SelectString", $res)
		CK_settingspref_Proxy()
	endif
#EndRegion
	GUISetState(@SW_SHOW)
#region contextmenu
	_CreateContextMenu_Lists($SettingsForm,"Settings")
#endregion
Global $flagUpdateSettings=1
EndFunc