#region  ================================= forms============================================================================================================
	func ApplicationClose($formHandle=0)
		ConsoleWrite('++ApplicationClose() = '&  BitAND(WinGetState( $mainformname & $version),0010)  &@crlf )
		Select
			Case  $formHandle=$FormAbout
				FormAboutClose()
			Case  BitAND(WinGetState( $mainformname & $version),0010) <>0
				_SQLite_Close()
				_SQLite_Shutdown()
				exit
			Case  $formHandle=$MainfORM
				_SQLite_Close()
				_SQLite_Shutdown()
				exit
			Case  $formHandle=$JobConsoleForm
				$hotKeyKill=1
				JobConsole_FormClose()
			Case  $formHandle=$SettingsForm
				_CheckSetProxy_InetRead()
				FormSettingsClose()
				_checkRepo()
			Case  $formHandle=$JobCreationForm
				JobCreationFormClose()
				_checkRepo()
			Case  $formHandle=$TaskFolderCreation
				TaskFolderCreationClose()
			Case  $formHandle=$TaskExecutionForm
				TaskExecutionClose()
			Case  $formHandle=$TaskDeployAgentForm
				TaskDeployAgentClose()
			Case  $TasKCopyCreation
				TaskCopyCreationClose()
			Case  $formHandle=$GUI_inputbox2
				JobConsole_inputbox2Close()
			Case  $formHandle=$FormJobImport
				FormJobImportClose()
			Case  $formHandle=$FormExportImportServers
				FormExportImportServersClose()
			Case  $formHandle=$ConsoleDescribeForm
				ConsoleDescribe_FormClose()
			Case  $formHandle=$ResetServers2TemplateForm
				ResetServers2Template_FormClose()
			Case Else
				ConsoleWrite('!!!!!!!!!!!!!!!!!  not handeled !!!!!!!!!!!!!!!!!!!'& @crlf & $formHandle& @crlf& $ResetServers2TemplateForm )
		endselect
	EndFunc
	Func _CreateContextMenu_Lists($formH,$task)
		ConsoleWrite('++_CreateContextMenu_Lists() = '   & $task & @crlf )
		$contextmenu_list = GUICtrlCreateContextMenu()
		$contextSubmenu_list_delete = GUICtrlCreateMenuItem("Delete", $contextmenu_list)
		SetOnEventA($contextSubmenu_list_delete,"contextSubmenu_list_delete",$paramByVal,$formH,$paramByVal,$task)
		if $task="Jobs" Then
			$contextSubmenu_list_Duplicate = GUICtrlCreateMenuItem("Duplicate", $contextmenu_list)
			SetOnEventA($contextSubmenu_list_Duplicate,"contextSubmenu_list_Duplicate",$paramByVal,$formH,$paramByVal,$task)
		endif
	EndFunc
	Func contextSubmenu_list_delete($lformH=0,$ltask="")
		ConsoleWrite('++contextSubmenu_list_delete() = '   & @crlf )
		$fcs=_WinAPI_GetFocus()
		Select
			;task execution
			Case  $fcs=GUICtrlGetHandle($LST_TaskExecution_extraFiles)
				contextSubmenu_TaskExecution_delete()
			Case  $fcs=GUICtrlGetHandle($LST_TaskExecution_TargetLoc)
				contextSubmenu_TaskExecution_delete()

			;folder creation task
			Case  $fcs=GUICtrlGetHandle($LST_TaskFolderCreation_TargetLoc) and $lformH = $TaskFolderCreation and $ltask="Folder Creation Task"
				contextSubmenu_TaskFolderCreation_delete()
			Case  $fcs=GUICtrlGetHandle($LST_TaskFolderCreation_TargetPaths) and $lformH = $TaskFolderCreation and $ltask="Folder Creation Task"
				BTN_TaskFolderCreation_DeleteTargetPathClick()

			;deletion  task
			Case  $fcs=GUICtrlGetHandle($LST_TaskFolderCreation_TargetPaths ) and $lformH = $TaskFolderCreation and $ltask="Deletion Task"
				BTN_TaskFolderCreation_DeleteTargetPathClick()
			Case  $fcs=GUICtrlGetHandle($LST_TaskFolderCreation_TargetLoc)  and $lformH = $TaskFolderCreation and $ltask="Deletion Task"
				BTN_TaskFolderCreation_DeleteTargetLoc()

			;copy task
			Case  $fcs=GUICtrlGetHandle($LST_TaskFolderCreation_SourceLoc) and $lformH = $TasKCopyCreation and $ltask="Copy Task"
				BTN_TaskFolderCreation_DeleteSourceLoc()
			Case  $fcs=GUICtrlGetHandle($LST_TaskFolderCreation_TargetLoc) and $lformH = $TasKCopyCreation and $ltask="Copy Task"
				BTN_TaskFolderCreation_DeleteTargetLoc()
			Case  $fcs=GUICtrlGetHandle($LST_TaskFolderCreation_SourcePaths) and $lformH = $TasKCopyCreation and $ltask="Copy Task"
				BTN_TaskFolderCreation_DeleteSourcePathClick()
			Case  $fcs=GUICtrlGetHandle($LST_TaskFolderCreation_TargetPaths) and $lformH = $TasKCopyCreation and $ltask="Copy Task"
				BTN_TaskFolderCreation_DeleteTargetPathClick()

			;compression task
			Case  $fcs=GUICtrlGetHandle($LST_TaskFolderCreation_SourceLoc) and $lformH = $TaskFolderCreation and $ltask="Compression Task"
				BTN_TaskFolderCreation_DeleteSourceLoc()
			Case  $fcs=GUICtrlGetHandle($LST_TaskFolderCreation_TargetLoc) and $lformH = $TaskFolderCreation and $ltask="Compression Task"
				BTN_TaskFolderCreation_DeleteTargetLoc()
			Case  $fcs=GUICtrlGetHandle($LST_TaskFolderCreation_SourcePaths) and $lformH = $TaskFolderCreation and $ltask="Compression Task"
				BTN_TaskFolderCreation_DeleteSourcePathClick()
			Case  $fcs=GUICtrlGetHandle($LST_TaskFolderCreation_TargetPaths) and $lformH = $TaskFolderCreation and $ltask="Compression Task"
				BTN_TaskFolderCreation_DeleteTargetPathClick()

			;settings - server crud
			Case  $fcs=GUICtrlGetHandle($LST_settings_serversAdd) and $lformH=$SettingsForm
				BTN_Settings_ServerRemoveClick()
			Case  $fcs=GUICtrlGetHandle($LST_CredManage) and $lformH=$SettingsForm
				BTN_CredDeleteClick()
			Case  $fcs=GUICtrlGetHandle($LST_custsrvgrp) and $lformH=$SettingsForm
				Btn_custListDeleteSrvClick()
			Case  $fcs=GUICtrlGetHandle($LST_custshare) and $lformH=$SettingsForm
				Btn_custDeleteShareClick()

			;job form
			Case  $fcs=GUICtrlGetHandle($LST_JobCreation_JobList) and $lformH=$JobCreationForm
				BTN_JobCreation_deletejobClick()
			Case  $fcs=GUICtrlGetHandle($LST_jobcreation_tasklist) and $lformH=$JobCreationForm
				BTN_JobCreation_deletetaskClick()

			;Case else not handeled
			case else
				ConsoleWrite("!!!!!!!++contextSubmenu_list_delete  NOT HANDELED"  & @LF)
		endselect
	EndFunc
	Func contextSubmenu_list_Duplicate($lformH=0,$ltask="")
		ConsoleWrite('++contextSubmenu_list_Duplicate() = '   & @crlf )
		$fcs=_WinAPI_GetFocus()
		Select
			;job form
			Case  $fcs=GUICtrlGetHandle($LST_JobCreation_JobList) and $lformH=$JobCreationForm
				BTN_JobCreation_DuplicatejobClick()
			Case  $fcs=GUICtrlGetHandle($LST_jobcreation_tasklist) and $lformH=$JobCreationForm
				BTN_JobCreation_DuplicateTaskClick()

			;Case else not handeled
			case else
				ConsoleWrite("!!!!!!!++contextSubmenu_list_delete  NOT HANDELED"  & @LF)
		endselect
	EndFunc
	#region  ================================= main form                      =====================================================================
		Func MainClose()
			ConsoleWrite('++MainClose() = '& @crlf)
			$formHandle=WinGetHandle("[Active]")
			ApplicationClose($formHandle)
		EndFunc
		func ShowSettingsForm($iTabIndex)
			ConsoleWrite('++ShowSettingsForm() = tab idx = '& $iTabIndex& @crlf )
			If _Singleton($SettingsForm, 1) = 0 Then
				ConsoleWrite('!++ShowSettingsForm() = _Singleton'& @crlf )
			Else
				If Not @Compiled Then $version= FileGetVersion(@ScriptName)
				$arr_formPos=WinGetPos ($mainformname & $version)
				GUISetCursor(15, 1)
				GUI_Settings($arr_formPos[0]+($arr_formPos[3]/2)+$factorx,$arr_formPos[1])
				GUISetState(@SW_HIDE, $MainfORM)
				GUISetCursor(-1, 1)
;~ 				_GUICtrlTab_SetCurSel($PageControl1, $iTabIndex)
				_GUICtrlTab_SetCurFocus($PageControl1, $iTabIndex)
			endif
		endfunc
		func ShowJobCreationForm()
			ConsoleWrite('++ShowJobCreationForm() = '& @crlf )
			If $GUI_JobCreation=1 Then
;~ 				$formTitle="Job Creation"  & "                " & @ComputerName & _CheckcomputerMembership()
			else
				GUISetState(@SW_HIDE, $MainfORM)
				If Not @Compiled Then $version= FileGetVersion(@ScriptName)
				$arr_formPos=WinGetPos ($mainformname & $version)
				GUI_JobCreation($arr_formPos[0]+($arr_formPos[3]/2)+$factorx,$arr_formPos[1])
			endif
		EndFunc
		Func ShowAboutForm()
			ConsoleWrite('++ShowAboutForm() = '& @crlf)
			If $Gui_FormAbout=1 Then
				ConsoleWrite('!++ShowAboutForm() = _Singleton'& @crlf )
			Else
				GUICtrlSetState($B_Close,$GUI_DISABLE)
				Gui_FormAbout()
			endif
		EndFunc
		Func SetDatabase()
			ConsoleWrite('++SetDatabase() = '& @crlf)
			If _AreYouSureYesNo("Do you want to set the project database to "&_CTRLread($CMB_DatabaseSelect)&"?") Then
				_LoadTimerPrint("Start Database update")
				Global $splashH = _ProgressGUI("     FileGodMode" & @CRLF & "          " & _
					FileGetVersion(@ScriptName),0,16,"","","","0x2C3539","0x0FFFC19")
				_loadDatabase(_CTRLread($CMB_DatabaseSelect))
				_ConfigDBInitial(1)  ; Force project data update
				Sleep(2000)
				_ReduceMemory()
				_FillDatabaseListbox()
				GUIDelete($splashH[0])
				_MainFormBTNdisable(1)
				GUICtrlSetstate($LBL_setdb,$GUI_hide)
				_LoadTimerPrint("End Database update")
			endif
		EndFunc
	#endregion
	#region ********************************** FORM CREATEJOB                 *********************************************************************
