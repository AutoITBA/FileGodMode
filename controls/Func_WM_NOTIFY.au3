Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)  ; Handle WM_NOTIFY messages  en lists, combos
    Local $nID = _LoWord($iwParam)
;~ 	ConsoleWrite("+WM_NsOTIFY="&$nID& @CRLf)
    Local $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
;~     Local $hWndFrom = DllStructGetData($tNMHDR, "hWndFrom")
    Local $nNotifyCode = DllStructGetData($tNMHDR, "Code")
;~ 	Local $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	If $WM_Notify_Silent=0 Then
		Switch $nID
			#region settings form lists
				Case $LST_CredManage
		;~ 			ConsoleWrite("+$LST_CredManage"& " WM_NOTIFY" & @CRLf)
					Switch $nNotifyCode
						Case $LVN_ITEMCHANGED
							If _GUICtrlListView_GetSelectedCount($LST_CredManage)=1 Then
								consoleWrite("+$NM_CLICK   +$LST_CredManage ,$LVN_ITEMCHANGED   WM_NOTIFY  "& @CRLf)
								$lineValues=_GUICtrlListView_GetItemTextArray($LST_CredManage)
								GUICtrlSetData($TXT_creddomain,$lineValues[1])
								GUICtrlSetData($TXT_creduser,$lineValues[2])
								GUICtrlSetData($TXT_credpassword,_Hashing($lineValues[3],1))
								$flagCredShow=1
								BTN_credshowpassClick()
							endif
						Case -108 ;$NM_CLICK
							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_CredManage   WM_NOTIFY  "& @CRLf)
		;~ 					$bSet = 0
		;~ 					$nCurCol = $nCol
		;~ 					GUICtrlSendMsg($LST_CredManage, $LVM_SETSELECTEDCOLUMN, GUICtrlGetState($LST_CredManage), 0)
		;~ 					DllCall("user32.dll", "int", "InvalidateRect", "hwnd", GUICtrlGetHandle($LST_CredManage), "int", 0, "int", 1)
						Case $NM_DBLCLK
							ConsoleWrite("+$NM_DBLCLK"& @CRLf)
						case $NM_RCLICK
							consoleWrite("+$NM_RCLICK   +$LST_CredManage   WM_NOTIFY  "& @CRLf)
							ShowMenuAtMouse($SettingsForm, $LST_CredManage, $contextmenu_list)
					EndSwitch
				Case $LST_custsrvgrp
		;~ 			ConsoleWrite("+$LST_CredManage"& " WM_NOTIFY" & @CRLf)
					Switch $nNotifyCode
						Case $LVN_ITEMCHANGED ;$NM_CLICK
							$flagCustomlistclick=0
							If _GUICtrlListView_GetSelectedCount($LST_custsrvgrp)=1 Then
								consoleWrite("+$NM_CLICK   +$LST_custsrvgrp   WM_NOTIFY  "& @CRLf)
								$lineValues=_GUICtrlListView_GetItemTextArray($LST_custsrvgrp)
								ControlCommand ($SettingsForm, "", $CMB_custselectgroup, "SelectString", $lineValues[1])
								ControlCommand ($SettingsForm, "", $CMB_custselectserver, "SelectString", $lineValues[2])
								GUICtrlSetState($BTN_custlistdeletesrv,$GUI_ENABLE)
								consoleWrite("+$NM_CLICK   +$LST_custsrvgrp   WM_NOTIFY 1 "& @CRLf)
							Else
								GUICtrlSetState($BTN_custlistdeletesrv,$GUI_DISABLE)
							endif
							$flagCustomlistclick=1
						Case -108 ;$NM_CLICK
							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_custsrvgrp   WM_NOTIFY  "& @CRLf)
							_SortControl_WM_NOTIFY($LST_JobCreation_JobList)
						Case $NM_DBLCLK
							ConsoleWrite("+$NM_DBLCLK"& @CRLf)
						case $NM_RCLICK
							consoleWrite("+$NM_RCLICK   +$LST_custsrvgrp   WM_NOTIFY  "& @CRLf)
							ShowMenuAtMouse($SettingsForm, $LST_custsrvgrp, $contextmenu_list)
					EndSwitch
				Case $LST_custshare
		;~ 			ConsoleWrite("+$LST_CredManage"& " WM_NOTIFY" & @CRLf)
					Switch $nNotifyCode
						Case $NM_CLICK,$LVN_ITEMCHANGED
							consoleWrite("+$NM_CLICK   +$LST_custshare   WM_NOTIFY  "& @CRLf)
							If _GUICtrlListView_GetSelectedCount($LST_custshare)=1 Then
								$lineValues=_GUICtrlListView_GetItemTextArray($LST_custshare)
								GUICtrlSetData($TXT_custsharename,$lineValues[1])
								GUICtrlSetData($TXT_custsharepath,$lineValues[2])
								GUICtrlSetState($BTN_custdeleteshare,$GUI_ENABLE)
							Else
								GUICtrlSetState($BTN_custdeleteshare,$GUI_DISABLE)
								GUICtrlSetData($TXT_custsharename,"")
								GUICtrlSetData($TXT_custsharepath,"")
							endif
						Case -108 ;$NM_CLICK
							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_custshare   WM_NOTIFY  "& @CRLf)
							_SortControl_WM_NOTIFY($LST_JobCreation_JobList)
						Case $NM_DBLCLK
							ConsoleWrite("+$NM_DBLCLK"& @CRLf)
						case $NM_RCLICK
							consoleWrite("+$NM_RCLICK   +$LST_custshare   WM_NOTIFY  "& @CRLf)
							ShowMenuAtMouse($SettingsForm, $LST_custshare, $contextmenu_list)
					EndSwitch
				Case $LST_settings_serversAdd
					Switch $nNotifyCode
						Case $LVN_ITEMCHANGED
							If _GUICtrlListView_GetSelectedCount($LST_settings_serversAdd)=1 Then
								consoleWrite("+$NM_CLICK   +$LST_settings_serversAdd   WM_NOTIFY  "& @CRLf)
								$lineValues=_GUICtrlListView_GetItemTextArray($LST_settings_serversAdd)
								GUICtrlSetData($TXT_settings_FQDN,$lineValues[1])
								_GUICtrlIpAddress_Set($IPAddress1, "0.0.0.0")
								If $lineValues[4]="yes" Or $lineValues[5]="No" then
									GUICtrlSetState($BTN_Settings_ServerRemove,$GUI_ENABLE)
								Else
									GUICtrlSetState($BTN_Settings_ServerRemove,$GUI_DISABLE)
								endif
							Else
								GUICtrlSetState($BTN_Settings_ServerRemove,$GUI_DISABLE)
								GUICtrlSetData($TXT_settings_FQDN,"")
							endif
						Case -108 ;$NM_CLICK
							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_settings_serversAdd   WM_NOTIFY  "& @CRLf)
							_SortControl_WM_NOTIFY($LST_settings_serversAdd)
						Case $NM_DBLCLK
							ConsoleWrite("+$NM_DBLCLK"& @CRLf)
						case $NM_RCLICK
							consoleWrite("+$NM_RCLICK   +$LST_settings_serversAdd   WM_NOTIFY  "& @CRLf)
							ShowMenuAtMouse($SettingsForm, $LST_settings_serversAdd, $contextmenu_list)
	;~ 					Case $LVN_ITEMCHANGING
	;~ 						ConsoleWrite("+$LVN_ITEMCHANGING"& @CRLf)
				EndSwitch
				Case $LST_importExport_ExportJoblist
					Switch $nNotifyCode
						Case $LVN_ITEMCHANGED
							consoleWrite("+$NM_CLICK   +$LST_importExport_ExportJoblist   WM_NOTIFY  "& @CRLf)
							$exportfile=_CTRLread($TXT_importExport_fileExport)
							$exportfileDIR=GetDir($exportfile)
							If $exportfileDIR<>"" Then
								If FileExists($exportfileDIR) And _HasLSTCheckBoxCheched($LST_importExport_ExportJoblist) Then
									GUICtrlSetstate($BTN_importExport_Export,$GUI_ENABLE)
								Else
									GUICtrlSetstate($BTN_importExport_Export,$GUI_DISABLE)
								endif
							endif
						Case -108 ;$NM_CLICK
							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_importExport_ExportJoblist   WM_NOTIFY  "& @CRLf)
						Case $NM_DBLCLK
							ConsoleWrite("+$NM_DBLCLK"& @CRLf)
	;~ 					Case $LVN_ITEMCHANGING
	;~ 						ConsoleWrite("+$LVN_ITEMCHANGING"& @CRLf)
				EndSwitch
			#endregion
			#region task creation form lists
				Case $LST_TaskFolderCreation_TargetLoc
					Switch $nNotifyCode
						Case $LVN_ITEMCHANGED
							consoleWrite("+$NM_CLICK   +$LST_TaskFolderCreation_TargetLoc   WM_NOTIFY  "& @CRLf)
							If _GUICtrlListView_GetSelectedCount($LST_TaskFolderCreation_TargetLoc)>0 Then
								GUICtrlSetState($BTN_TaskFolderCreation_DeleteTargetLoc,$GUI_ENABLE)
							Else
								GUICtrlSetState($BTN_TaskFolderCreation_DeleteTargetLoc,$GUI_DISABLE)
							endif
							_TaskFormCreation_SaveBTN()
						Case -108 ;$NM_CLICK
							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_TaskFolderCreation_TargetLoc   WM_NOTIFY  "& @CRLf)
							_SortControl_WM_NOTIFY($LST_TaskFolderCreation_TargetLoc)
						Case $NM_DBLCLK
							ConsoleWrite("+$NM_DBLCLK"& @CRLf)
						case $NM_RCLICK
							consoleWrite("+$NM_RCLICK   +$LST_TaskFolderCreation_TargetLoc   WM_NOTIFY $task= "&$task& @CRLf)
							if $task="Copy Task" then
								ShowMenuAtMouse($TasKCopyCreation, $LST_TaskFolderCreation_TargetLoc, $contextmenu_list)
							ELSE
								ShowMenuAtMouse($TaskFolderCreation, $LST_TaskFolderCreation_TargetLoc, $contextmenu_list)
							ENDIF
					EndSwitch
				Case $LST_TaskFolderCreation_SourceLoc
					Switch $nNotifyCode
						Case $LVN_ITEMCHANGED
							consoleWrite("+$NM_CLICK   +$LST_TaskFolderCreation_SourceLoc   WM_NOTIFY  "& @CRLf)
							If _GUICtrlListView_GetSelectedCount($LST_TaskFolderCreation_SourceLoc)>0 Then
								GUICtrlSetState($BTN_TaskFolderCreation_DeleteSourceLoc,$GUI_ENABLE)
							Else
								GUICtrlSetState($BTN_TaskFolderCreation_DeleteSourceLoc,$GUI_DISABLE)
							endif
							_TaskFormCreation_SaveBTN()
						Case -108 ;$NM_CLICK
							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_TaskFolderCreation_SourceLoc   WM_NOTIFY  "& @CRLf)
							_SortControl_WM_NOTIFY($LST_TaskFolderCreation_SourceLoc)
						Case $NM_DBLCLK
							ConsoleWrite("+$NM_DBLCLK"& @CRLf)
						case $NM_RCLICK
							consoleWrite("+$NM_RCLICK   +$LST_TaskFolderCreation_SourceLoc   WM_NOTIFY $task= "&$task& @CRLf)
							if $task="Copy Task" then
								ShowMenuAtMouse($TasKCopyCreation, $LST_TaskFolderCreation_SourceLoc, $contextmenu_list)
							ELSE
								ShowMenuAtMouse($TaskFolderCreation, $LST_TaskFolderCreation_SourceLoc, $contextmenu_list)
							ENDIF
					EndSwitch
				Case $LST_TaskFolderCreation_SourcePaths
					Switch $nNotifyCode
						Case $LVN_ITEMCHANGED
							consoleWrite("+$NM_CLICK   +$LST_TaskFolderCreation_SourcePaths   WM_NOTIFY  "& @CRLf)
							If _GUICtrlListView_GetSelectedCount($LST_TaskFolderCreation_SourcePaths)>0 Then
								GUICtrlSetState($BTN_TaskFolderCreation_DeleteSourcePath,$GUI_ENABLE)
								$lineValues=_GUICtrlListView_GetItemTextArray($LST_TaskFolderCreation_SourcePaths)
								GUICtrlSetData($TXT_TaskFolderCreation_SourcePath,StringStripWS($lineValues[1],3))
	;~ 							$sTitle = WinGetTitle("[active]")
								$sTitle = _ctrlread($CMB_jobcreation_selecttask)
								If $sTitle="Compression Task" Or $sTitle="Copy Task"  Then
									GUICtrlSetState($RD_CopyTask_Copy,$GUI_CHECKED)
									GUICtrlSetState($CK_TaskFolderCreation_Recurse,$GUI_UNCHECKED)
									GUICtrlSetState($RD_CopyTask_Mirror,$GUI_UNCHECKED)
									GUICtrlSetState($RD_CopyTask_Move,$GUI_UNCHECKED)

									If StringInStr($lineValues[2],"[R]")>0 Then
										GUICtrlSetState($CK_TaskFolderCreation_Recurse,$GUI_CHECKED)
									endif
									Select
										Case StringInStr($lineValues[2],"[M]")>0
											GUICtrlSetState($RD_CopyTask_Mirror,$GUI_CHECKED)
											GUICtrlSetState($RD_CopyTask_Copy,$GUI_UNCHECKED)
										Case StringInStr($lineValues[2],"[MV]")>0
											GUICtrlSetState($RD_CopyTask_Move,$GUI_CHECKED)
											GUICtrlSetState($RD_CopyTask_Copy,$GUI_UNCHECKED)
										Case Else
											GUICtrlSetState($RD_CopyTask_Copy,$GUI_CHECKED)
									EndSelect
									GUICtrlSetData($TXT_TaskFolderCreation_olderThan,0)
									$l=$lineValues[2]
									If StringInStr($l,"[")>0 Then
										$in=StringInStr($l,"[")
										$en=StringInStr($l,"]")
										$olderday=StringMid($l,$in+1,$en-$in-1)
										If Int($olderday)>0 Then GUICtrlSetData($TXT_TaskFolderCreation_olderThan,$olderday)
										$l=StringMid($l,1,$in-1)
									endif
									GUICtrlSetData($TXT_TaskFolderCreation_SourceZIPFilter,StringStripWS($l,3))
								endif
								_CopyForm_OnMirror_Checks()
							Else
								GUICtrlSetState($BTN_TaskFolderCreation_DeleteSourcePath,$GUI_DISABLE)
							endif
							_TaskFormCreation_SaveBTN()
						Case -108 ;$NM_CLICK
							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_TaskFolderCreation_SourcePaths   WM_NOTIFY  "& @CRLf)
							_SortControl_WM_NOTIFY($LST_TaskFolderCreation_SourcePaths)
						Case $NM_DBLCLK
							ConsoleWrite("!+$NM_DBLCLK"& @CRLf)
						case $NM_RCLICK
							consoleWrite("+$NM_RCLICK   +$LST_TaskFolderCreation_SourcePaths   WM_NOTIFY $task= "&$task& @CRLf)
							if $task="Copy Task" then
								ShowMenuAtMouse($TasKCopyCreation, $LST_TaskFolderCreation_SourcePaths, $contextmenu_list)
							ELSE
								ShowMenuAtMouse($TaskFolderCreation, $LST_TaskFolderCreation_SourcePaths, $contextmenu_list)
							ENDIF
					EndSwitch
				Case $LST_TaskFolderCreation_TargetPaths
					Switch $nNotifyCode
						Case $LVN_ITEMCHANGED
							consoleWrite("+$NM_CLICK   +$LST_TaskFolderCreation_TargetPaths   WM_NOTIFY  "& @CRLf)
							If _GUICtrlListView_GetSelectedCount($LST_TaskFolderCreation_TargetPaths)>0 Then
	;~ 							$sTitle = WinGetTitle("[active]")
								$sTitle = _ctrlread($CMB_jobcreation_selecttask)
								GUICtrlSetState($BTN_TaskFolderCreation_DeleteTargetPath,$GUI_ENABLE)
								$lineValues=_GUICtrlListView_GetItemTextArray($LST_TaskFolderCreation_TargetPaths)
								GUICtrlSetData($TXT_TaskFolderCreation_TargetPath,StringStripWS($lineValues[1],3))
								If UBound($lineValues)>2 Then
									GUICtrlSetData($TXT_TaskFolderCreation_TargetPathFilter,StringStripWS($lineValues[2],3))
									Switch $sTitle
										Case "Compression Task"
											GUICtrlSetState($RD_TaskFolderCreation_ZIPsingle, $GUI_UNCHECKED)
											GUICtrlSetState($RD_TaskFolderCreation_ZIPMultiple, $GUI_UNCHECKED)
											GUICtrlSetState($RD_TaskFolderCreation_ZIPstructure, $GUI_UNCHECKED)
											GUICtrlSetState($CK_TaskFolderCreation_DeleteZip,$GUI_UNCHECKED)
											GUICtrlSetState($CK_TaskFolderCreation_AutoRenameZip,$GUI_UNCHECKED)
											GUICtrlSetState($CK_TaskFolderCreation_ServerFolderZip,$GUI_UNCHECKED)
											GUICtrlSetState($CK_TaskFolderCreation_ServerFolderInsideZip,$GUI_UNCHECKED)

											$newf=StringReplace($lineValues[2],"[NS]","")
											$newf=StringReplace($newf,"[D]","")
											$newf=StringReplace($newf,"[A]","")
											$newf=StringReplace($newf,"[S]","")
											$newf=StringReplace($newf,"[FS]","")
											GUICtrlSetData($TXT_TaskFolderCreation_TargetZIPfilename,StringStripWS($newf,3))

											if StringInStr($lineValues[2],"Autonaming")>0 then
												GUICtrlSetState($TXT_TaskFolderCreation_TargetZIPfilename,$GUI_DISABLE)
												GUICtrlSetState($RD_TaskFolderCreation_ZIPmultiple, $GUI_CHECKED)
											else
												GUICtrlSetState($TXT_TaskFolderCreation_TargetZIPfilename,$GUI_ENABLE)
											Endif

											if StringInStr($lineValues[2],"Autonaming")=0 then
												if StringInStr($lineValues[2],"[NS]")>0 then
													GUICtrlSetState($RD_TaskFolderCreation_ZIPsingle, $GUI_CHECKED)
												Else
													GUICtrlSetState($RD_TaskFolderCreation_ZIPstructure, $GUI_CHECKED)
												endif
											endif

											if StringInStr($lineValues[2],"[D]")>0 then
												GUICtrlSetState($CK_TaskFolderCreation_DeleteZip,$GUI_CHECKED)
											endif

											if StringInStr($lineValues[2],"[A]")>0 then
												GUICtrlSetState($CK_TaskFolderCreation_AutoRenameZip,$GUI_CHECKED)
											endif

											if StringInStr($lineValues[2],"[S]")>0 then
												GUICtrlSetState($CK_TaskFolderCreation_ServerFolderZip,$GUI_CHECKED)
											endif

											if StringInStr($lineValues[2],"[FS]")>0 then
												GUICtrlSetState($CK_TaskFolderCreation_ServerFolderInsideZip,$GUI_CHECKED)
											endif

										Case "Decompression Task"
											If $lineValues[2]="Autorename" Then
												GUICtrlSetState($RD_TaskFolderCreation_ZIPAutorename, $GUI_CHECKED)
											Else
												GUICtrlSetState($RD_TaskFolderCreation_ZIPOverwrite, $GUI_CHECKED)
											endif
										Case "Deletion Task"
											If StringInStr($lineValues[2],"[R]")>0 Then
												GUICtrlSetState($CK_TaskFolderCreation_Recurse,$GUI_CHECKED)
											Else
												GUICtrlSetState($CK_TaskFolderCreation_Recurse,$GUI_UNCHECKED)
											endif
											$l=StringReplace($lineValues[2],"[R]","")
											If StringInStr($l,"[")>0 Then
												$in=StringInStr($l,"[")
												$en=StringInStr($l,"]")
												$olderday=StringStripWS(StringMid($l,$in+1,$en-$in-1),3)
												GUICtrlSetData($TXT_TaskFolderCreation_olderThan,$olderday)
												$l=StringStripWS(StringMid($l,1,$in-1),3)
											endif
											GUICtrlSetData($TXT_TaskFolderCreation_TargetPathFilter,$l)
										Case "Copy Task"
											GUICtrlSetState($CK_CopyTask_RStructure, $GUI_UNCHECKED)
											If StringInStr($lineValues[2],"[NS]")>0 Then GUICtrlSetState($CK_CopyTask_RStructure,$GUI_CHECKED)
											GUICtrlSetState($CK_CopyTask_FolderPerSource, $GUI_UNCHECKED)
											If  StringInStr($lineValues[2],"[OF]")>0 Then GUICtrlSetState($CK_CopyTask_FolderPerSource,$GUI_CHECKED)
											GUICtrlSetState($CK_CopyTask_EmptyFolders, $GUI_UNCHECKED)
											If  StringInStr($lineValues[2],"[EF]")>0 Then GUICtrlSetState($CK_CopyTask_EmptyFolders,$GUI_CHECKED)
											$CopyTBehaviour=""
											$ps=StringInStr($lineValues[2],"[")
											If $ps=0 Then $ps=StringLen($lineValues[2])+1
											Switch StringMid($lineValues[2],1,$ps-1)
												Case "Overwrite"
													$CopyTBehaviour="Overwrite"
												Case "Skip"
													$CopyTBehaviour="Skip on conflict"
												Case "Rename"
													$CopyTBehaviour="Rename on conflict"
												Case "Prompt"
													$CopyTBehaviour="Prompt user on conflict"
											EndSwitch
											ControlCommand ($TasKCopyCreation, "", $CMB_CopyTask_Behaviour, "SelectString", $CopyTBehaviour)
									EndSwitch
								endif
							Else
								GUICtrlSetState($BTN_TaskFolderCreation_DeleteTargetPath,$GUI_DISABLE)
							endif
							_TaskFormCreation_SaveBTN()
						Case -108 ;$NM_CLICK
							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_TaskFolderCreation_TargetPaths   WM_NOTIFY  "& @CRLf)
							_SortControl_WM_NOTIFY($LST_TaskFolderCreation_TargetPaths)
						Case $NM_DBLCLK
							ConsoleWrite("+$NM_DBLCLK"& @CRLf)
						case $NM_RCLICK
							consoleWrite("+$NM_RCLICK   +$LST_TaskFolderCreation_TargetPaths   WM_NOTIFY $task= "&$task& @CRLf)
							if $task="Copy Task" then
								ShowMenuAtMouse($TasKCopyCreation, $LST_TaskFolderCreation_TargetPaths, $contextmenu_list)
							ELSE
								ShowMenuAtMouse($TaskFolderCreation, $LST_TaskFolderCreation_TargetPaths, $contextmenu_list)
							ENDIF
					EndSwitch
			#endregion
			#region Execute form task
				Case $LST_TaskExecution_TargetLoc
					Switch $nNotifyCode
						Case $LVN_ITEMCHANGED
							consoleWrite("+$NM_CLICK   +$LST_TaskExecution_TargetLoc   WM_NOTIFY  "& @CRLf)
							If _GUICtrlListView_GetSelectedCount($LST_TaskExecution_TargetLoc)>0 Then
								GUICtrlSetState($BTN_TaskExecution_DeleteTargetLoc,$GUI_ENABLE)
							Else
								GUICtrlSetState($BTN_TaskExecution_DeleteTargetLoc,$GUI_DISABLE)
							endif
							_TaskExecution_SaveBTN()
						Case -108 ;$NM_CLICK
							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_TaskExecution_TargetLoc   WM_NOTIFY  "& @CRLf)
							$bSet = 0
							$nCurCol = $nCol
							GUICtrlSendMsg($LST_TaskExecution_TargetLoc, $LVM_SETSELECTEDCOLUMN, GUICtrlGetState($LST_TaskExecution_TargetLoc), 0)
							DllCall("user32.dll", "int", "InvalidateRect", "hwnd", GUICtrlGetHandle($LST_TaskExecution_TargetLoc), "int", 0, "int", 1)
						Case $NM_DBLCLK
							ConsoleWrite("+$NM_DBLCLK"& @CRLf)
						case $NM_RCLICK
							consoleWrite("+$NM_RCLICK   +$LST_TaskExecution_TargetLoc   WM_NOTIFY  "& @CRLf)
							ShowMenuAtMouse($TaskExecutionForm, $LST_TaskExecution_TargetLoc, $contextmenu_list)
					EndSwitch
				Case $LST_TaskExecution_extraFiles
					Switch $nNotifyCode
						Case $LVN_ITEMCHANGED
