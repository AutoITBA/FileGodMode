
Func GUI_FolderCreation($ParentPosX,$ParentPosY,$ParentWide,$task="",$edit=0)
	ConsoleWrite('+GUI_FolderCreation() = $taskID = ' & $taskID & @crlf )
	_CheckTaskID() ; create a unike task id
$title= $task & "            " & @ComputerName & _CheckcomputerMembership()
if $task<>"" then
#Region ### START Koda GUI section ###
$bigform=$task<>"Folder Creation Task"  and $task<>"Deletion Task"
if $bigform then
	$width=1040
	$high=550
else
	$width=700
	$high=460
endif
;~ 	$posxis= _PosXaxis($formWidth,$posX)
	$posxis= $ParentPosX-(($Width-$ParentWide)/2)
	If $posxis < 0 Then	$posxis= 0
	Local $__style = BitOR($WS_BORDER,$LVS_SHOWSELALWAYS,$LVS_REPORT);$LVS_SINGLESEL  $LVS_REPORT

		$TaskFolderCreation = GUICreate($title,$Width , $high,  $posxis ,$ParentPosY)
		GUISetOnEvent($GUI_EVENT_CLOSE, "TaskFolderCreationClose")
#region source loc    ############# source Location ###################
		;################### from location t otarget  ###############################################################################
$left=8
$top=8
		GUICtrlCreateLabel("Location Selection", $left, $top, 92, 17)
		;------------------------------------------------------
$top+=18
		GUICtrlCreateLabel("Select type", $left, $top , 57, 17)
		GUICtrlCreateLabel("Select server/Group/Share", $left + 120, $top, 170, 17)
