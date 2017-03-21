
Func GUI_JobCreation($posX,$posY)
	ConsoleWrite('+GUI_JobCreation() ='  & @crlf )
	$GUI_JobCreation=1
	$formTitle="Job Creation"  & "                " & @ComputerName & _CheckcomputerMembership()
	$formWidth=850
	$formHigh=397
	$posxis= _PosXaxis($formWidth,$posX)
	#Region ### START Koda GUI section ### JobCreationForm.kxf
		$JobCreationForm = GUICreate($formTitle, $formWidth,$formHigh ,$posxis ,$posY)
		GUISetOnEvent($GUI_EVENT_CLOSE, "JobCreationFormClose")

;~ 			$Grp_JobCreation = GUICtrlCreateGroup("Jobs", 16, 6, 777, 345)

				GUICtrlCreateLabel("Job Name", 24, 22, 57, 17)
				$TXT_JobCreation_jobname = GUICtrlCreateInput("", 90, 19, 310, 21)


				GUICtrlCreateLabel("Description", 24, 45, 57, 17)
				$TXT_JobCreation_jobdescription = GUICtrlCreateInput("", 90, 42, 310, 21)

				GUICtrlCreateLabel("Avalilable Jobs - Click to select a previously created one:", 24, 78, 271,17)

					Local $__style = BitOR($WS_BORDER,$LVS_SHOWSELALWAYS,$LVS_SINGLESEL);$LVS_SINGLESEL  $LVS_REPORT
				$LST_JobCreation_JobList = GUICtrlCreateListView("Job Name|Description|Archive", 24, 102, 270, 240,$__style,0)
					_GUICtrlListView_SetColumnWidth($LST_JobCreation_JobList, 0, 100)
					_GUICtrlListView_SetColumnWidth($LST_JobCreation_JobList, 1, 90)
					_GUICtrlListView_SetColumnWidth($LST_JobCreation_JobList, 2, $LVSCW_AUTOSIZE_USEHEADER)
;~ 					_GUICtrlListView_SetExtendedListViewStyle($LST_JobCreation_JobList, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))
					_GUICtrlListView_SetExtendedListViewStyle($LST_JobCreation_JobList, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_CHECKBOXES,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))

					GUICtrlRegisterListViewSort(-1, "LVSortReport")

$butons1Pos=310
				$BTN_JobCreation_updatejob = GUICtrlCreateButton("Update Description", $butons1Pos-15, 70, 105, 28)
					GUICtrlSetOnEvent(-1, "BTN_JobCreation_updatejobClick")
					GUICtrlSetState(-1,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

				$BTN_JobCreation_duplicatejob = IconButton("  Duplicate",$butons1Pos, 133, 89, 26, 16, $FgmDataFolderImages & "\dna.ico")
					GUICtrlSetOnEvent(-1, "BTN_JobCreation_DuplicatejobClick")
					GUICtrlSetState(-1,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

				$BTN_JobCreation_deletejob = IconButton("    Delete Job",$butons1Pos, 103, 89, 26, 16, $FgmDataFolderImages & "\Cleaner.ICO")
					GUICtrlSetOnEvent(-1, "BTN_JobCreation_deletejobClick")
					GUICtrlSetState(-1,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

				GUICtrlCreateLabel("Deleting a job will delete all associated tasks", $butons1Pos, 163, 99, 50, $SS_RIGHTJUST)

				$BTN_JobCreation_Archivejob = IconButton("      Archive Job",$butons1Pos, 215, 89, 26, 16, $FgmDataFolderImages & "\Padlock.ico")
					GUICtrlSetOnEvent(-1, "BTN_JobCreation_ArchivejobClick")
					GUICtrlSetState($BTN_JobCreation_Archivejob,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

				$CK_JobCreation_Showjob = GUICtrlCreateCheckbox("Show Archived Jobs", $butons1Pos, 271, 100, 35,$BS_MULTILINE)
					GUICtrlSetState($CK_JobCreation_Showjob,$GUI_unCHECKED)
					GUICtrlSetColor(-1, _color("black"))

				$BTN_JobCreation_runjob = IconButton("    Run Job",$butons1Pos, 315, 89, 26, 16, $FgmDataFolderImages & "\SNAIL.ICO")
					GUICtrlSetOnEvent(-1, "BTN_JobCreation_runjobClick")
					GUICtrlSetState($BTN_JobCreation_runjob,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))
				;----------------------------------------------------------------------------------------------------------
$leftBTN=750
$leftBllock=425
$bottonWidth=90
				GUICtrlCreateLabel("Select the type of task to be added:", $leftBllock, 16, 173, 17)

				$CMB_jobcreation_selecttask = GUICtrlCreateCombo("", $leftBllock, 37, 161, 25,BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL,$CBS_SORT))
				GUICtrlSetData(-1, " |Folder Creation Task|Compression Task|Deletion Task|Copy Task|Execution Task", "")
				GUICtrlSetColor(-1, _color("black"))
				GUICtrlSetBkColor(-1, _color("white"))
				GUICtrlSetState(-1,$GUI_DISABLE)


;~ 				$BTN_jobcreation_addtask = GUICtrlCreateButton("Add task", $leftBTN, 30, $bottonWidth, 25)
				$BTN_jobcreation_addtask = IconButton("    Add Task",$leftBTN, 30, $bottonWidth, 26, 16, $FgmDataFolderImages & "\ToolBox.ico")
					GUICtrlSetOnEvent(-1, "BTN_jobcreation_addtaskClick")
					GUICtrlSetState($BTN_jobcreation_addtask,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))


				$LBL_jobcreation_tasklist = GUICtrlCreateLabel("Tasks associated to job", $leftBllock, 79, 300, 17)

					Local $__style = BitOR($WS_BORDER,$LVS_SHOWSELALWAYS,$LVS_REPORT) ;$LVS_SINGLESEL  $LVS_REPORT
				$LST_jobcreation_tasklist = GUICtrlCreateListView("Task type|Task Description|TaskUID", $leftBllock, 102, 305, 240,$__style,0)
					_GUICtrlListView_SetColumnWidth($LST_jobcreation_tasklist, 0, 130)
					_GUICtrlListView_SetColumnWidth($LST_jobcreation_tasklist, 1, 133)
					_GUICtrlListView_SetColumnWidth($LST_jobcreation_tasklist, 2, 1)
					_GUICtrlListView_SetExtendedListViewStyle($LST_jobcreation_tasklist, BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_CHECKBOXES,$LVS_EX_ONECLICKACTIVATE,$LVS_EX_GRIDLINES))

