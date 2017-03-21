#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=images\TransferDEV.ico
#AutoIt3Wrapper_Outfile=.\release\FileGodMode.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=Development version - File Deployer - Management & Automation
#AutoIt3Wrapper_Res_Description=Development version - File Deployer - Management & Automation
#AutoIt3Wrapper_Res_Fileversion=0.4.4.807
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductVersion=0.4.4
#AutoIt3Wrapper_Res_LegalCopyright=Marcelo N. Saied & Roberto P Iralour . All rights reserved
#AutoIt3Wrapper_Res_Field=Productname|FileGodMode
#AutoIt3Wrapper_Res_Field=ProductVersion|Version 0.4.4
#AutoIt3Wrapper_Res_Field=Manufacturer |Marcelo N. Saied & Roberto P Iralour . All rights reserved
#AutoIt3Wrapper_Res_Field=Compile date|%longdate% %time%
#AutoIt3Wrapper_Run_Before=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\CopySecretsBefore.cmd
#AutoIt3Wrapper_Run_Before=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\updaterCompilerDEV.cmd
#AutoIt3Wrapper_Run_Before=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\versioncheckerCompiler.cmd
#AutoIt3Wrapper_Run_Before=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\FGMminionCompiler.cmd
#AutoIt3Wrapper_Run_Before=start c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\FGMagentCompilerDev.cmd
#AutoIt3Wrapper_Run_After=start c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\deployDEV.cmd  %fileversion%
#AutoIt3Wrapper_Run_After=start c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\deployDEVfilegodmode.azurewebsites.net.cmd  %fileversion%
#AutoIt3Wrapper_Run_After=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\CopySecretsAfter.cmd
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/mergeonly
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; *** Start added by AutoIt3Wrapper ***
#include <WindowsConstants.au3>
; *** End added by AutoIt3Wrapper ***
;~ #Obfuscator_Parameters=/cs=1 /cn=1 /cf=1 /cv=1 /sf=1 /sv=1
;~ #Obfuscator_Parameters=/cs=1 /cn=1 /cf=1 /cv=1 /sf=1
$dev=1
#include <Misc.au3>
If _Singleton(@ScriptName, 1) = 0 Then ; allow only one instance
	MsgBox(0, "Warning", "An occurence of " & @ScriptName & " is already running")
	Exit
EndIf

#region LoadInit
		ConsoleWrite('!!++_LoadInit() = '& @ComputerName &@crlf)
		$LoadTimerBegin = TimerInit()
		#include <forms\_progressGUI.au3>
		Global $splashH = _ProgressGUI("     FileGodMode" & @CRLF & "          " & _
		FileGetVersion(@ScriptName),0,16,"","","","0x2C3539","0x0FFFC19")
		Sleep(1000)
		#include <Includes\includes.au3>
		#include <controls\updateDEV.au3>
		_Licence()

		Opt("GUIOnEventMode", 1)
		AutoItSetOption("WinTitleMatchMode", 4)
		GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
		GUIRegisterMsg($WM_SYSCOMMAND, "WM_SYSCOMMAND")
		GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

		_ConfigDBInitial()
		Sleep(2000)
		#include <forms/FormMain.au3>
;~ 		_checkVersion()
		_ReduceMemory()
		GUIDelete($splashH[0])
		_MainFormBTNdisable(1)
		_SetDesktopShortcut()
#endregion
#region auto form open UNITTESTING
;~ 	ShowSettingsForm(3)
;~ 	ShowJobCreationForm()

;~ 	$task="Execution Task"
;~ 	$task="Copy Task"
;~ 	GUICtrlSetData($TXT_JobCreation_jobname,  "minion test 1")
;~ 	ControlCommand ($JobCreationForm, "", $CMB_jobcreation_selecttask, "SelectString", $task)
;~ 	$taskid="4102452825"
;~ 	$jobid="40115207"
;~ 	BTN_jobcreation_addtaskClick()

;~ 		GUICtrlSetData($TXT_JobCreation_jobname,  "job execute")
	;~GUICtrlSetState($CMB_jobcreation_selecttask, $GUI_ENABLE)

#endregion
$LabelsTimerBegin = TimerInit()
$useInetcheckMethod=_CheckInetcheckMethod()
$intervalcheckInet=5000
$checkeocounter=0
While 1
	;LBLtimer
	if $FlagLBLhide=1 Then
		if TimerDiff($LBLTimerBegin)>60000 then
			;labels to hide
			GUICtrlSetstate($LBL_CheckRepo,$GUI_hide)
			$FlagLBL=0
		endif
	endif

	if $checkeocounter<1 and @Compiled then
		if TimerDiff($LabelsTimerBegin)>$intervalcheckInet then
			$intervalcheckInet =60000
			$checkeocounter+=1
			$LabelsTimerBegin = TimerInit()
			if _CheckInetConnection() then
				ConsoleWrite("_CheckInetConnection() show" & @crlf )
				GUICtrlSetstate($LBL_noInet,$GUI_show)
			Else
				ConsoleWrite("_CheckInetConnection() hide" & @crlf )
				GUICtrlSetstate($LBL_noInet,$GUI_HIDE)
			endif
		endif
	Else
		$checkeocounter+=1
		if $intervalcheckInet>60000*20 then $checkeocounter=0
	endif
	Sleep(80)
WEnd
Exit