;~ 		Func TXT_JobCreation_jobnameChange()
;~ 			ConsoleWrite('++TXT_JobCreation_jobnameChange() = '& @crlf )
;~ 		EndFunc
		Func BTN_JobCreation_deletejobClick()
			ConsoleWrite('++BTN_JobCreation_deletejobClick() = '& @crlf )
			$lineValues=_GUICtrlListView_GetItemTextArray($LST_JobCreation_JobList)
			If _AreYouSureYesNo("Do you want to delete the selected Job?" & @CRLF & "Job: "& $lineValues[1]& @CRLF & "Desc: "& $lineValues[2]& @CRLF &"All Job's tasks will be deleted.") Then
				_JobCreationDeleteJob()
				_FillJobList()
				_FillTaskJobList()
			endif
		EndFunc
		Func BTN_jobcreation_addtaskClick($edit=0)
			ConsoleWrite('++BTN_jobcreation_addtaskClick() = '& @crlf )
			_CheckJobId()
			$arr_formPos=WinGetPos ("[active]")
			Global $Task=GUICtrlRead($CMB_jobcreation_selecttask)
			switch $task
				case "Folder Creation Task","Deletion Task","Compression Task","Decompression Task"
					ConsoleWrite('Folder Creation Task,"Deletion Task","Compression Task"'& @crlf )
					GUI_FolderCreation($arr_formPos[0],$arr_formPos[1],$arr_formPos[2],_CTRLread($CMB_jobcreation_selecttask),$edit)
					GUISetState(@SW_HIDE, $JobCreationForm)
				case "Execution Task"
					ConsoleWrite('Execution Task'& @crlf )
					GUI_ExecuteTask($arr_formPos[0],$arr_formPos[1],$arr_formPos[2],_CTRLread($CMB_jobcreation_selecttask),$edit)
					GUISetState(@SW_HIDE, $JobCreationForm)
				case "Copy Task"
					ConsoleWrite('"Copy Task"'& @crlf )
					GUI_CopyTask($arr_formPos[0],$arr_formPos[1],$arr_formPos[2],_CTRLread($CMB_jobcreation_selecttask),$edit)
					GUISetState(@SW_HIDE, $JobCreationForm)
				case "Deploy Agent Task"
					ConsoleWrite('Deploy Agent Task'& @crlf )
					GUI_DeployAgentTask($arr_formPos[0],$arr_formPos[1],$arr_formPos[2],_CTRLread($CMB_jobcreation_selecttask),$edit)
					GUISetState(@SW_HIDE, $JobCreationForm)
				Case Else
;~ 					Box(4096,"caca","no existe form",0)
					ConsoleWrite('++_CheckCRTLRegex() = caca no existe form' & @crlf)
			EndSwitch
			$taskFormActivity=0
		EndFunc
		Func BTN_JobCreation_deletetaskClick()
			ConsoleWrite('++BTN_JobCreation_deletetaskClick() = '& @crlf )
			$taskID=0
			If _AreYouSureYesNo("Do you want to delete the selected task?") Then
				_JobCreationDeleteTask()
				_FillTaskJobList()
			endif
		EndFunc
		Func BTN_jobcreation_closeClick()
			ConsoleWrite('++BTN_jobcreation_closeClick() = '& @crlf )
			JobCreationFormClose()
		EndFunc
		Func BTN_JobCreation_updatejobClick()
			ConsoleWrite('++BTN_JobCreation_updatejobClick() = '& @crlf )
			_UpdateJobDescription()
			_FillJobList()
			_FillTaskJobList()
			_updateJobDescriptionBTN()
		EndFunc
		Func BTN_JobCreation_EdittaskClick()
			ConsoleWrite('++BTN_JobCreation_EdittaskClick() = '& @crlf )
			$lineValues=_GUICtrlListView_GetItemTextArray($LST_jobcreation_tasklist)
			$taskID=$lineValues[3]
			BTN_jobcreation_addtaskClick(1)
		EndFunc
		Func BTN_JobCreation_RunjobClick()
			ConsoleWrite('++BTN_JobCreation_RunjobClick() = '& @crlf )
			$arr_formPos=WinGetPos ("[active]")
			If $JobConsoleForm>0 Then
				BTN_JobConsole_clearConsole()
				GUIRegisterMsg($WM_SIZE, "WM_SIZE")
				GUISetState(@SW_show,$JobConsoleForm)
				WinSetTitle($JobConsoleForm,"",_CTRLread($TXT_JobCreation_jobname))
			else
				GUI_console($arr_formPos[0],$arr_formPos[1],$arr_formPos[2],_CTRLread($TXT_JobCreation_jobname))
			endif
			GUICtrlSetState($BTN_JobCreation_runjob,$GUI_DISABLE)
			_runJob("show",$Edt_JobConsole)
		EndFunc
		Func BTN_JobCreation_taskUpClick()
			ConsoleWrite('++BTN_JobCreation_taskUpClick() = '& @crlf )
			$selectedIndex=_TaskUpDown(-1)
			_FillTaskJobList($selectedIndex-1)
		EndFunc
		Func BTN_JobCreation_taskDownClick()
			ConsoleWrite('++BTN_JobCreation_taskDownClick() = '& @crlf )
			$selectedIndex=_TaskUpDown(1)
			_FillTaskJobList($selectedIndex-1)
		EndFunc
		Func BTN_JobCreation_DuplicatejobClick()
			ConsoleWrite('++BTN_JobCreation_DuplicatejobClick() = '& @crlf )
			$jobIDorig=$jobID
			$arr_formPos=WinGetPos ("[active]")
			Local $answer = _inputbox2("Duplicate Job", "New Job name","New Description",$arr_formPos[0],$arr_formPos[1],$arr_formPos[2])
			GUIDelete($GUI_inputbox2)
			If IsArray($answer) Then
				If $answer[0]<>"" Then
					If _NoexistInList($LST_JobCreation_JobList,$answer[0],0) Then
						GUICtrlSetData($TXT_JobCreation_jobname,$answer[0])
						GUICtrlSetData($TXT_JobCreation_jobdescription,$answer[1])
						If _JobDuplicate($jobIDorig) Then
							If _TaskCreation_registerJOB() then
								MsgBox(64+4096,"Job Duplication","The Job was duplicated succesfully",0,0)
							Endif
						EndIf
					Else
						MsgBox(48+4096,"Job Duplication","The Job already exist. Cannot be duplicated.",0,0)
					endif
				endif
			endif
			$taskID=0
			_FillJobList()
			_FillTaskJobList()
			_JobCreation_disableGral()
		EndFunc
		Func BTN_JobCreation_ArchivejobClick()
			ConsoleWrite('++BTN_JobCreation_ArchivejobClick() = '& @crlf)
			If _CTRLread($BTN_JobCreation_Archivejob)="Archive Job" Then
				_JobCreation_Archive(1)
			else
				_JobCreation_Archive(0)
			endif
			_FillJobList()
			_FillTaskJobList()
			_JobCreation_disableGral()
		EndFunc
		Func BTN_JobCreation_DuplicateTaskClick()
			ConsoleWrite('++BTN_JobCreation_DuplicateTaskClick() = '& @crlf)
			If _AreYouSureYesNo("Are you sure , you want to Duplicte the task? ") Then
				If _GUICtrlListView_GetSelectedCount($LST_jobcreation_tasklist)=1 Then
					$lineValues=_GUICtrlListView_GetItemTextArray($LST_jobcreation_tasklist)
					If _TaskDuplicate($lineValues[3] ) Then
						MsgBox(64+4096,"Task Duplication","The Task was duplicated succesfully",0,0)
					EndIf
					$taskID=0
					_FillJobList()
					_FillTaskJobList()
					_JobCreation_disableGral()
				endif
			endif
		EndFunc
		Func BTN_JobCreation_DescribeTaskClick()
			ConsoleWrite('++BTN_JobCreation_DescribeTaskClick() = '& @crlf)
;~ 			If _GUICtrlListView_GetSelectedCount($LST_jobcreation_tasklist)=1 Then
				$lineValues=_GUICtrlListView_GetItemTextArray($LST_jobcreation_tasklist)
				_printFromArray($lineValues)
				$arr_formPos=WinGetPos ("[active]")
				GUICtrlSetState($BTN_JobCreation_runjob,$GUI_DISABLE)
				GUICtrlSetState($BTN_createjob_DescribeTask,$GUI_DISABLE)
;~ 				GUICtrlSetState($BTN_exitClick,$GUI_DISABLE)
				$descabbrev=_CTRLread($TXT_JobCreation_jobname)& "    " & $lineValues[1] & "  <=>  " & $lineValues[2]
				If StringLen($descabbrev)>60 Then  $descabbrev=StringMid($descabbrev,1,60)& "..."
				GUI_ConsoleDescribe($arr_formPos[0],$arr_formPos[1],$arr_formPos[2], $descabbrev)
				_RunJob("Describe",$Edt_ConsoleDescribe)
;~ 				If _TaskDescribe($lineValues[3] ) Then
;~ 					MsgBox(64+4096,"Task Duplication","The Task was duplicated succesfully",0,0)
;~ 				EndIf
				$taskID=0
				_FillJobList()
				_FillTaskJobList()
				_JobCreation_disableGral()
;~ 			endif
		EndFunc
	#endregion
	#region ********************************** FORM Describe Console               *********************************************************************
		Func BTN_ConsoleDescribe_OpenCSV()
			ConsoleWrite('++BTN_ConsoleDescribe_OpenCSV() = '& @crlf)
			Run(@comspec & ' /c start ' & $FGMtaskReport,"",@SW_HIDE)