;~ 							consoleWrite("+$NM_CLICK   +$LST_TaskExecution_TargetLoc   WM_NOTIFY  "& @CRLf)
						Case -108 ;$NM_CLICK
;~ 							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_TaskExecution_extraFiles   WM_NOTIFY  "& @CRLf)
;~ 							$bSet = 0
;~ 							$nCurCol = $nCol
;~ 							GUICtrlSendMsg($LST_TaskExecution_extraFiles, $LVM_SETSELECTEDCOLUMN, GUICtrlGetState($LST_TaskExecution_extraFiles), 0)
;~ 							DllCall("user32.dll", "int", "InvalidateRect", "hwnd", GUICtrlGetHandle($LST_TaskExecution_extraFiles), "int", 0, "int", 1)
						Case $NM_DBLCLK
;~ 							consoleWrite("+$NM_DBLCLK   +$LST_TaskExecution_extraFiles   WM_NOTIFY  "& @CRLf)
						case $NM_RCLICK
							consoleWrite("+$NM_RCLICK   +$LST_TaskExecution_extraFiles   WM_NOTIFY  "& @CRLf)
							ShowMenuAtMouse($TaskExecutionForm, $LST_TaskExecution_extraFiles, $contextmenu_list)
					EndSwitch
			#endregion
			#region Deploy Agent form task
				Case $LST_TaskDeployAgent_TargetLoc
					Switch $nNotifyCode
						Case $LVN_ITEMCHANGED
							consoleWrite("+$NM_CLICK   +$LST_TaskDeployAgent_TargetLoc   WM_NOTIFY  "& @CRLf)
							If _GUICtrlListView_GetSelectedCount($LST_TaskDeployAgent_TargetLoc)>0 Then
								GUICtrlSetState($BTN_TaskDeployAgent_DeleteTargetLoc,$GUI_ENABLE)
							Else
								GUICtrlSetState($BTN_TaskDeployAgent_DeleteTargetLoc,$GUI_DISABLE)
							endif
	;~ 						_TaskDeployAgent_SaveBTN()
						Case -108 ;$NM_CLICK
							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_TaskDeployAgent_TargetLoc   WM_NOTIFY  "& @CRLf)
							$bSet = 0
							$nCurCol = $nCol
							GUICtrlSendMsg($LST_TaskDeployAgent_TargetLoc, $LVM_SETSELECTEDCOLUMN, GUICtrlGetState($LST_TaskDeployAgent_TargetLoc), 0)
							DllCall("user32.dll", "int", "InvalidateRect", "hwnd", GUICtrlGetHandle($LST_TaskDeployAgent_TargetLoc), "int", 0, "int", 1)
						Case $NM_DBLCLK
							ConsoleWrite("+$NM_DBLCLK"& @CRLf)
					EndSwitch
			#endregion
			#region  JOB Form lists
				Case $LST_JobCreation_JobList
					Switch $nNotifyCode
						Case $NM_CLICK,$LVN_ITEMCHANGED
							consoleWrite("+$NM_CLICK   +$LST_JobCreation_JobList   WM_NOTIFY  "& @CRLf)
							$taskID=0
							if $listLoop=1 then
								if $listUpdateFlag=False then
									If _GUICtrlListView_GetSelectedCount($LST_JobCreation_JobList)=1 Then
										$listUpdateFlag=True
