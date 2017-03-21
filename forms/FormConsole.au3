
Func GUI_console($ParentPosX,$ParentPosY,$ParentWide,$formTitle="Console")
	ConsoleWrite('+GUI_console() ='  & @crlf )
	$formTitle= $formTitle & "            " & @ComputerName & _CheckcomputerMembership()

	$formWidth=800   ;actualizar en func_wm_size  & _FormMinSize
	$formHigh=450	;actualizar en func_wm_size  & _FormMinSize
	$EditRichTxtLeft=5
	$EditRichTxtBottom=10
	$EditRichTxtTop=42
	$EditRichTxtWidth=$formWidth-($EditRichTxtLeft*2)
	$EditRichTxtHigh=$formHigh-$EditRichTxtTop-$EditRichTxtBottom-30

	$posxis= $ParentPosX-(($formWidth-$ParentWide)/2)
	If $posxis < 0 Then	$posxis= 0
		$JobConsoleForm = GUICreate($formTitle, $formWidth,$formHigh ,$posxis ,$ParentPosY,$WS_MAXIMIZEBOX+$WS_SIZEBOX+$WS_MINIMIZEBOX )
		GUISetOnEvent($GUI_EVENT_CLOSE, "JobConsole_FormClose")

		$Edt_JobConsole = _GUICtrlRichEdit_Create1($JobConsoleForm,"", $EditRichTxtLeft, $EditRichTxtTop, _
		$EditRichTxtWidth,  $EditRichTxtHigh,BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL,$WS_HSCROLL))
		_GUICtrlRichEdit_SetBkColor($Edt_JobConsole, 0xFFF0FF)
		 _GUICtrlRichEdit_SetUndoLimit($Edt_JobConsole, 0)

		$BTN_JobConsole_Testjob = IconButton("    Test", 5, 1, 60, 23, 16, $FgmDataFolderImages & "\iLearning.ICO")
		GUICtrlSetOnEvent(-1, "BTN_JobConsole_Testjob")
		GUICtrlSetResizing(-1,$GUI_DOCKleft+$GUI_DOCKTOP+$GUI_DOCKSIZE)

		$BTN_JobConsole_runjob = IconButton("   Run", 70, 1, 60, 23, 16, $FgmDataFolderImages & "\hammer.ico")
		GUICtrlSetOnEvent(-1, "BTN_JobConsole_Runjob")
		GUICtrlSetResizing(-1,$GUI_DOCKleft+$GUI_DOCKTOP+$GUI_DOCKSIZE)

		$BTN_JobConsole_runjob = IconButton("    Clear", 135, 1, 60, 23, 16, $FgmDataFolderImages & "\twirl.ico")
		GUICtrlSetOnEvent(-1, "BTN_JobConsole_clearConsole")
		GUICtrlSetResizing(-1,$GUI_DOCKleft+$GUI_DOCKTOP+$GUI_DOCKSIZE)

		$CK_JobConsole_Clearconsole=GUICtrlCreateCheckbox("Clear console(at runtime)",135, 25, 140, 17);,$GUI_DOCKright+$GUI_DOCKTOP+$GUI_DOCKSIZE)
		GUICtrlSetResizing(-1,$GUI_DOCKleft+$GUI_DOCKTOP+$GUI_DOCKSIZE)

		$ClearConsoleEveryLines= _GetAppSettings("CleanConsoleEveryLinesvalue","1000")
		$CK_JobConsole_ClearconsoleEveryLines=GUICtrlCreateCheckbox("Clear console every " & $ClearConsoleEveryLines & " Lines.",280, 25, 165, 17);,$GUI_DOCKright+$GUI_DOCKTOP+$GUI_DOCKSIZE)
		GUICtrlSetResizing(-1,$GUI_DOCKleft+$GUI_DOCKTOP+$GUI_DOCKSIZE)
		GUICtrlSetState($CK_JobConsole_ClearconsoleEveryLines,_GetAppSettings("CleanConsoleEveryLines",$GUI_UnCHECKED))
;~ 		GUICtrlSetBkColor(-1,_color("RED"))

		$CK_JobConsole_ConsoleQuiet=GUICtrlCreateCheckbox("Quiet " ,450, 25, 50, 17);,$GUI_DOCKright+$GUI_DOCKTOP+$GUI_DOCKSIZE)
		GUICtrlSetResizing(-1,$GUI_DOCKleft+$GUI_DOCKTOP+$GUI_DOCKSIZE)
		GUICtrlSetState($CK_JobConsole_ConsoleQuiet,_GetAppSettings("ConsoleQuiet",$GUI_UNCHECKED))
