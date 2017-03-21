	Func WM_COMMAND($hWnd, $iMsg, $iwParam, $ilParam)  ; Handle WM_COMMAND messages en botones y checkboxes etc
		Local $nNotifyCode = _HiWord($iwParam)
		Local $nID = _LoWord($iwParam)
;~ 		ConsoleWrite("!+$nID" & $nID & @CRLF)  	;~ 	;ConsoleWrite("--$iMsg" & $iMsg & @CRLF)
;~ 		ConsoleWrite("!+$nID" & $iMsg & @CRLF)  	;~ 	;ConsoleWrite("--$iMsg" & $iMsg & @CRLF)
	If $WM_Notify_Silent=0 Then
		Switch $nID
		#region  gral
			#region credential settings
				case $TXT_credpassword
					consoleWrite("++$TXT_credpassword   WM_COMMAND  "& @CRLf)
					_ControlStateEmpty($TXT_credpassword,$btn_credshowpass)
			#endregion
			#region job console
				Case $CK_JobConsole_ConsoleQuiet
					consoleWrite("++$CK_JobConsole_ConsoleQuiet   WM_COMMAND  "& @CRLf)
					If _ischecked($CK_JobConsole_ConsoleQuiet) Then GUICtrlSetState($CK_JobConsole_Verbose,$GUI_UNCHECKED)
				Case $CK_JobConsole_Verbose
					consoleWrite("++$CK_JobConsole_Verbose   WM_COMMAND  "& @CRLf)
					If _ischecked($CK_JobConsole_Verbose) Then GUICtrlSetState($CK_JobConsole_ConsoleQuiet,$GUI_UNCHECKED)
				Case $CK_settingspref_quiet
					consoleWrite("++$CK_JobConsole_Verbose   WM_COMMAND  "& @CRLf)
					If _ischecked($CK_settingspref_quiet) Then GUICtrlSetState($CK_settingspref_verbose,$GUI_UNCHECKED)
				Case $CK_settingspref_Verbose
					consoleWrite("++$CK_JobConsole_Verbose   WM_COMMAND  "& @CRLf)
					If _ischecked($CK_settingspref_Verbose) Then GUICtrlSetState($CK_settingspref_quiet,$GUI_UNCHECKED)
			#endregion
			#region JobCreation
				case $TXT_JobCreation_jobname
;~ 					consoleWrite("++$TXT_JobCreation_jobname   WM_COMMAND  "& @CRLf)
					Switch $nNotifyCode
						Case  $EN_CHANGE
							consoleWrite("++$TXT_JobCreation_jobname   WM_COMMAND  "& @CRLf)
							$taskID=0
							GUICtrlSetData($LBL_jobcreation_tasklist,'Tasks associated to job "' & GUICtrlRead($TXT_JobCreation_jobname)& '"')
							If $listUpdateFlag=False Or _CtrlRead($TXT_JobCreation_jobname)="" then
								If GUICtrlRead($TXT_JobCreation_jobname)<>"" Then
									GUICtrlSetState($CMB_jobcreation_selecttask,$GUI_ENABLE)
									GUICtrlSetState($BTN_JobCreation_deletejob,$GUI_DISABLE)
								Else
									GUICtrlSetState($CMB_jobcreation_selecttask,$GUI_DISABLE)
									_JobCreation_disabletasks()
									ControlCommand ($JobCreationForm, "", $CMB_jobcreation_selecttask, "SelectString", " ")
								endif
								_CheckJobId()
								_FillTaskJobList()
								If _CheckJobDescription()<>"" Then
									GUICtrlSetData($TXT_JobCreation_jobdescription,_CheckJobDescription())
								endif
							Else
		;~ 						$listUpdateFlag=true
							endif
					EndSwitch
				Case $TXT_JobCreation_jobdescription
;~ 					consoleWrite("++$TXT_JobCreation_jobdescription   WM_COMMAND  "& @CRLf)
					Switch $nNotifyCode
						Case  $EN_CHANGE
;~ 							If $listUpdateFlag=False Then
								consoleWrite("++$TXT_JobCreation_jobdescription   WM_COMMAND"& @CRLf)
								_updateJobDescriptionBTN()
;~ 								$listUpdateFlag=True
;~ 							endif
;~ 							if _ExistSTRinJOBList($LST_JobCreation_JobList,_ctrlread($TXT_JobCreation_jobdescription),2)=False then
;~ 								_updateJobDescriptionBTN()
;~ 							endif
					EndSwitch
				Case $CK_JobCreation_Showjob
					consoleWrite("++$CK_JobCreation_Showjob   WM_COMMAND  "& @CRLf)
					_FillJobList()
					_JobCreation_disableJobs()
					If GUICtrlRead($TXT_JobCreation_jobdescription)<>"" Then GUICtrlSetData($TXT_JobCreation_jobdescription,"")
					If GUICtrlRead($TXT_JobCreation_jobname)<>"" Then GUICtrlSetData($TXT_JobCreation_jobname,"")
					GUICtrlSetState($BTN_jobcreation_addtask,$GUI_DISABLE)
					ControlCommand ($SettingsForm, "", $CMB_jobcreation_selecttask, "SelectString"," ")
			#endregion
			#region groups settings
				case $CMB_custselectgroup
					Switch $nNotifyCode
						Case  $CBN_SELCHANGE  ;  $CBN_CLOSEUP , $CBN_EDITUPDATE,$CBN_SELCHANGE,$CBN_EDITCHANGE ; when user types in new data
							GUICtrlSetState($BTN_custlistdeletesrv,$GUI_DISABLE)
							if _CtrlRead($CMB_custselectgroup)<>"" then
								consoleWrite("+$CMB_custselectgroup   WM_COMMAND  1"& @CRLf)
								_ControlStateEmpty(StringStripWS($CMB_custselectserver,3),$BTN_custaddcreategrp)
								if $flagCustomlistclick=1 then 	_FillCustomServersLst()
								if _GUICtrlListView_GetItemCount($LST_custsrvgrp)=0 then
