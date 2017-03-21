Func GUI_DeployAgentTask($posX,$posY,$ParentWide,$task="",$edit=0)
	ConsoleWrite('+GUI_DeployAgentTask() = $taskID = ' & $taskID & @crlf )
	_CheckTaskID()  ; create a unike task id
$title=$task & "  @  " & @ComputerName & _CheckcomputerMembership()
if $task<>"" then
	$formWidth=700
	$formhigh=460
;~ 	$posxis= _PosXaxis($formWidth,$posX)
		$posxis= $posX-(($formWidth-$ParentWide)/2)
		If $posxis < 0 Then	$posxis= 0
		Local $__style = BitOR($WS_BORDER,$LVS_SHOWSELALWAYS,$LVS_REPORT);$LVS_SINGLESEL  $LVS_REPORT

		$TaskDeployAgentForm = GUICreate($title,$formWidth , $formhigh,  $posxis ,$posY)
		GUISetOnEvent($GUI_EVENT_CLOSE, "TaskDeployAgentClose")
		;################### from location to target  ###############################################################################
	$left=8
	$top=8
			GUICtrlCreateLabel("Location Selection", $left, $top, 92, 17)
			GUICtrlCreateLabel("Select type", $left, 32, 57, 17)
			$CMB_TaskDeployAgent_SelType = GUICtrlCreateCombo("", $left, 48, 112, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
			GUICtrlSetData(-1, "|Localhost|Servers|Groups|Custom Groups", "")

			GUICtrlCreateLabel("Select Server/Group", $left + 120, 32, 170, 17)
			$CMD_TaskDeployAgent_SelServerShare = GUICtrlCreateCombo("", $left + 120, 48, 205, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
	#region Target loc
			;-------------------           Target Locations            -----------------------------------
	$top=$top+72
	$listHigh=$formhigh-170

			GUICtrlCreateLabel("Target Locations", $left, $top, 84, 17)
			$LBL_TargetLoc=GUICtrlCreateLabel("", $left+100, $top , 40, 17)

			$BTN_TaskDeployAgent_AddToTargetLoc = GUICtrlCreateButton("Add to Target", 130, $top -5, 80, 25)
			GUICtrlSetOnEvent(-1, "BTN_TaskDeployAgent_AddToTargetLocClick")
			GUICtrlSetState($BTN_TaskDeployAgent_AddToTargetLoc,$GUI_DISABLE)

			$BTN_TaskDeployAgent_DeleteTargetLoc = GUICtrlCreateButton("Delete selected Target", 210, $top -5, 125, 25)
			GUICtrlSetOnEvent(-1, "BTN_TaskDeployAgent_DeleteTargetLoc")
			GUICtrlSetState($BTN_TaskDeployAgent_DeleteTargetLoc,$GUI_DISABLE)

			$CK_TaskForms_UpdateTypesTRG=GUICtrlCreateCheckbox("Auto Update Server Type",$left, $top+15, 112, 28,$BS_MULTILINE)
			GUICtrlSetBkColor(-1, _color("red"))
			if $newtask=1 then GUICtrlSetState(-1,_GetAppSettings("TypeUpdate",$GUI_UNCHECKED))

			$LST_TaskDeployAgent_TargetLoc = GUICtrlCreateListView("Type|Server|Group",  $left, $top + 24, 325, $listHigh,$__style,0)
			_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
			_GUICtrlListView_SetColumnWidth(-1, 0, 120)
			_GUICtrlListView_SetColumnWidth(-1, 1, 225)
			_GUICtrlListView_SetColumnWidth(-1,2, $LVSCW_AUTOSIZE_USEHEADER)
			GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback

			;------------------------------------------------------

			GUICtrlCreateButton("", 345, 3, 5, $formhigh-10)  ; linea separadora
			GUICtrlSetState(-1,$GUI_DISABLE)

			;################### what  ###############################################################################
			;################### what  ###############################################################################
			;################### what  ###############################################################################
	#endregion
	#region                #############    Target path ###################
	$left=365
	$ancho1=595/2+50
	$texthigh=35
	$top=20
	#endregion
	#region  common buttons
	$left+=125
			If Not @Compiled Then
				$BTN_exitClick = GUICtrlCreateButton("&Exit", 380, 425, 89, 25)
				GUICtrlSetOnEvent($BTN_exitClick, "BTN_exitClick")
				GUICtrlSetColor($BTN_exitClick, _color("red"))
			EndIf

			$BTN_TaskDeployAgent_save = GUICtrlCreateButton("&Save task", $left, $formhigh-35, 89, 25)
				GUICtrlSetOnEvent(-1, "BTN_TaskDeployAgent_saveClick")
;~ 				If $edit=0 Then GUICtrlSetState($BTN_TaskDeployAgent_save, $GUI_Disable)
;~ 				GUICtrlSetState($BTN_TaskDeployAgent_save, $GUI_Disable)

			$BTN_TaskDeployAgent_close = GUICtrlCreateButton("&Close", $left +100, $formhigh-35, 89, 25)
				GUICtrlSetOnEvent(-1, "BTN_TaskDeployAgent_closeClick")
	#endregion

		;------------------------------ credential combos
		$left=8
		$top=8
	#region
		$top+=300
		GUICtrlCreateGroup("", $left+360 , $top,  1,1)
			$RD_TaskDeployAgent_Install = GUICtrlCreateRadio("Deploy (Install)", $left+360, 60, 150, 17)
				GUICtrlSetState($RD_TaskDeployAgent_Install, $GUI_CHECKED)
			$RD_TaskDeployAgent_Uninstall=GUICtrlCreateRadio("Uninstall",$left+360,78,150,17)
		GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
	#endregion
	#region description
		$top+=75
			GUICtrlCreateLabel("Description", $left+360, $top, 57, 35)
			$TXT_TaskDeployAgent_taskdesc = GUICtrlCreateInput("", $left+360 + 65,  $top, 247, 21)
	#endregion
	#region credentials
			GUICtrlCreateLabel("Target Credentials", $left, $top+30, 90, 17)
			$CMB_TaskDeployAgent_TargetCred = GUICtrlCreateCombo("", $left+95, $top+30, 135, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
;~ 			GUICtrlSetData(-1, "|dir|ds", "")
			GUICtrlCreateLabel("When .\Logged User selected, the user login will be used", $left+240, $top+20, 80, 68)

		GUISetState(@SW_SHOW)
	#endregion
	#Region llenado de datos iniciales
		_Fill_TaskDeployAgent_Data($task)
		GUICtrlSetState($BTN_TaskDeployAgent_save, $GUI_Disable)
	#EndRegion
Else
	TaskDeployAgentClose()
endif
EndFunc
