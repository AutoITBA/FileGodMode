Func _GUICtrlRichEdit_Create1($hWnd, $sText, $iLeft, $iTop, $iWidth = 150, $iHeight = 150, $iStyle = -1, $iExStyle = -1)
    If Not IsString($sText) Then Return SetError(2, 0, 0) ; 2nd parameter not a string for _GUICtrlRichEdit_Create

    If Not __GCR_IsNumeric($iLeft, "") Then Return SetError(103, 0, 0)
    If Not __GCR_IsNumeric($iTop, "") Then Return SetError(104, 0, 0)
    If Not __GCR_IsNumeric($iWidth, ">0,-1") Then Return SetError(105, 0, 0)
    If Not __GCR_IsNumeric($iHeight, ">0,-1") Then Return SetError(106, 0, 0)
    If Not __GCR_IsNumeric($iStyle, ">=0,-1") Then Return SetError(107, 0, 0)
    If Not __GCR_IsNumeric($iExStyle, ">=0,-1") Then Return SetError(108, 0, 0)

    If $iWidth = -1 Then $iWidth = 150
    If $iHeight = -1 Then $iHeight = 150
    If $iStyle = -1 Then $iStyle = BitOR($ES_WANTRETURN, $ES_MULTILINE)

    If BitAND($iStyle, $ES_MULTILINE) <> 0 Then $iStyle = BitOR($iStyle, $ES_WANTRETURN)
    If $iExStyle = -1 Then $iExStyle = 0x200 ;  $DS_FOREGROUND

    $iStyle = BitOR($iStyle, $__RICHEDITCONSTANT_WS_CHILD, $__RICHEDITCONSTANT_WS_VISIBLE)
    If BitAND($iStyle, $ES_READONLY) = 0 Then $iStyle = BitOR($iStyle, $__RICHEDITCONSTANT_WS_TABSTOP)

    Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
    If @error Then Return SetError(@error, @extended, 0)

    __GCR_Init()

    Local $hRichEdit = _WinAPI_CreateWindowEx($iExStyle, $_GRE_sRTFClassName, "", $iStyle, $iLeft, $iTop, $iWidth, _
            $iHeight, $hWnd, $nCtrlID)
    If $hRichEdit = 0 Then Return SetError(700, 0, False)

    __GCR_SetOLECallback($hRichEdit)
    _SendMessage($hRichEdit, $__RICHEDITCONSTANT_WM_SETFONT, _WinAPI_GetStockObject($DEFAULT_GUI_FONT), True)
    _GUICtrlRichEdit_AppendText($hRichEdit, $sText)
    Return $hRichEdit
EndFunc   ;==>_GUICtrlRichEdit_Create