Func WM_SIZE($hWnd, $Msg, $wParam, $lParam)
;~ 	ConsoleWrite("++WM_SIZE()"& @CRLf)
    $iGUIWidth = BitAND($lParam, 0xFFFF)
    $iGUIHeight = BitShift($lParam, 16)
	Switch $hWnd
		Case $JobConsoleForm
			$formWidth=800
			$formHigh=140
			If $iGUIHeight<$formHigh Then $iGUIHeight=$formHigh-5
			If $iGUIWidth<$formWidth Then $iGUIWidth=$formWidth
			ControlMove("[ACTIVE]","",$Edt_JobConsole, default, default, _
						$iGUIWidth-($EditRichTxtLeft*2)-$EditRichTxtLeft, $iGUIHeight-$EditRichTxtTop-$EditRichTxtBottom-25)
			_FormMinSize($JobConsoleForm,$formWidth, $formHigh)
			_resizeStatusBarParts()
;~ 			ControlMove("[ACTIVE]","",$Edt_JobConsole, default, default, _
;~ 						$iGUIWidth-($EditRichTxtLeft*2)-$EditRichTxtLeft, $iGUIHeight-$EditRichTxtTop-$EditRichTxtBottom-25)
;~ 			_FormMinSize($JobConsoleForm,$formWidth, $formHigh)
			_GUICtrlStatusBar_Resize($STS_JobConsole_StatusBar)
		Case $ConsoleDescribeForm
			$formWidth=800
			$formHigh=140
			If $iGUIHeight<$formHigh Then $iGUIHeight=$formHigh
			If $iGUIWidth<$formWidth Then $iGUIWidth=$formWidth
			ControlMove("[ACTIVE]","",$Edt_JobConsole, default, default, _
						$iGUIWidth-($EditRichTxtLeft*2)-$EditRichTxtLeft, $iGUIHeight-$EditRichTxtTop-$EditRichTxtBottom-5)
			_FormMinSize($ConsoleDescribeForm,$formWidth, $formHigh)
	EndSwitch
; Set flag
    $fResized = True
    Return $GUI_RUNDEFMSG
EndFunc  ;==>MY_WM_SIZE
Func _resizeStatusBarParts($formTitle="[ACTIVE]")
;~ 	ConsoleWrite('++_resizeStatusBarParts() = '& @crlf)
	Local $aClientSize = WinGetClientSize($formTitle)
	If IsArray($aClientSize) Then
		$part0=90
		$part3=90
		$midlepart=$aClientSize[0]-$part0-$part3
		Local $aParts[3] = [$part0, $midlepart, -1]
;~ 		$part3_width=_GUICtrlStatusBar_GetWidth($STS_JobConsole_StatusBar,2)
		_GUICtrlStatusBar_SetParts($STS_JobConsole_StatusBar, $aParts)
		Local $hIcons0 = _WinAPI_LoadShell32Icon(23)
		_GUICtrlStatusBar_SetIcon($STS_JobConsole_StatusBar, 0, $hIcons0)
	endif
EndFunc



