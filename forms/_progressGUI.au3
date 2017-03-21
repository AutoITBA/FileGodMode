#include-once
#Include <ProgressConstants.au3>
#include <WindowsConstants.au3>
	If @OSVersion="WIN_2003" Or @OSVersion="WIN_2000"  Or @OSVersion="WIN_XP" Then
		$tempDir=@TempDir
	else
		$tempDir=@HomeDrive&@HomePath&"\AppData\Local\Temp"
	endif
; #INDEX# =======================================================================================================================
; Title .........: ProgressGui
; Language ......: English
; Description ...: A small splash screen type GUI with a progress bar and a configurable label
; Author(s) .....: Bob Marotte (BrewManNH)
; ===============================================================================================================================
; #CURRENT# =====================================================================================================================
;_ProgressGui
; ===============================================================================================================================
; #FUNCTION# ====================================================================================================================
; Name...........: _ProgressGui
; Description ...: A small splash screen type GUI with a progress bar and a configurable label
; Syntax.........: _ProgressGUI($MsgText = "Text Message"[, $_MarqueeType = 0[, $_iFontsize = 14[, $_sFont = "Arial"[, $_iXSize = 290[, $_iYSize = 100[, $_GUIColor = 0x00080FF[, $_FontColor = 0x0FFFC19]]]]]]])
; Parameters ....: $MsgText      - Text to display on the GUI
;                  $_MarqueeType - [optional] Style of Progress Bar you want to use:
;                  |0 - Marquee style [default]
;                  |1 - Normal Progress Bar style
;                  $_iFontsize 	 - [optional] The font size that you want to display the $MsgText at [default = 14]
;                  $_sFont  	 - [optional] The font you want the message to use [default = "Arial"]
;                  $_iXSize 	 - [optional] Width of the GUI [Default = 290] - Minimum size is 80
;                  $_iYSize 	 - [optional] Height of the GUI [Default = 100]
;                  $_GUIColor 	 - [optional] Background color of the GUI [default = 0x00080FF = Blue]
;                  $_sFontColor  - [optional] Color of the text message [default = 0x0FFFC19 = Yellow]
; Return values .: Success - Returns an array of the Control IDs created in the format:
;                  |array[0] = The handle of the GUI
;                  |array[1] = The handle of the Progress bar
;                  |array[2] = The handle of the label
;                  Failure - 0 and @error to 1 if the GUI couldn't be created
; Author ........: Bob Marotte (BrewManNH)
; Modified.......:
; Remarks .......: This will create a customizable GUI with a progress bar. The default style of the progress bar
;                  using this function is the Marquee style of progress bar. If you call this function with any
;                  positive, non-zero number it will use the normal progress bar style. All optional parameters
;                  will accept the Default keyword, an empty string "", or -1 if passed to the function, except
;                  the color parameters which will not accept the Default keyword.
;                  Use the array[0] return value to delete the GUI when you're done using it (ex. GUIDelete($Returnvalue[0])
; Related .......: None
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Global $LBL_ProgressGui_Load=""
Func _ProgressGUI($MsgText = "Text Message", $_MarqueeType = 0, $_iFontsize = 14, $_sFont = "Arial", $_iXSize = 290, $_iYSize = 100, $_GUIColor = 0x00080FF, $_FontColor = 0x0FFFC19)
	Local $PBMarquee[3]
	Local $GUI_HIDE = 32
	Local $GUI_SHOW = 16
	; bounds checking/correcting
	If $_iFontsize = "" Or $_iFontsize = "Default" Or $_iFontsize = "-1" Then $_iFontsize = 14
	If $_iFontsize < 1 Then $_iFontsize = 1
	If $_iXSize = "" Or $_iXSize = "-1" Or $_iXSize = Default Then $_iXSize = 290
	If $_iXSize < 80 Then $_iXSize = 80
	If $_iXSize > @DesktopWidth - 50 Then $_iXSize = @DesktopWidth - 50
	If $_iYSize = "" Or $_iYSize = "-1" Or $_iYSize = Default Then $_iYSize = 100
	If $_iYSize > @DesktopHeight - 50 Then $_iYSize = @DesktopHeight - 50
	If $_GUIColor = "" Or $_GUIColor = "-1" Then $_GUIColor = 0x00080FF
	If $_sFont = "" Or $_sFont = "-1" Or $_sFont = "Default" Then $_sFont = "Arial"

	;create the GUI
	$PBMarquee[0] = GUICreate("", $_iXSize, $_iYSize, -1, -1, BitOR($WS_DLGFRAME, $WS_POPUP),$WS_EX_TOPMOST);
	If @error Then Return SetError(@error, 0, 0) ; if there's any error with creating the GUI, return the error code
	GUISetBkColor($_GUIColor, $PBMarquee[0])

	;	Create the progressbar
	If $_MarqueeType < 1 Then ; if $_MarqueeType < 1 then use the Marquee style progress bar
		$PBMarquee[1] = GUICtrlCreateProgress(20, $_iYSize - 20, $_iXSize - 40, 15, BitOR($PBS_MARQUEE, $PBS_SMOOTH))
		GUICtrlSendMsg($PBMarquee[1], 1034, True, 20)
	Else ; If $_MarqueeType > 0 then use the normal style progress bar
		$PBMarquee[1] = GUICtrlCreateProgress(20, $_iYSize - 20, $_iXSize - 40, 15, $PBS_SMOOTH)
	EndIf

	$PBMarquee[2] = GUICtrlCreateLabel($MsgText, 60, 20, $_iXSize - 40, $_iYSize - 45) ; create the label for the GUI
	GUICtrlSetFont(-1, $_iFontsize, 400, Default, $_sFont)
	GUICtrlSetColor(-1, $_FontColor)

	$LBL_ProgressGui_Load = GUICtrlCreateLabel("    Loading  project data  ",80, $_iYSize - 33, 140, 17)
	GUICtrlSetBkColor($LBL_ProgressGui_Load,_color("GREEN"))
	$font = "Comic Sans MS"
	GUICtrlSetFont(-1, 8, 700, 0, $font)
	GUICtrlSetstate($LBL_ProgressGui_Load,$GUI_HIDE)

	FileInstall("images\Transfer.ico", $tempDir & "\Transfer.ico", 1)
	GUICtrlCreateIcon($tempDir & "\Transfer.ico", -1, 0, 0, 48, 48)

	GUISetState()
	Return SetError(0, 0, $PBMarquee) ;Return the ControlIDs of the GUI and the Progress bar
EndFunc   ;==>_ProgressGUI