;~ 									GUICtrlSetState($BTN_custdeletegroup,$GUI_DISABLE)
									GUICtrlSetState($BTN_custdeletegroup,$GUI_ENABLE)
								else
									GUICtrlSetState($BTN_custdeletegroup,$GUI_ENABLE)
								endif
	;~ 							ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $flagCustomlistclick = ' & $flagCustomlistclick & @crlf )
							else
								GUICtrlSetState($BTN_custdeletegroup,$GUI_DISABLE)
								GUICtrlSetState($BTN_custaddcreategrp,$GUI_DISABLE)
							EndIf
					EndSwitch
				case $CMB_custselectserver
					consoleWrite("++$CMB_custselectserver   WM_COMMAND  "& @CRLf)
					Switch $nNotifyCode
						Case $CBN_SELCHANGE;  $CBN_CLOSEUP , $CBN_EDITUPDATE,$CBN_SELCHANGE,$CBN_EDITCHANGE ; when user types in new data
							GUICtrlSetState($BTN_custlistdeletesrv,$GUI_DISABLE)
							if _CtrlRead($CMB_custselectserver)<>""  then
								consoleWrite("+$CMB_custselectserver   WM_COMMAND  1"& @CRLf)
								_ControlStateEmpty(StringStripWS($CMB_custselectgroup,3),$BTN_custaddcreategrp)
	;~ 							if $flagCustomlistclick=1 then 	_FillCustomServersLst()
								ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $flagCustomlistclick = ' & $flagCustomlistclick & @crlf )
							endif
						EndSwitch

				case $TXT_custsharename,$TXT_custsharepath
;~ 					consoleWrite("+$TXT_custsharename $TXT_custsharepath    WM_COMMAND  "& @CRLf)
					Switch $nNotifyCode
						Case  $EN_CHANGE
							consoleWrite("+$TXT_custsharename $TXT_custsharepath    WM_COMMAND  "& @CRLf)
							$res= _CheckCRTLRegex($TXT_custsharepath)
							if _CtrlRead($TXT_custsharename)<>"" AND $res Then
								GUICtrlSetState( $BTN_custaddshare,$GUI_ENABLE)
							Else
								GUICtrlSetState( $BTN_custaddshare,$GUI_DISABLE)
							endif
							GUICtrlSetState($BTN_custdeleteshare,$GUI_DISABLE)
					EndSwitch
			#endregion
			#region Job creation
				case $CMB_jobcreation_selecttask
;~ 					consoleWrite("++$CMB_jobcreation_selecttask   WM_COMMAND  "& @CRLf)
					$taskID=0
					Switch $nNotifyCode
						Case $CBN_SELCHANGE;$CBN_CLOSEUP ,  $CBN_EDITUPDATE,$CBN_SELCHANGE,$CBN_EDITCHANGE ; when user types in new data
							if _CtrlRead($CMB_jobcreation_selecttask)<>"" then
								consoleWrite("++$CMB_jobcreation_selecttask   WM_COMMAND  1"& @CRLf)
								GUICtrlSetState($BTN_jobcreation_addtask,$GUI_ENABLE)
							else
								GUICtrlSetState($BTN_jobcreation_addtask,$GUI_DISABLE)
							EndIf
						EndSwitch
						GUICtrlSetState($BTN_createjob_Edittask,$GUI_DISABLE)
						GUICtrlSetState($BTN_createjob_deletetask,$GUI_DISABLE)
						GUICtrlSetState($BTN_createjob_taskUp,$GUI_DISABLE)
						GUICtrlSetState($BTN_createjob_taskDown,$GUI_DISABLE)
				Case $btn_inputbox2
					consoleWrite("++$btn_inputbox2   WM_COMMAND  "& @CRLf)
					JobConsole_inputbox2Close()
			#endregion
			#region folder task creation
				Case $TXT_TaskFolderCreation_olderThan
;~ 					consoleWrite("++$TXT_TaskFolderCreation_olderThan   WM_COMMAND  "& @CRLf)
					Switch $nNotifyCode
						Case  $EN_CHANGE
							consoleWrite("++$TXT_TaskFolderCreation_olderThan   WM_COMMAND  "& @CRLf)
							If _ctrlread($TXT_TaskFolderCreation_olderThan)<0 Then GUICtrlSetData($TXT_TaskFolderCreation_olderThan,0)
							$r=_DateAdd('D',(_ctrlread($TXT_TaskFolderCreation_olderThan)*-1),_NowCalc())
							GUICtrlSetData($DT_olderThan,$r)
					EndSwitch
				case $CMB_TaskFolderCreation_SelType
;~ 					consoleWrite("++$CMB_TaskFolderCreation_SelType   WM_COMMAND  "& @CRLf)
					Switch $nNotifyCode
						Case $CBN_SELCHANGE;;$CBN_CLOSEUP , ,$CBN_EDITCHANGE , $CBN_EDITUPDATE,; when user types in new data -----------------------------
							if _CtrlRead($CMB_TaskFolderCreation_SelType)<>"" then
								consoleWrite("++$CMB_TaskFolderCreation_SelType   WM_COMMAND  1"& @CRLf)
								_Fill_CMB_TaskFolderCreation_SelType(_CtrlRead($CMB_TaskFolderCreation_SelType))
							EndIf
					EndSwitch
					if _CtrlRead($CMB_TaskFolderCreation_SelType)<>""  and _CtrlRead($CMD_TaskFolderCreation_SelServerShare)<>"" then
						GUICtrlSetState($BTN_TaskFolderCreation_AddToSourceLoc,$GUI_ENABLE)
						GUICtrlSetState($BTN_TaskFolderCreation_AddToTargetLoc,$GUI_ENABLE)
					else
						GUICtrlSetState($BTN_TaskFolderCreation_AddToSourceLoc,$GUI_DISABLE)
						GUICtrlSetState($BTN_TaskFolderCreation_AddToTargetLoc,$GUI_DISABLE)
					endif
				case $CMD_TaskFolderCreation_SelServerShare
					Switch $nNotifyCode
						Case  $CBN_SELCHANGE ; $CBN_CLOSEUP ,
						consoleWrite("++$CMD_TaskFolderCreation_SelServerShare   WM_COMMAND  "& @CRLf)
						if _CtrlRead($CMB_TaskFolderCreation_SelType)<>""  and _CtrlRead($CMD_TaskFolderCreation_SelServerShare)<>"" then
							GUICtrlSetState($BTN_TaskFolderCreation_AddToSourceLoc,$GUI_ENABLE)
							GUICtrlSetState($BTN_TaskFolderCreation_AddToTargetLoc,$GUI_ENABLE)
						else
							GUICtrlSetState($BTN_TaskFolderCreation_AddToSourceLoc,$GUI_DISABLE)
							GUICtrlSetState($BTN_TaskFolderCreation_AddToTargetLoc,$GUI_DISABLE)
						endif
						_CopyForm_OnMirror_Checks()
					EndSwitch
				case $TXT_TaskFolderCreation_SourcePath,$TXT_TaskFolderCreation_SourceZIPFilter