;~ 				$BTN_createjob_Edittask = GUICtrlCreateButton("    Edit Task", $leftBTN, 102, $bottonWidth, 26)
				$BTN_createjob_Edittask = IconButton("    Edit Task",$leftBTN, 102, $bottonWidth, 26, 16, $FgmDataFolderImages & "\Crayons.ico")
					GUICtrlSetOnEvent(-1, "BTN_JobCreation_EdittaskClick")
					GUICtrlSetState($BTN_createjob_Edittask,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

				$BTN_createjob_deletetask = IconButton("    Delete Task",$leftBTN, 140, $bottonWidth, 26, 16, $FgmDataFolderImages & "\delete_16.ico")
					GUICtrlSetOnEvent(-1, "BTN_JobCreation_deletetaskClick")
					GUICtrlSetState($BTN_createjob_deletetask,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

				$BTN_createjob_taskUp = IconButton("    Move Up",$leftBTN, 180, $bottonWidth, 26, 16, $FgmDataFolderImages & "\uparrow.ico")
					GUICtrlSetOnEvent(-1, "BTN_JobCreation_taskUpClick")
					GUICtrlSetState($BTN_createjob_taskUp,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

				$BTN_createjob_taskDown = IconButton("    Move Down",$leftBTN,  210, $bottonWidth, 26, 16, $FgmDataFolderImages & "\downarrow.ico")
					GUICtrlSetOnEvent(-1, "BTN_JobCreation_taskDownClick")
					GUICtrlSetState($BTN_createjob_taskDown,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

				$BTN_createjob_DuplicateTask = IconButton("     Duplicate ",$leftBTN,  250, $bottonWidth, 26, 16, $FgmDataFolderImages & "\copy.ico")
					GUICtrlSetOnEvent(-1, "BTN_JobCreation_DuplicateTaskClick")
					GUICtrlSetState($BTN_createjob_DuplicateTask,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

				$BTN_createjob_DescribeTask = IconButton("     Describe ",$leftBTN,  290, $bottonWidth, 26, 16, $FgmDataFolderImages & "\eye.ico")
					GUICtrlSetOnEvent(-1, "BTN_JobCreation_DescribeTaskClick")
					GUICtrlSetState($BTN_createjob_DescribeTask,$GUI_DISABLE)
					GUICtrlSetColor(-1, _color("black"))

;~ 			GUICtrlCreateGroup("", -99, -99, 1, 1)

		If Not @Compiled Then
			$BTN_exitClick = GUICtrlCreateButton("&Exit", 599, 360, 89, 25)
			GUICtrlSetOnEvent($BTN_exitClick, "BTN_exitClick")
			GUICtrlSetColor($BTN_exitClick, _color("red"))
		EndIf

;~ 		$BTN_jobcreation_close = GUICtrlCreateButton("&Close", 704, 360, 89, 25)
		$BTN_jobcreation_close = IconButton("&Close",704, 360, $bottonWidth, 25, 16, $FgmDataFolderImages & "\Door2.ico")
			GUICtrlSetOnEvent(-1, "BTN_jobcreation_closeClick")
			GUICtrlSetColor(-1, _color("black"))


		GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###
	#Region llenado de datos iniciales
		_FilljobcreationFormData()
	#EndRegion
	#region contextmenu
		_CreateContextMenu_Lists($JobCreationForm,"Jobs")
	#endregion
EndFunc