$top+=15
		$CMB_TaskFolderCreation_SelType = GUICtrlCreateCombo("", $left, $top, 112, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
		GUICtrlSetData(-1, "|Localhost|Servers|Groups|Custom Groups|Shares", "")

		$CMD_TaskFolderCreation_SelServerShare = GUICtrlCreateCombo("", $left + 120, $top, 205, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
		;---------------------            Source Locations         ---------------------------------
if $bigform then
	$top=$top+22
	$listHigh=$high-265
		$BTN_TaskFolderCreation_AddToSourceLoc = GUICtrlCreateButton("Add to source", 125, $top , 80, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_AddToSourceLocClick")
		GUICtrlSetState($BTN_TaskFolderCreation_AddToSourceLoc,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$BTN_TaskFolderCreation_DeleteSourceLoc = GUICtrlCreateButton("Delete selected source", 215, $top , 120, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_DeleteSourceLoc")
		GUICtrlSetState($BTN_TaskFolderCreation_DeleteSourceLoc,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$CK_TaskForms_UpdateTypesSRC=GUICtrlCreateCheckbox("Auto Update Servers Type",$left, $top, 112, 28,$BS_MULTILINE)
		GUICtrlSetBkColor(-1, _color("red"))
		if $newtask=1 then GUICtrlSetState(-1,_GetAppSettings("TypeUpdate",$GUI_UNCHECKED))
	$top+=30
	GUICtrlCreateLabel("Source Locations", $left, $top , 87, 17)
	$LBL_SourceLoc=GUICtrlCreateLabel("", $left+100, $top , 40, 17)
	$top+=16
		$LST_TaskFolderCreation_SourceLoc = GUICtrlCreateListView("Type|Server/Share|Group",$left, $top, 325, $listHigh-$top,$__style,0)
		_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
		_GUICtrlListView_SetColumnWidth(-1, 0, 100)
		_GUICtrlListView_SetColumnWidth(-1, 1, $LVSCW_AUTOSIZE_USEHEADER)
		_GUICtrlListView_SetColumnWidth(-1, 2, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback
endif
#endregion
	if $bigform then
		_lineaV($left-5,$listHigh+3,335)
	endif
#region Target loc    ############# Target Location ###################
		;-------------------           Target Locations            -----------------------------------
if $bigform then
	$top=$top+185
;~ 	$listHigh=195
	$listHigh=$high-10
else
	$top=$top+25
	$listHigh=$high-60
endif
		$BTN_TaskFolderCreation_AddToTargetLoc = GUICtrlCreateButton("Add to Target", 127, $top , 80, 25)
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
	$top+=30
		GUICtrlCreateLabel("Target Locations", $left, $top, 84, 17)
		$LBL_TargetLoc=GUICtrlCreateLabel("", $left+100, $top , 40, 17)
	$top=$top+15
		$LST_TaskFolderCreation_TargetLoc = GUICtrlCreateListView("Type|Server/Share|Group",  $left, $top , 325, $listHigh-$top,$__style,0)
		_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
		_GUICtrlListView_SetColumnWidth(-1, 0, 100)
		_GUICtrlListView_SetColumnWidth(-1, 1, $LVSCW_AUTOSIZE_USEHEADER)
		_GUICtrlListView_SetColumnWidth(-1, 2, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback

		;------------------------------------------------------

		GUICtrlCreateButton("", 345, 3, 5, $high-10)  ; linea separadora
		GUICtrlSetState(-1,$GUI_DISABLE)

		;################### what  ###############################################################################
		;################### what  ###############################################################################
		;################### what  ###############################################################################
#endregion
#region               ############# source path     ###################
$left=365
		GUICtrlCreateLabel("Path selection (completes the selected location)", $left, 4, 229, 17)

if $bigform then
	$top=110
	$tsft=110
else
	$top=140
endif
$listHigh=260
if $bigform then
		GUICtrlCreateLabel("Source Folder", $left, 20, 80, 17)
		$TXT_TaskFolderCreation_SourcePath = GUICtrlCreateInput("", $left, 37, 320, 21)
		if $task="Compression Task" then  ;00000000000000000000000000000000000000000000000000000000
			$t=GUICtrlCreateLabel("USE FILTER TO SELECT FOLDER CONTENTS", $left+90, 21, 280, 15)
			GUICtrlSetColor($t, _color("red"))
			GUICtrlCreateLabel("Content Filter", $left, 62, 50, 25, $SS_RIGHTJUST)
			$TXT_TaskFolderCreation_SourceZIPFilter = GUICtrlCreateInput("", $left+50, 65, 90, 21)

			$CK_TaskFolderCreation_Recurse=GUICtrlCreateCheckbox("Recurse [R]",$left+190, 82, 80, 21)
			GUICtrlSetState($CK_TaskFolderCreation_Recurse,_GetAppSettings("Recurse",$GUI_CHECKED))
;~ 			GUICtrlSetBkColor(-1,_color("RED"))
		endif
		if $task="Decompression Task" then  ;00000000000000000000000000000000000000000000000000000000
			GUICtrlCreateLabel("Content Filter", $left, 62, 50, 25, $SS_RIGHTJUST)
			$TXT_TaskFolderCreation_SourceZIPFilter = GUICtrlCreateInput("", $left+50, 65, 90, 21)
			GUICtrlCreateLabel(".zip extension auto-added", $left+145, 66, 150, 25, $SS_RIGHTJUST)
		EndIf

		_dateCluster($left,103)

		$BTN_TaskFolderCreation_AddSourcePath = GUICtrlCreateButton("Add Source Path", $left, $top+$tsft, 95, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_AddSourcePathClick")
		GUICtrlSetState($BTN_TaskFolderCreation_AddSourcePath,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$BTN_TaskFolderCreation_DeleteSourcePath = GUICtrlCreateButton("Delete selected target", $left + 200, $top+$tsft, 115, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_DeleteSourcePathClick")
		GUICtrlSetState($BTN_TaskFolderCreation_DeleteSourcePath,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$columnasnames="Source Path"
		if $task="Compression Task" Or $task="Decompression Task" Then $columnasnames="Source Path|Content Filter"
		$LST_TaskFolderCreation_SourcePaths = GUICtrlCreateListView($columnasnames, $left, $top+$tsft + 28, 320, $listHigh-$tsft,$__style,0)
		_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
		_GUICtrlListView_SetColumnWidth(-1, 0, 200)
		_GUICtrlListView_SetColumnWidth(-1, 1, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback

endif

#endregion
#region               #############    Target path  ###################
if $bigform Then    ;00000000000000000000000000000000000000000000000000000000
	$ancho1=595
	$left1=$left
	$left=$left+330
	$texthigh=17
else
	$ancho1=595/2+50
	$left1=$left
	$texthigh=35
endif

		GUICtrlCreateLabel("Target Folder", $left, 20, 90, 17)
		$TXT_TaskFolderCreation_TargetPath = GUICtrlCreateInput("", $left, 37, 320, 21)
		if $task="Deletion Task" Then   ;00000000000000000000000000000000000000000000000000000000
			GUICtrlCreateLabel("If NOT FILTER,the FOLDER WILL BE DELETED", $left+75, 20, 300, 17)
			GUICtrlSetColor(-1, _color("red"))

			GUICtrlCreateLabel("Content Filter", $left, 62, 50, 25, $SS_RIGHTJUST)
			$TXT_TaskFolderCreation_TargetPathFilter = GUICtrlCreateInput("", $left+50, 65, 90, 21)

			_dateCluster($left,105)

			$CK_TaskFolderCreation_RecycleBin=GUICtrlCreateCheckbox("Empty the recycle bin",$left+190, 62, 150, 21)
			GUICtrlSetState($CK_TaskFolderCreation_RecycleBin,$GUI_DISABLE)
			GUICtrlSetState($CK_TaskFolderCreation_RecycleBin,$GUI_UNCHECKED)

			$CK_TaskFolderCreation_Recurse=GUICtrlCreateCheckbox("Recurse [R]",$left+190, 82, 0, 21)
			GUICtrlSetState($CK_TaskFolderCreation_Recurse,_GetAppSettings("Recurse",$GUI_CHECKED))
;~ 			GUICtrlSetBkColor(-1,_color("RED"))
		endif

		if $task="Compression Task" Then   ;00000000000000000000000000000000000000000000000000000000
			GUIStartGroup()

			$RD_TaskFolderCreation_ZIPstructure=GUICtrlCreateRadio("Single ZIP archive (Structure)",$left,60, 175, 17)
			GUICtrlSetState($RD_TaskFolderCreation_ZIPstructure, $GUI_CHECKED)

			$RD_TaskFolderCreation_ZIPsingle = GUICtrlCreateRadio("Single ZIP archive (No Structure)[NS]", $left,80,175,17)
			GUICtrlCreateLabel("    * If ZIP file exist, will be overwriten", $left, 97, 200, 17)
			GUICtrlSetState($RD_TaskFolderCreation_ZIPsingle, $GUI_UNCHECKED)

			GUICtrlCreateLabel("Target ZIP filename.(.zip)", $left+190, 62, 150, 17, $SS_RIGHTJUST)
			$TXT_TaskFolderCreation_TargetZIPfilename = GUICtrlCreateInput("", $left+190, 75, 130, 20)
			$TXT_TaskFolderCreation_TargetZIPfilenameTEMP=""
			GUICtrlCreateLabel("* [date] Actual date", $left+205, 96, 150, 15, $SS_RIGHTJUST)
			GUICtrlCreateLabel("* [server] Server name", $left+205, 110, 150, 15, $SS_RIGHTJUST)

			$RD_TaskFolderCreation_ZIPmultiple=GUICtrlCreateRadio("One ZIP archive per file (No Structure)",$left,120,200,17)
			GUICtrlSetState($RD_TaskFolderCreation_ZIPmultiple, $GUI_UNCHECKED)
;~ 			GUICtrlSetBkColor(-1,_color("RED"))

			_lineaV($left,140,320) ; linea separadora

			$CK_TaskFolderCreation_DeleteZip=GUICtrlCreateCheckbox("Delete After ZIP [D]",$left, 145,110,17)
			GUICtrlSetState($CK_TaskFolderCreation_DeleteZip,$GUI_UNCHECKED)
;~ 			GUICtrlSetBkColor(-1,_color("green"))

			$CK_TaskFolderCreation_AutoRenameZip=GUICtrlCreateCheckbox("AutoRename Zip File if exist (No Structure) [A]",$left, 163,260,17)
			GUICtrlSetState($CK_TaskFolderCreation_AutoRenameZip,$GUI_CHECKED)
;~ 			GUICtrlSetBkColor(-1,_color("RED"))

			$CK_TaskFolderCreation_ServerFolderZip=GUICtrlCreateCheckbox("Create folder per source server - 1 ZIP per source. [S]",$left, 181,260,17)
			GUICtrlSetState($CK_TaskFolderCreation_ServerFolderZip,$GUI_UNCHECKED)
;~ 			GUICtrlSetBkColor(-1,_color("green"))

			$CK_TaskFolderCreation_ServerFolderInsideZip=GUICtrlCreateCheckbox("Create 1 ZIP file with a folder per source. [FS]",$left, 199,260,17)
			GUICtrlSetState($CK_TaskFolderCreation_ServerFolderInsideZip,$GUI_CHECKED)
;~ 			GUICtrlSetBkColor(-1,_color("green"))

		endif
		if $task="Decompression Task" then  ;00000000000000000000000000000000000000000000000000000000
			GUIStartGroup()
			$RD_TaskFolderCreation_ZIPOverwrite = GUICtrlCreateRadio("Overwrite existent files", $left, 61, 150, 17)
			$RD_TaskFolderCreation_ZIPAutorename=GUICtrlCreateRadio("Autorename duplicated files names",$left,77,150,17)
			GUICtrlSetState($RD_TaskFolderCreation_ZIPOverwrite, $GUI_CHECKED)
		endif

		;list and buttons
		if $task="Deletion Task"  Then    ;00000000000000000000000000000000000000000000000000000000
			$tsft=60
			$top=$top+$tsft
			$listHigh=210
		endif
		if $task="Compression Task"  Then    ;00000000000000000000000000000000000000000000000000000000
;~ 			$tshift=90
			$top=$top+$tsft
		endif
		if $task="Folder Creation Task"  Then    ;00000000000000000000000000000000000000000000000000000000
			$tsft=-10
			$top=$top+$tsft
			$listHigh=200
		endif

		$BTN_TaskFolderCreation_AddTargetPath = GUICtrlCreateButton("Add Target Path", $left , $top, 95, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_AddTargetPathClick")
		GUICtrlSetState($BTN_TaskFolderCreation_AddTargetPath,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$BTN_TaskFolderCreation_DeleteTargetPath = GUICtrlCreateButton("Delete selected target", $left + 200, $top, 115, 25)
		GUICtrlSetOnEvent(-1, "BTN_TaskFolderCreation_DeleteTargetPathClick")
		GUICtrlSetState($BTN_TaskFolderCreation_DeleteTargetPath,$GUI_DISABLE)
		GUICtrlSetColor(-1, _color("black"))

		$columnasnames="Target Path"
		if $task="Deletion Task" Then $columnasnames="Target Path|Content Filter"
		if $task="Compression Task" Then $columnasnames="Target Path|ZIP File Name"
		if $task="Decompression Task" Then $columnasnames="Target Path|Name Conflict"
		$LST_TaskFolderCreation_TargetPaths = GUICtrlCreateListView($columnasnames, $left, $top+ 28, 320, $listHigh-$tsft,$__style,0)
		_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
		_GUICtrlListView_SetColumnWidth(-1, 0, 200)
		_GUICtrlListView_SetColumnWidth(-1, 1, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlRegisterListViewSort(-1, "LVSortReport") ; Register the function "SortLV" for the sorting callback

#endregion
#region               #############    examples     ###################
		$tshift=0
		$top=135

		if $task="Deletion Task" Or $task="Compression Task"  Then   ;00000000000000000000000000000000000000000000000000000000
			$tshift=0
			$top=$top+$tshift
		endif
		if $task="Deletion Task"Then   ;00000000000000000000000000000000000000000000000000000000
			$anchoLBL=$ancho1
		endif
		if $task="Compression Task"  Then   ;00000000000000000000000000000000000000000000000000000000
			$anchoLBL=$ancho1-270
			_lineaV($left1-5,$top,$anchoLBL)  ; linea separadora
			$top=$top+5
		endif
		if $task="Folder Creation Task"  Then   ;00000000000000000000000000000000000000000000000000000000
			$anchoLBL=$ancho1-20
			$top=$top-70
			_lineaV($left1-5,$top,$anchoLBL)  ; linea separadora
			$top=$top+5
		endif
		GUICtrlCreateLabel("Examples: c:\MyFolder (Always use Localpath) "& @crlf& _
						   "                 \MyFolder (Folder in Share preceeded by \)" _
						   , $left1 , $top, $anchoLBL, 28, $SS_RIGHTJUST);BitOR($SS_CENTER,$SS_RIGHTJUST)
;~ 		GUICtrlSetBkColor(-1,_color("RED"))
		if $task="Compression Task" Then
			GUICtrlCreateLabel("Filters: Wildcards (Ex. *.* and ?) for files  "& @crlf& _
							   "            * to ZIP only child files/folders" _
							   , $left1 , $top+30, $anchoLBL, 28, $SS_RIGHTJUST)
;~ 			GUICtrlSetBkColor(-1,_color("green"))
		endif
		if $task="Deletion Task" Then
			GUICtrlCreateLabel("Filters:   Wildcards (Ex. *.* and ?) for files" & @crlf& _
							   "            * to delete only child files/folders" _
							   , $left1 , $top+30, $anchoLBL, $texthigh, $SS_RIGHTJUST)
;~ 			GUICtrlSetBkColor(-1,_color("green"))
		endif



#endregion
#region               #############    bottom       ###################
$left=$left+125

		If Not @Compiled Then
			if $bigform Then
				$BTN_exitClick = GUICtrlCreateButton("&Exit", 380, $high-35, 89, 25)
			Else
				$BTN_exitClick = GUICtrlCreateButton("&Exit", 380, $high-35, 89, 25)
			endif
			GUICtrlSetOnEvent($BTN_exitClick, "BTN_exitClick")
			GUICtrlSetColor($BTN_exitClick, _color("red"))
		EndIf

		$BTN_FolderCreation_save = GUICtrlCreateButton("&Save task", $left, $high-35, 89, 25)
			GUICtrlSetOnEvent(-1, "BTN_FolderCreation_saveClick")
			GUICtrlSetColor(-1, _color("black"))

		$BTN_FolderCreation_close = GUICtrlCreateButton("&Close", $left +100, $high-35, 89, 25)
			GUICtrlSetOnEvent(-1, "BTN_FolderCreation_closeClick")
			GUICtrlSetColor(-1, _color("black"))
#endregion
#region credentials
$left=8
$top=8
if $bigform then
	;right pane
	$top=$top+400
	$left=$left+360

		GUICtrlCreateLabel("Description *", $left, $top, 60, 45)
		$TXT_FolderCreation_taskdesc = GUICtrlCreateInput("", $left + 65,  $top, 253, 21)

	; left pane
	$top=$top
	$left=$left+330

		GUICtrlCreateLabel("Source Credentials", $left, $top, 90, 17)
		$CMB_TaskFolderCreation_SourceCred = GUICtrlCreateCombo("", $left+95, $top, 135, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
		GUICtrlSetData(-1, "|domain", "")

		GUICtrlCreateLabel("Target Credentials", $left, $top+20, 90, 17)
		$CMB_TaskFolderCreation_TargetCred = GUICtrlCreateCombo("", $left+95, $top+33, 135, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
		GUICtrlSetData(-1, "|domain", "")

		GUICtrlCreateLabel("When .\Logged User selected, the user login will be used", $left+240, $top-5, 70, 68)

	$top=$top+20
		if $task="Compression Task" then
			$CK_TaskFolderCreation_Powershell=GUICtrlCreateCheckbox("Enable Remoting Powershell at runtime", $left , $top+50, 247, 21)
			GUICtrlSetState($CK_TaskFolderCreation_Powershell,$GUI_DISABLE)
			GUICtrlSetState($CK_TaskFolderCreation_Powershell,$GUI_UNCHECKED)
		endif
else  ; lttle form
	$top=$top+375
	$left2=$left+360

		GUICtrlCreateLabel("Description (optional)", $left2, $top, 57, 35)
		$TXT_FolderCreation_taskdesc = GUICtrlCreateInput("", $left2 + 65,  $top, 247, 21)

		GUICtrlCreateLabel("Target Credentials", $left, $top+30, 90, 17)
		$CMB_TaskFolderCreation_TargetCred = GUICtrlCreateCombo("", $left+95, $top+30, 135, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
;~ 		GUICtrlSetData(-1, "|dir|ds", "")
		GUICtrlCreateLabel("When .\Logged User selected, the user login will be used", $left+240, $top+20, 80, 68)
endif
#endregion
GUISetState(@SW_SHOW)
	#Region llenado de datos iniciales
		_Fill_TaskFolderCreation_Data($task)
		GUICtrlSetState($BTN_FolderCreation_save, $GUI_Disable)
	#EndRegion
	#region contextmenu
		_CreateContextMenu_Lists($TaskFolderCreation,$task)
	#endregion
Else
	TaskFolderCreationClose()
endif
#endregion
EndFunc
