	#region ******************************** FORM SETTINGS                ***********************
		Func _FillSettingsFormData()
			ConsoleWrite('+++_FillSettingsFormData() = '& @crlf )
			; delete credential of non logged user
				_DeleteCredassert()
			;credentals tab
				_FillCredSettingsListbox()
			;servers tab
				_FillServersList()
			;groups tab
				_FillCustomGroupCMB()
				_FillCustomServerCMB()
				_FillCustomShareLst()
				_FillCustomServersLst()
			;users combo at application preferences
				_Fill_task_credCMB($CMB_Proxy_Cred)
			EndFunc
		Func FormSettingsClose()
			ConsoleWrite('++FormSettingsClose() = '& @crlf )
			GUIDelete($SettingsForm)
			_SettingsVarInit()
			_JobsVarsInit()
			_TaskFormsInit()
			_ReduceMemory()
			GUISetState(@SW_SHOW,$MainfORM)
		EndFunc
		Func _CheckIfFGMAdmin()
			ConsoleWrite('++_CheckIfFGMAdmin() = '& @crlf )
			$query="SELECT value FROM Configuration WHERE config='Administrators';"
			_SQLITEqry($query,$Basedbfile,$quietSQLQuery)
			If  IsArray($qryResult) then
;~ 				@logonDNSdomain
				If _ArraySearch($qryResult,@UserName) Then Return true
			endif
			Return false
		EndFunc
		#region --------------------------------- Settings-Credentials general  -----------------------------------------------------
			Func _SettingsCreds_save()
				ConsoleWrite('++SettingsCreds_save() = '& @crlf )
				;id field is autoincrement (integer)
				;dir y username es un indice UNIQUE
				$query='INSERT OR REPLACE INTO credentials VALUES (NULL,"' & _
								_Hashing($creddomainvalue,0)& '","' & _
								_Hashing($creduservalue,0) & '","' & _
								_Hashing(_ctrlRead($TXT_credpassword),0) & '","' & _
								@UserName &'");'

				if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