;~ 					consoleWrite("++$TXT_TaskFolderCreation_SourcePath , $TXT_TaskFolderCreation_SourceZIPFilter   WM_COMMAND  "& @CRLf)
					Switch $nNotifyCode
						Case  $EN_CHANGE
							consoleWrite("++$TXT_TaskFolderCreation_SourcePath , $TXT_TaskFolderCreation_SourceZIPFilter   WM_COMMAND  "&$nNotifyCode& @CRLf)
							$res= _CheckCRTLRegex($TXT_TaskFolderCreation_SourcePath)
							Select
								Case _ctrlread($CMB_jobcreation_selecttask)="Decompression Task"
									$resfilter= _CheckCRTLRegex($TXT_TaskFolderCreation_SourceZIPFilter)
									if (_CtrlRead($TXT_TaskFolderCreation_SourcePath)<>"" AND $res) And _
										(_ctrlRead($TXT_TaskFolderCreation_SourceZIPFilter)<>"" OR $resfilter) Then
										GUICtrlSetState( $BTN_TaskFolderCreation_AddSourcePath,$GUI_ENABLE)
									Else
										GUICtrlSetState( $BTN_TaskFolderCreation_AddSourcePath,$GUI_DISABLE)
									endif
								Case else
									$resfilter=_CheckCRTLRegex($TXT_TaskFolderCreation_SourceZIPFilter)
									if (_CtrlRead($TXT_TaskFolderCreation_SourcePath)<>"" AND $res) And _
										(_ctrlRead($TXT_TaskFolderCreation_SourceZIPFilter)="" OR $resfilter) Then
										GUICtrlSetState( $BTN_TaskFolderCreation_AddSourcePath,$GUI_ENABLE)
									Else
										GUICtrlSetState( $BTN_TaskFolderCreation_AddSourcePath,$GUI_DISABLE)
									endif
							endselect
							GUICtrlSetState($BTN_custdeleteshare,$GUI_DISABLE)
					EndSwitch
				case $TXT_TaskFolderCreation_TargetPath,$TXT_TaskFolderCreation_TargetPathFilter,$TXT_TaskFolderCreation_TargetZIPfilename
					Switch $nNotifyCode
						Case  $EN_CHANGE
							consoleWrite("++$TXT_TaskFolderCreation_TargetPath,$TXT_TaskFolderCreation_TargetPathFilter,$TXT_TaskFolderCreation_TargetZIPfilename WM_COMMAND  "&$nNotifyCode& @CRLf)
							If $nID=$TXT_FolderCreation_taskdesc Then $taskFormActivity=1
							_TaskFolderCreation_TargetPath_WM_COMMAND()
;~ 							_TaskFormCreation_SaveBTN()
					EndSwitch
				case $TXT_FolderCreation_taskdesc
					Switch $nNotifyCode
						Case  $EN_CHANGE
							consoleWrite("++$TXT_FolderCreation_taskdesc WM_COMMAND  "&$nNotifyCode& @CRLf)
							If $nID=$TXT_FolderCreation_taskdesc Then
								$taskFormActivity=1
								_TaskFormCreation_SaveBTN()
							endif
					EndSwitch
				Case $RD_TaskFolderCreation_ZIPsingle
					consoleWrite("++$RD_TaskFolderCreation_ZIPsingle   WM_COMMAND  "& @CRLF)
					GUICtrlSetState($TXT_TaskFolderCreation_TargetZIPfilename,$GUI_ENABLE)
					If _ctrlread($TXT_TaskFolderCreation_TargetZIPfilename)="Autonaming" Then
						GUICtrlSetData($TXT_TaskFolderCreation_TargetZIPfilename,$TXT_TaskFolderCreation_TargetZIPfilenameTEMP)
					endif
					_TaskFolderCreation_TargetPath_WM_COMMAND()
				Case $RD_TaskFolderCreation_ZIPmultiple
					consoleWrite("++$RD_TaskFolderCreation_ZIPmultiple WM_COMMAND  "& @CRLF)
					$TXT_TaskFolderCreation_TargetZIPfilenameTEMP=_ctrlread($TXT_TaskFolderCreation_TargetZIPfilename)
					ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $TXT_TaskFolderCreation_TargetZIPfilenameTEMP = ' & $TXT_TaskFolderCreation_TargetZIPfilenameTEMP & @crlf )
					GUICtrlSetData($TXT_TaskFolderCreation_TargetZIPfilename,"Autonaming")
					GUICtrlSetState($TXT_TaskFolderCreation_TargetZIPfilename,$GUI_DISABLE)
					_TaskFolderCreation_TargetPath_WM_COMMAND()
				Case $RD_TaskFolderCreation_ZIPstructure
					consoleWrite("++$RD_TaskFolderCreation_ZIPstructure   WM_COMMAND  "& @CRLF)
					GUICtrlSetState($TXT_TaskFolderCreation_TargetZIPfilename,$GUI_ENABLE)
					If _ctrlread($TXT_TaskFolderCreation_TargetZIPfilename)="Autonaming" Then
						GUICtrlSetData($TXT_TaskFolderCreation_TargetZIPfilename,$TXT_TaskFolderCreation_TargetZIPfilenameTEMP)
					endif
					_TaskFolderCreation_TargetPath_WM_COMMAND()
				Case $CMB_TaskFolderCreation_TargetCred, $CMB_TaskFolderCreation_SourceCred
					Switch $nNotifyCode
						Case $CBN_SELCHANGE;;$CBN_CLOSEUP , ,$CBN_EDITCHANGE , $CBN_EDITUPDATE,; when user types in new data -----------------------------
						consoleWrite("++$CMB_TaskFolderCreation_TargetCred  $CMB_TaskFolderCreation_SourceCred WM_COMMAND  1"& @CRLf)
						_TaskFormCreation_SaveBTN()
						$taskFormActivity=1
					EndSwitch
			#endregion
			#region Menu Main form
