Func QueryWebService($sURLGET)
	;ConsoleWrite("!QueryWebService"  & @CRLF)
	Local $iResponse = "Empty"

	Local $sURL="http://" & $WebServiceaddr & $sURLGET
	ConsoleWrite("->$sURL=" & $sURL &  @CRLF)
	Local $iResponse = "Empty"
	$oXHR = ObjCreate("Msxml2.ServerXMLHTTP.6.0");
	$lResolve = 5000 ;5 * 1000
	$lConnect = 5000; 5 * 1000
	$lSend = 5000 ;15 * 1000
	$lReceive = 5000 ;15 * 1000
	$oXHR.setTimeouts($lResolve, $lConnect, $lSend, $lReceive)
	$oXHR.open("POST", $sURL, False)
	$oXHR.send()
	$err=@error
	If $err = 0 Then  ;-  connection OK
		$iResponse = $oXHR.responseText
		$iResponse =ClearEmptyLines($iResponse)
		if StringInStr($iResponse,"<HTML>")>0 or  StringInStr($iResponse,"Web Server: Too")>0  Or StringInStr($iResponse,"Could not connect:")>0 then
			;-- site down
			ConsoleWrite("!QueryWebService= HTML"  & @CRLF)
			$iResponse="NoAnswer"
		else  ;-- site OK
			ConsoleWrite("+QueryWebService= site OK"  & @CRLF)
		endif
	Else ;Site not answering
		ConsoleWrite("!QueryWebService= NO site answer"  & @CRLF)
		If $oMyError.WinDescription<>"" Then
			$iResponse="NoAnswer"
		else
			$iResponse="NoConnection"
		endif
	EndIf
	$oXHR=""

	;cleanup tracking
	$iResponseTEMP=StringSplit($iResponse, '<!--',1)
	$iResponse=StringStripWS($iResponseTEMP[1],3)
	ConsoleWrite('$iResponse = ' & $iResponse & @crlf)
	return $iResponse
EndFunc