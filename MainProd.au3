#NoTrayIcon
$dev=0
#include <Misc.au3>
If _Singleton(@ScriptName, 1) = 0 Then ; allow only one instance
	MsgBox(0, "Warning", "An occurence of " & @ScriptName & " is already running")
	Exit
EndIf

#region LoadInit
		ConsoleWrite('++_LoadInit() = '& @crlf)
		$LoadTimerBegin = TimerInit()
		#include <forms\_progressGUI.au3>
		Global $splashH = _ProgressGUI("     FileGodMode" & @CRLF & "          " & _
		FileGetVersion(@ScriptName),0,16,"","","","0x2C3539","0x0FFFC19")
		Sleep(1000)
		#include <Includes\includes.au3>
		#include <controls\update.au3>
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
;~ 	ShowSettingsForm()
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