;~ 				Case $idNew
;~ 					consoleWrite("++Menu Main form $idNew WM_COMMAND  "& @CRLF)
;~ 				Case $idOpen
;~ 					consoleWrite("++Menu Main form $idOpen WM_COMMAND  "& @CRLF)
;~ 				Case $idSave
;~ 					consoleWrite("++Menu Main form $idSave WM_COMMAND  "& @CRLF)
;~ 				Case $idCut
;~ 					consoleWrite("++Menu Main form $idCut WM_COMMAND  "& @CRLF)
;~ 				Case $idCopy
;~ 					consoleWrite("++Menu Main form $idCopy WM_COMMAND  "& @CRLF)
;~ 				Case $idPaste
;~ 					consoleWrite("++Menu Main form $idPaste WM_COMMAND  "& @CRLF)
				Case $idAbout
					consoleWrite("++Menu Main form $idAbout WM_COMMAND  "& @CRLF)
					Menu_About_Pressed()
;~ 				case
;~ 					consoleWrite("++Menu Main form $idSettings WM_COMMAND  "& @CRLF)
;~ 					Menu_Settings_Pressed()
				case $idSettings,$idSettingsServers,$idSettingsDB,$idSettingApplications,$idSettingsCustom,$idSettingsCredentials
					consoleWrite("!++Menu Main form $idSettingsExtra tabs WM_COMMAND  "& @CRLF)
						ConsoleWrite("Selected +$nID" & $nID & @CRLF)
						Menu_Settings_Pressed($nID)
				Case $idHelp
					consoleWrite("++Menu Main form $idHelp WM_COMMAND  "& @CRLF)
					Menu_help_Pressed()
				Case $idprj
					consoleWrite("++Menu Main form $idprj WM_COMMAND  "& @CRLF)
					GUICtrlSetstate($btn_config,$GUI_disable)
					GUICtrlSetstate($btn_CreateJob,$GUI_disable)
					GUICtrlSetstate($hUpdt,$GUI_disable)
					GUICtrlSetstate($hHelp,$GUI_disable)
					GUICtrlSetstate($hFile,$GUI_disable)
