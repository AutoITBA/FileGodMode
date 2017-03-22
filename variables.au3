#REGION GENERAL
	Global $version= FileGetVersion(@ScriptName)
	Global $LoginFlag = True
	Global $ImportExportVersion="1.0"            ; version para aceptar importar un  exportfile
	Global $Admin=0
#endregion
#region
	Global $LogFileDebug="FileGodModeDebug.log"
	Global $hLogFile=""
	Global $tempdir=_GetTempDir()
	ConsoleWrite('$tempDir = ' & $tempDir & @crlf )
	Global $sWorkingDir=@WorkingDir
	Global $FgmDataFolder=@UserProfileDir & "\AppData\Roaming\FGM"
	Global $FgmDataFolderImages=$FgmDataFolder & "\Images"
	Global $FgmDataFolderResources=$FgmDataFolder & "\Resources"
	Global $INIfile= $FgmDataFolder & "\FGM.ini"
	Global $MinionExecutablePath=$FgmDataFolder & "\FGMminion.exe"
#endregion
#region f# forms positions
	Global $factorx=50
	Global $posxis=0
#endregion
#region f# Hashing
	Global $HashingPassword = ""
	#include <secrets/HashingPassword.secret>
#endregion
#region f# DB
	global $useInetcheckMethod=0
	;$RepoProjectDBDefault="http://acnalert.cloudapp.net/FGM/ProjectRepo"
	$RepoProjectDBDefault="https://filegodmode.azurewebsites.net/FGM/ProjectRepo"
;~ 	$RepoProjectDBDefault="https://filegodmode.azurewebsites.net"
	$DataBaseSchemaAplication=7         ; verion de aplicaciom para machear con version de configuration table
	$DataBaseSchemaProfile=0
	$sSQliteDll=""
	ConsoleWrite('!@UserName = ' & @UserName & @crlf )
	$quietSQLQuery=false
	$vervoseSQLQuery=true
	Func _DBvarInit()
		ConsoleWrite('++_DBvarInit() = '& @crlf)
		Global $profiledbfile="profile.db"  ; re setted at ConfigInitial()
		Global $FGMdbFile=""  ; re setted at ConfigInitial()
		Global $Basedbfile="FGMbase.db"
		If Not @Compiled Then
			#include <secrets/devadmin.secret>
		endif
		Global $EncryptDB=true
		if $EncryptDB  then
			#include <secrets/dbEncriptionPass.secret>
		Else
			Global $FGMencript=""
			Global $profiledbencript=""
			Global $basedbencript=""
			Global $defaultdbencript=""
		endif
		global $qryResult
	EndFunc
	_DBvarInit()
#endregion
#region f# Answers
	global $answerOK=1
	global $answerCANCEL=2
	global $answerABORT=3
	global $answerRETRY=4
	global $answerIGNORE=5
	global $answerYES=6
	global $answerNO=7
#endregion
#region FGMagent Connection
	Global $debugflag=1
	#region encryption
		#include <secrets/ConnectorPassCode.secret>
	#endregion
	#region f- TCP Variables
	;~ 	Dim $sMaxConnections = 10
	;~ 	Dim $sSocket[$sMaxConnections], $sBuffer[$sMaxConnections], $iAuth[$sMaxConnections]
		Global $sMainSocket =""
		;; TCP Options
		Global $nPort = 23
		Global $listenerIP=""
		Global $ListenerActive=1
		Global $ConnectedSocket=-1
	#endregion
	#region f# Service main
		Global $ServiceIdletimeout=30000
		Global $ServiceIdleTimerInit=0
	#endregion
	#region f# Command execution
		Global $pathFolderCommand=""
		Global $PathFileBatCommand=""
	#endregion
