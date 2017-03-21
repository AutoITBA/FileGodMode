#region -----------------     functions  --------------------------------------------------------------------------------------------------------
	#region f==================================== Run Function  Main  ==============================
	Func _RunJob($Action,$hEdit)
		ConsoleWrite('++_RunJob() =' & "Action = " & $Action & @crlf )
;~ 		_ClearSciteConsole()
		#region f# descrive
		If $Action="Describe" Then
			$Action="SHOW"
			$hFGMtaskReport=""
			Local $hFGMtaskReport = FileOpen($FGMtaskReport, 2+8)
			If $hFGMtaskReport = -1 Then
				$CSVreport=0
				MsgBox(0, "Error", "Unable to create file for CSV report.")
				GUICtrlSetState($BTN_ConsoleDescribe_OpenCSV,$GUI_DISABLE)
				Return false
			Else
				$CSVreport=1
				GUICtrlSetState($BTN_ConsoleDescribe_OpenCSV,$GUI_ENABLE)
				FileWriteLine($FGMtaskReport,"Job Name,Task ID,Task type,Task name description,Enabled," & _
											"Source Location,Source Path,Source filter," & _
											"Target Location,Target Path,Target Zip file,Source user," & _
											"Target user,Behaviour,AdditionalMSG")
				ConsoleWrite('--@@ Debug(' & @ScriptLineNumber & ') : $LST_jobcreation_tasklist = ' & $LST_jobcreation_tasklist & @crlf )
				$DescriptionTaskArr=_GUICtrlListView_GetItemsSelectedByColumn($LST_jobcreation_tasklist,2)
			EndIf
		Else
			$CSVreport=0
		endif
		#endregion
		Global $RunFail=0
		$iMemo=$hEdit
		MemoWrite($iMemo,"Log Filename = "& $LogFileActivity ,"",8,1)
		MemoWrite($iMemo,"Job Name = "& GUICtrlRead($TXT_JobCreation_jobname) & @TAB & @TAB & "Action = " & $Action,"",12,1)
		$arrsql=_getJobTasks()
		If  IsArray($arrsql) then
			; loop tasks  $qryResult
			For $iRows = 1 To UBound($arrsql)-1
				If $hotKeyKill=1 Then Return false
				$run_taskid=0
				$run_taskid=$arrsql[$iRows][0]
				$taskType=$arrsql[$iRows][1]
				$TaskName=$arrsql[$iRows][2]
				$taskActive=$arrsql[$iRows][3]
				If $taskActive=1 Then
					$taskEnabled="Enabled"
				Else
					$taskEnabled="Disabled"
				endif
				#region f# deployar install uninstall agemt check
					if $taskType="Deploy Agent Task" then
						$InInstall=_CheckTaskDeployAgentDeployAction($run_taskid)
						If $InInstall Then
							$Deployagent="Install "
						Else
							$Deployagent="Uninstall "
						EndIf
					Else
						$Deployagent=""
					endif
				#endregion
				If $taskActive=1 Or $CSVreport=1 Then
					$msg="Task Type = "& $taskType & " " & $Deployagent& @TAB& @TAB & @TAB& " Task Name = "& $TaskName& @TAB &  "Task " & $taskEnabled
					If $Action="RUN" Then
						If _checkRunOneByOne($msg)=False Then return
					endif
					MemoWrite($iMemo,$msg ,"Darkgreen",10,1)
					#region f# Update Type - servers in group
						if _CheckIfTypeUpdate("SourceLoc")=true then
							if _TypeUpdateDB("SourceLoc")=False then return False
						endif
						if _CheckIfTypeUpdate("TargetLoc")=true then
							if _TypeUpdateDB("TargetLoc")=false then return False
						endif
					#endregion
					#region f# get variables for task
						;get stored data by tasktype
						$arrTargetLOC=_get_UnitByVertice("TargetLoc",$run_taskid)
						_printFromArray($arrTargetLOC,"$arrTargetLOC")
						$arrSourceLOC=_get_UnitByVertice("SourceLoc",$run_taskid)
						_printFromArray($arrSourceLOC,"$arrSourceLOC")

						$arrTargetPath=_get_UnitFilterByVertice("TargetPath",$run_taskid)  ; return unit,filter
						$arrSourcePath=_get_UnitByVertice("SourcePath",$run_taskid)
						$arrSourcePathfilter=_get_UnitFilterByVertice("SourcePath",$run_taskid)
						;get passwords
						$arr_cred=_get_UserCred("TargetLoc",$run_taskid,$arrTargetLOC[1][0])
						$userT=$arr_cred[1]&"\"&$arr_cred[2]
						$passT=$arr_cred[3]

						if IsArray($arrSourceLOC) then
							$arr_cred=_get_UserCred("SourceLoc",$run_taskid,$arrSourceLOC[1][0])
							If UBound($arr_cred)>1 Then
								$userP=$arr_cred[1]&"\"&$arr_cred[2]
								If $userP="\" Then $userP=""
								$passP=$arr_cred[3]
							endif
						endif
					#endregion
					#region f# alertar si server is in trash
						If $Action="Show" Then
							$TrashAlert="Attention !!!:"&@crlf
							$TrashAlert&=@tab&"Server/s deleted from Group/s"&@crlf
							$lenAlertTitle=StringLen($TrashAlert)
							$resp=_TrashAlert($arrTargetLOC)
								If $resp<>"" Then $TrashAlert&=$resp&@crlf
							$resp=_TrashAlert($arrSourceLOC)
								If $resp<>"" Then $TrashAlert&=$resp&@crlf
							If StringLen($TrashAlert)>$lenAlertTitle Then MemoWrite($iMemo,@TAB & $TrashAlert,"Red",10,1)

							$DeletedAlert="Attention !!!:"&@crlf
							$DeletedAlert&=@tab&"Server/s deleted from server list."&@crlf
							$lenAlertTitle=StringLen($DeletedAlert)
							$resp=_DeletedAlert($arrTargetLOC)
								If $resp<>"" Then $DeletedAlert&=$resp&@crlf
							$resp=_DeletedAlert($arrSourceLOC)
								If $resp<>"" Then $DeletedAlert&=$resp&@crlf
							If StringLen($DeletedAlert)>$lenAlertTitle Then MemoWrite($iMemo,@TAB & $DeletedAlert,"Red",10,1)
						endif
					#endregion
					;action
					$showDesc=$CSVreport=1 And _ArraySearch($DescriptionTaskArr,$run_taskid)>-1
					#region f# select task activity
					Switch $taskType
						Case "Folder Creation Task"
							For $i=1 To UBound($arrTargetLOC)-1
								For $j=1 To UBound($arrTargetPath)-1
									$res=_Run_FolderCreation($arrTargetLOC[$i][0],$arrTargetPath[$j][0],$Action,$userT,$passT,$userP,$passP)
									If $Action<>"Show" Then MemoWrite($iMemo,@TAB & "-------------------------------------")
									If $res=False Then
										MemoWrite($iMemo,"________________________________________________________________________________________________________")
										_StatusPercent()
										return
									endif
								next
							next
							If $Action<>"Show" Then MemoWrite($iMemo,@TAB & "End Folder Creation Task "& " -------------------------------------","black",10,0 )
							If $RunFail=1 AND _checkIf2Hold( "Folder creation Error. " )=False Then return
						Case "Deletion Task"
							For $i=1 To UBound($arrTargetLOC)-1
								For $j=1 To UBound($arrTargetPath)-1
									$res=_Run_Deletion($arrTargetLOC[$i][0],$arrTargetPath[$j][0],$arrTargetPath[$j][1],$Action,$userT,$passT,$userP,$passP)
									If $Action<>"Show" Then MemoWrite($iMemo,@TAB & "-------------------------------------")
									If $res=False Then
										MemoWrite($iMemo,"________________________________________________________________________________________________________")
										_StatusPercent()
										return
									endif
								next
							next
							If $Action<>"Show" Then MemoWrite($iMemo,@TAB & "End Deletion Task"& " -------------------------------------","black",10,0 )
							If $RunFail=1 AND _checkIf2Hold( "Deletion Error. " )=False Then return
						Case "Compression Task"
							For $isl=1 To UBound($arrSourceLOC)-1
								For $itl=1 To UBound($arrTargetLOC)-1
									For $isp=1 To UBound($arrSourcePath)-1
										For $itp=1 To UBound($arrTargetPath)-1
											$res=_Run_Zip( $arrSourceLOC[$isl][0],$arrSourcePathfilter[$isp][0],$arrSourcePathfilter[$isp][1] , _
														$arrTargetLOC[$itl][0],$arrTargetPath[$itp][0],$arrTargetPath[$itp][1],$Action,$userT,$passT,$userP,$passP)
											If $Action<>"Show" Then MemoWrite($iMemo,@TAB & "-------------------------------------")
											If $res=False Then
												MemoWrite($iMemo,"________________________________________________________________________________________________________")
												_StatusPercent()
												return
											endif
										next
									next
								next
							next
							If $Action<>"Show" Then MemoWrite($iMemo,@TAB & "End Compression Task"& " -------------------------------------","black",10,0 )
							If $RunFail=1 AND _checkIf2Hold( "Compression Error. " )=False Then return
						Case "Copy Task"
							For $isl=1 To UBound($arrSourceLOC)-1
								For $itl=1 To UBound($arrTargetLOC)-1
									For $isp=1 To UBound($arrSourcePath)-1
										For $itp=1 To UBound($arrTargetPath)-1
											$res=_Run_Copy( $arrSourceLOC[$isl][0],$arrSourcePathfilter[$isp][0],$arrSourcePathfilter[$isp][1] , _
													$arrTargetLOC[$itl][0],$arrTargetPath[$itp][0],$arrTargetPath[$itp][1],$Action,$userT,$passT,$userP,$passP)
											If $Action<>"Show" Then MemoWrite($iMemo,@TAB & "-------------------------------------")
											If $res=False Then
												MemoWrite($iMemo,"________________________________________________________________________________________________________")
												_StatusPercent()
												return
											endif
										next
									next
								next
							next
							If $Action<>"Show" Then MemoWrite($iMemo,@TAB & "End Copy Task"& " -------------------------------------","black",10,0 )
							If $RunFail=1 AND _checkIf2Hold( "Copy Error. " )=False Then return
						Case "Deploy Agent Task"
							For $i=1 To UBound($arrTargetLOC)-1
								$res=_Run_DeployAgent($arrTargetLOC[$i][0],$InInstall,$Action,$userT,$passT)
								If $Action<>"Show" Then MemoWrite($iMemo,@TAB & "-------------------------------------")
								If $res=False Then
									MemoWrite($iMemo,"________________________________________________________________________________________________________")
									_StatusPercent()
									return
								endif
							next
							If $Action<>"Show" Then MemoWrite($iMemo,@TAB & "End Deploy Agent Task"& " -------------------------------------","black",10,0 )
							If $RunFail=1 AND _checkIf2Hold( "Agent Deploy Error. " )=False Then return
						Case "Execution Task"
							For $i=1 To UBound($arrTargetLOC)-1
								For $j=1 To UBound($arrTargetPath)-1
									$targetFolder=$arrTargetPath[$j][0]
									$targetServer=$arrTargetLOC[$i][0]
									;get commands
									$arrCommands=_GetTaskCommands($run_taskid)
									_printFromArray($arrCommands,"all commands")
									if IsArray($arrCommands) then
										$arrCommandLines=stringsplit($arrCommands[1],"|\n",1)
										$arrCommandLines=_clearEmptyLinesFromArray($arrCommandLines,0)
										_printFromArray($arrCommandLines,"commands")
										select
											Case $arrCommands[0]=1
												ConsoleWrite('!!@@ Debug(' & @ScriptLineNumber & ') : $arrCommandLines[1] = ' & $arrCommandLines[1] & @crlf )
											Case $arrCommands[0]=2
												$arrExtraFiles=stringsplit($arrCommands[2],"|",1)
												$arrExtraFiles=_clearEmptyLinesFromArray($arrExtraFiles,0)
												_printFromArray($arrExtraFiles,"extra files")
											case Else
												MsgBox(48+4096,"Setting execution data error","An error setting Script execution data. ErrNo 2151" & @CRLF ,0,0)
										EndSelect
										$res=_Run_Exwcute($targetServer,$targetFolder,$arrCommandLines,$arrExtraFiles,$Action,$userT,$passT,$userP,$passP)
										If $Action<>"Show" Then MemoWrite($iMemo,@TAB & "-------------------------------------")
										If $res=False Then
											MemoWrite($iMemo,"________________________________________________________________________________________________________")
											_StatusPercent()
											return
										endif
									Else
										MsgBox(48+4096,"Setting execution data error","An error setting execution data. ErrNo 2150" & @CRLF ,0,0)
										return
									endif
								next
							next
							If $Action<>"Show" Then MemoWrite($iMemo,@TAB & "End Execution Task "& " -------------------------------------","black",10,0 )
							If $RunFail=1 AND _checkIf2Hold( "Execution Task Error. " )=False Then return
						case Else
							ConsoleWrite('!!!  RunFunction Task not handeled' & @crlf )
					EndSwitch
					#endregion
				Else
					MemoWrite($iMemo,"Task Type = "& $taskType & @TAB& @TAB & @TAB& " Task Name = "& $TaskName& @TAB &  "Task " & $taskEnabled ,"orange",10,1)
				endif
			next
		Else
			MemoWrite($iMemo,"The Job "& GUICtrlRead($TXT_JobCreation_jobname) & " don't has tasks assosciated." )
			return
		endif
		FileClose($hFGMtaskReport)
		MemoWrite($iMemo,"End of Job" )
		MemoWrite($iMemo,"________________________________________________________________________________________________________")
	EndFunc
	#endregion
	#region f==================================== Folder creation     ==============================
		Func _Run_FolderCreation($targetLoc,$targetPath,$Action,$userT="",$passT="",$userP="",$passP="")
			#region f################################     INIT   ###################################
			ConsoleWrite('++_Run_FolderCreation() ='& @crlf )
			$srvipmsg=_GetTarget($targetLoc,"Target ")
			MemoWrite($iMemo,@TAB & "Using  "& $userT & " credentials")
			;separation de C$ admin share fron remote path
			$arrPath=StringSplit($targetPath,":\",1)
			If $arrPath[0]>1 Then  ;normal folder
				$RemoteDrive="\\"&$srvipmsg[0]&"\"&$arrPath[1]&"$"   ; \\server\c$
				$fullRemotePath=$RemoteDrive & "\" & $arrPath[2]   ;\\server\c$\folderToCreate
			Else  ; share
				$RemoteDrive=$targetLoc ; \\server\share
				$fullRemotePath=$targetLoc&$targetPath      ;\\server\share\folderToCreate
			EndIf
			#endregion
			If $showDesc Then _WriteReportCSV("","","",$targetLoc,$targetPath,"",$userP,$userT,"",$srvipmsg[1])
			#region f################################     SHOW   ###################################
			If $Action="show" Then
				If $CSVreport=0 Or $showDesc Then
					ConsoleWrite('_Run_FolderCreation() =  $Action ='& $Action & @crlf )
	;~ 				_CheckDirAccess("\\"&$targetLoc&"\"&$arrPath[1]&"$") ;unit test
					MemoWrite($iMemo,@TAB & "Create folder "& $fullRemotePath )
				endif
			EndIf
			#endregion
			#region f################################     TEST   ###################################
			If $Action="test" Then
				ConsoleWrite('_Run_FolderCreation() =  $Action ='& $Action & @crlf )
				_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Testing Job", 0)
				If _CheckMap($RemoteDrive,$userT,$passT) Then
					If $hotKeyKill=1 Then Return false
					If DirGetSize($fullRemotePath) = -1 Then
						MemoWrite($iMemo,@TAB & "Folder will be created AT JOB RUNTIME "& $fullRemotePath ,"blue")
					Else
						MemoWrite($iMemo,@TAB & "Folder already exist and WON'T BE CREATED. "& $fullRemotePath,"orange")
					endif
					$res=DriveMapDel($RemoteDrive)
					If Not $res Then
						MemoWrite($iMemo,@TAB & "Drive cannot be UnMounted " & $RemoteDrive ,"Red",8,1)
					EndIf
				Else
					MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* "  & @crlf,"Red",8,1)
					If $RunFail=1 AND _checkIf2Hold( "Mapping Error . " )=True Then Return true
					Return false
				endif
			EndIf
			#endregion
			#region f################################     RUN    ###################################
			If $Action="run" Then
				ConsoleWrite('_Run_FolderCreation() =  $Action ='& $Action & @crlf )
				_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Running Job", 0)
				If _CheckMap($RemoteDrive,$userT,$passT) Then
					If DirGetSize($fullRemotePath) = -1 Then
						_checkPause()
						_CheckClearConsole()
						If $hotKeyKill=1 Then Return false
						_createDIR($fullRemotePath)
						If DirGetSize($fullRemotePath) > -1 Then
							MemoWrite($iMemo,@TAB & "Created Folder successfully tested. "& $fullRemotePath,"Darkgreen",10,1)
						Else
							MemoWrite($iMemo,@TAB & "Folder NOT created. "& $fullRemotePath )
							MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* "  & @crlf,"Red",8,1)
							$RunFail=1
						endif
					Else
						MemoWrite($iMemo,@TAB & "Folder already exist - NOT created. "& $fullRemotePath ,"orange")
					endif
					$res2=DriveMapDel($RemoteDrive)
					If Not $res2 Then
						MemoWrite($iMemo,@TAB & "Drive cannot be UnMounted " & $RemoteDrive,"Red",8,1)
					Return false
					EndIf
				Else
					MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* "  & @crlf,"Red",8,1)
					If $RunFail=1 AND _checkIf2Hold( "Mapping Error . " )=True Then Return true
					Return false
				endif
			EndIf
			return true
			#endregion ##############################################################################
		EndFunc
	#endregion
	#region f==================================== Deletion            ==============================
		Func _Run_Deletion($targetLoc,$targetPath,$filter,$Action,$userT="",$passT="",$userP="",$passP="")
			#cs	Clave para deleteo:
				No filter -> boletea todo
				*  -> boletea solo los files y folders hijos
				*.* o cualquier otro filterro  -> se boletean solo files
			#ce
			#region f################################     INIT   ###################################
			ConsoleWrite('++_Run_Deletion() ='& @crlf )
			$rrecursivo=0
			If StringInStr($filter,"[R]")>0 Then
				$filter=StringReplace($filter,"[R]","")
				$rrecursivo=1
			endif
			$olderdays=0
			If StringInStr($filter,"[")>0 Then
				$in=StringInStr($filter,"[")
				$en=StringInStr($filter,"]")
				$olderdays=StringMid($filter,$in+1,$en-$in-1)
				$filter=StringMid($filter,1,$in-1)
			endif

			$srvipmsg=_GetTarget($targetLoc,"Target ")
			MemoWrite($iMemo,@TAB & "Using  "& $userT & " credentials")
			;separation de C$ admin share fron remote path
			$arrPath=StringSplit($targetPath,":\",1)
			If $arrPath[0]>1 Then  ;normal folder
				$RemoteDrive="\\"&$srvipmsg[0]&"\"&$arrPath[1]&"$"   ; \\server\c$
				If $filter<>"" Then
					if $arrPath[2]<>"" then
						$fullRemotePath=$RemoteDrive & "\" & $arrPath[2] & "\" & $filter   ;\\server\c$\folderFilesToDelete
					Else
						$fullRemotePath=$RemoteDrive  & "\" & $filter   ;\\server\c$\folderFilesToDelete
					endif
					$fullRemotePathfolder=$RemoteDrive & "\" & $arrPath[2]
				Else
					$fullRemotePath=$RemoteDrive & "\" & $arrPath[2]  ;\\server\c$\folderFilesToDelete
					$fullRemotePathfolder=$RemoteDrive & "\" & $arrPath[2]
				endif
			Else  ; share
				$RemoteDrive=$targetLoc ; \\server\share
				$fullRemotePath=$targetLoc&$targetPath      ;\\server\share\folderToCreate
			EndIf
			$olderdaysmgg=""
			If $olderdays>0 Then  $olderdaysmgg=" older than "& $olderdays & " days"
			$RecurseMemo=""
			If $rrecursivo=1 Then $RecurseMemo=" - Recurse"
			#endregion
			If $showDesc  Then _WriteReportCSV("","","",$targetLoc,$targetPath,"",$userP,$userT,"",$srvipmsg[1])
			#region f################################     SHOW   ###################################
			If $Action="show" Then
				If $CSVreport=0 Or $showDesc Then
					ConsoleWrite('_Run_Deletion() =  $Action ='& $Action & @crlf )
					MemoWrite($iMemo,@TAB & "Deletion of "& $fullRemotePath & $olderdaysmgg & $RecurseMemo )
				endif
			EndIf
			#endregion
			#region f################################     TEST   ###################################
			If $Action="test" Then
				ConsoleWrite('_Run_Deletion() =  $Action ='& $Action & @crlf )
				_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Testing Job", 0)
				MemoWrite($iMemo,@TAB & "Deletion of  "& $fullRemotePath & $olderdaysmgg & $RecurseMemo,"Black",8,1)
				If _CheckMap($RemoteDrive,$userT,$passT) Then
					If DirGetSize($fullRemotePathfolder) > -1 Then
						_checkPause()
						_CheckClearConsole()
						If $hotKeyKill=1 Then Return false
						$withFolders=0
						$folderLast=1
						If StringStripWS($filter,3)="*" Or StringStripWS($filter,3)="" Then $withFolders=1
						If _checkDirContent($fullRemotePathfolder,$filter,$folderLast,$olderdays,$withFolders)=0 Then
							MemoWrite($iMemo,@TAB & "Folder/Files will be deleted AT JOB RUNTIME "& $fullRemotePath  & $olderdaysmgg & $RecurseMemo,"blue")
						Else
							Return true
						endif
					Else
						MemoWrite($iMemo,@TAB & "Folder/Files do not exist and WON'T BE DELETED. "& $fullRemotePath,"orange")
					endif
					$res=DriveMapDel($RemoteDrive)
					If Not $res Then
						MemoWrite($iMemo,@TAB & "Drive cannot be UnMounted " & $RemoteDrive ,"Red",8,1)
					EndIf
				Else
					MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* "  & @crlf,"Red",8,1)
					If $RunFail=1 AND _checkIf2Hold( "Mapping Error . " )=True Then Return true
					Return false
				endif
			EndIf
			#endregion
			#region f################################     RUN    ###################################
			If $Action="run" Then
				ConsoleWrite('_Run_Deletion() =  $Action ='& $Action & @crlf )
				_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Running Job", 0)
				MemoWrite($iMemo,@TAB & "Deletion of  "& $fullRemotePath & $olderdaysmgg,"Black",8,1)
				If _CheckMap($RemoteDrive,$userT,$passT) Then
					If DirGetSize($fullRemotePathfolder) > -1 Then
						$withFolders=0
						$folderLast=1
						If StringStripWS($filter,3)="*" Or StringStripWS($filter,3)="" Then $withFolders=1
						If _checkDirContent($fullRemotePathfolder,$filter,$folderLast,$olderdays,$withFolders)=0 Then
							$arrDel=""
							$arrDel=_GetDirContent($fullRemotePathfolder,$filter,$folderLast,$olderdays,$withFolders,0)
							_StatusPercent()
							For $i=1 To UBound($arrDel)-1
								_checkPause()
								_CheckClearConsole()
								If $hotKeyKill=1 Then Return false
								_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Running Job", 0)
								_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Deleting "&$arrDel[$i]&"  "&$i&"/"&UBound($arrDel)-1, 1)
								_DeleteDIRFILE($arrDel[$i])
								_StatusPercent($i,$arrDel)
								If FileExists($arrDel[$i])=0 Then
								Else
									MemoWrite($iMemo,@TAB&"               An Error occurred , please check credentials and path. => "& $arrDel[$i] ,"Red",8,1)
									$RunFail=1
								endif
								_CheckConsoleLines($i)
							next
						Else
							Return true
						endif
					Else
						MemoWrite($iMemo,@TAB & "Folder/Files do not exist and WON'T BE DELETED.  "& $fullRemotePath,"orange")
					endif
					$res=DriveMapDel($RemoteDrive)
					If Not $res Then
						MemoWrite($iMemo,@TAB & "Drive cannot be UnMounted  " & $RemoteDrive ,"Red",8,1)
					EndIf
				Else
					MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* " ,"Red",8,1)
					If $RunFail=1 AND _checkIf2Hold( "Mapping Error . " )=True Then Return true
					Return false
				endif
			EndIf
			return true
			#endregion ##############################################################################
		EndFunc
	#endregion
	#region f==================================== ZIP                 ==============================
		Func _Run_Zip($sourceLoc,$sourcePath,$sourcefilter,$targetLoc,$targetPath,$targetZipFile,$Action,$userT="",$passT="",$userP="",$passP="")
			#region f################################     INIT   ###################################
			ConsoleWrite('++_Run_Zip() ='& @crlf )
;~ 			Dim $szDrive, $szDir, $szFName, $szExt
			;target-----------------------------------------------------------------------------------
			;parse flags [NS][D][S][A][R][FS][date]
				$rDeleteZip=0   ;parse [D] delete after zip
				If StringInStr($targetZipFile,"[D]")>0 Then
					$targetZipFile=StringReplace($targetZipFile,"[D]","")
					$rDeleteZip=1
				endif
				$rServerFolderZip=0   ;parse [S] create folder server name
				If StringInStr($targetZipFile,"[S]")>0 Then
					$targetZipFile=StringReplace($targetZipFile,"[S]","")
					$rServerFolderZip=1
				endif
				$rServerFolderZipInside=0   ;parse [S] create folder server name
				If StringInStr($targetZipFile,"[FS]")>0 Then
					$targetZipFile=StringReplace($targetZipFile,"[FS]","")
					$rServerFolderZipInside=1
				endif
				$rAutoRenameZip=0   ;parse [A] autorename zip if exist
				If StringInStr($targetZipFile,"[A]")>0 Then
					$targetZipFile=StringReplace($targetZipFile,"[A]","")
					$rAutoRenameZip=1
				endif
				$rrecursivo=0
				If StringInStr($Sourcefilter,"[R]")>0 Then
					$Sourcefilter=StringReplace($Sourcefilter,"[R]","")
					$rrecursivo=1
				endif
				$rStructure=1    ; 1 to 1 or many to 1 with no structure
				If StringInStr($targetZipFile,"[NS]")>0 Or StringInStr($targetZipFile,"Autonaming")>0 Then
					$targetZipFile=StringReplace($targetZipFile,"[NS]","")
					$rStructure=0
				endif
				If StringInStr($targetZipFile,"[date]")>0 Then
					$targetZipFile=StringReplace($targetZipFile,"[date]",StringReplace(_NowCalcDate(),"/","_") )
				endif
				If StringInStr($targetZipFile,"[server]")>0 Then
					$targetZipFile=StringReplace($targetZipFile,"[server]",_GetSourceServerName("\\"&$sourceLoc&"\") )
				endif
				If StringInStr($targetZipFile,"Autonaming")>0 Then
					$targetZipFile="Autonaming..zip"
				endif
			;separation de C$ admin share fron remote path
				$arrPath=StringSplit($targetPath,":\",1)
				$srvipmsg2=_GetTarget($sourceLoc,"Source")
;~ 				MemoWrite($iMemo,@TAB & "Using  "& $userP & " credentials for " & $sourceLoc)
				MemoWrite($iMemo,@TAB & "Using  "& $userP & " credentials")
				$srvipmsg1=_GetTarget($targetLoc,"Target")
;~ 				MemoWrite($iMemo,@TAB & "Using  "& $userT & " credentials for " & $targetLoc)
				MemoWrite($iMemo,@TAB & "Using  "& $userT & " credentials")
				If $arrPath[0]>1 Then  ;normal folder
					$RemoteDriveTarget="\\"&$srvipmsg1[0]&"\"&$arrPath[1]&"$"   ; \\server\c$
					if $arrPath[2]<>"" then
						$fullRemotePathTargetZipFile=$RemoteDriveTarget & "\" & $arrPath[2] & "\" & $targetZipFile   ;\\server\c$\folderFilesTozip
					Else
						$fullRemotePathTargetZipFile=$RemoteDriveTarget & "\" & $targetZipFile   ;\\server\c$\folderFilesTozip
					endif
					$fullRemotePathfolderTarget=$RemoteDriveTarget & "\" & $arrPath[2]
				Else  ; share
					$RemoteDriveTarget=$targetLoc ; \\server\share
					$fullRemotePathTargetZipFile=$targetLoc&$targetPath & "\" & $targetZipFile       ;\\server\share\folderTozipOutput
				EndIf
			;source-----------------------------------------------------------------------------------
			;separation de C$ admin share fron remote path
				$olderdays=0
				If StringInStr($Sourcefilter,"[")>0 Then
					$in=StringInStr($Sourcefilter,"[")
					$en=StringInStr($Sourcefilter,"]")
					$olderdays=StringMid($Sourcefilter,$in+1,$en-$in-1)
					$Sourcefilter=StringMid($Sourcefilter,1,$in-1)
				endif
				$arrPath=StringSplit($SourcePath,":\",1)
				$fullRemotePathfolderSource=""
				If $arrPath[0]>1 Then  ;normal folder
					$RemoteDriveSource="\\"&$srvipmsg2[0]&"\"&$arrPath[1]&"$"   ; \\server\c$
					If $Sourcefilter<>"" Then
						if $arrPath[2]<>"" then
							$fullRemotePathSource=$RemoteDriveSource & "\" & $arrPath[2] & "\" & $Sourcefilter   ;\\server\c$\folderFilesTozip
						Else
							$fullRemotePathSource=$RemoteDriveSource & "\" & $Sourcefilter   ;\\server\c$\folderFilesTozip
						endif
						$fullRemotePathfolderSource=$RemoteDriveSource & "\" & $arrPath[2]
					Else
						$fullRemotePathSource=$RemoteDriveSource & "\" & $arrPath[2]  ;\\server\c$\folderFilesTozip
						$fullRemotePathfolderSource=$RemoteDriveSource & "\" & $arrPath[2]
					endif
				Else  ; share
					$RemoteDriveSource=$SourceLoc ; \\server\share
					$fullRemotePathSource=$SourceLoc&$SourcePath      ;\\server\share\folderTozip
					$fullRemotePathfolderSource=$fullRemotePathSource
				EndIf
				if $rServerFolderZip=1 then	$fullRemotePathTargetZipFile=_AddServerNameToFileZip($fullRemotePathTargetZipFile,$RemoteDriveSource)
			;mesage creation -------------------------------------------------------------------------
				$additionalMSG="  "
				If $olderdays>0 Then  $additionalMSG=" older than "& $olderdays & " days"
				$olderdaysmgg=$additionalMSG
				$Mesag=" - No recurse"
				If $rrecursivo=1 Then $Mesag=" - Recurse"
				$additionalMSG=$additionalMSG & $Mesag
				$Mesag=" - Not Structured"
				If $rStructure=1 Then $Mesag=" - Structured"
				$additionalMSG=$additionalMSG & $Mesag
				$Mesag=""
				If $targetZipFile="Autonaming..zip" Then $Mesag=" - Autonaming"
				$additionalMSG=$additionalMSG & $Mesag
				$Mesag=""
				If $rAutoRenameZip=1 Then $Mesag=" - AutoRename if exist"
				$additionalMSG=$additionalMSG & $Mesag
				$Mesag=""
				If $rDeleteZip=1 Then $Mesag=" - Delete source"
				$additionalMSG=$additionalMSG & $Mesag
				$Mesag=""
				If $rServerFolderZip=1 Then $Mesag=" - Create Folder per source"
				$additionalMSG=$additionalMSG & $Mesag
				$Mesag=""
				If $rServerFolderZipInside=1 Then $Mesag=" - Create Folder per source At Zip"
				$additionalMSG=$additionalMSG & $Mesag

				$additionalMSG=$additionalMSG ;& $srvipmsg1[1] & " - " & $srvipmsg2[1]
			#endregion
			#region f################################     SHOW   ###################################
			If $showDesc Then _WriteReportCSV($sourceLoc,$sourcePath,$sourcefilter,$targetLoc,$targetPath,$targetZipFile,$userP,$userT,"",$additionalMSG)
			If $Action="show" Then
				If $CSVreport=0 Or $showDesc Then
					ConsoleWrite('_Run_Zip() =  $Action ='& $Action & @crlf )
					MemoWrite($iMemo,@TAB & "Compression of  "& $fullRemotePathSource & "    To   "& _
									$fullRemotePathTargetZipFile & $additionalMSG,"black",9,0)
				endif
			EndIf
			#endregion
			#region f################################     TEST   ###################################
			If $Action="test" Then
				ConsoleWrite('_Run_Zip() =  $Action ='& $Action & @crlf )
				_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Testing Job", 0)
				MemoWrite($iMemo,@TAB & "Compression of  "& $fullRemotePathSource & "    To   "&  $fullRemotePathTargetZipFile & $additionalMSG)
				$rescheckmap=true
				If _CheckMap($RemoteDriveSource,$userP,$passP,"Source Path") Then
					If ($RemoteDriveSource<>$RemoteDriveTarget) Then $rescheckmap=_CheckMap($RemoteDriveTarget,$userT,$passT,"Target Path")
					If $rescheckmap Then
						If DirGetSize($fullRemotePathfolderSource) > -1 And  DirGetSize($fullRemotePathfolderTarget) > -1 Then
							_checkPause()
							If $hotKeyKill=1 Then Return false
							$withFolders=1
							If $rStructure=0 Then $withFolders=0
							$folderLast=0
							If _checkDirContent($fullRemotePathfolderSource,$Sourcefilter,$folderLast,$olderdays,$withFolders,$RemoteDriveTarget,"ZIP")=0 Then
								MemoWrite($iMemo,@TAB & "Folder/Files will be compress AT JOB RUNTIME  "& $fullRemotePathSource & "   to   " & _
								$fullRemotePathTargetZipFile & $additionalMSG,"blue")
								$arrZipFileFldr=_GetDirContent($fullRemotePathfolderSource,$Sourcefilter,$folderLast,$olderdays,$withFolders,0,"ZIP")
								if $rServerFolderZip=1 then	$fullRemotePathfolderTarget=_AddServerNameToFolder($fullRemotePathfolderTarget,$RemoteDriveSource)
								$active=0
								$res=ZipCab($targetZipFile,$arrZipFileFldr,$fullRemotePathfolderTarget,$fullRemotePathTargetZipFile,  $RemoteDriveSource,$fullRemotePathfolderSource,$active)
							Else
								Return true
							endif
						Else
							MemoWrite($iMemo,@TAB & "Folder/Files do not exist and WON'T BE COMPRESSED.  "& $fullRemotePathSource ,"RED")
						endif
						$res=DriveMapDel($RemoteDriveSource)
						If Not $res Then
							MemoWrite($iMemo,@TAB & "Drive cannot be UnMounted " & $RemoteDriveSource ,"Red",8,1)
						EndIf
					Else
						MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* " & @crlf,"Red",8,1)
					If $RunFail=1 AND _checkIf2Hold( "Mapping Error . " )=True Then Return true
					Return false
					endif
				Else
					MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* " & @crlf,"Red",8,1)
					Return true
				endif
			EndIf
			#endregion
			#region f################################     RUN    ###################################
			If $Action="run" Then
				ConsoleWrite('_Run_Zip() =  $Action ='& $Action & @crlf )
				_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Running Job", 0)
				MemoWrite($iMemo,@TAB & "Compression of  "& $fullRemotePathSource & "    To   "&  $fullRemotePathTargetZipFile & $additionalMSG)
				$rescheckmap=true
				If _CheckMap($RemoteDriveSource,$userP,$passP,"Source Path") Then
					If ($RemoteDriveSource<>$RemoteDriveTarget) Then $rescheckmap=_CheckMap($RemoteDriveTarget,$userT,$passT,"Target Path")
					If $rescheckmap Then
						$fullRemotePathfolderSourceOK=0
						$fullRemotePathfolderTargetOK=0
						If DirGetSize($fullRemotePathfolderSource) > -1  Then
							$fullRemotePathfolderSourceOK=1
						Else
							MemoWrite($iMemo,@TAB & "Folder do not exist .  "& $fullRemotePathfolderSource,"orange")
						endif
						If DirGetSize($fullRemotePathfolderTarget) > -1 Then
							$fullRemotePathfolderTargetOK=1
						Else
							MemoWrite($iMemo,@TAB & "Folder do not exist .  "& $fullRemotePathfolderTarget,"orange")
						endif

						If 	$fullRemotePathfolderSourceOK<1 Then
							_createDIR($fullRemotePathfolderSource)
							If DirGetSize($fullRemotePathfolderSource) > -1 Then
								MemoWrite($iMemo,@TAB & "Folder created successfully tested. "& $fullRemotePathfolderSource,"Darkgreen",10,1)
								$fullRemotePathfolderSourceOK=1
							Else
								MemoWrite($iMemo,@TAB & "Folder NOT created. "& $fullRemotePathfolderSource )
								MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* "  & @crlf,"Red",8,1)
							endif
						endif

						If 	$fullRemotePathfolderTargetOK<1 Then
							_createDIR($fullRemotePathfolderTarget)
							If DirGetSize($fullRemotePathfolderTarget) > -1 Then
								MemoWrite($iMemo,@TAB & "Folder created successfully tested. "& $fullRemotePathfolderTarget,"Darkgreen",10,1)
								$fullRemotePathfolderTargetOK=1
							Else
								MemoWrite($iMemo,@TAB & "Folder NOT created. "& $fullRemotePathfolderTarget )
								MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* "  & @crlf,"Red",8,1)
							endif
						endif

						If 	$fullRemotePathfolderTargetOK=1 And $fullRemotePathfolderSourceOK=1  Then
							_checkPause()
							_CheckClearConsole()
							If $hotKeyKill=1 Then Return false
							$withFolders=1
							If $rStructure=0 Then $withFolders=0
							$folderLast=0
							If _checkDirContent($fullRemotePathfolderSource,$Sourcefilter,$folderLast,$olderdays,$withFolders,$RemoteDriveTarget,"ZIP")=0 Then
								MemoWrite($iMemo,@TAB & "Compressing  "& $fullRemotePathSource & "   to   " & $fullRemotePathTargetZipFile & $olderdaysmgg ,"blue")
								_checkPause()
								_CheckClearConsole()
								If $hotKeyKill=1 Then Return false
								$arrZipFileFldr=""
								$arrZipFileFldr=_GetDirContent($fullRemotePathfolderSource,$Sourcefilter,$folderLast,$olderdays,$withFolders,0,"ZIP")
								_checkPause()
								_CheckClearConsole()
								If $hotKeyKill=1 Then Return false
								_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Running Job", 0)
								_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar," ", 1)
								if $rServerFolderZip=1 then	$fullRemotePathfolderTarget=_AddServerNameToFolder($fullRemotePathfolderTarget,$RemoteDriveSource)
								ConsoleWrite('!!!@@ Debug(' & @ScriptLineNumber & ') : $fullRemotePathfolderSource = ' & $fullRemotePathfolderSource & @crlf )
								$active=1
								$res=ZipCab($targetZipFile,$arrZipFileFldr,$fullRemotePathfolderTarget,$fullRemotePathTargetZipFile,  $RemoteDriveSource,$fullRemotePathfolderSource,$active)
								if $res then
									Return true
								Else
									$RunFail=1
									Return False
								endif
							Else
								Return true
							endif
						Else
							$RunFail=1
							Return False
						endif
						$res=DriveMapDel($RemoteDriveSource)
						If Not $res Then
							MemoWrite($iMemo,@TAB & "Drive cannot be UnMounted " & $RemoteDriveSource ,"Red",8,1)
						EndIf
					Else
						MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* " & @crlf ,"Red",8,1)
						If $RunFail=1 AND _checkIf2Hold( "Mapping Error . " )=True Then Return true
						Return false
					endif
				Else
					MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* " & @crlf ,"Red",8,1)
					Return False
				endif
			EndIf
			return true
			#endregion ######################################################################
		EndFunc
	#endregion
	#region f==================================== Copy Move Mirror    ==============================
		Func _Run_Copy($sourceLoc,$sourcePath,$filter,$targetLoc,$targetPath,$Behaviour,$Action,$userT="",$passT="",$userP="",$passP="")
			#region f################################     INIT   ###################################
			ConsoleWrite('++_Run_Copy() ='& @crlf )
			;Source-----------------------------------------------------------------------------------
			;Source------------------------------copy mode -------------------------------------------
			Select
				case StringInStr($filter,"[M]")>0
					$filter=StringReplace($filter,"[M]","")
					$rCopyMode="[M]"
					$MesagCopy= " Mirror "
					MemoWrite($iMemo,@TAB & "*****  Mirror will delete all content in target folder prior copying from source  *****" ,"Red",10,1)
				Case StringInStr($filter,"[MV]")>0
	 				$filter=StringReplace($filter,"[MV]","")
					$rCopyMode="[MV]"
					$MesagCopy= " Move "
				Case Else
					$rCopyMode="[C]"
					$MesagCopy= " Copy"
			EndSelect
			;Source------------------------------Recursive  -----------------------------------------
			$rrecursivo=0
			If StringInStr($filter,"[R]")>0 Then
				$filter=StringReplace($filter,"[R]","")
				$rrecursivo=1
			endif
			;Source------------------------------older than days--------------------------------------
			$olderdays=0
			If StringInStr($filter,"[")>0 Then
				$in=StringInStr($filter,"[")
				$en=StringInStr($filter,"]")
				$olderdays=StringMid($filter,$in+1,$en-$in-1)
				$filter=StringMid($filter,1,$in-1)
			endif
			;target------------------------------Behaviour  structure  -----------------------------------------
			$rStructure=1
			If StringInStr($Behaviour,"[NS]")>0 Then
				$Behaviour=StringReplace($Behaviour,"[NS]","")
				$rStructure=0
			endif
			;target------------------------------Behaviour  Empty Folders  -----------------------------------------
			$withFolders=0
			If StringInStr($Behaviour,"[EF]")>0 Then
				$Behaviour=StringReplace($Behaviour,"[EF]","")
				$withFolders=1
			endif
			If $rCopyMode="[M]" Then $withFolders=1
			;target------------------------------Behaviour  one file per source-----------------------------------------
			$rFolderPerSource=0
			If StringInStr($Behaviour,"[OF]")>0 Then
				$Behaviour=StringReplace($Behaviour,"[OF]","")
				$rFolderPerSource=1
			endif
			;target------------------------------Behaviour  -----------------------------------------
			$rBehaviour=$Behaviour
			Switch $Behaviour
				Case "Overwrite"
					$Behaviour="Overwrite"
				Case "Skip"
					$Behaviour="Skip on conflict"
				Case "Rename"
					$Behaviour="Rename on conflict"
				Case "Prompt"
					$Behaviour="Prompt user on conflict"
				Case Else
					$Behaviour="Unknown behaviour!!!!!!!!"
			EndSwitch
			;Target-----------------separation de C$ admin share fron remote path------------------------
			$arrPath=StringSplit($targetPath,":\",1)
			$srvipmsg2=_GetTarget($sourceLoc,"Source")
;~ 			MemoWrite($iMemo,@TAB & "Using  "& $userP & " credentials for " & $sourceLoc)
			MemoWrite($iMemo,@TAB & "Using  "& $userP & " credentials")
			$srvipmsg1=_GetTarget($targetLoc,"Target ")
;~ 			MemoWrite($iMemo,@TAB & "Using  "& $userT & " credentials for " & $targetLoc)
			MemoWrite($iMemo,@TAB & "Using  "& $userT & " credentials")
			If $arrPath[0]>1 Then  ;normal folder
				$RemoteDriveTarget="\\"&$srvipmsg1[0]&"\"&$arrPath[1]&"$"   ; \\server\c
				If $rFolderPerSource=1 Then
					if $arrPath[2]<>"" then
						$fullRemotePathfolderTarget = $RemoteDriveTarget & "\" & $arrPath[2] & "\" & $srvipmsg2[0]
					Else
						$fullRemotePathfolderTarget = $RemoteDriveTarget & "\" & $srvipmsg2[0]
					endif
					$fullRemotePathfolderTargetCkeck = $RemoteDriveTarget & "\" & $arrPath[2]
				Else
					$fullRemotePathfolderTarget = $RemoteDriveTarget & "\" & $arrPath[2]
				endif
			Else  ; share
				$RemoteDriveTarget = $targetLoc & $targetPath; \\server\share
				If $rFolderPerSource=1 Then
					$fullRemotePathfolderTarget =$RemoteDriveTarget & "\" & $sourceLoc
				Else
					$fullRemotePathfolderTarget=$RemoteDriveTarget
				endif
			EndIf
			$fullRemotePathfolderTargetTemp=$fullRemotePathfolderTarget
			$fullRemotePathfolderTarget=StringReplace($fullRemotePathfolderTargetTemp,"\\","\")
			If StringInStr($fullRemotePathfolderTarget,"\")=1 Then $fullRemotePathfolderTarget="\"&$fullRemotePathfolderTarget
			;Source-----------------separation de C$ admin share fron remote path------------------------
			$arrPath=StringSplit($SourcePath,":\",1)
			If $arrPath[0]>1 Then  ;normal folder
				$RemoteDriveSource="\\"&$srvipmsg2[0]&"\"&$arrPath[1]&"$"   ; \\server\c$
				If $filter<>"" Then
					if $arrPath[2]<>"" then
						$fullRemotePathSource=$RemoteDriveSource & "\" & $arrPath[2] & "\" & $filter   ;\\server\c$\folder
					Else
						$fullRemotePathSource=$RemoteDriveSource & "\" & $filter   ;\\server\c$\folder
					endif
					$fullRemotePathfolderSource=$RemoteDriveSource & "\" & $arrPath[2]
				Else
					$fullRemotePathSource=$RemoteDriveSource & "\" & $arrPath[2]  ;\\server\c$\folder
					$fullRemotePathfolderSource=$RemoteDriveSource & "\" & $arrPath[2]
				endif
			Else  ; share
				$RemoteDriveSource=$SourceLoc ; \\server\share
				$fullRemotePathSource=$SourceLoc&$SourcePath      ;\\server\share\
			EndIf

			; --------------------------------   messages     -------------------------------------
			$additionalMSG="  "
			If $olderdays>0 Then  $additionalMSG=" older than "& $olderdays & " days"
			$olderdaysmgg=$additionalMSG
			$Mesag=" No recurse"
			If $rrecursivo=1 Then $Mesag=" Recurse"
			$additionalMSG=$additionalMSG & " - " & $Mesag
			$Mesag=" No structure"
			If $rStructure=1 Then $Mesag=" Structured"
			$additionalMSG=$additionalMSG & " - " & $Mesag
			$Mesag=" One consolidated folder"
			If $rFolderPerSource=1 Then $Mesag=" One Folder per source"
			$additionalMSG=$additionalMSG & " - " & $Mesag
			$Mesag=" NO empty folders"
			If $withFolders=1 Then $Mesag=" With empty folders"
			$additionalMSG=$additionalMSG & " - " & $Mesag
			$additionalMSG=$additionalMSG & " - " & $Behaviour
			$additionalMSG=$additionalMSG & " - " & $srvipmsg1 & " - " & $srvipmsg2
			#endregion
			#region f################################     SHOW   ###################################
			If $showDesc Then _WriteReportCSV($sourceLoc,$sourcePath,"",$targetLoc,$targetPath,"",$userP,$userT,$Behaviour,$additionalMSG)
			If $Action="show" Then
				If $CSVreport=0 Or $showDesc Then
					ConsoleWrite('_Run_Copy() =  $Action ='& $Action & @crlf )
					MemoWrite($iMemo,@TAB & $MesagCopy &" options: " & $additionalMSG,"black",10,1)
					MemoWrite($iMemo,@TAB & $MesagCopy&" of  "& $fullRemotePathSource & "    To   "& 	$fullRemotePathfolderTarget & $additionalMSG)
				EndIf
			EndIf
			#endregion
			#region f################################     TEST   ###################################
			If $Action="test" Then
				ConsoleWrite('_Run_Copy() =  $Action ='& $Action & @crlf )
				_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Testing Job", 0)
				MemoWrite($iMemo,@TAB & $MesagCopy &" options " & $additionalMSG,"black",9,1)
				MemoWrite($iMemo,@TAB & $MesagCopy &" of  "& $fullRemotePathSource & "    To   "&  $fullRemotePathfolderTarget & $additionalMSG)
				$rescheckmap=true
				If _CheckMap($RemoteDriveSource,$userP,$passP,"Source Path") Then
					If ($RemoteDriveSource<>$RemoteDriveTarget) Then $rescheckmap=_CheckMap($RemoteDriveTarget,$userT,$passT,"Target Path")
					If $rescheckmap Then
						If $rFolderPerSource=1 Then
							$sizetarget=DirGetSize($fullRemotePathfolderTargetCkeck)
						else
							$sizetarget=DirGetSize($fullRemotePathfolderTarget)
						endif
						$sizeSource=DirGetSize($fullRemotePathfolderSource)
						if $sizeSource > -1 And  $sizetarget > -1 Then
							_checkPause()
							_CheckClearConsole()
							If $hotKeyKill=1 Then Return false
;~ 							$withFolders=0
							$folderLast=0
							If _checkDirContent($fullRemotePathfolderSource,$filter,$folderLast,$olderdays,$withFolders,$RemoteDriveTarget,"COPY")=0 Then
								MemoWrite($iMemo,@TAB & "Folder/Files will be " & $MesagCopy & " AT JOB RUNTIME  "& $fullRemotePathSource & "   to   " & _
								$fullRemotePathfolderTarget & $additionalMSG,"blue")
								;test copy
								_StatusPercent()
								$arrCopyFileFldr=""
								$arrCopyFileFldr=_GetDirContent($fullRemotePathfolderSource,$filter,$folderLast,$olderdays,$withFolders,0)
								For $i=1 To UBound($arrCopyFileFldr)-1
									_checkPause()
									_CheckClearConsole()
									If $hotKeyKill=1 Then Return false
									_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Testing Job", 0)
									_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,$MesagCopy&"ing "&$arrCopyFileFldr[$i]&"  "&$i&"/"&UBound($arrCopyFileFldr)-1, 1)
									If $rCopyMode="[C]" Then CopyTest($arrCopyFileFldr[$i],$fullRemotePathfolderTarget,$fullRemotePathfolderSource,$rBehaviour,$rCopyMode)
									If $rCopyMode="[MV]" Then CopyTest($arrCopyFileFldr[$i],$fullRemotePathfolderTarget,$fullRemotePathfolderSource,$rBehaviour,$rCopyMode)
									If $rCopyMode="[M]" Then CopyTest($arrCopyFileFldr[$i],$fullRemotePathfolderTarget,$fullRemotePathfolderSource,$rBehaviour,$rCopyMode)
									_CheckConsoleLines($i)
									_StatusPercent($i,$arrCopyFileFldr)
								next
							Else
								Return true
							endif
						Else
							$MesagCopyx=$MesagCopy
							If StringInStr($MesagCopy,"copy") Then $MesagCopyx="copi"
							MemoWrite($iMemo,@TAB & "Folder/Files do not exist and WON'T BE "& StringUpper($MesagCopyx) & "ED "& $fullRemotePathSource ,"orange")
						endif
						$res=DriveMapDel($RemoteDriveSource)
						If Not $res Then
							MemoWrite($iMemo,@TAB & "Drive cannot be UnMounted " & $RemoteDriveSource ,"Red",8,1)
						EndIf
					Else
						MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* " & @crlf,"Red",8,1)
						Return true
					endif
				Else
					MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* " & @crlf,"Red",8,1)
					If $RunFail=1 AND _checkIf2Hold( "Mapping Error . " )=True Then Return true
					Return false
				endif
			EndIf
			#endregion
			#region f################################     RUN    ###################################
			If $Action="run" Then
				ConsoleWrite('_Run_Copy() =  $Action ='& $Action & @crlf )
				_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Running Job", 0)
				MemoWrite($iMemo,@TAB & $MesagCopy &" options: " & $additionalMSG,"black",9,1)
				MemoWrite($iMemo,@TAB & $MesagCopy &" of  "& $fullRemotePathSource & "    To   "&  $fullRemotePathfolderTarget & $additionalMSG)
				$rescheckmap=true
				If _CheckMap($RemoteDriveSource,$userP,$passP,"Source Path") Then
					If ($RemoteDriveSource<>$RemoteDriveTarget) Then $rescheckmap=_CheckMap($RemoteDriveTarget,$userT,$passT,"Target Path")
					If $rescheckmap Then
						$fullRemotePathfolderSourceOK=0
						$fullRemotePathfolderTargetOK=0
						If DirGetSize($fullRemotePathfolderSource) > -1  Then
							$fullRemotePathfolderSourceOK=1
						Else
							MemoWrite($iMemo,@TAB & "Folder do not exist .  "& $fullRemotePathfolderSource,"orange")
						endif

						If $rFolderPerSource=1 Then
							$sizetarget=DirGetSize($fullRemotePathfolderTargetCkeck)
						else
							$sizetarget=DirGetSize($fullRemotePathfolderTarget)
						endif
						If $sizetarget> -1 Then
							$fullRemotePathfolderTargetOK=1
						Else
							MemoWrite($iMemo,@TAB & "Folder do not exist .  "& $fullRemotePathfolderTarget,"orange")
						endif

						If 	$fullRemotePathfolderSourceOK<1 Then
							_createDIR($fullRemotePathfolderSource)
							If DirGetSize($fullRemotePathfolderSource) > -1 Then
								MemoWrite($iMemo,@TAB & "Folder created successfully tested. "& $fullRemotePathfolderSource,"Darkgreen",10,1)
								$fullRemotePathfolderSourceOK=1
							Else
								MemoWrite($iMemo,@TAB & "Folder NOT created. "& $fullRemotePathfolderSource )
								MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* "  & @crlf,"Red",8,1)
							endif
						endif

						If 	$fullRemotePathfolderTargetOK<1 Then
							_createDIR($fullRemotePathfolderTarget)
							If DirGetSize($fullRemotePathfolderTarget) > -1 Then
								MemoWrite($iMemo,@TAB & "Folder created successfully tested. "& $fullRemotePathfolderTarget,"Darkgreen",10,1)
								$fullRemotePathfolderTargetOK=1
							Else
								MemoWrite($iMemo,@TAB & "Folder NOT created. "& $fullRemotePathfolderTarget )
								MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* "  & @crlf,"Red",8,1)
							endif
						endif

						If 	$fullRemotePathfolderTargetOK=1 And $fullRemotePathfolderSourceOK=1  Then
							_checkPause()
							_CheckClearConsole()
							If $hotKeyKill=1 Then Return false
;~ 							$withFolders=0
							$folderLast=0
							If _checkDirContent($fullRemotePathfolderSource,$filter,$folderLast,$olderdays,$withFolders,$RemoteDriveTarget,"COPY")=0 Then
								MemoWrite($iMemo,@TAB & $MesagCopy&"ing  "& $fullRemotePathSource & "   to   " & $fullRemotePathfolderTarget & $olderdaysmgg ,"blue")
								_checkPause()
								_CheckClearConsole()
								If $hotKeyKill=1 Then Return false
								$arrCopyFileFldr=""
								$arrCopyFileFldr=_GetDirContent($fullRemotePathfolderSource,$filter,$folderLast,$olderdays,$withFolders,0)
								If $rCopyMode="[M]" Then  ;boletear target ================================================================
									MemoWrite($iMemo,@TAB & "Deleting Folder content for MIRRORING  "&$fullRemotePathfolderTarget ,"black",9,1)
									_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Running Job", 0)
									_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Deleting Folder content for MIRRORING  "&$fullRemotePathfolderTarget, 1)
									;----------------------------------
									$RunFail=0
									$filter="*"
									$rrecursivo=1
									$folderLast=1
;~ 									$withFolders=0
									If _checkDirContent($fullRemotePathfolderTarget,$filter,$folderLast,$olderdays,$withFolders)=0 Then
										$arrDel=""
										$arrDel=_GetDirContent($fullRemotePathfolderTarget,$filter,$folderLast,$olderdays,$withFolders,0)
										_StatusPercent()
										For $i=1 To UBound($arrDel)-1
											If $arrDel[$i]<>"" then
												_checkPause()
												_CheckClearConsole()
												If $hotKeyKill=1 Then Return false
												_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Deleting "&$arrDel[$i]&"  "&$i&"/"&UBound($arrDel)-1, 1)
												_DeleteDIRFILE($arrDel[$i])
												_StatusPercent($i,$arrDel)
												If FileExists($arrDel[$i])=0 Then
												Else
													MemoWrite($iMemo,@TAB&"               An Error occurred , please check credentials and path. => "& $arrDel[$i] ,"Red",8,1)
													$RunFail=1
												endif
												_CheckConsoleLines($i)
											endif
										next
									endif
									;------------------
									If $RunFail=0 Then
										MemoWrite($iMemo,@TAB & "All Files/Folders Were deleted successfully . pre Mirroring","Darkgreen",8,1)
										MemoWrite($iMemo,@TAB & "_____________________________________________","Darkgreen",8,1)
									Else
										MemoWrite($iMemo,@TAB & "No All Files/Folders Were deleted before MIRRORING.","Red",12,1)
										If $RunFail=1 AND _checkIf2Hold( "Folder Deletion Error before mirroring. " )=False Then return
									endif
								endif
								_StatusPercent()
								$TasKCopyCounter=0
								For $i=1 To UBound($arrCopyFileFldr)-1
									_checkPause()
									_CheckClearConsole()
									If $hotKeyKill=1 Then Return false
									_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Running Job", 0)
									_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,$MesagCopy&"ing "&$arrCopyFileFldr[$i]&"  "&$i&"/"&UBound($arrCopyFileFldr)-1, 1)
									If $rCopyMode="[C]" Then CopyProcess($arrCopyFileFldr[$i],$fullRemotePathfolderTarget,$fullRemotePathfolderSource,$rBehaviour,$rCopyMode)
									If $rCopyMode="[MV]" Then CopyProcess($arrCopyFileFldr[$i],$fullRemotePathfolderTarget,$fullRemotePathfolderSource,$rBehaviour,$rCopyMode)
									If $rCopyMode="[M]" Then CopyProcess($arrCopyFileFldr[$i],$fullRemotePathfolderTarget,$fullRemotePathfolderSource,$rBehaviour,$rCopyMode)
									_CheckConsoleLines($i)
									_StatusPercent($i,$arrCopyFileFldr)
								next
								$MesageCopy=" Copied "
								If $rCopyMode="[MV]" Then $MesageCopy=" Moved "
								If $rCopyMode="[M]" Then $MesageCopy=" Mirrored "
								If $TasKCopyCounter=UBound($arrCopyFileFldr)-1 Then ; all copyed / moved ok
									If $rCopyMode="[MV]" Then
										$folderDelCounter=0
										For $i=1 To UBound($arrCopyFileFldr)-1
											If _IsFolder($arrCopyFileFldr[$i]) Then
												If _DeleteDIRFILE($arrCopyFileFldr[$i]) Then
												Else
													$folderDelCounter=$folderDelCounter+1
												EndIf
											endif
										next
										If $folderDelCounter=0 Then
											MemoWrite($iMemo,@TAB & "All Files/Folders Were"& $MesageCopy & "successfully ","Darkgreen",12,1)
										Else
											MemoWrite($iMemo,@TAB & "All Files/Folders Were"& $MesageCopy & "successfully But Source was not deleted successfully","Orange",12,1)
											$RunFail=1
										EndIf
									Else
										MemoWrite($iMemo,@TAB & "All Files/Folders Were"& $MesageCopy & "successfully ","Darkgreen",12,1)
									endif
								Else
									MemoWrite($iMemo,@TAB & "Not All Files/Folders Were"& $MesageCopy & " ","Red",12,1)
									$RunFail=1
								endif
							Else
								Return true
							endif
						Else
							Return False
						endif
						$res=DriveMapDel($RemoteDriveSource)
						If Not $res Then
							MemoWrite($iMemo,@TAB & "Drive cannot be UnMounted " & $RemoteDriveSource ,"Red",8,1)
						EndIf
					Else
						MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* " & @crlf ,"Red",8,1)
						Return true
					endif
				Else
					MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* " & @crlf ,"Red",8,1)
					If $RunFail=1 AND _checkIf2Hold( "Mapping Error . " )=True Then Return true
					Return false
				endif
			EndIf
			return true
			#endregion ######################################################################
		EndFunc
	#endregion
	#region f==================================== Execute             ==============================
		Func _Run_Exwcute($targetLoc,$targetPath,$arrCommandLines,$arrExtraFiles,$Action,$userT="",$passT="",$userP="",$passP="")
			#region f################################     INIT   ###################################
				ConsoleWrite('++_Run_Exwcute() ='& @crlf )
				;separation de C$ admin share fron remote path
				$arrPath=StringSplit($targetPath,":\",1)
				$srvipmsg=_GetTarget($targetLoc,"Target ")
				MemoWrite($iMemo,@TAB & "Using  "& $userT & " credentials")
				If $arrPath[0]>1 Then  ;normal folder
					$RemoteDrive="\\"&$srvipmsg[0]&"\"&$arrPath[1]&"$"   ; \\server\c$
					$fullRemotePath=$RemoteDrive & "\" & $arrPath[2]   ;\\server\c$\folderToCreate
				Else  ; share
					$RemoteDrive=$targetLoc ; \\server\share
					$fullRemotePath=$targetLoc&$targetPath      ;\\server\share\folderToCreate
				EndIf
				;script command list diferentiation
				$ScriptCommandLinesIS=StringRegExp($arrCommandLines[1],'^SCRIPT',0)
				if $ScriptCommandLinesIS then
					$iscriptFullSourcePath=StringRegExpReplace($arrCommandLines[1],'^SCRIPT',"")
					$iscriptSourcePathDir=GetDir($iscriptFullSourcePath)
					$iscriptFilename=GetFileName($iscriptFullSourcePath)
				Else
					$iscriptSourcePathDir=$tempDir
					$iscriptFilename="MinionCommands.min"
					$iscriptFullSourcePath=$iscriptSourcePathDir&"\"&$iscriptFilename
					if _createScriptFromCommands($arrCommandLines,$iscriptFullSourcePath) then
					Else
						$RunFail=1
						Return false
					endif
				endif

				$descArrCommandLines=_ArrayToString($arrCommandLines," |-| ")
				$descArrExtraFiles=_ArrayToString($arrExtraFiles," |-| ")
				If $showDesc Then _WriteReportCSV("","","",$targetLoc,$targetPath,$descArrCommandLines,$userP,$userT,$descArrExtraFiles,$srvipmsg[1])
			#endregion
			#region f################################     SHOW   ###################################
			If $Action="show" Then
				If $CSVreport=0 Or $showDesc Then
					ConsoleWrite('_Run_Exwcute() =  $Action ='& $Action & @crlf )
	;~ 				_CheckDirAccess("\\"&$targetLoc&"\"&$arrPath[1]&"$") ;unit test
					MemoWrite($iMemo,@TAB & "Working folder "& $fullRemotePath & "   (Folder will be created if not existent)")
					if $ScriptCommandLinesIS then
						MemoWrite($iMemo,@TAB & "Running Script: "& $iscriptFilename & "  from source: " & $iscriptSourcePathDir)
					Else
						MemoWrite($iMemo,@TAB & "Running Commands :")
						for $is=1 to UBound($arrCommandLines)-1
							MemoWrite($iMemo,@TAB & @TAB & $arrCommandLines[$is])
						next
						MemoWrite($iMemo,@TAB & "Extra Files :")
						for $is=1 to UBound($arrExtraFiles)-1
							MemoWrite($iMemo,@TAB & @TAB & $arrExtraFiles[$is])
						next
					endif
				endif
			EndIf
			#endregion
			#region f################################     TEST   ###################################
			If $Action="test" Then
				ConsoleWrite('_Run_Exwcute() =  $Action ='& $Action & @crlf )
				_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Testing Job", 0)
				#region check Script existence
				$iscriptFullSourcePath=$iscriptSourcePathDir&"\"&$iscriptFilename
					if _checkScriptExistence($iscriptFullSourcePath) = false then
						MemoWrite($iMemo,@TAB & "The job will stop AT JOB RUNTIME since the execution script was not found." ,"red",10,1)
					endif
				#endregion
				#region check extra files existence and size
					$totalsize=0
					if _checkExtraFiles($arrExtraFiles,$totalsize) = false then
						MemoWrite($iMemo,@TAB & "The job will stop AT JOB RUNTIME since some extra files where not found." ,"red",10,1)
					endif
				#endregion
				#region check maping
				If _CheckMap($RemoteDrive,$userT,$passT) Then
					If $hotKeyKill=1 Then Return false

;~ 					#region working folder
;~ 						If DirGetSize($fullRemotePath) = -1 Then
;~ 							MemoWrite($iMemo,@TAB & "Remote working Folder will be created AT JOB RUNTIME "& $fullRemotePath ,"orange")
;~ 						Else
;~ 							MemoWrite($iMemo,@TAB & "Remote working Folder already exist. "& $fullRemotePath,"blue")
;~ 						endif
;~ 					#endregion
;~ 					#region check disk size
;~ 						if _checkIfEnoughDiskSize($RemoteDrive,$totalsize) = false then
;~ 							MemoWrite($iMemo,@TAB & "The job will stop AT JOB RUNTIME since not enought space at remote." ,"red",10,1)
;~ 						endif
;~ 					#endregion
					#region Files Copy delete Checks
						#region create working folder
							If DirGetSize($fullRemotePath) = -1 Then
								_checkPause()
								_CheckClearConsole()
								If $hotKeyKill=1 Then Return false
								if _CheckcreateDIR($fullRemotePath) = false then
									$RunFail=1
									Return false
								endif
							Else
								MemoWrite($iMemo,@TAB & "Remote working Folder already exist. "& $fullRemotePath,"blue")
							endif
						#endregion
						#region check disk size
							if _checkIfEnoughDiskSize($RemoteDrive,$totalsize) = false then
								MemoWrite($iMemo,@TAB & "The job will stop AT JOB RUNTIME since not enought space at remote." ,"red",10,1)
								$RunFail=1
								Return false
							endif
						#endregion
						#region check Minion copy
							MemoWrite($iMemo,@TAB & "Checking Minion executable copy.","blue")
							if _checkMinionCopy($fullRemotePath) = false then
;~ 								$RunFail=1
;~ 								Return false
							endif
						#endregion
						#region check Minion Delete
							if _checkMinionDelete($fullRemotePath) = false then
;~ 								$RunFail=1
;~ 								Return false
							endif
						#endregion
						#region check script copy
							MemoWrite($iMemo,@TAB & "Checking Script copy.","blue")
							if _checkScriptCopy($iscriptFullSourcePath,$fullRemotePath) = false then
;~ 								$RunFail=1
;~ 								Return false
							endif
						#endregion
						#region check script Delete
							if _checkScriptDelete($iscriptFilename,$fullRemotePath) = false then
;~ 								$RunFail=1
;~ 								Return false
							endif
						#endregion
						#region check extra files copy
							MemoWrite($iMemo,@TAB & "Checking Extra files copy.","blue")
							if _checkExtraFilesCopy($arrExtraFiles,$fullRemotePath) = false then
;~ 								$RunFail=1
;~ 								Return false
							endif
						#endregion
						#region check extra files Delete
							if _checkExtraFilesDelete($arrExtraFiles,$fullRemotePath) = false then
;~ 								$RunFail=1
;~ 								Return false
							endif
						#endregion
					#endregion
					$res=DriveMapDel($RemoteDrive)
					If Not $res Then
						MemoWrite($iMemo,@TAB & "Drive cannot be UnMounted " & $RemoteDrive ,"Red",8,1)
					EndIf
				Else
					MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* "  & @crlf&@TAB&$RemoteDrive & @crlf,"Red",8,1)
					If $RunFail=1 AND _checkIf2Hold( "Mapping Error . " )=True Then Return true
					Return false
				endif
				#endregion
			EndIf
			#endregion
			#region f################################     RUN    ###################################
			If $Action="run" Then
				ConsoleWrite('_Run_Exwcute() =  $Action ='& $Action & @crlf )
				_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Running Job", 0)
				#region check Script existence
					if _checkScriptExistence($iscriptFullSourcePath) = false then
						$RunFail=1
						Return false
					endif
				#endregion
				#region check extra files existence and size
					$totalsize=0
					if _checkExtraFiles($arrExtraFiles,$totalsize) = false then
						$RunFail=1
						Return false
					endif
				#endregion
				#region check maping
					If _CheckMap($RemoteDrive,$userT,$passT) Then
						If $hotKeyKill=1 Then Return false
						#region create working folder
							If DirGetSize($fullRemotePath) = -1 Then
								_checkPause()
								_CheckClearConsole()
								If $hotKeyKill=1 Then Return false
								if _CheckcreateDIR($fullRemotePath) = false then
									$RunFail=1
									Return false
								endif
							Else
								MemoWrite($iMemo,@TAB & "Remote working Folder already exist. "& $fullRemotePath,"blue")
							endif
						#endregion
						#region check disk size
							if _checkIfEnoughDiskSize($RemoteDrive,$totalsize) = false then
								$RunFail=1
								Return false
							endif
						#endregion
						#region check Minion copy
							MemoWrite($iMemo,@TAB & "Checking Minion executable copy.","blue")
							if _checkMinionCopy($fullRemotePath) = false then
								$RunFail=1
								Return false
							endif
						#endregion
						#region check script copy
							MemoWrite($iMemo,@TAB & "Checking Script copy.","blue")
							if _checkScriptCopy($iscriptFullSourcePath,$fullRemotePath) = false then
								$RunFail=1
								Return false
							endif
						#endregion
						#region check extra files copy
							MemoWrite($iMemo,@TAB & "Checking Extra files copy.","blue")
							if _checkExtraFilesCopy($arrExtraFiles,$fullRemotePath) = false then
								$RunFail=1
								Return false
							endif
						#endregion
						#region start execution
							$servername=_getServerFromPath($fullRemotePath)
							if _checkStartMinion($serverName,$targetPath,$iscriptFilename,$userT,$passT) = false then
								$RunFail=1
								Return false
							endif
						#endregion
						#region get execution data

						#endregion

						#region delete files
;~ 							#region check Minion Delete
;~ 								if _checkMinionDelete($fullRemotePath) = false then
;~ 	;~ 								$RunFail=1
;~ 	;~ 								Return false
;~ 								endif
;~ 							#endregion
;~ 							#region check script Delete
;~ 								if _checkScriptDelete($iscriptFilename,$fullRemotePath) = false then
;~ 	;~ 								$RunFail=1
;~ 	;~ 								Return false
;~ 								endif
;~ 							#endregion
;~ 							#region check extra files Delete
;~ 								if _checkExtraFilesDelete($arrExtraFiles,$fullRemotePath) = false then
;~ 	;~ 								$RunFail=1
;~ 	;~ 								Return false
;~ 								endif
;~ 							#endregion
						#endregion
						$res=DriveMapDel($RemoteDrive)
						If Not $res Then
							MemoWrite($iMemo,@TAB & "Drive cannot be UnMounted " & $RemoteDrive ,"Red",8,1)
						EndIf
					Else
						MemoWrite($iMemo,@TAB&" An Error occurred , please check credentials and path."  & @crlf&@TAB&$RemoteDrive & @crlf,"Red",8,1)
						If $RunFail=1 AND _checkIf2Hold( "Mapping Error . " )=True Then Return true
						Return false
					endif
				#endregion
			EndIf
			#endregion ##############################################################################
			return true
		EndFunc
	#endregion
	#region f==================================== Deploy Agent    ==============================
		Func _Run_DeployAgent($targetLoc,$InInstall,$Action,$userT="",$passT="")
			#region f################################     INIT   ###################################
			ConsoleWrite('!!++_Run_DeployAgent() ='& @crlf )
			;separation de C$ admin share fron remote path
			$srvipmsg=_GetTarget($targetLoc,"Target ")
			MemoWrite($iMemo,@TAB & "Using  "& $userT & " credentials")
			$RemoteDrive="\\"&$srvipmsg[0]&"\c$"   ; \\server\c$
			$fullRemotePath=$RemoteDrive & "\Program Files\FGMagent"    ;\\server\c$\program files
			#endregion
			If $showDesc Then _WriteReportCSV("","","",$targetLoc,$fullRemotePath,"","",$userT,$Deployagent,$srvipmsg[1])
			#region f################################     SHOW   ###################################
			If $Action="show" Then
				If $CSVreport=0 Or $showDesc Then
					ConsoleWrite('_Run_DeployAgent() =  $Action ='& $Action & @crlf )
					MemoWrite($iMemo,@TAB & $Deployagent & " Agent at "& $fullRemotePath )
				endif
			EndIf
			#endregion
			#region f################################     TEST   ###################################
			If $Action="test" Then
				ConsoleWrite('_Run_DeployAgent() =  $Action ='& $Action & @crlf )
				_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Testing Job", 0)
				If _CheckMap($RemoteDrive,$userT,$passT) Then
					If $hotKeyKill=1 Then Return false
					If $InInstall Then
						If FileExists ($fullRemotePath&"\FGMagent.exe") = -1 Then
							MemoWrite($iMemo,@TAB & "FGM Agent executable already exist and will be updated with last version at "& $fullRemotePath,"blue")
						Else
							MemoWrite($iMemo,@TAB & "FGM Agent executable will be installed AT JOB RUNTIME in "& $fullRemotePath ,"orange")
						endif
					Else
						If FileExists ($fullRemotePath&"\FGMagent.exe") = -1 Then
							MemoWrite($iMemo,@TAB & "FGM Agent executable exist and will be uninstalled "& $fullRemotePath,"blue")
						Else
							MemoWrite($iMemo,@TAB & "FGM Agent executable is not installed in "& $fullRemotePath ,"orange")
						endif
					endif

					$res=DriveMapDel($RemoteDrive)
					If Not $res Then
						MemoWrite($iMemo,@TAB & "Drive cannot be UnMounted " & $RemoteDrive ,"Red",8,1)
					EndIf
				Else
					MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* "  & @crlf,"Red",8,1)
					If $RunFail=1 AND _checkIf2Hold( "Mapping Error . " )=True Then Return true
					Return true
				endif
			EndIf
			#endregion
			#region f################################     RUN    ###################################
			If $Action="run" Then
				ConsoleWrite('_Run_DeployAgent() =  $Action ='& $Action & @crlf )
				_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Running Job", 0)
				If _CheckMap($RemoteDrive,$userT,$passT) Then
					_checkPause()
					_CheckClearConsole()
					If $hotKeyKill=1 Then Return false
					MemoWrite($iMemo,@TAB & "FGM Agent - Deploy. Action= "& $Deployagent& $fullRemotePath,"Darkgreen",8,1)
					#region install agent
					If $InInstall Then
						If FileExists ($fullRemotePath&"\FGMagent.exe") = -1 Then
							MemoWrite($iMemo,@TAB & "FGM Agent executable already exist at "& $fullRemotePath,"blue")
						Else
							; create dir
								_createDIR($fullRemotePath)
								If DirGetSize($fullRemotePath) > -1 Then
								Else
									MemoWrite($iMemo,@TAB & "FGM Agent - Folder NOT created. "& $fullRemotePath )
									MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* "  & @crlf,"Red",8,1)
									$RunFail=1
									Return false
								endif
							; copy executable
								If FileCopy($FgmDataFolder & "\FGMagent.exe",$fullRemotePath & "\FGMagent.exe",1+8) = 1 Then
									MemoWrite($iMemo,@TAB & "FGM Agent - Agent copied ok . ","Darkgreen",8,1)
								Else
									MemoWrite($iMemo,@TAB & "FGM Agent - Agent NOT copied to "& $fullRemotePath )
									MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* "  & @crlf,"Red",8,1)
									$RunFail=1
									Return false
								endif
						endif
						;start process
								$serverName=$targetLoc
								if Not _StartFGMagent($serverName,$userT,$passT) Then
									$RunFail=1
									Return false
								endif
						MemoWrite($iMemo,@TAB & "FGM Agent - executable was instaled OK at "& $fullRemotePath ,"Darkgreen",10,1)
					#endregion
					Else
					#region uninstall agent
						; delete executable
						If FileExists ($fullRemotePath&"\FGMagent.exe") = 1 Then
							If _DeleteDIR($fullRemotePath,0,1) Then
								MemoWrite($iMemo,@TAB & "FGM Agent - executable was successfully deleted from "& $fullRemotePath,"Darkgreen",8,1)
							Else
								MemoWrite($iMemo,@TAB & "FGM Agent - executable cannot be deleted from "& $fullRemotePath,"red")
							Endif
						Else
							MemoWrite($iMemo,@TAB & "FGM Agent - executable is not installed in "& $fullRemotePath ,"orange",8,1)
						endif
						;delete service
						_UninstallServiceFGM($userT,$passT)
					#endregion
					endif


					$res2=DriveMapDel($RemoteDrive)
					If Not $res2 Then
						MemoWrite($iMemo,@TAB & "Drive cannot be UnMounted " & $RemoteDrive,"Red",8,1)
					Return false
					EndIf
				Else
					MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path.********* "  & @crlf,"Red",8,1)
					If $RunFail=1 AND _checkIf2Hold( "Mapping Error . " )=True Then Return true
					Return false
				endif
			EndIf
			return true
			#endregion ##############################################################################
		EndFunc
	#endregion
#endregion
#region  ----------------     model     ---------------------------------------------------------------------------------------------------------
	Func _getJobTasks()
		ConsoleWrite('++_getJobTasks() = '& @crlf )
		$query='SELECT distinct(taskuid),tasktype,taskname,active FROM tasks WHERE jobuid=' & $jobid & ' ORDER BY taskorder ASC;'
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) and UBound($qryResult)>1 then
			Return $qryResult
		Else
			Return ""
		endif
	EndFunc
	Func _get_UnitByVertice($vert,$run_taskid)
		ConsoleWrite('++_get_UnitByVertice() = '& @crlf )
		$query='SELECT unit FROM tasks WHERE vertice="' & $vert & '" AND taskuid=' & $run_taskid & ';'
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) and UBound($qryResult)>1 then
			_printFromArray($qryResult,"_get_UnitByVertice")
			Return $qryResult
		Else
			Return ""
		endif
	EndFunc
	Func _get_TypeByVertice($vert,$run_taskid)
		ConsoleWrite('++_get_UnitByVertice() = '& @crlf )
		$query='SELECT type FROM tasks WHERE vertice="' & $vert & '" AND taskuid=' & $run_taskid & ';'
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) and UBound($qryResult)>1 then
			Return $qryResult
		Else
			Return ""
		endif
	EndFunc
	Func _get_UnitFilterByVertice($vert,$run_taskid)
		ConsoleWrite('++_get_UnitFilterByVertice() = '& @crlf )
		$query='SELECT unit,filter FROM tasks WHERE vertice="' & $vert & '" AND taskuid=' & $run_taskid & ';'
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) and UBound($qryResult)>1 then
			Return $qryResult
		Else
			Return ""
		endif
	EndFunc
	Func _get_UserCred($vertice,$run_taskid,$server)
		ConsoleWrite('++_get_UserCred() = ' & " - " & $vertice & " - " & $run_taskid & " - " &$server & @crlf )
		Dim $arrcred[4]=["","","",""]
		$query='SELECT distinct(domain||"\"||login) FROM tasks WHERE taskuid="' & $run_taskid & '" AND vertice="' & $vertice & '";'
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) And UBound($qryResult)=2 then
			$userdom=$qryResult[1][0]
			$userdom=_GetUserT($userdom,$server)
			$arrcred=StringSplit($userdom,"\")
			If $arrcred[0]<>"-" then
				$pass=_get_passwdRUNfunctions($arrcred[1],$arrcred[2])
				_ArrayAdd($arrcred,$pass)
				Return $arrcred
			Else
				Return $arrcred
			endif
		Else
			Return $arrcred
		endif
	EndFunc
	Func _get_passwdRUNfunctions($domain,$user)
		ConsoleWrite('++_get_passwdRUNfunctions() = '&$domain&" - "& $user& @crlf )
		$domainencripted=_Hashing($domain,0)
		$userencripted=_Hashing($user,0)
		$query='SELECT password FROM credentials WHERE  domain="'&$domainencripted&'" AND userid="'&$userencripted&'" ;'
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) then
			if  UBound($qryResult)>1 then
				Return _Hashing($qryResult[1][0],1)
			endif
		endif
		Return ""
	EndFunc
;~ 	Func _get_passwd($domain,$user)
;~ 		ConsoleWrite('++_get_passwd() = '&$domain&" - "& $user& @crlf )
;~ 		$domainencripted=_Hashing($domain,1)
;~ 		$userencripted=_Hashing($user,1)
;~ 		$query='SELECT password FROM credentials WHERE  domain="'&$domainencripted&'" AND login="'&$userencripted&'" ;'
;~ 		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
;~ 		If  IsArray($qryResult) then
;~ 			if  UBound($qryResult)>1 then
;~ 				Return _Hashing($qryResult[1][0],1)
;~ 			endif
;~ 		endif
;~ 		Return ""
;~ 	EndFunc
	Func _WriteReportCSV($sourceLoc,$sourcePath,$sourcefilter,$targetLoc,$targetPath,$targetZipFile,$userP,$userT,$Behaviour,$additionalMSG)
		ConsoleWrite('++_WriteReportCSV() = '& @crlf)
		If $CSVreport Then
;~ 			Columns:
;~ 			Job Name			<=>		GUICtrlRead($TXT_JobCreation_jobname)
;~ 			task name			<=>		$arrsql[$iRows][2]
;~ 			task type			<=>		$taskType
;~ 			Is Enabled			<=>		$taskActive 0-1
;~ 			task description	<=>
;~ 			sourcepath			<=>		$arrSourcePathfilter[$isp][0]
;~ 			targetpath			<=>		$arrTargetPath[$j][0]
;~ 			details				<=>		?????????????????????
;~ 			sourcecredentials	<=>		$userT
;~ 			targetcredentials	<=>		$userP
;~ 			Action				<=>		$Action
;~ 			targetLoc			<=>		$arrTargetLOC[$i][0]
;~ 			sourceLoc			<=>		$arrSourceLOC[$isl][0]
;~ 			$sourcefilter		<=>		$arrSourcePathfilter[$isp][1]
;~ 			targetZipFile		<=>		$arrTargetPath[$itp][1]
;~ 			filter				<=>		$arrSourcePathfilter[$isp][0]
;~ 			Behaviour			<=>		$arrTargetPath[$itp][1]
			$CSVline=GUICtrlRead($TXT_JobCreation_jobname) & "," & _   ;Job Name
					$run_taskid		& "," & _						;task id
					$taskType		& "," & _						;task type
					$TaskName		& "," & _						;task name  task description
					$taskEnabled		& "," & _					;Is Enabled
					$sourceLoc		& "," & _						;Source Location
					$sourcePath		& "," & _						;Source Path
					$sourcefilter	& "," & _						;source filter
					$targetLoc		& "," & _						;Target Location
					$targetPath		& "," & _						;Target Path
					$targetZipFile	& "," & _						;Target Zip file
					$userP			& "," & _						;Source user
					$userT			& "," & _						;Target user
					$Behaviour		& "," & _						;Behaviour
					$additionalMSG									;$additionalMSG
;~ 			ConsoleWrite($CSVline & @crlf)
			FileWriteLine($FGMtaskReport,$CSVline)
		EndIf
	EndFunc
	Func _GetTargetIP($trgt)
		ConsoleWrite('++_GetTargetIP() = '& $trgt& @crlf)
		$query='SELECT ip from servers where servername="'& $trgt & '" ;'
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) then
			If UBound($qryResult)>1 then
				Return $qryResult[1][0]
			Else
				Return $trgt
			endif
		endif
		return $trgt
	EndFunc
	Func _GetTarget($trgt,$msgorig)
		ConsoleWrite('++_GetTarget() = '& $trgt& @crlf)
		Dim $info[2]
		$srvip=_GetTargetIP($trgt)
		if _IsValidIP($srvip) then
			$ipMSG=$msgorig&":"&@tab& " Using stored Server IP: "& $trgt & " = " & $srvip
		Else
			$ipMSG=$msgorig&":"&@tab& " Using Server FQDN: "& $trgt
			$srvip=$trgt
		EndIf
;~ 		MemoWrite($iMemo,@TAB & $ipMSG,"black",8,0,0,0)
		MemoWrite($iMemo,@TAB & $ipMSG,"black",8,0)
		$info[0]=$srvip
		$info[1]=$ipMSG
		return $info
	EndFunc
#endregion
#region -----------------     executers --------------------------------------------------------------------------------------------------------
	#region execution tasks
		Func _createScriptFromCommands($arrCommandLines,$iscriptFullSourcePath)
			ConsoleWrite('++_createScriptFromCommands() = '& @crlf)
			Local $ScriptfileH = FileOpen($iscriptFullSourcePath, 2+8)
			If $ScriptfileH = -1 Then
				$res1=false
			Else
				for $is=1 to UBound($arrCommandLines)-1
					FileWriteLine($ScriptfileH, $arrCommandLines[$is])
				next
				FileClose($ScriptfileH)
				$res1=true
			EndIf

			If $res1 Then
				return true
			Else
				MemoWrite($iMemo,@TAB & "Error creating Script from commands. Aborting execution." ,"red",10,1)
				return false
			EndIf
		EndFunc
		Func _checkExtraFiles($arrExtraFiles,ByRef $totalsize)
			ConsoleWrite('++_checkExtraFiles() = '& @crlf)
			MemoWrite($iMemo,@TAB & "Checking extra files:","blue")
			$flg1=0
			for $exF=1 to UBound($arrExtraFiles)-1
				$extrafile=$arrExtraFiles[$exF]
				if FileExists($extrafile) then
					MemoWrite($iMemo,@TAB & @TAB & $extrafile  ,"Darkgreen")
					$size=FileGetSize($extrafile)
					if $size >0 then
						$totalsize=$totalsize+$size
					endif
				Else
					MemoWrite($iMemo,@TAB & @TAB & "File not found. "& $extrafile,"red")
					$flg1=1
				endif
			next
			MemoWrite($iMemo,@TAB & @TAB & "Extra files total size: "& _ByteSuffix($totalsize)  ,"blue")
			if $flg1=1 then
				MemoWrite($iMemo,@TAB & "Some extra files where not found." ,"red",10,1)
				return false
			endif
			return true
		EndFunc
		Func _checkIfEnoughDiskSize($RemoteDrive,ByRef $totalsize)
			ConsoleWrite('++_checkIfEnoughDiskSize() $RemoteDrive= '& $RemoteDrive & @crlf)
			MemoWrite($iMemo,@TAB & "Checking disk free space:","blue")
			$rsize=_checkDiskSize($RemoteDrive)
			if IsArray($rsize) then
				$remotesize=$rsize[0]
			Else
				$remotesize=DirGetSize($RemoteDrive)
			endif
			if $remotesize=-1 Then
				MemoWrite($iMemo,@TAB &@TAB & "Remote disk free space Check error. ","red",10,1)
				return false
			endif
			if $remotesize>$totalsize then
				MemoWrite($iMemo,@TAB & @TAB &"Remote disk free space OK.  Remote:"& _ByteSuffix($remotesize) & "    Space needed:"& _ByteSuffix($totalsize) & "   ","Darkgreen")
				return true
			Else
				MemoWrite($iMemo,@TAB &@TAB & "Remote disk free space not enought. "&  _ByteSuffix($remotesize)  & "    Space needed:"& _ByteSuffix($totalsize) & "   ","red",10,1)
				return false
			endif
		EndFunc
		Func _checkDiskSize($RemoteDrive)
			ConsoleWrite('++_checkDiskSize() $RemoteDrive='& $RemoteDrive & @crlf)
			$RemoteDrive=StringStripWS($RemoteDrive,1+2)
			$server=_getServerFromPath($RemoteDrive)
			$disk=StringRegExp($RemoteDrive,'\\([a-zA-Z]+)\$',1)
			$sCommand='wmic /node:'&$server&' LOGICALDISK GET Name,Size,FreeSpace'
			$var=_GetDOSOutput($sCommand )
			$varArr=StringSplit($var,@crlf,2)
			$varArr=_clearEmptyLinesFromArray($varArr)
			_printFromArray($varArr,"$varArr")
			$titlearr=StringRegExp($varArr[0],'(FreeSpace)\s+?(Name)\s+?(Size)',1)
;~ 			_printFromArray($titlearr,"$titlearr")
			if IsArray($titlearr) then
				for $vr=1 to UBound($varArr)-1
					$lin=StringStripWS($varArr[$vr],1+2+4)
					$lindata=StringSplit($lin," ",2)
					_printFromArray($lindata,"$lindata")
					if $lindata[1]=$disk[0]&":" then return $lindata
				next
				return false
			Else
				return false
			endif
		EndFunc
		Func _CheckcreateDIR($path)
			ConsoleWrite('++_CheckcreateDIR() = '& @crlf )
			$res1=DirCreate($path)
			If $res1 Then
				MemoWrite($iMemo,@TAB & "Working folder created successfully . "& $path ,"Darkgreen",8,1)
				return true
			Else
				MemoWrite($iMemo,@TAB & "Remote working Folder Can't be created.  "& $path ,"RED",10,1)
				return false
			EndIf
		EndFunc
		Func _checkScriptDelete($iscriptFilename,$fullRemotePath)
			ConsoleWrite('++_checkScriptDelete() = '& @crlf )
			sleep(1000)
			$deleteMinionPath=$fullRemotePath& "\"&$iscriptFilename
			$res1= FileDelete($deleteMinionPath)
			If $res1 Then
				MemoWrite($iMemo,@TAB &@TAB & "Execute Script successfully Deleted.   At: "& $deleteMinionPath ,"Darkgreen",8,0)
				return true
			Else
				MemoWrite($iMemo,@TAB & @TAB &"Execute script cannot be deleted from remote.   At: "& $deleteMinionPath,"red",10,1)
				return false
			EndIf
		EndFunc
		Func _checkScriptCopy($iscriptFullSourcePath,$fullRemotePath)
			ConsoleWrite('++_checkScriptCopy() = '& @crlf )
			$res1= FileCopy($iscriptFullSourcePath,$fullRemotePath,1+8)
			If $res1 Then
				MemoWrite($iMemo,@TAB & @TAB &"Execute Script successfully copied.   To: "& $fullRemotePath&"\"&GetFileName($iscriptFullSourcePath) ,"Darkgreen",8,0)
				return true
			Else
				MemoWrite($iMemo,@TAB &@TAB & "Execute script cannot be copied to remote.   To: "& $fullRemotePath,"red",10,1)
				return false
			EndIf
		EndFunc
		Func _checkMinionCopy($fullRemotePath)
			ConsoleWrite('++_checkMinionCopy() = '& @crlf )
			$res1= FileCopy($MinionExecutablePath,$fullRemotePath,1+8)
			If $res1 Then
				MemoWrite($iMemo,@TAB &@TAB & "Execute Minion successfully copied.   To: "& $fullRemotePath ,"Darkgreen",8,0)
				return true
			Else
				MemoWrite($iMemo,@TAB &@TAB & "Execute Minion cannot be copied to remote.   To: "& $fullRemotePath  ,"red",10,1)
				return false
			EndIf
		EndFunc
		Func _checkMinionDelete($fullRemotePath)
			ConsoleWrite('++_checkMinionDelete() = '& @crlf )
			sleep(1000)
			$deleteMinionPath=$fullRemotePath& "\FGMminion.exe"
			$res1= FileDelete($deleteMinionPath)
			If $res1 Then
				MemoWrite($iMemo,@TAB & @TAB & "Execute Minion successfully Deleted.   At: "& $deleteMinionPath ,"Darkgreen",8,0)
				return true
			Else
				MemoWrite($iMemo,@TAB &@TAB &  "Execute Minion cannot be delted from remote.   At: "& $deleteMinionPath  ,"red",10,1)
				return false
			EndIf
		EndFunc
		Func _checkExtraFilesCopy($arrExtraFiles,$fullRemotePath)
			ConsoleWrite('++_checkExtraFilesCopy() = '& @crlf )
			MemoWrite($iMemo,@TAB  & "Copying Extra file/s to remote." ,"blue")
			$flg1=0
			for $exf=1 to  $arrExtraFiles[0]
				$res= FileCopy($arrExtraFiles[$exf],$fullRemotePath&"\",1+8)
				if $res then
					MemoWrite($iMemo,@TAB & @TAB & $arrExtraFiles[$exf]  ,"darkgreen")
				Else
					MemoWrite($iMemo,@TAB & @TAB & "File can't be copied.  "& $arrExtraFiles[$exf],"red",10,1)
					$flg1=1
				endif
			next

			If $flg1=1 Then
				MemoWrite($iMemo,@TAB & "Some extra files Could not be copied.   To: "& $fullRemotePath  ,"red",10,1)
				return false
			Else
				MemoWrite($iMemo,@TAB & "Extra files successfully copied.   To: "& $fullRemotePath ,"Darkgreen",8,0)
				return true
			EndIf
		EndFunc
		Func _checkExtraFilesDelete($arrExtraFiles,$fullRemotePath)
			ConsoleWrite('++_checkExtraFilesDelete() = '& @crlf )
			MemoWrite($iMemo,@TAB & "Deleting Extra file/s from remote." ,"blue")
			$flg1=0
			for $exf=1 to  $arrExtraFiles[0]
				$extrafilename=GetFileName($arrExtraFiles[$exf])
				$extrafileDelete=$fullRemotePath&"\"&$extrafilename
				sleep(1000)
				$res= Filedelete($extrafileDelete)
				if $res then
					MemoWrite($iMemo,@TAB & @TAB & $extrafileDelete  ,"Darkgreen")
				Else
					MemoWrite($iMemo,@TAB & @TAB & "File can't be deleted  "& $extrafileDelete,"red",10,1)
					$flg1=1
				endif
			next

			If $flg1=1 Then
				MemoWrite($iMemo,@TAB & "Some extra files Could not be Deleted   At: "& $extrafileDelete  ,"red",10,1)
				return false
			Else
				MemoWrite($iMemo,@TAB & "Extra files successfully Deleted.   At: "& $fullRemotePath ,"Darkgreen",8,0)
				return true
			EndIf
		EndFunc
		Func _checkScriptExistence($iscriptFullSourcePath)
			ConsoleWrite('++_checkScriptExistence() = '& @crlf )
			MemoWrite($iMemo,@TAB & "Checking Execute Script file:","blue")
			$res1= FileExists($iscriptFullSourcePath)
			If $res1 Then
				MemoWrite($iMemo,@TAB &@TAB & "Execute Script found at source.  "& $iscriptFullSourcePath ,"Darkgreen",8,0)
				return true
			Else
				MemoWrite($iMemo,@TAB &@TAB & "Execute Script cannot be found at source.  "& $iscriptFullSourcePath ,"Red",10,1)
				return false
			EndIf
		EndFunc
		Func _checkStartMinion($serverName,$targetPath,$iscriptFilename,$user,$pass)
			ConsoleWrite('!!++_checkStartExecution() = '& @crlf )
			$MinionExecutable=GetFileName($MinionExecutablePath)
			$sCommand = $targetPath&"\"&$MinionExecutable&"  "&$iscriptFilename
			$var=_GetDOSOutputRunAsRemote($sCommand,$serverName,$user,$pass)
			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $var = ' & $var & @crlf )
			$ProcessId=$var[0]
			$ReturnValue=$var[1]
			$ProcessOutput=$var[2]
			MemoWrite($iMemo, "Developer information:"&@CRLF& "ProcessId:"&$ProcessId&@CRLF& _
			"ReturnValue:"&$ReturnValue&@CRLF& "ProcessOutput:"&$ProcessOutput&@CRLF ,"Purple",8,0)
			$executionsuccess=StringInStr($ProcessOutput,"execution successful")>0
			Select
				case $ReturnValue = 0 and $ProcessId>0 and $ProcessId<>1000000 and $executionsuccess
					MemoWrite($iMemo,@TAB & "Minion Execution started ok.  PID="&$ProcessId &"  RetVal="&$ReturnValue,"Darkgreen",8,0)
					return true
				Case $ProcessId=1000000
					MemoWrite($iMemo,@TAB & "Error Starting Minion execution on remote server.  ErrNo 30" ,"Red",10,1)
					MemoWrite($iMemo, "Developer information:"&@CRLF& "ProcessId:"&$ProcessId&@CRLF& _
					"ReturnValue:"&$ReturnValue&@CRLF& "ProcessOutput:"&$ProcessOutput&@CRLF ,"RED",8,0)
					return false
				Case $ReturnValue = 9
					MemoWrite($iMemo,@TAB & "Error Starting Minion execution on remote server.  ErrNo 31" ,"Red",10,1)
					MemoWrite($iMemo, "Developer information:"&@CRLF& "ProcessId:"&$ProcessId&@CRLF& _
					"ReturnValue:"&$ReturnValue&@CRLF& "ProcessOutput:"&$ProcessOutput&@CRLF ,"RED",8,0)
					return false
				Case Else
					MemoWrite($iMemo,@TAB & "Error Starting Minion execution on remote server.  ErrNo 33" ,"Red",10,1)
					MemoWrite($iMemo, "Developer information:"&@CRLF& "ProcessId:"&$ProcessId&@CRLF& _
					"ReturnValue:"&$ReturnValue&@CRLF& "ProcessOutput:"&$ProcessOutput&@CRLF ,"RED",8,0)
					return false
			EndSelect
		EndFunc
	#endregion
	#region basic tasks
		Func _CheckDirAccess($path)
			ConsoleWrite('++_CheckDirAccess() = '& $path & @crlf )
			Local $aFileList = _FileListToArray($path, "*")
			If @error = 1 Then
				MemoWrite($iMemo,@TAB&"CheckDirExist = Path was invalid.  " & $path ,"Red",8,1)
				Return 1
			EndIf
			If @error = 4 Then
				MemoWrite($iMemo,@TAB&"CheckDirExist = No file(s) were found.  " & $path  ,"Red",8,1)
				Return 2
			EndIf
	;~ 		_printFromArray($aFileList)
			MemoWrite($iMemo,@TAB&"CheckDirExist = Path found.  " & $path )
			Return 0
		EndFunc
		Func _filterOlderThan($arr,$older=0)
			ConsoleWrite('++_filterOlderThan() = '& $older& @crlf)
			If $older>0 Then
	;~ 			_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Older than "& $older & " days", 2)
				Dim $arrtotal[1]
				_StatusPercent()
				for $i=1 To UBound($arr)-1
					If Not _IsFolder($arr[$i]) Then
						$tiempo=FileGetTime($arr[$i],0,1)
						$tiempo1=StringMid($tiempo,1,4)&"/"& StringMid($tiempo,5,2)&"/"&StringMid($tiempo,7,2)&" "&StringMid($tiempo,9,2)&":"&StringMid($tiempo,11,2)&":"&StringMid($tiempo,13,2)
						$difer=_DateDiff('D',$tiempo1,_NowCalc())
						If $difer>=$older Then
							_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Filtering older", 0)
							_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,$arr[$i] & "  " & $difer & "   " & $i & "/" & UBound($arr)-1, 1)
							_ArrayAdd($arrtotal,$arr[$i])
						endif
					Else
						_ArrayAdd($arrtotal,$arr[$i])
					endif
					_StatusPercent($i,$arr)
				next
	;~ 			_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"", 2)
				If IsArray($arrtotal) Then
					Return $arrtotal
				Else
					Dim $arr[1]
					$arr[0]=""
					Return $arr
				endif
			Else
				Return $arr
			endif
		EndFunc
		Func _GetDirContent($path,$filter="",$folderLast=1,$older=0,$withFolders=1,$memoOutput=1,$task="")
			ConsoleWrite('++_GetDirContent() = '&$path& " > "&  $filter& " > "&  $task & @crlf)

			If $memoOutput=1 Then MemoWrite($iMemo,@TAB & "Gathering data for "& $path ,"Black")
			_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Gathering data for "& $path , 1)
			$dirsizeArr=DirGetSize($path,1)
			$dirsize=$dirsizeArr[0]
			$filesCount=$dirsizeArr[1]
			$foldercount=$dirsizeArr[2]
			If FileExists($path) And $filesCount=0 And $foldercount=0  And $filter="" Then   ; el folder existe pero esta vacio devuelve el path
				Dim $aFileList[2]
				$aFileList[0]=1
				$aFileList[1]=$path
				Return $aFileList
			EndIf
			If FileExists($path) And $filesCount=0 And $foldercount=0  And $filter<>"" Then
				Dim $aFileList[2]
				$aFileList[0]=1
				$aFileList[1]=""
				Return $aFileList
			EndIf

			$errNo=0
			$errNo1=0
			$errNoExt=0
			$errNo1Ext=0
			$filtro=StringStripWS($filter,3)
			If StringStripWS($filter,3)="" Or StringStripWS($filter,3)="*" Or StringStripWS($filter,3)="*.*"  Then	$filtro="*"
			Local $aFileList = _FileListToArrayRec($path, $filtro,$ronlyfiles,$rrecursivo,$rsorted,$rfullpath)
			$errNo=@error
			$errNoExt=@extended
			If $withFolders=1 And $rrecursivo=1 Then
				Local $aFolderList = _FileListToArrayRec($path, "*",$ronlyfolders,$rrecursivo,$rsorted,$rfullpath)
				$errNo1=@error
				$errNo1Ext=@extended
					ConsoleWrite('Getdircontent file $errNo = ' & $errNo & @crlf )
					ConsoleWrite('Getdircontent file $errNoExt = ' & $errNoExt & @crlf )
					ConsoleWrite('Getdircontent folder $errNo1 = ' & $errNo1 & @crlf )
					ConsoleWrite('Getdircontent folder $errNo1Ext = ' & $errNo1Ext & @crlf )
				_printFromArray($aFolderList)
				ConsoleWrite('$folderLast = ' & $folderLast & @crlf )
				If $errNo = 0 and $errNo1 = 0 Then  ; hay files y folders
					If $folderLast=1 Then
						_ArrayDelete($aFolderList,0)
						_ArrayDelete($aFileList,0)
						_ArrayReverse($aFolderList)
						_ArrayConcatenate($aFileList,$aFolderList)
					Else
						_ArrayDelete($aFolderList,0)
						_ArrayDelete($aFileList,0)
						If $task="ZIP" Then
						else
							_ArrayReverse($aFolderList)
						endif
						_ArrayConcatenate($aFolderList,$aFileList)
						$aFileList=$aFolderList
					endif
					_ArrayInsert($aFileList,0,UBound($aFileList))
				endif
				If $errNo = 1 and $errNo1 = 0 Then  ; no hay files - solo folders
					If $folderLast=1 Then
						_ArrayDelete($aFolderList,0)
						_ArrayReverse($aFolderList)
					Else
						_ArrayDelete($aFolderList,0)
						If $task="ZIP" Then
						else
							_ArrayReverse($aFolderList)
						endif
					endif
					$aFileList=$aFolderList
					_ArrayInsert($aFileList,0,UBound($aFileList))
				endif
				If StringStripWS($filter,3)="" Then _ArrayAdd($aFileList,$path)
			endif
			_printFromArray($aFileList)
			If IsArray($aFileList) Then
				$aFileList1=_filterOlderThan($aFileList,$older)
				Return $aFileList1
			Else
				MsgBox(0,"imposible error","this error shouldnt happend.  $aFileList1 do not exist" & @crlf& "filtro="&$filter & _
				 @crlf& "$rrecursivo="&$rrecursivo & @crlf& "$withFolders="&$withFolders,0)
				_ArrayDisplay($aFileList)
			EndIf
			Return 0
		EndFunc
		Func _checkDirContent($path,$filter="",$folderLast=1,$older=0,$withFolders=1,$RemoteDriveTarget="",$task="")
			ConsoleWrite('++_checkDirContent() = '& $path & @crlf )
			$aFileList=_GetDirContent($path,$filter,$folderLast,$older,$withFolders,1,$task)
;~ 			_printFromArray($aFileList)
			$olderdaysmgg=""
			If $older>0 Then  $olderdaysmgg=" older than "& $older & " days"
			Select
				Case $errNoext=9 And $errNo1Ext<>0
					MemoWrite($iMemo,@TAB&"Checking the folder/files. The Path do not contain files. " & $path &"\"&$filter  & "  " & $olderdaysmgg,"orange",8,1)
					Return 1
	;~ 			Case $errNo1Ext=9
	;~ 				MemoWrite($iMemo,@TAB&"Checking the folder/files. The Path do not contain Folders " & $path ,"orange",8,1)
	;~ 				Return 0
				case $errNo = 1 AND ($errNo1=1 And $errNo1Ext<>9)
					MemoWrite($iMemo,@TAB&"Checking the folder/files. The Path was invalid. " & $path&"\"&$filter  & "  " & $olderdaysmgg,"Red",8,1)
					Return 1
				case $errNo = 2 Or $errNo1 = 2
					MemoWrite($iMemo,@TAB&"Checking the folder/files. Invalid filter provided.  " &  $path&"\"&$filter,"red" )
					Return 2
				case $errNo = 4 Or $errNo1 = 4
					MemoWrite($iMemo,@TAB&"Checking the folder/files. No file(s) were found.  " &  $path&"\"&$filter,"orange" )
					Return 4
			endselect

			MemoWrite($iMemo,@TAB&"Checking the folder/files. Path found.  " &  $path&"\"&$filter ,"Darkgreen",8,1)
			If UBound($aFileList)=1 Then
				MemoWrite($iMemo,@TAB&@TAB &"No File found for the selected criteria." ,"Purple")
			else
				_StatusPercent()
				$filesizeTotal=0
				$foldercounter=0
				$filecounter=0
				MemoWrite($iMemo,@TAB & "Checking total files size at source  "& $path ,"Black")
				For $i=1 To UBound($aFileList)-1
					If $hotKeyKill=1 Then Return false
					If $aFileList[$i]<>"" Then
						$filesize=FileGetSize($aFileList[$i])
						$esfolder=_IsFolder($aFileList[$i])
						If Not $esfolder Then $filesizeTotal += $filesize
						If _IsChecked($CK_JobConsole_Verbose) then
							If $esfolder Then
								If _IsChecked($CK_JobConsole_ConsoleQuiet)=False Then MemoWrite($iMemo,@TAB&@TAB&$aFileList[$i] ,"Purple",8,1)
								$foldercounter += 1
							else
								$tiempo=FileGetTime($aFileList[$i],0,1)
								$tiempo1=StringMid($tiempo,5,2)&"/"&StringMid($tiempo,7,2)&"/"&StringMid($tiempo,1,4)&"    T "&StringMid($tiempo,9,2)&":"&StringMid($tiempo,11,2)
								$difer=""
								If $older>0 Then
									$tiempo2=StringMid($tiempo,1,4)&"/"& StringMid($tiempo,5,2)&"/"&StringMid($tiempo,7,2)&" "&StringMid($tiempo,9,2)&":"&StringMid($tiempo,11,2)&":"&StringMid($tiempo,13,2)
									$difer=_DateDiff('D',$tiempo2,_NowCalc()) & " days old."
								endif
								If _IsChecked($CK_JobConsole_ConsoleQuiet)=False Then MemoWrite($iMemo,@TAB&@TAB&$aFileList[$i] &"  --->  "& _ByteSuffix($filesize) &"  --->      "&   $tiempo1 &"     "&  $difer ,"blue")
								_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,$aFileList[$i] & "   " & $i & "/" & UBound($aFileList)-1 , 1)
								$filecounter += 1
							endif
							_checkPause()
							_CheckClearConsole()
							If $hotKeyKill=1 Then Return false
						Else
							If $esfolder Then
								$foldercounter += 1
							Else
								$filecounter += 1
							endif
						endif
						_StatusPercent($i,$aFileList)
						_CheckConsoleLines($i)
					endif
				next
				$color="black"
				If $filecounter=0 And $foldercounter=0 Then $color="orange"
				MemoWrite($iMemo,@TAB&"Total files at source  "& $path & "    is    "  & $filecounter & "    And    " & $foldercounter & "    Folders " & @TAB & "Total size " & _ByteSuffix($filesizeTotal) ,$color)
			endif
			_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"" , 1)
			_StatusPercent()
			If $task="ZIP" Then
				MemoWrite($iMemo,@TAB &"Disk space calculation at %10 of compression rate at "& Round($filesizeTotal/1048576,1) & " ( The calculation is an estimate)" ,"orange")
			EndIf
			If $task="ZIP" OR $task="COPY" Then
				If _isEnoughSpace(Round(($filesizeTotal*0.15)/1048576,2),$RemoteDriveTarget) Then Return 0
				Return 1
			EndIf
			Return 0
		EndFunc
		Func _CheckIfMapExists($path)
			ConsoleWrite('++_CheckIfMapExists() = '&$path & @crlf )
			Local $aArray = DriveGetDrive("NETWORK")
			If @error Then
				ConsoleWrite( "!! _CheckIfMapExists() DriveGetDrive It appears an error occurred."&@crlf )
				MemoWrite($iMemo,@TAB &@TAB &  "Network path Check Error ErrNo 998 "& $path,"red",8,1)
				return true
			Else
				_printFromArray($aArray,"DriveGetDrive")
				For $i = 1 To $aArray[0]
					$sDrvPath = DriveMapGet(StringUpper($aArray[$i]))
					if StringStripWS($sDrvPath,1+2) =  StringStripWS($path,1+2) then
						MemoWrite($iMemo,@TAB &@TAB &  "Network remote path is already mapped to "& $path,"Orange",8,1)
						return true
					endif
				Next
			EndIf
			return false
		EndFunc
		Func _CheckMap($path,$userT,$passT,$msge="")
			ConsoleWrite('++_CheckMap() = '&$path&" "&$userT&" "&@crlf )
			MemoWrite($iMemo,@TAB& "Checking access to Server." ,"blue")
			DriveMapDel($path)
			MemoWrite($iMemo,@TAB &@TAB &  "Using  "& $userT & " credentials for "& $path)
			if _CheckIfMapExists($path)=false then
				If $userT=".\Logged User" Or $passT="" Or $userT="" Then
					$res=DriveMapAdd( "", $path, 0)
					$errNo=@error
				else
					$res=DriveMapAdd( "", $path, 0 ,$userT,$passT)
					$errNo=@error
					$errNoext=@extended
					ConsoleWrite('!@@ Debug(' & @ScriptLineNumber & ') : $errNoext = ' & $errNoext & @crlf )
				endif
			Else
				$errNo=0
			endif
			If $errNo Then
				Switch $errNoext
					Case 1
						$res="Check Folder Map = Undefined.  " ;------------------------
					Case 2
						$res="Check Folder Map = Access to the remote share was denied.  " ;------------------------
					Case 3
						$res="Check Folder Map = The device is already assigned.  "
					Case 4
						$res="Check Folder Map = Invalid device name.  "
					Case 5
						$res="Check Folder Map = Invalid remote share.  "
					Case 6
						$res="Check Folder Map = Invalid password.  " ;------------------------
					Case else
						if $errNoext = 1219 then
							$res="Check Folder Map = Remote folder already mapped.  " ;------------------------
						Else
							$res="Check Folder Map = Undefined extra.  " ;------------------------
						endif
				EndSwitch
				MemoWrite($iMemo,@TAB & $res & $path ,"Red",8,1)
				Return false
			Else
				MemoWrite($iMemo,@TAB&@TAB&"Check Folder Map = Test OK. "& $msge & " " & $path ,"Darkgreen",8,1 )
				Return true
			endif
		EndFunc
		Func _createDIR($path) ;------------------------------------------------------------------------------
			ConsoleWrite('++_createDIR() = '& @crlf )
			$res1=DirCreate($path)
			If Not $res1 Then
				MemoWrite($iMemo,@TAB & "***********  folder cannot be created  " & $path  ,"Red",8,1)
			Else
				MemoWrite($iMemo,@TAB & "Folder created successfully . "& $path ,"Darkgreen",8,1)
			EndIf
			If $res1=0 Then $res1=10
			Return $res1
		EndFunc
		Func _AddAsAdmin()  ;------------------------------------------------------------------------------
			ConsoleWrite('++_AddAsAdmin() = '& @crlf )
		EndFunc
		Func _DeleteDIRFILE($path) ;------------------------------------------------------------------------------
			ConsoleWrite('++_DeleteDIRFILE() = '&$path& @crlf )
			If $path<>"" Then
				If _IsFolder($path) Then
					$res1=runwait('cmd /c rmdir  /s/q "' & $path & '"',"", @SW_HIDE )
					If $res1=0 Then
						$res1=21
					Else
						$res1=20
					endif
				else
					$res1=FileDelete($path)
				endif
				Switch $res1
					Case 0
						MemoWrite($iMemo,@TAB & "***********  File cannot be deleted   " & $path ,"Red",8,1)
						Return false
					Case 1
						If _IsChecked($CK_JobConsole_ConsoleQuiet)=False Then MemoWrite($iMemo,@TAB & "File deleted successfully. "& $path ,"Darkgreen",8,1)
					Case 20
						MemoWrite($iMemo,@TAB & "***********  Folder cannot be deleted   " & $path ,"Red",8,1)
						Return false
					Case 21
						If _IsChecked($CK_JobConsole_ConsoleQuiet)=False Then MemoWrite($iMemo,@TAB & "Folder deleted successfully. "& $path ,"Darkgreen",8,1)
					Case Else
						MemoWrite($iMemo,@TAB & "Folder/Files Unknown status. "& $path ,"Red",8,1)
				EndSwitch
			endif
			Return true
		EndFunc
		Func _DeleteDIR($path,$contentOnly=0,$memoOutput=1) ;------------------------------------------------------------------------------
			ConsoleWrite('++_DeleteDIR() = '&$path& @crlf )
			If _IsFolder($path) Then
				$res1=runwait('cmd /c rmdir  /s/q "' & $path & '"',"", @SW_HIDE )
				If $res1=0 Then $res1=21
				If $res1=1 Then $res1=20
				If $res1=3 Then $res1=23
				If $res1=5 Then $res1=25
				If $res1=32 Then $res1=32
			else
				$res1=22
			endif
			Switch $res1
				Case 20
					MemoWrite($iMemo,@TAB & "***********  Folder cannot be deleted   " &"  EXITCODE="&$res1&"   "& $path ,"Red",8,1)
					Return false
				Case 21
					If $memoOutput=1 And _IsChecked($CK_JobConsole_ConsoleQuiet)=False Then MemoWrite($iMemo,@TAB & "Folder deleted successfully. "& $path ,"Darkgreen",8,1)
					Return true
				Case 22
					MemoWrite($iMemo,@TAB & "***********  Folder not deleted - Folder not found "&"  EXITCODE="&$res1&"   "&$path ,"Red",8,1)
					Return false
				Case 23
					MemoWrite($iMemo,@TAB & "***********  Folder not deleted - Folder not found  - ERROR_PATH_NOT_FOUND " &"  EXITCODE="&$res1&"   "& $path ,"Red",8,1)
					Return false
				Case 25
					MemoWrite($iMemo,@TAB & "*********** Folder not deleted - ERROR_ACCESS_DENIED - probably failed an ACL check." &"  EXITCODE="&$res1&"   "&$path ,"Red",8,1)
					Return false
				Case 25
					MemoWrite($iMemo,@TAB & "***********  Folder not deleted - ERROR_SHARING_VIOLATION - one of the files inside the directory probably was opened without FILE_SHARE_DELETE specified." &"  EXITCODE="&$res1&"   "&$path ,"Red",8,1)
					Return false
				Case Else
					If $memoOutput=1 Then MemoWrite($iMemo,@TAB & "Folder deletion  Unknown status. "&"  EXITCODE="&$res1&"   "&$path ,"Red",8,1)
					Return False
			EndSwitch
			Return true
		EndFunc
		Func _CleanUpTempZipFolders()
			ConsoleWrite('++_CleanUpTempZipFolders() = '& @crlf)
			 runwait("cmd /c for /f %i in ('dir C:\Users\marcelo.saied\AppData\Local\Temp  /a:d /s /b ~*') do rd /s /q %i","", @SW_HIDE )
		EndFunc
		Func  ZipProcess($arrZip,$fullRemotePathTargetZipFile,$fullRemotePathfolderTarget,$RemoteDriveSource,$fullRemotePathfolderSource)
			ConsoleWrite('++ZipProcess() = '& @crlf)
			_CleanUpTempZipFolders()
			$filecounter=0
			$folderCounter=0
			$method=0
			$zfile=""
			Local $ZipArray[1]
			Dim $szDrive, $szDir, $szFName, $szExt

			$overwrite=1
			If StringInStr($fullRemotePathTargetZipFile,"Autonaming..zip")=0 Then
				$hZip = _Zip_Create($fullRemotePathTargetZipFile,$overwrite)
			endif
			If $method=0 then
				For $i=1 To UBound($arrZip)-1                       ; loopea folders y despues files y los agrega al zip
					ConsoleWrite('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX '& @crlf)
					_checkPause()
					_CheckClearConsole()
					If $hotKeyKill=1 Then Return false
					_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Zipping "&$arrZip[$i]&"  "&$i&"/"&UBound($arrZip)-1, 1)
					$prog=1
					If _IsChecked($CK_JobConsole_progress) Then $prog=0
					;--------------------------------------------------------------------------------    add file -------------------------------------------
					If  _IsChecked($CK_JobConsole_ConsoleQuiet)=False Then
						MemoWrite($iMemo,@TAB & "Ziping file - "& $arrZip[$i] & "   " & _ByteSuffix(FileGetSize($arrZip[$i])) ,"black",8,1)
					endif
					$filetoAddArr = _PathSplit($arrZip[$i], $szDrive, $szDir, $szFName, $szExt)
					$filetoAdd=$szFName&$szExt
					If $rStructure=0 Then
						If StringInStr($fullRemotePathTargetZipFile,"Autonaming..zip")>0 Then   ; autonaming. create a zip container
							;------------------------------------------------------------------   autonaming
							$arrf=StringSplit($filetoAdd,".",2)
							$zfile=$arrf[0]&"."
							For $t=1 To UBound($arrf)-1
								$zfile=$zfile&$arrf[$t]&"."
							next
							$zfile=$zfile&"zip"
							$zfile=StringReplace($fullRemotePathTargetZipFile,"Autonaming..zip","")&$zfile
							If FileExists($zfile) Then
								$filetoAddArr = _PathSplit($zfile, $szDrive, $szDir, $szFName, $szExt)
								$zfile=$szDrive& $szDir&$szFName&"_Renamed_"&$i&$szExt
								MemoWrite($iMemo,@TAB & @TAB &"Renaming file - "& $arrZip[$i] & "  as  " & $zfile ,"Orange",8,1)
							endif
							$hZip = _Zip_Create($zfile,$overwrite)
						Else
							;----------------------------------------------------------------   no structure - one file
							_ArraySearch($ZipArray,$filetoAdd)
							$rr=@error
							If $rr=6 Then   ; not in array
								_ArrayAdd($ZipArray,$filetoAdd)
							Else
								$filetoAdd=$szFName&"_Renamed_"&$i&$szExt
								MemoWrite($iMemo,@TAB & @TAB &"Renaming file - "& $arrZip[$i] & "  as  " & $filetoAdd ,"Orange",8,1)
							endif
						EndIf
						;-------------------------------------------------------------------- zip file add -------
						$err=_AddFile($hZip,$arrZip[$i],$filetoAdd,"",$prog)
					Else ;--- structure=1 -----------------------------------------------------------------    structure
						$sDestDir=StringReplace($arrZip[$i],$fullRemotePathfolderSource&"\","")
						ConsoleWrite('>>>>>>>>>>>>>>>>>>>>>>>> ToZip <<<<<<<<<<<<<<<<<<<<<= ' & $arrZip[$i] & @crlf )
						$sDestDir=StringReplace($sDestDir,$filetoAdd,"")
						If _IsFolder($arrZip[$i]) Then
							ConsoleWrite('-is folder  $sDestDir = ' & $sDestDir & ' $filetoAdd = ' & $filetoAdd & @crlf )
							ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sDestDir&$filetoAdd = ' & $sDestDir&$filetoAdd & @crlf )
	;~ 						$res1=_Zip_AddPath($hZip, $sDestDir&$filetoAdd,"","",$prog)
							$res1=_Zip_AddPath($hZip, $sDestDir&$filetoAdd&"\")
							$err=@error
						else
							If $sDestDir<>"" Then
								ConsoleWrite('-is SubFolder FILE  $sDestDir = ' & $sDestDir & ' $filetoAdd = ' & $filetoAdd & ' $arrZip[$i] = '& $arrZip[$i]& @crlf )
	;~ 							If StringRight($sDestDir, 1) = "\" Then $sDestDir=StringLeft($sDestDir,StringLen($sDestDir)-1)
								$err=_AddFile($hZip,$arrZip[$i],$sDestDir&$filetoAdd,$sDestDir,$prog)
							Else
								ConsoleWrite('-is root FILE  $sDestDir = ' & $sDestDir & ' $filetoAdd = ' & $filetoAdd & @crlf )
								$err=_AddFile($hZip,$arrZip[$i],$filetoAdd,"",$prog)
							endif
						endif
					endif

					Switch $err
						Case 0
							If  _IsChecked($CK_JobConsole_ConsoleQuiet)=False Then
								MemoWrite($iMemo,@TAB & "File Zipped successfully - "& $filetoAdd,"Darkgreen",8,1)
							endif
						Case 1000
							MemoWrite($iMemo,@TAB & "File to zip is locked for read - "& $arrZip[$i],"Orange",8,1)
						Case Else
							MemoWrite($iMemo,@TAB & "File Zip Error - "& $arrZip[$i],"red",8,1)
							$RunFail=1
							$filecounter=$filecounter+1
					EndSwitch
				next
				If ($folderCounter + $filecounter)=0  Then
					MemoWrite($iMemo,@TAB & "Files were Zipped successfully- ","Darkgreen",8,1)
				Else
					MemoWrite($iMemo,@TAB & "Files Zip Errors- ","red",8,1)
					$RunFail=1
				endif
			endif

		EndFunc
		Func  ZipCab($targetZipFile,$arrZip,$fullRemotePathfolderTarget,$fullRemotePathTargetZipFile, $RemoteDriveSource,$fullRemotePathfolderSource,$active=0)
			ConsoleWrite('++ZipCab() = '& @crlf)
;~ 			$tempDir & "\makecab64.exe"
			_CleanUpTempZipFolders()
			$filecounter=0
			$folderCounter=0
			$method=1
			$One2one=0
			$Many2oneNoStructure=0
			$Many2oneStructure=0
			$zfile=""
			$targetZipFileNoRenamed=""
			Local $ZipArray[1]
			Dim $szDrive, $szDir, $szFName, $szExt

			If StringInStr($fullRemotePathTargetZipFile,"Autonaming..zip")=0 Then
				if _ZIP_DDFinit($targetZipFile) then
					if _ZIP_DDFBase($fullRemotePathfolderSource,$fullRemotePathfolderTarget,$rStructure) then
					else
						MemoWrite($iMemo,@TAB & @TAB &"ZIP definition DDF file cannot be Updated Base Action - ","RED",8,1)
						return false
					endif
				Else
					MemoWrite($iMemo,@TAB & @TAB &"ZIP definition DDF file cannot be initialated - ","RED",8,1)
					return false
				endif
			endif

			If $method=1 then
				For $i=1 To UBound($arrZip)-1                       ; loopea folders y despues files y los agrega al zip
					ConsoleWrite('XXXXXXXXXXXXXXXXXXXXX '& @crlf)
					ConsoleWrite('->$arrZip[$i]= ' &$i&") "& $arrZip[$i]  & @crlf )
					_checkPause()
					_CheckClearConsole()
					If $hotKeyKill=1 Then Return false
					_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Zipping "&$arrZip[$i]&"  "&$i&"/"&UBound($arrZip)-1, 1)
					$prog=1
					If _IsChecked($CK_JobConsole_progress) Then $prog=0
					;--------------------------------------------------------------------------------    add file -------------------------------------------
					If  _IsChecked($CK_JobConsole_ConsoleQuiet)=False Then
						If $rStructure=0 Then
							if $active=1 then
								MemoWrite($iMemo,@TAB & @TAB&"Ziping file - "& $arrZip[$i] & "   " & _ByteSuffix(FileGetSize($arrZip[$i])) ,"black",8,0)
							Else
								MemoWrite($iMemo,@TAB &@TAB& $arrZip[$i] & "   " & _ByteSuffix(FileGetSize($arrZip[$i])) ,"black",8,0)
							endif
						endif
					endif
					$filetoAddArr = _PathSplit($arrZip[$i], $szDrive, $szDir, $szFName, $szExt)
					$filetoAdd=$szFName&$szExt
					If $rStructure=0 Then
						$rRenamed=0
						If StringInStr($fullRemotePathTargetZipFile,"Autonaming..zip")>0 Then   ; autonaming. create a zip container
							#region ZIP 1 -> 1  autonaming
								$One2one=1
								$arrf=StringSplit($filetoAdd,".",2)
								$zfile=$arrf[0]&"."
								For $t=1 To UBound($arrf)-1
									$zfile=$zfile&$arrf[$t]&"."
								next
								$targetZipFile=$zfile&"zip"
								$zfilePath=StringReplace($fullRemotePathTargetZipFile,"Autonaming..zip","")&$targetZipFile
								#region rename
									_checkPause()
									If $hotKeyKill=1 Then Return false
									If FileExists($zfilePath) Then
										if $rAutoRenameZip=1 then
											$filetoAddArr = _PathSplit($zfilePath, $szDrive, $szDir, $szFName, $szExt)
											$targetZipFile=$szFName&"_Renamed_"&$i&$szExt
											MemoWrite($iMemo,@TAB & @TAB &"Renaming file - "& $arrZip[$i] & "  as  " & $targetZipFile ,"Orange",8,1)
										Else
											MemoWrite($iMemo,@TAB & @TAB &"File exist at target - "& $zfilePath ,"red",8,1)
											if $active=1 then
												$res=_AreYouSureYesNoCancel("File exist at target - "& $zfilePath&@crlf& _
												"You want to:"&@crlf&"   YES to Rename the file."&@crlf&"   NO to skip the file."& _
												@crlf&"   CANCEL to stop task.")
												if $res=$answerCANCEL then
													MemoWrite($iMemo,@TAB & @TAB &"File compression canceled - "& $zfilePath ,"red",8,1)
													return false
												endif
												if $res=$answerYES then
													$filetoAddArr = _PathSplit($zfilePath, $szDrive, $szDir, $szFName, $szExt)
													$targetZipFile=$szFName&"_Renamed_"&$i&$szExt
													MemoWrite($iMemo,@TAB & @TAB &"Renaming file - "& $arrZip[$i] & "  as  " & $targetZipFile ,"Orange",8,1)
												endif
												if $res=$answerNO then
													MemoWrite($iMemo,@TAB & @TAB &"File compression Skipped - "& $zfilePath ,"orange",8,1)
												endif
											endif
										endif
									endif
								#endregion ;==> rename
								#region zip activity for 1->1
									if _ZIP_DDFinit($targetZipFile) then
										Local $FilesArray[2]
										$FilesArray[0]=1
										$filetoAddArr = _PathSplit($arrZip[$i], $szDrive, $szDir, $szFName, $szExt)
										$FilesArray[1]=$szDrive & $szDir & $filetoAdd
										$basefolder=""
										if $rServerFolderZipInside=1 then $basefolder=_GetSourceServerName($fullRemotePathfolderSource)
										_checkPause()
										If $hotKeyKill=1 Then Return false
										if _ZIP_DDFBase($fullRemotePathfolderSource,$fullRemotePathfolderTarget,$rStructure,$basefolder) then
											_checkPause()
											If $hotKeyKill=1 Then Return false
											if _ZIP_DDFFilesInfo($fullRemotePathfolderSource,$fullRemotePathfolderTarget,$FilesArray,$rStructure) then
												if $active=1 then
													_checkPause()
													If $hotKeyKill=1 Then Return false
													$res=_ZIP_DDFrun()
													sleep(250)
													if $res=false then return false
												endif
											else
												MemoWrite($iMemo,@TAB & @TAB &"ZIP definition DDF file cannot be Updated FilesInfo - ","RED",8,1)
												return false
											endif
										else
											MemoWrite($iMemo,@TAB & @TAB &"ZIP definition DDF file cannot be Updated Base Action - ","RED",8,1)
											return false
										endif
									Else
										MemoWrite($iMemo,@TAB & @TAB &"ZIP definition DDF file cannot be initialated - ","RED",8,1)
										return false
									endif
								#endregion
							#endregion
						Else
							#region zip many to 1   no structure - one file
								#region rename
									$Many2oneNoStructure=1
									$AddToZIP=0
									_ArraySearch($ZipArray,$filetoAdd)
									$rr=@error
									If $rr=6 Then   ; not in array
										_ArrayAdd($ZipArray,$filetoAdd)
										$AddToZIP=1
									Else
										if $rAutoRenameZip=1 then
											$filetoAdd=$szFName&"_Renamed_"&$i&$szExt
											$targetZipFileNoRenamed=$szFName&$szExt
											MemoWrite($iMemo,@TAB & @TAB& @TAB &"Renaming file - "& $arrZip[$i] & "  as  " & $filetoAdd ,"Orange",8,1)
											$rRenamed=1
											$AddToZIP=1
										Else
											MemoWrite($iMemo,@TAB & @TAB & @TAB&"File Already exist - "& $arrZip[$i] ,"red",8,1)
											if $active=1 then
												$res=_AreYouSureYesNoCancel("File exist at target - "& $arrZip[$i]&@crlf& _
												"Do you want to remane it?"&@crlf&"   YES   to Rename the file."&@crlf&"   NO   to skip the file."& _
												@crlf&"   CANCEL   to stop task.")
												if $res=$answerCANCEL then
													MemoWrite($iMemo,@TAB & @TAB &"File compression canceled - "& $arrZip[$i] ,"red",8,1)
													return false
												endif
												if $res=$answerYES then
													$filetoAdd=$szFName&"_Renamed_"&$i&$szExt
													$targetZipFileNoRenamed=$szFName&$szExt
													MemoWrite($iMemo,@TAB & @TAB &"Renaming file - "& $arrZip[$i] & "  as  " & $filetoAdd ,"Orange",8,1)
													$rRenamed=1
													$AddToZIP=1
												endif
												if $res=$answerNO then
													MemoWrite($iMemo,@TAB & @TAB &"File compression Skipped - "& $arrZip[$i] ,"orange",8,1)
													$AddToZIP=0
												endif
											endif
										endif
									endif
								#endregion ;==> rename
								#region zip many to 1  No structure-> DDF file file data adition
									if $AddToZIP=1 then
										Local $FilesArray[2]
										$FilesArray[0]=1
										$filetoAddArr = _PathSplit($arrZip[$i], $szDrive, $szDir, $szFName, $szExt)
										Select
											case $rRenamed=1 and $rServerFolderZipInside=0
												$FilesArray[1]=$szDrive & $szDir & $targetZipFileNoRenamed & '"  "' & $filetoAdd
											Case $rRenamed=0 and $rServerFolderZipInside=0
												$FilesArray[1]=$szDrive & $szDir & $filetoAdd
											case $rRenamed=1 and $rServerFolderZipInside=1
												$FilesArray[1]=$szDrive & $szDir & $targetZipFileNoRenamed & '"  "' &_GetSourceServerName($fullRemotePathfolderSource)&"\"& $filetoAdd
											Case $rRenamed=0 and $rServerFolderZipInside=1
		;~ 										$FilesArray[1]=$szDrive & $szDir & _GetSourceServerName($fullRemotePathfolderSource)&"\"&$filetoAdd
												$FilesArray[1]=$szDrive & $szDir & $filetoAdd & '"  "' &_GetSourceServerName($fullRemotePathfolderSource)&"\"& $filetoAdd
											Case Else
										EndSelect

										if _ZIP_DDFFilesInfo($fullRemotePathfolderSource,$fullRemotePathfolderTarget,$FilesArray,$rStructure) then
										else
											MemoWrite($iMemo,@TAB & @TAB &"ZIP definition DDF file cannot be Updated FilesInfo - ","RED",8,1)
											return false
										endif
									endif
								#endregion
							#endregion
						EndIf
					Else ;--- structure=1 -----------------------------------------------------------------    structure
						#region zip many to 1  structure-> DDF file file data adition
							$Many2oneStructure=1
							if _IsFolder($arrZip[$i]) then
							Else
								Local $FilesArray[2]
								$FilesArray[0]=1
								$filetoAddArr = _PathSplit($arrZip[$i], $szDrive, $szDir, $szFName, $szExt)
								$FilesArray[1]=$szDrive & $szDir & $filetoAdd
								if _ZIP_DDFFilesInfo($fullRemotePathfolderSource,$fullRemotePathfolderTarget,$FilesArray,$rStructure) then
								else
									MemoWrite($iMemo,@TAB & @TAB &"ZIP definition DDF file cannot be Updated FilesInfo - ","RED",8,1)
									return false
								endif
							endif
						#endregion
					endif
;~ 					Switch $err
;~ 						Case 0
;~ 							If  _IsChecked($CK_JobConsole_ConsoleQuiet)=False Then
;~ 								MemoWrite($iMemo,@TAB & "File Zipped successfully - "& $filetoAdd,"Darkgreen",8,1)
;~ 							endif
;~ 						Case 1000
;~ 							MemoWrite($iMemo,@TAB & "File to zip is locked for read - "& $arrZip[$i],"Orange",8,1)
;~ 						Case Else
;~ 							MemoWrite($iMemo,@TAB & "File Zip Error - "& $arrZip[$i],"red",8,1)
;~ 							$RunFail=1
;~ 							$filecounter=$filecounter+1
;~ 					EndSwitch
				next

				if $active=1 then
					if $Many2oneNoStructure=1 or $Many2oneStructure=1 then
						$res=_ZIP_DDFrun()
						if $res then
							MemoWrite($iMemo,@TAB & "Files were Zipped successfully. ","Darkgreen",9,1)
							if $rDeleteZip=0  then return true
						Else
							MemoWrite($iMemo,@TAB & "Files Zip Errors. ","red",10,1)
							if $rDeleteZip=1 then
								MemoWrite($iMemo,@TAB & "Deletion after zip is canceled due errors on Zip process ","red",9,1)
							endif
							$RunFail=1
							return false
						endif
					endif
				endif
				#region Delete zip
					if $rDeleteZip=0  then
						return true
					else
						if $active=1 then
							$msg="Task Type = Deletion After Compression " &  @crlf& " Task Name = "& $TaskName
							If _checkRunOneByOne($msg)=False Then return
							MemoWrite($iMemo,@TAB & "- - - - - - - - - - - - - - - - - - - - ","Darkgreen",8,1)
							MemoWrite($iMemo,@TAB & "Deleting Zip source files. ","Darkgreen",10,1)
							_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Running Job", 0)
							Select
								case $One2one=1
									_printFromArray($arrZip)
									For $i=1 To UBound($arrZip)-1
										_checkPause()
										_CheckClearConsole()
										If $hotKeyKill=1 Then Return false
										_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Deleting "&$arrZip[$i]&"  "&$i&"/"&UBound($arrZip)-1, 1)
										_DeleteDIRFILE($arrZip[$i])
										_StatusPercent($i,$arrZip)
										If FileExists($arrZip[$i])=0 Then
										Else
											MemoWrite($iMemo,@TAB&"An Error occurred , please check credentials and path. => "& $arrZip[$i] ,"Red",8,1)
											$RunFail=1
										endif
									next
									if $RunFail=1 then return false
									return true
								case $Many2oneStructure=1

								Case $Many2oneNoStructure=1

								case else
									MsgBox(0,"imposible error","this error shouldnt happend.  Err 2070" & @crlf,0)
							EndSelect
						Else
							MemoWrite($iMemo,@TAB & "Folder/Files will be deleted AT JOB RUNTIME "& $fullRemotePathfolderSource ,"blue")
							MemoWrite($iMemo,@TAB & 'If "Task Run Confirmation" Checkbox is selected , then you will be pronpt for confirmation. '& $fullRemotePathfolderSource ,"blue")
							Select
								case $One2one=1
									_printFromArray($arrZip)
									For $i=1 To UBound($arrZip)-1
										_CheckClearConsole()
										If $hotKeyKill=1 Then Return false
										If _IsChecked($CK_JobConsole_ConsoleQuiet)=False Then MemoWrite($iMemo,@TAB&@TAB&$arrZip[$i] ,"Purple",8,0)
									next
								case $Many2oneStructure=1

								Case $Many2oneNoStructure=1

								case else
									MsgBox(0,"imposible error","this error shouldnt happend.  Err 2070" & @crlf,0)
							EndSelect
						endif
					endif
				return true
				#endregion
			endif
		EndFunc
		Func _GetUserT($userT,$server)
			ConsoleWrite('++_GetUserT() = '&$userT& @crlf)
				if stringmid($userT,0,2)=".\" then
					$userArr=stringsplit($userT,"\")
					$userT= _GetSourceServerName($server)&"\"&$userArr[2]
				endif
			return $userT
		EndFunc
		func _GetSourceServerName($fullRemotePathfolderSource)
			ConsoleWrite('++_GetSourceServerName() = $fullRemotePathfolderSource ='&$fullRemotePathfolderSource & @crlf)
			Dim $szDrive, $szDir, $szFName, $szExt
			$serverName=""
			$serverNameArr=StringRegExp($fullRemotePathfolderSource,"\A\\{2}[a-zA-Z0-9-.]*\\",1)
			if IsArray($serverNameArr) Then
				$serverName=StringReplace($serverNameArr[0],"\","")
				if $serverName="localhost" then $serverName=@ComputerName
			else
				if $serverName<>"" then
					if $serverName="localhost" then $serverName=@ComputerName
				else
					MsgBox(0,"imposible error","this error shouldnt happend.  $RemoteDriveSource do not have server name, check RunFunctions" ,0)
				endif
			endif
			return $serverName
		endfunc
		func _AddServerNameToFolder($fullRemotePathfolderTarget,$RemoteDriveSource)
		;server folder name
			$serverNameArr=StringRegExp($RemoteDriveSource,"\A\\{2}[a-zA-Z0-9-.]*\\",1)
			if IsArray($serverNameArr) Then
				$serverName=StringReplace($serverNameArr[0],"\","")
				if $serverName="localhost" then $serverName=@ComputerName
				$fullRemotePathfolderTarget=$fullRemotePathfolderTarget&"\"&$serverName
			else
				MsgBox(0,"imposible error","this error shouldnt happend.  $RemoteDriveSource do not have server name, check RunFunctions" ,0)
			endif
			return $fullRemotePathfolderTarget
		EndFunc
		func _AddServerNameToFileZip($fullRemotePathfolderTarget,$RemoteDriveSource)
			Dim $szDrive, $szDir, $szFName, $szExt
			$serverNameArr=StringRegExp($RemoteDriveSource,"\A\\{2}[a-zA-Z0-9-.]*\\",1)
			_printFromArray($serverNameArr)
			if IsArray($serverNameArr) Then
				$serverName=StringReplace($serverNameArr[0],"\","")
				if $serverName="localhost" then $serverName=@ComputerName
;~ 				$fullRemotePathfolderTarget=$fullRemotePathfolderTarget&"\"&$serverName
			else
				MsgBox(0,"imposible error","this error shouldnt happend.  $RemoteDriveSource do not have server name, check RunFunctions" ,0)
			endif
			$fileArr = _PathSplit($fullRemotePathfolderTarget, $szDrive, $szDir, $szFName, $szExt)
			$targetZipFile=$szDrive&$szDir&$serverName&"\"&$szFName&$szExt
			ConsoleWrite('!!!!!!@@ Debug(' & @ScriptLineNumber & ') : $targetZipFile = ' & $targetZipFile & @crlf )
			return $targetZipFile
		endfunc
		Func _addfile($hZip,$filetoaddOrig,$filetoadd,$sDestDir,$prog)
			ConsoleWrite('++_addfile() = '& @crlf)
			$retries=0
			While $retries<3
				if Not _FileInUse($filetoaddOrig) Then
					$res1=_Zip_AddFile($hZip,$filetoaddOrig,$filetoAdd,$sDestDir,$prog)
					$err=@error
					If $err=0 Then exitloop
				else
					$err=1000
				endif
				$retries=$retries+1
			wend
			Return $err
		EndFunc
		Func  CopyProcess($sourceFile,$fullRemotePathfolderTarget,$fullRemotePathfolderSource,$rBehaviour,$rCopyMode)
			ConsoleWrite('++CopyProcess() = '& @crlf)

			Dim $szDrive, $szDir, $szFName, $szExt
			$cflag=1+8
			$res=0
			$filetoAddArr = _PathSplit($sourceFile, $szDrive, $szDir, $szFName, $szExt)
			$filetoAdd=$szFName&$szExt
			$FiletargetPath=$fullRemotePathfolderTarget&"\"&$filetoAdd
			$SourcepartialFilePath=StringReplace($sourceFile,$fullRemotePathfolderSource&"\","")
			$FiletargetPath=$fullRemotePathfolderTarget&"\"&$SourcepartialFilePath

			If $rStructure=0 Then
				$FiletargetPath=$fullRemotePathfolderTarget&"\"&$filetoAdd
			Else
				$SourcepartialFilePath=StringReplace($sourceFile,$fullRemotePathfolderSource&"\","")
				$FiletargetPath=$fullRemotePathfolderTarget&"\"&$SourcepartialFilePath
			EndIf

			If FileExists($FiletargetPath)=1 Then
				If $rBehaviour="Overwrite" Then     ;----------- Overwrite ---------
				endif
				If $rBehaviour="Skip" Then    		;----------- Skip  ---------
					MemoWrite($iMemo,@TAB & "File skipped - "& $sourceFile & " exists in " & $fullRemotePathfolderTarget,"Orange",8,1)
					return
				EndIf
				If $rBehaviour="prompt" Then       ;----------- prompt ---------
					$question= "The file " & $FiletargetPath  & " exist in target path." & @CRLF & "Do you want to overwrite it?"
					If _AreYouSureYesNo($question) Then
					Else
						MemoWrite($iMemo,@TAB & "File Skipped user request - "& $sourceFile ,"orange",8,1)
						$TasKCopyCounter=$TasKCopyCounter+1
						return
					endif
				endif
				If $rBehaviour="Rename" Then    	;----------- Rename  ---------
					$isdir=0
					If _isfolder($FiletargetPath) Then $isdir=1
					$filetoAddArr = _PathSplit($FiletargetPath, $szDrive, $szDir, $szFName, $szExt)
					$xx=0
					do
						$xx=$xx+1
						If $isdir=1 Then
							$FiletargetPath = $szDrive & $szDir & $szFName & $szExt &"("& $xx &")"
						Else
							$FiletargetPath = $szDrive & $szDir & $szFName &"("& $xx &")" & $szExt
						endif
					Until FileExists($FiletargetPath)=0
				endif
			endif

	;~ 		ConsoleWrite('!$sourceFile = ' & $sourceFile & @crlf )
	;~ 		ConsoleWrite('!$FiletargetPath = ' & $FiletargetPath & @crlf )
	;~ 		ConsoleWrite('!=================================' & @crlf )
			If $rCopyMode="[MV]" Then
				If _IsFolder($sourceFile) Then
					$res=_createDIR($FiletargetPath)
					If $res=1 Then $res=4
				Else
					$res=FileMove($sourceFile,$FiletargetPath,$cflag)
					If $res=1 Then $res=2
				endif
			else
				If _IsFolder($sourceFile) Then
					$res=_createDIR($FiletargetPath)
					If $res=1 Then $res=5
				Else
					$res=FileCopy($sourceFile,$FiletargetPath,$cflag)
					If $res=1 Then $res=3
				endif
			endif
			Switch $res
				Case 1   ; general - copied ok
					If _IsChecked($CK_JobConsole_ConsoleQuiet)=False  Then MemoWrite($iMemo,@TAB & "File was Copied successfully- "& $sourceFile & @TAB &"==>" & @TAB &$FiletargetPath,"Darkgreen",8,1)
					$TasKCopyCounter=$TasKCopyCounter+1
				Case 2   ; File Moved OK
					If _IsChecked($CK_JobConsole_ConsoleQuiet)=False  Then MemoWrite($iMemo,@TAB & "File was Moved successfully- "& $sourceFile & @TAB &"==>" & @TAB &$FiletargetPath,"Darkgreen",8,1)
					$TasKCopyCounter=$TasKCopyCounter+1
				Case 3   ; File copied OK
					If _IsChecked($CK_JobConsole_ConsoleQuiet)=False  Then MemoWrite($iMemo,@TAB & "File was Copied successfully- "& $sourceFile & @TAB &"==>" & @TAB &$FiletargetPath,"Darkgreen",8,1)
					$TasKCopyCounter=$TasKCopyCounter+1
				Case 4   ; folder Moved OK
	;~ 				MemoWrite($iMemo,@TAB & "Folder was Copied successfully- "& $sourceFile & @TAB &" ==> " & @TAB &$FiletargetPath,"Darkgreen",8,1)
					$TasKCopyCounter=$TasKCopyCounter+1
				Case 5   ; folder copied OK
	;~ 				MemoWrite($iMemo,@TAB & "Folder was Copied successfully- "& $sourceFile & @TAB &" ==> " & @TAB &$FiletargetPath,"Darkgreen",8,1)
					$TasKCopyCounter=$TasKCopyCounter+1
				Case 10  ; folder Not  created
	;~ 				MemoWrite($iMemo,@TAB&"An Error occurred , Folder was not copied. => "& $sourceFile & @TAB &" ==> " & @TAB &$FiletargetPath,"Red",8,1)
				Case 0
					MemoWrite($iMemo,@TAB&"An Error occurred , File was not copied. => "& $sourceFile & @TAB &"==>" & @TAB &$FiletargetPath,"Red",8,1)
					$RunFail=1
					Return False
				Case Else
					MemoWrite($iMemo,@TAB&"An Error occurred , Undefined error. => "& $sourceFile & @TAB &"==>" & @TAB &$FiletargetPath,"Red",8,1)
					$RunFail=1
					Return False
			EndSwitch
			Return True
		EndFunc
		Func  CopyTest($sourceFile,$fullRemotePathfolderTarget,$fullRemotePathfolderSource,$rBehaviour,$rCopyMode)
			ConsoleWrite('++CopyTest() = '& @crlf)

			Dim $szDrive, $szDir, $szFName, $szExt
			$cflag=1+8
			$res=0
			$filetoAddArr = _PathSplit($sourceFile, $szDrive, $szDir, $szFName, $szExt)
			$filetoAdd=$szFName&$szExt
			$FiletargetPath=$fullRemotePathfolderTarget&"\"&$filetoAdd
			$SourcepartialFilePath=StringReplace($sourceFile,$fullRemotePathfolderSource&"\","")
			$FiletargetPath=$fullRemotePathfolderTarget&"\"&$SourcepartialFilePath

			If $rStructure=0 Then
				$FiletargetPath=$fullRemotePathfolderTarget&"\"&$filetoAdd
			Else
				$SourcepartialFilePath=StringReplace($sourceFile,$fullRemotePathfolderSource&"\","")
				$FiletargetPath=$fullRemotePathfolderTarget&"\"&$SourcepartialFilePath
			EndIf

			If FileExists($FiletargetPath)=1 Then
				If $rBehaviour="Overwrite" Then     ;----------- Overwrite ---------
					MemoWrite($iMemo,@TAB & "File will be overwriten - "& $sourceFile & @TAB &"==>" & @TAB &$FiletargetPath,"orange",8,1)
				endif
				If $rBehaviour="Skip" Then    		;----------- Skip  ---------
					MemoWrite($iMemo,@TAB & "File will be skipped - "& $sourceFile & " exists in " & $fullRemotePathfolderTarget,"Orange",8,1)
					return
				EndIf
				If $rBehaviour="prompt" Then       ;----------- prompt ---------
					MemoWrite($iMemo,@TAB & "User will be Prompt to proceed for  "& $sourceFile ,"orange",8,1)
				endif
				If $rBehaviour="Rename" Then    	;----------- Rename  ---------
					$isdir=0
					If _isfolder($FiletargetPath) Then $isdir=1
					$filetoAddArr = _PathSplit($FiletargetPath, $szDrive, $szDir, $szFName, $szExt)
					$xx=0
					do
						$xx=$xx+1
						If $isdir=1 Then
							$FiletargetPath = $szDrive & $szDir & $szFName & $szExt &"("& $xx &")"
						Else
							$FiletargetPath = $szDrive & $szDir & $szFName &"("& $xx &")" & $szExt
						endif
					Until FileExists($FiletargetPath)=0
					MemoWrite($iMemo,@TAB & "Folder/File will be renamed - "& $sourceFile & @TAB &"==>" & @TAB &$FiletargetPath,"orange",8,1)
				endif
			endif

			If $rCopyMode="[MV]" Then
				If _IsFolder($sourceFile) Then
					MemoWrite($iMemo,@TAB & "Folder will be created - "& $FiletargetPath ,"blue",8,1)
				Else
					MemoWrite($iMemo,@TAB & "File will be moved- "& $sourceFile & @TAB &"==>" & @TAB &$FiletargetPath,"Blue",8,1)
				endif
			else
				If _IsFolder($sourceFile) Then
					MemoWrite($iMemo,@TAB & "Folder will be created - "& $FiletargetPath ,"blue",8,1)
				Else
					MemoWrite($iMemo,@TAB & "File will be copied- "& $sourceFile & @TAB &"==>" & @TAB &$FiletargetPath,"Blue",8,1)
				endif
			endif
		EndFunc
		Func  JobConsole_pause()
			ConsoleWrite('++JobConsole_pause() = '& @crlf)
			If $HotKeyPause=0 Then
				$HotKeyPause=1
				GUICtrlSetData($LBL_RUNalert,"  Paused  ")
				Sleep(600)
			Else
				$HotKeyPause=0
				GUICtrlSetData($LBL_RUNalert,"Running job")
			endif
		EndFunc
		Func  JobConsole_kill()
			ConsoleWrite('++JobConsole_kill() = '& @crlf)
			If $hotKeyKill=0 Then
				$hotKeyKill=1
				GUICtrlSetData($LBL_RUNalert,"  Stop  ")
				Sleep(600)
			endif
		EndFunc
		Func _checkpause()
	;~ 		ConsoleWrite('++_checkpause() = '&$HotKeyPause & @crlf)
			While $HotKeyPause=1
				Sleep(50)
			wend
		EndFunc
		Func _CheckClearConsole()
		;~ 	ConsoleWrite('++_CheckClearConsole() = '& @crlf)
			If _isChecked($CK_JobConsole_Clearconsole) Then
				MemoWrite($iMemo,"")
				GUICtrlSetState($CK_JobConsole_Clearconsole,$GUI_UNCHECKED)
			endif
		EndFunc
		Func _ClearConsole($hEdit)
			ConsoleWrite('++_ClearConsole() = '& @crlf )
			MemoWrite($hEdit,"")
		EndFunc
		Func _checkRunOneByOne($msg)
			ConsoleWrite('++_checkRunOneByOne() = '& @crlf)
			If _IsChecked($CK_JobConsole_RunOneByOne) Then
				$mensaje="Do you want to proceed with the task?" & @CRLF & $msg
				Return _AreYouSureYesNo($mensaje)
			Else
				Return true
			endif
		EndFunc
		Func _checkIf2Hold($msg)
			ConsoleWrite('++_checkIf2Hold() = '& @crlf)
			$mensaje=$msg  & @CRLF & "Do you still want to proceed with the task?"
			Return _AreYouSureWarning($mensaje)
		EndFunc
		Func  MemoWrite($hEdit,$sMessage,$color="black",$FontSize=8,$bold=0,$writeInline=0,$newLine=1)
			If $sMessage="" Then
				_GUICtrlRichEdit_SetText($hEdit,"")
			else
				If _IsChecked($CK_JobConsole_Log) Then FileWriteLine($hLogFile,_LogDate()  &  $sMessage)
				_GUICtrlRichEdit_WriteLine($hEdit, $sMessage,_color($color),$FontSize,$bold,$writeInline,$newLine=1)
			endif
		EndFunc
		Func _StatusPercent($i=1,$arrObj=1)
	;~ 		ConsoleWrite('++_StatusPercent() = '& @crlf)
			If IsArray($arrObj) Then
				GUICtrlSetData($progressConsole, round(($i/(UBound($arrObj)-1))*100,0))
			Else
				GUICtrlSetData($progressConsole, 1)
			endif
		EndFunc
		Func _isEnoughSpace($sourceSize,$discoTarget)
			ConsoleWrite('++_CheckAvailableSpace() = '& @crlf)
			If $discoTarget<>"" Then
				$targetsize=Round(DriveSpaceFree($discoTarget),1)
				MemoWrite($iMemo,@TAB &"Disk space size at target  "& $discoTarget & " is " & _ByteSuffix(Round($targetsize*1048576,2)) ,"Black")
				ConsoleWrite('>>_CheckAvailableSpace(source) = '&$sourceSize & @crlf)
				ConsoleWrite('>>_CheckAvailableSpace(target) = '&$targetsize & @crlf)
				If $sourceSize <= $targetsize Then
					return True
				Else
					MemoWrite($iMemo,@TAB & "***********  Not enough space on target path  " & $discoTarget ,"Red",12,1)
					Return false
				endif
			Else
				Return false
			endif
		EndFunc
		Func _CheckConsoleLines($lines)
	;~ 		ConsoleWrite('++_CheckConsoleLines() = '& @crlf)
			If _isChecked($CK_JobConsole_ClearconsoleEveryLines) And  _isChecked($CK_JobConsole_Verbose) and  _IsChecked($CK_JobConsole_ConsoleQuiet)=False  Then
				If Mod($lines,$ClearConsoleEveryLines)=0 Then 	MemoWrite($iMemo,"")
			endif
		EndFunc
	#endregion
	;~ 	Func  ZipProcessFast($arrZip,$fullRemotePathTargetZipFile,$fullRemotePathfolderTarget,$RemoteDriveSource,$fullRemotePathfolderSource)
	#region FGMcontrol
		Func _StartFGMagent($serverName,$user,$pass)
			ConsoleWrite('++_StartServiceFGM() = '& @crlf)
			$sCommand='sc start FGMagent'
			$var=_GetDOSOutputRunAsRemote($sCommand,$serverName,$user,$pass)
			ConsoleWrite('$var = ' & $var & @crlf )
			If StringInStr($var,"successful")>0 Then
				MemoWrite($iMemo,@TAB&"FGMagent process was started.","Darkgreen",8,1)
;~ 				MemoWrite($iMemo,@TAB& _clearEmptyLines($var) & @crlf,"Darkgreen",8,1)
			Else
				MemoWrite($iMemo,@TAB&"FGMagent process cannot be started.","red",10,1)
				MemoWrite($iMemo,@TAB& _clearEmptyLines($var) & @crlf,"red",8,1)
				Return 0
			endif
			Return 1
		EndFunc
	#endregion
	#region service
		Func _installServiceFGM($userT,$passT)
;~ 			instsrv.exe "FGMagent" "c:\program files\fgmagent\srvany.exe
			ConsoleWrite('++_installServiceFGM() = '& @crlf)
			$sCommand='sc create FGMagent displayname= "FGM Agent"  type= own error= severe start= demand obj= "'&$userT& _
											'" password= "'&$passT&'" binpath= ' & '"c:\program files\FGMagent\FGMagent.exe"'
			$var=_GetDOSOutputRunAs($sCommand,$userT,$passT)
			If StringInStr($var,"SUCCESS")>0 Then
				MemoWrite($iMemo,@TAB&_clearEmptyLines($var)  ,"Darkgreen",8,1)
			Else
				MemoWrite($iMemo,@TAB&_clearEmptyLines($var),"red",10,1)
				Return false
			endif
			If _ExistService("FGMagent",$userT,$passT)=1 Then
				MemoWrite($iMemo,@TAB&"FGMagent service was installed" ,"Darkgreen",8,1)
			Else
				MemoWrite($iMemo,@TAB&"FGMagent service was not installed" ,"red",10,1)
;~ 				MemoWrite($iMemo,@TAB&_clearEmptyLines($var) ,"red",8,1)
				Return false
			endif
			Return true
		EndFunc
		Func _UninstallServiceFGM($userT,$passT)
			ConsoleWrite('++_UninstallServiceFGM() = '& @crlf)
			_KillProcess("mmc.exe",$userT,$passT)
			$sCommand='sc delete FGMagent'
			$var=_GetDOSOutputRunAs($sCommand,$userT,$passT)
			If StringInStr($var,"SUCCESS")>0 Then
				MemoWrite($iMemo,@TAB&_clearEmptyLines($var),"Darkgreen",8,1)
			Else
				MemoWrite($iMemo,@TAB&_clearEmptyLines($var) ,"red",10,1)
			endif
			If Not _ExistService("FGMagent",$userT,$passT)=1 Then
				MemoWrite($iMemo,@TAB&"FGMagent service is uninstalled" ,"Darkgreen",8,1)
			Else
				MemoWrite($iMemo,@TAB&"FGMagent service was not uninstalled" ,"red",10,1)
;~ 				MemoWrite($iMemo,@TAB&_clearEmptyLines($var) ,"red",8,1)
				Return false
			endif
			Return true
		EndFunc
		Func _SetServiceDescriptionFGM($userT,$passT)
			ConsoleWrite('++_SetServiceDescriptionFGM() = '& @crlf)
			$sCommand='sc description FGMagent "Runs diagnostic of service control."'
			$var=_GetDOSOutputRunAs($sCommand,$userT,$passT)
			If StringInStr($var,"SUCCESS")>0 Then
				MemoWrite($iMemo,@TAB&"FGMagent service description set.","Darkgreen",8,1)
;~ 				MemoWrite($iMemo,@TAB& _clearEmptyLines($var) ,"Darkgreen",8,1)
			Else
				MemoWrite($iMemo,@TAB&"FGMagent service description was not set.","red",10,1)
				MemoWrite($iMemo,@TAB& _clearEmptyLines($var) ,"red",8,1)
				Return false
			endif
			Return true
		EndFunc
		Func _StartServiceFGM($userT,$passT)
			ConsoleWrite('++_StartServiceFGM() = '& @crlf)
			$sCommand='sc start FGMagent'
			$var=_GetDOSOutputRunAs($sCommand,$userT,$passT)
			If StringInStr($var,"SUCCESS")>0 Then
				MemoWrite($iMemo,@TAB&"FGMagent service was started for testing.","Darkgreen",8,1)
;~ 				MemoWrite($iMemo,@TAB& _clearEmptyLines($var) & @crlf,"Darkgreen",8,1)
			Else
				MemoWrite($iMemo,@TAB&"FGMagent service cannot be started for testing.","red",10,1)
				MemoWrite($iMemo,@TAB& _clearEmptyLines($var) & @crlf,"red",8,1)
				Return false
			endif
			Return true
		EndFunc
		Func _StopServiceFGM($userT,$passT)
			ConsoleWrite('++_StopServiceFGM() = '& @crlf)
			$sCommand='sc stop FGMagent'
			$var=_GetDOSOutputRunAs($sCommand,$userT,$passT)
			If StringInStr($var,"SUCCESS")>0 Then
				MemoWrite($iMemo,@TAB&"FGMagent service was stopped. output= ","Darkgreen",8,1)
;~ 				MemoWrite($iMemo,@TAB& _clearEmptyLines($var),"Darkgreen",8,1)
			Else
				MemoWrite($iMemo,@TAB&"FGMagent service cannot be stopped. Output= ","red",10,1)
				MemoWrite($iMemo,@TAB& _clearEmptyLines($var) ,"red",8,1)
				Return false
			endif
			Return true
		EndFunc
		Func _CheckServiceStatus($servicename,$userT,$passT)
			ConsoleWrite('++_CheckServiceStatus() = $servicename= '& $servicename & @crlf)
			$sCommand='sc query ' & $servicename & '| find "STATE"'
			$var=_GetDOSOutputRunAs($sCommand,$userT,$passT)
			Select
				Case StringInStr($var,"RUNNING")>0
					MemoWrite($iMemo,@TAB&"FGMagent service is RUNNING","Darkgreen",8,1)
					Return 1
				Case StringInStr($var,"STOPPED")>0
					MemoWrite($iMemo,@TAB&"FGMagent service is STOPPED","orange",8,1)
					Return 0
				Case Else
					MemoWrite($iMemo,@TAB&"FGMagent service - status check - error.","red",10,1)
					MemoWrite($iMemo,@TAB& _clearEmptyLines($var) & @crlf,"red",8,1)
					Return -1
			EndSelect
		EndFunc
		Func _ExistService($servicename,$userT,$passT)
			ConsoleWrite('++_ExistService() = $servicename= '&$servicename &  @crlf)
			$sCommand='sc query ' & $servicename ;& '| find "STATE"'
			$var=_GetDOSOutputRunAs($sCommand,$userT,$passT)
			$var=_clearEmptyLines($var)
			Select
				Case StringInStr($var,"The specified service does not exist as an installed service.")>0
					MemoWrite($iMemo,@TAB&"FGMagent service do not exist.","orange",8,1)
					Return 0
				Case StringInStr($var,"SERVICE_NAME: FGMAgent")>0
;~ 					MemoWrite($iMemo,@TAB&"FGMagent service exist","darkgreen",8,1)
					Return 1
				Case Else
					MemoWrite($iMemo,@TAB&"FGMagent service - exist ckeck - error.","red",10,1)
					MemoWrite($iMemo,@TAB& _clearEmptyLines($var) ,"red",8,1)
					Return -1
			EndSelect
		EndFunc
	#endregion
#endregion
