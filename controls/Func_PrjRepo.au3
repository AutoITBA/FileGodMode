	Func _UpdateAppSettings_PrjDBRepo()
		$repoPath=_GetAppSettings("RepoAddress",$RepoProjectDBDefault,1)
		ConsoleWrite('++_UpdateAppSettings_PrjDBRepo() $repoPath = ' & $repoPath& @crlf)
		$RepoType=_GetAppSettings("RepoType","http",1)
	EndFunc
	Func _CkeckPrjDBRepoFiles($flagForceUpdateRepodb)
		ConsoleWrite('++_CkeckPrjDBRepoFiles() = '& @crlf)
		GUICtrlSetstate($LBL_CheckRepo,$GUi_show)
		GUICtrlSetBkColor($LBL_CheckRepo,_color("ORANGE"))
		GUICtrlSetData($LBL_CheckRepo,"   Checking Project Database repository")
		GUICtrlSetData($LBL_CheckRepo,_CkeckUpdatePrjDBRepoFiles($flagForceUpdateRepodb))
	EndFunc
	Func _CkeckUpdatePrjDBRepoFiles($flagForceUpdateRepodb=0)
		$repoPath=_GetAppSettings("RepoAddress",$RepoProjectDBDefault)
		ConsoleWrite('++_CkeckUpdatePrjDBRepoFiles() = '&$repoPath& @crlf)
		$RepoType=_GetAppSettings("RepoType","http")
		local $returnsentence=""
		$repoArr=_GetRepoFiles($repoPath,$RepoType)
		_printfromarray($repoArr)
		if IsArray($repoArr) Then
			for $i=0 to UBound($repoArr)-1
				GUICtrlSetBkColor($LBL_CheckRepo,_color("ORANGE"))
				$filename = $repoArr[$i][0]
							ConsoleWrite("-"&$FgmDataFolder&"\"&$filename & @crlf )
				$fileDateRepo = $repoArr[$i][1]
							ConsoleWrite('--$fileDateRepo =  ' & $fileDateRepo & @crlf )
				$fileDateRepoS = $repoArr[$i][3]
							ConsoleWrite('--$fileDateRepoS =  ' & $fileDateRepoS & @crlf )
				if FileExists($FgmDataFolder&"\"&$filename) then
					$fileDateLocal=FileGetTime($FgmDataFolder&"\"&$filename,0,1)
					$fileDateLocal=_Date_Time_Convert($fileDateLocal, "yyyyMMddHHmmss", "yyyy/MM/dd HH:mm")
							ConsoleWrite('--$fileDateLocal = ' & $fileDateLocal & @crlf )
					$iDateCalc = _DateDiff("n",$fileDateRepo,$fileDateLocal)
							ConsoleWrite('$iDateCalc = ' & $iDateCalc & @crlf )
				Else
					$iDateCalc=-1
				endif
				if $iDateCalc<0 or $flagForceUpdateRepodb=1 Then
					if _UpdatePrjDBfromRepo($RepoPath,$FgmDataFolder,$filename,$RepoType) then
						FileClose($FgmDataFolder&"\"&$filename)
						;$FT_MODIFIED=0 modified(default)     $FT_CREATED=1 Created     $FT_ACCESSED=2 accessed
						Local $iFileSetTime = FileSetTime($FgmDataFolder&"\"&$filename, $fileDateRepoS, $FT_MODIFIED)
						If $iFileSetTime Then
						Else
							ConsoleWrite("!!! An error occurred while setting the timestamp of the file."& @crlf )
						EndIf
						ConsoleWrite('>!!!  Project Database was updated from Repository !!!'& @crlf)
						GUICtrlSetBkColor($LBL_CheckRepo,_color("GREEN"))
						$returnsentence=_ReturnSentence_CkeckUpdatePrjDBRepoFiles(" Project Database was updated from Repository",$returnsentence)
					Else
						ConsoleWrite('!!!  Error Updating Project Database from Repository !!!'& @crlf)
						GUICtrlSetBkColor($LBL_CheckRepo,_color("RED"))
						$returnsentence=_ReturnSentence_CkeckUpdatePrjDBRepoFiles(" Error Updating Project Database from Repository",$returnsentence)
					endif
				Else
					ConsoleWrite(">!!!  Project's Database is up to date   !!!"& @crlf)
					GUICtrlSetBkColor($LBL_CheckRepo,_color("GREEN"))
					$returnsentence=_ReturnSentence_CkeckUpdatePrjDBRepoFiles("          Project's Database is up to date",$returnsentence)
				endif
			next
			if StringInStr($returnsentence,"was updated")>0 then
				GUICtrlSetBkColor($LBL_CheckRepo,_color("ORANGE"))
				$lbl_orig=_ctrlread($LBL_CheckRepo)
				GUICtrlSetData($LBL_CheckRepo,"       Updating Project Database repository ")
				_ConfigDBInitial(1)
				GUICtrlSetData($LBL_CheckRepo,$lbl_orig)
				GUICtrlSetBkColor($LBL_CheckRepo,_color("GREEN"))
			endif
			return $returnsentence
		Else
			Switch $repoArr
				Case 1
					ConsoleWrite('!!!  No Project DataBase files in Repository   !!!'& @crlf)
					GUICtrlSetBkColor($LBL_CheckRepo,_color("green"))
					return "   No Project DataBase files at Repository"
				Case 0
					ConsoleWrite('!!!  No connection to Project DataBase Repository   !!!'& @crlf)
					GUICtrlSetBkColor($LBL_CheckRepo,_color("orange"))
					return "  No connection to Project DataBase Repository"
				Case 2
					ConsoleWrite('!!!  Path to Project DataBase Repository not found !!!'& @crlf)
					GUICtrlSetBkColor($LBL_CheckRepo,_color("orange"))
					return "  Path to Project DB Repository not found"
				case Else
					ConsoleWrite('!!!  No repo files to update   !!!'& @crlf)
	;~ 				GUICtrlSetstate($LBL_CheckRepo,$GUi_hide)
					GUICtrlSetBkColor($LBL_CheckRepo,_color("lightblue"))
					return "   No repo files to update"
			EndSwitch
		endif
	EndFunc
	Func _GetRepoFiles($RepoPath,$RepoType)
		ConsoleWrite('++_GetRepoFiles() = '& @crlf)
;~ 		$RepoPath='https://filegodmode.azurewebsites.net/repo'
;~ 		$RepoPath='http://acnalert.cloudapp.net/FGM/ProjectRepo'
		; ----  LOCAL  ---------
		if $RepoType="local" then
			Local $filesArr = _FileListToArray($RepoPath, "*.db",1)
			If @error = 1 Then
				ConsoleWrite("!!!!!! Path was invalid." & @crlf)
				return 2
			EndIf
			If @error = 4 Then
				ConsoleWrite("!!!!!! No file(s) were found.")
				return 1
			EndIf
			_printfromarray($filesArr)
			local $files[1][4]
			for $i=0 to UBound($filesArr)-1
				;file names
					$files[$i][0]=StringStripWS($filesArr[$i],1+2)
				;file date
					$fres=FileGetTime($RepoPath&"\"&$filesArr[$i],0,1)
					$files[$i][1] = _Date_Time_Convert($fres,"yyyyMMddHHmmss", "yyyy/MM/dd HH:mm")
					$files[$i][3] = StringReplace($fres,"*","0")
				;file sizes
					$files[$i][2]=FileGetSize($RepoPath&"\"&$filesArr[$i])
				redim $files[$i+2][4]
			next
			_ArrayDelete($files,UBound($files)-1)
			_ArrayDelete($files,0)
			_printfromarray($files)
			return $files
		endif
		; ----   SMB   ---------
		if $RepoType="smb" then
			$RepoPath=_ReplaceIfLocalhost($repoPath)
			Local $filesArr = _FileListToArray($RepoPath, "*.db",1)
			If @error = 1 Then
				ConsoleWrite("Path was invalid." & @crlf)
				return 2
			EndIf
			If @error = 4 Then
				ConsoleWrite("No file(s) were found.")
				return 1
			EndIf
			_printfromarray($filesArr)
			local $files[1][4]
			for $i=0 to UBound($filesArr)-1
				;file names
					$files[$i][0]=StringStripWS($filesArr[$i],1+2)
				;file date
					$fres=FileGetTime($RepoPath&"\"&$filesArr[$i],0,1)
					$files[$i][1] = _Date_Time_Convert($fres,"yyyyMMddHHmmss", "yyyy/MM/dd HH:mm")
					$files[$i][3] = StringReplace($fres,"*","0")
				;file sizes
					$files[$i][2]=FileGetSize($RepoPath&"\"&$filesArr[$i])
				redim $files[$i+2][4]
			next
			_ArrayDelete($files,UBound($files)-1)
			_ArrayDelete($files,0)
			_printfromarray($files)
			return $files
		endif
		; ----   http   ---------
		if $RepoType="http" then
			$RepoPath=_ReplaceIfLocalhost($repoPath)
			$LinesArrS=""
			Local $sData = InetRead($RepoPath,1)
			Local $err=@error
			if $err then
				return 0
			else
				Local $nBytesRead = @extended
				ConsoleWrite('$nBytesRead = ' & $nBytesRead & @crlf )
				local $files[1][4]
				$LinesArrDformat="empty $LinesArrDformat"
				$rawData=BinaryToString($sData)
				;filter the wanted files
					$rawData=StringReplace($rawData,'<br>',@crlf)
					$rawData=StringReplace($rawData,'</td>',@crlf)
					$LinesArrF=StringRegExp($rawData,'(>.*\.db</)',3)
					$LinesArrD=StringRegExp($rawData,'[0-9]{1,2}[/][0-9]{1,2}[/][0-9]{2,4}',3)
					if IsArray($LinesArrD) then
						$LinesArrDformat="M/d/yyyy"
					Else
						$LinesArrD=StringRegExp($rawData,'[0-9]{2,4}[-][0-9]{1,2}[-][0-9]{1,2}',3)
						$LinesArrDformat="yyyy-mm-dd"
					endif
					$LinesArrS=StringRegExp($rawData,'\s+[0-9]*\s+[<]{1}[Aa]{1}',3)
					if IsArray($LinesArrS) then
					Else
						$LinesArrS=StringRegExp($rawData,'[0-9.]+[KMG]',3)
					endif
				for $i=0 to UBound($LinesArrF)-1
					;file names
						$fileNameArr=StringSplit($LinesArrF[$i],"<>")
						$files[$i][0]=$fileNameArr[UBound($fileNameArr)-2]
					;file date
						Switch $LinesArrDformat
							case "M/d/yyyy"
								$fres= _Date_Time_Convert(StringStripWS($LinesArrD[$i],1+2), "M/d/yyyy HH:mm:ss", "yyyy/MM/dd HH:mm")
								$files[$i][1] = StringReplace($fres,"*","0")
								$fres= _Date_Time_Convert(StringStripWS($LinesArrD[$i],1+2), "M/d/yyyy HH:mm:ss", "yyyyMMddHHmmss")
								$files[$i][3] = StringReplace($fres,"*","0")
							case "yyyy-mm-dd"
								$fres= _Date_Time_Convert(StringStripWS($LinesArrD[$i],1+2), "yyyy/MM/dd HH:mm:ss", "yyyy/MM/dd HH:mm")
								$files[$i][1] = StringReplace($fres,"*","0")
								$fres= _Date_Time_Convert(StringStripWS($LinesArrD[$i],1+2), "yyyy/MM/dd HH:mm:ss", "yyyyMMddHHmmss")
								$files[$i][3] = StringReplace($fres,"*","0")
							case else
								MsgBox(4096,"Error _GetRepoFiles" , "Report this to marcelo. this error shouldnt happen. Error _GetRepoFiles($RepoPath,$RepoType)." & _
									  $LinesArrDformat &  @CRLF & "Err.2060" ,0)
						EndSwitch
					;file sizes
						$fileSize=_ToBytes($LinesArrS[$i])
						$files[$i][2]=StringStripWS($fileSize,1+2)
					redim $files[$i+2][4]
				next
				_ArrayDelete($files,UBound($files)-1)
				if IsArray($files) then
					return $files
				Else
					return 1
				EndIf
			endif
		endif
		MsgBox(4096,"Error _GetRepoFiles" , "Report this to marcelo. this error shouldnt happen. Error _GetRepoFiles($RepoPath,$RepoType)." & _
			 " $RepoPath = " & $RepoPath & "  $RepoType = " & $RepoType & @CRLF & "Err.2020" ,0)
		exit
	EndFunc
	Func _UpdatePrjDBfromRepo($RepoProjectDBRepoPath,$RepoProjectDBLocalPath,$filename,$RepoType)
		ConsoleWrite('++_UpdatePrjDBfromRepo() = '&$RepoProjectDBRepoPath&"/"&$filename& @crlf)
		$RepoProjectDBRepoPathfile=$RepoProjectDBRepoPath&"/"&$filename
		$RepoProjectDBLocalPathFile=$RepoProjectDBLocalPath&"\"&$filename
		GUICtrlSetData($LBL_CheckRepo,"      Downloading Project Database repository ")
		; ----   LOCAL ---------
		if $RepoType="local" then
			If FileExists($RepoProjectDBRepoPathfile) Then ;$FGM project database download
				Local $size = FileGetSize($RepoProjectDBRepoPathfile)
				Local $hDownload =FileCopy($RepoProjectDBRepoPathfile,$tempdir&"\"&$filename,1)
			EndIf
		endif
		; ----   SMB   ---------
		if $RepoType="smb" then
			If FileExists($RepoProjectDBRepoPathfile) Then ;$FGM project database download
				Local $size = FileGetSize($RepoProjectDBRepoPathfile)
				Local $hDownload =FileCopy($RepoProjectDBRepoPathfile,$tempdir&"\"&$filename,1)
			EndIf
		endif
		; ----   HTTP  ---------
		if $RepoType="http" then
			Local $size = InetGetSize($RepoProjectDBRepoPathfile)
			Local $hDownload =InetGet($RepoProjectDBRepoPathfile,$tempdir&"\"&$filename,1,1)
			Local $aData = InetGetInfo($hDownload)
			Local $begin = TimerInit()
			Do
				Local $BytesDownloaded = INetGetInfo($hDownload, 0)
				Local $FileProgress = Floor(($BytesDownloaded / $size) * 100)
				Sleep(250)
				if TimerDiff($begin)>300000 then exitloop  ; 300 seconds of timeout
				Until InetGetInfo($hDownload, 2)
			if InetGetInfo($hDownload, 3)=False then
				MsgBox(4096,"Project DataBase Version update" , "Error while Downloading Project DataBase from Repository. " & @CRLF & _
						"The File " & $filename & " cannot be downloaded."  & @CRLF & " Try again Later." & @CRLF & "Err.2018" ,0)
				_WinHttpCloseHandle($hDownload)
				return false
			endif
			InetClose($hDownload)
			_WinHttpCloseHandle($hDownload)
		EndIf
		; ----------------------

		; ---  copy file from temp to apdata
		if FileExists($tempdir& "\"&$filename) and FileGetSize($tempdir&"\"&$filename)=$size and FileGetSize($tempdir&"\"&$filename)<>0 then
			if FileExists($RepoProjectDBLocalPathFile) Then
				$r=filedelete($RepoProjectDBLocalPathFile)
			endif
			$r=FileCopy($tempdir&"\"&$filename,$RepoProjectDBLocalPath,1)
			If $r=1 Then
				_UpdatePrjDBprofile($RepoProjectDBLocalPathFile)
				return true
			Else
				MsgBox(4096,"Project DataBase Version update" , "Error while updating Project DataBase from Repository. " & @CRLF & _
						"The File " & $filename & " cannot de copied into "&$RepoProjectDBLocalPath & @CRLF & _
						" Try again Later." & @CRLF & "Err.2017" ,0)
				return false
			endif
		Else
			MsgBox(4096,"Project DataBase Version update" , "Error while updating Project DataBase from Repository. " & @CRLF & _
					"The File " & $filename & " remote size of " & FileGetSize($tempdir&"\"&$filename)  & " and  downloaded sizeof " & $size & _
					" on DIR " & $tempdir & " created an exception." & @CRLF & _
					" Try again Later." & @CRLF & "Err.2016" ,0)
			return false
		EndIf
	EndFunc
	Func _ReturnSentence_CkeckUpdatePrjDBRepoFiles($sentence,$returnsentence)
;~ 		ConsoleWrite('++_ReturnSentence_CkeckUpdatePrjDBRepoFiles() = '& @crlf)
		if $returnsentence<>$sentence and $returnsentence<>""then
			if StringInStr($returnsentence,"Error")>0 then
				$returnsentence=" Some error @ _CkeckUpdatePrjDBRepoFiles()"
			Else
				$returnsentence=$sentence
			endif
		Else
			$returnsentence=$sentence
		endif
		return $returnsentence
	EndFunc
	Func _UpdatePrjDBprofile($db)
		ConsoleWrite('++_UpdatePrjDBprofile() = '& $db & @crlf)
		$query="SELECT value FROM Configuration WHERE config='FGMdatabase';"
		$value=_SQLITEgetUnit($query,$db)
		if $value then
			$query='INSERT OR REPLACE INTO Configuration VALUES ("FGMdatabase","' & $value & '","' & GetFileName($db) & '");'
			if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
				return 1
			Else
				MsgBox(48+4096,"Updating database error","An error updating the project database. ErrNo 2019" & @CRLF & $query,0,0)
				return 0
			EndIf
		Else
			return 0
		EndIf
	EndFunc
	Func _updateDefaultRepoFromINI()
		ConsoleWrite('++_updateDefaultRepoFromINI() = '& $INIfile & @crlf)
		$inetvar=_CheckInetConnection()
		if $inetvar=0 then
			ConsoleWrite('!! no inet connection'& @crlf)
			GUICtrlSetstate($LBL_noInet,$GUI_show)
		Else
			ConsoleWrite('!! OK inet connection'& @crlf)
			GUICtrlSetstate($LBL_noInet,$GUI_HIDE)
		endif
		$updateRepoOnLoad = IniRead($INIfile, "General", "updateRepoOnLoad", "0")
		if $updateRepoOnLoad then
			Local $var = IniReadSection($INIfile, "Repositories")
			If @error Then
				MsgBox(48+4096, "INI file error", "Error occurred, probably the FGM.INI file not readable. ErrNo 2040" & @CRLF & $INIfile)
				_LBL_noRepo_Show()
				return false
			Else
				if IsArray($var) then
					if $var[0][0]>1 then
						For $i = 1 To $var[0][0]
							ConsoleWrite( "Key: " & $var[$i][0] &'Value = ' & $var[$i][1]& @crlf )
							if _checkConnectionToRepo($var[$i][1]) then
								_LBL_okRepo_Show($var[$i][1])
								return true
							endif
							ConsoleWrite("! Bad RepoAddress from INI: "&$var[$i][1]& @crlf )
						Next
						_LBL_noRepo_Show()
						return false
					EndIf
				Else
					MsgBox(48+4096, "INI file error", "Error occurred, probably the section REPOSITORIES at FGM.INI file not configured or empty. ErrNo 2041" & @CRLF & $INIfile)
					_LBL_noRepo_Show()
					return false
				endif
			EndIf
		endif
	EndFunc
	Func _LBL_noRepo_Show()
		$msg_LBL_noRepo="Project repository cannot be reached."&@crlf& _
			"Configure the repository "&@crlf& '"Settings -> Application preferences"'
		GUICtrlSetData($LBL_noRepo,$msg_LBL_noRepo)
		GUICtrlSetColor($LBL_noRepo,_color("RED"))
		GUICtrlSetstate($LBL_noRepo,$GUI_show)
	EndFunc
	Func _LBL_okRepo_Show($srepo)
		$msg_LBL_noRepo="Connected to repository: " & $srepo
		GUICtrlSetData($LBL_noRepo,$msg_LBL_noRepo)
		GUICtrlSetColor($LBL_noRepo,_color("darkgreen"))
		GUICtrlSetstate($LBL_noRepo,$GUI_show)
	EndFunc
	Func _checkConnectionToRepo($repoPath)
		ConsoleWrite('++_checkConnectionToRepo() = '& $repoPath & @crlf)
		$RepoType=_RecognizeRepoType($repoPath)
		$repoArr=_GetRepoFiles($repoPath,$RepoType)
		if IsArray($repoArr) Then
			if UBound($repoArr)>1 then
				_printfromarray($repoArr)
				if _UpdateAppSettings("RepoAddress",$repoPath) and _UpdateAppSettings("RepoType", $RepoType) then
					ConsoleWrite("Updated RepoAddress from INI: "&$repoPath& @crlf )
					return true
				Else
					GUICtrlSetBkColor($TXT_settingspref_Repo, _color("lightRed"))
					$repoPath=_GetAppSettings("RepoAddress",$RepoProjectDBDefault,1)
					MsgBox(48+4096, "Error database update", "Error occurred while updating REPOADDRESS in database" & @crlf& _
					". ErrNo 2043" & @crlf& "default repository is set"  & @crlf&  "Repository address: " & $repoPath   )
					return false
				endif
			EndIf
			return false
		endif
		return false
	EndFunc
	Func _ReplaceIfLocalhost($repoPath)
		ConsoleWrite('++_ReplaceIfLocalhost() = '& $repoPath & @crlf)
		if StringInStr($repoPath,@ComputerName)>0 then
			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : @ComputerName = ' & @ComputerName & @crlf )
			$repoPath=StringRegExpReplace($repoPath,"(\A\\{2}[a-zA-Z0-9.]+\\{1})","\\\\localhost\\")
		endif
		return $repoPath
	EndFunc
	Func _checkRepo()  ; check the ini file and set the repository for the project database
		ConsoleWrite('++_checkRepo() = ' & @crlf)
		$repoPath=_GetAppSettings("RepoAddress",$RepoProjectDBDefault)
		if _checkConnectionToRepo($repoPath)=false then
			_updateDefaultRepoFromINI()
		endif
	EndFunc
	Func _verifyProjectsInProfileDB()
		ConsoleWrite('++_verifyProjectsInProfileDB() = '& @crlf )
		$query="SELECT key,value FROM Configuration WHERE config='FGMdatabase';"
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) Then
			if UBound($qryResult)>1 then
				For $iRows = 1 To UBound($qryResult,1)-1
					$prjname=$qryResult[$iRows][0]
					$filedb=$qryResult[$iRows][1]
					if FileExists($tempDir & "\"&$filedb) or FileExists($FgmDataFolder & "\"&$filedb) Then
					Else
						$query='DELETE FROM Configuration WHERE config="FGMdatabase" and value="'&$prjname&'" and key="'&$filedb&'" ;'
						_SQLITErun($query,$profiledbfile,$quietSQLQuery)
					EndIf
				next
			EndIf
		EndIf
	EndFunc
	Func _CheckSetProxy_InetRead()
		ConsoleWrite('++_CheckSetProxy_InetRead() = '& @crlf )
		;  next lines if using a proxy server		$GUI_UNCHECKED=4    $GUI_CHECKED=1
		$useproxy=_GetAppSettings("UseProxy",$GUI_UNCHECKED)
		if $GUI_CHECKED=$useproxy then
			Local $ProxyExceptions =""
			;set proxy
			if $GUI_UNCHECKED=_GetAppSettings("UseProxyIE",$GUI_UNCHECKED) then
				Local $proxyserver  = _GetAppSettings("ProxyHttp","http://proxyserver") ; add proxy server name
				Local $proxyport    = _GetAppSettings("ProxyPort","8080") ; add proxy server port
				Local $proxyuser    = _GetAppSettings("ProxyUser","") ; add proxy server name
				if $proxyuser="" then
					HttpSetProxy(2, $proxyserver&":"&$proxyport)   ; Use the proxy
					ConsoleWrite('!@@ Debug(' & @ScriptLineNumber & ') : $proxy = ' & $proxyserver&":"&$proxyport & @crlf )
				else
					$arrcred=StringSplit($proxyuser,"\")
					$pass=_get_passwd($arrcred[1],$arrcred[2])
					if $arrcred[1]="." then $proxyuser=$arrcred[2]
					HttpSetProxy(2, $proxyuser&":"&$pass&"@"&$proxyserver&":"&$proxyport)   ; Use the proxy
					ConsoleWrite('!@@ Debug(' & @ScriptLineNumber & ') : $proxy = ' & $proxyuser&":"&$pass&"@"&$proxyserver&":"&$proxyport & @crlf )
				endif

			Else
				HttpSetProxy(0)  ; Use IE defaults for proxy
			endif
		Else
			HttpSetProxy(1)   ; Use no proxy
		endif
	EndFunc
	Func _get_passwd($domain,$user)
;~ 		ConsoleWrite('++_get_passwd() = '& @crlf )
		$domainencripted=_Hashing($domain,0)
		$userencripted=_Hashing($user,0)
		$query='SELECT password FROM credentials WHERE  domain="'&$domainencripted&'" AND userID="'&$userencripted&'" ;'
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) then
			if  UBound($qryResult)>1 then
				$resv=_Hashing($qryResult[1][0],1)
				Return $resv
			endif
		endif
		Return ""
	EndFunc