;~ 					0 - Enabled
;~ 					1 - Grayed
;~ 					2 - Disabled
					_GUICtrlMenu_EnableMenuItem($hFile,0,2)
					_GUICtrlMenu_EnableMenuItem($hUpdt,0,2)
					_GUICtrlMenu_EnableMenuItem($hUpdt,1,2)
					_GUICtrlMenu_EnableMenuItem($hUpdt,2,2)
					_GUICtrlMenu_EnableMenuItem($hHelp,0,2)
					_GUICtrlMenu_EnableMenuItem($hHelp,1,2)
					Menu_CheckPrjDB_Pressed()
					GUICtrlSetstate($btn_config,$GUI_ENABLE)
					GUICtrlSetstate($btn_CreateJob,$GUI_ENABLE)
					GUICtrlSetstate($hUpdt,$GUI_ENABLE)
					GUICtrlSetstate($hHelp,$GUI_ENABLE)
					GUICtrlSetstate($hFile,$GUI_ENABLE)
					_GUICtrlMenu_EnableMenuItem($hFile,0,0)
					_GUICtrlMenu_EnableMenuItem($hUpdt,0,0)
					_GUICtrlMenu_EnableMenuItem($hUpdt,1,0)
					_GUICtrlMenu_EnableMenuItem($hUpdt,2,0)
					_GUICtrlMenu_EnableMenuItem($hHelp,0,0)
					_GUICtrlMenu_EnableMenuItem($hHelp,1,0)
				Case $idUpdate
					consoleWrite("++Menu Main form $idUpdate WM_COMMAND  "& @CRLF)
					Menu_Update_Pressed()
				Case $idCheckVersion
					consoleWrite("++Menu Main form $idCheckVersion WM_COMMAND  "& @CRLF)
					GUISetCursor(15, 1, $MainfORM)
					Sleep(1000)
					Menu_CheckVersion_Pressed()
					Sleep(1000)
					GUISetCursor(-1, 1, $MainfORM)
				Case $idExit
					Exit
				Case $CMB_DatabaseSelect
					Switch $nNotifyCode
						Case $CBN_SELCHANGE;, $CBN_EDITUPDATE;;$CBN_CLOSEUP , ,$CBN_EDITCHANGE , $CBN_EDITUPDATE,; when user types in new data -----------------------------
							consoleWrite("++$CMB_DatabaseSelect  $CBN_SELCHANGE  WM_COMMAND "& @CRLf)
							if _CtrlRead($CMB_DatabaseSelect)=_ActiveDatabaseValue() And _CtrlRead($CMB_DatabaseSelect)<>""then
								GUICtrlSetstate($LBL_setdb,$GUI_hide)
								GUICtrlSetstate($btn_CreateJob,$GUI_ENABLE)
								GUICtrlSetstate($btn_config,$GUI_ENABLE)
								GUICtrlSetstate($B_setDB,$GUI_disable)
							Else
								GUICtrlSetstate($LBL_setdb,$GUI_SHOW)
								If _CtrlRead($CMB_DatabaseSelect)="" then
									GUICtrlSetData($LBL_setdb,"No Project selected "&@crlf&"Select a Database from list")
									GUICtrlSetstate($B_setDB,$GUI_disable)
								else
									GUICtrlSetData($LBL_setdb,"Attentention , you are going to change project database")
									GUICtrlSetstate($B_setDB,$GUI_enable)
								endif
								GUICtrlSetstate($btn_CreateJob,$GUI_disable)
								GUICtrlSetstate($btn_config,$GUI_disable)
							EndIf
					EndSwitch
			#endregion
			#region Add server settings
				Case $TXT_settings_FQDN
					Switch $nNotifyCode
						Case  $EN_CHANGE
							consoleWrite("++$TXT_settings_FQDN   WM_COMMAND  "& @CRLf)
							GUICtrlSetState($LBL_Settings_DNSregistration,$GUI_HIDE)
							GUICtrlSetState($BTN_Settings_ServerRemove,$GUI_DISABLE)
							If $flagfqdn=0 Then
								_GUICtrlIpAddress_Set($IPAddress1, "0.0.0.0")
							endif
						EndSwitch
				Case $CMB_selectServerIP
					Switch $nNotifyCode
						Case $CBN_SELCHANGE;, $CBN_EDITUPDATE;;$CBN_CLOSEUP , ,$CBN_EDITCHANGE , $CBN_EDITUPDATE,; when user types in new data -----------------------------
							consoleWrite("++$CMB_selectServerIP  $CBN_SELCHANGE  WM_COMMAND "& @CRLf)
							If _IsValidIP(_CtrlRead($CMB_selectServerIP)) Then
								_GUICtrlIpAddress_set($IPAddress1,_CtrlRead($CMB_selectServerIP))
								GUICtrlSetState($LBL_Settings_DNSregistration,$GUI_HIDE)
							else
								_GUICtrlIpAddress_Set($IPAddress1, "0.0.0.0")
							EndIf
					EndSwitch
			#endregion
			#region application settings
				Case $TXT_settingspref_Repo
					Switch $nNotifyCode
						Case  $EN_CHANGE
							consoleWrite("++$TXT_settingspref_Repo   WM_COMMAND  "& @CRLf)
							if _CtrlRead($TXT_settingspref_Repo)<>"" AND _CtrlRead($TXT_settingspref_Repo)<>_GetAppSettings("RepoAddress","") Then
								GUICtrlSetstate($BTN_settingspref_repo_SaveClick,$GUI_ENABLE)
								GUICtrlSetstate($BTN_settingspref_repo_open,$GUI_ENABLE)
								GUICtrlSetBkColor($TXT_settingspref_Repo, _color("rose"))
								GUICtrlSetData($LBL_settingspref_repo_default,"...")
								$rtype=_RecognizeRepoType(_CTRLread($TXT_settingspref_Repo))
								if $rtype then
									if $rtype="local" then
										if FileExists(_CTRLread($TXT_settingspref_Repo)) then
											GUICtrlSetBkColor($TXT_settingspref_Repo, _color("rose"))
											GUICtrlSetData($LBL_settingspref_repo_default,"Local Path OK.")
										Else
											GUICtrlSetBkColor($TXT_settingspref_Repo, _color("lightRed"))
											GUICtrlSetstate($BTN_settingspref_repo_SaveClick,$GUI_DISABLE)
											GUICtrlSetstate($BTN_settingspref_repo_open,$GUI_DISABLE)
											GUICtrlSetData($LBL_settingspref_repo_default,"Local Path not found.")
										endif
									endif
									if $rtype="smb" then
										if FileExists(_CTRLread($TXT_settingspref_Repo)) then
											GUICtrlSetBkColor($TXT_settingspref_Repo, _color("rose"))
											GUICtrlSetData($LBL_settingspref_repo_default,"SMB: Address share Path OK.")
										Else
											GUICtrlSetBkColor($TXT_settingspref_Repo, _color("lightRed"))
											GUICtrlSetstate($BTN_settingspref_repo_SaveClick,$GUI_DISABLE)
											GUICtrlSetstate($BTN_settingspref_repo_open,$GUI_DISABLE)
											GUICtrlSetData($LBL_settingspref_repo_default,"SMB: share Path not found.")
										endif
									endif
									if $rtype="http" then
										GUICtrlSetBkColor($TXT_settingspref_Repo, _color("rose"))
										GUICtrlSetData($LBL_settingspref_repo_default,"Http address type OK.")
									endif
								else
									GUICtrlSetBkColor($TXT_settingspref_Repo, _color("orange"))
									GUICtrlSetstate($BTN_settingspref_repo_SaveClick,$GUI_DISABLE)
									GUICtrlSetstate($BTN_settingspref_repo_open,$GUI_DISABLE)
									GUICtrlSetData($LBL_settingspref_repo_default,"Address type not recognized.")
								endif
							Else
								GUICtrlSetstate($BTN_settingspref_repo_SaveClick,$GUI_DISABLE)
								GUICtrlSetstate($BTN_settingspref_repo_open,$GUI_DISABLE)
								GUICtrlSetBkColor($TXT_settingspref_Repo, _color("white"))
								GUICtrlSetData($LBL_settingspref_repo_default,"Address match stored.")
							endif
						EndSwitch
				Case $TXT_settingspref_Proxy
					Switch $nNotifyCode
						Case  $EN_CHANGE
							consoleWrite("++$TXT_settingspref_Proxy   WM_COMMAND  "& @CRLf)
							_CheckproxyportTXT()
					EndSwitch
				Case $TXT_settingspref_ExecutableWorkingFolder
					Switch $nNotifyCode
						Case  $EN_CHANGE
							consoleWrite("++$TXT_settingspref_ExecutableWorkingFolder   WM_COMMAND  "& @CRLf)
							if _CheckCRTLRegex($TXT_settingspref_ExecutableWorkingFolder) then
								_UpdateAppSettings("ExecutableWorkingFolder",_ctrlread($TXT_settingspref_ExecutableWorkingFolder))
								GUICtrlSetBkColor($TXT_settingspref_ExecutableWorkingFolder, _color("white"))
							Else
								GUICtrlSetBkColor($TXT_settingspref_ExecutableWorkingFolder, _color("rose"))
							endif
					EndSwitch
				Case $CMB_Proxy_Cred
					Switch $nNotifyCode
						Case $CBN_SELCHANGE   ;$CBN_CLOSEUP ,
							consoleWrite("++$CMB_Proxy_Cred   WM_COMMAND  "& @CRLf)
							_UpdateAppSettings("ProxyUser", _ctrlread($CMB_Proxy_Cred))
					EndSwitch
			#endregion
			#region Task Common
				Case $CK_TaskForms_UpdateTypesTRG
					consoleWrite("++$CK_TaskForms_UpdateTypesTRG   WM_COMMAND  "& @CRLf)
					GUICtrlSetState($BTN_TaskExecution_save, $GUI_ENABLE)
					_TaskExecution_SaveBTN()
					GUICtrlSetState($BTN_FolderCreation_save, $GUI_ENABLE)
					_TaskFormCreation_SaveBTN()
					If _IsChecked($CK_TaskForms_UpdateTypesTRG) Then
						MsgBox(48+262144,"Attention!!","Attention:!!" & @CRLF &"Servers Groups will be updated before job run and task editing."& @CRLF & _
							"Maintain Serger groups up to date.",0)
					endif
				Case $CK_TaskForms_UpdateTypesSRC
					consoleWrite("++$CK_TaskForms_UpdateTypesSRC   WM_COMMAND  "& @CRLf)
					GUICtrlSetState($BTN_TaskExecution_save, $GUI_ENABLE)
					_TaskExecution_SaveBTN()
					GUICtrlSetState($BTN_FolderCreation_save, $GUI_ENABLE)
					_TaskFormCreation_SaveBTN()
					If _IsChecked($CK_TaskForms_UpdateTypesSRC) Then
						MsgBox(48+262144,"Attention!!","Attention:!!" & @CRLF &"Servers Groups will be updated before job run and task editing."& @CRLF & _
							"Maintain Serger groups up to date.",0)
					endif
			#endregion
			#region Copy task
				Case $CMB_CopyTask_Behaviour
					Switch $nNotifyCode
						Case $CBN_SELCHANGE   ;$CBN_CLOSEUP ,
						consoleWrite("++$CMB_CopyTask_Behaviour   WM_COMMAND  "& @CRLf)
					EndSwitch
				Case $CK_CopyTask_RStructure