;~ 			Global $oExcel = _Excel_Open()
;~ 			Global $oWorkbook = _Excel_BookOpen($oExcel, $FGMtaskReport)
		EndFunc
	#endregion
	#region ********************************** FORM Job Console               *********************************************************************
		Func BTN_JobConsole_Testjob()
			ConsoleWrite('++BTN_JobConsole_Testjob() = '& @crlf )
			$HotKeyPause=0
			$hotKeyKill=0
			GUICtrlSetData($LBL_RUNalert,"  Running Job  ")
			GUICtrlSetstate($LBL_RUNalert,$GUI_show)
			_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Testing Job", 0)
			_runJob("Test",$Edt_JobConsole)
			_StatusbarReset()
			GUICtrlSetstate($LBL_RUNalert,$GUI_hide)
		EndFunc
		Func BTN_JobConsole_Runjob()
			ConsoleWrite('++BTN_JobConsole_Runjob() = '& @crlf )
			If _AreYouSureYesNo("Are you sure , you want to run the job? "&@crlf&"Did you run the job tests?") Then
				GUICtrlSetData($LBL_RUNalert,"  Running Job  ")
				$HotKeyPause=0
				$hotKeyKill=0
				GUICtrlSetstate($LBL_RUNalert,$GUI_show)
				_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Running Job", 0)
				_runJob("Run",$Edt_JobConsole)
				_StatusbarReset()
				GUICtrlSetstate($LBL_RUNalert,$GUI_hide)
			endif
		EndFunc
		Func BTN_JobConsole_clearConsole()
			GUICtrlSetData($LBL_RUNalert,"  Running Job  ")
			_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Ready", 0)
			$HotKeyPause=0
			$hotKeyKill=0
			GUICtrlSetstate($LBL_RUNalert,$GUI_hide)
			_ClearConsole($iMemo)
		EndFunc
		Func _StatusbarReset()
			ConsoleWrite('++_StatusbarReset() = '& @crlf)
			_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Ready", 0)
			_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"", 1)
			_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"", 2)
		EndFunc
	#endregion
	#region ********************************** FORM Copy task                 *********************************************************************
		Func BTN_TaskCopy_closeClick()
			ConsoleWrite('++BTN_TaskCopy_closeClick() = '& @crlf )
			TaskCopyCreationClose()
		EndFunc
	#endregion
	#region ********************************** FORM Deploy agent task         *********************************************************************
		Func BTN_TaskDeployAgent_closeClick()
			ConsoleWrite('++BTN_TaskDeployAgent_closeClick() = '& @crlf )
			TaskDeployAgentClose()
		EndFunc
		Func BTN_TaskDeployAgent_AddToTargetLocClick()
			ConsoleWrite('++BTN_TaskDeployAgent_AddToTargetLocClick() = '& @crlf)
			GUICtrlSetState($BTN_TaskDeployAgent_AddToTargetLoc,$GUI_DISABLE)
			_TaskDeployAgent_FillLocList($LST_TaskDeployAgent_TargetLoc)
			GUICtrlSetState($BTN_TaskDeployAgent_AddToTargetLoc,$GUI_ENABLE)
			$taskFormActivity=1
			_TaskDeployAgent_SaveBTN()
		EndFunc
		Func BTN_TaskDeployAgent_DeleteTargetLoc()
			ConsoleWrite('++BTN_TaskDeployAgent_DeleteTargetLoc() = '& @crlf)
			_GUICtrlListView_DeleteItemsSelected(GUICtrlGetHandle($LST_TaskDeployAgent_TargetLoc))
			GUICtrlSetState($BTN_TaskDeployAgent_DeleteTargetLoc,$GUI_DISABLE)
			$taskFormActivity=1
			_TaskDeployAgent_SaveBTN()
			GUICtrlSetData($LBL_TargetLoc,"Cant:"&_GUICtrlListView_GetItemCount($LST_TaskDeployAgent_TargetLoc)  )
		EndFunc
		Func BTN_TaskDeployAgent_saveClick()
			$sTitle = _CTRLread($CMB_jobcreation_selecttask)
			ConsoleWrite('++BTN_TaskDeployAgent_saveClick() = '& $sTitle & @crlf )
			Dim $r[5]
			$taskorder=_GetNextTaskOrder()
			$TaskActive=_CheckTaskActive($taskNumber)
			_LST_TaskCreationDeleteTaskUID()  ; delete all from task before creation

			$r[1]=_LST_TaskCreation_LocStore($sTitle,"TargetLoc",$LST_TaskDeployAgent_TargetLoc,$CMB_TaskDeployAgent_TargetCred,$TXT_TaskDeployAgent_taskdesc,$TaskActive)
			$r[2]=_DeployAgentData_Store($sTitle,_IsCheckedType($RD_TaskDeployAgent_install) ,$TaskActive)
			If $r[1] And $r[2] Then
				MsgBox(64+4096,"Saving Task data","The Task data was stored",0,0)
				$taskFormActivity=0
			ENDIF
			_TaskCreation_registerJOB()
		EndFunc
	#endregion
	#region ********************************** FORM Execution task            *********************************************************************
		Func BTN_TaskExecution_closeClick()
			ConsoleWrite('++BTN_TaskExecution_closeClick() = '& @crlf )
			TaskExecutionClose()
			ControlFocus($JobCreationForm, "", $LST_JobCreation_JobList)
		EndFunc
		Func BTN_TaskExecution_BrowseFileClick()
			ConsoleWrite('++BTN_TaskExecution_BrowseFileClick() = '& @crlf)
			GUICtrlSetstate($BTN_TaskExecution_BrowseFile,$GUI_DISABLE)
			GUICtrlSetstate($BTN_TaskExecution_close,$GUI_DISABLE)
			_selectExecuteFile()
			GUICtrlSetstate($BTN_TaskExecution_BrowseFile,$GUI_ENABLE)
			GUICtrlSetstate($BTN_TaskExecution_close,$GUI_ENABLE)
			_TaskExecution_SaveBTN()
		EndFunc
		Func BTN_TaskExecution_BrowseScriptClick()
			ConsoleWrite('++BTN_TaskExecution_BrowseScriptClick() = '& @crlf)
			GUICtrlSetstate($BTN_TaskExecution_scriptfile_BrowseFile,$GUI_DISABLE)
			GUICtrlSetstate($BTN_TaskExecution_close,$GUI_DISABLE)
			_selectExecuteScript()
			GUICtrlSetstate($BTN_TaskExecution_scriptfile_BrowseFile,$GUI_ENABLE)
			GUICtrlSetstate($BTN_TaskExecution_close,$GUI_ENABLE)
			_TaskExecution_SaveBTN()
		EndFunc
		Func BTN_TaskExecution_addFileClick()
			ConsoleWrite('++BTN_TaskExecution_addFileClick() = '& @crlf)
			GUICtrlSetstate($BTN_TaskExecution_BrowseFile,$GUI_DISABLE)
			GUICtrlSetstate($BTN_TaskExecution_close,$GUI_DISABLE)
			If _NOexistInList($LST_TaskExecution_extraFiles,_ctrlread($TXT_TaskExecution_ExtraFile),0) Then
				_GUICtrlListView_AddItem($LST_TaskExecution_extraFiles,_ctrlread($TXT_TaskExecution_ExtraFile))
			endif
			GUICtrlSetstate($BTN_TaskExecution_BrowseFile,$GUI_ENABLE)
			GUICtrlSetstate($BTN_TaskExecution_close,$GUI_ENABLE)
			GUICtrlSetData($TXT_TaskExecution_ExtraFile,"")
			_TaskExecution_SaveBTN()
		EndFunc
		Func BTN_TaskExecution_AddToTargetLocClick()
			ConsoleWrite('++BTN_TaskExecution_AddToTargetLocClick() = ' & @crlf )
			GUICtrlSetState($BTN_TaskExecution_AddToTargetLoc,$GUI_DISABLE)
			GUISetCursor(15, 1,$TaskExecutionForm)
			_TaskExecution_FillLocList($LST_TaskExecution_TargetLoc)
			GUICtrlSetState($BTN_TaskExecution_AddToTargetLoc,$GUI_ENABLE)
			$taskFormActivity=1
			_TaskExecution_SaveBTN()
			GUISetCursor(-1, 1,$TaskExecutionForm)
		EndFunc
		Func BTN_TaskExecution_DeleteTargetLoc()
			ConsoleWrite('++BTN_TaskExecution_DeleteTargetLoc() = ' & @crlf )
			_GUICtrlListView_DeleteItemsSelected(GUICtrlGetHandle($LST_TaskExecution_TargetLoc))
			GUICtrlSetState($BTN_TaskExecution_DeleteTargetLoc,$GUI_DISABLE)
			$taskFormActivity=1
			_TaskExecution_SaveBTN()
			GUICtrlSetData($LBL_TargetLoc,"Cant:"&_GUICtrlListView_GetItemCount($LST_TaskFolderCreation_TargetLoc)  )
		EndFunc
		Func BTN_TaskExecution_saveClick()
			$sTitle = _CTRLread($CMB_jobcreation_selecttask)
			ConsoleWrite('++BTN_TaskExecution_saveClick() = '& $sTitle & @crlf )
			if _CTRLread($TXT_TaskExecution_scriptfile)<>"" or _CTRLread($CMB_TaskExecution_mode)<>"" then
				Dim $r[5]
				$taskorder=_GetNextTaskOrder()
				$TaskActive=_CheckTaskActive($taskNumber)
				_LST_TaskCreationDeleteTaskUID()  ; delete all from task before creation

				$r[1]=_LST_TaskCreation_LocStore($sTitle,"TargetLoc",$LST_TaskExecution_TargetLoc,$CMB_TaskExecution_TargetCred,$TXT_TaskExecution_taskdesc,$TaskActive)
				$extrafilesArr= _GUICtrlListView_CreateArray_fromColumn($LST_TaskExecution_extraFiles,0)
				$extrafiles=_ArrayToString($extrafilesArr)
				if StringInStr(_CTRLread($CMB_TaskExecution_mode),"Execution commands")>0 then
					$scriptdata=_CTRLread($EDT_TaskExecution_commands)
				Else
					$scriptdata="SCRIPT"&_CTRLread($TXT_TaskExecution_scriptfile)
				endif
				$r[2]=_ExecutionData_Store($sTitle,$scriptdata,_CTRLread($TXT_TaskExecution_TargetPath),$extrafiles,$TaskActive)
				If $r[1] And $r[2] Then
					MsgBox(64+4096,"Saving Task data","The Task data was stored",0,0)
					$taskFormActivity=0
				ENDIF
				_TaskCreation_registerJOB()
			endif
		EndFunc
		Func contextSubmenu_TaskExecution_delete()
			$fcs=_WinAPI_GetFocus()
			if $fcs=GUICtrlGetHandle($LST_TaskExecution_extraFiles) then
				if _GUICtrlListView_GetSelectedCount($LST_TaskExecution_extraFiles) >0 then
					_GUICtrlListView_DeleteItemsSelected(GUICtrlGetHandle($LST_TaskExecution_extraFiles))
					GUICtrlSetState($BTN_TaskExecution_save, $GUI_ENABLE)
					$taskFormActivity=1
				endif
			endif
			if $fcs=GUICtrlGetHandle($LST_TaskExecution_TargetLoc) then
				if _GUICtrlListView_GetSelectedCount($LST_TaskExecution_TargetLoc) >0 then
					BTN_TaskExecution_DeleteTargetLoc()
				endif
			endif
		EndFunc
	#endregion
	#region ********************************** FORM Folder creation task      *********************************************************************
		#region general form task
			Func BTN_FolderCreation_saveClick()
				$sTitle = _CTRLread($CMB_jobcreation_selecttask)
				ConsoleWrite('++BTN_FolderCreation_saveClick() = '& $sTitle & @crlf )
				GUISetCursor(15, 1,$TaskFolderCreation)
				GUISetCursor(15, 1,$TasKCopyCreation)
				Dim $r[5]
				$taskorder=_GetNextTaskOrder()
				$TaskActive=_CheckTaskActive($taskNumber)
				_LST_TaskCreationDeleteTaskUID()  ; delete all from task before creation
				switch $sTitle
					Case "Folder Creation Task","Deletion Task"
						$r[1]=_LST_TaskCreation_LocStore($sTitle,"TargetLoc",$LST_TaskFolderCreation_TargetLoc,$CMB_TaskFolderCreation_TargetCred,$TXT_FolderCreation_taskdesc,$TaskActive)
						$r[2]=_LST_TaskCreation_PathStore($sTitle,"TargetPath",$LST_TaskFolderCreation_TargetPaths,$TaskActive)
						If $r[1] And $r[2] Then
							MsgBox(64+4096,"Saving Task data","The Task data was stored",0,0)
							$taskFormActivity=0
						ENDIF
					Case "Copy Task","Execution Task","Compression Task","Decompression Task"
						$r[1]=_LST_TaskCreation_LocStore($sTitle,"SourceLoc",$LST_TaskFolderCreation_SourceLoc,$CMB_TaskFolderCreation_SourceCred,$TXT_FolderCreation_taskdesc,$TaskActive)
						$r[2]=_LST_TaskCreation_LocStore($sTitle,"TargetLoc",$LST_TaskFolderCreation_TargetLoc,$CMB_TaskFolderCreation_TargetCred,$TXT_FolderCreation_taskdesc,$TaskActive)
						$r[3]=_LST_TaskCreation_PathStore($sTitle,"SourcePath",$LST_TaskFolderCreation_SourcePaths,$TaskActive)
						$r[4]=_LST_TaskCreation_PathStore($sTitle,"TargetPath",$LST_TaskFolderCreation_TargetPaths,$TaskActive)
						If $r[1] And $r[2] And $r[3] And $r[4] Then
							MsgBox(64+4096,"Saving Task data","The Task data was stored",0,0)
							$taskFormActivity=0
						endif
				EndSwitch
				GUISetCursor(-1, 1,$TaskFolderCreation)
				GUISetCursor(-1, 1,$TasKCopyCreation)
				_TaskCreation_registerJOB()
			EndFunc
			Func BTN_FolderCreation_closeClick()
				ConsoleWrite('++BTN_FolderCreation_closeClick() = '& @crlf )
				TaskFolderCreationClose()
			EndFunc
		#endregion
		#region select local source and target
			Func BTN_TaskFolderCreation_AddToSourceLocClick()
				ConsoleWrite('++BTN_TaskFolderCreation_AddToSourceLocClick() = '& @crlf )
				GUICtrlSetState($BTN_TaskFolderCreation_AddToSourceLoc,$GUI_DISABLE)
				_TaskFormCreationFillLocList($LST_TaskFolderCreation_SourceLoc)
				GUICtrlSetData($LBL_SourceLoc,"Cant:"&_GUICtrlListView_GetItemCount($LST_TaskFolderCreation_SourceLoc)  )
				_TaskFormCreation_SaveBTN()
				GUICtrlSetState($BTN_TaskFolderCreation_AddToSourceLoc,$GUI_ENABLE)
				_CopyForm_OnMirror_Checks()
				$taskFormActivity=1
			EndFunc
			Func BTN_TaskFolderCreation_AddToTargetLocClick()
				ConsoleWrite('++BTN_TaskFolderCreation_AddToTargetLocClick() = ' & @crlf )
				GUICtrlSetState($BTN_TaskFolderCreation_AddToTargetLoc,$GUI_DISABLE)
				_TaskFormCreationFillLocList($LST_TaskFolderCreation_TargetLoc)
				GUICtrlSetData($LBL_TargetLoc,"Cant:"&_GUICtrlListView_GetItemCount($LST_TaskFolderCreation_TargetLoc)  )
				_TaskFormCreation_SaveBTN()
				GUICtrlSetState($BTN_TaskFolderCreation_AddToTargetLoc,$GUI_ENABLE)
				$taskFormActivity=1
			EndFunc
			Func BTN_TaskFolderCreation_DeleteTargetLoc()
				ConsoleWrite('++BTN_TaskFolderCreation_DeleteTargetLoc() = ' & @crlf )
				_GUICtrlListView_DeleteItemsSelected(GUICtrlGetHandle($LST_TaskFolderCreation_TargetLoc))
				_TaskFormCreation_SaveBTN()
				GUICtrlSetState($BTN_TaskFolderCreation_DeleteTargetLoc,$GUI_DISABLE)
				$taskFormActivity=1
				GUICtrlSetData($LBL_TargetLoc,"Cant:"&_GUICtrlListView_GetItemCount($LST_TaskFolderCreation_TargetLoc)  )
			EndFunc
			Func BTN_TaskFolderCreation_DeleteSourceLoc()
				ConsoleWrite('++BTN_TaskFolderCreation_DeleteSourceLoc() = ' & @crlf )
				_GUICtrlListView_DeleteItemsSelected(GUICtrlGetHandle($LST_TaskFolderCreation_SourceLoc))
				_TaskFormCreation_SaveBTN()
				GUICtrlSetState($BTN_TaskFolderCreation_DeleteSourceLoc,$GUI_DISABLE)
				_CopyForm_OnMirror_Checks()
				$taskFormActivity=1
				GUICtrlSetData($LBL_SourceLoc,"Cant:"&_GUICtrlListView_GetItemCount($LST_TaskFolderCreation_SourceLoc)  )
			EndFunc
			Func contextSubmenu_TaskFolderCreation_delete()
				if _GUICtrlListView_GetSelectedCount($LST_TaskFolderCreation_TargetLoc) >0 then
					 BTN_TaskFolderCreation_DeleteTargetLoc()
				endif
			EndFunc
		#endregion
		#region select path
			Func BTN_TaskFolderCreation_AddSourcePathClick()
				ConsoleWrite('++BTN_TaskFolderCreation_AddSourcePathClick() = '& @crlf )
				$recurse=""
				Select
					Case _CTRLread($CMB_jobcreation_selecttask)="Decompression Task"
						GUICtrlCreateListViewItem(_CTRLread($TXT_TaskFolderCreation_SourcePath)&"|"& _
							_CTRLread($TXT_TaskFolderCreation_SourceZIPFilter)&".zip",$LST_TaskFolderCreation_SourcePaths)
					Case _CTRLread($CMB_jobcreation_selecttask)="Compression Task"
						If _NOexistInList($LST_TaskFolderCreation_TargetPaths,_CTRLread($TXT_TaskFolderCreation_SourcePath),0) AND _
							_CheckDuplicatesIn2Lists($LST_TaskFolderCreation_SourceLoc,$LST_TaskFolderCreation_TargetLoc,1)=False Then  ;checkear que no existe duplicado AND del las colunas 0 y 1
							If _IsChecked($CK_TaskFolderCreation_Recurse) Then $recurse="[R]"
							If _CTRLread($TXT_TaskFolderCreation_SourceZIPFilter)="" Then
								GUICtrlSetData($TXT_TaskFolderCreation_SourceZIPFilter,"*")
							endif
							If _CTRLread($TXT_TaskFolderCreation_olderThan)=0 Or _CTRLread($TXT_TaskFolderCreation_olderThan)="" Then
								GUICtrlCreateListViewItem(_CTRLread($TXT_TaskFolderCreation_SourcePath)&"|"& _
									_CTRLread($TXT_TaskFolderCreation_SourceZIPFilter)&$recurse,$LST_TaskFolderCreation_SourcePaths)
							else
								GUICtrlCreateListViewItem(_CTRLread($TXT_TaskFolderCreation_SourcePath)&"|"& _
									_CTRLread($TXT_TaskFolderCreation_SourceZIPFilter) &" ["& _
									_CTRLread($TXT_TaskFolderCreation_olderThan)&"]"&$recurse,$LST_TaskFolderCreation_SourcePaths)
							endif
						Else
							MsgBox(48+4096,"Attention","Same source/target path. You cannot save the zip container in the same location of the source files",0,0)
						endif
					Case _CTRLread($CMB_jobcreation_selecttask)="Copy Task"
						If _NOexistInList($LST_TaskFolderCreation_TargetPaths,_CTRLread($TXT_TaskFolderCreation_SourcePath),0) And _
							_CheckDuplicatesIn2Lists($LST_TaskFolderCreation_SourceLoc,$LST_TaskFolderCreation_TargetLoc,1)=False Then  ;checkear que no existe duplicado AND del las colunas 0 y 1
							If 	_IsChecked($CK_TaskFolderCreation_Recurse)=False Or _   ; no recursive
								_CheckDuplicatesIn2Lists($LST_TaskFolderCreation_SourceLoc,$LST_TaskFolderCreation_TargetLoc,1)=False Or _
								(_IsChecked($CK_TaskFolderCreation_Recurse)=True And _	; recursive y el target no contiene el source
									_NoexistInSTRinList($LST_TaskFolderCreation_TargetPaths,_CTRLread($TXT_TaskFolderCreation_SourcePath),1)=True ) _
							Then
								If _IsChecked($CK_TaskFolderCreation_Recurse) Then $recurse="[R]"
								If _IsChecked($RD_CopyTask_Move) Then $recurse=$recurse&"[MV]"
								If _IsChecked($RD_CopyTask_Mirror) Then
									$recurse=$recurse&"[M]"
									GUICtrlSetState($RD_CopyTask_Copy,$GUI_CHECKED)
									GUICtrlSetState($RD_CopyTask_Mirror, $GUI_UNCHECKED)
								endif
								If _CTRLread($TXT_TaskFolderCreation_SourceZIPFilter)="" Then
									GUICtrlSetData($TXT_TaskFolderCreation_SourceZIPFilter,"*")
								endif
								If _CTRLread($TXT_TaskFolderCreation_olderThan)=0 Or _CTRLread($TXT_TaskFolderCreation_olderThan)="" Then
									GUICtrlCreateListViewItem(_CTRLread($TXT_TaskFolderCreation_SourcePath)&"|"& _
										_CTRLread($TXT_TaskFolderCreation_SourceZIPFilter)&$recurse,$LST_TaskFolderCreation_SourcePaths)
								else
									GUICtrlCreateListViewItem(_CTRLread($TXT_TaskFolderCreation_SourcePath)&"|"& _
										_CTRLread($TXT_TaskFolderCreation_SourceZIPFilter) &" ["& _
										_CTRLread($TXT_TaskFolderCreation_olderThan)&"]"&$recurse,$LST_TaskFolderCreation_SourcePaths)
								endif
							Else
								MsgBox(48+4096,"Attention","Source path contained in Target path . You cannot Copy/Move/Mirror recursive , starting and endless loop.",0)
							EndIf
						Else
							MsgBox(48+4096,"Attention","“Same source/target path. You cannot save the zip container in the same location of the source files”",0,0)
						endif
					Case Else
						If _CTRLread($TXT_TaskFolderCreation_olderThan)>0 And _CTRLread($TXT_TaskFolderCreation_SourceZIPFilter)="" Then
							GUICtrlSetData($TXT_TaskFolderCreation_SourceZIPFilter,"*")
						endif
						GUICtrlCreateListViewItem(_CTRLread($TXT_TaskFolderCreation_SourcePath)&"|"& _
							_CTRLread($TXT_TaskFolderCreation_SourceZIPFilter),$LST_TaskFolderCreation_SourcePaths)
				EndSelect

				GUICtrlSetData($TXT_TaskFolderCreation_olderThan,0)
				$taskFormActivity=1
				_TaskFormCreation_SaveBTN()
				GUICtrlSetData($TXT_TaskFolderCreation_SourcePath,"")
				GUICtrlSetData($TXT_TaskFolderCreation_SourceZIPFilter,"")
				_cleanLSTduplicates($LST_TaskFolderCreation_SourcePaths)
				_CopyForm_OnMirror_Checks()
			EndFunc
			Func BTN_TaskFolderCreation_AddTargetPathClick()
				ConsoleWrite('++BTN_TaskFolderCreation_AddTargetPathClick() = '& @crlf )
				$sTitle = _CTRLread($CMB_jobcreation_selecttask)
				Select
					Case $sTitle="Decompression Task"
						ConsoleWrite('++BTN_TaskFolderCreation_AddTargetPathClick() = Decompression Task'& @crlf )
						If _IsChecked($RD_TaskFolderCreation_ZIPOverwrite) then
							GUICtrlCreateListViewItem(_CTRLread($TXT_TaskFolderCreation_TargetPath)&"|Overwrite",$LST_TaskFolderCreation_TargetPaths)
						else
							GUICtrlCreateListViewItem(_CTRLread($TXT_TaskFolderCreation_TargetPath)&"|Autorename",$LST_TaskFolderCreation_TargetPaths)
						endif
						$taskFormActivity=1
					Case $sTitle="Deletion Task"
						ConsoleWrite('++BTN_TaskFolderCreation_AddTargetPathClick() = Deletion Task'& @crlf )
						$recurse=""
						If _IsChecked($CK_TaskFolderCreation_Recurse) Then $recurse="[R]"
						If _CTRLread($TXT_TaskFolderCreation_olderThan)=0 Or _CTRLread($TXT_TaskFolderCreation_olderThan)="" Then
							GUICtrlCreateListViewItem(_CTRLread($TXT_TaskFolderCreation_TargetPath)&"|"& _
								_CTRLread($TXT_TaskFolderCreation_TargetPathFilter)&$recurse,$LST_TaskFolderCreation_TargetPaths)
						else
							GUICtrlCreateListViewItem(_CTRLread($TXT_TaskFolderCreation_TargetPath)&"|"& _
								_CTRLread($TXT_TaskFolderCreation_TargetPathFilter) &" ["& _
								_CTRLread($TXT_TaskFolderCreation_olderThan)&"]"&$recurse,$LST_TaskFolderCreation_TargetPaths)
						endif
						$taskFormActivity=1
					Case $sTitle="Compression Task"
						$ZipStructure=""
						$ZipDelete=""
						$ZipAutoRename=""
						$ZipServerFolder=""
						$ZipServerFolderInside=""
						If _NOexistInList($LST_TaskFolderCreation_SourcePaths,_CTRLread($TXT_TaskFolderCreation_TargetPath),0) OR _CheckDuplicatesIn2Lists($LST_TaskFolderCreation_SourceLoc,$LST_TaskFolderCreation_TargetLoc,1)=False  then
							If	(_NoexistInSTRinList($LST_TaskFolderCreation_SourcePaths,"[R]",2)=True) Or _	; [R] no existe
								(_NoexistInSTRinList($LST_TaskFolderCreation_SourcePaths,"[R]",2)=False AND _   ; [R] si existe y el target no contiene al source
									_CheckListIfInSTR($LST_TaskFolderCreation_SourcePaths,_CTRLread($TXT_TaskFolderCreation_TargetPath),1)=False) _
							Then
								If _IsChecked($RD_TaskFolderCreation_ZIPsingle) Then $ZipStructure="[NS]"
								If _IsChecked($CK_TaskFolderCreation_DeleteZip) Then $ZipDelete="[D]"
								If _IsChecked($CK_TaskFolderCreation_AutoRenameZip) Then $ZipAutoRename="[A]"
								If _IsChecked($CK_TaskFolderCreation_ServerFolderZip) Then $ZipServerFolder="[S]"
								If _IsChecked($CK_TaskFolderCreation_ServerFolderInsideZip) Then $ZipServerFolderInside="[FS]"
								GUICtrlCreateListViewItem(_CTRLread($TXT_TaskFolderCreation_TargetPath)&"|"& _
								_CTRLread($TXT_TaskFolderCreation_TargetZIPfilename)&$ZipStructure&$ZipDelete&$ZipAutoRename&$ZipServerFolder&$ZipServerFolderInside,$LST_TaskFolderCreation_TargetPaths)
								$taskFormActivity=1
							Else
								MsgBox(48+4096,"Attention","Source path contained in Target path . You cannot ZIP recursive , starting and endless loop."&@crlf&"ErrNo 995",0)
							EndIf
						Else
							MsgBox(48+4096,"Attention","'Same source/target path. You cannot save the zip container in the same location of the source files'"&@crlf&"ErrNo 996",0)
						EndIf
					Case $sTitle="Copy Task"
						If _NOexistInList($LST_TaskFolderCreation_SourcePaths,_CTRLread($TXT_TaskFolderCreation_TargetPath),0) OR _CheckDuplicatesIn2Lists($LST_TaskFolderCreation_SourceLoc,$LST_TaskFolderCreation_TargetLoc,1)=False then
							If	(_NoexistInSTRinList($LST_TaskFolderCreation_SourcePaths,"[R]",2)=True) Or _	; [R] no existe
								_CheckDuplicatesIn2Lists($LST_TaskFolderCreation_SourceLoc,$LST_TaskFolderCreation_TargetLoc,1)=False Or _
								(_NoexistInSTRinList($LST_TaskFolderCreation_SourcePaths,"[R]",2)=False AND _   ; [R] si existe y el target no contiene al source
									_CheckListIfInSTR($LST_TaskFolderCreation_SourcePaths,_CTRLread($TXT_TaskFolderCreation_TargetPath),1)=False ) _
							Then
								$CopyStructure=""
								$CopyForderPerSource=""
								$CopyEmptyForders=""
								If _IsChecked($CK_CopyTask_RStructure) Then	$CopyStructure="[NS]"
								If _IsChecked($CK_CopyTask_FolderPerSource) Then $CopyForderPerSource="[OF]"
								If _IsChecked($CK_CopyTask_EmptyFolders) Then $CopyEmptyForders="[EF]"

								$CopyTBehaviour=""
								Switch _CTRLread($CMB_CopyTask_Behaviour)
									Case "Overwrite"
										$CopyTBehaviour="Overwrite"
									Case "Skip on conflict"
										$CopyTBehaviour="Skip"
									Case "Rename on conflict"
										$CopyTBehaviour="Rename"
									Case "Prompt user on conflict"
										$CopyTBehaviour="Prompt"
								EndSwitch

								GUICtrlCreateListViewItem(_CTRLread($TXT_TaskFolderCreation_TargetPath)&"|"& _
								$CopyTBehaviour&$CopyStructure&$CopyForderPerSource&$CopyEmptyForders,$LST_TaskFolderCreation_TargetPaths)
								$taskFormActivity=1
							Else
								MsgBox(48+4096,"Attention","Source path contained in Target path . You cannot Copy/Move/Mirror recursive , starting and endless loop.",0)
							EndIf
						Else
							MsgBox(48+4096,"Attention","Same source/target path. You cannot Copy/Move/Mirror container in the same location of the source files",0)
						EndIf
					Case Else
						ConsoleWrite('!!3 = '& @crlf )
						GUICtrlCreateListViewItem(_CTRLread($TXT_TaskFolderCreation_TargetPath),$LST_TaskFolderCreation_TargetPaths)
						$taskFormActivity=1
				EndSelect

				_cleanLSTduplicates($LST_TaskFolderCreation_TargetPaths)
				_TaskFormCreation_SaveBTN()
				GUICtrlSetData($TXT_TaskFolderCreation_TargetPath,"")
				GUICtrlSetData($TXT_TaskFolderCreation_TargetPathFilter,"")
				GUICtrlSetState($RD_TaskFolderCreation_ZIPOverwrite, $GUI_CHECKED)
				GUICtrlSetState($RD_TaskFolderCreation_ZIPsingle, $GUI_CHECKED)
				GUICtrlSetState($RD_TaskFolderCreation_ZIPMultiple, $GUI_UNCHECKED)
				GUICtrlSetState($RD_TaskFolderCreation_ZIPstructure, $GUI_UNCHECKED)
				GUICtrlSetData($TXT_TaskFolderCreation_TargetZIPfilename,"")
				GUICtrlSetState($TXT_TaskFolderCreation_TargetZIPfilename,$GUI_ENABLE)
			EndFunc
			Func BTN_TaskFolderCreation_DeleteTargetPathClick()
				ConsoleWrite('++BTN_TaskFolderCreation_DeleteTargetPathClick() = '& @crlf )
				_GUICtrlListView_DeleteItemsSelected(GUICtrlGetHandle($LST_TaskFolderCreation_TargetPaths))
				$taskFormActivity=1
				_TaskFormCreation_SaveBTN()
				GUICtrlSetState($BTN_TaskFolderCreation_DeleteTargetPath,$GUI_DISABLE)
			EndFunc
			Func BTN_TaskFolderCreation_DeleteSourcePathClick()
				ConsoleWrite('++BTN_TaskFolderCreation_DeleteSourcePathClick() = '& @crlf )
				_GUICtrlListView_DeleteItemsSelected(GUICtrlGetHandle($LST_TaskFolderCreation_SourcePaths))
				_TaskFormCreation_SaveBTN()
				GUICtrlSetState($BTN_TaskFolderCreation_DeleteSourcePath,$GUI_DISABLE)
				_CopyForm_OnMirror_Checks()
				_CopyForm_OnDeleteMirror_Checks()
				$taskFormActivity=1
			EndFunc
		#endregion
	#endregion
	#region  ================================= form About                     =====================================================================
	#endregion
	#region  ================================= form Settings                  =====================================================================
		#region  ================================= general form settings                 ======================================
			Func BTN_SettingsCancelClick()
				ConsoleWrite('++BTN_SettingsCancelClick() = '& @crlf )
				FormSettingsClose()
			EndFunc
			Func BTN_SettingsOKClick()
				ConsoleWrite('++BTN_SettingsOKClick() = '& @crlf )
				FormSettingsClose()
			EndFunc
			Func PageControl1Change()
				ConsoleWrite('++PageControl1Change() = '& _GUICtrlTab_GetCurSel($hTab_PageControl1_servers)  &@crlf )
				If _GUICtrlTab_GetCurSel($hTab_PageControl1_servers) = 1 Then ; zero based index of current selected TabItem
					_GUICtrlIpAddress_ShowHide ($IPAddress1, @SW_SHOW)
				Else
					_GUICtrlIpAddress_ShowHide ($IPAddress1, @SW_HIDE)
				EndIf

			EndFunc
		#endregion
		#region  ================================= form settings servers add             ======================================
			Func BTN_Settings_NSlookupClick()
				ConsoleWrite('++BTN_Settings_NSlookupClick() = '& @crlf)
				If _CTRLread($TXT_settings_FQDN)<>"" Then
					GUICtrlSetData($LBL_Settings_DNSregistration,"No DNS Registration found")
					GUICtrlSetState(-1,$GUI_HIDE)
					$res=_ReverseDNS(_CTRLread($TXT_settings_FQDN))
					If IsArray($res) Then
						;check if there are many ips
						_printFromArray($res)
						if ubound($res)>3 then
							GUICtrlSetState($LBL_selectServerIP,$GUI_Show)
							GUICtrlSetState($CMB_selectServerIP,$GUI_Show)
						else
							GUICtrlSetState($LBL_selectServerIP,$GUI_HIDE)
							GUICtrlSetState($CMB_selectServerIP,$GUI_HIDE)
						endif
						for $ic=2 to ubound($res)-1
							If _IsValidIP($res[$ic]) Then
								_GUICtrlComboBox_InsertString($CMB_selectServerIP, $res[$ic], 0)
							endif
						next
						_GUICtrlComboBox_SelectString($CMB_selectServerIP, $res[2])
						If _IsValidIP($res[2]) Then
							_GUICtrlIpAddress_set($IPAddress1,$res[2])
							GUICtrlSetState($LBL_Settings_DNSregistration,$GUI_HIDE)
						else
							_GUICtrlIpAddress_Set($IPAddress1, "0.0.0.0")
							GUICtrlSetData($LBL_Settings_DNSregistration,"DNS Registration is not IPv4")
							GUICtrlSetState($LBL_Settings_DNSregistration,$GUI_show)
						EndIf
						If StringInStr($res[1],_CTRLread($TXT_settings_FQDN))>0 Then
							$flagfqdn=1
							GUICtrlSetData($TXT_settings_FQDN,$res[1])
							$flagfqdn=0
						endif
					Else
						_GUICtrlIpAddress_Set($IPAddress1, "0.0.0.0")
						GUICtrlSetState($LBL_Settings_DNSregistration,$GUI_show)
					endif
				endif
			EndFunc
			Func BTN_settings_AddNewServerClick()
				ConsoleWrite('++BTN_settings_AddNewServerClick() = '& @crlf)
				If _CTRLread($TXT_settings_FQDN)<>"" Then
					$linea=_GetLineInList($LST_settings_serversAdd,0,_CTRLread($TXT_settings_FQDN))
					If _NOexistInList($LST_settings_serversAdd,_CTRLread($TXT_settings_FQDN),0) or  $linea[2]<>_GUICtrlIpAddress_Get($IPAddress1)  then
						_AddNewServer()
						_FillSettingsFormData()
					Else
						MsgBox(48+4096,"Saving Custom server data","The Custom server already exist.",0,0)
					endif
				EndIf
			EndFunc
			Func BTN_Settings_ServerRemoveClick()
				ConsoleWrite('++BTN_Settings_ServerRemoveClick() = '& @crlf)
				If _AreYouSureYesNo("Do you want to delete the selected server?" ) Then
					$selected=_GUICtrlListView_GetSelectedIndices($LST_settings_serversAdd, True)
					_DeleteserverManagement()
					_FillSettingsFormData()
					_GUICtrlListView_EnsureVisible($LST_settings_serversAdd,$selected[1])
					If _GUICtrlListView_GetItemCount($LST_settings_serversAdd)>=$selected[1] Then
						$sel=$selected[1]
					Else
						$sel=$selected[1]-1
					endif
					_GUICtrlListView_SetItemSelected($LST_settings_serversAdd,$sel)
				endif
			EndFunc
			Func BTN_Settings_ResetServers()
				ConsoleWrite('++BTN_Settings_ResetServers() = '& @crlf)
				GUI_ConfirmResetServers2TemplateForm("Confirm server deletion.","ResetServers2template")
			EndFunc
			Func BTN_Settings_KeepCustomServers()
				ConsoleWrite('++BTN_Settings_KeepCustomServers() = '& @crlf)
				GUI_ConfirmResetServers2TemplateForm("Confirm server deletion.","KeepOnlyCustom")
			EndFunc
			Func BTN_ResetServers2Template_OKClick($optionReset)
				ConsoleWrite('++BTN_ResetServers2Template_OKClick() = '&$optionReset& @crlf)
				if $optionReset="ResetServers2template" then
					_ResetServers2template()
					GUICtrlSetstate($LBL_ResetServers2TemplateProgress,$GUI_Show)
					GUICtrlSetBkColor($LBL_ResetServers2TemplateProgress, _color("RED"))
					_ConfigDBInitial(1)
					GUICtrlSetstate($LBL_ResetServers2TemplateProgress,$GUI_hide)
				endif
				if $optionReset="KeepOnlyCustom" then _ResetKeepOnlyCustom()
				_FillSettingsFormData()
				ResetServers2Template_FormClose()
			EndFunc
			Func BTN_ResetServers2Template_CloseClick()
				ConsoleWrite('++BTN_ResetServers2Template_CloseClick() = '& @crlf)
				ResetServers2Template_FormClose()
			EndFunc
		#endregion
		#region  ================================= form Settings credentials             ======================================
			Func BTN_credAddChangeClick()
				ConsoleWrite('++BTN_credAddChangeClick() = '& @crlf )
				;validating fields
				$creddomainvalue=GUICtrlRead($TXT_creddomain)
				$creduservalue=GUICtrlRead($TXT_creduser)
				$credpasswrdvalue=GUICtrlRead($TXT_credpassword)
				if StringStripWS($creddomainvalue,8)="" then
					MsgBox(48+4096,"Missing credentials data","Domain field cannot be blank",0)
					Return
				EndIf
				if StringStripWS($creduservalue,8)=""  then
					MsgBox(48+4096,"Missing credentials data","User field cannot be blank",0)
					Return
				EndIf
				if StringStripWS($credpasswrdvalue,8)="" then
					MsgBox(48+4096,"Missing credentials data","Password field cannot be blank",0)
					Return
				EndIf
				;saving user data
				_SettingsCreds_save()
				_FillCredSettingsListbox()
				GUICtrlSetData($TXT_creddomain,"")
				GUICtrlSetData($TXT_creduser,"")
				GUICtrlSetData($TXT_credpassword,"")
			EndFunc
			Func BTN_CredDeleteClick()
				ConsoleWrite('++BTN_CredDeleteClick() = '& @crlf )
				_Deletecred()
				GUICtrlSetData($TXT_creddomain,"")
				GUICtrlSetData($TXT_creduser,"")
				GUICtrlSetData($TXT_credpassword,"")
				_FillCredSettingsListbox()
				$flagCredShow=1
				BTN_credshowpassClick()
			EndFunc
			Func BTN_credshowpassClick()
				ConsoleWrite('++btn_credshowpassClick() = '& @crlf )
				if $flagCredShow=0 then
					;Show Password
					GUICtrlSendMsg($TXT_credpassword,0xCC,0,0)
					GUICtrlSetState($TXT_credpassword, @SW_UNLOCK)
					GUICtrlSetData($BTN_credshowpass,"Hide")
					$flagCredShow=1
				Else
					;Hide Password
					GUICtrlSendMsg($TXT_credpassword, 0xCC, Asc("*"), 0)
					GUICtrlSetState($TXT_credpassword, @SW_UNLOCK)
					GUICtrlSetData($BTN_credshowpass,"Show")
					$flagCredShow=0
				EndIf
			EndFunc
		#endregion
		#region  ================================= form Settings Custom Groups           ======================================
			Func CMB_custSelectGroupChange()
				ConsoleWrite('++Cmb_custSelectGroupChange() = '& @crlf )
				_FillCustomServersLst()
				If _GUICtrlListView_GetSelectedCount($LST_custsrvgrp)=0 Then
					GUICtrlSetState($BTN_custlistdeletesrv,$GUI_DISABLE)
				endif
			EndFunc
			Func BTN_custDeleteGroupClick()
				ConsoleWrite('++btn_custDeleteGroupClick() = '& @crlf )
				If _AreYouSureYesNo("Do you want to delete the selected custom group " &_CTRLread($CMB_custselectgroup) &"?" ) Then
					_DeleteCustomGroup()
					_FillCustomTabControls()
				EndIf
			EndFunc
			Func CMB_custSelectServerChange()
				ConsoleWrite('!!!!!!!!!++cmd_custSelectServerChange() = '& @crlf )
			EndFunc
			Func BTN_custAddCreateGRPClick()
				ConsoleWrite('++Btn_custAddCreateGRPClick() = '& @crlf )
				_custaddcreategrp()
				GUICtrlSetState($BTN_custdeletegroup,$GUI_DISABLE)
				GUICtrlSetState($BTN_custaddcreategrp,$GUI_DISABLE)
				_FillCustomTabControls()
			EndFunc
			Func BTN_custListDeleteSrvClick()
				ConsoleWrite('++Btn_custListDeleteSrvClick() = '& @crlf )
				If _AreYouSureYesNo("Do you want to delete the selected server?" ) Then
					_deletecustListDeleteSrv()
					_FillCustomTabControls()
				endif
			EndFunc
			; ---------  custom shares ----------------------------------------------------------------------------
			Func BTN_custAddShareClick()
				ConsoleWrite('++Btn_custAddShareClick() = '& @crlf )
				_custaddshare()
				_FillCustomShareLst()
				GUICtrlSetData($TXT_custsharename,"")
				GUICtrlSetData($TXT_custsharepath,"")
			EndFunc
			Func BTN_custDeleteShareClick()
				ConsoleWrite('++Btn_custDeleteShareClick() = '& @crlf )
				If _AreYouSureYesNo("Do you want to dDelete custom Share"&_CTRLread($TXT_custsharename) ) Then
					_custDeleteshare()
					_FillCustomShareLst()
					GUICtrlSetData($TXT_custsharename,"")
					GUICtrlSetData($TXT_custsharepath,"")
				endif
			EndFunc
		#endregion
		#region  ================================= form Settings import export - JOBS    ======================================
			Func BTN_settings_importExport()
				ConsoleWrite('++BTN_settings_importExport() = '& @crlf)
				$arr_formPos=WinGetPos ("[active]")
				GUI_JobImport($arr_formPos[0],$arr_formPos[1],$arr_formPos[2])
				GUISetState(@SW_HIDE, $SettingsForm)
			EndFunc
			Func BTN_importExport_CloseClick()
				ConsoleWrite('++BTN_importExport_CloseClick() = '& @crlf)
				FormJobImportClose()
			EndFunc
			Func BTN_importExport_ExportClick()
				ConsoleWrite('++BTN_importExport_ExportClick() = '& @crlf)
				GUICtrlSetstate($LBL_importExport_Load,$GUI_show)
				GUISetCursor(15, 1, $FormJobImport)
				_ExportJobs()
				GUISetCursor(-1, 1, $FormJobImport)
				GUICtrlSetstate($LBL_importExport_Load,$GUI_HIDE)
				GUICtrlSetData($TXT_importExport_fileExport,"")
				_cleanLSTCheckboxes($LST_importExport_ExportJoblist)
				GUICtrlSetData($TXT_importExtort_fileImport,"")
				_GUICtrlListView_DeleteAllItems($LST_importExport_ImportJoblist)
				GUICtrlSetstate($BTN_importExport_Export,$GUI_DISABLE)
			EndFunc
			Func BTN_importExtort_fileExportClick()
				ConsoleWrite('++BTN_importExtort_fileExportClick() = '& @crlf)
				_selectExportFile()
				$exportfile=_CTRLread($TXT_importExport_fileExport)
				$exportfileDIR=GetDir($exportfile)
				If $exportfileDIR<>"" Then
					If FileExists($exportfileDIR) And _HasLSTCheckBoxCheched($LST_importExport_ExportJoblist) Then
						GUICtrlSetstate($BTN_importExport_Export,$GUI_ENABLE)
					Else
						GUICtrlSetstate($BTN_importExport_Export,$GUI_DISABLE)
					endif
				Else
