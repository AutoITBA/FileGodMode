Func QueryWebService($sURLGET="",$dta="")
	ConsoleWrite("!QueryWebService"  & @CRLF)
	ConsoleWrite('>>$dta = ' & $dta & @crlf )

	$sURL="http://" & $WebServiceaddr &"/"& $sURLGET
	ConsoleWrite('>>$sURL = ' & $sURL & @crlf )

	Local $iResponse = "Empty"
	$oXHR = ObjCreate("Msxml2.ServerXMLHTTP.6.0");
	$lResolve = 5000 ;5 * 1000
	$lConnect = 5000; 5 * 1000
	$lSend = 5000 ;15 * 1000
	$lReceive = 5000 ;15 * 1000
	$oXHR.setTimeouts($lResolve, $lConnect, $lSend, $lReceive)
	$oXHR.open("POST", $sURL, False)
	$oXHR.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	$oXHR.send($dta)
	$err=@error

;~ 	$oXHR = ObjCreate("MSXML2.XMLHTTP.6.0")
;~ 	$oXHR.open("POST", $sURL, False)
;~ 	$oXHR.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
;~ 	$oXHR.send($dta)

	If $err = 0 Then  ;-  connection OK
		$iResponse = $oXHR.responseText
		ConsoleWrite('@@$iResponse = ' & $iResponse & @crlf )
		$oStatusCode = $oXHR.Status
		ConsoleWrite('@@$oStatusCode = ' & $oStatusCode & @crlf )
		If $oStatusCode <> 200 then
			$iResponse="error" & $oStatusCode
		else
			$iResponse=StringReplace($iResponse,"</br>",@crlf)
			$iResponse=StringSplit($iResponse,@crlf)
			if StringInStr($iResponse,"Error")>0 then return $iResponse="Error"
			if StringInStr($iResponse,"<HTML>")>0 or StringInStr($iResponse,"Web Server: Too")>0  Or StringInStr($iResponse,"Could not connect:")>0 then
				;-- site down
				ConsoleWrite("!QueryWebService= HTML"  & @CRLF)
				$iResponse="NoAnswer"
			else  ;-- site OK
				ConsoleWrite("+QueryWebService= site OK"  & @CRLF)
			endif
		EndIf
	Else ;Site not answering
		ConsoleWrite("!QueryWebService= NO site answer"  & @CRLF)
		If $oMyError.WinDescription<>"" Then
			$iResponse="NoAnswer"
		else
			$iResponse="NoConnection"
		endif
	EndIf
	$oXHR=""
	ConsoleWrite("!iresponse= " & $iResponse  & @CRLF & "--------------------------"& @CRLF )
	return $iResponse
EndFunc
