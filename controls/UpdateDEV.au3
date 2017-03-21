
	Func _checkVersion($direct=0)
		ConsoleWrite('++_checkVersion() = '& @crlf)
		If $direct=1 Then _UpdateVersion()
		GUICtrlSetBkColor($LBL_CheckUpdate,_color("red"))
		GUICtrlSetData($LBL_CheckUpdate,"   Ckecking for updates")
		$version= FileGetVersion(@ScriptName)
		GUICtrlSetstate($LBL_CheckUpdate,$GUI_Show)
		$remoteVersion=_CheckNewVersion()
		If Not @Compiled Then
			If $version="0.0.0.0" Then $version=$remoteVersion
		endif
		Select
			Case $remoteVersion="error"
				GUICtrlSetData($LBL_CheckUpdate,"  Error while Checking update")
				GUICtrlSetBkColor($LBL_CheckUpdate,_color("Red"))
			Case $remoteVersion="No data"
				GUICtrlSetData($LBL_CheckUpdate,"   Unable to check update " )
				GUICtrlSetBkColor($LBL_CheckUpdate,_color("Red"))
			Case $remoteVersion="NoConnection" Or $remoteVersion="NoAnswer"
				GUICtrlSetData($LBL_CheckUpdate,"   No Connection while Checking update")
				GUICtrlSetBkColor($LBL_CheckUpdate,_color("Red"))
			Case $version=$remoteVersion
				GUICtrlSetData($LBL_CheckUpdate,"   Running last version " & $version)
				GUICtrlSetBkColor($LBL_CheckUpdate,_color("Green"))
			Case StringStripWS($version,3)<>StringStripWS($remoteVersion,3)
				GUICtrlSetData($LBL_CheckUpdate,"   New version " & $remoteVersion & " available")
				GUICtrlSetBkColor($LBL_CheckUpdate,_color("Orange"))
				If _AreYouSureYesNo("New version available." & @CRLF & "Do you want to update to last version?") Then
					_UpdateVersion()
				endif
			Case Else
				GUICtrlSetData($LBL_CheckUpdate," -> Unable to check update " & $remoteVersion)
		endselect
	EndFunc
	Func _CheckNewVersion()
		ConsoleWrite('++_CheckNewVersion() = '& @crlf)
		$sCommand=$FgmDataFolder & "\versionChecker.exe dev"
		$versionHelper=_GetDOSOutput($sCommand)
		ConsoleWrite('_CheckNewVersion $versionHelper = ' & $versionHelper & @crlf )
		If @error = 0 Then
			return $versionHelper
		else
			return "error"
		EndIf
	EndFunc
;~ 	Func _CheckNewVersion()
;~ 			$sURL="Http://" & $WebServiceaddr & "/?VP=T"
;~ 			ConsoleWrite(') : $sURL = ' & $sURL & @crlf)
;~ 			$oXHR = ObjCreate("MSXML2.XMLHTTP.6.0")
;~ 			$oXHR.open("GET", $sURL, False)
;~ 			$oXHR.send()
;~ 			If @error = 0 Then
;~ 				$versionpath = $oXHR.responseText
;~ 				$oXHR.responseText="1.0.0.0"
;~ 				$versionpath =ClearEmptyLines($versionpath)
;~ 				If StringInStr($versionpath,"FileVersion")>0 Then
;~ 					$fversionArr=StringSplit($versionpath,"FileVersion",1)
;~ 					_printfromarray($fversionArr)
;~ 					If $fversionArr<>"" Then return $fversionArr[2]
;~ 				endif
;~ 				return "No data"
;~ 			else
;~ 				return "error"
;~ 			EndIf
;~ 	EndFunc
	Func _UpdateVersion()
		$handle_write = FileOpen($tempDir & "\temp.tgm", 2)   ; record  script folderb
		FileWriteLine($handle_write,$version&"::" & @ScriptDir&"::" & @ScriptName)
		FileClose($handle_write)
		$correWD=Run($FGMDataFolder & "\FGMupdater.exe")
		if $correWD<>0 then
			exit
		endif
	EndFunc
	func  ClearEmptyLines($iResponse)
		$elements=StringSplit($iResponse,@crlf)
		$totalline=""
		For $e=1 to $elements[0]
			if StringStripWS($elements[$e],3)<>"" then
				$totalline&=StringStripWS($elements[$e],3) & @crlf
			endif
		next
		return $totalline
	endfunc
	Func _CheckIfUpgraded()
		ConsoleWrite('++_CheckIfUpgraded() = '& @crlf)
		If Not FileExists($tempDir & "\temp.tgm") Then _MarkUpdated("UpdateDB")
		$handle_read = FileOpen($tempDir & "\temp.tgm", 0)
		If $handle_read = -1 Then
			ConsoleWrite('!!!!!!!!!Unable to open file '& $tempDir & "\temp.tgm" & @crlf)
			Return true
		endif
		$line = FileReadLine($handle_read , 1)
		FileClose($handle_read)
		$linearr =StringSplit($line,"::",1)
		If $linearr[1]="UpdateDB" Then
			Return True
		Else
			Return False
		endif
	EndFunc
	Func _MarkUpdated($status)
		$handle_write = FileOpen($tempDir & "\temp.tgm", 2)
		FileWriteLine($handle_write,$status&"::" & @ScriptDir&"::" & @ScriptName)
		FileClose($handle_write)
	EndFunc

