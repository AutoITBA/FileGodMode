
#region app greneral
	Func _Licence()
		ConsoleWrite('++_Licence() = '& @crlf)
		If @Compiled Then
			Local $iDateCalc = _DateDiff('s', "2017/07/9 00:00:00", _NowCalc())
			If $iDateCalc > 0 Then Exit
		EndIf
	EndFunc
#endregion
#region Error Handeler
;---------- error class 1 -------------------------------
;~ 	Global $oMyError = ObjEvent("AutoIt.Error","MyErrFunc")
;~ 	Func MyErrFunc()
;~ 		Local $HexNumber = Hex($oMyError.Number, 8)
;~ 		ConsoleWrite("! COM Error !  Number: " & $HexNumber & @crlf &  "! ScriptLine: " & $oMyError.scriptline & @crlf & _
;~ 		"! Source: "  & $oMyError.source & @crlf & "! Description:" & $oMyError.WinDescription  & @LF & _
;~ 		"! Lastdllerror: " & $oMyError.lastdllerror & @crlf )
;~ 		SetError(1)
;~ 	 Endfunc
;---------- error class 2 -------------------------------
	Global Const $oMyError = ObjEvent("AutoIt.Error", "ObjErrorHandler")
	Func ObjErrorHandler()
		ConsoleWrite(   "A COM Error has occured!" & @CRLF  & @CRLF & _
                                "err.description is: "    & @TAB & $oMyError.description    & @CRLF & _
                                "err.windescription:"     & @TAB & $oMyError & @CRLF & _
                                "err.number is: "         & @TAB & Hex($oMyError.number, 8)  & @CRLF & _
                                "err.lastdllerror is: "   & @TAB & $oMyError.lastdllerror   & @CRLF & _
                                "err.scriptline is: "     & @TAB & $oMyError.scriptline     & @CRLF & _
                                "err.source is: "         & @TAB & $oMyError.source         & @CRLF & _
                                "err.helpfile is: "       & @TAB & $oMyError.helpfile       & @CRLF & _
                                "err.helpcontext is: "    & @TAB & $oMyError.helpcontext & @CRLF _
                            )
	EndFunc

#cs
	 Func MyErrFunct() ; Com Error Handler
		$HexNumber = Hex($oMyError.number, 8)
		$oMyRet[0] = $HexNumber
		$oMyRet[1] = StringStripWS($oMyError.description,3)
		ConsoleWrite("### COM Error !  Number: " & $HexNumber & "   ScriptLine: " & $oMyError.scriptline & "   Description:" & $oMyRet[1] & @LF)
		SetError(1); something to check for when this function returns
		Return
	EndFunc  ;==>MyErrFunc

	; Register a customer error handler
	_IEErrorHandlerRegister("IEMyErrFunc")
	; Do something
	; Deregister the customer error handler
	_IEErrorHandlerDeRegister()
	; Do something else
	; Register the default IE.au3 COM Error Handler
	_IEErrorHandlerRegister()
	; Do more work

	Func IEMyErrFunc()
		Local $HexNumber = Hex($oMyError.Number, 8)
		ConsoleWrite("> COM Error !  Number: " & $HexNumber & @crlf &  "> ScriptLine: " & $oMyError.scriptline & @crlf & _
		"> Source: "  & $oMyError.source & @crlf & "> Description:" & $oMyError.WinDescription  & @LF & _
		"> Lastdllerror: " & $oMyError.lastdllerror & @crlf )
		SetError(1)
	 Endfunc


	;~ ;
	;~ ; Convert Windows error code to message.
	;
	Func _WinAPI_GetErrorMessageByCode($code)
		Local $tBufferPtr = DllStructCreate("ptr")
		Local $pBufferPtr = DllStructGetPtr($tBufferPtr)

		Local $nCount = _WinAPI_FormatMessage(BitOR($__WINAPICONSTANT_FORMAT_MESSAGE_ALLOCATE_BUFFER, $__WINAPICONSTANT_FORMAT_MESSAGE_FROM_SYSTEM), _
			0, $code, 0, $pBufferPtr, 0, 0)
		If @error Then Return SetError(@error, 0, "")

		 Local $sText = ""
		Local $pBuffer = DllStructGetData($tBufferPtr, 1)
		If $pBuffer Then
			If $nCount > 0 Then
				Local $tBuffer = DllStructCreate("wchar[" & ($nCount+1) & "]", $pBuffer)
				$sText = DllStructGetData($tBuffer, 1)
			EndIf
			_WinAPI_LocalFree($pBuffer)
		EndIf

		Return $sText
	EndFunc   ;==>_WinAPI_GetErrorMessageByCode
#ce
#endregion
#region sciTe
	Func _ClearSciteConsole()
		ConsoleWrite('!!!!!!!!!!!_ClearSciteConsole Func General 92!!!!!!!!!!!!  '& @crlf)
		if $debugflag=1 then ConsoleWrite('++_ClearSciteConsole() = '& @crlf)
		ControlSend("[CLASS:SciTEWindow]", "", "Scintilla2", "+{F5}")
	EndFunc
#endregion
#region debug
	Func _LoadTimerPrint($msg="No Message")
		If $dev=1 Then
			$LoadTimerdif = TimerDiff($LoadTimerBegin)
			ConsoleWrite('--- Load Timer Difference = ' & Sec2Time($LoadTimerdif/1000) & @crlf )
			ConsoleWrite('--- ' & $msg & @crlf )
		endif
	EndFunc