;~ 					consoleWrite("++$CK_CopyTask_RStructure   WM_COMMAND  "& @CRLf)
					If _ischecked($CK_CopyTask_RStructure) And Not _ischecked($CK_CopyTask_FolderPerSource) And _ischecked($RD_CopyTask_Move) then
						ControlCommand ($TasKCopyCreation, "", $CMB_CopyTask_Behaviour, "SelectString", "Rename on conflict")
						GUICtrlSetState($CMB_CopyTask_Behaviour, $GUI_DISABLE)
					Else
						GUICtrlSetState($CMB_CopyTask_Behaviour, $GUI_ENABLE)
					endif
				Case $CK_CopyTask_FolderPerSource
;~ 					consoleWrite("++$CK_CopyTask_FolderPerSource   WM_COMMAND  "& @CRLf)
					If _ischecked($CK_CopyTask_RStructure) And Not _ischecked($CK_CopyTask_FolderPerSource) And _ischecked($RD_CopyTask_Move) then
						ControlCommand ($TasKCopyCreation, "", $CMB_CopyTask_Behaviour, "SelectString", "Rename on conflict")
						GUICtrlSetState($CMB_CopyTask_Behaviour, $GUI_DISABLE)
					Else
						GUICtrlSetState($CMB_CopyTask_Behaviour, $GUI_ENABLE)
					endif
				;-------------------------------------------------------------------------------------------------
				Case $RD_CopyTask_Copy
					consoleWrite("++$RD_CopyTask_Copy   WM_COMMAND  "& @CRLf)
					GUICtrlSetState($CMB_CopyTask_Behaviour, $GUI_ENABLE)
					ControlCommand ($TasKCopyCreation, "", $CMB_CopyTask_Behaviour, "SelectString", "Overwrite")
					GUICtrlSetState($CK_CopyTask_EmptyFolders, $GUI_ENABLE)
				Case $RD_CopyTask_Move
					consoleWrite("++$RD_CopyTask_Move   WM_COMMAND  "& @CRLf)
					If _ischecked($CK_CopyTask_RStructure) And Not _ischecked($CK_CopyTask_FolderPerSource) then
						ControlCommand ($TasKCopyCreation, "", $CMB_CopyTask_Behaviour, "SelectString", "Rename on conflict")
						GUICtrlSetState($CMB_CopyTask_Behaviour, $GUI_DISABLE)
					Else
						GUICtrlSetState($CMB_CopyTask_Behaviour, $GUI_ENABLE)
					endif

					GUICtrlSetState($TXT_TaskFolderCreation_olderThan, $GUI_ENABLE)
					GUICtrlSetState($DT_olderThan, $GUI_ENABLE)

					GUICtrlSetState($TXT_TaskFolderCreation_SourceZIPFilter, $GUI_ENABLE)

					GUICtrlSetState($CK_CopyTask_RStructure, $GUI_ENABLE)
					GUICtrlSetState($CK_CopyTask_FolderPerSource, $GUI_ENABLE)

					GUICtrlSetState($CK_TaskFolderCreation_Recurse,$GUI_CHECKED)
					GUICtrlSetState($CK_TaskFolderCreation_Recurse, $GUI_ENABLE)

