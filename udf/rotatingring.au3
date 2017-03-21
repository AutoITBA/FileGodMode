
Global $picNo = 0,  $stp = 0, $alarm=""

	Func showRotatingRing($ParentPosX,$ParentPosY,$ParentWide)
		ConsoleWrite('++showRotatingRing() = '& @crlf)
		$posxis= $ParentPosX-((32-$ParentWide)/2)
		Global $GuiRing = GUICreate("test", 67, 80, $posxis, $ParentPosY+10, $WS_POPUP, BitOR($WS_EX_COMPOSITED, $WS_EX_LAYERED, $WS_EX_TOPMOST))
		$alarm = GUICtrlCreatePic($tempDir&"\RotatingRing01.bmp", 0, 0, 67, 80)
		GUISetState()
		$picNo = 0
		AdlibRegister("Ring", 30)
		Return $GuiRing
	EndFunc  ;==>ShowAlarm
	Func stopRotatingRing()
		ConsoleWrite('++stopRotatingRing() = '& @crlf)
		AdlibUnRegister("Ring")
		ToolTip("")
		GUIDelete($GuiRing)
	EndFunc
	Func Ring()
		$timetip = "Processing"
		 $cantImages =4
		$stp=$stp+1
		If $stp>10 Then
			WinSetOnTop($GuiRing, "", 1)
			$picNo = Mod($picNo + 1, 3)
			If $picNo>$cantImages Then $picNo = 1
			GUICtrlSetImage($alarm, $tempDir&"\RotatingRing0" & 3 - $picNo & ".bmp")
			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $picNo = ' & $picNo & @crlf )
			$stp = 0
			Local $pos=WinGetPos($GuiRing)
			ToolTip($timetip& _StringRepeat(".",$picNo*2),$pos[0],$pos[1]+30)
		EndIf

	EndFunc