;~ 										sleep(50)
										$lineIndexs=_GUICtrlListView_GetSelectedIndices($LST_JobCreation_JobList,true)
										_printfromarray($lineIndexs,"index")
										$lineValues=_GUICtrlListView_GetItemTextArray($LST_JobCreation_JobList)
										_printfromarray($lineValues,"values")
										GUICtrlSetData($TXT_JobCreation_jobname,$lineValues[1])
										GUICtrlSetData($TXT_JobCreation_jobdescription,$lineValues[2])
										_CheckJobId()
										_FillTaskJobList()
										_JobCreation_EnableJobs()
										GUICtrlSetState($CMB_jobcreation_selecttask,$GUI_ENABLE)
											If $lineValues[3]="Yes" Then
												GUICtrlSetdata($BTN_JobCreation_Archivejob,"      Restore Job")
											Else
												GUICtrlSetdata($BTN_JobCreation_Archivejob,"      Archive Job")
											endif
										;_GUICtrlListView_SetItemSelected($LST_JobCreation_JobList,$lineIndexs[1])
										_GUICtrlListView_SetHotItem($LST_JobCreation_JobList,$lineIndexs[1])
										$listUpdateFlag=false
									Else
										If GUICtrlRead($TXT_JobCreation_jobdescription)<>"" Then GUICtrlSetData($TXT_JobCreation_jobdescription,"")
										If GUICtrlRead($TXT_JobCreation_jobname)<>"" Then GUICtrlSetData($TXT_JobCreation_jobname,"")
										_JobCreation_disableJobs()
										GUICtrlSetState($BTN_jobcreation_addtask,$GUI_DISABLE)
										ControlCommand ($SettingsForm, "", $CMB_jobcreation_selecttask, "SelectString"," ")
										$listUpdateFlag=false
									endif
								endif
								ControlFocus($JobCreationForm, "", $LST_JobCreation_JobList)
								consoleWrite("! set focus "& @CRLf)
								$listLoop=0
							Else
								$listLoop=1
							endif
						Case -108 ;$NM_CLICK
							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_JobCreation_JobList   WM_NOTIFY  "& @CRLf)
							_SortControl_WM_NOTIFY($LST_JobCreation_JobList)
						Case $NM_DBLCLK
							ConsoleWrite("+$NM_DBLCLK "& @CRLf)
						case $NM_RCLICK
							consoleWrite("+$NM_RCLICK   +$LST_JobCreation_JobList   WM_NOTIFY  "& @CRLf)
							ShowMenuAtMouse($JobCreationForm, $LST_JobCreation_JobList, $contextmenu_list)
						Case Else
	;~ 						ConsoleWrite("!!$LST_JobCreation_JobList nNotifyCode"& $nNotifyCode& @CRLf)
					EndSwitch
				Case $LST_jobcreation_tasklist
					Switch $nNotifyCode
						Case $NM_CLICK