;~ 					GUICtrlSetState($CK_CopyTask_EmptyFolders,$GUI_CHECKED)
					GUICtrlSetState($CK_CopyTask_EmptyFolders, $GUI_ENABLE)

				Case $RD_CopyTask_Mirror
					consoleWrite("++$RD_CopyTask_Mirror   WM_COMMAND  "& @CRLf)
					MsgBox(48+4096, "Mirror", "Attention!!" & @crlf& "When Mirror selected all contents in target folder WILL BE DELETED prior copy from source!!", 0)
					ControlCommand ($TasKCopyCreation, "", $CMB_CopyTask_Behaviour, "SelectString", "Overwrite")
					GUICtrlSetState($CMB_CopyTask_Behaviour, $GUI_DISABLE)

					GUICtrlSetData($TXT_TaskFolderCreation_olderThan,"0")
					GUICtrlSetState($TXT_TaskFolderCreation_olderThan, $GUI_DISABLE)
					GUICtrlSetState($DT_olderThan, $GUI_DISABLE)

					GUICtrlSetData($TXT_TaskFolderCreation_SourceZIPFilter,"*")
					GUICtrlSetState($TXT_TaskFolderCreation_SourceZIPFilter, $GUI_DISABLE)

					GUICtrlSetState($CK_CopyTask_RStructure,$GUI_UNCHECKED)
					GUICtrlSetState($CK_CopyTask_RStructure, $GUI_DISABLE)

					GUICtrlSetState($CK_CopyTask_FolderPerSource,$GUI_UNCHECKED)
					GUICtrlSetState($CK_CopyTask_FolderPerSource, $GUI_DISABLE)

					GUICtrlSetState($CK_TaskFolderCreation_Recurse,$GUI_CHECKED)
					GUICtrlSetState($CK_TaskFolderCreation_Recurse, $GUI_DISABLE)

					GUICtrlSetState($CK_CopyTask_EmptyFolders,$GUI_CHECKED)
					GUICtrlSetState($CK_CopyTask_EmptyFolders, $GUI_DISABLE)

			#endregion
			#region Execution Task
				case $TXT_TaskExecution_taskdesc
					Switch $nNotifyCode
						Case  $EN_CHANGE
							consoleWrite("++$TXT_TaskExecution_taskdesc WM_COMMAND  "&$nNotifyCode& @CRLf)
							If $nID=$TXT_TaskExecution_taskdesc Then
								$taskFormActivity=1
								_TaskExecution_SaveBTN()
							endif
					EndSwitch
				case $TXT_TaskExecution_TargetPath
					consoleWrite("++$TXT_TaskExecution_TargetPath "& @CRLF)
					Switch $nNotifyCode
						Case  $EN_CHANGE
							If $nID=$TXT_TaskExecution_TargetPath Then
								$taskFormActivity=1
								_TaskExecution_SaveBTN()
							endif
					EndSwitch
				case $CMD_TaskExecution_SelServerShare
					Switch $nNotifyCode
						Case  $CBN_SELCHANGE ; $CBN_CLOSEUP ,
						consoleWrite("++$CMD_TaskExecution_SelServerShare   WM_COMMAND  "& @CRLf)
						if _CtrlRead($CMB_TaskExecution_SelType)<>""  and _CtrlRead($CMD_TaskExecution_SelServerShare)<>"" then
							GUICtrlSetState($BTN_TaskExecution_AddToTargetLoc,$GUI_ENABLE)
						else
							GUICtrlSetState($BTN_TaskExecution_AddToTargetLoc,$GUI_DISABLE)
						endif
					EndSwitch
				case $CMB_TaskExecution_SelType
					Switch $nNotifyCode
						Case $CBN_SELCHANGE;;$CBN_CLOSEUP , ,$CBN_EDITCHANGE , $CBN_EDITUPDATE,; when user types in new data -----------------------------
							if _CtrlRead($CMB_TaskExecution_SelType)<>"" then
								consoleWrite("++$CMB_TaskExecution_SelType   WM_COMMAND  1"& @CRLf)
								_Fill_CMB_TaskExecution_SelType(_CtrlRead($CMB_TaskExecution_SelType))
							EndIf
					EndSwitch
					if _CtrlRead($CMB_TaskExecution_SelType)<>""  and _CtrlRead($CMD_TaskExecution_SelServerShare)<>"" then
						GUICtrlSetState($BTN_TaskExecution_AddToTargetLoc,$GUI_ENABLE)
					else
						GUICtrlSetState($BTN_TaskExecution_AddToTargetLoc,$GUI_DISABLE)
					endif
				Case $CMB_TaskExecution_TargetCred
					Switch $nNotifyCode
						Case $CBN_SELCHANGE;;$CBN_CLOSEUP , ,$CBN_EDITCHANGE , $CBN_EDITUPDATE,; when user types in new data -----------------------------
							consoleWrite("++$CMB_TaskExecution_TargetCred   WM_COMMAND  1"& @CRLf)
							_TaskExecution_SaveBTN()
							$taskFormActivity=1
					EndSwitch
				Case $CMB_TaskExecution_mode
					Switch $nNotifyCode
						Case $CBN_SELCHANGE;;$CBN_CLOSEUP , ,$CBN_EDITCHANGE , $CBN_EDITUPDATE,; when user types in new data -----------------------------
							if _ctrlread($CMB_TaskExecution_mode)="Execution commands" Then
								consoleWrite("++$CMB_TaskExecution_mode   WM_COMMAND  1"& @CRLf)
								GUICtrlSetState($LBL_TaskExecution_commands, $GUI_SHOW)
								GUICtrlSetState($EDT_TaskExecution_commands, $GUI_SHOW)

								GUICtrlSetState($LBL_TaskExecution_scriptfile, $GUI_HIDE)
								GUICtrlSetState($TXT_TaskExecution_scriptfile, $GUI_HIDE)
								GUICtrlSetState($BTN_TaskExecution_scriptfile_addFile, $GUI_HIDE)
								GUICtrlSetState($BTN_TaskExecution_scriptfile_BrowseFile, $GUI_HIDE)
							Else
								consoleWrite("++$CMB_TaskExecution_mode   WM_COMMAND  2"& @CRLf)
								GUICtrlSetState($LBL_TaskExecution_commands, $GUI_HIDE)
								GUICtrlSetState($EDT_TaskExecution_commands, $GUI_HIDE)

								GUICtrlSetState($LBL_TaskExecution_scriptfile, $GUI_SHOW)
								GUICtrlSetState($TXT_TaskExecution_scriptfile, $GUI_SHOW)
								GUICtrlSetState($BTN_TaskExecution_scriptfile_addFile, $GUI_SHOW)
								GUICtrlSetState($BTN_TaskExecution_scriptfile_BrowseFile, $GUI_SHOW)
							endif
							_TaskExecution_SaveBTN()
						EndSwitch
				case $EDT_TaskExecution_commands
					Switch $nNotifyCode
						Case  $EN_CHANGE
							consoleWrite("++$EDT_TaskExecution_commands WM_COMMAND  "&$nNotifyCode& @CRLf)
							$taskFormActivity=1
							_TaskExecution_SaveBTN()
					EndSwitch
			#endregion
			#region Deploy Agent Task
				case $TXT_TaskDeployAgent_taskdesc
					Switch $nNotifyCode
						Case  $EN_CHANGE
							consoleWrite("++$TXT_TaskDeployAgent_taskdesc WM_COMMAND  "&$nNotifyCode& @CRLf)
							If $nID=$TXT_TaskDeployAgent_taskdesc Then
								$taskFormActivity=1
								_TaskDeployAgent_SaveBTN()
							endif
					EndSwitch
				case $CMD_TaskDeployAgent_SelServerShare
					Switch $nNotifyCode
						Case  $CBN_SELCHANGE ; $CBN_CLOSEUP ,
						consoleWrite("++$CMD_TaskDeployAgent_SelServerShare   WM_COMMAND  "& @CRLf)
						if _CtrlRead($CMB_TaskDeployAgent_SelType)<>""  and _CtrlRead($CMD_TaskDeployAgent_SelServerShare)<>"" then
							GUICtrlSetState($BTN_TaskDeployAgent_AddToTargetLoc,$GUI_ENABLE)
						else
							GUICtrlSetState($BTN_TaskDeployAgent_AddToTargetLoc,$GUI_DISABLE)
						endif
					EndSwitch
				case $CMB_TaskDeployAgent_SelType
					Switch $nNotifyCode
						Case $CBN_SELCHANGE;;$CBN_CLOSEUP , ,$CBN_EDITCHANGE , $CBN_EDITUPDATE,; when user types in new data -----------------------------
							if _CtrlRead($CMB_TaskDeployAgent_SelType)<>"" then
								consoleWrite("++$CMB_TaskDeployAgent_SelType   WM_COMMAND  1"& @CRLf)
								_Fill_CMB_TaskDeployAgent_SelType(_CtrlRead($CMB_TaskDeployAgent_SelType))
							EndIf
					EndSwitch
					if _CtrlRead($CMB_TaskDeployAgent_SelType)<>""  and _CtrlRead($CMD_TaskDeployAgent_SelServerShare)<>"" then
						GUICtrlSetState($BTN_TaskDeployAgent_AddToTargetLoc,$GUI_ENABLE)
					else
						GUICtrlSetState($BTN_TaskDeployAgent_AddToTargetLoc,$GUI_DISABLE)
					endif
				Case $RD_TaskDeployAgent_Install, $RD_TaskDeployAgent_Uninstall
					consoleWrite("++$RD_TaskDeployAgent_Install  $RD_TaskDeployAgent_Uninstall   WM_COMMAND  "& @CRLF)
					_TaskDeployAgent_SaveBTN()
					$taskFormActivity=1
				Case $CMB_TaskDeployAgent_TargetCred
					Switch $nNotifyCode
						Case $CBN_SELCHANGE;;$CBN_CLOSEUP , ,$CBN_EDITCHANGE , $CBN_EDITUPDATE,; when user types in new data -----------------------------
						consoleWrite("++$CMB_TaskDeployAgent_TargetCred   WM_COMMAND  1"& @CRLf)
						_TaskDeployAgent_SaveBTN()
						$taskFormActivity=1
					EndSwitch
			#endregion
		#endregion
		EndSwitch
	endif
