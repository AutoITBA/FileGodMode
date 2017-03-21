#region mesagebox
	Func GUI_ConfirmResetServers2TemplateForm($titulo,$optionReset)
		ConsoleWrite('++BTN_Settings_KeepCustomServers() = '& $optionReset &@crlf)
		;$optionReset="ResetServers2template"
		;$optionReset="KeepOnlyCustom"
		Local $__WsExStyle = 0
		Local $__style = BitOR($WS_BORDER,$LVS_SHOWSELALWAYS,$LVS_SINGLESEL);$LVS_SINGLESEL  $LVS_REPORT
		$ResetServers2TemplateForm = _GUICreate_NoIcon($titulo)

		$LBL_ResetServers2Template = GUICtrlCreateLabel("", 10, 5, 200, 25)

		$LST_MSGBoxScroll = GUICtrlCreateListView("Server FQDN|IP|Group Membership|Description", 7, 25, 385, 345,$__style,$__WsExStyle)
		Local $__CtrlExStyle = BitOR($LVS_EX_GRIDLINES,$LVS_EX_FULLROWSELECT,$LVS_EX_ONECLICKACTIVATE)
		GUICtrlSendMsg(-1,$LVM_SETEXTENDEDLISTVIEWSTYLE,$__CtrlExStyle,$__CtrlExStyle)

		$BTN_ResetServers2TemplateOK = GUICtrlCreateButton("Delete All", 220, 375, 110, 20)
		SetOnEventA(-1, "BTN_ResetServers2Template_OKClick",$paramByVal,$optionReset)
		$BTN_ResetServers2TemplateClose = GUICtrlCreateButton("Cancel", 340, 375, 50, 20)
		GUICtrlSetOnEvent(-1, "BTN_ResetServers2Template_CloseClick")

		$LBL_ResetServers2TemplateProgress = GUICtrlCreateLabel(" Updating servers from template", 5, 375, 205, 19)
			GUICtrlSetBkColor(-1,_color("RED"))
			$font = "Comic Sans MS"
			GUICtrlSetFont(-1, 9, 700, 0, $font)
			GUICtrlSetstate($LBL_ResetServers2TemplateProgress,$GUI_hide)



		$res=0
		if $optionReset="ResetServers2template" then _FillListResetServers2template()
		if $optionReset="KeepOnlyCustom" then _FillListKeepOnlyCustom()

		GUISetState(@SW_SHOW, $ResetServers2TemplateForm)
	EndFunc   ;==>_MSGBoxScroll
; _WinAPI_GetClassLongEx(), _WinAPI_SetClassLongEx()
	#region constants
		Global Const $GCL_CBCLSEXTRA = -20
		Global Const $GCL_CBWNDEXTRA = -18
		Global Const $GCL_HBRBACKGROUND = -10
		Global Const $GCL_HCURSOR = -12
		Global Const $GCL_HICON = -14
		Global Const $GCL_HICONSM = -34
		Global Const $GCL_HMODULE = -16
		Global Const $GCL_MENUNAME = -8
		Global Const $GCL_STYLE = -26
		Global Const $GCL_WNDPROC = -24
	#endregion
	Func _WinAPI_GetClassLongEx($hWnd, $iIndex)
		Local $aRet
		If @AutoItX64 Then
			$aRet = DllCall('user32.dll', 'ulong_ptr', 'GetClassLongPtrW', 'hwnd', $hWnd, 'int', $iIndex)
		Else
			$aRet = DllCall('user32.dll', 'dword', 'GetClassLongW', 'hwnd', $hWnd, 'int', $iIndex)
		EndIf
		If @error Or Not $aRet[0] Then Return SetError(@error, @extended, 0)
		; If Not $aRet[0] Then Return SetError(1000, 0, 0)

		Return $aRet[0]
	EndFunc   ;==>_WinAPI_GetClassLongEx
	Func _WinAPI_SetClassLongEx($hWnd, $iIndex, $iNewLong)
		Local $aRet
		If @AutoItX64 Then
			$aRet = DllCall('user32.dll', 'ulong_ptr', 'SetClassLongPtrW', 'hwnd', $hWnd, 'int', $iIndex, 'long_ptr', $iNewLong)
		Else
			$aRet = DllCall('user32.dll', 'dword', 'SetClassLongW', 'hwnd', $hWnd, 'int', $iIndex, 'long', $iNewLong)
		EndIf
		If @error Then Return SetError(@error, @extended, 0)
		; If Not $aRet[0] Then Return SetError(1000, 0, 0)

		Return $aRet[0]
	EndFunc   ;==>_WinAPI_SetClassLongEx
	Func _GUICreate_NoIcon($sTitle = "", $iWidth = -1, $iHeight = -1, $iXpos = -1, $iYpos = -1)
		Local $hGUI = GUICreate($sTitle, $iWidth, $iHeight, $iXpos, $iYpos, BitOR($WS_CAPTION, $WS_SYSMENU), $WS_EX_DLGMODALFRAME)
		Local $hIcon = _WinAPI_GetClassLongEx($hGUI, $GCL_HICON)
		_WinAPI_DestroyIcon($hIcon)
		_WinAPI_SetClassLongEx($hGUI, $GCL_HICON, 0)
		_WinAPI_SetClassLongEx($hGUI, $GCL_HICONSM, 0)
		Return $hGUI
	EndFunc   ;==>_GUICreate_NoIcon
#endregion