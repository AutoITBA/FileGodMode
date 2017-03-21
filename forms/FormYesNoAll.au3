
#Region ### START Koda GUI section ### Form=
	$FormYesNoAll = GUICreate("Form1", 357, 118, -1, -1, $WS_POPUP)
	GUISetOnEvent($GUI_EVENT_CLOSE, "FormYesNoAlClose")
	$BTN_YesNoAl_no = GUICtrlCreateButton("No", 107, 80, 57, 25)
	GUICtrlSetOnEvent(-1, "BTN_YesNoAl_no_Click")

	$Lbl_YesNoAll = GUICtrlCreateLabel("", 32, 16, 36, 17)
	GUICtrlSetOnEvent(-1, "Lbl_YesNoAll_Click")

	$BTN_YesNoAl_yes= GUICtrlCreateButton("Yes", 24, 80, 57, 25)
	GUICtrlSetOnEvent(-1, "BTN_YesNoAl_yes_Click")

	$BTN_YesNoAl_YesAll = GUICtrlCreateButton("Yes to all", 189, 80, 57, 25)
	GUICtrlSetOnEvent(-1, "BTN_YesNoAl_yesall_Click")

	$BTN_YesNoAl_noall = GUICtrlCreateButton("No to all", 272, 80, 57, 25)
	GUICtrlSetOnEvent(-1, "BTN_YesNoAl_noall_Click")
	GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	Sleep(100)
WEnd

Func $BTN_YesNoAl_no()

EndFunc
Func $Lbl_YesNoAll()

EndFunc
Func $BTN_YesNoAl_YesAll()

EndFunc
Func $BTN_YesNoAl_noall()

EndFunc
Func FormYesNoAlClose()

EndFunc

