#region  ================================== INIT ======================================

#endregion
#region  ================================== Helpers ======================================
	Func _getToken()
		if $debugflag=1 then ConsoleWrite('++_getToken() = '& @crlf)
		$StartTicks = _GetUnixTime()
		$EndTicks = $StartTicks + 60
		Local $var1=_Hashing($passcode&@SEC&$EndTicks,1)
		Return $var1
	EndFunc
	Func _IsValidToken($token)
		if $debugflag=1 then ConsoleWrite('++_IsValidToken() = '&$token& @crlf)
		Local $var1=_Hashing($token,0)
		Local $tokenTicks=StringTrimLeft(StringReplace($var1,$passcode,""),2)
		$NowTicks = _GetUnixTime()
		If $tokenTicks>$NowTicks Then
			Return True
		Else
			Return false
		endif
	EndFunc

#endregion
#region =================================== listener   ========================================
	Func _startListener()
		if $debugflag=1 then ConsoleWrite('++_startListener() = '& @crlf)
		$listenerIP=_GetServerDNSip()
		If _IsValidIP($listenerIP) Then
			TCPStartup()
			$sMainSocket = TCPListen($listenerIP, $nPort, 50)
			$err=@error
			If $err Then
				If Not _checkerror($err) Then _ConsoleWrite("Unable to set up a listening server on IP " & _
													$listenerIP & " Port " & $nPort & " ERROR  NUMBER = " & $err,3 )
				_stopListener()
				_ConsoleWrite('Unable to start listener' ,3)
				return
			endif
			If $sMainSocket < 1 Then
				_ConsoleWrite("TCP Socket connot be created " ,3)
				_ConsoleWrite('Unable to start listener' ,3)
				$ListenerActive=0
				Return
			Else
				_consolewrite("Listener Active on IP " & $listenerIP & " Port " & $nPort)
				$ListenerActive=1
			EndIf
		Else
			_consolewrite("Not Valid IP",3)
			$ListenerActive=0
		endif
	EndFunc
	Func _TCPacceptConnection()