;~ 							consoleWrite("+$NM_CLICK   +$LST_jobcreation_tasklist   WM_NOTIFY  "& @CRLf)
							$taskID=0
							if $listUpdateFlag=False then
								consoleWrite("+$NM_CLICK   +$LST_jobcreation_tasklist   WM_NOTIFY  "& @CRLf)
								If _GUICtrlListView_GetSelectedCount($LST_jobcreation_tasklist)=1 Then
									$listUpdateFlag=True
									$lineValues=_GUICtrlListView_GetItemTextArray($LST_jobcreation_tasklist)
									$taskID=$lineValues[3]
									ConsoleWrite('$taskID = ' & $taskID & @crlf )
									ControlCommand ($JobCreationForm, "", $CMB_jobcreation_selecttask, "SelectString", $lineValues[1])
									_JobCreation_enabletasks()
									$listUpdateFlag=False
								Else
									_JobCreation_disabletasks()
									$listUpdateFlag=false
								endif
								If _GUICtrlListView_GetSelectedCount($LST_jobcreation_tasklist)>1 Then
									GUICtrlSetState($BTN_createjob_DescribeTask,$GUI_ENABLE)
								endif
							endif
						Case -108 ;$NM_CLICK
							consoleWrite("+LVN_COLUMNCLICK -108   +$LST_jobcreation_tasklist   WM_NOTIFY  "& @CRLf)
						Case $NM_DBLCLK
							ConsoleWrite("+$NM_DBLCLK   +$LST_jobcreation_tasklist   WM_NOTIFY  "& @CRLf)
						Case $LVN_ITEMCHANGED
							If $listUpdateFlag_tasklist=False Then
								ConsoleWrite("+$LVN_ITEMCHANGED   +$LST_jobcreation_tasklist   WM_NOTIFY "& @CRLf)
								$listUpdateFlag_tasklist=true
								$tInfo = DllStructCreate($tagNMLISTVIEW, $ilParam)
								$item=DllStructGetData($tInfo, "Item")
								$checked=DllStructGetData($tInfo, "NewState")
								$taskNumber=_GUICtrlListView_GetItemText($LST_jobcreation_tasklist,$item,2)
								If $taskNumber<>"" then
									If $checked=4096 Then _UpdateTaskActive($taskNumber,0)
									if $checked=8192 Then _UpdateTaskActive($taskNumber,1)
								endif
								$listUpdateFlag_tasklist=False
							endif
						case $NM_RCLICK
							consoleWrite("+$NM_RCLICK   +$LST_jobcreation_tasklist   WM_NOTIFY  "& @CRLf)
							ShowMenuAtMouse($JobCreationForm, $LST_jobcreation_tasklist, $contextmenu_list)
						Case Else