;~ 					MsgBox(64+4096,"Saving credentials data","The Credential was stored",0)
				Else
					MsgBox(48+4096,"Saving credentials error","An error saving the credential. ErrNo 1002",0)
				EndIf
			EndFunc
			Func _FillCredSettingsListbox()
				ConsoleWrite('++_FillCredSettingsListbox() = '& @crlf )
				$query='SELECT * FROM credentials;'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					;deshashear las columnas
					Local $iColumna=1  ;columna de domain
					$qryResultUnHashed=_HashingColumnArray($qryResult,$iColumna,0)
					Local $iColumna=2  ;columna de username
					$qryResultUnHashed=_HashingColumnArray($qryResultUnHashed,$iColumna,0)
					_FillTableSQL($LST_CredManage,$qryResultUnHashed,3)
				endif
				_GUICtrlListView_SetColumnWidth($LST_CredManage, 2, 1)
			EndFunc
			Func _DeleteCredassert() ; borra los rows que no machean el login
				ConsoleWrite('++_DeleteCredassert() = '& @crlf )
				if @Compiled then
					$query='DELETE FROM credentials WHERE login <> "' & @UserName & '";'
					_SQLITErun($query,$profiledbfile,$quietSQLQuery)
				endif
			EndFunc
			Func _Deletecred()
				ConsoleWrite('++_Deletecred() = '& @crlf )
				$creddomainvalue=GUICtrlRead($TXT_creddomain)
				$creduservalue=GUICtrlRead($TXT_creduser)
				$domainencripted=_Hashing($creddomainvalue,0)
				$userencripted=_Hashing($creduservalue,0)
				if @Compiled then
				$query='DELETE FROM credentials WHERE login = "' &  @UserName & _
													'" and domain = "' & $domainencripted & _
													'" and userid= "'  &  $userencripted  & '";'
				Else
				$query='DELETE FROM credentials WHERE domain = "' & $domainencripted & _
													'" and userid= "'  &  $userencripted  & '";'
				EndIf
				_SQLITErun($query,$profiledbfile,$quietSQLQuery)
			EndFunc
			Func  TXT_credpasswordChange()
				consoleWrite("++TXT_credpasswordChange()"& @CRLf)
				if GUICtrlRead($TXT_credpassword)="" then
					GUICtrlSetState($btn_credshowpass,$GUI_DISABLE)
				Else
					GUICtrlSetState($btn_credshowpass,$GUI_ENABLE)
				endif
			EndFunc
		#endregion
		#region --------------------------------- settings custom group-servers -----------------------------------------------------
			Func _FillCustomGroupCMB()
				ConsoleWrite('++_FillCustomGroupCMB() = '& @crlf )
				$query='SELECT distinct(servergroupname) FROM servergroups WHERE custom=1 order by servergroupname;'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					_FillComboSQL($CMB_custselectgroup,$qryResult)
				endif
			EndFunc
			Func _FillCustomServerCMB()
				ConsoleWrite('++_FillCustomServerCMB() = '& @crlf )
				$query='SELECT servername FROM servers order by servername ;'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					_FillComboSQL($CMB_custselectserver,$qryResult)
				endif
			EndFunc
			Func _custaddcreategrp()
				ConsoleWrite('++_custaddcreategrp() = '& @crlf )
				local $grpid='SELECT groupid FROM servergroups WHERE servergroupname="' & _CtrlRead($CMB_custselectgroup) & '" '
				Local $srvid='Select serverID FROM servers WHERE servername="' & _CtrlRead($CMB_custselectserver) & '" '
				$query='REPLACE INTO servergroups VALUES ((' & $grpid & '),"' & _CtrlRead($CMB_custselectgroup) & '",1); '
				$query=$query&'UPDATE RServerGroup SET groupid=(' & $grpid& ') WHERE serverid=(' & $srvid & ');'
				if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
					MsgBox(64+4096,"Saving Custom Group data","The Custom Group data was stored",0,0)
				Else
					MsgBox(48+4096,"Saving Custom Group error","An error saving the Custom Group data . ErrNo 1003",0,0)
				EndIf
			EndFunc
			Func _FillCustomServersLst()
				ConsoleWrite('++_FillCustomServersLst() = '& @crlf )
					$query='SELECT servergroups.servergroupname,Servers.servername FROM Servers INNER JOIN RServerGroup ON RServerGroup.ServerID = Servers.serverid  INNER JOIN servergroups ON servergroups.groupid = RServerGroup.groupID' & _
						' WHERE servergroups.servergroupname="' & _CtrlRead($CMB_custselectgroup)  & '" AND servergroups.custom=1 ORDER BY servergroups.servergroupname,servers.servername ;'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					_FillTableSQL($LST_custsrvgrp,$qryResult,3,0)
				endif
			EndFunc
			Func _DeleteCustomGroup()
				ConsoleWrite('++_DeleteCustomGroup() = '& @crlf )
				local $grpid='SELECT groupid FROM servergroups WHERE servergroupname="' & _CtrlRead($CMB_custselectgroup) & '" '
				$query='UPDATE Rservergroup SET groupID=1 WHERE serverID=(' & $grpid& ');'
				$query=$query&'DELETE FROM servergroups WHERE servergroupname="' & _CtrlRead($CMB_custselectgroup) & '";'
				if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
					MsgBox(64+4096,"Delete Custom Group data","The Custom Group data was deleted",0,0)
				Else
					MsgBox(48+4096,"Delete Custom Group error","An error deleting the Custom Group data . ErrNo 1025",0,0)
				EndIf
			EndFunc
			Func _deletecustListDeleteSrv()
				ConsoleWrite('++_deletecustListDeleteSrv() = '& @crlf )
				local $grpid='SELECT groupid FROM servergroups WHERE servergroupname="' & _CtrlRead($CMB_custselectgroup) & '" '
				Local $srvid='Select serverID FROM servers WHERE servername="' & _CtrlRead($CMB_custselectserver) & '" '
				$query='DELETE FROM servers WHERE servername="' & GUICtrlRead($CMB_custselectserver) & '";'
				$query=$query&'DELETE FROM RServerGroup WHERE groupid=(' & $grpid& ') AND serverid=(' & $srvid & ');'
				if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
					MsgBox(48+4096,"Delete Server from custom Group","The Server from Custom Group was deleted",0,0)
				Else
					MsgBox(48+4096,"Delete Server from custom Group error","An error Deleting server from custom group . errNo 1005",0,0)
				endif
			EndFunc
			Func _FillCustomTabControls()
				ConsoleWrite('++_FillCustomTabControls() = '& @crlf)
				$grporig=_ctrlread($CMB_custselectgroup)
				_FillCustomGroupCMB()
				_FillCustomServerCMB()
				ControlCommand ($SettingsForm, "", $CMB_custselectgroup, "SelectString", $grporig)
				_FillCustomServersLst()
				_FillServersList()
				If _GUICtrlListView_GetSelectedCount($LST_custsrvgrp)=0 Then
					GUICtrlSetState($BTN_custlistdeletesrv,$GUI_DISABLE)
				endif
			EndFunc
		#endregion
		#region --------------------------------- settings custom shares        -----------------------------------------------------
			Func _custaddshare()
				ConsoleWrite('++_custaddshare() = '& @crlf )
				;id field is autoincrement (integer)
				;dir y username es un indice UNIQUE
				local $shareid='SELECT shareid FROM customshares WHERE sharename="' & _CtrlRead($TXT_custsharename)  & '"'
				$query='REPLACE INTO customshares VALUES ((' & $shareid & '),"' & _CtrlRead($TXT_custsharename)  &  _
									'","' & _CtrlRead($TXT_custsharepath)  & '");'
				if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
					MsgBox(64+4096,"Saving Custom Share data","The Custom Share was stored",0,0)
				Else
					MsgBox(48+4096,"Saving Custom Share  error","An error saving the Custom Share . ErrNo 1004",0,0)
				EndIf
			EndFunc
			Func _FillCustomShareLst()
				ConsoleWrite('++_FillCustomShareLst() = '& @crlf )
				$query='SELECT shareid,sharename,sharepath FROM customshares ORDER BY sharename;'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					_FillTableSQL($LST_custshare,$qryResult,3,1)
				endif
				If _GUICtrlListView_GetSelectedCount($LST_custshare)=0 Then
					GUICtrlSetState($BTN_custdeleteshare,$GUI_DISABLE)
				endif
			EndFunc
			Func _custDeleteshare()
				ConsoleWrite('++_custDeleteshare() = '& @crlf )
				$query='DELETE FROM customshares WHERE sharename="' & GUICtrlRead(StringStripWS($TXT_custsharename,3)) & '";'
				_SQLITErun($query,$profiledbfile,$quietSQLQuery)
			EndFunc
		#endregion
		#region --------------------------------- Import export   Jobs          -----------------------------------------------------
			Func FormJobImportClose()
				ConsoleWrite('++FormJobImportClose() = '& @crlf)
				GUIDelete($FormJobImport)
				_ReduceMemory()
				GUISetState(@SW_SHOW,$SettingsForm)
			EndFunc
			Func FormJobImport_fillData()
				ConsoleWrite('++FormJobImport_fillData() = '& @crlf)
				 _FillJobList_Export()
			EndFunc
			Func _FillJobList_Export()
				ConsoleWrite('++_FillJobList_Export() = '& @crlf )
				$query='SELECT jobname,jobdesc,jobuid FROM jobs;'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					_FillTableSQL($LST_importExport_ExportJoblist,$qryResult,3,0,1)
				endif