#endregion
#region time
	Func  Sec2Time($nr_sec)
		$sec2time_hour = Int($nr_sec / 3600)
		$sec2time_min = Int(($nr_sec - $sec2time_hour * 3600) / 60)
		$sec2time_sec = $nr_sec - $sec2time_hour * 3600 - $sec2time_min * 60
		Return StringFormat('%02d:%02d:%02d', $sec2time_hour, $sec2time_min, $sec2time_sec)
	EndFunc   ;==>Sec2Time
	Func _GetUnixTime($sDate = 0);Date Format: 2013/01/01 00:00:00 ~ Year/Mo/Da Hr:Mi:Se
		Local $aSysTimeInfo = _Date_Time_GetTimeZoneInformation()
		Local $utcTime = ""
		If Not $sDate Then $sDate = _NowCalc()
		If Int(StringLeft($sDate, 4)) < 1970 Then Return ""
		If $aSysTimeInfo[0] = 2 Then
			$utcTime = _DateAdd('n', $aSysTimeInfo[1] + $aSysTimeInfo[7], $sDate)
		Else
			$utcTime = _DateAdd('n', $aSysTimeInfo[1], $sDate)
		EndIf
		Return _DateDiff('s', "1970/01/01 00:00:00", $utcTime)
	EndFunc   ;==>_GetUnixTime
	; #INDEX# =======================================================================================================================
	; Title .........: Time and Date Conversion Library
	; AutoIt Version : 3.3.6++
	; UDF Version ...: 1.1
	; Language ......: English
	; Description ...: Converts time between 12 hr and 24 hr with other time and date related functions.
	; Dll ...........:
	; Author(s) .....: Adam Lawrence (AdamUL)
	; Email .........:
	; Modified.......:
	; Contributors ..:
	; Resources .....:
	; Remarks .......:
	; ===============================================================================================================================
	; #CURRENT# =====================================================================================================================
	;_IsTime12Hr
	;_IsTime24Hr
	;_Time12HrTo24Hr
	;_Time24HrTo12Hr
	;_IsCalcDate
	;_IsStandardDate
	;_IsDateAndTime
	;_DateStandardToCalcDate
	;_DateCalcToStandardDate
	;_IsBetweenTimes
	;_IsBetweenDatesTimes
	;_IsBetweenDatesTimesLite
	; ===============================================================================================================================
	; #FUNCTION# ====================================================================================================================
	; Name ..........: _IsTime12Hr
	; Description ...: Checks to see if a time string is in the 12 hr (AM/PM) format.
	; Syntax ........: _IsTime12Hr($sTime)
	; Parameters ....: $sTime - A string value in time format.
	; Return values .: Success - True
	;                  Failure - False, sets @error to:
	;                  |0 - String is not in 12 hr time format.
	;                  |1 - Invalid time format string.
	; Author ........: Adam Lawrence (AdamUL)
	; Modified ......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......: No
	; ===============================================================================================================================
	Func _IsTime12Hr($sTime)
		If StringRegExp($sTime, "^(1[0-2]|[1-9]):([0-5]\d):?([0-5]\d)?(?-i:\h*)(?i)([ap]m?)$") Then Return True
		If @error Then Return SetError(1, 0, False)

		Return False
	EndFunc
	; #FUNCTION# ====================================================================================================================
	; Name ..........: _IsTime24Hr
	; Description ...: Checks to see if a time string is in the 24 hr format.
	; Syntax ........: _IsTime24Hr($sTime)
	; Parameters ....: $sTime - A string value in time format.
	; Return values .: Success - True
	;                  Failure - False, sets @error to:
	;                  |0 - String is not in 24 hr time format.
	;                  |1 - Invalid time format string.
	; Author ........: Adam Lawrence (AdamUL)
	; Modified ......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......: No
	; ===============================================================================================================================
	Func _IsTime24Hr($sTime)
		If StringRegExp($sTime, "^([01]?\d|2[0-3]):([0-5]\d):?([0-5]\d)?$") Then Return True
		If @error Then Return SetError(1, 0, False)

		Return False
	EndFunc
	; #FUNCTION# ====================================================================================================================
	; Name ..........: _Time12HrTo24Hr
	; Description ...: Convert 12 hr (AM/PM) time string to a 24 hr time string.
	; Syntax ........: _Time12HrTo24Hr($sTime[, $fDisplaySecs = True[, $fHourLeadingZero = False]])
	; Parameters ....: $sTime - "hh:mm:ss AM/PM" time format.
	;                  $fDisplaySecs - [optional] A boolean value to display seconds values. Default is True.
	;                  $fHourLeadingZero - [optional] A boolean value to pad leading zero to single digit hours. Default is False.
	; Return values .: Success - A string value in "hh:mm:ss" 24 hr time string.
	;                  Failure - "", sets @error to:
	;                  |1 - Invalid time format string
	; Author ........: Adam Lawrence (AdamUL)
	; Modified ......:
	; Remarks .......:
	; Related .......: _Time24HrTo12Hr
	; Link ..........:
	; Example .......: _Time12HrTo24Hr("12:30AM"), _Time12HrTo24Hr("1:30:45 PM"), _Time12HrTo24Hr("12:30 pm")
	; ===============================================================================================================================
	Func _Time12HrTo24Hr($sTime, $fDisplaySecs = True, $fHourLeadingZero = False)

		Local $aTime = StringRegExp($sTime, "^(1[0-2]|[1-9]):([0-5]\d):?([0-5]\d)?(?-i:\h*)(?i)([ap]m?)$", 1)
		If @error Then Return SetError(1, 0, "")
		Local $sHour = $aTime[0]
		Local $sMins = $aTime[1]
		Local $sSecs = $aTime[2]
		Local $sAMPM = $aTime[3]

		$sHour = Mod($sHour, 12)
		If StringInStr($sAMPM, "p") Then $sHour += 12

		If $fHourLeadingZero And Number($sHour) < 10 And StringLen($sHour) = 1 Then $sHour = "0" & $sHour
		If $fDisplaySecs And $sSecs = "" Then $sSecs = "00"

		If $fDisplaySecs Then Return $sHour & ":" & $sMins & ":" & $sSecs

		Return $sHour & ":" & $sMins
	EndFunc
	; #FUNCTION# ====================================================================================================================
	; Name ..........: _Time24HrTo12Hr
	; Description ...: Convert 24 hr time string to a 12 hr (AM/PM) time string.
	; Syntax ........: _Time24HrTo12Hr($sTime[, $fDisplaySecs = True[, $fHourLeadingZero = False[, $sAMPMDelim = " "]]])
	; Parameters ....: $sTime - A string value in "hh:mm:ss" time format.
	;                  $fDisplaySecs - [optional] A boolean value to display seconds values. Default is True.
	;                  $fHourLeadingZero - [optional] A boolean value to pad leading zero to single digit hours. Default is False.
	;                  $sAMPMDelim - [optional] A string value delimiter to seperate AM/PM from the numeric time. Default is " ".
	; Return values .: Success - "hh:mm:ss AM/PM" time format.
	;                  Failure - "", sets @error to:
	;                  |1 - Invalid time format string.
	; Author ........: Adam Lawrence (AdamUL)
	; Modified ......:
	; Remarks .......:
	; Related .......: _Time12HrTo24Hr
	; Link ..........:
	; Example .......: _Time24HrTo12Hr("0:30"), _Time24HrTo12Hr("15:45:36"), _Time24HrTo12Hr("5:36")
	; ===============================================================================================================================
	Func _Time24HrTo12Hr($sTime, $fDisplaySecs = True, $fHourLeadingZero = False, $sAMPMDelim = " ")

		Local $aTime = StringRegExp($sTime, "^([01]?\d|2[0-3]):([0-5]\d):?([0-5]\d)?$", 1)
		If @error Then Return SetError(1, 0, "")
		If UBound($aTime) = 2 Then ReDim $aTime[3]

		Local $sHour = $aTime[0]
		Local $sMins = $aTime[1]
		Local $sSecs = $aTime[2]
		Local $sAMPM = ""

		Switch $sHour
			Case 0
				$sHour = 12
				$sAMPM = "AM"
			Case 1 To 11
				$sAMPM = "AM"
			Case 12
				$sAMPM = "PM"
			Case 13 To 23
				$sHour = $sHour - 12
				$sAMPM = "PM"
			Case Else
		EndSwitch

		If $fHourLeadingZero And Number($sHour) < 10 And StringLen($sHour) = 1 Then $sHour = "0" & $sHour
		If Not $fHourLeadingZero  And Number($sHour) < 10 And StringLen($sHour) = 2 Then $sHour = Number($sHour)

		If $fDisplaySecs And $sSecs = "" Then $sSecs = "00"

		If $fDisplaySecs Then Return $sHour & ":" & $sMins & ":" & $sSecs & $sAMPMDelim & $sAMPM

		Return $sHour & ":" & $sMins & $sAMPMDelim & $sAMPM
	EndFunc
	; #FUNCTION# ====================================================================================================================
	; Name ..........: _IsCalcDate
	; Description ...: Checks to see if a date is in a format for calculations.
	; Syntax ........: _IsCalcDate($sDate)
	; Parameters ....: $sDate - A string value date format.
	; Return values .: Success - True
	;                  Failure - False, sets @error to 1.
	; Author ........: Adam Lawrence (AdamUL)
	; Modified ......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......: No
	; ===============================================================================================================================
	Func _IsCalcDate($sDate)
		If StringRegExp($sDate, "^(\d{4})/(\d{1,2})/(\d{1,2})$") Then Return True
		If @error Then Return SetError(1, 0, False)

		Return False
	EndFunc
	; #FUNCTION# ====================================================================================================================
	; Name ..........: _IsStandardDate
	; Description ...: Checks to see if a date is in a standard date format, "MM/DD/YYYY".
	; Syntax ........: _IsStandardDate($sDate)
	; Parameters ....: $sDate - A string value in date format.
	; Return values .: Success - True
	;                  Failure - False, sets @error to 1.
	; Author ........: Adam Lawrence (AdamUL)
	; Modified ......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......: No
	; ===============================================================================================================================
	Func _IsStandardDate($sDate)
		If StringRegExp($sDate, "^(\d{1,2})/(\d{1,2})/(\d{4})$") Then Return True
		If @error Then Return SetError(1, 0, False)

		Return False
	EndFunc
	; #FUNCTION# ====================================================================================================================
	; Name ..........: _IsDateAndTime
	; Description ...: Checks to see if a string is in a date and time format.
	; Syntax ........: _IsDateAndTime($sDateTime)
	; Parameters ....: $sDateTime - A string value in date and time format.
	; Return values .: Success - True
	;                  Failure - False, sets @error to 1.
	; Author ........: Adam Lawrence (AdamUL)
	; Modified ......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......: No
	; ===============================================================================================================================
	Func _IsDateAndTime($sDateTime)
		Local $sRegEx = "^((?:\d{1,2}/\d{1,2}/\d{4})|(?:\d{4}/\d{1,2}/\d{1,2}))?(?-i:\h*)?((?:1[0-2]|[1-9]):(?:[0-5]\d):?(?:[0-5]\d)?(?-i:\h*)(?i:[ap]m?)|(?:[01]?\d|2[0-3]):(?:[0-5]\d):?(?:[0-5]\d)?)$"

		If StringRegExp($sDateTime, $sRegEx) Then Return True
		If @error Then Return SetError(1, 0, False)

		Return False
	EndFunc
	; #FUNCTION# ====================================================================================================================
	; Name ..........: _DateStandardToCalcDate
	; Description ...: Convert a date from "MM/DD/YYYY" to "YYYY/MM/DD" format to use in date calculations.
	; Syntax ........: _DateStandardToCalcDate($sDate)
	; Parameters ....: $sDate - A string value in "MM/DD/YYYY" format.
	; Return values .: Success - Calc date string.
	;                  Failure - "", sets @error to:
	;                  |1 - Invalid date format.
	; Author ........: Adam Lawrence (AdamUL)
	; Modified ......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......: No
	; ===============================================================================================================================
	Func _DateStandardToCalcDate($sDate)
		If Not StringRegExp($sDate, "^(\d{1,2})/(\d{1,2})/(\d{4})$") Then Return SetError(1, 0, "")
		If @error Then Return SetError(1, 0, "")

		Local $sDateNew = StringRegExpReplace($sDate, "(\d{2})/(\d{2})/(\d{4})", "$3/$1/$2")
		$sDateNew = StringRegExpReplace($sDateNew, "(\d{2})/(\d)/(\d{4})", "$3/$1/0$2")
		$sDateNew = StringRegExpReplace($sDateNew, "(\d)/(\d{2})/(\d{4})", "$3/0$1/$2")
		$sDateNew = StringRegExpReplace($sDateNew, "(\d)/(\d)/(\d{4})", "$3/0$1/0$2")

		Return $sDateNew
	EndFunc
	; #FUNCTION# ====================================================================================================================
	; Name ..........: _DateCalcToStandardDate
	; Description ...: Convert a date from "YYYY/MM/DD" to "MM/DD/YYYY" format.
	; Syntax ........: _DateCalcToStandardDate($sDate)
	; Parameters ....: $sDate - A string value in "YYYY/MM/DD" format.
	; Return values .: Success - Standard date string
	;                  Failure - "", sets @error to:
	;                  |1 - Invalid date format.
	; Author ........: Adam Lawrence (AdamUL)
	; Modified ......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......: No
	; ===============================================================================================================================
	Func _DateCalcToStandardDate($sDate)
		Local $aDate = StringRegExp($sDate, "^(\d{4})/(\d{1,2})/(\d{1,2})$", 1)
		If @error Then Return SetError(1, 0, "")

		Local $sYear = $aDate[0]
		Local $sMonth = $aDate[1]
		Local $sDay = $aDate[2]

		Return Number($sMonth) & "/" & Number($sDay) & "/" & $sYear

	EndFunc
	Func _DateTimeStandardToCalcDateTime($sDateTime)
		Local $sRegEx = "^((?:\d{1,2}/\d{1,2}/\d{4})|(?:\d{4}/\d{1,2}/\d{1,2}))?(?-i:\h*)?((?:1[0-2]|[1-9]):(?:[0-5]\d):?(?:[0-5]\d)?(?-i:\h*)(?i:[ap]m?)|(?:[01]?\d|2[0-3]):(?:[0-5]\d):?(?:[0-5]\d)?)$"

		Local $aDateTime = StringRegExp($sDateTime, $sRegEx, 1)
		If @error Then Return SetError(1, 1, "")

		Local $sDate = $aDateTime[0]
		Local $sTime = $aDateTime[1]

		If _IsStandardDate($sDate) Then
			$sDate = _DateStandardToCalcDate($sDate)
			If @error Then Return SetError(2, 1, "")
		EndIf
		If Not _IsCalcDate($sDate) Then Return SetError(2, 2, "")

		If _IsTime12Hr($sTime) Then
			$sTime = _Time12HrTo24Hr($sTime)
			If @error Then Return SetError(3, 1, "")
		EndIf
		If Not _IsTime24Hr($sTime) Then Return SetError(3, 2, "")

		Return $sDate & " " & $sTime
	EndFunc
	Func _DateTimeCalcToStandardDateTime($sDateTime)
		Local $sRegEx = "^((?:\d{1,2}/\d{1,2}/\d{4})|(?:\d{4}/\d{1,2}/\d{1,2}))?(?-i:\h*)?((?:1[0-2]|[1-9]):(?:[0-5]\d):?(?:[0-5]\d)?(?-i:\h*)(?i:[ap]m?)|(?:[01]?\d|2[0-3]):(?:[0-5]\d):?(?:[0-5]\d)?)$"

		Local $aDateTime = StringRegExp($sDateTime, $sRegEx, 1)
		If @error Then Return SetError(1, 1, "")

		Local $sDate = $aDateTime[0]
		Local $sTime = $aDateTime[1]

		If _IsCalcDate($sDate) Then
			$sDate = _DateCalcToStandardDate($sDate)
			If @error Then Return SetError(2, 1, "")
		EndIf
		If Not _IsStandardDate($sDate) Then Return SetError(2, 2, "")

		If _IsTime24Hr($sTime) Then
			$sTime = _Time24HrTo12Hr($sTime)
			If @error Then Return SetError(3, 1, "")
		EndIf
		If Not _IsTime12Hr($sTime) Then Return SetError(3, 2, "")

		Return $sDate & " " & $sTime
	EndFunc
	; #FUNCTION# ====================================================================================================================
	; Name ..........: _IsBetweenTimes
	; Description ...: Test a time to see if it is between the Start Time and the End Time in a 24 hour day.
	; Syntax ........: _IsBetweenTimes($sTestTime, $sStartTime, $sEndTime)
	; Parameters ....: $sTestTime - A string value time to test, in 12 hr or 24 hr format.
	;                  $sStartTime - A string value start Time, must be before End Time in 12 hr or 24 hr format.
	;                  $sEndTime - A string value end Time, must be after Start Time in 12 hr or 24 hr format.
	; Return values .: Success - True
	;                  Failure - False, sets @error to:
	;                  |0 - Not between times.
	;                  |1 - Invalid 12 Hr format.
	;                  |2 - Invalid 24 Hr format.
	;                  |3 - Invalid time string.
	;                  |4 - End Time before Start Time.
	; Author ........: Adam Lawrence (AdamUL)
	; Modified ......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......: No
	; ===============================================================================================================================
	Func _IsBetweenTimes($sTestTime, $sStartTime, $sEndTime)

		If _IsTime12Hr($sTestTime) Then
			$sTestTime = _Time12HrTo24Hr($sTestTime)
			If @error Then Return SetError(1, 1, False)
		EndIf

		If _IsTime12Hr($sStartTime) Then
			$sStartTime = _Time12HrTo24Hr($sStartTime)
			If @error Then Return SetError(1, 2, False)
		EndIf

		If _IsTime12Hr($sEndTime) Then
			$sEndTime = _Time12HrTo24Hr($sEndTime)
			If @error Then Return SetError(1, 3, False)
		EndIf

		If Not _IsTime24Hr($sTestTime) Then Return SetError(2, 1, False)
		If Not _IsTime24Hr($sStartTime) Then Return SetError(2, 2, False)
		If Not _IsTime24Hr($sEndTime) Then Return SetError(2, 3, False)

		$sTestTime = StringReplace(StringStripWS($sTestTime, 8), ":", "")
		If @error Or @extended > 2 Then Return SetError(3, 1, False)
		If @extended = 1 Then $sTestTime &= "00"
		Local $iTestTime = Number($sTestTime)

		$sStartTime = StringReplace(StringStripWS($sStartTime, 8), ":", "")
		If @error Or @extended > 2 Then Return SetError(3, 2, False)
		If @extended = 1 Then $sStartTime &= "00"
		Local $iStartTime = Number($sStartTime)

		$sEndTime = StringReplace(StringStripWS($sEndTime, 8), ":", "")
		If @error Or @extended > 2 Then Return SetError(3, 3, False)
		If @extended = 1 Then $sEndTime &= "00"
		Local $iEndTime = Number($sEndTime)

		If $iEndTime < $iStartTime Then Return SetError(4, 0, False)

		If $iTestTime >= $iStartTime And $iTestTime <= $iEndTime Then Return True

		Return False

	EndFunc
	; #FUNCTION# ====================================================================================================================
	; Name ..........: _IsBetweenDatesTimes
	; Description ...: Test a time to see if it is between the Start Date and Time and the End Date and Time.
	; Syntax ........: _IsBetweenDatesTimes($sTestDateTime, $sStartDateTime, $sEndDateTime)
	; Parameters ....: $sTestDateTime - A string value, Date and Time to test, in 12 hr or 24 hr format "YYYY/MM/DD[ HH:MM:SS]".
	;                  $sStartDateTime - A string value, Start Date and Time, must be before End Date and Time in 12 hr or 24 hr format "YYYY/MM/DD[ HH:MM:SS]".
	;                  $sEndDateTime - A string value, End Date and Time, must be after Start Date and Time in 12 hr or 24 hr format "YYYY/MM/DD[ HH:MM:SS]".
	; Return values .: Success - True
	;                  Failure - False, sets @error to:
	;                  |1 - Invalid date format.
	;                  |2 - Error Converting to Calc date.
	;                  |3 - Invalid time format.
	;                  |4 - Invalid $sTestDateTime
	;                  |5 - Invalid $sStartDateTime
	;                  |6 - Invalid $sEndDateTime
	; Author ........: Adam Lawrence (AdamUL)
	; Modified ......:
	; Remarks .......:
	; Related .......: _IsBetweenDatesTimesLite, _IsBetweenTimes
	; Link ..........:
	; Example .......: No
	; ===============================================================================================================================
	Func _IsBetweenDatesTimes($sTestDateTime, $sStartDateTime, $sEndDateTime)
		Local $sRegEx = "^((?:\d{1,2}/\d{1,2}/\d{4})|(?:\d{4}/\d{1,2}/\d{1,2}))?(?-i:\h*)?((?:1[0-2]|[1-9]):(?:[0-5]\d):?(?:[0-5]\d)?(?-i:\h*)(?i:[ap]m?)|(?:[01]?\d|2[0-3]):(?:[0-5]\d):?(?:[0-5]\d)?)$"

		Local $aTestDateTime = StringRegExp($sTestDateTime, $sRegEx, 1)
		If @error Then Return SetError(1, 1, False)

		Local $sTestDate = $aTestDateTime[0]
		Local $sTestTime = $aTestDateTime[1]

		Local $aStartDateTime = StringRegExp($sStartDateTime, $sRegEx, 1)
		If @error Then Return SetError(1, 2, False)

		Local $sStartDate = $aStartDateTime[0]
		Local $sStartTime = $aStartDateTime[1]

		Local $aEndDateTime = StringRegExp($sEndDateTime, $sRegEx, 1)
		If @error Then Return SetError(1, 3, False)

		Local $sEndDate = $aEndDateTime[0]
		Local $sEndTime = $aEndDateTime[1]

		Select
			Case $sTestDate = "" And $sStartDate = "" And $sEndDate = ""
				$sTestDate = _NowCalcDate()
				$sStartDate = $sTestDate
				$sEndDate = $sTestDate
			Case $sTestDate <> "" And $sStartDate <> "" And $sEndDate <> ""
			Case $sTestDate = "" And $sStartDate <> "" And $sEndDate <> ""
				ContinueCase
			Case $sTestDate <> "" And $sStartDate = "" And $sEndDate <> ""
				ContinueCase
			Case $sTestDate <> "" And $sStartDate <> "" And $sEndDate = ""
				ContinueCase
			Case Else
				Return SetError(1, 4, False)
		EndSelect

		If _IsStandardDate($sTestDate) Then
			$sTestDate = _DateStandardToCalcDate($sTestDate)
			If @error Then Return SetError(2, 1, False)
		EndIf
		If _IsStandardDate($sStartDate) Then
			$sStartDate = _DateStandardToCalcDate($sStartDate)
			If @error Then Return SetError(2, 2, False)
		EndIf
		If _IsStandardDate($sEndDate) Then
			$sEndDate = _DateStandardToCalcDate($sEndDate)
			If @error Then Return SetError(2, 3, False)
		EndIf

		If Not _IsCalcDate($sTestDate) Then Return SetError(3, 1, False)
		If Not _IsCalcDate($sStartDate) Then Return SetError(3, 2, False)
		If Not _IsCalcDate($sEndDate) Then Return SetError(3, 3, False)

		$sTestDate = $sTestDate & " "
		$sStartDate = $sStartDate & " "
		$sEndDate = $sEndDate & " "

		If _IsTime12Hr($sTestTime) Then
			$sTestTime = _Time12HrTo24Hr($sTestTime)
			If @error Then Return SetError(2, 4, False)
		EndIf
		If _IsTime12Hr($sStartTime) Then
			$sStartTime = _Time12HrTo24Hr($sStartTime)
			If @error Then Return SetError(2, 5, False)
		EndIf
		If _IsTime12Hr($sEndTime) Then
			$sEndTime = _Time12HrTo24Hr($sEndTime)
			If @error Then Return SetError(2, 6, False)
		EndIf

		If Not _IsTime24Hr($sTestTime) Then Return SetError(3, 4, False)
		If Not _IsTime24Hr($sStartTime) Then Return SetError(3, 5, False)
		If Not _IsTime24Hr($sEndTime) Then Return SetError(3, 6, False)

		$sTestDateTime = $sTestDate & $sTestTime
		$sStartDateTime = $sStartDate & $sStartTime
		$sEndDateTime = $sEndDate & $sEndTime

		Local $sStartTestDateTimeDiff = _DateDiff("s", $sStartDateTime, $sTestDateTime)
		Switch @error
			Case 2
				Return SetError(5, @error, False)
			Case 3
				Return SetError(4, @error, False)
		EndSwitch

		Local $sEndTestDateTimeDiff = _DateDiff("s", $sTestDateTime, $sEndDateTime)
		Switch @error
			Case 2
				Return SetError(4, @error, False)
			Case 3
				Return SetError(6, @error, False)
		EndSwitch

		If $sStartTestDateTimeDiff >= 0 And $sEndTestDateTimeDiff >= 0 Then Return True

		Return False
	EndFunc
	; #FUNCTION# ====================================================================================================================
	; Name ..........: _IsBetweenDatesTimesLite
	; Description ...: Test a time to see if it is between the Start Date and Time and the End Date and Time.
	; Syntax ........: _IsBetweenDatesTimesLite($sTestDateTime, $sStartDateTime, $sEndDateTime)
	; Parameters ....: $sTestDateTime - A string value, Date and Time to test, in 24 hr format "YYYY/MM/DD[ HH:MM:SS]".
	;                  $sStartDateTime - A string value, Start Date and Time, must be before End Date and Time in 24 hr format "YYYY/MM/DD[ HH:MM:SS]".
	;                  $sEndDateTime - A string value, End Date and Time, must be after Start Date and Time in 24 hr format "YYYY/MM/DD[ HH:MM:SS]".
	; Return values .: Success - True
	;                  Failure - False, sets @error to:
	;                  |1 - Invalid sTestDateTime.
	;                  |2 - Invalid $sStartDateTime.
	;                  |3 - Invalid $sEndDateTime.
	; Author ........: Adam Lawrence (AdamUL)
	; Modified ......:
	; Remarks .......: Faster return than the _IsBetweenDatesTimes function, but more retricted on the format of the date and time entered.
	; Related .......: _IsBetweenDatesTimes, _IsBetweenTimes
	; Link ..........:
	; Example .......: No
	; ===============================================================================================================================
	Func _IsBetweenDatesTimesLite($sTestDateTime, $sStartDateTime, $sEndDateTime)

		Local $sStartTestDateTimeDiff = _DateDiff("s", $sStartDateTime, $sTestDateTime)
		Switch @error
			Case 2
				Return SetError(2, @error, False)
			Case 3
				Return SetError(1, @error, False)
		EndSwitch

		Local $sEndTestDateTimeDiff = _DateDiff("s", $sTestDateTime, $sEndDateTime)
		Switch @error
			Case 2
				Return SetError(1, @error, False)
			Case 3
				Return SetError(3, @error, False)
		EndSwitch

		If $sStartTestDateTimeDiff >= 0 And $sEndTestDateTimeDiff >= 0 Then Return True

		Return False
	EndFunc
