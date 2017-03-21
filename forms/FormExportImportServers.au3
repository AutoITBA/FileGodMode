Func GUI_ExportImportServers($ParentPosX,$ParentPosY,$ParentWide)
	$formWidth=610
	$formHigh=340
	Local $__WsExStyle = 0
	$posxis= $ParentPosX-(($formWidth-$ParentWide)/2)
	If $posxis < 0 Then	$posxis= 0
	Local $__style = BitOR($WS_BORDER,$LVS_SHOWSELALWAYS,$LVS_SINGLESEL);$LVS_SINGLESEL  $LVS_REPORT

	$FormExportImportServers= GUICreate("Edit Project Database servers",$formWidth , $formHigh,  $posxis ,$ParentPosY)
		GUISetOnEvent($GUI_EVENT_CLOSE, "FormExportImportServersClose")
		; ----------------- import  --------------------------
		GUICtrlCreateLabel("Select csv file for Import to Project Database", 16, 8, 300, 17)
		$TXT_ExportImportServers_fileImport = GUICtrlCreateInput("", 16, 32, 273, 21, BitOR($ES_READONLY,$ES_AUTOHSCROLL))  ;$ES_READONLY

		$BTN_ExportImportServers_fileImport = GUICtrlCreateButton("Browse", 160, 60, 57, 25)
		GUICtrlSetOnEvent(-1, "BTN_ExportImportServers_BrowseImportClick")

		$LBL_ExportImportServers_List = GUICtrlCreateLabel("", 16, 73, 120, 17)
		$BTN_ExportImportServers_Import = GUICtrlCreateButton("Import", 230, 60, 57, 25)
		GUICtrlSetOnEvent(-1, "BTN_ExportImportServers_ImportClick")
		GUICtrlSetstate($BTN_ExportImportServers_Import,$GUI_DISABLE)

		; --------------------   export -------------------------
		GUICtrlCreateLabel("Select Database for export to csv file", 319, 8, 200, 17)
		$TXT_ExportImportServers_fileExport = GUICtrlCreateInput("", 319, 32, 273, 21, BitOR($ES_READONLY,$ES_AUTOHSCROLL))

		$BTN_ExportImportServers_Template = GUICtrlCreateButton("Download Template", 340, 60, 110, 25)
		GUICtrlSetOnEvent(-1, "BTN_ExportImportServers_Template")

		$BTN_ExportImportServers_fileExport = GUICtrlCreateButton("Browse", 465, 60, 57, 25)
		GUICtrlSetOnEvent(-1, "BTN_ExportImportServers_BrowseExportClick")

		$BTN_ExportImportServers_Export = GUICtrlCreateButton("Export", 535, 60, 57, 25)
		GUICtrlSetOnEvent(-1, "BTN_ExportImportServers_ExportClick")
		GUICtrlSetstate($BTN_ExportImportServers_Export,$GUI_DISABLE)

		;--------------------- table -------------------------------
		$LST_ExportImportServers_Importlist = GUICtrlCreateListView("Server FQDN|IP|Group Membership|Description", 16, 90, $formWidth-35, $formHigh-130,$__style,$__WsExStyle)
		Local $__CtrlExStyle = BitOR($LVS_EX_GRIDLINES,$LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE)
		GUICtrlSendMsg(-1,$LVM_SETEXTENDEDLISTVIEWSTYLE,$__CtrlExStyle,$__CtrlExStyle)
			_GUICtrlListView_SetColumnWidth(-1, 0, 130)
;~ 			_GUICtrlListView_SetColumnWidth(-1, 1, 130)
;~ 			_GUICtrlListView_SetColumnWidth(-1, 2, 1)
;~ 			_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_CHECKBOXES,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
		; -------------------- general ----------------------------
		local $lastline=$formHigh-30

		GUICtrlCreateLabel("DB creation for compilation stack", 20, $lastline, 200, 25)

		$BTN_ExportImportServers_Close = GUICtrlCreateButton("Close", 544, $lastline, 49, 25)
		GUICtrlSetOnEvent(-1, "BTN_ExportImportServers_CloseClick")

		$LBL_ExportImportServers_Load = GUICtrlCreateLabel("", 200, $lastline, 200, 25)
		GUICtrlSetBkColor($LBL_ExportImportServers_Load,_color("RED"))
		$font = "Comic Sans MS"
		GUICtrlSetFont(-1, 12, 700, 0, $font)
		GUICtrlSetstate($LBL_ExportImportServers_Load,$GUI_HIDE)

	GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

	#Region llenado de datos iniciales
;~ 		FormJobImport_fillData()
	#EndRegion
EndFunc