;~ 		GUICtrlSetBkColor(-1,_color("RED"))

		$LBL_RUNalert=GUICtrlCreateLabel("Running Job",220, 1, 110, 23)
		GUICtrlSetBkColor($LBL_RUNalert,_color("RED"))
		$font = "Comic Sans MS"
		GUICtrlSetFont(-1, 12, 700, 0, $font)
		GUICtrlSetstate($LBL_RUNalert,$GUI_HIDE)
		GUICtrlSetResizing(-1, $GUI_DOCKleft + $GUI_DOCKSIZE + $GUI_DOCKTOP)

		GUICtrlCreateLabel("F10 Pause",340, 1, 55, 15)
		GUICtrlSetResizing(-1, $GUI_DOCKleft + $GUI_DOCKSIZE + $GUI_DOCKTOP)
		GUICtrlCreateLabel("F9 Stop",340, 12, 50, 15)
		GUICtrlSetResizing(-1, $GUI_DOCKleft + $GUI_DOCKSIZE + $GUI_DOCKTOP)

		$CK_JobConsole_RunOneByOne=GUICtrlCreateCheckbox("Task run confirmation",410, 1, 125, 21);,$GUI_DOCKright+$GUI_DOCKTOP+$GUI_DOCKSIZE)
		GUICtrlSetState($CK_JobConsole_RunOneByOne,$GUI_UNCHECKED)
		GUICtrlSetResizing(-1,$GUI_DOCKleft+$GUI_DOCKTOP+$GUI_DOCKSIZE)

		$CK_JobConsole_progress=GUICtrlCreateCheckbox("Show progress",540, 1, 90, 21);,$GUI_DOCKright+$GUI_DOCKTOP+$GUI_DOCKSIZE)
		GUICtrlSetState($CK_JobConsole_progress,_GetAppSettings("ShowProgress",$GUI_UNCHECKED))
		GUICtrlSetResizing(-1,$GUI_DOCKleft+$GUI_DOCKTOP+$GUI_DOCKSIZE)

		$CK_JobConsole_Verbose=GUICtrlCreateCheckbox("Verbose",635, 1, 60, 21);,$GUI_DOCKright+$GUI_DOCKTOP+$GUI_DOCKSIZE)
		GUICtrlSetState($CK_JobConsole_Verbose,_GetAppSettings("verbose",$GUI_CHECKED))
		GUICtrlSetResizing(-1,$GUI_DOCKleft+$GUI_DOCKTOP+$GUI_DOCKSIZE)

		$CK_JobConsole_Log=GUICtrlCreateCheckbox("Log Activity",705, 1, 150, 21);,$GUI_DOCKright+$GUI_DOCKTOP+$GUI_DOCKSIZE)
		GUICtrlSetState($CK_JobConsole_Log,_GetAppSettings("logactivity",$GUI_CHECKED))
		GUICtrlSetResizing(-1,$GUI_DOCKleft+$GUI_DOCKTOP+$GUI_DOCKSIZE)

;~ 		$progressConsole = GUICtrlCreateProgress(2,$formHigh-17,85, 15,$PBS_SMOOTH)
		$progressConsole = GUICtrlCreateProgress(0,0,-1, -1,$PBS_SMOOTH)
		GUICtrlSetColor($progressConsole, _color("blue"))
;~ 		GUICtrlSetColor(-1, 32250)
		$hprogressConsole=GUICtrlGetHandle($progressConsole)

GUISetState(@SW_SHOW)
		Local $aParts[3] = [90, 620, -1]
		$STS_JobConsole_StatusBar = _GUICtrlStatusBar_Create($JobConsoleForm,$aParts)
		_GUICtrlStatusBar_SetMinHeight($JobConsoleForm, 25)
		_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar, "Ready", 0)
		_GUICtrlStatusBar_EmbedControl($STS_JobConsole_StatusBar, 2,$hprogressConsole,1+4)

		Local $hIcons0 = _WinAPI_LoadShell32Icon(23)
		_GUICtrlStatusBar_SetIcon($STS_JobConsole_StatusBar, 0, $hIcons0)

		GUIRegisterMsg($WM_SIZE, "WM_SIZE") ; When window is resized, run this function
		GUIRegisterMsg($WM_PAINT, "WM_PAINT")

		 HotKeySet("{F10}", "JobConsole_pause")
		 HotKeySet("{F9}", "JobConsole_kill")
EndFunc

