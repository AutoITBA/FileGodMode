Func _ZIP_DDFinit($ZipFileName)
	ConsoleWrite('++_ZIP_DDFinit() = '& @crlf)
	$fileh=FileOpen($tempdir&"\derectives.ddf",2+8)
	If $fileh = -1 Then
		MemoWrite($iMemo,@TAB&"*************  An Error occurred , Unable to create DDF directives file.********* "  & @crlf,"Red",8,1)
		return false
	EndIf

	FileWriteLine($fileh, ";  *** Source Code MakeCAB Directive file autogenerated by FileGodMode ***"&@crlf&";"&@crlf&" .OPTION EXPLICIT                 ; Generate errors")
	FileWriteLine($fileh, ";  No limits for the cabinet file"&@crlf&" .Set CabinetFileCountThreshold=0"&@crlf&" .Set FolderFileCountThreshold=0"& _    ; no file limits
							@crlf&" .Set FolderSizeThreshold=0"&@crlf&" .Set MaxCabinetSize=0"&@crlf& _
							" .Set MaxDiskFileCount=0"&@crlf&" .Set MaxDiskSize=0"&@crlf&""&@crlf)
	FileWriteLine($fileh, ";  Cabinet general options"&@crlf&" .Set Cabinet=on"&@crlf&" .Set Compress=on"&@crlf& _
							" .Set UniqueFiles=OFF"&@crlf&" .set DiskDirectoryTemplate=CDROM  ; All cabinets in a single directory" &@crlf& _
							" .Set CompressionType=MSZIP        ; All files are compressed in cabinet files"&@crlf&""&@crlf)
	FileWriteLine($fileh, ";  Cabinet file options"&@crlf&" .Set CabinetNameTemplate="&$ZipFileName& _
							"  ;CabinetNameTemplate is the name of the output CAB file")
	FileWriteLine($fileh, " .set RptFileName="&$ZipReportFileName)
	FileClose($fileh)
	return true
EndFunc
Func _ZIP_DDFBase($SourcePath,$DestinationPath,$structure=1,$basefolder="")
	ConsoleWrite('++_ZIP_DDFBase() = '& @crlf)
	$fileh=FileOpen($tempdir&"\derectives.ddf",1)
	If $fileh = -1 Then
		MemoWrite($iMemo,@TAB&"*************  An Error occurred , Unable to add activity directives to DDF file. ********* "  & @crlf,"Red",8,1)
		return false
	EndIf
	FileWriteLine($fileh, ";  ************* Zip activity ***************"&@crlf&"")
	FileWriteLine($fileh, ";  init activity options"&@crlf&" .Set SourceDir="&$SourcePath&@crlf&" .set DiskDirectory1="&$DestinationPath&@crlf&""&@crlf)
	if $structure=0 then FileWriteLine($fileh, " .Set DestinationDir="&$basefolder )
	FileClose($fileh)
	return true
EndFunc
Func _ZIP_DDFFilesInfo($SourcePath,$DestinationPath,$FilesArray,$structure=1)
	ConsoleWrite('++_ZIP_DDFFilesInfo() = '& @crlf)
	$fileh=FileOpen($tempdir&"\derectives.ddf",1)
	If $fileh = -1 Then
		MemoWrite($iMemo,@TAB&"*************  An Error occurred , Unable to add activity files to DDF file. ********* "  & @crlf,"Red",8,1)
		return false
	EndIf
	for $i=1 to $FilesArray[0]
		$Dirfile2zip=StringReplace($FilesArray[$i],$SourcePath,"")

		$DestinationDir=""
		if $structure=1 then
			$file2zipArr=_SplitDirFile2Zip($Dirfile2zip)
			$DestinationDir=$file2zipArr[1]
			FileWriteLine($fileh," .Set DestinationDir="&$DestinationDir )
		endif

		$Dirfile2zip4ddf=StringTrimLeft($Dirfile2zip,1)
		FileWriteLine($fileh,@tab&' "'&$Dirfile2zip4ddf &'"')
	next
	FileClose($fileh)
	return true
