
Func GUI_CopyTask($ParentPosX,$ParentPosY,$ParentWide,$task="",$edit=0)
	ConsoleWrite('+GUI_CopyTask() = $taskID = ' & $taskID & @crlf )
	_CheckTaskID()  ; create a unike task id
	$title= $task & "            " & @ComputerName & _CheckcomputerMembership()
if $task<>"" then
#Region ### START Koda GUI section ###

	$width=1040
	$high=550
	$posxis= $ParentPosX-(($Width-$ParentWide)/2)
	If $posxis < 0 Then	$posxis= 0
	Local $__style = BitOR($WS_BORDER,$LVS_SHOWSELALWAYS,$LVS_REPORT);$LVS_SINGLESEL  $LVS_REPORT

;~ 	$TaskFolderCreation = GUICreate($title,$Width , $high,  $posxis ,$ParentPosY)
	$TasKCopyCreation = GUICreate($title,$Width , $high,  $posxis ,$ParentPosY)
	GUISetOnEvent($GUI_EVENT_CLOSE, "TaskCopyCreationClose")
#region                       ########## source loc    ########################
$left=8
$top=8
$listHigh=$high-250
		GUICtrlCreateLabel("Location Selection", $left, $top, 92, 17)
		;------------------------------------------------------
$top=$top+17
		GUICtrlCreateLabel("Select type", $left, $top, 57, 17)
		GUICtrlCreateLabel("Select server/Group/Share", $left + 120, $top, 170, 17)
