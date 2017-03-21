
Func GUI_ConsoleDescribe($ParentPosX,$ParentPosY,$ParentWide,$formTitle="Describe task")
	ConsoleWrite('+GUI_ConsoleDescribe() ='  & $taskid & @crlf )

	$formTitle= $formTitle & "            " & @ComputerName ;& _CheckcomputerMembership()
	$formWidth=800   ;actualizar en func_wm_size  & _FormMinSize
	$formHigh=450	;actualizar en func_wm_size  & _FormMinSize
	$EditRichTxtLeft=5
	$EditRichTxtBottom=5
	$EditRichTxtTop=30
	$EditRichTxtWidth=$formWidth-($EditRichTxtLeft*2)
	$EditRichTxtHigh=$formHigh-$EditRichTxtTop-$EditRichTxtBottom-30
	$posxis= $ParentPosX-(($formWidth-$ParentWide)/2)
	If $posxis < 0 Then	$posxis= 0

		$ConsoleDescribeForm = GUICreate($formTitle, $formWidth,$formHigh ,$posxis ,$ParentPosY,$WS_MAXIMIZEBOX+$WS_SIZEBOX+$WS_MINIMIZEBOX )
			GUISetOnEvent($GUI_EVENT_CLOSE, "ConsoleDescribe_FormClose")

		$BTN_ConsoleDescribe_OpenCSV = IconButton("    Open CSV report", 5, 1, 120, 24, 16, $FgmDataFolderImages & "\OpenCSV.ico")
			GUICtrlSetOnEvent(-1, "BTN_ConsoleDescribe_OpenCSV")
			GUICtrlSetResizing(-1,$GUI_DOCKleft+$GUI_DOCKTOP+$GUI_DOCKSIZE)
			GUICtrlSetState($BTN_ConsoleDescribe_OpenCSV,$GUI_DISABLE)

		$Edt_ConsoleDescribe = _GUICtrlRichEdit_Create1($ConsoleDescribeForm,"", $EditRichTxtLeft, $EditRichTxtTop, _
			$EditRichTxtWidth,  $EditRichTxtHigh,BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL,$WS_HSCROLL))
			_GUICtrlRichEdit_SetBkColor(-1, 0xFFF0FF)
			_GUICtrlRichEdit_SetUndoLimit(-1, 0)
	GUISetState(@SW_SHOW)
		GUIRegisterMsg($WM_SIZE, "WM_SIZE") ; When window is resized, run this function
;~ 		GUIRegisterMsg($WM_PAINT, "WM_PAINT")
EndFunc

