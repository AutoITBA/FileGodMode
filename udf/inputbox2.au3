Func _inputbox2($title,$mensage1,$mensage2,$ParentPosX,$ParentPosY,$ParentWide,$formwidth=300)
	ConsoleWrite('++() = '& @crlf)
	$posxis= $ParentPosX-(($formwidth-$ParentWide)/2)
	If $posxis < 0 Then	$posxis= 0
	$GUI_inputbox2=GUICreate($title, 320, 120, $posxis, $ParentPosY)
	GUICtrlCreateLabel($mensage1,    10,  5,  $formwidth, 17)
	$field1_inputbox2 = GUICtrlCreateInput("", 10, 22,  $formwidth, 20)
	GUICtrlCreateLabel($mensage2,    10, 48,  $formwidth, 17)
	$field2_inputbox2 = GUICtrlCreateInput("", 10, 65,  $formwidth, 20)
	$btn_inputbox2 = GUICtrlCreateButton("Ok", ($formwidth/2)-20, 90,  60,  20)
	GUISetState()

	Dim $arr[2]
	$flagInputbox2=0
	Local $begin = TimerInit()

	While $flagInputbox2=0
		Sleep(200)
		$dif = TimerDiff($begin)
		If $dif>(60*1000) Then $flagInputbox2=1
	WEnd

	$flagInputbox2=0
	$arr[0]=StringStripWS(GUICtrlRead($field1_inputbox2),3)
	$arr[1]=StringStripWS(GUICtrlRead($field2_inputbox2),3)
	Return $arr
EndFunc