#endregion
#region Forms
	Global $formHandle=""
	Global $WM_Notify_Silent=0
	Global $LBLTimerBegin = ""
	Global $FlagLBLhide=0
	Global $LoopTimer=TimerInit()
	#region form Progress Main
		; variables set on the ProgressGUI form itself, since it loads first
	#endregion
	#region f# form main
		Global $MainfORM=""
		Global $mainformname=" FileGodMode V"
		Global Enum $idNew = 1000, $idOpen, $idSave, $idExit, $idCut, $idCopy, $idPaste, $idAbout,$idHelp,$idUpdate,$idCheckVersion,$idprj,$hUpdates
		Global Enum $idSettings = 3000, $idSettingsCredentials,$idSettingsServers,$idSettingsCustom,$idSettingApplications,$idSettingsDB
		Global $B_Close=""
		Global $LBL_CheckUpdate=""
		Global $btn_CreateJob=""
		Global $btn_config=""
		Global $CMB_DatabaseSelect=""
		Global $LBL_setdb=""
		Global $B_setDB=""
		Global $LBL_CheckRepo=""
		;menu
		Global $hFile=""
		Global $hUpdt=""
		Global $hHelp=""
		Global $hOption=""
		Global $LBL_noInet=""
		Global $LBL_noRepo=""
	#endregion
	#region f# sort lists
		Global $nCurCol = -1
		Global $nSortDir = 1
		Global $bSet = 0
		Global $nCol = -1
	#endregion
	#region f# Update
