#region
		Func WM_SYSCOMMAND($hWnd, $iMsg, $iwParam, $ilParam)  ; Handle WM_SYSCOMMAND messages
			#forceref $hWnd, $iMsg, $ilParam
			Local $nNotifyCode = BitShift($iwParam, 16)
		    Local $nID = BitAND($iwParam, 0x0000FFFF)
			Local $hCtrl = $ilParam
;~ 				ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $iwParam = ' & $iwParam & @crlf )

			Switch $iwParam
				Case $SC_CLOSE
					ConsoleWrite("!Exit pressed" & @LF)
					$formHandle=WinGetHandle("[Active]")
					ApplicationClose($formHandle)
				Case  0x0000F012
					$formHandle=WinGetHandle("[Active]")
					If $FormAbout=$formHandle Then
						ConsoleWrite("!top bar pressed" & @LF)
						ApplicationClose($formHandle)
					endif
		;~ 		Case 0x0000F095 ;$MenuItem_About)
		;~ 			AboutEvent()
		;~ 		Case $SC_RESTORE
		;~ 			ConsoleWrite("!Restore window" & @LF)
		;~ 			Return 0
		;~ 		Case $SC_MINIMIZE
		;~ 			ConsoleWrite("!Minimize Window" & @LF)
		;~ 			Return 0
		;~ 		Case $SC_MOUSEMENU + 3
		;~ 			ConsoleWrite("!System menu pressed" & @LF)
		;~ 		Case $SC_MOVE
		;~ 			ConsoleWrite("!System menu Move Option pressed" & @LF)
		;~ 			Return 0
		;~ 		Case $SC_SIZE
		;~ 			ConsoleWrite("!System menu Size Option pressed" & @LF)
		;~ 			Return 0
		;~ 		Case $SC_MOUSEMENU + 2 ; This and the following case statements are only valid when the GUI is resizable
		;~ 			ConsoleWrite("!Right side of GUI clicked" & @LF)
		;~ 			Return 0
		;~ 		Case $SC_MOUSEMENU + 1
		;~ 			ConsoleWrite("!Left side of GUI clicked" & @LF)
		;~ 			Return 0
		;~ 		Case $SC_MOUSEMENU + 8
		;~ 			ConsoleWrite("!Lower Right corner of GUI clicked" & @LF)
		;~ 			Return 0
		;~ 		Case $SC_MOUSEMENU + 7
		;~ 			ConsoleWrite("!Lower Left corner of GUI clicked" & @LF)
		;~ 			Return 0
		;~ 		Case $SC_MOUSEMENU + 6
		;~ 			ConsoleWrite("!Bottom side of GUI clicked" & @LF)
		;~ 			Return 0




;~ 				Case Else
;~ 					ConsoleWrite("!!!WM_SYSCOMMAND" & @CRLF &"GUIHWnd" & @TAB & ":" & $hWnd & @LF & _
;~ 							"MsgID" & @TAB & ":" & $imsg & @LF & "iwParam" & @TAB & ":" & $iwParam & @LF & _
;~ 							"ilParam" & @TAB & ":" & $ilParam & @LF & @LF & "WM_SYSCOMMAND - Infos:" & @LF & _
;~ 							"-----------------------------" & @LF & "Code" & @TAB & ":" & $nNotifyCode & @LF & _
;~ 							"CtrlID" & @TAB & ":" & $nID & @LF & "CtrlHWnd" & @TAB & ":" & $hCtrl & @LF )
				EndSwitch
			EndFunc
#endregion