;~ 		ConsoleWrite('++_TCPacceptConnection() = '& @crlf)
		;; Accept new incoming clients, and ask them to authorise.
		$ConnectedSocket = TCPAccept($sMainSocket)
		If $ConnectedSocket > -1 Then
			; Get IP of client connecting
			$szIP_Accepted = _SocketToIP($ConnectedSocket)
			If _IsValidIP($szIP_Accepted) then
				_ConsoleWrite("Client connected IP "& $szIP_Accepted,1)
			Else
				_ConsoleWrite("Client connected IP not valid "& $szIP_Accepted,2)
			endif
			Return true
		Else
			Return false
		EndIf
	EndFunc
	Func _Authentication()
		if $debugflag=1 then ConsoleWrite('++_Authentication() = '& @crlf)
		$bitesSent=TCPSend($ConnectedSocket, "REQ_AUTH")
		$err=@error
		If $err Then
			If Not _checkerror($err) Then _ConsoleWrite('Unhandled exception. AuthRequest error '&$err,3)
			_stopListener()
			Return false
		else
			If $bitesSent>1 Then
				$recv= _WaitResponse("OFR_CRED",100,60000)
				If $recv Then
					$TokenRecv=StringReplace($recv,"OFR_CRED","")
					$TokenValid=_IsValidToken($tokenrecv)
					_ConsoleWrite('Authentication Token is  '&$TokenValid,1)
					If $TokenValid Then
						TCPSend($ConnectedSocket, "AUTH_OK")
						Return true
					Else
						TCPSend($ConnectedSocket, "AUTH_DENY")
						_stopListener( )
						Return false
					endif
				Else
					Return false
				endif
			Else
				_ConsoleWrite('Authentication canot be requested by REQ_AUTH',3)
				Return false
			endif
		endif
	EndFunc
	Func _Authorization()
		if $debugflag=1 then ConsoleWrite('++_Authorization() = '& @crlf)
		Return true
	EndFunc
	Func _PathRequest()
		if $debugflag=1 then ConsoleWrite('++_PathRequest() = '& @crlf)
		$bitesSent=TCPSend($ConnectedSocket, "REQ_PATH")
		$err=@error
		If $err Then
			If Not _checkerror($err) Then _ConsoleWrite('Unhandled exception. PathRequest error '&$err,3)
			_stopListener()
			Return false
		else
			If $bitesSent>1 Then
				$recv= _WaitResponse("OFR_PATH",1000,60000)
				If $recv Then
					$PathRecv=StringReplace($recv,"OFR_PATH","")
					$PathValid=_IsFolder($Pathrecv)
					_ConsoleWrite('Path validation is  '&$PathValid,1)
					If $PathValid Then
						$pathFolderCommand=$PathRecv
						TCPSend($ConnectedSocket, "PATH_OK")
						Return true
					Else
						TCPSend($ConnectedSocket, "PATH_DENY")
						_stopListener( )
						Return false
					endif
				Else
					Return false
				endif
			Else
				_ConsoleWrite('Path canot be requested by REQ_PATH',3)
				Return false
			endif
		endif
	EndFunc
	Func _BatRequest()
		if $debugflag=1 then ConsoleWrite('++_BatRequest() = '& @crlf)
		$bitesSent=TCPSend($ConnectedSocket, "REQ_BAT")
		$err=@error
		If $err Then
			If Not _checkerror($err) Then _ConsoleWrite('Unhandled exception. BatRequest error '&$err,3)
			_stopListener()
			Return false
		else
			If $bitesSent>1 Then
				$recv= _WaitResponse("OFR_BAT",1000,60000)
				If $recv Then
					$BatRecv=StringReplace($recv,"OFR_BAT","")
					$BatValid=FileExists($pathFolderCommand&"\"&$BatRecv)
					_ConsoleWrite('File validation is  '&$BatValid,1)
					$BatIsBat=StringInStr(stringRight($BatRecv,4),".bat")
					_ConsoleWrite('Bat extension validation is  '&$BatValid,1)
					If $BatValid And $BatIsBat Then
						$PathFileBatCommand=$pathFolderCommand&"\"&$BatRecv
						TCPSend($ConnectedSocket, "BAT_OK")
						Return true
					Else
						TCPSend($ConnectedSocket, "BAT_DENY")
						_stopListener( )
						Return false
					endif
				Else
					Return false
				endif
			Else
				_ConsoleWrite('Bat canot be requested by REQ_BAT',3)
				Return false
			endif
		endif
	EndFunc
	Func _RunBatFile()
		if $debugflag=1 then ConsoleWrite('++_RunBatFile() = '&$PathFileBatCommand& @crlf)
		$pathcommand=$PathFileBatCommand&"\"&$pathFolderCommand
		$msgresult=_GetDOSOutput($pathcommand)
		_SendResults($msgresult)
	EndFunc
	Func _SendResults($msgresult)
		if $debugflag=1 then ConsoleWrite('++_SendResults() = '& @crlf)
		$bitesSent=TCPSend($ConnectedSocket, $msgresult)
		$err=@error
		If $err Then
			If Not _checkerror($err) Then _ConsoleWrite('Unhandled exception. SendResults error '&$err,3)
			_ConsoleWrite($msgresult,1)
			_stopListener()
			Return false
		else
			Return true
		endif
	EndFunc
#endregion
#region =================================== TCP connection helpers   ========================================
	Func _SocketToIP($SHOCKET)  ; Function to return IP Address from a connected socket.
		Local $sockaddr, $aRet

		$sockaddr = DllStructCreate("short;ushort;uint;char[8]")

		$aRet = DllCall("Ws2_32.dll", "int", "getpeername", "int", $SHOCKET, _
				"ptr", DllStructGetPtr($sockaddr), "int*", DllStructGetSize($sockaddr))
		If Not @error And $aRet[0] = 0 Then
			$aRet = DllCall("Ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($sockaddr, 3))
			If Not @error Then $aRet = $aRet[0]
		Else
			$aRet = 0
		EndIf

		$sockaddr = 0

		Return $aRet
	EndFunc   ;==>SocketToIP
	func _checkerror($err)
		Switch $err
			Case 1
				_ConsoleWrite("The listening address is incorrect (Possibly another server is already running): " & $listenerIP,3)
			Case 2
				_ConsoleWrite("The listening port is incorrect (Possibly another server is already running): " & $nPort,3)
			Case 10048
				_ConsoleWrite("Address already in use. " ,3)
			Case 10050
				_ConsoleWrite("Network is down. " ,3)
			Case 10013
				_ConsoleWrite("Permission denied. An attempt was made to access a socket in a way forbidden by its access permissions. " ,3)
			Case 10014
				_ConsoleWrite("Bad address. The system detected an invalid pointer address in attempting to use a pointer argument of a call." ,3)
			Case 10054 ;Connection reset by peer.
				_ConsoleWrite('Cnnection reset by peer. An existing connection was forcibly closed by the remote host.'&$err,3)
			Case 10057
				_ConsoleWrite('Socket is not connected.request to send or receive data was disallowed because the socket is not connected.'&$err,3)
			Case 10038
				_ConsoleWrite('Socket operation on nonsocket. An operation was attempted on something that is not a socket.'&$err,3)
			Case Else
				Return false
		EndSwitch
		Return true
	EndFunc
	Func _stopListener( )
		ConsoleWrite('++_stopListener( ) '& @crlf)
		TCPCloseSocket($sMainSocket)
		TCPShutdown( )
		_ConsoleWrite("Listener TCP Socket closed" ,1)
		$ListenerActive=0
	EndFunc   ;==>_CloseReceiveTCP
	func _WaitResponse($responseEspected,$bits,$timeout=60000)
		ConsoleWrite('++_WaitResponse   $response= ' & $responseEspected & '  $timeout = ' & $timeout & @crlf )
		$inicio=TimerInit()
		$TCPres=""
		$respuesta=""
		$sData=""
		$res=0
		$sBuffer=""
		While 1
			$sData=TCPRecv($ConnectedSocket, $bits)
			$err=@error
			If $err Then
				If Not _checkerror($err) Then _ConsoleWrite('Unhandled exception. WaitResponse. error '&$err,3)
				_stopListener()
				Return false
			else
				$sBuffer&= $sData
				If StringInStr($sBuffer, @CRLF) Then $respuesta = StringReplace($sBuffer,@crlf,"")

				if $responseEspected<>"" then
					$res=StringInStr($respuesta, $responseEspected)
					select
						case TimerDiff($inicio)>$timeout
							_ConsoleWrite("Connection Closing due timeout ("&$timeout&")",2)
							_stopListener( )
							Return false
						case $res>0
							_ConsoleWrite("TCPrecv = " & $respuesta , 1)
							Return $respuesta
						case $respuesta<>""
							_ConsoleWrite("TCPrecv = " & $respuesta , 2)
							$respuesta=""
	;~ 						Return $respuesta
					EndSelect
				Else
					Return $respuesta
				endif
			endif
			Sleep(10)
		WEnd
	endfunc
#endregion