;~ 		$WebServiceaddr="acnalert.cloudapp.net/FGM"
		$WebServiceaddr="filegodmode.azurewebsites.net/FGM/"
	#endregion
	Func _SettingsVarInit()
		ConsoleWrite('++_SettingsVarInit() = '& @crlf)
		#region form settings
			global $PageControl1=""
			global $task=""
			global $flagUpdateSettings=1
			#region credentials
				global $SettingsForm=""
				global $TXT_creddomain=""
				global $TXT_credpassword=""
				global $TXT_creduser=""
				global $creddomainvalue=""
				global $creduservalue=""
				global $credpasswrdvalue=""
				global $LST_CredManage=""
				global $flagCredShow=0
				global $BTN_credshowpass=""
			#endregion
			#region custom groups
				global $LST_custsrvgrp=""
				global $LST_custshare=""
				global $CMB_custselectgroup=""
				global $BTN_custaddcreategrp=""
				global $CMB_custselectserver=""
				global $flagCustomlistclick=1
				global $BTN_custdeletegroup=""
				global $BTN_custlistdeletesrv=""
			#endregion
			#region custom shares
				global $TXT_custsharepath=""
				global $TXT_custsharename=""
				global $BTN_custaddshare=""
				global $BTN_custdeleteshare=""
			#endregion
			#region import export jobs
				global $FormJobImport=""
				global $TXT_importExport_fileExport=""
				global $TXT_importExtort_fileImport=""
				global $LST_importExport_ExportJoblist=""
				global $TXT_importExtort_fileImport=""
				global $importArr=""
				global $LST_importExport_ImportJoblist=""
				global $LBL_importExport_Load=""
				global $BTN_importExport_Import=""
				global $BTN_importExport_Export=""
				Global $BTN_importExport_fileImport=""
			#endregion
			#region Servers add
				global $hTab_PageControl1_servers=""
				global $IPAddress1=""
				global $LST_settings_servers=""
				global $Tab_servers=""
				global $TXT_settings_FQDN=""
				global $LST_settings_serversAdd=""
				global $BTN_Settings_ServerRemove=""
				global $IPAddress1=""
				global $LBL_Settings_DNSregistration=""
				Global $flagfqdn=1
				Global $CMB_selectServerIP=""
				Global $LBL_selectServerIP=""
				Global $BTN_Settings_KeepCustomServers=""
				Global $BTN_ResetServers2TemplateOK=""
				Global $BTN_ResetServers2TemplateClose=""
				Global $LBL_settingspref_repo_default=""
				Global $FGMshare=""
			#endregion
			#region Application settings
				Global $CK_settingspref_Recurse=""
				Global $CK_settingspref_CleanConsoleEveryLines=""
				Global $CK_settingspref_verbose=""
				Global $CMB_settingspref_copybehaviour=""
				Global $CMB_settingspref_CleanConsoleEveryLinesvalue=""
				Global $CK_settingspref_logactivity=""
				Global $CK_settingspref_showprogress=""
				Global $TXT_settingspref_ExecutableFileFolderDefault=""
				Global $BTN_settingspref_ExecutableFileFolder_BrowseFile=""
				Global $BTN_settingspref_repo_BrowseFile=""
				Global $TXT_settingspref_Repo=""
				Global $BTN_settingspref_repo_open=""
				Global $BTN_settingspref_repo_default=""
				Global $CK_settingspref_CreateDesktopShortcut=""
				Global $TXT_settingspref_ActivityLogFolder=""
				Global $BTN_settingspref_ActivityLogFolder=""
				Global $ActivityLogFolder=@ScriptDir
				Global $LogFileActivity="FileGodModeActivity.log"
				Global $BTN_settingspref_ActivityLogFolder_default=""
				Global $CK_settingspref_StopOnWarnings=""
				Global $CK_settingspref_ProxyIE=""
				Global $CK_settingspref_Proxy=""
				Global $TXT_settingspref_Proxy=""
				Global $CMB_Proxy_Cred=""
				Global $TXT_settingspref_ExecutableWorkingFolder=""
				Global $CK_settingspref_TypeUpdate=""
			#endregion
			#region import export servers
				global $FormExportImportServers=""
				global $TXT_ExportImportServers_fileExport=""
				global $TXT_ExportImportServers_fileImport=""
				global $BTN_ExportImportServers_Export=""
				global $BTN_ExportImportServers_Import=""
				global $BTN_ExportImportServers_fileImport=""
				global $BTN_ExportImportServers_fileExport=""
				global $LBL_ExportImportServers_Load=""
				global $LST_ExportImportServers_Importlist=""
				global $LBL_ExportImportServers_List=""
				global $TemplateFilename="ProjectServersForImport.csv"
				global $TemplateServersExportFilename=$FgmDataFolderResources & "\" & $TemplateFilename
			#endregion
			#region reset servers to template
				global $LST_MSGBoxScroll=""
				global $ResetServers2TemplateForm=""
				global $LBL_ResetServers2Template=""
				global $LBL_ResetServers2TemplateProgress=""
			#endregion
		#endregion
	EndFunc
	Func _JobsVarsInit()
		ConsoleWrite('++_JobsVarsInit() = '& @crlf)
		#region gral
			Global $contextmenu_list=""
		#endregion
		#region Console Describe
			Global $ConsoleDescribeForm=""
			Global $BTN_exitClick=""
			Global $Edt_ConsoleDescribe=""
			Global $FGMtaskReport=$tempdir&"\FGMtaskReport.csv"
			Global $BTN_ConsoleDescribe_OpenCSV=""
			Global $showDesc=false
			Global $run_taskid=0
		#endregion
		#region job creation form
			Global $GUI_JobCreation=0
			Global $TaskFolderCreation=""
			Global $JobID=""
			Global $LST_JobCreation_JobList=""
			Global $BTN_JobCreation_deletejob=""
			Global $BTN_JobCreation_runjob=""
			Global $TXT_JobCreation_jobdescription=""
			Global $LST_jobcreation_tasklist=""
			Global $BTN_createjob_deletetask=""
			Global $BTN_createjob_Edittask=""
			Global $BTN_createjob_taskUp=""
			Global $BTN_createjob_taskDown=""
			Global $BTN_JobCreation_updatejob=""
			Global $BTN_createjob_DuplicateTask=""
			Global $BTN_createjob_DescribeTask=""
			Global $taskNumber=""
			Global $TaskID=0
			Global $taskorder=""
			Global $JobCreationForm=""
			Global $LBL_jobcreation_tasklist=""
			Global $TXT_JobCreation_jobname=""
			Global $BTN_jobcreation_addtask=""
			Global $BTN_JobCreation_duplicatejob=""
			Global $GUI_inputbox2=""
			Global $field1_inputbox2=""
			Global $field2_inputbox2=""
			Global $flagInputbox2=0
			Global $btn_inputbox2=""
			Global $CK_JobCreation_Showjob=""
			Global $BTN_JobCreation_Archivejob=""
			Global $LBL_RUNalert=""
			Global $CMB_jobcreation_selecttask=""
			Global $listUpdateFlag_tasklist=False
			Global $listUpdateFlag=False
			Global $listUpdateFlagFill=False
			Global $listLoop=0
		#endregion
		#region run tasks
			Global $CSVreport=0
			Global $TaskName=""
			Global $taskdesc=""
			Global $taskType=""
			Global $taskActive=""
			Global $taskEnabled=""
		#endregion
		#region Job Console
			Global $JobConsoleForm=""
			Global $Edt_JobConsole=""
			Global $BTN_JobCreation_Showjob=""
			Global $Edt_JobConsole=""
			Global $targetLoc=""
			Global $targetPath=""
			Global $iMemo=""
			Global $EditRichTxtBottom=""
			Global $EditRichTxtLeft=""
			Global $EditRichTxtTop=""
			Global $CK_JobConsole_RunOneByOne=""
			Global $CK_JobConsole_progress=""
			Global $HotKeyPause=0
			Global $hotKeyKill=0
			Global $STS_JobConsole_StatusBar=""
			Global $CK_JobConsole_Log=""
			Global $CK_JobConsole_Verbose=""
			Global $progressConsole=""
			Global $hprogressConsole=""
			Global $CK_JobConsole_Clearconsole=""
			Global $ClearConsoleEveryLines=0
			Global $CK_JobConsole_ClearconsoleEveryLines=""
			Global $RunFail=0
			Global $SkipobtainAtributesFlag=1
			Global $CK_JobConsole_ConsoleQuiet=""
			Global $CK_settingspref_quiet=""
			Global $hFGMtaskReport=""
			Global $ZipReportFileName=$tempdir&"\tempLogFileActivity.log"
		#endregion
	EndFunc
	Func _TaskFormsInit()
		ConsoleWrite('++_TaskFormsInit() = '& @crlf)
		Global $userT=""
		Global $passT=""
		Global $userP=""
		Global $passP=""
		Global $newtask=0
		Global $LBL_SourceLoc=""
		Global $LBL_TargetLoc=""
		#region Copy Task
			Global $RD_CopyTask_Move=""
			Global $RD_CopyTask_Mirror=""
			Global $CMB_CopyTask_Behaviour=""
			Global $CK_CopyTask_RStructure=""
			Global $CK_CopyTask_FolderPerSource=""
			Global $CK_CopyTask_EmptyFolders=""
			Global $RD_CopyTask_Copy=""
			Global $TasKCopyCreation=""
			Global $TasKCopyCounter=0
		#endregion
		#region task creation folder
			; ---  loc ----

			Global $CMB_TaskFolderCreation_SelType=""
			Global $CMD_TaskFolderCreation_SelServerShare=""

			Global $BTN_TaskFolderCreation_AddToSourceLoc=""
			Global $BTN_TaskFolderCreation_AddToTargetLoc=""
			Global $BTN_TaskFolderCreation_DeleteTargetLoc=""
			Global $BTN_TaskFolderCreation_DeleteSourceLoc=""

			Global $LST_TaskFolderCreation_TargetLoc=""
			Global $LST_TaskFolderCreation_SourceLoc=""

			; ---  path
			Global $TXT_TaskFolderCreation_SourcePath=""
			Global $TXT_TaskFolderCreation_TargetPath=""

			Global $BTN_TaskFolderCreation_AddSourcePath=""
			Global $BTN_TaskFolderCreation_AddTargetPath=""
			Global $BTN_TaskFolderCreation_DeleteSourcePath=""
			Global $BTN_TaskFolderCreation_DeleteTargetPath=""

			Global $LST_TaskFolderCreation_SourcePaths=""
			Global $LST_TaskFolderCreation_TargetPaths=""

			;gral
			Global $BTN_FolderCreation_close=""
			Global $BTN_FolderCreation_save=""
			Global $TXT_FolderCreation_taskdesc=""
			Global $edit=0
			Global $CMB_TaskFolderCreation_TargetCred=""
			Global $CMB_TaskFolderCreation_SourceCred=""
			Global $TXT_TaskFolderCreation_TargetPathFilter=""
			Global $CK_TaskFolderCreation_Powershell=""
			Global $taskFormActivity=0
			Global $TXT_TaskFolderCreation_olderThan=""
			Global $DT_olderThan=""

		#endregion
		#region Task ZIP
			Global $RD_TaskFolderCreation_ZIPOverwrite = ""
			Global $RD_TaskFolderCreation_ZIPAutorename=""
			Global $RD_TaskFolderCreation_ZIPsingle=""
			Global $CK_TaskFolderCreation_DeleteZip=""
			Global $RD_TaskFolderCreation_ZIPmultiple=""
			Global $RD_TaskFolderCreation_ZIPstructure=""
			Global $TXT_TaskFolderCreation_TargetZIPfilename=""
			Global $TXT_TaskFolderCreation_TargetZIPfilenameTEMP=""
			Global $TXT_TaskFolderCreation_SourceZIPFilter=""
			Global $CK_TaskFolderCreation_AutoRenameZip=""
			Global $CK_TaskFolderCreation_ServerFolderZip=""
			Global $CK_TaskFolderCreation_ServerFolderInsideZip=""
			Global $rAutoRenameZip=0
			Global $rDeleteZip=0
			Global $rServerFolderZip=0
			Global $rServerFolderZipInside=0
		#endregion
		#region Task delete folder
			Global $rStructure=0
			Global $rrecursivo=1
			Global $rfoldersandfiles=0
			Global $ronlyfiles=1
			Global $ronlyfolders=2
			Global $rsorted=2
			Global $rfullpath=2
			Global $errNo=0
			Global $errNo1=0
			Global $errNoExt=0
			Global $errNo1Ext=0
			Global $CK_TaskFolderCreation_Recurse=0
			Global $anchoLBL=""
		#endregion
		#region Task Deploy Agent
			Global $BTN_TaskDeployAgent_save=""
			Global $TaskDeployAgentForm=""
			Global $CMD_TaskDeployAgent_SelServerShare=""
			Global $CMB_TaskDeployAgent_SelType=""
			Global $BTN_TaskDeployAgent_AddToTargetLoc=""
			Global $LST_TaskDeployAgent_TargetLoc=""
			Global $TXT_TaskDeployAgent_taskdesc=""
			Global $CMB_TaskDeployAgent_TargetCred=""
			Global $BTN_TaskDeployAgent_DeleteTargetLoc=""
			Global $RD_TaskDeployAgent_Install=""
			Global $RD_TaskDeployAgent_Uninstall=""
			Global $Deployagent=""
		#endregion
		#region Task Execution
			Global $TXT_TaskExecution_TargetPath=""
			Global $LST_TaskExecution_TargetLoc=""
			Global $BTN_TaskExecution_AddToTargetLoc=""
			Global $BTN_TaskExecution_DeleteTargetLoc=""
			Global $TaskExecutionForm=""
			Global $TXT_Execution_taskdesc=""
			Global $CMD_TaskExecution_SelServerShare=""
			Global $CMB_TaskExecution_SelType=""
			Global $CMD_Execution_SelServerShare=""
			Global $BTN_TaskExecution_save=""
			Global $executeFileFolderDefault=""
			Global $TXT_TaskExecution_Executable=""
			Global $TXT_TaskExecution_ExtraFIle=""
			Global $BTN_TaskExecution_BrowseFile=""
			Global $CMB_TaskExecution_TargetCred=""
			Global $BTN_TaskExecution_close=""
			Global $TXT_TaskExecution_taskdesc=""
			Global $BTN_settingspref_repo_SaveClick=""
			Global $EDT_TaskExecution_commands=""
			Global $LST_TaskExecution_extraFiles=""
			Global $BTN_TaskExecution_addFile=""
			Global $CMB_TaskExecution_mode=""
			Global $LBL_TaskExecution_commands=""
			Global $LBL_TaskExecution_scriptfile=""
			Global $TXT_TaskExecution_scriptfile=""
			Global $BTN_TaskExecution_scriptfile_addFile=""
			Global $BTN_TaskExecution_scriptfile_BrowseFile=""
			Global $CK_TaskForms_UpdateTypesTRG=""
			Global $CK_TaskForms_UpdateTypesSRC=""
		#endregion
	EndFunc
	Func _AboutVarsInit()
		ConsoleWrite('++_AboutVarsInit() = '& @crlf)
		#region About form
			Global $Gui_FormAbout=0
			Global $hWaterDll
			Global $iXwb
			Global $iYwb
			Global $FormAbout
			Global $iMsg
			Global $sBmpFilePath
			Global $sFlippedBMP
			Global $iBMPWidth
			Global $iBMPHeight
			Global $iTimer1 = 3000
			Global $iTimer2 = 10000
	;~ 		Global $errWater
			Global $creditos=""
		#endregion
	EndFunc
	#region f rotationRing
		$GuiRing=""
		$guiAlOn =""
	#endregion
#endregion
#region ------------- load initvar --------------------
	_SettingsVarInit()
	_JobsVarsInit()
	_TaskFormsInit()
	_AboutVarsInit()
#endregion

