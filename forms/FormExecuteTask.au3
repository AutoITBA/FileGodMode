Func GUI_ExecuteTask($posX,$posY,$ParentWide,$task="",$edit=0)
	ConsoleWrite('+GUI_ExecutionTask() = $taskID = ' & $taskID & @crlf )
	_CheckTaskID()
$title= $task & "            " & @ComputerName & _CheckcomputerMembership()
if $task<>"" then
	$formWidth=900
	$formhigh=510
;~ 	$posxis= _PosXaxis($formWidth,$posX)
		$posxis= $posX-(($formWidth-$ParentWide)/2)
		If $posxis < 0 Then	$posxis= 0
		Local $__style = BitOR($WS_BORDER,$LVS_SHOWSELALWAYS,$LVS_REPORT);$LVS_SINGLESEL  $LVS_REPORT

		$TaskExecutionForm = GUICreate($title,$formWidth , $formhigh,  $posxis ,-1)
		GUISetOnEvent($GUI_EVENT_CLOSE, "TaskExecutionClose")
		;################### from location to target  ###############################################################################
	$left=8
	$top=8
	$LeftPaneWidth=375
			GUICtrlCreateLabel("Location Selection", $left, $top, 92, 17)
			GUICtrlCreateLabel("Select type", $left, 32, 57, 17)
			$CMB_TaskExecution_SelType = GUICtrlCreateCombo("", $left, 48, 112, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
			GUICtrlSetData(-1, "|Localhost|Servers|Groups|Custom Groups", "")
			GUICtrlSetColor(-1, _color("black"))

			$SelectserverCMBleft=$left + 120
			GUICtrlCreateLabel("Select Server/Group", $SelectserverCMBleft, 32, 99, 17)
			$CMD_TaskExecution_SelServerShare = GUICtrlCreateCombo("", $SelectserverCMBleft, 48, $LeftPaneWidth-$SelectserverCMBleft-10, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
			GUICtrlSetColor(-1, _color("black"))
	#region Target loc
			;-------------------           Target Locations            -----------------------------------
	$top=$top+68
	$listHigh=$formhigh-80
			$BTN_TaskExecution_AddToTargetLoc = GUICtrlCreateButton("Add to Target -->", $LeftPaneWidth-245, $top , 97, 25)
			GUICtrlSetOnEvent(-1, "BTN_TaskExecution_AddToTargetLocClick")
			GUICtrlSetState($BTN_TaskExecution_AddToTargetLoc,$GUI_DISABLE)
			GUICtrlSetColor(-1, _color("black"))

			$BTN_TaskExecution_DeleteTargetLoc = GUICtrlCreateButton("Delete selected Target", $LeftPaneWidth-135, $top , 125, 25)
			GUICtrlSetOnEvent(-1, "BTN_TaskExecution_DeleteTargetLoc")
			GUICtrlSetState(-1,$GUI_DISABLE)
			GUICtrlSetColor(-1, _color("black"))

			$CK_TaskForms_UpdateTypesTRG=GUICtrlCreateCheckbox("Auto Update Servers Type",$left, $top-5, 112, 30,$BS_MULTILINE)
			GUICtrlSetBkColor(-1, _color("RED"))
			if $newtask=1 then GUICtrlSetState(-1,_GetAppSettings("TypeUpdate",$GUI_UNCHECKED))
	$top+=25
			GUICtrlCreateLabel("Target Locations", $left, $top, 84, 17)
			$LBL_TargetLoc=GUICtrlCreateLabel("", $left+100, $top , 40, 17)
	$top+=20
			$LST_TaskExecution_TargetLoc = GUICtrlCreateListView("Type|Server|Group",  $left, $top , $LeftPaneWidth-20, $listHigh-$top,$__style,0)
			_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
			_GUICtrlListView_SetColumnWidth(-1, 0, 120)
			_GUICtrlListView_SetColumnWidth(-1, 1, $LVSCW_AUTOSIZE_USEHEADER)
			_GUICtrlListView_SetColumnWidth(-1, 2, $LVSCW_AUTOSIZE_USEHEADER)
			GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback

			;-----------------------         linea separadora            -------------------------------
			GUICtrlCreateButton("", $LeftPaneWidth, 3, 5, $formhigh-10)
			GUICtrlSetState(-1,$GUI_DISABLE)
	#endregion
	#region                #############    Left Pane Column  ###############################################################################
	$left=$LeftPaneWidth+20
	$RightPaneWidth=$formWidth-$LeftPaneWidth
	$ListWidth=$RightPaneWidth-40
	$texthigh=35
	$top=10
			GUICtrlCreateLabel("Select execution source", $left, $top+3, 120, 17)
			$CMB_TaskExecution_mode = GUICtrlCreateCombo("", $left+135, $top, 160, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
			GUICtrlSetData(-1, "Execution commands|Script file (CMD/BAT/PS1)", "Execution commands")

	$top+=30
		$edtctrlhigh=140
		;------- show
			$LBL_TaskExecution_commands = GUICtrlCreateLabel("Execution commands. (New line = Ctrl+Enter or '\n')", $left, $top, 260, 17)
			$EDT_TaskExecution_commands = GUICtrlCreateEdit("",  $left, $top+20, $ListWidth, $edtctrlhigh, $ES_AUTOVSCROLL + $WS_VSCROLL)
			_lineaV($left,$top+25+$edtctrlhigh,$ListWidth+10)
		;------- hide
			$LBL_TaskExecution_scriptfile = GUICtrlCreateLabel("Select script file", $left, $top, 200, 17)
			$TXT_TaskExecution_scriptfile = GUICtrlCreateInput("", $left, $top+17, 340, 21,BitOR($ES_READONLY,$ES_AUTOHSCROLL))
			GUICtrlSetState($BTN_TaskExecution_addFile, $GUI_Disable)
			$BTN_TaskExecution_scriptfile_BrowseFile = GUICtrlCreateButton("Browse",$left+365, $top+15, 57, 25)
			GUICtrlSetOnEvent(-1, "BTN_TaskExecution_BrowseScriptClick")
			GUICtrlSetColor(-1, _color("black"))

			GUICtrlSetState($LBL_TaskExecution_scriptfile, $GUI_HIDE)
			GUICtrlSetState($TXT_TaskExecution_scriptfile, $GUI_HIDE)
			GUICtrlSetState($BTN_TaskExecution_scriptfile_addFile, $GUI_HIDE)
			GUICtrlSetState($BTN_TaskExecution_scriptfile_BrowseFile, $GUI_HIDE)

	$top+=$edtctrlhigh+30
			GUICtrlCreateLabel("Extra files", $left, $top, 200, 17)
			$TXT_TaskExecution_ExtraFile = GUICtrlCreateInput("", $left, $top+17, 290, 21,BitOR($ES_READONLY,$ES_AUTOHSCROLL))
	$top+=15
			$BTN_TaskExecution_addFile = GUICtrlCreateButton("Add",$left+300, $top, 57, 25)
			GUICtrlSetOnEvent(-1, "BTN_TaskExecution_addFileClick")
			GUICtrlSetColor(-1, _color("black"))
			GUICtrlSetState($BTN_TaskExecution_addFile, $GUI_Disable)
			$BTN_TaskExecution_BrowseFile = GUICtrlCreateButton("Browse",$left+365, $top, 57, 25)
			GUICtrlSetOnEvent(-1, "BTN_TaskExecution_BrowseFileClick")
			GUICtrlSetColor(-1, _color("black"))
	$top+=5
		$edtctrlhigh=100
;~ 			$EDT_TaskExecution_extraFiles = GUICtrlCreateEdit("",  $left, $top+20, 310, $edtctrlhigh, $ES_READONLY + $WS_VSCROLL + $WS_HSCROLL)
			$LST_TaskExecution_extraFiles = GUICtrlCreateListView("File",  $left, $top + 24, $ListWidth, $edtctrlhigh,BitOR($WS_BORDER,$LVS_SHOWSELALWAYS,$LVS_NOCOLUMNHEADER),0)
			_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
			_GUICtrlListView_SetColumnWidth(-1, 0, $LVSCW_AUTOSIZE_USEHEADER)
			GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback

			_lineaV($left,$top+27+$edtctrlhigh,$ListWidth+10)

	$top+=$edtctrlhigh+35
			GUICtrlCreateLabel("Target working folder for the executable at the remote server.", $left, $top, 260, 17)
			$TXT_TaskExecution_TargetPath = GUICtrlCreateInput("", $left, $top+17, 310, 21)

	;------------------- examples --------------
	$top+=40
			GUICtrlCreateLabel("Ex. c:\MyFolder (Always use Localpath) Folder will be created if not exist.", _
						$left , $top, $ListWidth-30, $texthigh, $SS_RIGHTJUST);BitOR($SS_CENTER,$SS_RIGHTJUST)
			;------------------------------------------------------
	#endregion
	#region  common buttons
	$left+=125
			If Not @Compiled Then
				$BTN_exitClick = GUICtrlCreateButton("&Exit", $LeftPaneWidth+30, $formhigh-35, 89, 25)
				GUICtrlSetOnEvent($BTN_exitClick, "BTN_exitClick")
				GUICtrlSetColor($BTN_exitClick, _color("red"))
			EndIf

			$BTN_TaskExecution_save = GUICtrlCreateButton("&Save task", $formWidth-210, $formhigh-35, 89, 25)
				GUICtrlSetOnEvent(-1, "BTN_TaskExecution_saveClick")
				GUICtrlSetColor(-1, _color("black"))
;~ 				If $edit=0 Then GUICtrlSetState($BTN_TaskExecution_save, $GUI_Disable)
;~ 				GUICtrlSetState($BTN_TaskExecution_save, $GUI_Disable)

			$BTN_TaskExecution_close = GUICtrlCreateButton("&Close", $formWidth-105, $formhigh-35, 89, 25)
				GUICtrlSetOnEvent(-1, "BTN_TaskExecution_closeClick")
				GUICtrlSetColor(-1, _color("black"))
	#endregion
	#region credentials
		;------------------------------ credential combos
		$left=8
		$topright=$formhigh-70
			GUICtrlCreateLabel("Description", $LeftPaneWidth +20, $topright+3, 57, 21)
			$TXT_TaskExecution_taskdesc = GUICtrlCreateInput("", $LeftPaneWidth+20 + 65,  $topright, 247, 21)

		$topleft=$formhigh-80
			GUICtrlCreateLabel("Target Credentials", $left, $topleft+20, 90, 17)
			$CMB_TaskExecution_TargetCred = GUICtrlCreateCombo("", $left, $topleft+40, 160, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
			GUICtrlSetColor(-1, _color("black"))
			GUICtrlCreateLabel("When .\Logged User selected, the user login will be used", $left+170, $topleft+20, 110, 68)

		GUISetState(@SW_SHOW)
	#endregion
	#Region llenado de datos iniciales
		_Fill_TaskExecution_Data($task)
		GUICtrlSetState($BTN_TaskExecution_save, $GUI_Disable)
	#EndRegion
	#region contextmenu
		_CreateContextMenu_Lists($TaskExecutionForm,$task)
	#endregion
Else
	TaskExecutionClose()
endif
EndFunc

