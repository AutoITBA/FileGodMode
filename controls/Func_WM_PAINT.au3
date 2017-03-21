Func WM_PAINT($hWnd, $Msg)
	_GUICtrlStatusBar_EmbedControl($STS_JobConsole_StatusBar, 2,$hprogressConsole,1+4)
    Return 'GUI_RUNDEFMSG'
EndFunc   ;==>WM_PAINT