$top=$top+15
		$CMB_TaskFolderCreation_SelType = GUICtrlCreateCombo("", $left, $top, 112, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
		GUICtrlSetData(-1, "|Localhost|Servers|Groups|Custom Groups|Shares", "")
		GUICtrlSetColor(-1, _color("black"))

		$CMD_TaskFolderCreation_SelServerShare = GUICtrlCreateCombo("", $left + 120, $top, 205, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
		GUICtrlSetColor(-1, _color("black"))
		;---------------------            Source Locations         ---------------------------------
$top=$top+23

		$BTN_TaskFolderCreation_AddToSourceLoc = GUICtrlCreateButton("Add to source", $left + 120, $top , 80, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_AddToSourceLocClick")
		GUICtrlSetState($BTN_TaskFolderCreation_AddToSourceLoc,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$BTN_TaskFolderCreation_DeleteSourceLoc = GUICtrlCreateButton("Delete selected source", 210, $top , 125, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_DeleteSourceLoc")
		GUICtrlSetState($BTN_TaskFolderCreation_DeleteSourceLoc,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$CK_TaskForms_UpdateTypesSRC=GUICtrlCreateCheckbox("Auto Update Servers Type",$left, $top, 112, 28,$BS_MULTILINE)
		GUICtrlSetBkColor(-1, _color("red"))
		if $newtask=1 then GUICtrlSetState(-1,_GetAppSettings("TypeUpdate",$GUI_UNCHECKED))
$top+=30
		GUICtrlCreateLabel("Source Locations", $left, $top , 87, 17)
		$LBL_SourceLoc=GUICtrlCreateLabel("", $left+100, $top , 40, 17)
$top+=17
		$LST_TaskFolderCreation_SourceLoc = GUICtrlCreateListView("Type|Server/Share|Group",$left, $top, 325, $listHigh-$top,$__style,0)
		_GUICtrlListView_SetExtendedListViewStyle(-1,BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
		_GUICtrlListView_SetColumnWidth(-1, 0, 120)
		_GUICtrlListView_SetColumnWidth(-1, 1, $LVSCW_AUTOSIZE_USEHEADER )
		_GUICtrlListView_SetColumnWidth(-1, 2, $LVSCW_AUTOSIZE_USEHEADER )
		GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback

		_lineaV($left-5,$listHigh+3,335)
#endregion
#region                       ########## Target loc    ########################
	$top=$top+200
	$listHigh=$high-10
		$BTN_TaskFolderCreation_AddToTargetLoc = GUICtrlCreateButton("Add to Target", $left + 120, $top , 80, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_AddToTargetLocClick")
		GUICtrlSetState($BTN_TaskFolderCreation_AddToTargetLoc,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$BTN_TaskFolderCreation_DeleteTargetLoc = GUICtrlCreateButton("Delete selected Target", 210, $top , 125, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_DeleteTargetLoc")
		GUICtrlSetState($BTN_TaskFolderCreation_DeleteTargetLoc,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$CK_TaskForms_UpdateTypesTRG=GUICtrlCreateCheckbox("Auto Update Servers Type",$left, $top, 112, 28,$BS_MULTILINE)
		GUICtrlSetBkColor(-1, _color("red"))
		if $newtask=1 then GUICtrlSetState(-1,_GetAppSettings("TypeUpdate",$GUI_UNCHECKED))
$top+=29
		GUICtrlCreateLabel("Target Locations", $left, $top, 84, 17)
		$LBL_TargetLoc=GUICtrlCreateLabel("", $left+100, $top , 40, 17)
$top+=15
		$LST_TaskFolderCreation_TargetLoc = GUICtrlCreateListView("Type|Server/Share|Group",  $left, $top, 325, $listHigh-$top,$__style,0)
		_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
		_GUICtrlListView_SetColumnWidth(-1, 0, 120)
		_GUICtrlListView_SetColumnWidth(-1, 1, $LVSCW_AUTOSIZE_USEHEADER )
		_GUICtrlListView_SetColumnWidth(-1, 2, $LVSCW_AUTOSIZE_USEHEADER )
		GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback

		GUICtrlCreateButton("", 345, 3, 5, $high-10)  ; linea separadora
		GUICtrlSetState(-1,$GUI_DISABLE)
#endregion
#region                       ########## source path   ########################
		;################### what  ###############################################################################
		;################### what  ###############################################################################
		;################### what  ###############################################################################
$left=365
$top=110
$tshift=50
$listHigh=200
		GUICtrlCreateLabel("Path selection (completes the selected location)", $left, 4, 229, 17)

		GUICtrlCreateLabel("Source Folder", $left, 20, 80, 17)
		$TXT_TaskFolderCreation_SourcePath = GUICtrlCreateInput("", $left, 37, 320, 21)
		$t=GUICtrlCreateLabel("USE FILTER TO SELECT FOLDER CONTENTS", $left+90, 21, 280, 15)
		GUICtrlSetColor($t, _color("red"))

		GUICtrlCreateLabel("Content Filter", $left, 62, 50, 25, $SS_RIGHTJUST)
		$TXT_TaskFolderCreation_SourceZIPFilter = GUICtrlCreateInput("", $left+40, 65, 80, 21)

		GUIStartGroup()
		$ShiftSelectionsSource=$left+130
			GUICtrlCreateGroup("", $ShiftSelectionsSource , $top,  1,1)
				$RD_CopyTask_Copy = GUICtrlCreateRadio("Copy", $ShiftSelectionsSource, 60, 50, 17)
					GUICtrlSetState($RD_CopyTask_Copy, $GUI_CHECKED)
				$RD_CopyTask_Move=GUICtrlCreateRadio("Move [MV] ",$ShiftSelectionsSource,78,70,17)
					$t=GUICtrlCreateLabel("(Delete files on source)" , $ShiftSelectionsSource + 80, 78, 120, 21, $SS_RIGHTJUST)
					GUICtrlSetColor($t, _color("red"))
				$RD_CopyTask_Mirror=GUICtrlCreateRadio("Mirror [M] ",$ShiftSelectionsSource,97,70,17)
					$t=GUICtrlCreateLabel("(Clear target content first)" , $ShiftSelectionsSource + 70, 97, 120, 21, $SS_RIGHTJUST)
					GUICtrlSetColor($t, _color("red"))
			GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
			$CK_TaskFolderCreation_Recurse=GUICtrlCreateCheckbox("Recurse [R]",$left+40, 90, 80, 21)
			GUICtrlSetState($CK_TaskFolderCreation_Recurse,_GetAppSettings("Recurse",$GUI_CHECKED))

		_dateCluster($left,120)

		$BTN_TaskFolderCreation_AddSourcePath = GUICtrlCreateButton("Add Source Path", $left, $top+$tshift, 95, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_AddSourcePathClick")
		GUICtrlSetState($BTN_TaskFolderCreation_AddSourcePath,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$BTN_TaskFolderCreation_DeleteSourcePath = GUICtrlCreateButton("Delete selected target", $left + 200, $top+$tshift, 115, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_DeleteSourcePathClick")
		GUICtrlSetState($BTN_TaskFolderCreation_DeleteSourcePath,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$columnasnames="Source Path|Content Filter"
;~ 		if $task="Compression Task" Or $task="Decompression Task" Then $columnasnames="Source Path|Content Filter"
		$LST_TaskFolderCreation_SourcePaths = GUICtrlCreateListView($columnasnames, $left, $top+$tshift + 28, 320, $listHigh-$tshift,$__style,0)
		_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
		_GUICtrlListView_SetColumnWidth(-1, 0, 230)
		_GUICtrlListView_SetColumnWidth(-1, 1, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback

#endregion
#region                       ########## Target path   ########################
$left=$left+330

		GUICtrlCreateLabel("Target Folder", $left, 20, 90, 17)
		$TXT_TaskFolderCreation_TargetPath = GUICtrlCreateInput("", $left, 37, 320, 21)

		GUICtrlCreateLabel("Copy Behavior", $left, 62, 100, 17, $SS_RIGHTJUST)
		$CMB_CopyTask_Behaviour = GUICtrlCreateCombo("", $left, 80, 140, 20, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
		GUICtrlSetData(-1, "Overwrite|Skip on conflict|Rename on conflict|Prompt user on conflict", _GetAppSettings("CopyBehaviour","Prompt user on conflict"))

		$CK_CopyTask_RStructure=GUICtrlCreateCheckbox("No Structure [NS]",$left+150, 62, 150, 21)
;~ 		GUICtrlSetState($CK_CopyTask_RStructure,$GUI_CHECKED)
		$CK_CopyTask_FolderPerSource=GUICtrlCreateCheckbox("One folder per source [OF]",$left+150, 85, 150, 21)
		GUICtrlSetState($CK_CopyTask_FolderPerSource,$GUI_CHECKED)
		$CK_CopyTask_EmptyFolders=GUICtrlCreateCheckbox("Copy empty folders [EF]",$left+150, 108, 150, 21)
		GUICtrlSetState($CK_CopyTask_EmptyFolders,$GUI_CHECKED)
$top=$top+$tshift

		$BTN_TaskFolderCreation_AddTargetPath = GUICtrlCreateButton("Add Target Path", $left , $top, 95, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_AddTargetPathClick")
		GUICtrlSetState($BTN_TaskFolderCreation_AddTargetPath,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$BTN_TaskFolderCreation_DeleteTargetPath = GUICtrlCreateButton("Delete selected target", $left + 200, $top, 115, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_DeleteTargetPathClick")
		GUICtrlSetState($BTN_TaskFolderCreation_DeleteTargetPath,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$columnasnames="Target Path|Copy Behaviour"
		$LST_TaskFolderCreation_TargetPaths = GUICtrlCreateListView($columnasnames, $left, $top + 28, 320, $listHigh-$Tshift,$__style,0)
		_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
		_GUICtrlListView_SetColumnWidth(-1, 0, 220)
		_GUICtrlListView_SetColumnWidth(-1, 1, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback

#endregion
#region   leyendas
$top=$top+$listHigh-$Tshift+30
	 GUICtrlCreateGroup("", $left , $top,  320,130)
		GUICtrlCreateLabel("Source/Target Examples: c:\MyFolder (Always use Localpath) or \MyFolder (Folder in Share preceeded by \)", $left+5 , $top+10, 300, 28, $SS_RIGHTJUST);BitOR($SS_CENTER,$SS_RIGHTJUST)
		GUICtrlCreateLabel("Content Filter: Wildcards (Ex. *.* and ?) for files"&@crlf&@tab&@tab&"*  only child files/folders" , $left+5 , $top+40, 300, 28, $SS_RIGHTJUST)
		GUICtrlCreateLabel("MIRROR COPY MODE: Selection will be enabled when only one source is listed" , $left+5 , $top+75, 300, 28, $SS_RIGHTJUST)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
#endregion
#region General Buttons
$left=$left+125

		If Not @Compiled Then
			$BTN_exitClick = GUICtrlCreateButton("&Exit", 380, 500, 89, 25)

			GUICtrlSetOnEvent($BTN_exitClick, "BTN_exitClick")
			GUICtrlSetColor($BTN_exitClick, _color("red"))
		EndIf

		$BTN_FolderCreation_save = GUICtrlCreateButton("&Save task", $left, $high-35, 89, 25)
			GUICtrlSetOnEvent(-1, "BTN_FolderCreation_saveClick")
			GUICtrlSetColor(-1, _color("black"))

		$BTN_FolderCreation_close = GUICtrlCreateButton("&Close", $left +100, $high-35, 89, 25)
			GUICtrlSetOnEvent(-1, "BTN_TaskCopy_closeClick")
			GUICtrlSetColor(-1, _color("black"))
#endregion
#region credentials
$left=8
$top=8
$top=$top+345
$left=$left+360

		GUICtrlCreateLabel("Description", $left, $top, 55, 45)
		$TXT_FolderCreation_taskdesc = GUICtrlCreateInput("", $left + 65,  $top, 247, 21)

		GUICtrlCreateLabel("Source Credentials", $left, $top+50, 90, 17)
		$CMB_TaskFolderCreation_SourceCred = GUICtrlCreateCombo("", $left+95, $top+45, 135, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
		GUICtrlSetData(-1, "|dir|ds", "")

		GUICtrlCreateLabel("Target Credentials", $left, $top+75, 90, 17)
		$CMB_TaskFolderCreation_TargetCred = GUICtrlCreateCombo("", $left+95, $top+70, 135, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
;~ 		GUICtrlSetData(-1, "|dir1|ds1", "")

;~ 		if $task="Compression Task" then
;~ 			$CK_TaskFolderCreation_Powershell=GUICtrlCreateCheckbox("Enable Remoting Powershell at runtime", $left + 333, $top+45, 247, 21)
;~ 			GUICtrlSetState($CK_TaskFolderCreation_Powershell,$GUI_DISABLE)
;~ 			GUICtrlSetState($CK_TaskFolderCreation_Powershell,$GUI_UNCHECKED)
;~ 		endif
		GUICtrlCreateLabel("When .\Logged User selected, the user login will be used", $left+240, $top+45, 80, 68)

GUISetState(@SW_SHOW)
#endregion
#Region llenado de datos iniciales
	_Fill_TaskCopy_Data($task)
	GUICtrlSetState($BTN_FolderCreation_save, $GUI_Disable)
#EndRegion
#region contextmenu
	_CreateContextMenu_Lists($TasKCopyCreation,$task)
#endregion
Else
	TaskCopyCreationClose()
endif
#endregion
EndFunc