;~ 				_GUICtrlListView_SetColumnWidth($LST_importExport_ExportJoblist, 2, $LVSCW_AUTOSIZE_USEHEADER)
				_GUICtrlListView_SetColumnWidth($LST_importExport_ExportJoblist, 2, 1)
			EndFunc
			Func _ImportFile_fillListData()
				ConsoleWrite('++_ImportFile_fillListData() = '& @crlf)
				If Not _FileReadToArray(_ctrlread($TXT_importExtort_fileImport),$importArr) Then
					MsgBox(4096, "Error", " Error reading FGM Job file.     error:" & @error)
					GUICtrlSetData($TXT_importExtort_fileImport,"")
					GUICtrlSetstate($BTN_importExport_Import,$GUI_DISABLE)
				else
					Dim $Tarr[1][3]
					$r=0
					$c=0
					For $x = 1 To $importArr[0]
						$lineaArr=StringSplit(_Hashing($importArr[$x],1),",")
						If $lineaArr[1]="JOB" Then
							$r=$r+1
							ReDim $Tarr[$r+1][3]
							$Tarr[$r][1]=$lineaArr[3]
							$Tarr[$r][2]=$lineaArr[4]
						endif
					Next
					If  IsArray($Tarr) then
						_FillTableSQL($LST_importExport_ImportJoblist,$Tarr,3,1,1)
					endif
					GUICtrlSetstate($BTN_importExport_Import,$GUI_ENABLE)
				EndIf
			EndFunc
			Func _selectExportFile()
				ConsoleWrite('++_selectExportFile() = '& @crlf)
				Local Const $sMessage = "Save Export File as."
				Local $sFileOpenDialog = FileSaveDialog ($sMessage, @WorkingDir & "\", "FGM (*.fgm)",2+16,"JobExport_"&StringReplace(_NowCalcDate(),"/","_")&".fgm")
				if StringRight($sFileOpenDialog,4) <> ".fgm" Then
					$sFileOpenDialog=$sFileOpenDialog&".fgm"
				endif
				If @error Then
					MsgBox(64+4096, "", "No file was selected.")
					GUICtrlSetData($TXT_importExport_fileExport,"")
				Else
					If Not FileExists($sFileOpenDialog) then
						$file = FileOpen($sFileOpenDialog,2)
						If $file = -1 Then
							GUICtrlSetData($TXT_importExport_fileExport,"")
							MsgBox(48, "Error", "Unable to create file.")
							Return
						EndIf
						FileClose($file)
					Else
						MsgBox(64,"File already exist","FYI."&@crlf&"File already exist.")
					endif
					GUICtrlSetData($TXT_importExport_fileExport,$sFileOpenDialog)
				EndIf
			EndFunc
			Func _selectImportFile()
				ConsoleWrite('++_selectImportFile() = '& @crlf)
				Local Const $sMessage = "Select file for import."
				Local $sFileOpenDialog = FileOpenDialog($sMessage, @WorkingDir & "\", "FGM (*.fgm)",1+2)
				If @error Then
					MsgBox(64+4096, "", "No file was selected.")
					GUICtrlSetData($TXT_importExtort_fileImport,"")
				Else
					GUICtrlSetData($TXT_importExtort_fileImport,$sFileOpenDialog)
				EndIf
			EndFunc
			Func _ExportJobs()
				ConsoleWrite('++_ExportJobs() = '& @crlf)
				$contador=0
				$fila=_ctrlread($TXT_importExport_fileExport)
				$arr=_GetArrayListCheckedItems($LST_importExport_ExportJoblist)
				If UBound($arr)=1 Then
					MsgBox(48+4096, "Exporting Job", "Select Job for Export")
				ElseIf FileExists($fila) then
					Local $fileh = FileOpen($fila, 2)
					If $fileh = -1 Then
						MsgBox(48+4096, "Error Exporting Job", "Unable to open file "&$fila&" for export")
						Return 1
					EndIf
					FileWriteLine($fileh,"VERSION,"&$ImportExportVersion)
					FileClose($fileh)
					For $i=1 To UBound($arr)-1
						$avArray=StringSplit($arr[$i],"|")
						; read job record
						$query='SELECT * FROM jobs WHERE jobuid=' & $avArray[3] & ';'
						_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
						If _ArrayToFile($fila,$qryResult,1,"JOB",1)=0 Then
							$contador=$contador+1
						endif
						;resd task rows for the job
						$query='SELECT taskid,taskuid,tasktype,vertice,type,unit,jobuid,taskname,"-","-",taskorder,filter,active FROM tasks WHERE jobuid=' & $avArray[3] & ' ORDER BY taskorder;'
						_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
						If _ArrayToFile($fila,$qryResult,1,"TASK",1)=0 Then
							$contador=$contador+1
						endif
					next
				Else
					MsgBox(48+4096, "Exporting Job", "Select a File for Export")
				endif
				If $contador=(UBound($arr)-1)*2 And $contador>0 And UBound($arr)>1 Then
					MsgBox(64+4096, "Exporting Job", "The Export to file "&$fila&" was successful")
				Else
					MsgBox(648+4096, "Error Exporting Job", "The Export to file "&$fila&" is faulty")
				endif
			EndFunc
			Func _ImportJobs()
				ConsoleWrite('++_ImportJobs() = '& @crlf)
				If Not _FileReadToArray(_ctrlread($TXT_importExtort_fileImport),$importArr) Then
					MsgBox(4096, "Error", " Error reading FGM Job file.     error:" & @error)
					Return false
				else
					Dim $Tarr[1][3]
					$r=0
					$c=0
					$taskorig="xxxx"
					For $x = 1 To $importArr[0]
						$lineaArr=StringSplit(_Hashing($importArr[$x],1),",")
						Switch $lineaArr[1]
							Case "VERSION"
								If $lineaArr[2]<>$ImportExportVersion Then
									MsgBox(48+4096, "Importing Job", "The File is not compatible with this FGM version"&@crlf&"Jobs can be only imported only on matching versions")
									Return false
								endif
							Case "JOB"
								_CreateJobID()
								$Jname=$lineaArr[3]
								$xx=0
								While _ExistJobName($Jname)
									$xx=$xx+1
									$Jname=$lineaArr[3]&"("& $xx &")"
								WEnd
								$query='INSERT INTO jobs VALUES (null,' & _
									$jobid & ',"' & $Jname & '","' & $lineaArr[4] & '",' & $lineaArr[5] & ');'
								ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $query = ' & $query & @crlf )
								if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
								Else
									MsgBox(48+4096,"Importing error","An error Importing. ErrNo 1021" & @CRLF & $query,0,0)
									Return false
								EndIf
							Case "TASK"
								If $taskorig=$lineaArr[2] Then
								Else
									_CreateTaskID()
									$taskorig=$lineaArr[2]
								endif
								$query='INSERT INTO tasks VALUES (null,' & _
											$TaskID & ',"' & _
											$lineaArr[3] & '","' & _
											$lineaArr[4] & '","' & _
											$lineaArr[5] & '","' & _
											$lineaArr[6] & '",' & _
											$JobId & ',"' & _
											$lineaArr[8] & '","' & _
											$lineaArr[9] & '","' & _
											$lineaArr[10] & '",' & _
											$lineaArr[11] & ',"' & _
											$lineaArr[12] & '",' & _
											$lineaArr[13] & ');'
								if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
								Else
									MsgBox(48+4096,"Importing error","An error Importing. ErrNo 1021" & @CRLF & $query,0,0)
									Return false
								EndIf
							Case Else
						EndSwitch
					Next
				EndIf
				_FillJobList_Export()
				Return true
			EndFunc
			Func _ExistJobName($jname)
				ConsoleWrite('++_ExistJobName() = '& @crlf )
				$query='SELECT count(*) FROM jobs WHERE jobname="' & $jname& '"'
;~ 				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
;~ 				If  IsArray($qryResult) then
;~ 					If UBound($qryResult)>1 then
;~ 						$res=$qryResult[1][0]
;~ 					Else
;~ 						$res=0
;~ 					endif
;~ 				endif
				$res=_SQLITEgetUnit($query,$profiledbfile,$quietSQLQuery)
				if $res="" then $res=0
				If $res>0 Then
					Return true
				Else
					Return false
				endif
			EndFunc
			Func _GetArrayListCheckedItems($listview)
				ConsoleWrite('++_GetArrayListCheckedItems() = '& @crlf)
				Dim $avArray[1]
				For $x = 1 To _GUICtrlListView_GetItemCount($listview)
					If _GUICtrlListView_GetItemChecked($listview, $x - 1) Then
						$ar=_GUICtrlListView_GetItemTextString($listview, $x - 1)
						_ArrayAdd($avArray,$ar)
					EndIf
				Next
				Return $avArray
			EndFunc
		#endregion
		#region --------------------------------- Servers add                   -----------------------------------------------------
			Func _FillServersList()
				ConsoleWrite('++_FillServersList() = '& @crlf)
				$query='SELECT Servers.servername, Servers.ip,servergroups.servergroupname,Servers.custom,Servers.trash FROM Servers ' & _
							'INNER JOIN RServerGroup ON RServerGroup.ServerID = Servers.serverid ' & _
							'INNER JOIN servergroups ON servergroups.groupid = RServerGroup.groupID'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					_FillTableSQL($LST_settings_serversAdd,$qryResult,3,0,1,4)
				endif
				_GUICtrlListView_SetColumnWidth($LST_settings_serversAdd, 0,$LVSCW_AUTOSIZE  )
			EndFunc
			Func _AddNewServer()
				ConsoleWrite('++_AddNewServer() = '& @crlf)
				$contador=0
				Local $srvid='Select serverID FROM servers WHERE servername="' & StringLower(_CtrlRead($TXT_settings_FQDN)) & '" '

				$query=$srvid
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				ConsoleWrite('!!! Debug(' & @ScriptLineNumber & ') : UBound($qryResult) = ' & UBound($qryResult) & @crlf )
				$toTrash=0
				If  IsArray($qryResult) Then
					if UBound($qryResult)=1 then $toTrash=1
				Else
					MsgBox(48+4096,"Saving Custom server error","An error saving the Custom server . ErrNo 2013",0,0)
				endif

				$query='REPLACE INTO servers VALUES ((' & $srvid & '),"' & StringLower(_CtrlRead($TXT_settings_FQDN)) & _
							'","description","' & _GUICtrlIpAddress_get($IPAddress1) & '",1,'& $toTrash & ');'
				if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then $contador=1

				$cuenta=0
				$query='SELECT count(*) FROM RServerGroup WHERE serverID=(' & $srvid & ') ;'
;~ 				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
;~ 				If  IsArray($qryResult) Then
;~ 					If UBound($qryResult)>1 then
;~ 						$cuenta=Int($qryResult[1][0])
;~ 					endif
;~ 				endif
				$cuenta=_SQLITEgetUnit($query,$profiledbfile,$quietSQLQuery)
				if $cuenta="" then
					$cuenta=0
				Else
					$cuenta=Int($cuenta)
				endif
				If $cuenta=0 Then
					$query='INSERT into RServerGroup VALUES ((' & $srvid & '),1);'
					if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then $contador=$contador+1
				endif
				Switch $contador
					Case 1
;~ 						MsgBox(64+4096,"Saving Custom server data","The Custom server was updated",0,0)
					Case 2
;~ 						MsgBox(64+4096,"Saving Custom server data","The Custom server was stored",0,0)
					Case 0
						MsgBox(48+4096,"Saving Custom server  error","An error saving the Custom server . ErrNo 1023",0,0)
				EndSwitch
			EndFunc
			Func _DeleteserverManagement()
				ConsoleWrite('++_DeleteserverManagement() = '& @crlf)
;~ 				DllCall("user32.dll", "int", "GetScrollPos", "hwnd", GUICtrlGetHandle($LST_settings_serversAdd), "int", $SB_VERT)
				If _GUICtrlListView_GetSelectedCount($LST_settings_serversAdd)=1 Then
					$lineValues=_GUICtrlListView_GetItemTextArray($LST_settings_serversAdd)
					If _CheckIfCustomServer($lineValues[1]) Or _CheckIfTrash($lineValues[1]) Then
						Local $srvid='Select serverID FROM servers WHERE servername="' & $lineValues[1]& '" '
						$query='DELETE FROM servers WHERE servername="' &$lineValues[1]& '" ;'
						$query=$query&'DELETE FROM RserverGroup WHERE serverID=(' & $srvid & ') ;'
						if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
;~ 							MsgBox(64+4096,"Deleting server","The server was deleted.",0,0)
						Else
							MsgBox(48+4096,"Delete server error","An error Deleting the server. ErrNo 1024" & @CRLF & $query,0,0)
						EndIf
					Else
						MsgBox(48+4096,"Delete server error","The server is not a custom one."& @CRLF &"This server can be deleted only by the administrator." & @CRLF ,0,0)
					endif
				Else
					MsgBox(48+4096,"Delete server error","Select a server to Delete",0,0)
				endif
			EndFunc
			Func _CheckIfCustomServer($srv)
				ConsoleWrite('++_CheckIfCustomServer() = '& @crlf)
				Local $srvid='Select serverID FROM servers WHERE servername="' &$srv& '" '
				$query='SELECT count(*) FROM servers WHERE servername="' &$srv& '" AND custom=1 ;'
;~ 				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
;~ 				If  IsArray($qryResult) then
;~ 					If UBound($qryResult)>1 then
;~ 						$res=$qryResult[1][0]
;~ 					endif
;~ 				endif
				$res=_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If $res=1 Then
					Return true
				Else
					Return false
				endif
			EndFunc
			Func _FillListResetServers2template()
				ConsoleWrite('++_FillListResetServers2template() = '& @crlf)
				$query='SELECT Servers.servername, Servers.ip,servergroups.servergroupname,Servers.description ' & _
						'FROM Servers ' & _
						'INNER JOIN RServerGroup ON RServerGroup.ServerID = Servers.serverid ' & _
						'INNER JOIN servergroups ON RServerGroup.groupID = servergroups.groupid ' & _
						'WHERE  Servers.custom=1 OR Servers.trash=1 AND Servers.serverName<>"_dummyServer" ; '
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				GUICtrlSetData($LBL_ResetServers2Template,"Total servers: " & ubound($qryResult,1)-1 )
				If  IsArray($qryResult) then
					if UBound($qryResult)>1 then
						_FillTableSQL($LST_MSGBoxScroll,$qryResult,3,0)
					Else
						GUICtrlSetData($BTN_ResetServers2TemplateOK,"Reset to project")
					endif
				Else
					_GUICtrlListView_DeleteAllItems($LST_MSGBoxScroll)
					GUICtrlSetData($BTN_ResetServers2TemplateOK,"Reset All")
				endif
			EndFunc
			Func _ResetServers2template()
				ConsoleWrite('++_ResetServers2template() = '& @crlf)
				$query='Select serverID FROM servers WHERE  custom=1 OR trash=1 AND serverName<>"_dummyServer" ;'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					For $iRows = 1 To UBound($qryResult,1)-1
						$srvid=$qryResult[$iRows][0]
						$query='DELETE FROM servers WHERE serverid="' &$srvid& '" ;'
						$query=$query&'DELETE FROM RserverGroup WHERE serverID="' & $srvid & '" ;'
						GUICtrlSetData($LBL_ResetServers2TemplateProgress," Deleting " &  $iRows & "/" & UBound($qryResult,1)-1 )
						if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
;~ 							MsgBox(64+4096,"Deleting server","The server was deleted.",0,0)
						Else
							MsgBox(48+4096,"Delete server error","An error Deleting the server. ErrNo 1052" & @CRLF & $query,0,0)
						EndIf
					next
				endif
			EndFunc
			Func _FillListKeepOnlyCustom()
				ConsoleWrite('++_FillListKeepOnlyCustom() = '& @crlf)
				$query='SELECT Servers.servername, Servers.ip,servergroups.servergroupname,Servers.description ' & _
						'FROM Servers ' & _
						'INNER JOIN RServerGroup ON RServerGroup.ServerID = Servers.serverid ' & _
						'INNER JOIN servergroups ON RServerGroup.groupID = servergroups.groupid ' & _
						'WHERE  Servers.custom<>1 AND Servers.serverName<>"_dummyServer" ; '
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				GUICtrlSetData($LBL_ResetServers2Template,"Total servers: " & ubound($qryResult,1)-1 )
				If  IsArray($qryResult) then
					_FillTableSQL($LST_MSGBoxScroll,$qryResult,3,0)
				Else
					_GUICtrlListView_DeleteAllItems($LST_MSGBoxScroll)
				endif
			EndFunc
			Func _ResetKeepOnlyCustom()
				ConsoleWrite('++_ResetKeepOnlyCustom() = '& @crlf)
				$query='Select serverID FROM servers WHERE  custom=0 AND serverName<>"_dummyServer" ;'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					For $iRows = 1 To UBound($qryResult,1)-1
						$srvid=$qryResult[$iRows][0]
						$query='DELETE FROM servers WHERE serverid="' &$srvid& '" ;'
						$query=$query&'DELETE FROM RserverGroup WHERE serverID="' & $srvid & '" ;'
						GUICtrlSetData($LBL_ResetServers2TemplateProgress," Deleting " &  $iRows & "/" & UBound($qryResult,1)-1 )
						if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
;~ 							MsgBox(64+4096,"Deleting server","The server was deleted.",0,0)
						Else
							MsgBox(48+4096,"Delete server error","An error Deleting the server. ErrNo 1053" & @CRLF & $query,0,0)
						EndIf
					next
				endif
			EndFunc
			Func  ResetServers2Template_FormClose()
				ConsoleWrite('++ResetServers2Template_FormClose() = '& @crlf )
				GUIDelete($ResetServers2TemplateForm)
			EndFunc
		#endregion
		#region --------------------------------- Application settings          -----------------------------------------------------
			Func _UpdateAppSettings($value,$key)
				if $flagUpdateSettings=1 then
					ConsoleWrite('++_UpdateAppSettings() Value= '& $value & "  Key= " & $key & @crlf)
					$Config="AppSettings"
					$query="INSERT OR replace into Configuration  (Config,value,key) VALUES ('"&$Config&"','"& $value &"','"&$key&"') ;"
					if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
						return true
					Else
						MsgBox(48+8192,"Saving Configuration error","An error saving configuration data. ErrNo 1051" & @CRLF & $query,0,0)
						return false
					EndIf
					return false
				Else
					return true
				endif
			EndFunc
			Func _GetAppSettings($value,$defstatus,$upsert=0)  ;$upsert=1 if data is empty then instert it
				ConsoleWrite('++_GetAppSettings() = '&$value& @crlf)
				$res=$defstatus
				$query="SELECT key FROM Configuration WHERE value='"& $value &"';"
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)   ;
				If  IsArray($qryResult) then
					if UBound($qryResult)>1 then
						$res=$qryResult[1][0]
						Return $res
					endif
				endif
				if $upsert=1 then
					$query='INSERT OR REPLACE INTO Configuration VALUES ("AppSettings","' & $value & '","' & $defstatus & '");'
					if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
					Else
						MsgBox(48+8192,"Saving Configuration error","An error saving configuration data. ErrNo 1054  _GetAppSettings" & @CRLF & $query,0,0)
					EndIf
				endif
				Return $res
			EndFunc
			Func _selectExecuteFolderAppSettings()
				ConsoleWrite('++_selectExecuteFolderAppSettings' & @crlf )
				Local $sMessage = "Select default folder for executables"
				If $executeFileFolderDefault="" Then $executeFileFolderDefault=@WorkingDir
				Local $sFileOpenDialog = FileSelectFolder ( $sMessage,"" ,1+2+4 , $executeFileFolderDefault ,$SettingsForm)
				If @error Then
				Else
					GUICtrlSetData($TXT_settingspref_ExecutableFileFolderDefault,$sFileOpenDialog)
				EndIf
			EndFunc
			Func _selectActivityLogFolderAppSettings()
				ConsoleWrite('++_selectActivityLogFolderAppSettings' & @crlf )
				Local $sMessage = "Select default folder for Activity log"
				If $ActivityLogFolder="" Then $ActivityLogFolder=@ScriptFullPath
				Local $sFileOpenDialog = FileSelectFolder ( $sMessage,"" ,1+2+4 , _ctrlread($TXT_settingspref_ActivityLogFolder) ,$SettingsForm)
				If @error Then
				Else
					GUICtrlSetData($TXT_settingspref_ActivityLogFolder,$sFileOpenDialog)
				EndIf
			EndFunc
			Func _RecognizeRepoType($repodir)
				ConsoleWrite('++_RecognizeRepoType() = '& @crlf)
				$res= _CheckTypeRegex($repodir)
				ConsoleWrite('RepoType = ' & $res & @crlf )
				return $res
			EndFunc
			Func _CheckTypeRegex($rgx)
				ConsoleWrite('++_CheckTypeRegex() = '& @crlf)
				$resShare=0
				$resPesos=0
				$resShare= StringRegExp($rgx,"(\A\\{2}[a-zA-Z0-9.]+(\\{1}[a-zA-Z0-9]+)\z)",0)
				$resPesos= StringRegExp($rgx,"(\A\\{2}[a-zA-Z0-9.]+\\{1}[a-zA-Z]{1}[$]{1}((\\{1}[a-zA-Z0-9]+)+\z)?\z)",0)
				$resto= ($resShare or $resPesos)
				if $resto then
					return "smb"
				endif

				$reshttp=0
				$reshttp= StringRegExp($rgx,"(^http.?://.*[a-zA-Z0-9]$)",0)
				if $reshttp then
					return "http"
				endif

				$reslocal=0
				$reslocal= StringRegExp($rgx,"(\A[c-zC-Z]{1}:{1}(\\{1}[a-zA-Z0-9\s_.$@*]+)+\Z)",0)
				if $reslocal then
					return "local"
				endif
				return 0
			EndFunc
			Func _OpenRepo($repoPath)
				ConsoleWrite('++_OpenRepo() = '&$repoPath& @crlf)
				$res=_RecognizeRepoType($repoPath)
				Switch $res
					case "local"
						Run("C:\WINDOWS\EXPLORER.EXE /n,/e," & $repoPath)
					case "smb"
						Run("C:\WINDOWS\EXPLORER.EXE /n,/e," & $repoPath)
					case "http"
						$res=_IECreate($repoPath, 0, 1, 0,1)
					case Else
						MsgBox(48+4096,"Opening repository.","Repository type canno't be recognized" & @CRLF ,0,0)
				EndSwitch
			EndFunc
			func _getproxyport()
				$proxy= _GetAppSettings("ProxyHttp","",1)
				$port= _GetAppSettings("ProxyPort","",1)
				$proxyport=""
				if $proxy<>"" and $port<>"" Then $proxyport=$proxy&":"&$port
				if $proxy="http://proxyserver" then $proxyport=""
				return $proxyport
			EndFunc
			func _CheckproxyportTXT()
				$TXT_proxy=_CtrlRead($TXT_settingspref_Proxy)
				$ste=_IsCheckedType($CK_settingspref_Proxy)
				$steIE=_IsCheckedType($CK_settingspref_ProxyIE)
				if $TXT_proxy <> "" Then
					if StringRegExp($TXT_proxy,'^[a-zA-z0-9-.]+[:]{1}([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$',0) Then
						GUICtrlSetBkColor($TXT_settingspref_Proxy, _color("white"))
						if $steIE=$GUI_CHECKED  then

						Else
							$TXT_proxyArr=StringSplit($TXT_proxy,":")
							_UpdateAppSettings("ProxyHttp",$TXT_proxyArr[1])
							_UpdateAppSettings("ProxyPort",$TXT_proxyArr[2])
						endif
					Else
						GUICtrlSetBkColor($TXT_settingspref_Proxy, _color("rose"))
					endif
				Else
					if $ste=$GUI_CHECKED then
						GUICtrlSetBkColor($TXT_settingspref_Proxy, _color("lightRed"))
						_UpdateAppSettings("ProxyHttp","http://proxyserver")
						_UpdateAppSettings("ProxyPort","8080")
					endif
					if $steIE=$GUI_CHECKED then
						GUICtrlSetBkColor($TXT_settingspref_Proxy, _color("white"))
					endif
				endif

			EndFunc
			func _getproxyportIE()
				$res=RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyServer")
				$proxyIEarr= StringSplit($res,":",2)
				_printfromarray($proxyIEarr)
				Local $proxy  = $proxyIEarr[0]
				Local $port  = $proxyIEarr[1]
				$proxyport=""
				if $proxy<>"" and $port<>"" Then $proxyport=$proxy&":"&$port
				return $proxyport
			EndFunc
		#endregion
		#region --------------------------------- Import export  Servers        -----------------------------------------------------
			Func FormExportImportServersClose()
				ConsoleWrite('++FormExportImportServersClose() = '& @crlf)
				GUIDelete($FormExportImportServers)
				_ReduceMemory()
				GUISetState(@SW_SHOW,$SettingsForm)
			EndFunc
			Func _selectImportServersFile()
				ConsoleWrite('++_selectImportServersFile() = '& @crlf)
				Local Const $sMessage = "Select csv file for Import to Project Database."
				Local $sFileOpenDialog =  FileOpenDialog ($sMessage, @WorkingDir & "\", "Csv File (*.csv)",1+2,"")
				If @error Then
					MsgBox(64+4096, "", "No file was selected.")
					GUICtrlSetData($TXT_ExportImportServers_fileExport,"")
				Else
					If Not FileExists($sFileOpenDialog) then
						MsgBox(48, "Error", "Unable to find file.")
						GUICtrlSetData($TXT_ExportImportServers_fileImport,"")
						Return
					endif
					GUICtrlSetData($TXT_ExportImportServers_fileimport,$sFileOpenDialog)
				EndIf
			EndFunc
			Func _selectExportServersFile()
				ConsoleWrite('++_selectExportServersFile() = '& @crlf)
				Local Const $sMessage = "Select Database for export to csv file."
				Local $sFileOpenDialog = FileOpenDialog ($sMessage, $FgmDataFolder, "FGM DB (*.db)",1+2,"")
				If @error Then
;~ 					MsgBox(64+4096, "", "No Database was selected.")
;~ 					GUICtrlSetData($TXT_ExportImportServers_fileExport,"")
				Else
					GUICtrlSetData($TXT_ExportImportServers_fileExport,$sFileOpenDialog)
					_ExportServerFile_fillListData()
				EndIf
			EndFunc
			Func _ImportServerFile_fillListData($importedDB)
				ConsoleWrite('++_ImportServerFile_fillListData() = '& @crlf)
				$query='Select servername,ip,servergroupname,description FROM tableTMP;'
				_SQLITEqry($query,$importedDB,$quietSQLQuery)
				If  IsArray($qryResult) then
					_FillTableSQL($LST_ExportImportServers_Importlist,$qryResult,3,0)
					GUICtrlSetData($LBL_ExportImportServers_List,"Servers import to db")
				Else
					_GUICtrlListView_DeleteAllItems($LST_ExportImportServers_Importlist)
					GUICtrlSetData($LBL_ExportImportServers_List,"")
				endif
			EndFunc
			Func _ExportServerFile_fillListData()
				ConsoleWrite('!++_ExportServerFile_fillListData() = '& @crlf)
				$filaDB=_ctrlread($TXT_ExportImportServers_fileExport)
				$query='Select servername,ip,servergroupname,description ' & _
						' FROM (SELECT Servers.serverid,Servers.servername,Servers.description,Servers.ip, ' & _
						' RServerGroup.ServerID AS ServerID1,RServerGroup.groupID,servergroups.groupid AS groupid1, ' & _
						' servergroups.servergroupname ' & _
						' FROM Servers ' & _
						' INNER JOIN RServerGroup ON Servers.serverid = RServerGroup.ServerID ' & _
						' INNER JOIN servergroups ON RServerGroup.groupID = servergroups.groupid)' & ';'
				_SQLITEqry($query,$filaDB,$quietSQLQuery)
				If  IsArray($qryResult) then
					_FillTableSQL($LST_ExportImportServers_Importlist,$qryResult,3,0)
					GUICtrlSetData($LBL_ExportImportServers_List,"Servers File content ")
				Else
					_GUICtrlListView_DeleteAllItems($LST_ExportImportServers_Importlist)
					GUICtrlSetData($LBL_ExportImportServers_List,"")
				endif
			EndFunc
			Func _selectExportServersFiledest()
				ConsoleWrite('++_selectExportServersFiledest() = '& @crlf)
				Local Const $sMessage = "Select destination Csv file."
				$filaDB=_ctrlread($TXT_ExportImportServers_fileExport)
				Local $sDrive, $sDir, $sFileName, $sExtension
				Local $filaDBPathSplit = _PathSplit($filaDB, $sDrive, $sDir, $sFileName, $sExtension)
				Local $MyDocsFolder = "::{450D8FBA-AD25-11D0-98A8-0800361B1103}"
				Local $MyDocsFolder = @MyDocumentsDir
				Local $sFileOpenDialog = FileSaveDialog($sMessage, $MyDocsFolder, "Csv file (*.csv)", 2+16,"ServerExport_"&$filaDBPathSplit[3]&"_"&StringReplace(_NowCalcDate(),"/","_")&".csv")
				$var=@error
				If $var Then
;~ 					MsgBox(64+4096, "", "No file was selected.")
					Return "0"
				Else
					$file = FileOpen($sFileOpenDialog,2)
					If $file = -1 Then
						MsgBox(48, "Error", "Unable to create file.")
						Return "0"
					EndIf
					FileClose($file)
					return $sFileOpenDialog
				EndIf
			EndFunc
			Func _selectExportServersTemplateFiledest()
				ConsoleWrite('++_selectExportServersTemplateFiledest() = '& @crlf)
				Local Const $sMessage = "Select destination template Csv file."
				Local $MyDocsFolder = "::{450D8FBA-AD25-11D0-98A8-0800361B1103}"
				Local $MyDocsFolder = @MyDocumentsDir
				Local $sFileOpenDialog = FileSaveDialog($sMessage, $MyDocsFolder, "Csv file (*.csv)", 2+16,$TemplateFilename)
				$var=@error
				If $var Then
;~ 					MsgBox(64+4096, "", "No file was selected.")
					Return "0"
				Else
					$file = FileOpen($sFileOpenDialog,2)
					If $file = -1 Then
						MsgBox(48, "Error", "Unable to create file.")
						Return "0"
					EndIf
					FileClose($file)
					return $sFileOpenDialog
				EndIf
			EndFunc
			Func _ExportServers($filedest )
				ConsoleWrite('!++_ExportServers() = '& @crlf)
				$filaDB=_ctrlread($TXT_ExportImportServers_fileExport)
				_SQLite_Close($filaDB)
				Local $fileCSV = FileOpen($filedest, 2)
				If $fileCSV = -1 Then
					MsgBox(48+4096, "Error Exporting Server List", "Unable to open file "&$filedest&" for export")
					Return 1
				EndIf
				FileWriteLine($fileCSV,"servername,ip,servergroupname,description")
				FileClose($fileCSV)
				$query='Select servername,ip,servergroupname,description' & _
						' FROM (SELECT Servers.serverid,Servers.servername,Servers.description,Servers.ip, ' & _
						' RServerGroup.ServerID AS ServerID1,RServerGroup.groupID,servergroups.groupid AS groupid1, ' & _
						' servergroups.servergroupname ' & _
						' FROM Servers ' & _
						' INNER JOIN RServerGroup ON Servers.serverid = RServerGroup.ServerID ' & _
						' INNER JOIN servergroups ON RServerGroup.groupID = servergroups.groupid)' & ';'
				_SQLITEqry($query,$filaDB,$quietSQLQuery)
				$var=_ArrayToFile($filedest,$qryResult,0,"",0)
				If $var=0 Then
					MsgBox(64+4096, "Exporting Server list", "The Export to file "&$filaDB&" was successful")
				endif
			EndFunc
			Func _ExportTemplate($filedest)
				ConsoleWrite('++_ExportTemplate() = '& $filedest & @crlf)
				$res=FileCopy($TemplateServersExportFilename,$filedest,1)
				If $res = 0 Then
					MsgBox(4096, "Error exporting template", " Error exporting template csv file ."& @crlf  & " Err.no 2022")
					Return false
				EndIf
				Run("C:\WINDOWS\EXPLORER.EXE /n,/e," & $filedest)
				return true
			EndFunc
			Func _ImportServers_FillList()
				ConsoleWrite('++_ImportServers_FillList() = '& @crlf)
				If Not _FileReadToArray(_ctrlread($TXT_ExportImportServers_fileimport),$importArr) Then
					MsgBox(4096, "Error", " Error reading csv file for import."& @crlf  & "  error:" & @error & @crlf  & " Err.no 2023")
					Return false
				else
					_GUICtrlListView_DeleteAllItems($LST_ExportImportServers_Importlist)
					GUICtrlSetData($LBL_ExportImportServers_List,"")
					if  $importArr[1]= "servername,ip,servergroupname,description" then
						$importedDB=@MyDocumentsDir &"\FGMimported.db"
						if _createTMPdb($importedDB) then
							; _________-  upload data to table fill ________________________
							For $x = 2 To $importArr[0]
								$lineaArr=StringSplit($importArr[$x],",")
								if $lineaArr[0]>4 then
									MsgBox(48+4096, "Importing CSV to DB", "The csv file must have 4 columns."& @crlf  & '"servername,ip,servergroupname,description"' & @crlf&" Err.no 2032")
									FileDelete($importedDB)
									return false
								endif
								Select
									case $lineaArr[0]=3  ; no description
										$descServerImport=""
									case $lineaArr[0]=4
										$descServerImport=$lineaArr[4]
								EndSelect
								$query='INSERT INTO tableTMP VALUES (null,"' & _
											$lineaArr[1] & '","' & _
											$lineaArr[2] & '","' & _
											$lineaArr[3] & '","' & _
											$descServerImport & '");'
								GUICtrlSetData($LBL_ExportImportServers_Load," Checking file " &  $x & "/" & $importArr[0] )
								if _SQLITErun($query,$importedDB,0,1) Then
								Else
									MsgBox(48+4096,"Importing error","A Check Importing error. Cannot insert de csv data to the db.  ErrNo 2035" & @CRLF & $query,0,0)
									FileDelete($importedDB)
									Return false
								EndIf
							Next
							_SQLite_Close($importedDB)
							_ImportServerFile_fillListData($importedDB)
						Else
							MsgBox(48+4096, "Importing CSV to DB", "The first line of the CSV file is not as expected. this csv cannot be impoted. Keep the exported file first line without changes. " & @crlf & '"servername,ip,servergroupname,description"' & @crlf & " Err.no 2038")
							FileDelete($importedDB)
							return false
						endif
					EndIf
					Return true
				endif
			EndFunc
			Func _ImportServers($prjName)
				ConsoleWrite('++_ImportServers() = '&$prjName& @crlf)
				If Not _FileReadToArray(_ctrlread($TXT_ExportImportServers_fileimport),$importArr) Then
					MsgBox(4096, "Error", " Error reading csv file for import."& @crlf  & "  error:" & @error & @crlf  & " Err.no 2003")
					Return false
				else
					_GUICtrlListView_DeleteAllItems($LST_ExportImportServers_Importlist)
					GUICtrlSetData($LBL_ExportImportServers_List,"")
					if  $importArr[1]= "servername,ip,servergroupname,description" then
						$importedDB=@MyDocumentsDir & "\FGM" &$prjName & '.db'
						if _createTMPdb($importedDB) then
							; _________-  upload data to table fill ________________________
							For $x = 2 To $importArr[0]
								$lineaArr=StringSplit($importArr[$x],",")
								if $lineaArr[0]>4 then
									MsgBox(48+4096, "Importing CSV to DB", "The csv file must have 4 columns."& @crlf  & '"servername,ip,servergroupname,description"' & @crlf&" Err.no 2002")
									FileDelete($importedDB)
									return false
								endif
								Select
									case $lineaArr[0]=3  ; no description
										$descServerImport=""
									case $lineaArr[0]=4
										$descServerImport=$lineaArr[4]
								EndSelect
								$query='INSERT INTO tableTMP VALUES (null,"' & _
											$lineaArr[1] & '","' & _
											$lineaArr[2] & '","' & _
											$lineaArr[3] & '","' & _
											$descServerImport & '");'
								GUICtrlSetData($LBL_ExportImportServers_Load," Importing " &  $x & "/" & $importArr[0] )
								if _SQLITErun($query,$importedDB,0,1) Then
								Else
									MsgBox(48+4096,"Importing error","An error Importing. Cannot insert de csv data to the db.  ErrNo 2005" & @CRLF & $query,0,0)
									FileDelete($importedDB)
									Return false
								EndIf
							Next
							_SQLite_Close($importedDB)
							_ImportServerFile_fillListData($importedDB)
							; _________   fill table servergroups   ________________________
							$query= 'INSERT INTO servergroups (groupid,servergroupname) ' & _
									'SELECT groupid,servergroupname ' & _
									'FROM (select ROWID as groupid,servergroupname FROM (select distinct(servergroupname) from tableTMP));'
							if _SQLITErun($query,$importedDB,0,1) Then
							Else
								MsgBox(48+4096,"Importing error","An error Importing. Cannot insert data to servergroups table.  ErrNo 2009" & @CRLF & $query,0,0)
								FileDelete($importedDB)
								Return false
							EndIf
							; _________      fill table servers   ________________________
							$query= 'INSERT INTO servers (serverid,servername,description,ip) ' & _
									'SELECT id,servername,description,ip ' & _
									'FROM (select id,servername,description,ip from tableTMP);'
							if _SQLITErun($query,$importedDB,0,1) Then
							Else
								MsgBox(48+4096,"Importing error","An error Importing. Cannot insert data to Servers table.  ErrNo 2010" & @CRLF & $query,0,0)
								FileDelete($importedDB)
								Return false
							EndIf
;~ 							INSERT INTO servers (serverid,servername,description,ip)
;~ 							SELECT last_insert_rowid() AS rowid,servername,description,ip
;~ 							FROM (select servername,description,ip from tableTMP)
							; _________       fill table RServerGroup   ________________________
							$query= 'INSERT INTO RServerGroup (serverid,groupid) ' & _
									'SELECT [Servers].[serverid],[servergroups].[groupid] FROM [tableTMP]' & _
									'INNER JOIN [servergroups] ON [tableTMP].[servergroupname] = [servergroups].[servergroupname] ' & _
									'INNER JOIN [Servers] ON [Servers].[servername] = [tableTMP].[servername] ;'
							if _SQLITErun($query,$importedDB,0,1) Then
							Else
								MsgBox(48+4096,"Importing error","An error Importing. Cannot insert data to RServerGroup table.  ErrNo 2011" & @CRLF & $query,0,0)
								FileDelete($importedDB)
								Return false
							EndIf
;~ 							INSERT INTO RServerGroup (serverid,groupid)
;~ 							SELECT [Servers].[serverid],[servergroups].[groupid]
;~ 							FROM [tableTMP]
;~ 							  INNER JOIN [servergroups] ON [tableTMP].[servergroupname] = [servergroups].[servergroupname]
;~ 							  INNER JOIN [Servers] ON [Servers].[servername] = [tableTMP].[servername]
							; _________     register row with Config value key -  FGMdatabase Testeo FGMtesteo.db  ________________________
							$query= 'INSERT INTO configuration VALUES ("FGMdatabase","' & StringUpper($prjName) & '","FGM' & StringLower($prjName) & '.db");'
							if _SQLITErun($query,$importedDB,0,1) Then
							Else
								MsgBox(48+4096,"Importing error","An error Importing. Cannot insert data to configuration table.  ErrNo 2024" & @CRLF & $query,0,0)
								FileDelete($importedDB)
								Return false
							EndIf
							; _________    End csv to db import          ________________________
							MsgBox(64+4096, "Importing CSV to DB", "The CSV was imported to "& $importedDB & "    Successfully !!" & @crlf & "You can proceed to add it to the compilation stack.")
							return true
						Else
							MsgBox(48+4096, "Importing CSV to DB", "can´t create the base database at "& $importedDB & " Err.no 2000")
							FileDelete($importedDB)
							return false
						endif
					Else
						MsgBox(48+4096, "Importing CSV to DB", "The first line of the CSV file is not as expected. this csv cannot be impoted. Keep the exported file first line without changes. " & @crlf & '"servername,ip,servergroupname,description"' & @crlf & " Err.no 2008")
						FileDelete($importedDB)
						return false
					endif
				EndIf
				Return true
			EndFunc
			Func _createTMPdb($importedDB)
				ConsoleWrite('++_createTMPdb() = '& @crlf)
				$var = FileCopy($tempDir & "\FGM.db",$importedDB,1)
				if $var=1 then
					$query= 'VACUUM;CREATE TABLE [tableTMP] ( ' & _
							'  [id] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ' & _
							'  [servername] VARCHAR(100) NOT NULL COLLATE NOCASE, ' & _
							'  [ip] varchar(18),' & _
							'  [servergroupname] VARCHAR(100) COLLATE NOCASE,' & _
							'  [description] VARCHAR(250) COLLATE NOCASE' & _
							'  );'
					if _SQLITErun($query,$importedDB) Then
					Else
						MsgBox(48+4096,"Importing error","An error Importing. Table creation cannot be performed.  ErrNo 2004" & @CRLF & $query,0,0)
						Return false
					EndIf
				Else
					MsgBox(48+4096,"Importing error","An error Importing.The DBfile cannot be created.  ErrNo 2007" & @CRLF & $query,0,0)
					Return false
				endif
				Return $var
			EndFunc
		#endregion
	#endregion