#endregion
#region file work
	Func _CreateTempfile($path)
		Local $s_TempName
		Do
			$s_TempName = ""
			While StringLen($s_TempName) < 7
				$s_TempName &= Chr(Random(97, 122, 1))
			WEnd
			$s_TempName = $path & "\~" & $s_TempName & ".tmp"
		Until Not FileExists($s_TempName)
		Return $s_TempName
	EndFunc   ;==>_CreateTempfile($path)
	Func _Cat($filecat)
		ConsoleWrite('++_Cat() = '&$filecat& @crlf)
		local $line
		Local $fileh = FileOpen($filecat, 0)
		If $fileh = -1 Then 	return false
		$Cat=""
		While 1
			Local $line = FileReadLine($fileh)
			If @error = -1 Then ExitLoop
			$Cat&=$line
			ConsoleWrite('@@ Debug $line = ' & $line & @crlf )
		WEnd
		FileClose($fileh)
		return $Cat
	EndFunc
	Func _ByteSuffix($iBytes)
		$iIndex = 0
		Dim $aArray[9] = [' bytes', ' KB', ' MB', ' GB', ' TB', ' PB', ' EB', ' ZB', ' YB']
		While $iBytes > 1023
			$iIndex += 1
			$iBytes /= 1024
		WEnd
		Return Round($iBytes,1) & $aArray[$iIndex]
	EndFunc   ;==>ByteSuffix
	Func _ToBytes($sizeWithmagnitude)