EndFunc
Func _ZIP_DDFrun()
	ConsoleWrite('++_ZIP_DDFrun() = '& @crlf)

	$ZipReportFileNamH=FileOpen($ZipReportFileName,2)
	If $ZipReportFileNamH = -1 Then
		MemoWrite($iMemo,@TAB&"*************  An Error occurred , Unable to open Log file "&$ZipReportFileName&" ********* "  & @crlf,"Red",8,1)
		return false
	EndIf
	FileClose($ZipReportFileNamH)
	Switch @OSArch
		Case "X32"
			$makecabVer = "makecab32.exe"
		Case "X64"
			$makecabVer = "makecab64.exe"
	EndSwitch
	$sCommand=$FgmDataFolderResources&'\'&$makecabVer &' /F "' & $tempdir & '\derectives.ddf"'
	$var=_GetMakeCabOutput($sCommand)
	If StringInStr($var,"ERROR")>0 Then
		MemoWrite($iMemo, $var ,"Red",8,1)
		return false
	endif
	$ZipReportFileContent=_GetZipReportFileContent()
	if $ZipReportFileContent then
		If _IsChecked($CK_JobConsole_Verbose) then
			If StringInStr($ZipReportFileContent,"ERROR")>0 Then
				MemoWrite($iMemo, _clearEmptyLines($ZipReportFileContent) ,"Red",10,1)
				return false
			Else
				MemoWrite($iMemo, _clearEmptyLines($ZipReportFileContent) ,"Darkgreen",8,1)
				return true
			endif
		Else
			If StringInStr($ZipReportFileContent,"ERROR")>0 Then
				MemoWrite($iMemo,@TAB& $ZipReportFileContent & @crlf,"Red",10,1)
				return false
			endif
			$ZipReportFileContentArr=_clearEmptyLinesFromArray(StringSplit($ZipReportFileContent,@crlf))
			$iIndex =_ArraySearch($ZipReportFileContentArr,"Total files:",0,0,0,1)
			if $iIndex then
				MemoWrite($iMemo,@TAB& StringStripWS($ZipReportFileContentArr[$iIndex],1+2+4) & _
					@tab &@tab & StringStripWS($ZipReportFileContentArr[$iIndex+3],1+2+4) & _
					@tab &@tab & StringStripWS($ZipReportFileContentArr[$iIndex+4],1+2+4) ,"Darkgreen",8,1)
				return true
			Else
				MemoWrite($iMemo, _clearEmptyLines($ZipReportFileContent) & @crlf,"Red",10,1)
				return false
			endif
		endif
	Else
		return false
	endif
	return true
EndFunc
Func _GetZipReportFileContent()
	ConsoleWrite('++_GelZipReportFileContent() = '&$ZipReportFileName& @crlf)
	$ZipReportFileNamH=FileOpen($ZipReportFileName,0)
	If $ZipReportFileNamH = -1 Then
		MemoWrite($iMemo,@TAB&"*************  An Error occurred , Unable to open Log file "&$ZipReportFileName&" ********* "  & @crlf,"Red",8,1)
		return false
	EndIf
	$ZipReportFileContent=""
	for $ik=2 to 1000000
		$line= FileReadLine($ZipReportFileNamH,$ik)
		 If @error = -1 Then ExitLoop
		 $ZipReportFileContent =$ZipReportFileContent&@crlf&@TAB&$line
	next
	FileClose($ZipReportFileNamH)
	return $ZipReportFileContent
EndFunc
Func _GetMakeCabOutput($sCommand)
	ConsoleWrite('++_GetMakeCabOutput $sCommand = ' & $sCommand & @crlf )
	Local $iPID, $sOutput = "", $flagFlush=0, $writeInline=1 , $lastnumber=0
	$iPID = Run('"' & @ComSpec & '" /c ' & $sCommand, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	While 1
		$StdoutRead=StdoutRead($iPID, False, False)
		If @error Then ExitLoop
		$sOutput &= $StdoutRead
		if StringStripWS($StdoutRead,3)<>"" then
			$line=StringSplit($StdoutRead,@crlf)
			_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"Compresing "&$line[1], 1)
		endif
		Sleep(10)
	WEnd
	_GUICtrlStatusBar_SetText($STS_JobConsole_StatusBar,"", 1)
	$sOutput=_cleanOutputDosFile($sOutput)
	Return $sOutput
EndFunc   ;==>_GetDOSOutput
Func _cleanOutputDosFile($sOutput)
	ConsoleWrite('++_cleanOutputDosFile() = '& @crlf)
	local $resultOutput=""
	$outArr=StringSplit($sOutput,@crlf)
	for $ik=1 to $outArr[0]
		if StringStripWS($outArr[$ik],3)<>""  then
			if StringInStr($outArr[$ik],"%")=0 and StringInStr($outArr[$ik],"Cabinet Maker")=0	then
				$resultOutput=$resultOutput&@crlf&@tab&$outArr[$ik]
			endif
		endif
	next
	return $resultOutput
EndFunc
Func _SplitDirFile2Zip($file2zip)
;~ 	ConsoleWrite('++_SplitDirFile2Zip() = '& @crlf)
	$remote=0
	dim $res[2]
	If StringRegExp($file2zip,"\A\\{2}") then $remote=1
	$arr=StringSplit($file2zip,"\/")
	$res[0]=$arr[$arr[0]]
	$resconcat=""
	for $i=1 to $arr[0]-1
		$resconcat=$resconcat&"\"&$arr[$i]
	next
	$resconcat=StringTrimLeft($resconcat,2)
	$res[1]=$resconcat
	return $res
EndFunc