EndFunc
Func _HiWord($x)
    Return BitShift($x, 16)
EndFunc
Func _LoWord($x)
    Return BitAND($x, 0xFFFF)
EndFunc
#region wm_command  helpers
	Func _TaskFolderCreation_TargetPath_WM_COMMAND()
		ConsoleWrite('++TaskFolderCreation_TargetPath_WM_COMMAND() = '& @crlf)
		$res= _CheckCRTLRegex($TXT_TaskFolderCreation_TargetPath)
		$resfilter= _CheckCRTLRegex($TXT_TaskFolderCreation_TargetPathFilter)
		$resZIPfile= _CheckCRTLRegex($TXT_TaskFolderCreation_TargetZIPfilename)

		if (_ctrlRead($TXT_TaskFolderCreation_TargetPath)<>"" And $res) AND _
			(_ctrlRead($TXT_TaskFolderCreation_TargetPathFilter)="" OR $resfilter)And _
			($TXT_TaskFolderCreation_TargetZIPfilename=0 Or _ctrlRead($TXT_TaskFolderCreation_TargetZIPfilename)="Autonaming" OR $resZIPfile)  Then
			GUICtrlSetState( $BTN_TaskFolderCreation_AddTargetPath,$GUI_ENABLE)
		Else
			GUICtrlSetState( $BTN_TaskFolderCreation_AddTargetPath,$GUI_DISABLE)
		endif
		GUICtrlSetState($BTN_custdeleteshare,$GUI_DISABLE)
	EndFunc
#endregion