;~ 							ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $NM_CLICK = ' & $NM_CLICK & @crlf )
					EndSwitch
			#endregion
		EndSwitch
	EndIf
EndFunc
Func _SortControl_WM_NOTIFY($listObject)
	;  to sort list , the form object must be registered with _> GUICtrlRegisterListViewSort(-1, "LVSortReport")
	; HAY QUE PONER LOGICA EN -> Case -108 ;$NM_CLICK
	ConsoleWrite('!++_SortControl_WM_NOTIFY() = '& $listObject& @crlf)
	$bSet = 0
	$nCurCol = $nCol
	GUICtrlSendMsg($listObject, $LVM_SETSELECTEDCOLUMN, GUICtrlGetState($listObject), 0)
	DllCall("user32.dll", "int", "InvalidateRect", "hwnd", GUICtrlGetHandle($listObject), "int", 0, "int", 1)
EndFunc


#cs
			WM_NULL = 0x00
			WM_CREATE = 0x01
			WM_DESTROY = 0x02
			WM_MOVE = 0x03
			WM_SIZE = 0x05
			WM_ACTIVATE = 0x06
			WM_SETFOCUS = 0x07
			WM_KILLFOCUS = 0x08
			WM_ENABLE = 0x0A
			WM_SETREDRAW = 0x0B
			WM_SETTEXT = 0x0C
			WM_GETTEXT = 0x0D
			WM_GETTEXTLENGTH = 0x0E
			WM_PAINT = 0x0F
			WM_CLOSE = 0x10
			WM_QUERYENDSESSION = 0x11
			WM_QUIT = 0x12
			WM_QUERYOPEN = 0x13
			WM_ERASEBKGND = 0x14
			WM_SYSCOLORCHANGE = 0x15
			WM_ENDSESSION = 0x16
			WM_SYSTEMERROR = 0x17
			WM_SHOWWINDOW = 0x18
			WM_CTLCOLOR = 0x19
			WM_WININICHANGE = 0x1A
			WM_SETTINGCHANGE = 0x1A
			WM_DEVMODECHANGE = 0x1B
			WM_ACTIVATEAPP = 0x1C
			WM_FONTCHANGE = 0x1D
			WM_TIMECHANGE = 0x1E
			WM_CANCELMODE = 0x1F
			WM_SETCURSOR = 0x20
			WM_MOUSEACTIVATE = 0x21
			WM_CHILDACTIVATE = 0x22
			WM_QUEUESYNC = 0x23
			WM_GETMINMAXINFO = 0x24
			WM_PAINTICON = 0x26
			WM_ICONERASEBKGND = 0x27
			WM_NEXTDLGCTL = 0x28
			WM_SPOOLERSTATUS = 0x2A
			WM_DRAWITEM = 0x2B
			WM_MEASUREITEM = 0x2C
			WM_DELETEITEM = 0x2D
			WM_VKEYTOITEM = 0x2E
			WM_CHARTOITEM = 0x2F

			WM_SETFONT = 0x30
			WM_GETFONT = 0x31
			WM_SETHOTKEY = 0x32
			WM_GETHOTKEY = 0x33
			WM_QUERYDRAGICON = 0x37
			WM_COMPAREITEM = 0x39
			WM_COMPACTING = 0x41
			WM_WINDOWPOSCHANGING = 0x46
			WM_WINDOWPOSCHANGED = 0x47
			WM_POWER = 0x48
			WM_COPYDATA = 0x4A
			WM_CANCELJOURNAL = 0x4B
			WM_NOTIFY = 0x4E
			WM_INPUTLANGCHANGEREQUEST = 0x50
			WM_INPUTLANGCHANGE = 0x51
			WM_TCARD = 0x52
			WM_HELP = 0x53
			WM_USERCHANGED = 0x54
			WM_NOTIFYFORMAT = 0x55
			WM_CONTEXTMENU = 0x7B
			WM_STYLECHANGING = 0x7C
			WM_STYLECHANGED = 0x7D
			WM_DISPLAYCHANGE = 0x7E
			WM_GETICON = 0x7F
			WM_SETICON = 0x80

			WM_NCCREATE = 0x81
			WM_NCDESTROY = 0x82
			WM_NCCALCSIZE = 0x83
			WM_NCHITTEST = 0x84
			WM_NCPAINT = 0x85
			WM_NCACTIVATE = 0x86
			WM_GETDLGCODE = 0x87
			WM_NCMOUSEMOVE = 0xA0
			WM_NCLBUTTONDOWN = 0xA1
			WM_NCLBUTTONUP = 0xA2
			WM_NCLBUTTONDBLCLK = 0xA3
			WM_NCRBUTTONDOWN = 0xA4
			WM_NCRBUTTONUP = 0xA5
			WM_NCRBUTTONDBLCLK = 0xA6
			WM_NCMBUTTONDOWN = 0xA7
			WM_NCMBUTTONUP = 0xA8
			WM_NCMBUTTONDBLCLK = 0xA9

			WM_KEYFIRST = 0x100
			WM_KEYDOWN = 0x100
			WM_KEYUP = 0x101
			WM_CHAR = 0x102
			WM_DEADCHAR = 0x103
			WM_SYSKEYDOWN = 0x104
			WM_SYSKEYUP = 0x105
			WM_SYSCHAR = 0x106
			WM_SYSDEADCHAR = 0x107
			WM_KEYLAST = 0x108

			WM_IME_STARTCOMPOSITION = 0x10D
			WM_IME_ENDCOMPOSITION = 0x10E
			WM_IME_COMPOSITION = 0x10F
			WM_IME_KEYLAST = 0x10F

			WM_INITDIALOG = 0x110
			WM_COMMAND = 0x111
			WM_SYSCOMMAND = 0x112
			WM_TIMER = 0x113
			WM_HSCROLL = 0x114
			WM_VSCROLL = 0x115
			WM_INITMENU = 0x116
			WM_INITMENUPOPUP = 0x117
			WM_MENUSELECT = 0x11F
			WM_MENUCHAR = 0x120
			WM_ENTERIDLE = 0x121

			WM_CTLCOLORMSGBOX = 0x132
			WM_CTLCOLOREDIT = 0x133
			WM_CTLCOLORLISTBOX = 0x134
			WM_CTLCOLORBTN = 0x135
			WM_CTLCOLORDLG = 0x136
			WM_CTLCOLORSCROLLBAR = 0x137
			WM_CTLCOLORSTATIC = 0x138

			WM_MOUSEFIRST = 0x200
			WM_MOUSEMOVE = 0x200
			WM_LBUTTONDOWN = 0x201
			WM_LBUTTONUP = 0x202
			WM_LBUTTONDBLCLK = 0x203
			WM_RBUTTONDOWN = 0x204
			WM_RBUTTONUP = 0x205
			WM_RBUTTONDBLCLK = 0x206
			WM_MBUTTONDOWN = 0x207
			WM_MBUTTONUP = 0x208
			WM_MBUTTONDBLCLK = 0x209
			WM_MOUSEWHEEL = 0x20A
			WM_MOUSEHWHEEL = 0x20E

			WM_PARENTNOTIFY = 0x210
			WM_ENTERMENULOOP = 0x211
			WM_EXITMENULOOP = 0x212
			WM_NEXTMENU = 0x213
			WM_SIZING = 0x214
			WM_CAPTURECHANGED = 0x215
			WM_MOVING = 0x216
			WM_POWERBROADCAST = 0x218
			WM_DEVICECHANGE = 0x219

			WM_MDICREATE = 0x220
			WM_MDIDESTROY = 0x221
			WM_MDIACTIVATE = 0x222
			WM_MDIRESTORE = 0x223
			WM_MDINEXT = 0x224
			WM_MDIMAXIMIZE = 0x225
			WM_MDITILE = 0x226
			WM_MDICASCADE = 0x227
			WM_MDIICONARRANGE = 0x228
			WM_MDIGETACTIVE = 0x229
			WM_MDISETMENU = 0x230
			WM_ENTERSIZEMOVE = 0x231
			WM_EXITSIZEMOVE = 0x232
			WM_DROPFILES = 0x233
			WM_MDIREFRESHMENU = 0x234

			WM_IME_SETCONTEXT = 0x281
			WM_IME_NOTIFY = 0x282
			WM_IME_CONTROL = 0x283
			WM_IME_COMPOSITIONFULL = 0x284
			WM_IME_SELECT = 0x285
			WM_IME_CHAR = 0x286
			WM_IME_KEYDOWN = 0x290
			WM_IME_KEYUP = 0x291

			WM_MOUSEHOVER = 0x2A1
			WM_NCMOUSELEAVE = 0x2A2
			WM_MOUSELEAVE = 0x2A3

			WM_CUT = 0x300
			WM_COPY = 0x301
			WM_PASTE = 0x302
			WM_CLEAR = 0x303
			WM_UNDO = 0x304

			WM_RENDERFORMAT = 0x305
			WM_RENDERALLFORMATS = 0x306
			WM_DESTROYCLIPBOARD = 0x307
			WM_DRAWCLIPBOARD = 0x308
			WM_PAINTCLIPBOARD = 0x309
			WM_VSCROLLCLIPBOARD = 0x30A
			WM_SIZECLIPBOARD = 0x30B
			WM_ASKCBFORMATNAME = 0x30C
			WM_CHANGECBCHAIN = 0x30D
			WM_HSCROLLCLIPBOARD = 0x30E
			WM_QUERYNEWPALETTE = 0x30F
			WM_PALETTEISCHANGING = 0x310
			WM_PALETTECHANGED = 0x311

			WM_HOTKEY = 0x312
			WM_PRINT = 0x317
			WM_PRINTCLIENT = 0x318

			WM_HANDHELDFIRST = 0x358
			WM_HANDHELDLAST = 0x35F
			WM_PENWINFIRST = 0x380
			WM_PENWINLAST = 0x38F
			WM_COALESCE_FIRST = 0x390
			WM_COALESCE_LAST = 0x39F
			WM_DDE_FIRST = 0x3E0
			WM_DDE_INITIATE = 0x3E0
			WM_DDE_TERMINATE = 0x3E1
			WM_DDE_ADVISE = 0x3E2
			WM_DDE_UNADVISE = 0x3E3
			WM_DDE_ACK = 0x3E4
			WM_DDE_DATA = 0x3E5
			WM_DDE_REQUEST = 0x3E6
			WM_DDE_POKE = 0x3E7
			WM_DDE_EXECUTE = 0x3E8
			WM_DDE_LAST = 0x3E8

			WM_USER = 0x400
			WM_APP = 0x8000
#ce