;~ 					MsgBox(16,"Folder not existent","Attention , The folder do not exist.")
				endif
			EndFunc
			Func BTN_importExtort_fileImportClick()
				ConsoleWrite('++BTN_importExtort_fileImportClick() = '& @crlf)
				GUICtrlSetstate($BTN_importExport_Import,$GUI_DISABLE)
				GUICtrlSetstate($BTN_importExport_fileImport,$GUI_DISABLE)
				_selectImportFile()
				GUICtrlSetstate($LBL_importExport_Load,$GUI_show)
				GUISetCursor(15, 1, $FormJobImport)
				_ImportFile_fillListData()
				GUISetCursor(-1, 1, $FormJobImport)
				GUICtrlSetstate($LBL_importExport_Load,$GUI_HIDE)
				if _CTRLread($TXT_importExtort_fileImport)<>"" Then
					GUICtrlSetstate($BTN_importExport_Import,$GUI_ENABLE)
				endif
				GUICtrlSetstate($BTN_importExport_fileImport,$GUI_ENABLE)
			EndFunc
			Func BTN_importExtort_ImportClick()
				ConsoleWrite('++BTN_importExtort_ImportClick() = '& @crlf)
				If FileExists(_CTRLread($TXT_importExtort_fileImport)) Then
					GUICtrlSetstate($LBL_importExport_Load,$GUI_show)
					GUISetCursor(15, 1, $FormJobImport)
					If _ImportJobs() Then MsgBox(64+4096,"Job Import","Import successful" & @CRLF & "Attention: Remember to set credential for each imported task",0,0)
					GUISetCursor(-1, 1, $FormJobImport)
					GUICtrlSetstate($LBL_importExport_Load,$GUI_HIDE)
					GUICtrlSetData($TXT_importExtort_fileImport,"")
					GUICtrlSetstate($BTN_importExport_Import,$GUI_DISABLE)
					_GUICtrlListView_DeleteAllItems($LST_importExport_ImportJoblist)
					GUICtrlSetData($TXT_importExport_fileExport,"")
				Else
					MsgBox(16,"File not existent","Attention , The file do not exist.")
				endif
			EndFunc
		#endregion
		#region  ================================= Servers export import                 ======================================
			Func BTN_settings_ExpImpProjectServers()
				ConsoleWrite('++BTN_settings_ExpImpProjectServers() = '& @crlf)
				$arr_formPos=WinGetPos ("[active]")
				GUI_ExportImportServers($arr_formPos[0],$arr_formPos[1],$arr_formPos[2])
				GUISetState(@SW_HIDE, $SettingsForm)
			EndFunc
			Func BTN_ExportImportServers_CloseClick()
				ConsoleWrite('++BTN_ExportImportServers_CloseClick() = '& @crlf)
				FormExportImportServersClose()
			EndFunc
			Func BTN_ExportImportServers_BrowseExportClick()
				ConsoleWrite('++BTN_ExportImportServers_BrowseExportClick() = '& @crlf)
				_disable_ExportImportServers_btn()
				GUICtrlSetData($LBL_ExportImportServers_Load,"        Selecting       ")
				_selectExportServersFile()
				$exportfile=_CTRLread($TXT_ExportImportServers_fileExport)
				$exportfileDIR=GetDir($exportfile)
				If $exportfileDIR<>"" Then
					If FileExists($exportfileDIR) Then
						GUICtrlSetstate($BTN_ExportImportServers_Export,$GUI_ENABLE)
					Else
						GUICtrlSetstate($BTN_ExportImportServers_Export,$GUI_DISABLE)
					endif
				endif
				_Enable_ExportImportServers_btn()
			EndFunc
			Func BTN_ExportImportServers_BrowseImportClick()
				ConsoleWrite('++BTN_ExportImportServers_BrowseImportClick() = '& @crlf)
				_disable_ExportImportServers_btn()
				_selectImportServersFile()
				if _CTRLread($TXT_ExportImportServers_fileimport)<>"" Then	$res=_ImportServers_FillList()
				if $res=False then GUICtrlSetData($TXT_ExportImportServers_fileImport,"")
				_Enable_ExportImportServers_btn()
			EndFunc
			Func BTN_ExportImportServers_ImportClick()
				ConsoleWrite('!++BTN_ExportImportServers_ImportClick() = '& @crlf)
				If FileExists(_CTRLread($TXT_ExportImportServers_fileImport)) Then
					_disable_ExportImportServers_btn()
					$prjName=InputBox("Project Name","Project Name (max. 15 chars. alfanumeric.)","MyProject"," M15",-1,70)
					$prjName=StringStripWS($prjName,1+2+4)
					if $prjName<>"" then
						if StringIsAlNum($prjName) then
							If _ImportServers($prjName) Then MsgBox(64+4096,"Job Import","Import successful" & @CRLF & "Attention: Remember to set credential for each impotred task",0,0)
							GUICtrlSetData($TXT_ExportImportServers_fileImport,"")
						Else
							MsgBox(16,"Only Apfanumeic","Attention , The project name can only contain Apphanumeric simbols.")
						EndIf
					endif
					_Enable_ExportImportServers_btn()
				Else
					MsgBox(16,"File not exist","Attention , The file do not exist.")
				endif
			EndFunc
			Func BTN_ExportImportServers_ExportClick()
				ConsoleWrite('!++BTN_ExportImportServers_ExportClick() = '& @crlf)
				_disable_ExportImportServers_btn()
				GUICtrlSetData($LBL_ExportImportServers_Load,"        Exporting       ")
				local $filedest=_selectExportServersFiledest()
				if $filedest<>"0" then _ExportServers($filedest)
				_Enable_ExportImportServers_btn()
			EndFunc
			Func BTN_ExportImportServers_Template()
				ConsoleWrite('++BTN_ExportImportServers_Template() = '& @crlf)
				_disable_ExportImportServers_btn()
				GUICtrlSetData($LBL_ExportImportServers_Load,"  Exporting template   ")
				local $filedest=_selectExportServersTemplateFiledest()
				if $filedest<>"0" then _ExportTemplate($filedest)
				_Enable_ExportImportServers_btn()
			EndFunc
			Func _Enable_ExportImportServers_btn()
				ConsoleWrite('++_Enable_ExportImportServers_btn() = '& @crlf)
				GUISetCursor(2, 1, $FormExportImportServers)
				GUICtrlSetstate($LBL_ExportImportServers_Load,$GUI_HIDE)

				GUICtrlSetstate($BTN_ExportImportServers_fileImport,$GUI_ENABLE)
				if _CTRLread($TXT_ExportImportServers_fileimport)<>"" Then
					GUICtrlSetstate($BTN_ExportImportServers_Import,$GUI_ENABLE)
