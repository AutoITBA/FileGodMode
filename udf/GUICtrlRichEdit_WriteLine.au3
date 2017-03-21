;~ #include <GUIConstantsEx.au3>
;~ #include <GuiTab.au3>
;~ #include <GuiRichEdit.au3>
;~ #include <WinAPI.au3>
;~ #include <WindowsConstants.au3>
;~ #include <Constants.au3>
;~ Opt("GUIOnEventMode", 1)

;~ $Form1 = GUICreate("Main", 400, 400)
;~     GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEClicked")
;~     $idTab = GUICtrlCreateTab(2, 2, 396, 396)
;~         $hTab = GUICtrlGetHandle($idTab)
;~         $TabSheet1 = GUICtrlCreateTabItem("Main")
;~             $Tab1rich = _GUICtrlRichEdit_Create($Form1, "", 20, 80, 360, 200, BitOR($ES_MULTILINE, $ES_READONLY, $WS_VSCROLL))
;~             ;~ ControlDisable($Form1, "", $hRichEdit)
;~             ;~ ControlHide($Form1, "", $hRichEdit)
;~             GUICtrlCreateLabel("Main tab 0...", 20, 50, 360, 20)
;~         $TabSheet2 = GUICtrlCreateTabItem("History")
;~             GUICtrlCreateLabel("History tab 1...", 20, 50, 360, 20)
;~             $historyrich = _GUICtrlRichEdit_Create($Form1, "", 20, 80, 360, 200, BitOR($ES_MULTILINE, $ES_READONLY, $WS_VSCROLL))
;~             ControlDisable($Form1, "", $historyrich)
;~             ControlHide($Form1, "", $historyrich)
;~         $TabSheet3 = GUICtrlCreateTabItem("blah")
;~             GUICtrlCreateLabel("blah tab 2...", 20, 50, 360, 20)
;~             $Tab3rich = _GUICtrlRichEdit_Create($Form1, "", 20, 80, 360, 200, BitOR($ES_MULTILINE, $ES_READONLY, $WS_VSCROLL))
;~             ControlDisable($Form1, "", $Tab3rich)ControlHide($Form1, "", $Tab3rich)
;~     GUICtrlCreateTabItem("")
;~ GUISetState(@SW_SHOW)


;~ 	_GUICtrlRichEdit_WriteLine($Tab1rich,"ASDF  fj aslfj skldjf lkdsjf jaskdjf lsjdfldsjflasldsjf llskjlg fsdfsdffdsdsfghjf lskjdf lskdjf lskdjflkjlg ashd")
;~ 	_GUICtrlRichEdit_WriteLine($Tab1rich,"ABC",0x00FF00) ;green
;~ 	_GUICtrlRichEdit_WriteLine($historyrich,"ABC",0xFF0000) ;red
;~ 	_GUICtrlRichEdit_WriteLine($historyrich,"ABC",0xFFFF00) ;yellow
;~ 	_GUICtrlRichEdit_WriteLine($Tab3rich,"ABC",0x00FF00) ;green
;~ 	_GUICtrlRichEdit_WriteLine($Tab3rich,"ABC" ,0x00FFFF) ;light blue
;~ 	_GUICtrlRichEdit_WriteLine($Tab1rich,"ABC" ,0x0000FF) ;BLUE
;~ 	_GUICtrlRichEdit_WriteLine($historyrich,"3333333333" ,0xFF00FF) ;Purple

;~ While 1
;~ 	Sleep(50)
;~ WEnd

;~ Func CLOSEClicked()
;~     ;Note: at this point @GUI_CTRLID would equal $GUI_EVENT_CLOSE,
;~     ;and @GUI_WINHANDLE would equal $mainwindow
;~     _GUICtrlRichEdit_Destroy($Tab1rich)
;~     _GUICtrlRichEdit_Destroy($historyrich)
;~     _GUICtrlRichEdit_Destroy($Tab3rich)
;~     Exit
;~ EndFunc
Func _GUICtrlRichEdit_WriteLine($hWnd, $sText, $iColor = 0,$FontSize=8,$bold=1,$writeInline=0,$newLine=1)
	;set bold
	If $bold Then
		_GUICtrlRichEdit_SetCharAttributes($hWnd, "+bo",True)
	endif
    ; Count the @CRLFs
    StringReplace(_GUICtrlRichEdit_GetText($hWnd, True), @CRLF, "")
    Local $iLines = @extended
    ; Adjust the text char count to account for the @CRLFs
    Local $iEndPoint = _GUICtrlRichEdit_GetTextLength($hWnd, True, True) - $iLines

	if $writeInline=1 then
		; delete last line
		_GuiCtrlRichEdit_SetSel($hWnd, $iEndPoint, -1)
		_GUICtrlRichEdit_AppendText($hWnd, "" )
	endif

    ; Add new text
	$nl=""
	if $newLine=1 then $nl=@CRLF
    _GUICtrlRichEdit_AppendText($hWnd, $sText & $nl)
    ; Select text between old and new end points
    _GuiCtrlRichEdit_SetSel($hWnd, $iEndPoint, -1)
    ; Convert colour from RGB to BGR
    $iColor = Hex($iColor, 6)
    $iColor = '0x' & StringMid($iColor, 5, 2) & StringMid($iColor, 3, 2) & StringMid($iColor, 1, 2)
    ; Set colour
    _GuiCtrlRichEdit_SetCharColor($hWnd, $iColor)
	;set size
	If $FontSize<>8 Then
		$fontToset=$FontSize-8
	Else
		$fontToset=0
	endif

	_GUICtrlRichEdit_SetFont($hWnd, 8, "Times Roman")
	_GUICtrlRichEdit_ChangeFontSize($hWnd, $fontToset)

    ; Clear selection
    _GUICtrlRichEdit_Deselect($hWnd)
	_GUICtrlRichEdit_SetFont($hWnd, 8, "Times Roman")
	_GUICtrlRichEdit_SetCharAttributes($hWnd, "-bo")
	_GUICtrlRichEdit_ChangeFontSize($hWnd, 8)

EndFunc