;~ 		ConsoleWrite('++_ToBytes() = '& @crlf)
		$magnitude=StringRegExpReplace($sizeWithmagnitude,'[0-9]',"")
		$magnitude=StringStripWS($magnitude,1+2)
		$size=StringReplace($sizeWithmagnitude,$magnitude,"")
		select
			case $magnitude="KB" or $magnitude="K"
				$res=$size*1024
			case $magnitude="MB" or $magnitude="M"
				$res=$size*1024*1024
			case $magnitude="GB" or $magnitude="G"
				$res=$size*1024*1024*1024
			case $magnitude="B"
				$res=$size
			case Else
				$res=$size
		EndSelect
		Return $res
	EndFunc
	Func _IsFolder($sFolder)
		Local $sAttribute = FileGetAttrib($sFolder)
		If @error Then
			If $SkipobtainAtributesFlag=0 Then
;~ 				MsgBox(4096, "Error 1053", "Could not obtain the file attributes."&@crlf&"$sFolder="&$sFolder&@crlf&"$sAttribute="&$sAttribute,0)
				Return 0
			else
				Return 0
			endif
		endif
		Return StringInStr($sAttribute,"D")
	EndFunc
	Func _FileInUse($filename)
		$handle = FileOpen($filename, 1)
		$result = False
		if $handle = -1 then $result = True
		FileClose($handle)
		ConsoleWrite('_FileInUse $filename= ' & $filename& " $result= "&$result & @crlf )
		return $result
	EndFunc
	Func _GetTempDir()
	   ConsoleWrite('++_GetTempDir() = '& @crlf)
		If @OSVersion="WIN_2003" Or @OSVersion="WIN_2000"  Or @OSVersion="WIN_XP" Then
			$tempDir=@TempDir
		else
			$tempDir=@HomeDrive&@HomePath&"\AppData\Local\Temp"
		endif
		Return $tempdir
	EndFunc
	Func _updateFileInstall_bad($file_updateFileInstall,$filedest)
		; save binary data from resource to file (create not existing directory)
		;~ _ResourceSaveToFile("C:\Dir1\SubDir2\binary_data1.dat", "TEST_BIN_1", $RT_RCDATA, 0, 1)
		ConsoleWrite('>> $FileInstall= '&$filedest)
		if FileExists($file_updateFileInstall) then
			if FileGetTime($file_updateFileInstall,0,1) <>  FileGetTime($filedest,0,1) Then