;~ 					GUICtrlSetstate($BTN_ExportImportServers_Export,$GUI_ENABLE)
				endif

				GUICtrlSetstate($BTN_ExportImportServers_fileExport,$GUI_ENABLE)
				if _CTRLread($TXT_ExportImportServers_fileExport)<>"" Then
					GUICtrlSetstate($BTN_ExportImportServers_Export,$GUI_ENABLE)
;~ 					GUICtrlSetstate($BTN_ExportImportServers_Import,$GUI_ENABLE)
				endif
			EndFunc
			Func _disable_ExportImportServers_btn()
				ConsoleWrite('++_disable_ExportImportServers_btn() = '& @crlf)
				GUISetCursor(15, 1, $FormExportImportServers)
				GUICtrlSetstate($LBL_ExportImportServers_Load,$GUI_show)
				GUICtrlSetstate($BTN_ExportImportServers_Import,$GUI_DISABLE)
				GUICtrlSetstate($BTN_ExportImportServers_fileImport,$GUI_DISABLE)
				GUICtrlSetstate($BTN_ExportImportServers_fileExport,$GUI_DISABLE)
				GUICtrlSetstate($BTN_ExportImportServers_Export,$GUI_DISABLE)
			EndFunc
		#endregion
		#region  ================================= form Settings Application preferences ======================================
			Func CK_settingspref_Recurse()
				ConsoleWrite('++CK_settingspref_Recurse() = '& @crlf)
				_UpdateAppSettings("Recurse", _IsCheckedType($CK_settingspref_Recurse))
			EndFunc
			Func CK_settingspref_TypeUpdate()
				ConsoleWrite('++CK_settingspref_TypeUpdate() = '& @crlf)
				_UpdateAppSettings("TypeUpdate", _IsCheckedType($CK_settingspref_TypeUpdate))
			EndFunc
			Func CK_settingspref_CleanConsoleEveryLines()
				ConsoleWrite('++CK_settingspref_CleanConsoleEveryLines() = '& @crlf)
				_UpdateAppSettings("CleanConsoleEveryLines",_IsCheckedType($CK_settingspref_CleanConsoleEveryLines))
			EndFunc
			Func CK_settingspref_verbose()
				ConsoleWrite('++CK_settingspref_verbose() = '& @crlf)
				_UpdateAppSettings("verbose",_IsCheckedType($CK_settingspref_verbose))
			EndFunc
			Func CK_settingspref_logactivity()
				ConsoleWrite('++CK_settingspref_logactivity() = '& @crlf)
				_UpdateAppSettings("logactivity",_IsCheckedType($CK_settingspref_logactivity))
			EndFunc
			Func CK_settingspref_showprogress()
				ConsoleWrite('++CK_settingspref_showprogress() = '& @crlf)
				_UpdateAppSettings("ShowProgress",_IsCheckedType($CK_settingspref_showprogress))
			EndFunc
			Func CK_settingspref_StopOnWarnings()
				ConsoleWrite('++CK_settingspref_StopOnWarnings() = '& @crlf)
				_UpdateAppSettings("StopOnWarnings",_IsCheckedType($CK_settingspref_StopOnWarnings))
			EndFunc
			Func CK_settingspref_ConsoleQuiet()
				ConsoleWrite('++CK_settingspref_ConsoleQuiet() = '& @crlf)
				_UpdateAppSettings("ConsoleQuiet",_IsCheckedType($CK_settingspref_quiet))
			EndFunc
			Func CK_settingspref_CreateDesktopShortcut()
				ConsoleWrite('++CK_settingspref_CreateDesktopShortcut() = '& @crlf)
				_UpdateAppSettings("CreateDesktopShortcut",_IsCheckedType($CK_settingspref_CreateDesktopShortcut))
			EndFunc
			Func CK_settingspref_Proxy()
				ConsoleWrite('++CK_settingspref_Proxy() = '& @crlf)
				$ste=_IsCheckedType($CK_settingspref_Proxy)
				_UpdateAppSettings("UseProxy",$ste)
				_CheckproxyportTXT()
				if $ste=$GUI_CHECKED then
					GUICtrlSetState($CK_settingspref_ProxyIE,_GetAppSettings("UseProxyIE",$GUI_UNCHECKED,1))
					GUICtrlSetstate($CK_settingspref_ProxyIE,$GUI_Enable)
					GUICtrlSetstate($TXT_settingspref_Proxy,$GUI_Enable)
					GUICtrlSetData($TXT_settingspref_Proxy,_getproxyport())
					GUICtrlSetstate($CMB_Proxy_Cred,$GUI_ENABLE)
				Else
					GUICtrlSetstate($CK_settingspref_ProxyIE,$GUI_UNCHECKED)
					GUICtrlSetstate($CK_settingspref_ProxyIE,$GUI_DISABLE)
					GUICtrlSetstate($TXT_settingspref_Proxy,$GUI_DISABLE)
					GUICtrlSetBkColor($TXT_settingspref_Proxy, _color("white"))
					GUICtrlSetstate($CMB_Proxy_Cred,$GUI_DISABLE)
				endif
			EndFunc
			Func CK_settingspref_ProxyIE()
				ConsoleWrite('++CK_settingspref_ProxyIE() = '& @crlf)
				$ste=_IsCheckedType($CK_settingspref_ProxyIE)
				_UpdateAppSettings("UseProxyIE",_IsCheckedType($CK_settingspref_ProxyIE))
				if $ste=$GUI_CHECKED  then
					GUICtrlSetstate($TXT_settingspref_Proxy,$GUI_DISABLE)
					GUICtrlSetData($TXT_settingspref_Proxy,_getproxyportIE())
				Else
					GUICtrlSetstate($TXT_settingspref_Proxy,$GUI_Enable)
					GUICtrlSetData($TXT_settingspref_Proxy,_getproxyport())
				endif
				_CheckproxyportTXT()
			EndFunc
			Func CMB_settingspref_copybehaviour()
				ConsoleWrite('++CMB_settingspref_copybehaviour() = '& @crlf)
				_UpdateAppSettings("CopyBehaviour",_CTRLread($CMB_settingspref_copybehaviour))
			EndFunc
			Func CMB_settingspref_CleanConsoleEveryLinesvalue()
				ConsoleWrite('++CMB_settingspref_CleanConsoleEveryLinesvalue() = '& @crlf)
				_UpdateAppSettings("CleanConsoleEveryLinesvalue",_CTRLread($CMB_settingspref_CleanConsoleEveryLinesvalue))
			EndFunc
			Func BTN_settingspref_ExecutableFileFolder_BrowseFileClick()
				ConsoleWrite('++BTN_settingspref_ExecutableFileFolder_BrowseFileClick() = '& @crlf)
				GUICtrlSetstate($BTN_settingspref_ExecutableFileFolder_BrowseFile,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder_default,$GUI_DISABLE)
				_selectExecuteFolderAppSettings()
				_UpdateAppSettings("ExecutableFileFolderDefault", _CTRLread($TXT_settingspref_ExecutableFileFolderDefault))
				GUICtrlSetstate($BTN_settingspref_ExecutableFileFolder_BrowseFile,$GUI_ENABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder,$GUI_ENABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder_default,$GUI_ENABLE)
			EndFunc
			Func BTN_settingspref_repo_SaveClick()
				ConsoleWrite('++BTN_settingspref_repo_SaveClick() = '& @crlf)
				if _CtrlRead($TXT_settingspref_Repo)<>"" then
					$rtype=_RecognizeRepoType(_CTRLread($TXT_settingspref_Repo))
					if $rtype then
						if _UpdateAppSettings("RepoAddress", _CTRLread($TXT_settingspref_Repo)) and _UpdateAppSettings("RepoType", $rtype) then
							GUICtrlSetBkColor($TXT_settingspref_Repo, _color("white"))
						Else
							GUICtrlSetBkColor($TXT_settingspref_Repo, _color("lightRed"))
							MsgBox(48+4096, "Error database update", "Error occurred while updating REPOADDRESS in database. ErrNo 2042" )
						endif
						GUICtrlSetstate($BTN_settingspref_repo_SaveClick,$GUI_DISABLE)
					else
						GUICtrlSetBkColor($TXT_settingspref_Repo, _color("lightRed"))
						MsgBox(48+4096,"Address Repository type","The Project Database repository Address type cannot be recognized." & _
								@crlf&"Please check the Project Database repository Address type." & _
								@crlf& "It must be Http / SBM: Share / Local Path.",0,0)
					endif
				endif
			EndFunc
			Func BTN_settingspref_repo_default()
				ConsoleWrite('++BTN_settingspref_repo_default() = '& @crlf)
				GUISetCursor(15, 1)
				GUICtrlSetstate($BTN_settingspref_ExecutableFileFolder_BrowseFile,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_repo_SaveClick,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_repo_default,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_repo_open,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder_default,$GUI_DISABLE)
				_updateDefaultRepoFromINI()
				$var=_GetAppSettings("RepoAddress",$RepoProjectDBDefault)
				GUICtrlSetData($TXT_settingspref_Repo,$var)
				GUISetCursor(-1, 1)
				GUICtrlSetstate($BTN_settingspref_ExecutableFileFolder_BrowseFile,$GUI_ENABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder,$GUI_ENABLE)
				GUICtrlSetstate($BTN_settingspref_repo_default,$GUI_ENABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder_default,$GUI_ENABLE)
			EndFunc
			Func BTN_settingspref_repo_open()
				ConsoleWrite('++BTN_settingspref_repo_open() = '& @crlf)
				_OpenRepo(_CtrlRead($TXT_settingspref_Repo))
			EndFunc
			Func BTN_settingspref_ActivityLogFolder()
				ConsoleWrite('++BTN_settingspref_ActivityLogFolder() = '& @crlf)
				GUICtrlSetstate($BTN_settingspref_ExecutableFileFolder_BrowseFile,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder_default,$GUI_DISABLE)
				_selectActivityLogFolderAppSettings()
				_UpdateAppSettings("ActivityLogFolder", _CTRLread($TXT_settingspref_ActivityLogFolder))
				_initLog()
				GUICtrlSetstate($BTN_settingspref_ExecutableFileFolder_BrowseFile,$GUI_ENABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder,$GUI_ENABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder_default,$GUI_ENABLE)
			EndFunc
			Func BTN_settingspref_ActivityLogFolder_default()
				ConsoleWrite('++BTN_settingspref_ActivityLogFolder_default() = '& @crlf)
				GUISetCursor(15, 1)
				GUICtrlSetstate($BTN_settingspref_ExecutableFileFolder_BrowseFile,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_repo_SaveClick,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_repo_default,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_repo_open,$GUI_DISABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder_default,$GUI_DISABLE)
				$ActivityLogFolder=_GetActivityLogFolder("onlyFromINI")
				GUICtrlSetData($TXT_settingspref_ActivityLogFolder,$ActivityLogFolder)
				_UpdateAppSettings("ActivityLogFolder", _CTRLread($TXT_settingspref_ActivityLogFolder))
				GUISetCursor(-1, 1)
				GUICtrlSetstate($BTN_settingspref_ExecutableFileFolder_BrowseFile,$GUI_ENABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder,$GUI_ENABLE)
				GUICtrlSetstate($BTN_settingspref_repo_default,$GUI_ENABLE)
				GUICtrlSetstate($BTN_settingspref_ActivityLogFolder_default,$GUI_ENABLE)
			EndFunc
		#endregion
		#region  ================================= form Settings - BACKUPS               ======================================
			Func BTN_settings_BackupRestore()
				ConsoleWrite('++BTN_settings_BackupRestore() = '& @crlf)

			EndFunc
		#endregion
	#endregion
	#region  ================================= UnitTesting ===================================================================================================
		Func BTN_exitClick()
			ConsoleWrite('++BTN_FolderCreation_exitClick() = '& @crlf)
			exit
		EndFunc
	#endregion
#endregion

