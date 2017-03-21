Func GUI_JobImport($ParentPosX,$ParentPosY,$ParentWide)
	$Width=610
	$high=340
	$posxis= $ParentPosX-(($Width-$ParentWide)/2)
	If $posxis < 0 Then	$posxis= 0
	Local $__style = BitOR($WS_BORDER,$LVS_SHOWSELALWAYS,$LVS_SINGLESEL);$LVS_SINGLESEL  $LVS_REPORT

	$FormJobImport = GUICreate("Job Import & Export",$Width , $high,  $posxis ,$ParentPosY)
		GUISetOnEvent($GUI_EVENT_CLOSE, "FormJobImportClose")
		; ----------------- import  --------------------------
		GUICtrlCreateLabel("Select file for import", 16, 8, 96, 17)
		$TXT_importExtort_fileImport = GUICtrlCreateInput("", 16, 32, 273, 21, BitOR($ES_READONLY,$ES_AUTOHSCROLL))  ;$ES_READONLY

		$BTN_importExport_fileImport = GUICtrlCreateButton("Browse", 232, 60, 57, 25)
		GUICtrlSetOnEvent(-1, "BTN_importExtort_fileImportClick")

		GUICtrlCreateLabel("Job File content", 16, 64, 79, 17)
		$BTN_importExport_Import = GUICtrlCreateButton("Import All", 232, 264, 57, 25)
		GUICtrlSetOnEvent(-1, "BTN_importExtort_ImportClick")
		GUICtrlSetstate($BTN_importExport_Import,$GUI_DISABLE)

		Local $__style = BitOR($WS_BORDER,$LVS_SHOWSELALWAYS,$LVS_SINGLESEL);$LVS_SINGLESEL  $LVS_REPORT
		$LST_importExport_ImportJoblist = GUICtrlCreateListView("Job Name|Description", 16, 96, 273, 161,$__style,0)
			_GUICtrlListView_SetColumnWidth(-1, 0, 130)
			_GUICtrlListView_SetColumnWidth(-1, 1, 130)
			_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT, _
						$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))

		; --------------------   export -------------------------
		GUICtrlCreateLabel("Select file for export", 318, 211, 97, 17)
		$TXT_importExport_fileExport = GUICtrlCreateInput("", 319, 233, 273, 21, BitOR($ES_READONLY,$ES_AUTOHSCROLL))

		$BTN_importExtort_fileExport = GUICtrlCreateButton("Browse", 463, 265, 57, 25)
		GUICtrlSetOnEvent(-1, "BTN_importExtort_fileExportClick")

		GUICtrlCreateLabel("Select Jobs for export", 319, 9, 106, 17)
		$BTN_importExport_Export = GUICtrlCreateButton("Export", 535, 265, 57, 25)
		GUICtrlSetOnEvent(-1, "BTN_importExport_ExportClick")
		GUICtrlSetstate($BTN_importExport_Export,$GUI_DISABLE)

		Local $__style = BitOR($WS_BORDER,$LVS_SHOWSELALWAYS,$LVS_SINGLESEL);$LVS_SINGLESEL  $LVS_REPORT
		$LST_importExport_ExportJoblist = GUICtrlCreateListView("Job Name|Description|JobId",  319, 31, 273, 177,$__style,0)
			_GUICtrlListView_SetColumnWidth(-1, 0, 130)
			_GUICtrlListView_SetColumnWidth(-1, 1, 130)
			_GUICtrlListView_SetColumnWidth(-1, 2, 1)
			_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT, _
						$LVS_EX_CHECKBOXES,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))

		; -------------------- general ----------------------------
		$BTN_importExport_Close = GUICtrlCreateButton("Close", 544, 307, 49, 25)
		GUICtrlSetOnEvent(-1, "BTN_importExport_CloseClick")

		$LBL_importExport_Load = GUICtrlCreateLabel("    Loading", 20, 307, 100, 25)
		GUICtrlSetBkColor($LBL_importExport_Load,_color("RED"))
		$font = "Comic Sans MS"
		GUICtrlSetFont(-1, 12, 700, 0, $font)
		GUICtrlSetstate($LBL_importExport_Load,$GUI_HIDE)


		GUICtrlCreateLabel("Attention: Remember to set credential for each impotred task", 20, 280, 200, 25)

	GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

	#Region llenado de datos iniciales
		FormJobImport_fillData()
	#EndRegion
EndFunc