;~ 				FileInstall($file_updateFileInstall,$filedest, 1)
				ConsoleWrite('==> Updated'& @crlf)
			Else
				ConsoleWrite('==> No Change'& @crlf)
			endif
		Else
;~ 			FileInstall($file_updateFileInstall,$filedest, 1)
			ConsoleWrite('==> Installed'& @crlf)
		endif
	EndFunc
	Func GetDir($sFilePath)
		If Not IsString($sFilePath) Then
			Return SetError(1, 0, -1)
		EndIf
		Local $FileDir = StringRegExpReplace($sFilePath, "\\[^\\]*$", "")
		Return $FileDir
	EndFunc
	Func GetFileName($sFilePath)
		If Not IsString($sFilePath) Then
			Return SetError(1, 0, -1)
		EndIf
		Local $FileName = StringRegExpReplace($sFilePath, "^.*\\", "")
		Return $FileName
	EndFunc
	Func _ProgramFilesDir()
		Local $ProgramFileDir
		Switch @OSArch
			Case "X32"
				$ProgramFileDir = "Program Files"
			Case "X64"
				$ProgramFileDir = "Program Files (x86)"
		EndSwitch
		Return @HomeDrive & "\" & $ProgramFileDir
	EndFunc   ;==>_ProgramFilesDirh
	Func _getServerFromPath($RemoteDrive)
		ConsoleWrite('++_getServerFromPath() $RemoteDrive='& $RemoteDrive & @crlf)
		$RemoteDrive=StringStripWS($RemoteDrive,1+2)
		$serverArr=StringRegExp($RemoteDrive,'^\\\\([0-9.]+)\\',1)
		return $serverArr[0]
	EndFunc
