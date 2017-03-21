#include-once
;;; Start COM error Handler
;=====
; if a COM error handler does not already exist, assign one
If Not ObjEvent("AutoIt.Error") Then
    ; MUST assign this to a variable
    Global Const $_Zip_COMErrorHandler = ObjEvent("AutoIt.Error", "_Zip_COMErrorFunc")
EndIf
Func _IsFullPath($sPath)
;~ 	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sPath = ' & $sPath & @crlf )
    If StringInStr($sPath, ":\") Or  StringInStr($sPath, "\\")  Then
        Return True
    Else
        Return False
    EndIf
EndFunc   ;==>_IsFullPath

Func _Zip_CreateTempDir()
    Local $s_TempName
    Do
        $s_TempName = ""
        While StringLen($s_TempName) < 7
            $s_TempName &= Chr(Random(97, 122, 1))
        WEnd
        $s_TempName = $tempDir & "\~" & $s_TempName & ".tmp"
    Until Not FileExists($s_TempName)
    If Not DirCreate($s_TempName) Then Return SetError(1, 0, 0)
    Return $s_TempName
EndFunc   ;==>_Zip_CreateTempDir
Func _Zip_CreateTempName()
	Return "desktop.ini"
    Local $GUID = DllStructCreate("dword Data1;word Data2;word Data3;byte Data4[8]")
    DllCall("ole32.dll", "int", "CoCreateGuid", "ptr", DllStructGetPtr($GUID))
    Local $ret = DllCall("ole32.dll", "int", "StringFromGUID2", "ptr", DllStructGetPtr($GUID), "wstr", "", "int", 40)
    If @error Then Return SetError(1, 0, "")
    Return StringRegExpReplace($ret[2], "[}{-]", "")
EndFunc   ;==>_Zip_CreateTempName
Func _Zip_AddPath($sZipFile, $sPath,$sFileName="",$filePathtoadd="",$flag = 1)
	ConsoleWrite('================= _Zip_AddPath ==================================== '& @crlf )
	ConsoleWrite('$sZipFile = ' & $sZipFile & @crlf )
	ConsoleWrite('$sPath = ' & $sPath & @crlf )
	ConsoleWrite('$sFileName = ' & $sFileName & @crlf )
	ConsoleWrite('$filePathtoadd = ' & $filePathtoadd & @crlf )

	#region check dll
		Local $DLLChk = _Zip_DllChk()
		If $DLLChk <> 0 Then
			ConsoleWrite("no dll " & @crlf)
			MsgBox(0,"no dll ","no dll ",0)
			Return SetError($DLLChk, 0, 50);
		endif
	#endregion
	#region check parameters
		If not _IsFullPath($sZipFile) then
			ConsoleWrite('zip file isn t a full path ' & @crlf)
			Return SetError(2,0,2)
		endif
		If Not FileExists($sZipFile) Then
			ConsoleWrite("no zip file " & @crlf)
			Return SetError(3, 0, 3) ;
		endif
	#endregion
;~     Local $oNS = _Zip_GetNameSpace($sZipFile)
	$oApp = ObjCreate("Shell.Application")
    Local $oNS = $oApp.NameSpace($sZipFile)
    If Not IsObj($oNS) Then
		ConsoleWrite("no object " & @crlf)
		Return SetError(4, 0, 0)
	endif
	ConsoleWrite("@@ 24 " & @crlf)
    ; check and create directory structure
    $sPath = _Zip_PathStripSlash($sPath)
    Local $sNewPath = "";, $sFileName = "" ; -------------------------------
    If $sPath <> "" Then
        Local $aDir = StringSplit($sPath, "\"), $oTest
		_printfromarray($aDir)
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $aDir[0] = ' & $aDir[0] & @crlf )
        For $i = 1 To $aDir[0]
			; check if item already exists
            $oTest = $oNS.ParseName($aDir[$i])
			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $aDir[$i] = ' & $aDir[$i] & @crlf )
            If IsObj($oTest) Then
				ConsoleWrite('>@@ 1' & @crlf )
                ; check if folder
                If Not $oTest.IsFolder Then Return SetError(5, 0, 0)
				ConsoleWrite('>@@ 1.5' & @crlf )
                ; get next namespace level
                $oNS = $oTest.GetFolder
            Else
				ConsoleWrite('>@@ 2' & @crlf )
                ; create temp dir
                Local $sTempDir = _Zip_CreateTempDir()
                If @error Then Return SetError(6, 0, 0)
                Local $oTemp = _Zip_GetNameSpace($sTempDir)
                ; create the directory structure
                For $i = $i To $aDir[0]
                    $sNewPath &= $aDir[$i] & "\"
                Next
                DirCreate($sTempDir & "\" & $sNewPath)
				If $sFileName="" Then  $sFileName = _Zip_CreateTempName() ; ----------------------------------------------------
				$sNewPathDir=$sNewPath
                $sNewPath &= $sFileName
				FileClose(FileOpen($sTempDir & "\" & $sNewPath, 2 + 8))
;~ 				If $flag = 1 Then
;~ 					$oNS.CopyHere($oTemp.Items())
;~ 				Else
					$oNS.CopyHere($oTemp.Items(),4)
;~ 				endif
                ; wait for file
				$oAppwait = ObjCreate("Shell.Application")
				ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sZipFile = ' & $sZipFile & @crlf )
				ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sNewPath = ' & $sNewPathDir & @crlf )
				$rcount=0
                Do
					$rcount=$oAppwait.NameSpace($sZipFile).Items.Count
					ConsoleWrite('==> $rcount     = ' & $rcount & @crlf )
					ConsoleWrite('---$= ' & $sNewPathDir&$sNewPath & @crlf )
                    Sleep(250)
                Until $rcount>0
;~                 _DeleteDIR($sTempDir,1,0)
;~ 				_Zip_DeleteItem($sZipFile, $sZipFile&"\"&$sNewPath)
				If @error Then Return SetError(12, 0, 0)
            EndIf
        Next
    EndIf
;~     Return 1
    Return $sFileName
EndFunc   ;==>_Zip_AddPath
; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_Count
; Description....:  Count items in the root of a ZIP archive (not recursive)
; Syntax.........:  _Zip_Count($sZipFile)
; Parameters.....:  $sZipFile   - Full path to ZIP file
; Return values..:  Success     - Item count
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file does not exist
; ==============================================================================================================
Func _Zip_Count1($sZipFile)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    Local $oNS = _Zip_GetNameSpace($sZipFile)
    If Not IsObj($oNS) Then
		ConsoleWrite(' _Zip_Count($sZipFile) = Error' & @crlf )
		Return SetError(4, 0, 0)
	endif
    Return $oNS.Items().Count
EndFunc   ;==>_Zip_Count
Func _Zip_Count($hZipFile,$hZipfileFolder="")
	ConsoleWrite('========== _Zip_Count ==========  $hZipFile = ' & $hZipFile & @crlf )
	ConsoleWrite('========== _Zip_Count ==========  $hZipfileFolder= ' & $hZipfileFolder & @crlf )
	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
	ConsoleWrite('==========   _Zip_Count ====================================21' & @crlf )
	If Not FileExists($hZipFile) Then
		ConsoleWrite('file no exist=' &$hZipFile& @crlf )
		Return SetError(1, 0, 0) ;no zip file
	endif
	ConsoleWrite('==========   _Zip_Count ====================================22' & @crlf )
	If $hZipfileFolder="" Then $hZipfileFolder=$hZipFile
	$items = _Zip_List($hZipfileFolder)
	_printfromarray($items)
	Return UBound($items) - 1
EndFunc   ;==>_Zip_Count
Func _Zip_List($hZipFile)
	ConsoleWrite('==========   _Zip_List ====================================' & $hZipFile & @crlf )
	local $aArray[1]
;~ 	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
;~ 	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	ConsoleWrite('==========   _Zip_List ====================================1' & @crlf )
	$oApp = ObjCreate("Shell.Application")
	$hList = $oApp.Namespace($hZipFile).Items
	ConsoleWrite('==========   _Zip_List ====================================2' & @crlf )
	For $item in $hList
		_ArrayAdd($aArray,$item.name)
	Next
	$aArray[0] = UBound($aArray) - 1
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $aArray[0] = ' & $aArray[0] & @crlf )
	Return $aArray
EndFunc   ;==>_Zip_List
Func _Zip_List1($sZipFile)
	ConsoleWrite('==========   _Zip_List ====================================' & $sZipFile & @crlf )
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
	ConsoleWrite('==========   _Zip_List ====================================1' & @crlf )
    Local $oNS = _Zip_GetNameSpace($sZipFile)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
	ConsoleWrite('==========   _Zip_List ====================================2' & @crlf )
    Local $aArray[1] = [0]
    Local $oList = $oNS.Items()
    For $oItem In $oList
        $aArray[0] += 1
        ReDim $aArray[$aArray[0] + 1]
        $aArray[$aArray[0]] = $oItem.Name
    Next
    Return $aArray
EndFunc   ;==>_Zip_List
; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_Create
; Description....:  Create empty ZIP archive
; Syntax.........:  _Zip_Create($sFileName[, $iOverwrite = 0])
; Parameters.....:  $sFileName  - Name of new ZIP file
;                   $iOverwrite - [Optional] Overwrite flag (Default = 0)
;                               | 0 - Do not overwrite the file if it exists
;                               | 1 - Overwrite the file if it exists
;
; Return values..:  Success     - Name of the new file
;                   Failure     - 0 and sets @error
;                               | 1 - A file with that name already exists and $iOverwrite flag is not set
;                               | 2 - Failed to create new file
; ===============================================================================================================
Func _Zip_Create($sFileName, $iOverwrite = 0)
    If FileExists($sFileName) And Not $iOverwrite Then Return SetError(1, 0, 0)
;~ 	MsgBox(0,"zip create $sFileName",$sFileName,0)
    Local $hFp = FileOpen($sFileName, 2 + 8 + 16)
    If $hFp = -1 Then Return SetError(2, 0, 0)
    FileWrite($hFp, Binary("0x504B0506000000000000000000000000000000000000"))
    FileClose($hFp)
    Return $sFileName
EndFunc   ;==>_Zip_Create
;===============================================================================
;
; Function Name:    _Zip_AddFile()
; Description:      Add a file to a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$hFile2Add - Complete path to the file that will be added
;					$flag = 1
;					- 0 ProgressBox
;					- 1 no progress box
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
;                   On Failure - Returns False
; Author(s):        torels_
; Notes:			The return values will be given once the compressing process is ultimated... it takes some time with big files
;
;===============================================================================
Func _Zip_AddFile2($hZipFile,$hFile2Add, $hFile2Rename, $sDestDir="",$flag = 1)
	ConsoleWrite('==========   _Zip_AddFile ====================================' & @crlf )
	ConsoleWrite('$hZipFile = ' & $hZipFile & @crlf )
	ConsoleWrite('$hFile2Add = ' & $hFile2Add & @crlf )
	ConsoleWrite('$hFile2Rename = ' & $hFile2Rename & @crlf )
	ConsoleWrite('$sDestDir = ' & $sDestDir & @crlf )
	#region check dll
		Local $DLLChk = _Zip_DllChk()
		If $DLLChk <> 0 Then
			ConsoleWrite("no dll " & @crlf)
			MsgBox(0,"no dll ","no dll ",0)
			Return SetError($DLLChk, 0, 50);
		endif
	#endregion
	#region check parameters
		If not _IsFullPath($hZipFile) then
			ConsoleWrite('zip file isn t a full path ' & @crlf)
			Return SetError(2,0,2)
		endif
		If Not FileExists($hZipFile) Then
			ConsoleWrite("no zip file " & @crlf)
			Return SetError(3, 0, 3) ;
		endif

		If not _IsFullPath($hFile2Add) then
			ConsoleWrite('orig file isn t a full path ' & @crlf)
			Return SetError(4,0,4)
		endif
		If Not FileExists($hFile2Add) Then
			ConsoleWrite("no orig file " & @crlf)
			Return SetError(5, 0, 5) ;
		endif

	#endregion
	#region prepare variables
		; clean paths
;~     $sItem = _Zip_PathStripSlash($sItem)
		$sDestDir = _Zip_PathStripSlash($sDestDir)
		$destination=_Zip_PathStripSlash($hZipFile&"\"&$sDestDir)
		Local $files = _Zip_Count($hZipFile,$hZipFile&"\"&$sDestDir)

		$oApp = ObjCreate("Shell.Application")
		$sTempDir = _Zip_CreateTempDir()
	#endregion
	#region copy to local tempdir
		$Fcount=1
		do
			FileCopy($hFile2Add,$sTempDir&"\"&$hFile2Rename,1+8)
			If FileExists($sTempDir&"\"&$hFile2Rename) Then ExitLoop
			$Fcount +=1
			ConsoleWrite('$Fcount1 = ' & $Fcount & @crlf )
		Until $Fcount<10
		If $Fcount>9 Then Return SetError(6,0,6)
	#endregion
	#region  check if copyed to temp dir
		$Fcount=1
		Do
			Local $fil=FileOpen($sTempDir&"\"&$hFile2Rename,0)
			If $fil = -1 Then MsgBox(0, "Error", "Unable to open file.")
			FileClose($fil)
			$Fcount +=1
			ConsoleWrite('$Fcount2 = ' & $Fcount & @crlf )
		Until $Fcount<10
		If $Fcount>9 Then Return SetError(7,0,7)
	#endregion
;~ 	$progresso=1
;~ 	If $flag = 1 Then

;~ ConsoleWrite('@@--- $destination = ' & $destination & @crlf )

;~ 	Else
;~ 		$copy = $oApp.NameSpace($hZipFile&"\"&$sDestDir).CopyHere('"',$sTempDir&'\'&$hFile2Rename&'"',4);,4+8+512+1024+2048)
;~ 	endif
	#region Add file to ZIP
		$err=1
		$Fcount=1
		Do
			If $flag = 1 then _Hide()
			If $err Then
				If $sDestDir="" Then
					ConsoleWrite('>> 0 << ' & @crlf )
					ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sTempDir&''\''&$hFile2Rename = ' & $sTempDir&'\'&$hFile2Rename & @crlf )
					$copy = $oApp.NameSpace($hZipFile).CopyHere($sTempDir&'\'&$hFile2Rename)
					$err=@error
					ConsoleWrite('$sTempDir&''\''&$hFile2Rename = ' & $sTempDir&'\'&$hFile2Rename & @crlf )
					$rcount=$oApp.NameSpace($hZipFile&"\"&$sDestDir).Items.Count
					ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $rcount = ' & $rcount & @crlf )
					If _Zip_ItemExists($hZipFile, $sTempDir&'\'&$hFile2Rename) Then $err=0
				Else
					ConsoleWrite('>> 1 << ' & @crlf )
					ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sTempDir&''\''&$hFile2Rename = ' & $sTempDir&'\'&$hFile2Rename & @crlf )
					$copy = $oApp.NameSpace($hZipFile&"\"&$sDestDir).CopyHere($sTempDir&'\'&$hFile2Rename)
					$err=@error
					$rcount=$oApp.NameSpace($hZipFile&"\"&$sDestDir).Items.Count
					ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $rcount = ' & $rcount & @crlf )
					If _Zip_ItemExists($hZipFile, $sTempDir&'\'&$hFile2Rename&"\"&$sDestDir) Then $err=0
				endif
			Else
				ExitLoop
			EndIf
			ConsoleWrite('$copy Error status= ' & @error& "-"&@extended & @crlf )
			ConsoleWrite('Addfile count='&_Zip_Count($destination) & "  to go =" &($files+1) & " on ="& $destination&@crlf)
			Sleep(1000)
			$Fcount +=1
			ConsoleWrite('$Fcount3 = ' & $Fcount & @crlf )
		Until $Fcount<4
		If $Fcount>3 Then Return SetError(8,0,8)
	#endregion
	#region del tempdir
		_DeleteDIR($sTempDir,0,0)
		Return SetError(0,0,1)
	#endregion
EndFunc   ;==>_Zip_AddFile
Func _Zip_AddFile($hZipFile,$hFile2Add, $hFile2Rename, $sDestDir="",$flag = 1)
	ConsoleWrite('==========   _Zip_AddFile ====================================' & @crlf )
	ConsoleWrite('$hZipFile = ' & $hZipFile & @crlf )
	ConsoleWrite('$hFile2Add = ' & $hFile2Add & @crlf )
	ConsoleWrite('$hFile2Rename = ' & $hFile2Rename & @crlf )
	ConsoleWrite('$sDestDir = ' & $sDestDir & @crlf )
	#region check dll
		Local $DLLChk = _Zip_DllChk()
		If $DLLChk <> 0 Then
			ConsoleWrite("no dll " & @crlf)
			MsgBox(0,"no dll ","no dll ",0)
			Return SetError($DLLChk, 0, 50);
		endif
	#endregion
	#region check parameters
		If not _IsFullPath($hZipFile) then
			ConsoleWrite('zip file isn t a full path ' & @crlf)
			Return SetError(2,0,2)
		endif
		If Not FileExists($hZipFile) Then
			ConsoleWrite("no zip file " & @crlf)
			Return SetError(3, 0, 3) ;
		endif

		If not _IsFullPath($hFile2Add) then
			ConsoleWrite('orig file isn t a full path ' & @crlf)
			Return SetError(4,0,4)
		endif
		If Not FileExists($hFile2Add) Then
			ConsoleWrite("no orig file " & @crlf)
			Return SetError(5, 0, 5) ;
		endif

	#endregion
	#region prepare variables
		$oApp = ObjCreate("Shell.Application")
		$oApp1 = ObjCreate("Shell.Application")
		; clean paths
;~     $sItem = _Zip_PathStripSlash($sItem)
		$sDestDir = _Zip_PathStripSlash($sDestDir)
		$destination=_Zip_PathStripSlash($hZipFile&"\"&$sDestDir)

;~ 		$files=$oApp.NameSpace($hZipFile).Items.Count
		$files=_Zip_Count($hZipFile,$hZipFile&"\"&$sDestDir)
		ConsoleWrite('$files count = ' & $files & @crlf )

		$sTempDir = _Zip_CreateTempDir()
	#endregion
	#region copy to local tempdir
		$Fcount=1
		do
			FileCopy($hFile2Add,$sTempDir&"\"&$hFile2Rename,1+8)
			If FileExists($sTempDir&"\"&$hFile2Rename) Then ExitLoop
			$Fcount +=1
			ConsoleWrite('$Fcount1 = ' & $Fcount & @crlf )
		Until $Fcount<10
		If $Fcount>9 Then Return SetError(6,0,6)
	#endregion
	#region  check if copyed to temp dir
		$Fcount=1
		Do
			Local $fil=FileOpen($sTempDir&"\"&$hFile2Rename,0)
			If $fil = -1 Then MsgBox(0, "Error", "Unable to open file.")
			FileClose($fil)
			$Fcount +=1
			ConsoleWrite('$Fcount2 = ' & $Fcount & @crlf )
		Until $Fcount<10
		If $Fcount>9 Then Return SetError(7,0,7)
	#endregion
	#region Add file to ZIP
		$err=1
		If $sDestDir="" Then
			ConsoleWrite('>> 0 << ' & @crlf )
			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sTempDir&''\''&$hFile2Rename = ' & $sTempDir&'\'&$hFile2Rename & @crlf )
			$copy = $oApp.NameSpace($hZipFile).CopyHere($sTempDir&'\'&$hFile2Rename)
			$err=@error
		Else
			ConsoleWrite('>> 1 << ' & @crlf )
			ConsoleWrite('$sTempDir\$hFile2Rename = ' & $sTempDir&'\'&$hFile2Rename & @crlf )
			ConsoleWrite('$hZipFile\$sDestDir = ' & $hZipFile&"\"&$sDestDir & @crlf )
			$copy = $oApp1.NameSpace($hZipFile&"\"&$sDestDir).CopyHere($sTempDir&'\'&$hFile2Rename)
			$err=@error
		endif
	#endregion
	#region wait For copy
		$Fcount=0
;~ 		While 1
;~ 			ConsoleWrite('~~~~~~~~~~~~~~~ $err = ' & $err & @crlf )
;~ 			$rcount=$oApp.NameSpace($hZipFile).Items.Count
;~ 			ConsoleWrite('==> $rcount     = ' & $rcount & @crlf )
;~ 			ConsoleWrite('==>$files to go = ' & $files & @crlf )
;~ 			if Not _FileInUse($hZipFile) Then
;~ 				If $rcount>$files+1 then exitloop
;~ 			endif
;~ 			Sleep(30000)
;~ 			$Fcount +=1
;~ 			ConsoleWrite('$Fcount3 = ' & $Fcount & @crlf )
;~ 		wend
$cout=0
	While 1
		$cout +=1
		If $flag = 1 then _Hide()
		If Not _FileInUse($hZipFile) Then
			$rcount=_Zip_Count($hZipFile,$hZipFile&"\"&$sDestDir)
			If  $rcount = ($files+1) Then ExitLoop
			ConsoleWrite('count='&$rcount& "  to go =" &($files+1) & " on ="& $hZipFile&"\"&$sDestDir&@crlf)
			Sleep(10000)
			If $cout>2 Then Sleep(1000000)
		Else
			ConsoleWrite('File in use = ' & $hZipFile & @crlf )
			Sleep(5000)
		endif
	WEnd

	#endregion
	#region del tempdir
		_DeleteDIR($sTempDir,0,0)
		Return SetError(0,0,1)
	#endregion
EndFunc   ;==>_Zip_AddFile
Func _Zip_AddFile1($hZipFile,$hFile2Add, $hFile2Rename, $sDestDir="",$flag = 1)
	ConsoleWrite('$$$$$$ $hFile2Rename = ' & $hFile2Rename & @crlf )
	#region check dll
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then
		ConsoleWrite("no dll " & @crlf)
		MsgBox(0,"no dll ","no dll ",0)
		Return SetError($DLLChk, 0, 50);
	endif
	#endregion
	#region check parameters
	If not _IsFullPath($hZipFile) then
		ConsoleWrite('zip file isn t a full path ' & @crlf)
		Return SetError(2,0,2)
	endif
	If Not FileExists($hZipFile) Then
		ConsoleWrite("no zip file " & @crlf)
		Return SetError(3, 0, 3) ;
	endif

	If not _IsFullPath($hFile2Add) then
		ConsoleWrite('orig file isn t a full path ' & @crlf)
		Return SetError(4,0,4)
	endif
	If Not FileExists($hFile2Add) Then
		ConsoleWrite("no orig file " & @crlf)
		Return SetError(5, 0, 5) ;
	endif

;~ 	If not _IsFullPath($hFile2Rename) then
;~ 		ConsoleWrite('orig file isn t a full path ' & @crlf)
;~ 		Return SetError(6,0,6)
;~ 	endif
;~ 	If Not FileExists($hFile2Rename) Then
;~ 		ConsoleWrite("no orig file " & @crlf)
;~ 		Return SetError(7, 0,7) ;
;~ 	endif

;~ 	If not _IsFullPath($sDestDir) then
;~ 		ConsoleWrite('destdir file isn t a full path ' & @crlf)
;~ 		Return SetError(6,0,6)
;~ 	endif
;~ 	If Not FileExists($sDestDir) Then
;~ 		ConsoleWrite("no destdir file " & @crlf)
;~ 		Return SetError(7, 0,7) ;
;~ 	endif
	#endregion

	Local $files = _Zip_Count($hZipFile&"\"&$sDestDir)
	$oApp = ObjCreate("Shell.Application")
	$sTempDir = _Zip_CreateTempDir()

	$Fcount=1
	do
		FileCopy($hFile2Add,$sTempDir&"\"&$hFile2Rename,1+8)
		If FileExists($sTempDir&"\"&$hFile2Rename) Then ExitLoop
		$Fcount +=1
		ConsoleWrite('$Fcount1 = ' & $Fcount & @crlf )
	Until $Fcount<10
	If $Fcount>9 Then Return SetError(5,0,5)

	$Fcount=1
	Do
		Local $fil=FileOpen($sTempDir&"\"&$hFile2Rename,0)
		If $fil = -1 Then MsgBox(0, "Error", "Unable to open file.")
		FileClose($fil)
		$Fcount +=1
		ConsoleWrite('$Fcount2 = ' & $Fcount & @crlf )
	Until $Fcount<10
	If $Fcount>9 Then Return SetError(6,0,6)
;~ 	$progresso=1
;~ 	If $flag = 1 Then
		$copy = $oApp.NameSpace($hZipFile&"\"&$sDestDir).CopyHere('"',$sTempDir&'\'&$hFile2Rename&'"')
;~ 	Else
;~ 		$copy = $oApp.NameSpace($hZipFile&"\"&$sDestDir).CopyHere('"',$sTempDir&'\'&$hFile2Rename&'"',4);,4+8+512+1024+2048)
;~ 	endif
	ConsoleWrite(' : $copy = ' & @error& "-"&@extended & @crlf )
	While 1
		If $flag = 1 then _Hide()
		If _Zip_Count($hZipFile&"\"&$sDestDir) = ($files+1) Then ExitLoop
		ConsoleWrite('count='&_Zip_Count($hZipFile&"\"&$sDestDir) & "  to go =" &($files+1) & " on ="& $hZipFile&"\"&$sDestDir&@crlf)
		Sleep(1000)
	WEnd
	_DeleteDIR($sTempDir,1,0)
	Return SetError(0,0,1)
EndFunc   ;==>_Zip_AddFile
Func _Zip_DllChk()
	If Not FileExists(@SystemDir & "\zipfldr.dll") Then Return 2
	If Not RegRead("HKEY_CLASSES_ROOT\CLSID\{E88DCCE0-B7B3-11d1-A9F0-00AA0060FA31}", "") Then Return 3
	Return 0
EndFunc   ;==>_Zip_DllChk
Func _Zip_PathStripSlash($sString)
    Return StringRegExpReplace($sString, "(^\\+|\\+$)", "")
EndFunc   ;==>_Zip_PathStripSlash
Func _Zip_GetNameSpace($sZipFile, $sPath = "")
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    Local $oApp = ObjCreate("Shell.Application")
    Local $oNS = $oApp.NameSpace($sZipFile)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    If $sPath <> "" Then
        ; subfolder
        Local $aPath = StringSplit($sPath, "\")
        Local $oItem
        For $i = 1 To $aPath[0]
            $oItem = $oNS.ParseName($aPath[$i])
            If Not IsObj($oItem) Then Return SetError(5, 0, 0)
            $oNS = $oItem.GetFolder
            If Not IsObj($oNS) Then Return SetError(6, 0, 0)
        Next
    EndIf
    Return $oNS
EndFunc   ;==>_Zip_GetNameSpace
; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_DeleteItem
; Description....:  Delete a file or folder from a ZIP archive
; Syntax.........:  _Zip_DeleteItem($sZipFile, $sFileName)
; Parameters.....:  $sZipFile   - Full path to the ZIP file
;                   $sFileName  - Name of the item in the ZIP file
;
; Return values..:  Success     - 1
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file or sub path does not exist
;                               | 5 - Item not found in ZIP file
;                               | 6 - Failed to get list of verbs
;                               | 7 - Failed to delete item
;                               | 8 - User cancelled delete operation or operation failed
; Author.........:  wraithdu
; Modified.......:
; Remarks........:  $sFileName may be a path to an item from the root of the ZIP archive.
;                   For example, some ZIP file 'test.zip' has a subpath 'some\dir\file.ext'.  Do not include a leading or trailing '\'.
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_DeleteItem($sZipFile, $sFileName)
	ConsoleWrite('================= _Zip_DeleteItem ==================================== '& @crlf )
	ConsoleWrite('$sZipFile = ' & $sZipFile & @crlf )
	ConsoleWrite('$sFileName = ' & $sFileName & @crlf )
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    ; parse filename
    Local $sPath = ""
    $sFileName = _Zip_PathStripSlash($sFileName)
    If StringInStr($sFileName, "\") Then
        ; subdirectory, parse out path and filename
        $sPath = _Zip_PathPathOnly($sFileName)
        $sFileName = _Zip_PathNameOnly($sFileName)
    EndIf
    Local $oNS = _Zip_GetNameSpace($sZipFile, $sPath)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Local $oFolderItem = $oNS.ParseName($sFileName)
    If Not IsObj($oFolderItem) Then Return SetError(5, 0, 0)
    Local $oVerbs = $oFolderItem.Verbs()
    If Not IsObj($oVerbs) Then Return SetError(6, 0, 0)
    For $oVerb In $oVerbs
        If StringReplace($oVerb.Name, "&", "") = "delete" Then
            $oVerb.DoIt()
            If IsObj($oNS.ParseName($sFileName)) Then
                Return SetError(8, 0, 0)
            Else
                Return 1
            EndIf
        EndIf
    Next
    Return SetError(7, 0, 0)
EndFunc   ;==>_Zip_DeleteItem




;##################################################################################################################
;##################################################################################################################
;##################################################################################################################
;##################################################################################################################



; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_AddItem
; Description....:  Add a file or folder to a ZIP archive
; Syntax.........:  _Zip_AddItem($sZipFile, $sItem[, $sDestDir = ""[, $iFlag = 21]])
; Parameters.....:  $sZipFile   - Full path to ZIP file
;                   $sItem      - Full path to item to add
;                   $sDestDir   - [Optional] Destination subdirectory in which to place the item
;                               + Directory must be formatted similarly: "some\sub\dir"
;                   $iFlag      - [Optional] File copy flags (Default = 1+4+16)
;                               |   1 - Overwrite destination file if it exists
;                               |   4 - No progress box
;                               |   8 - Rename the file if a file of the same name already exists
;                               |  16 - Respond "Yes to All" for any dialog that is displayed
;                               |  64 - Preserve undo information, if possible
;                               | 256 - Display a progress dialog box but do not show the file names
;                               | 512 - Do not confirm the creation of a new directory if the operation requires one to be created
;                               |1024 - Do not display a user interface if an error occurs
;                               |2048 - Version 4.71. Do not copy the security attributes of the file
;                               |4096 - Only operate in the local directory, don't operate recursively into subdirectories
;                               |8192 - Version 5.0. Do not copy connected files as a group, only copy the specified files
;
; Return values..:  Success     - 1
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Destination ZIP file not a full path
;                               | 4 - Item to add not a full path
;                               | 5 - Item to add does not exist
;                               | 6 - Destination subdirectory cannot be a full path
;                               | 7 - Destination ZIP file or sub path does not exist
;                               | 8 - Destination item exists and is a folder (see Remarks)
;                               | 9 - Destination item exists and overwrite flag not set
;                               |10 - Destination item exists and failed to overwrite
;                               |11 - Failed to create internal directory structure
;
; Author.........:  wraithdu
; Modified.......:
; Remarks........:  Destination folders CANNOT be overwritten or merged.  They must be manually deleted first.
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_AddItem($sZipFile, $sItem, $sDestDir = "", $iFlag = 21)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    If Not _IsFullPath($sItem) Then Return SetError(4, 0, 0)
    If Not FileExists($sItem) Then Return SetError(5, 0, 0)
    If _IsFullPath($sDestDir) Then Return SetError(6, 0, 0)
    ; clean paths
    $sItem = _Zip_PathStripSlash($sItem)
    $sDestDir = _Zip_PathStripSlash($sDestDir)
    Local $sNameOnly = _Zip_PathNameOnly($sItem)
    ; process overwrite flag
    Local $iOverwrite = 0
    If BitAND($iFlag, 1) Then
        $iOverwrite = 1
        $iFlag -= 1
    EndIf
    ; check for overwrite, if target exists...
    Local $sTest = $sNameOnly
    If $sDestDir <> "" Then $sTest = $sDestDir & "\" & $sNameOnly
    Local $itemExists = _Zip_ItemExists($sZipFile, $sTest)
    If @error Then Return SetError(7, 0, 0)
    If $itemExists Then
        If @extended Then
            ; get out, cannot overwrite folders... AT ALL
            Return SetError(8, 0, 0)
        Else
            If $iOverwrite Then
                _Zip_InternalDelete($sZipFile, $sTest)
                If @error Then Return SetError(10, 0, 0)
            Else
                Return SetError(9, 0, 0)
            EndIf
        EndIf
    EndIf
    Local $sTempFile = ""
    If $sDestDir <> "" Then
        $sTempFile = _Zip_AddPath($sZipFile, $sDestDir)
        If @error Then Return SetError(11, 0, 0)
    EndIf
    Local $oNS = _Zip_GetNameSpace($sZipFile, $sDestDir)
    ; copy the item(s)
    $oNS.CopyHere($sItem, $iFlag)
    Do
        Sleep(250)
    Until IsObj($oNS.ParseName($sNameOnly))
    If $sTempFile <> "" Then
        _Zip_InternalDelete($sZipFile, $sDestDir & "\" & $sTempFile)
        If @error Then Return SetError(12, 0, 0)
    EndIf
    Return 1
EndFunc   ;==>_Zip_AddItem




; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_CountAll
; Description....:  Recursively count items contained in a ZIP archive
; Syntax.........:  _Zip_CountAll($sZipFile)
; Parameters.....:  $sZipFile       - Full path to ZIP file
;                   $sSub           - [Internal]
;                   $iFileCount     - [Internal]
;                   $iFolderCount   - [Internal]
;
; Return values..:  Success         - Array with file and folder count
;                                   [0] - File count
;                                   [1] - Folder count
;                   Failure         - 0 and sets @error
;                                   | 1 - zipfldr.dll does not exist
;                                   | 2 - Library not installed
;                                   | 3 - Not a full path
;                                   | 4 - ZIP file does not exist
; Author.........:  wraithdu
; Modified.......:
; Remarks........:
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_CountAll($sZipFile, $sSub = "", $iFileCount = 0, $iFolderCount = 0)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    Local $oNS = _Zip_GetNameSpace($sZipFile, $sSub)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Local $oItems = $oNS.Items(), $aCount, $sSub2
    For $oItem In $oItems
        ; reset subdir so recursion doesn't break
        $sSub2 = $sSub
        If $oItem.IsFolder Then
            ; folder, recurse
            $iFolderCount += 1
            If $sSub2 = "" Then
                $sSub2 = $oItem.Name
            Else
                $sSub2 &= "\" & $oItem.Name
            EndIf
            $aCount = _Zip_CountAll($sZipFile, $sSub2, $iFileCount, $iFolderCount)
            $iFileCount = $aCount[0]
            $iFolderCount = $aCount[1]
        Else
            $iFileCount += 1
        EndIf
    Next
    Dim $aCount[2] = [$iFileCount, $iFolderCount]
    Return $aCount
EndFunc   ;==>_Zip_CountAll


; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_ItemExists
; Description....:  Determines if an item exists in a ZIP file
; Syntax.........:  _Zip_ItemExists($sZipFile, $sItem)
; Parameters.....:  $sZipFile   - Full path to ZIP file
;                   $sItem      - Name of item
;
; Return values..:  Success     - 1
;                               @extended is set to 1 if the item is a folder, 0 if a file
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file or sub path does not exist
; Author.........:  wraithdu
; Modified.......:
; Remarks........:  $sItem may be a path to an item from the root of the ZIP archive.
;                   For example, some ZIP file 'test.zip' has a subpath 'some\dir\file.ext'.  Do not include a leading or trailing '\'.
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_ItemExists($sZipFile, $sItem)
;~ 	MsgBox(0,$sItem, $sZipFile,3)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    Local $sPath = ""
    $sItem = _Zip_PathStripSlash($sItem)
    If StringInStr($sItem, "\") Then
        ; subfolder
        $sPath = _Zip_PathPathOnly($sItem)
        $sItem = _Zip_PathNameOnly($sItem)
    EndIf

    Local $oNS = _Zip_GetNameSpace($sZipFile, $sPath)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Local $oItem = $oNS.ParseName($sItem)
    ; @extended holds whether item is a file (0) or folder (1)
    If IsObj($oItem) Then Return SetExtended(Number($oItem.IsFolder), 1)
    Return 0
EndFunc   ;==>_Zip_ItemExists

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_List
; Description....:  List items in the root of a ZIP archive (not recursive)
; Syntax.........:  _Zip_List($sZipFile)
; Parameters.....:  $sZipFile   - Full path to ZIP file
;
; Return values..:  Success     - Array of items
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file does not exist
; Author.........:  wraithdu, torels
; Modified.......:
; Remarks........:  Item count is returned in array[0].
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================


; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_ListAll
; Description....:  List all files inside a ZIP archive
; Syntax.........:  _Zip_ListAll($sZipFile[, $iFullPath = 1])
; Parameters.....:  $sZipFile   - Full path to ZIP file
;                   $iFullPath  - [Optional] Path flag (Default = 1)
;                               | 0 - Return file names only
;                               | 1 - Return full paths of files from the archive root
;
; Return values..:  Success     - Array of file names / paths
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file does not exist
; Author.........:  wraithdu
; Modified.......:
; Remarks........:  File count is returned in array[0], does not list folders.
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_ListAll($sZipFile, $iFullPath = 1)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    Local $aArray[1] = [0]
    _Zip_ListAll_Internal($sZipFile, "", $aArray, $iFullPath)
    If @error Then
        Return SetError(@error, 0, 0)
    Else
        Return $aArray
    EndIf
EndFunc   ;==>_Zip_ListAll

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_Search
; Description....:  Search for files in a ZIP archive
; Syntax.........:  _Zip_Search($sZipFile, $sSearchString)
; Parameters.....:  $sZipFile       - Full path to ZIP file
;                   $sSearchString  - Substring to search
;
; Return values..:  Success         - Array of matching file paths from the root of the archive
;                   Failure         - 0 and sets @error
;                                   | 1 - zipfldr.dll does not exist
;                                   | 2 - Library not installed
;                                   | 3 - Not a full path
;                                   | 4 - ZIP file does not exist
;                                   | 5 - No matching files found
; Author.........:  wraithdu
; Modified.......:
; Remarks........:  Found file count is returned in array[0].
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_Search($sZipFile, $sSearchString)
    Local $aList = _Zip_ListAll($sZipFile)
    If @error Then Return SetError(@error, 0, 0)
    Local $aArray[1] = [0], $sName
    For $i = 1 To $aList[0]
        $sName = $aList[$i]
        If StringInStr($sName, "\") Then
            ; subdirectory, isolate file name
            $sName = _Zip_PathNameOnly($sName)
        EndIf
        If StringInStr($sName, $sSearchString) Then
            $aArray[0] += 1
            ReDim $aArray[$aArray[0] + 1]
            $aArray[$aArray[0]] = $aList[$i]
        EndIf
    Next
    If $aArray[0] = 0 Then
        ; no files found
        Return SetError(5, 0, 0)
    Else
        Return $aArray
    EndIf
EndFunc   ;==>_Zip_Search

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_SearchInFile
; Description....:  Search file contents of files in a ZIP archive
; Syntax.........:  _Zip_SearchInFile($sZipFile, $sSearchString)
; Parameters.....:  $sZipFile       - Full path to ZIP file
;                   $sSearchString  - Substring to search
;
; Return values..:  Success         - Array of matching file paths from the root of the archive
;                   Failure         - 0 and sets @error
;                                   | 1 - zipfldr.dll does not exist
;                                   | 2 - Library not installed
;                                   | 3 - Not a full path
;                                   | 4 - ZIP file does not exist
;                                   | 5 - Failed to create temporary directory
;                                   | 6 - Failed to extract ZIP file to temporary directory
;                                   | 7 - No matching files found
; Author.........:  wraithdu
; Modified.......:
; Remarks........:  Found file count is returned in array[0].
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_SearchInFile($sZipFile, $sSearchString)
    Local $aList = _Zip_ListAll($sZipFile)
    If @error Then Return SetError(@error, 0, 0)
    Local $sTempDir = _Zip_CreateTempDir()
    If @error Then Return SetError(5, 0, 0)
    _Zip_UnzipAll($sZipFile, $sTempDir) ; flag = 20 -> no dialog, yes to all
    If @error Then
        DirRemove($sTempDir, 1)
        Return SetError(6, 0, 0)
    EndIf
    Local $aArray[1] = [0], $sData
    For $i = 1 To $aList[0]
        $sData = FileRead($sTempDir & "\" & $aList[$i])
        If StringInStr($sData, $sSearchString) Then
            $aArray[0] += 1
            ReDim $aArray[$aArray[0] + 1]
            $aArray[$aArray[0]] = $aList[$i]
        EndIf
    Next
    DirRemove($sTempDir, 1)
    If $aArray[0] = 0 Then
        ; no files found
        Return SetError(7, 0, 0)
    Else
        Return $aArray
    EndIf
EndFunc   ;==>_Zip_SearchInFile

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_Unzip
; Description....:  Extract a single item from a ZIP archive
; Syntax.........:  _Zip_Unzip($sZipFile, $sFileName, $sDestPath[, $iFlag = 21])
; Parameters.....:  $sZipFile   - Full path to ZIP file
;                   $sFileName  - Name of the item in the ZIP file
;                   $sDestPath  - Full path to the destination
;                   $iFlag      - [Optional] File copy flags (Default = 1+4+16)
;                               |   1 - Overwrite destination file if it exists
;                               |   4 - No progress box
;                               |   8 - Rename the file if a file of the same name already exists
;                               |  16 - Respond "Yes to All" for any dialog that is displayed
;                               |  64 - Preserve undo information, if possible
;                               | 256 - Display a progress dialog box but do not show the file names
;                               | 512 - Do not confirm the creation of a new directory if the operation requires one to be created
;                               |1024 - Do not display a user interface if an error occurs
;                               |2048 - Version 4.71. Do not copy the security attributes of the file
;                               |4096 - Only operate in the local directory, don't operate recursively into subdirectories
;                               |8192 - Version 5.0. Do not copy connected files as a group, only copy the specified files
;
; Return values..:  Success     - 1
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file or sub path does not exist
;                               | 5 - Item not found in ZIP file
;                               | 6 - Failed to create destination (if necessary)
;                               | 7 - Failed to open destination
;                               | 8 - Failed to delete destination file / folder for overwriting
;                               | 9 - Destination exists and overwrite flag not set
;                               |10 - Failed to extract file
; Author.........:  wraithdu, torels
; Modified.......:
; Remarks........:  $sFileName may be a path to an item from the root of the ZIP archive.
;                   For example, some ZIP file 'test.zip' has a subpath 'some\dir\file.ext'.  Do not include a leading or trailing '\'.
;                   If the overwrite flag is not set and the destination file / folder exists, overwriting is controlled
;                   by the remaining file copy flags ($iFlag) and/or user interaction.
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_Unzip($sZipFile, $sFileName, $sDestPath, $iFlag = 21)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Or Not _IsFullPath($sDestPath) Then Return SetError(3, 0, 0)
    ; get temp directory created by Windows
    Local $sTempDir = _Zip_TempDirName($sZipFile)
    ; parse filename
    Local $sPath = ""
    $sFileName = _Zip_PathStripSlash($sFileName)
    If StringInStr($sFileName, "\") Then
        ; subdirectory, parse out path and filename
        $sPath = _Zip_PathPathOnly($sFileName)
        $sFileName = _Zip_PathNameOnly($sFileName)
    EndIf
    Local $oNS = _Zip_GetNameSpace($sZipFile, $sPath)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Local $oFolderItem = $oNS.ParseName($sFileName)
    If Not IsObj($oFolderItem) Then Return SetError(5, 0, 0)
    $sDestPath = _Zip_PathStripSlash($sDestPath)
    If Not FileExists($sDestPath) Then
        DirCreate($sDestPath)
        If @error Then Return SetError(6, 0, 0)
    EndIf
    Local $oNS2 = _Zip_GetNameSpace($sDestPath)
    If Not IsObj($oNS2) Then Return SetError(7, 0, 0)
    ; process overwrite flag
    Local $iOverwrite = 0
    If BitAND($iFlag, 1) Then
        $iOverwrite = 1
        $iFlag -= 1
    EndIf
    Local $sDestFullPath = $sDestPath & "\" & $sFileName
    If FileExists($sDestFullPath) Then
        ; destination file exists
        If $iOverwrite Then
            If StringInStr(FileGetAttrib($sDestFullPath), "D") Then
                ; folder
                If Not DirRemove($sDestFullPath, 1) Then Return SetError(8, 0, 0)
            Else
                If Not FileDelete($sDestFullPath) Then Return SetError(8, 0, 0)
            EndIf
        Else
            Return SetError(9, 0, 0)
        EndIf
    EndIf
    $oNS2.CopyHere($oFolderItem, $iFlag)
    ; remove temp dir created by Windows
    DirRemove($sTempDir, 1)
    If FileExists($sDestFullPath) Then
        ; success
        Return 1
    Else
        ; failure
        Return SetError(10, 0, 0)
    EndIf
EndFunc   ;==>_Zip_Unzip

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_UnzipAll
; Description....:  Extract all files contained in a ZIP archive
; Syntax.........:  _Zip_UnzipAll($sZipFile, $sDestPath[, $iFlag = 20])
; Parameters.....:  $sZipFile   - Full path to ZIP file
;                   $sDestPath  - Full path to the destination
;                   $iFlag      - [Optional] File copy flags (Default = 4+16)
;                               |   4 - No progress box
;                               |   8 - Rename the file if a file of the same name already exists
;                               |  16 - Respond "Yes to All" for any dialog that is displayed
;                               |  64 - Preserve undo information, if possible
;                               | 256 - Display a progress dialog box but do not show the file names
;                               | 512 - Do not confirm the creation of a new directory if the operation requires one to be created
;                               |1024 - Do not display a user interface if an error occurs
;                               |2048 - Version 4.71. Do not copy the security attributes of the file
;                               |4096 - Only operate in the local directory, don't operate recursively into subdirectories
;                               |8192 - Version 5.0. Do not copy connected files as a group, only copy the specified files
;
; Return values..:  Success     - 1
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file does not exist
;                               | 5 - Failed to create destination (if necessary)
;                               | 6 - Failed to open destination
;                               | 7 - Failed to extract file(s)
; Author.........:  wraithdu, torels
; Modified.......:
; Remarks........:  Overwriting of destination files is controlled solely by the file copy flags (ie $iFlag = 1 is NOT valid).
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_UnzipAll($sZipFile, $sDestPath, $iFlag = 20)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Or Not _IsFullPath($sDestPath) Then Return SetError(3, 0, 0)
    ; get temp dir created by Windows
    Local $sTempDir = _Zip_TempDirName($sZipFile)
    Local $oNS = _Zip_GetNameSpace($sZipFile)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    $sDestPath = _Zip_PathStripSlash($sDestPath)
    If Not FileExists($sDestPath) Then
        DirCreate($sDestPath)
        If @error Then Return SetError(5, 0, 0)
    EndIf
    Local $oNS2 = _Zip_GetNameSpace($sDestPath)
    If Not IsObj($oNS2) Then Return SetError(6, 0, 0)
    $oNS2.CopyHere($oNS.Items(), $iFlag)
    ; remove temp dir created by WIndows
    DirRemove($sTempDir, 1)
    If FileExists($sDestPath & "\" & $oNS.Items().Item($oNS.Items().Count - 1).Name) Then
        ; success... most likely
        ; checks for existence of last item from source in destination
        Return 1
    Else
        ; failure
        Return SetError(7, 0, 0)
    EndIf
EndFunc   ;==>_Zip_UnzipAll

Func _Zip_CreateFolder($hZipFile, $hFolder, $flag = 1)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : _Zip_CreateFolder ========================= '  & @crlf )
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $hZipFile = ' & $hZipFile & @crlf )
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $hFolder = ' & $hFolder & @crlf )
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0);no dll
	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
;~ 	If StringRight($hFolder, 1) <> "\" Then $hFolder &= "\"
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $hFolder = ' & $hFolder & @crlf )
	$oApp = ObjCreate("Shell.Application")
;~ 	$oMkdir = $oApp.NameSpace($hZipFile).NewFolder($oApp.Namespace($hFolder))
	$oMkdir = $oApp.NameSpace($hZipFile).NewFolder($hFolder)
;~ 	$oFC = $oApp.NameSpace($hFolder).items.count
	$oFC = 1
	While 1
		If $flag = 1 then _Hide()
		If _Zip_Count($hZipFile) = ($oFC) Then ExitLoop
		MsgBox(0,@ScriptLineNumber&"_Zip_Count($hZipFile)", _Zip_Count($hZipFile),3)
		Sleep(10)
	WEnd
	Return SetError(0,0,1)
EndFunc   ;==>_Zip_AddFolder

;===============================================================================
;
; Function Name:    _Zip_AddFolderContents()
; Description:      Add a folder to a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$hFolder - Complete path to the folder that will be added (possibly including "\" at the end)
;					$flag = 1
;					- 1 no progress box
;					- 0 progress box
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			The return values will be given once the compressing process is ultimated... it takes some time with big files
;
;===============================================================================
Func _Zip_AddFolderContents($hZipFile, $hFolder, $flag = 1)
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0);no dll
	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	If StringRight($hFolder, 1) <> "\" Then $hFolder &= "\"
	$files = _Zip_Count($hZipFile)
	$oApp = ObjCreate("Shell.Application")
	$oFolder = $oApp.NameSpace($hFolder)
	$oCopy = $oApp.NameSpace($hZipFile).CopyHere($oFolder.Items)
	$oFC = $oApp.NameSpace($hFolder).items.count
	While 1
		If $flag = 1 then _Hide()
		If _Zip_Count($hZipFile) = ($files+$oFC) Then ExitLoop
		Sleep(10)
	WEnd
	Return SetError(0,0,1)
EndFunc   ;==>_Zip_AddFolderContents


;===============================================================================
;
; Function Name:    _Zip_VirtualZipCreate()
; Description:      Create a Virtual Zip.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$sPath - Path to where create the Virtual Zip
; Requirement(s):   none.
; Return Value(s):  On Success - List of Created Files
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			none
;
;===============================================================================
Func _Zip_VirtualZipCreate($hZipFile, $sPath)
	$List = _Zip_List($hZipFile)
	If @error Then Return SetError(@error,0,0)
	If Not FileExists($sPath) Then DirCreate($sPath)
	If StringRight($sPath, 1) = "\" Then $sPath = StringLeft($sPath, StringLen($sPath) -1)
	For $i = 1 to $List[0]
		If Not @Compiled Then
			$Cmd = @AutoItExe
			$params = '"' & @ScriptFullPath & '" ' & '"' & $hZipFile & "," & $List[$i] & '"'
		Else
			$Cmd = @ScriptFullPath
			$Params = '"' & $hZipFile & "," & $List[$i] & '"'
		EndIf
		FileCreateShortcut($Cmd, $sPath & "\" & $List[$i], -1,$Params, "Virtual Zipped File", _GetIcon($List[$i], 0), "", _GetIcon($List[$i], 1))
	Next
	$List = _ArrayInsert($List, 1, $sPath)
	Return $List
EndFunc

;===============================================================================
;
; Function Name:    _Zip_VirtualZipOpen()
; Description:      Open A File in a Virtual Zip, Internal Function.
; Parameter(s):     none.
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			none
;
;===============================================================================
Func _Zip_VirtualZipOpen()
	$ZipSplit = StringSplit($CMDLine[1], ",")
	$ZipName = $ZipSplit[1]
	$ZipFile = $ZipSplit[2]
	_Zip_Unzip($ZipName, $ZipFile, $tempDir & "\", 4+16) ;no progress + yes to all
	If @error Then Return SetError(@error,0,0)
	ShellExecute($tempDir & "\" & $ZipFile)
EndFunc

;===============================================================================
;
; Function Name:    _Zip_VirtualZipOpen()
; Description:      Delete a Virtual Zip.
; Parameter(s):     none.
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - none.
; Author(s):        torels_
; Notes:			none
;
;===============================================================================
Func _Zip_VirtualZipDelete($aVirtualZipHandle)
	For $i = 2 to UBound($aVirtualZipHandle)-1
		If FileExists($aVirtualZipHandle[1] & "\" & $aVirtualZipHandle[$i]) Then FileDelete($aVirtualZipHandle[1] & "\" & $aVirtualZipHandle[$i])
	Next
	Return 0
EndFunc

;===============================================================================
;
; Function Name:    _GetIcon()
; Description:      Internal Function.
; Parameter(s):     $file - File form which to retrieve the icon
;					$ReturnType - IconFile or IconID
; Requirement(s):   none.
; Return Value(s):  Icon Path/ID
; Author(s):        torels_
;
;===============================================================================
Func _GetIcon($file, $ReturnType = 0)
	$FileType = StringSplit($file, ".")
	$FileType = $FileType[UBound($FileType)-1]
	$FileParam = RegRead("HKEY_CLASSES_ROOT\." & $FileType, "")
	$DefaultIcon = RegRead("HKEY_CLASSES_ROOT\" & $FileParam & "\DefaultIcon", "")

	If Not @error Then
		$IconSplit = StringSplit($DefaultIcon, ",")
		ReDim $IconSplit[3]
		$Iconfile = $IconSplit[1]
		$IconID = $IconSplit[2]
	Else
		$Iconfile = @SystemDir & "\shell32.dll"
		$IconID = -219
	EndIf

	If $ReturnType = 0 Then
		Return $Iconfile
	Else
		Return $IconID
	EndIf
EndFunc



;===============================================================================
;
; Function Name:    _Hide()
; Description:      Internal Function.
; Parameter(s):     none
; Requirement(s):   none.
; Return Value(s):  none.
; Author(s):        torels_
;
;===============================================================================
Func _Hide()
	If ControlGetHandle("[CLASS:#32770]", "", "[CLASS:SysAnimate32; INSTANCE:1]") <> "" And WinGetState("[CLASS:#32770]") <> @SW_HIDE	Then ;The Window Exists
		$hWnd = WinGetHandle("[CLASS:#32770]")
		WinSetState($hWnd, "", @SW_HIDE)
	EndIf
EndFunc
#region INTERNAL FUNCTIONS


Func _Zip_InternalDelete($sZipFile, $sFileName)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    ; parse filename
    Local $sPath = ""
    $sFileName = _Zip_PathStripSlash($sFileName)
    If StringInStr($sFileName, "\") Then
        ; subdirectory, parse out path and filename
        $sPath = _Zip_PathPathOnly($sFileName)
        $sFileName = _Zip_PathNameOnly($sFileName)
    EndIf
    Local $oNS = _Zip_GetNameSpace($sZipFile, $sPath)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Local $oFolderItem = $oNS.ParseName($sFileName)
    If Not IsObj($oFolderItem) Then Return SetError(5, 0, 0)
    ; ## Ugh, this was ultimately a bad solution
    ; move file to a temp directory and remove the directory
    Local $sTempDir = _Zip_CreateTempDir()
    If @error Then Return SetError(6, 0, 0)
    Local $oApp = ObjCreate("Shell.Application")
    $oApp.NameSpace($sTempDir).MoveHere($oFolderItem, 20)
    DirRemove($sTempDir, 1)
    $oFolderItem = $oNS.ParseName($sFileName)
    If IsObj($oFolderItem) Then
        ; failure
        Return SetError(7, 0, 0)
    Else
        Return 1
    EndIf
EndFunc   ;==>_Zip_InternalDelete
Func _Zip_ListAll_Internal($sZipFile, $sSub, ByRef $aArray, $iFullPath, $sPrefix = "")
    Local $oNS = _Zip_GetNameSpace($sZipFile, $sSub)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Local $oList = $oNS.Items(), $sSub2
    For $oItem In $oList
        ; reset subdir so recursion doesn't break
        $sSub2 = $sSub
        If $oItem.IsFolder Then
            If $sSub2 = "" Then
                $sSub2 = $oItem.Name
            Else
                $sSub2 &= "\" & $oItem.Name
            EndIf
            ; folder, recurse
            If $iFullPath Then
                ; build path from root of zip
                _Zip_ListAll_Internal($sZipFile, $sSub2, $aArray, $iFullPath, $sSub2 & "\")
                If @error Then Return SetError(4)
            Else
                ; just filenames
                _Zip_ListAll_Internal($sZipFile, $sSub2, $aArray, $iFullPath, "")
                If @error Then Return SetError(4)
            EndIf
        Else
            $aArray[0] += 1
            ReDim $aArray[$aArray[0] + 1]
            $aArray[$aArray[0]] = $sPrefix & $oItem.Name
        EndIf
    Next
EndFunc   ;==>_Zip_ListAll_Internal

Func _Zip_PathNameOnly($sPath)
    Return StringRegExpReplace($sPath, ".*\\", "")
EndFunc   ;==>_Zip_PathNameOnly

Func _Zip_PathPathOnly($sPath)
    Return StringRegExpReplace($sPath, "^(.*)\\.*?$", "${1}")
EndFunc   ;==>_Zip_PathPathOnly
Func _Zip_TempDirName($sZipFile)
    Local $i = 0, $sTemp, $sName = _Zip_PathNameOnly($sZipFile)
    Do
        $i += 1
        $sTemp = $tempDir & "\Temporary Directory " & $i & " for " & $sName
    Until Not FileExists($sTemp) ; this folder will be created during extraction
    Return $sTemp
EndFunc   ;==>_Zip_TempDirName



;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;===============================================================================
;
; Function Name:    _Zip_AddFolder()
; Description:      Add a folder to a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$hFolder - Complete path to the folder that will be added (possibly including "\" at the end)
;					$flag = 1
;					- 1 no progress box
;					- 0 progress box
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			The return values will be given once the compressing process is ultimated... it takes some time with big files
;
;===============================================================================
Func _Zip_AddFolder1($hZipFile, $hFolder, $flag = 1)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : _Zip_AddFolder($hZipFile, $hFolder, $flag = 1) ==============' & @crlf )
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $hZipFile = ' & $hZipFile & @crlf )
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $hFolder = ' & $hFolder & @crlf )
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0);no dll
	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	If StringRight($hFolder, 1) <> "\" Then $hFolder &= "\"
	$files = _Zip_Count($hZipFile)
	$oApp = ObjCreate("Shell.Application")
	$oCopy = $oApp.NameSpace($hZipFile).CopyHere($hFolder)
	While 1
		If $flag = 1 then _Hide()
		If _Zip_Count($hZipFile) = ($files+1) Then ExitLoop
		ConsoleWrite("count="&_Zip_Count($hZipFile) & "    to go =" &($files+1) & "  ocopy="& $oCopy &@crlf)
		Sleep(1000)
	WEnd
	Return SetError(0,0,1)
EndFunc   ;==>_Zip_AddFolder
Func _Zip_AddFolder($hZipFile, $hFolder,$sDestDir, $flag = 1)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : _Zip_AddFolder ==============' & @crlf )
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $hZipFile = ' & $hZipFile & @crlf )
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $hFolder = ' & $hFolder & @crlf )
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0);no dll
	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	If StringRight($hFolder, 1) <> "\" Then $hFolder &= "\"
	$files = _Zip_Count($hZipFile)
	$oApp = ObjCreate("Shell.Application")
	runwait('cmd /c rmdir  /s/q "' & $tempDir&"\"&$sDestDir & '"',"", @SW_HIDE )
	DirCreate($tempDir&"\"&$sDestDir)
	$tempfile="tmp" & Floor(Random(0,100))
	FileClose(FileOpen($tempDir&"\"&$sDestDir&"\"&$tempfile, 2))
	$copy = $oApp.NameSpace($hZipFile).CopyHere($tempDir&"\"&$sDestDir,4)
	While 1
		If $flag = 1 then _Hide()
		If _Zip_Count($hZipFile) = ($files+1) Then ExitLoop
		ConsoleWrite("count="&_Zip_Count($hZipFile) & "    to go =" &($files+1) & "  copy="& $Copy &@crlf)
		Sleep(1000)
	WEnd
	Return SetError(0,0,1)
EndFunc   ;==>_Zip_AddFolder
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#cs

(4)Do not display a progress dialog box.
(8)Give the file being operated on a new name in a move, copy, or rename operation if a file with the target name already exists.
(16)Respond with "Yes to All" for any dialog box that is displayed.
(64)Preserve undo information, if possible.
(128)Perform the operation on files only if a wildcard file name (*.*) is specified.
(256)Display a progress dialog box but do not show the file names.
(512)Do not confirm the creation of a new directory if the operation requires one to be created.
(1024)Do not display a user interface if an error occurs.
(2048)Version 4.71. Do not copy the security attributes of the file.
(4096)Only operate in the local directory. Do not operate recursively into subdirectories.
(8192)Version 5.0. Do not copy connected files as a group. Only copy the specified files.

#ce