#endregion
#region commands
	Func _GetDOSOutput($sCommand )
		ConsoleWrite('++_GetDOSOutput $sCommand = ' & $sCommand & @crlf )
		Local $iPID, $sOutput = ""
		$iPID = Run('"' & @ComSpec & '" /c ' & $sCommand, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		While 1
			$sOutput &= StdoutRead($iPID, false, False)
			If @error Then
				ExitLoop
			EndIf
		;~ 	Sleep(10)
		WEnd
		ConsoleWrite('>> 	Output = ' & $sOutput & @crlf )
		Return $sOutput
	EndFunc   ;==>_GetDOSOutput
	Func _GetDOSOutputByFile($sCommand)
		ConsoleWrite('++_GetDOSOutputByFile $sCommand = ' & $sCommand & @crlf )
		Local $iPID, $sOutput = ""
		$tmpfile=_CreateTempfile($tempdir)
		$iPID = RunWait('"' & @ComSpec & '" /c ' & $sCommand & "  >"&$tmpfile, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		$sOutput=_cat($tmpfile)
		If $sOutput Then
			ConsoleWrite('>> 	Output = ' & $sOutput & @crlf )
			Return $sOutput
		Else
			return ""
		endif
	EndFunc   ;==>_GetDOSOutput
	Func _GetDOSOutputRunAs($sCommand,$user,$pass)
		ConsoleWrite('++_GetDOSOutputRunAs()' & @crlf )
		Local $iPID, $sOutput = ""
		$userArr=StringSplit($user,"\")
		If $userArr[1]="." Then  $userArr[1]=@ComputerName
		Local $iPID=RunAs( $userArr[2], $userArr[1],$pass, 1, '"' & @ComSpec & '" /c ' & $sCommand , @UserProfileDir ,  @SW_HIDE , $STDERR_CHILD + $STDOUT_CHILD)
		ConsoleWrite('$sCommand = ' & $sCommand & @crlf )
		While 1
			$sOutput &= StdoutRead($iPID, False, False)
			If @error Then 	ExitLoop
			Sleep(10)
		WEnd
		ConsoleWrite('_GetDOSOutputRunAs = ' & $sOutput & @crlf )
	   Return $sOutput
	EndFunc   ;==>_GetDOSOutput
	Func _GetDOSOutputRunAsRemote($sCommand,$serverName,$user,$pass)
		ConsoleWrite('++_GetDOSOutputRunAsRemote()' & @crlf )
		Local $iPID, $sOutput = ""
		dim $resarray[3]
		$resarray[0]=-1
		$resarray[1]=-1
		$resarray[2]=""

		$userArr=StringSplit($user,"\")
		if UBound($userArr)=2 then
			$usuario=$userArr[1]
			$dominio=$serverName
;~ 			$dominio="."
		Else
			If $userArr[1]="." Then
				$usuario=$userArr[2]
				$dominio=$serverName
			Else
				$usuario=$userArr[2]
				$dominio=$userArr[1]
			endif
		endif
		$sCommandRemote =  'WMIC /node:' & $serverName & '  /user:'& $dominio&'\'&$usuario  & '  /password:'& $pass&' process call create "' & $sCommand & '"'
		Local $iPID=Run( '"' & @ComSpec & '" /c ' & $sCommandRemote , @UserProfileDir ,  @SW_HIDE , $STDERR_MERGED)
;~ 		ConsoleWrite('-- $iPID = ' & $iPID &'  $sCommand = ' & $sCommand & @crlf )
		While 1
			$sOutput &= StdoutRead($iPID, False, False)
			$err=@error
			If $err Then ExitLoop
			Sleep(10)
		WEnd
		$resarray[2]=$sOutput
		if StringInStr($sOutput,"successful")>0 then
			$var=StringSplit($sOutput,@crlf)
			for $li in $var
				if StringInStr($li,"ProcessId")>0 then
					$liarr=StringSplit($li,"=")
					$resarray[0]=StringReplace(StringStripWS($liarr[2],3),";","")
				endif
				if StringInStr($li,"ReturnValue")>0 then
					$liarr=StringSplit($li,"=")
					$resarray[1]=StringReplace(StringStripWS($liarr[2],3),";","")
				endif
;~ 				ReturnValue = 9   no exe
			next
		Else
			$resarray[0]=1000000
			$resarray[1]=1000
			if StringInStr($sOutput,"The RPC server is unavailable")>0 then
				$resarray[2]="The RPC server is unavailable"
			endif
		endif
		_printFromArray($resarray)
		Return $resarray
	EndFunc   ;==>_GetDOSOutputRunAsRemote
	func _GetRemoteProcessStatus($serverName,$prosess,$user,$pass)
		ConsoleWrite('++_GetRemoteProcessStatus()' & @crlf )
		Local $iPID, $sOutput = ""
		dim $resarray[3]
		$resarray[0]=-1
		$resarray[1]=-1
		$resarray[2]=""

		$userArr=StringSplit($user,"\")
		if UBound($userArr)=2 then
			$usuario=$userArr[1]
			$dominio=$serverName
		Else
			If $userArr[1]="." Then
				$usuario=$userArr[2]
				$dominio=$serverName
			Else
				$usuario=$userArr[2]
				$dominio=$userArr[1]
			endif
		endif

		$sCommandRemote =  'WMIC /node:' & $serverName & '  /user:'& $dominio&'\'&$usuario  & '  /password:'& _
							$pass&' process where name="'& $prosess & '"  get ProcessId '
		ConsoleWrite('$sCommandRemote = ' & $sCommandRemote & @crlf )
		Local $iPID=Run( '"' & @ComSpec & '" /c ' & $sCommandRemote , @UserProfileDir ,  @SW_HIDE , $STDERR_MERGED)
		ConsoleWrite('-- $iPID = ' & $iPID & @crlf )
		While 1
			$sOutput &= StdoutRead($iPID, False, False)
			$err=@error
			If $err Then ExitLoop
			Sleep(10)
		WEnd
		ConsoleWrite('_GetRemoteProcessStatus = ' & $sOutput & @crlf )
		$resarray[2]=$sOutput
		$flagproc=0

		if StringInStr($sOutput,"ProcessId")>0 then
			$var=StringSplit($sOutput,@crlf)
			for $i=1 to UBound($var)-1
				$liclean=StringStripWS($var[$i],3)
				if $liclean<>"" then
					ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $li = ' & $liclean & @crlf )
					if $flagproc=0 then
						if StringInStr($liclean,"ProcessId")>0 then
						Else
							$resarray[0]=$liclean
							$flagproc=1
							ContinueLoop
						endif
					Else
						$resarray[1]=1
					endif
				endif
			next
		Else
			$resarray[0]=1000
			$resarray[1]=1000
			if StringInStr($sOutput,"The RPC server is unavailable")>0 then
				$resarray[2]="The RPC server is unavailable"
			endif
			if StringInStr($sOutput,"No Instance")>0 then
				$resarray[2]="No Instance"
			endif
		endif
		Return $resarray
	EndFunc
	func _TerminateRemoteProcess($serverName,$prosess,$user,$pass)
		ConsoleWrite('++_TerminateRemoteProcess()' & @crlf )
		Local $iPID, $sOutput = ""
		dim $resarray[3]
		$resarray[0]=-1
		$resarray[1]=-1
		$resarray[2]=""

		$userArr=StringSplit($user,"\")
		if UBound($userArr)=2 then
			$usuario=$userArr[1]
			$dominio=$serverName
		Else
			If $userArr[1]="." Then
				$usuario=$userArr[2]
				$dominio=$serverName
			Else
				$usuario=$userArr[2]
				$dominio=$userArr[1]
			endif
		endif

		$sCommandRemote =  'WMIC /node:' & $serverName & '  /user:'& $dominio&'\'&$usuario  & '  /password:'& _
							$pass&' process where name="'& $prosess & '"  Call Terminate '
;~ 		ConsoleWrite('$sCommandRemote = ' & $sCommandRemote & @crlf )
		Local $iPID=Run( '"' & @ComSpec & '" /c ' & $sCommandRemote , @UserProfileDir ,  @SW_HIDE , $STDERR_MERGED)
		ConsoleWrite('-- $iPID = ' & $iPID & @crlf )
		While 1
			$sOutput &= StdoutRead($iPID, False, False)
			$err=@error
			If $err Then ExitLoop
			Sleep(10)
		WEnd
		ConsoleWrite('_GetRemoteProcessStatus = ' & $sOutput & @crlf )
		$resarray[2]=$sOutput
		$flagHandle=0
		if StringInStr($sOutput,"successful")>0 then
			$var=StringSplit($sOutput,@crlf)
			for $li in $var
				$mtchArr=StringRegExp($li,'Win32_Process.Handle="[0-9]*"',1)
				if @error  then
					if $flagHandle=0 then $resarray[0]=1000
				Else
					$flagHandle=1
					$resarray[0]=StringReplace(StringReplace($mtchArr[0],'Win32_Process.Handle="',""),'"',"")
				endif

				if StringInStr($li,"ReturnValue")>0 then
					$liarr=StringSplit($li,"=")
					$resarray[1]=StringReplace(StringStripWS($liarr[2],3),";","")
				endif
			next
		Else
			$resarray[0]=1000
			$resarray[1]=1000
		endif
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $resarray[0] = ' & $resarray[0] & @crlf )
		Return $resarray
	EndFunc
	Func _KillProcess($proceso,$userT,$passT)
		ConsoleWrite('++_KillProcess() = '& $proceso& @crlf)
		$sCommand='tasklist /FI "IMAGENAME eq ' & $proceso &'"'
		$var=_GetDOSOutputRunAs($sCommand,$userT,$passT)
		If StringInStr($var,$proceso)>0 Then
			MemoWrite($iMemo,@TAB&"Killing process " & $proceso,"blue",8,1)
			$sCommand='taskkill /F /IM ' & $proceso &'"'
			$var=_GetDOSOutputRunAs($sCommand,$userT,$passT)
			MemoWrite($iMemo,@TAB&_clearEmptyLines($var) ,"blue",10,1)
		Else
;~ 				MemoWrite($iMemo,@TAB&_clearEmptyLines($var)  ,"red",10,1)
		endif
	EndFunc
#endregion
#region string processing
	Func _clearEmptyLines($var)
		ConsoleWrite('++_clearEmptyLines() = '& @crlf)
		$vararr=StringSplit($var,@crlf)
		Local $vartotal=""
		Local $counter=0
		For $va In $vararr
			If $counter>0 then
				If StringStripWS($va,3)<>"" then
					$vartotal &= @tab&StringReplace(StringReplace($va,@crlf,""),@tab,"")&@crlf
				endif
			EndIf
			$counter +=1
		next
		Return $vartotal
	EndFunc
	Func _clearEmptyLinesFromArray($vararr,$skipFirstrow=0)
		ConsoleWrite('++_clearEmptyLinesFromArray() = '& @crlf)
		dim $vartotal[1]
		For $va In $vararr
			if $skipFirstrow=1 then
				$skipFirstrow=0
			else
				if StringStripWS($va,1+2)<>"" then
					_ArrayAdd($vartotal,$va)
				EndIf
			endif
		next
		_ArrayDelete($vartotal,0)
		Return $vartotal
	EndFunc
#endregion
#region Firewall
	Func _SetFirewall()
		$f_sav = @ScriptDir & '\Pocket-SF.sav'
		$_GetIP = @IPAddress1
		Local $s_reg = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', $f_fopen, $f_Socket, $f_tray
	;~ 	Local $p_MD5 = PluginOpen('MD5.dll')

		$s_locip = @IPAddress1

		If Not FileExists($f_sav) Then
			ShellExecute("cmd.exe", 'netsh firewall add allowedprogram ' & @ScriptFullPath _
				& " " & 'ACNalertFT ENABLE ALL', "", "", @SW_HIDE) ;Add firewall exception

			For $i = 1 To 3
				FileWrite($f_sav, @CRLF)
			Next
		EndIf
	EndFunc
#endregion
#region controls
	Func _IsCheckedType($iControlID)
		$sts=$GUI_UNCHECKED
		If _IsChecked($iControlID) Then $sts=$GUI_CHECKED
		Return $sts
	EndFunc
	Func _IsChecked($iControlID)
		Return BitAND(GUICtrlRead($iControlID), 1) = 1
	EndFunc
#endregion
#region Network
	Func _ReverseDNS($IPAddress)
		ConsoleWrite('++_ReverseDNS() = '& $IPAddress & @crlf)
		GUICtrlSetData($LBL_Settings_DNSregistration,"DNS Registration Lookup")
		$IPAddress = StringStripWS($IPAddress,3)
		$sCommand="nslookup "& $IPAddress
		$ResponseText = _GetDOSOutputByFile($sCommand)
		ConsoleWrite('- $ResponseText = ' & $ResponseText & @crlf )
		If StringInStr($ResponseText,"*** UnKnown")>0 Then
			GUICtrlSetData($LBL_Settings_DNSregistration,"DNS Registration Lookup UnKnown")
			Return "Unknown"
		endif
		GUICtrlSetState($LBL_Settings_DNSregistration,@SW_HIDE)
		$x1 = StringInStr($ResponseText, "Name:")
		$x2 = StringInStr($ResponseText, "Address",0,-1)
		If $x1 = 0 or $x2 = 0 Then
			GUICtrlSetData($LBL_Settings_DNSregistration,"DNS Registration Lookup UnKnown")
			Return "Unknown"
		endif
		Dim $arr[3]
		$arr[1]=StringStripWS(StringMid($ResponseText, $x1 + 6, $x2 - $x1 - 6),3)
		$arr[2]=StringStripWS(StringMid($ResponseText, $x2 + 11, stringlen($ResponseText)),3)
		;check if there are many ips
		$ipArr=StringSplit(StringStripWS($arr[2],1+2+4),@TAB,2)
		_printFromArray($ipArr)
		$arrID=2
		for $ic=0 to UBound($ipArr)-1
			If _IsValidIP($ipArr[$ic]) Then
				$arr[$arrID] = $ipArr[$ic]
				$arrID=$arrID+1
				redim $arr[$arrID+1]
			endif
		next
		_ArrayDelete($arr,$arrID+1)
		If $x1 > 0 and $x2 > 0 Then Return $arr
		GUICtrlSetData($LBL_Settings_DNSregistration,"DNS Registration Lookup Error")
		Return "UnknownError"
	EndFunc
	Func _ReverseDNSConnector($IPAddress)
		if $debugflag=1 then ConsoleWrite('++_ReverseDNSConnector() = '& $IPAddress & @crlf)
		$IPAddress = StringStripWS($IPAddress,3)
		$sCommand="nslookup "& $IPAddress
		$ResponseText = _GetDOSOutput($sCommand)
		if $debugflag=1 then ConsoleWrite('ResponseText = ' & $ResponseText & @crlf )
		If StringInStr($ResponseText,"*** UnKnown")>0 Then
			Return "Unknown"
		endif
		$x1 = StringInStr($ResponseText, "Name:")
		$x2 = StringInStr($ResponseText, "Address",0,-1)
		If $x1 = 0 or $x2 = 0 Then Return "Unknown"
		Dim $arr[3]
		$arr[1]=StringStripWS(StringMid($ResponseText, $x1 + 6, $x2 - $x1 - 6),3)
		$arr[2]=StringStripWS(StringMid($ResponseText, $x2 + 8, 17),3)
		If $x1 > 0 and $x2 > 0 Then Return $arr[2]
		Return "UnknownError"
	EndFunc
	Func _GetFQDN()
		if $debugflag=1 then ConsoleWrite('++_GetFQDN() = '& @crlf)
		$objWMIService = ObjGet("winmgmts:{impersonationLevel = impersonate}!\\" & @ComputerName & "\root\cimv2")
		If @error Then Return SetError(2, 0, "")
		$colItems = $objWMIService.ExecQuery("SELECT Name,Domain FROM Win32_ComputerSystem ", "WQL", 0x30)
		If IsObj($colItems) Then
			For $objItem In $colItems
				If $objItem.Domain = "" Then
;~ 					Return  $objItem.Name
					Return SetError(3, 0, "")
				Else
					Return  $objItem.Name & "." & $objItem.Domain
				endif
			Next
		Else
			Return SetError(3, 0, "")
		EndIf
	EndFunc
	Func _GetServerDNSip()
		if $debugflag=1 then ConsoleWrite('++_GetServerDNSip() = '& @crlf)
		$fqdn=_GetFQDN()
		_consolewrite("FQDN = "&$fqdn)
		If @Compiled Then
			$ip=_ReverseDNSConnector($fqdn)
		Else
			$ip=@IPAddress1
		endif
		_consolewrite("ServerDNSip = "&$ip)
		Return $ip
	EndFunc
	Func _GetNetworkConnect()
		Local Const $NETWORK_ALIVE_LAN = 0x1  ;net card connection
		Local Const $NETWORK_ALIVE_WAN = 0x2  ;RAS (internet) connection
		Local Const $NETWORK_ALIVE_AOL = 0x4  ;AOL
		Local $aRet, $iResult
		$aRet = DllCall("sensapi.dll", "int", "IsNetworkAlive", "int*", 0)
		If BitAND($aRet[1], $NETWORK_ALIVE_LAN) Then $iResult &= "LAN connected" & @LF
		If BitAND($aRet[1], $NETWORK_ALIVE_WAN) Then $iResult &= "WAN connected" & @LF
		If BitAND($aRet[1], $NETWORK_ALIVE_AOL) Then $iResult &= "AOL connected" & @LF
		Return $iResult
	EndFunc
	Func _CheckInetConnectionGetIP()
		return false
		for $in=1 to 2
			ConsoleWrite('++_CheckInetConnectionGetIP() = '& @crlf )
			If _GetIP() <> -1 Then ;  internet connection is working
;~ 				MsgBox(64+4096, "YAY!!!", "Internet Connection Back!")
				return true
			EndIf
			Sleep(100)
		next
		return false
	EndFunc
	Func _CheckPingGooGle()
		ConsoleWrite('++_CheckPingGooGle() = '& @crlf )
;~ 		When the function fails (returns 0) @error contains extended information:
;~ 		1 = Host is offline
;~ 		2 = Host is unreachable
;~ 		3 = Bad destination
;~ 		4 = Other errors
		for $in=1 to 2
			Local $var = Ping("8.8.8.8", 4000)
			$err=@error
			If $var > 0 Then ;  internet connection is working
				return true
			EndIf
			Sleep(100)
		next
		return false
	EndFunc
	Func _CheckWebConnection()
		ConsoleWrite('++_CheckWebConnection() = '& @crlf )
		$sCommand= 'powershell.exe -command "& {$browser = New-Object System.Net.WebClient;$browser.Proxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials; Invoke-WebRequest -uri "www.google.com"|select statuscode|% {$_.statuscode -eq 200}}"'
		$res=_GetDOSOutput($sCommand )
		if $res="true" then return True
		return false
	EndFunc
	Func _CheckInetcheckMethod()
		ConsoleWrite('++_CheckInetcheckMethod() = '& @crlf )
		if _CheckPingGooGle()=0 then
			$useInetcheckMethod=0
		elseif _CheckWebConnection() then
			$useInetcheckMethod=1
		elseif _CheckInetConnectionGetIP() then
			$useInetcheckMethod=2
		Else
			$useInetcheckMethod=0
		endif
		return $useInetcheckMethod
	EndFunc
	func _CheckInetConnection()
		ConsoleWrite('++_CheckInetConnection() = '& @crlf )
		switch $useInetcheckMethod
			case 0
				$resp=_CheckPingGooGle()
			case 1
				$resp=_CheckWebConnection()
			case 2
				$resp=_CheckInetConnectionGetIP()
			case else
				$resp=_CheckPingGooGle()
		EndSwitch
		return $resp
	endfunc
#endregion
#region Encription
	Func _Hashing($Password,$Hashflag=0)   ; 1 decrypt to , 0 to  encrypt.
;~ 		ConsoleWrite('++_Hashing() = '& @crlf )
			if $Hashflag=0 then
				Local $bEncrypted = _StringEncrypt(1,$Password,$HashingPassword,1) ; 1 to encrypt, 0 to decrypt.
			Else
				Local $bEncrypted = _StringEncrypt(0,$Password,$HashingPassword,1) ; 1 to encrypt, 0 to decrypt.
			EndIf
		return $bEncrypted
	EndFunc
	Func _HashingColumnArray($qryRes,$iColumna,$Hashflag=0)  ; 1 to encrypt, 0 to decrypt.
;~ 		ConsoleWrite('++_HashingColumnArray() = '& @crlf)
		Local $qryResultHashing[1][ubound($qryRes,2)]
		if $Hashflag=0 then
			For $iRows = 0 To UBound($qryRes,1)-1
				For $iColumns = 0 To UBound($qryRes,2)-1
					ReDim $qryResultHashing[$iRows+1][ubound($qryRes,2)]
					if $iColumns=$iColumna and $iRows>0 then
						$qryResultHashing[$iRows][$iColumns]=_Hashing($qryRes[$iRows][$iColumns],1)
					Else
						$qryResultHashing[$iRows][$iColumns]=$qryRes[$iRows][$iColumns]
					endif
				next
			next
		Else
			ConsoleWrite('!!!!!!!!!!!!!!!!!!!!!!++_HashingColumnArray() =   fill code '& @crlf)
		EndIf
		return $qryResultHashing
	EndFunc
#endregion
#region Design
	Func _color($dato)
;~ 		ConsoleWrite('++_color() = '& @crlf )
		If $dato="blue" Then Return "0x0000FF"
		If $dato="lightgreen" Then Return "0x00FF00"
		If $dato="Darkgreen" Then Return "0x088A08"
;~ 		If $dato="green" Then Return "0x3A5F0B"  ;41A317
		If $dato="green" Then Return "0x99CC00"
		If $dato="red" Then Return "0xFF0000"
		If $dato="orange" Then Return "0xFF6600"
		If $dato="yellow" Then Return "0xFFFF00"
		If $dato="Purple" Then Return "0xFF00FF"
		If $dato="lightblue" Then Return "0x00FFFF"
		If $dato="black" Then Return "0x000000"
		If $dato="white" Then Return "0xffffff"
		If $dato="blue" Then Return "0x0000ff"
		If $dato="rose" Then Return "0xFAEBD7"
		If $dato="lightRed" Then Return "0xF78181"
	EndFunc
#endregion
#region contextMenu
	; Show a menu in a given GUI window which belongs to a given GUI ctrl
	Func ShowMenuAtMouse($hWnd, $CtrlID, $nContextID)
		ConsoleWrite('++ShowMenuAtMouse() = '& @crlf )
		if _GUICtrlListView_GetSelectedCount($CtrlID)>0 then
			Local $arPos, $x, $y
			Local $hMenu = GUICtrlGetHandle($nContextID)
			Local $arPos = MouseGetPos()
			$x = $arPos[0]
			$y = $arPos[1]
	;~ 		ClientToScreen($hWnd, $x, $y)
			TrackPopupMenu($hWnd, $hMenu, $x, $y)
		endif
	EndFunc   ;==>ShowMenu
	; Show a menu in a given GUI window which belongs to a given GUI ctrl
	Func ShowMenu($hWnd, $CtrlID, $nContextID)
;~ 		ConsoleWrite('++ShowMenu() = '& @crlf )
		Local $arPos, $x, $y
		Local $hMenu = GUICtrlGetHandle($nContextID)
		$arPos = ControlGetPos($hWnd, "", $CtrlID)
		$x = $arPos[0]
		$y = $arPos[1] + $arPos[3]
		ClientToScreen($hWnd, $x, $y)
		TrackPopupMenu($hWnd, $hMenu, $x, $y)
	EndFunc   ;==>ShowMenu
	; Convert the client (GUI) coordinates to screen (desktop) coordinates
	Func ClientToScreen($hWnd, ByRef $x, ByRef $y)
;~ 		ConsoleWrite('++ClientToScreen() = '& @crlf )
		Local $stPoint = DllStructCreate("int;int")
		DllStructSetData($stPoint, 1, $x)
		DllStructSetData($stPoint, 2, $y)
		DllCall("user32.dll", "int", "ClientToScreen", "hwnd", $hWnd, "ptr", DllStructGetPtr($stPoint))
		$x = DllStructGetData($stPoint, 1)
		$y = DllStructGetData($stPoint, 2)
		; release Struct not really needed as it is a local
		$stPoint = 0
	EndFunc   ;==>ClientToScreen
	; Show at the given coordinates (x, y) the popup menu (hMenu) which belongs to a given GUI window (hWnd)
	Func TrackPopupMenu($hWnd, $hMenu, $x, $y)
;~ 		ConsoleWrite('++TrackPopupMenu() = '& @crlf )
		DllCall("user32.dll", "int", "TrackPopupMenuEx", "hwnd", $hMenu, "int", 0, "int", $x, "int", $y, "hwnd", $hWnd, "ptr", 0)
	EndFunc   ;==>TrackPopupMenu

#endregion
#Region mouse
	func moveMouseOnePixel()
		Local $posMouse = MouseGetPos()
		MouseMove($posMouse[0],$posMouse[1]+1)
	endfunc
#endregion
#region Arrays
	Func _ArrayToFile($fila,$arrsql,$startColumn=0,$header="",$encript=0)
		ConsoleWrite('++++_ArrayToFile() = '& @crlf )
		Local $fileh = FileOpen($fila, 1)
		If $fileh = -1 Then
			MsgBox(48+4096, "Error Exporting Job", "Unable to open file "&$fila&" for export")
			Return 1
		EndIf
		For $iRows = 1 To UBound($arrsql,1)-1
			local $linea=""
			if $header <> "" then local $linea=$header& ","
			For $iColumns = $startColumn To UBound($arrsql,2)-2
				$linea &= $arrsql[$iRows][$iColumns] & ","
			next
			$linea &= $arrsql[$iRows][$iColumns]
			If $encript=1 Then
				FileWriteLine($fileh, _Hashing($linea,0) & @CRLF)
			Else
				FileWriteLine($fileh, $linea & @CRLF)
			EndIf
		next
		FileClose($fileh)
		Return 0
	EndFunc
#endregion