#region --------------------------------- helpers ------------------------------------------------------
	#region log
		Func _initLog()
			ConsoleWrite('++_initLog() = '& @crlf)
			FileClose($hLogFile)
			$ActivityLogFolder=_GetActivityLogFolder("any")
			$LogFileActivity=$ActivityLogFolder&"\" & "FileGodModeActivity.log"
			;open log file for activity
			$hLogFile = FileOpen($LogFileActivity, 1+8)
			If $hLogFile = -1 Then
				ConsoleWrite("Error Unable to open file Log File.")
				MsgBox(48+4096, "Activity Log File error", "Activity Log File cannot be reached." & @crlf & _
									"File configured: " & $LogFileActivity & @crlf & _
									"Using Log file: " & $LogFileActivity& @crlf &"ErrNo 2052",0)
			EndIf

			ConsoleWrite('- ActivityLogFile = ' & $LogFileActivity & @crlf )
			FileWriteLine($hLogFile,"===============================================================================" )
			FileWriteLine($hLogFile,"===============================================================================")
			FileWriteLine($hLogFile,_NowCalcDate()  & @TAB& "Start of activities"& @TAB& "Version: "& $version)
			FileWriteLine($hLogFile,"===============================================================================")
		EndFunc
		Func _GetActivityLogFolder($onlyFromINI="onlyFromINI")
			ConsoleWrite('++_GetActivityLogFolder() = '&$onlyFromINI& @crlf)
			$errorstatus=""
			; get from database
			if $onlyFromINI<>"onlyFromINI" then
				$ActivityLogFolderTemp=$ActivityLogFolder
				$ActivityLogFolder=_GetAppSettings("ActivityLogFolder","")
				if $ActivityLogFolder<>"" then
					$ActivityLogFolder=_ReplaceCMDEnvVar($ActivityLogFolder)
					if FileExists($ActivityLogFolder) and _IsFolder($ActivityLogFolder) Then
						$errorstatus="usingsettings"
						ConsoleWrite("-- Using Log File settings from application preferences.")
					else
						$errorstatus="settings"
					EndIf
				Else
					$ActivityLogFolder=$ActivityLogFolderTemp
				endif
			endif
			;-- get from INI file
			if $errorstatus="usingsettings" then
			else
				$ActivityLogFolderTemp=$ActivityLogFolder
				$ActivityLogFolder=IniRead($INIfile,"Debug","ActivityLogFolder","")
				if $ActivityLogFolder<>"" then
					$ActivityLogFolder=_ReplaceCMDEnvVar($ActivityLogFolder)
					if FileExists($ActivityLogFolder) and _IsFolder($ActivityLogFolder) Then
						$errorstatus="usingini"
						ConsoleWrite("-- Using Log File from INI file")
					else
						$errorstatus="ini"
					EndIf
				Else
					$ActivityLogFolder=$ActivityLogFolderTemp
				endif
			endif
			; set the  activity log file name variable
			$LogFileActivity=$ActivityLogFolder&"\" & "FileGodModeActivity.log"

			Switch $errorstatus
				Case "ini"
					MsgBox(48+4096, "Activity Log Folder error", "Activity Log Folder cannot be reached."&@crlf& _
									"There is a missconfiguration at the file " &$INIfile&@crlf& _
									"Using Log file: " & $LogFileActivity& @crlf& _
									@crlf&"ErrNo 2051",0)
				Case "settings"
					MsgBox(48+4096, "Activity Log Folder error", "Activity Log Folder cannot be reached." & @crlf & _
									"Configure it at " & @crlf & '"Settings -> Application preferences"' & @crlf & _
									"Folder configured: " & $ActivityLogFolder & @crlf & _
									"Using Log file: " & $LogFileActivity & @crlf & _
									@crlf&"ErrNo 2053",0)
			EndSwitch

			return $ActivityLogFolder
		EndFunc
		Func _ReplaceCMDEnvVar($ActivityLogFoldertmp)
			ConsoleWrite('++_ReplaceCMDfolder() = '& @crlf)
			Local $get=""
			$st=StringInStr($ActivityLogFoldertmp,"%",0,1)
			if $st>0 then
				Select
					Case StringInStr($ActivityLogFoldertmp,"%HOMEPATH%")>0 or StringInStr($ActivityLogFoldertmp,"%HOMEDRIVE%")>0
						$res=StringReplace($ActivityLogFoldertmp,"%HOMEPATH%",@HomePath)
						$res=StringReplace($res,"%HOMEDRIVE%",@HomeDrive)
					Case StringInStr($ActivityLogFoldertmp,"%~%")>0
						$res= StringReplace($ActivityLogFoldertmp,"%~%",@UserProfileDir)
					Case Else
						$ed=StringInStr($ActivityLogFoldertmp,"%",0,2)
						$envVar=StringMid($ActivityLogFoldertmp,$st+1,$ed-$st-1)
						$get = EnvGet($envVar)
						$res= StringReplace($ActivityLogFoldertmp,"%"&$envVar&"%",$get)
						$stnew=StringInStr($res,"%",0,1)
						if $stnew>0 then
							MsgBox(48+4096, "INI file error", 'Error in the [Debug] section for the "ActivityLogFolder" parameter configuration.' & _
										@crlf&'Accepted only CMD Environment variables.'&@crlf&@crlf&$res&@crlf&@crlf&"ErrNo 2050",0)
							$res=$ActivityLogFoldertmp
						endif
				EndSelect
			Else
				$res=$ActivityLogFoldertmp
			endif
			$res=$res
			ConsoleWrite('-- ' &$ActivityLogFoldertmp & " <=> " & $get & " <=> " & $res& @crlf )
			return $res
		EndFunc
		Func _ConsoleWrite($s_text,$logLevel="0")
			Switch $logLevel
				Case 0
					$logLevelmsg="DEBUG"
					$levelcolor="+"
				Case 1
					$levelcolor=">"
					$logLevelmsg="INFO"
				Case 2
					$levelcolor="-"
					$logLevelmsg="WARN"
				Case 3
					$levelcolor="!"
					$logLevelmsg="ERROR"
				Case Else
					$logLevelmsg="NA"
			EndSwitch
			FileWriteLine($hLogFile, _LogDate()&" ["& $logLevelmsg&"] " & $s_text )
;~ 			ConsoleWrite($levelcolor&"["& $logLevelmsg&"] " & $s_text & @CRLF)
			ConsoleWrite($s_text & @CRLF)
		EndFunc   ;==>_ConsoleWrite
		Func _LogDate()
			$tCur = _Date_Time_GetLocalTime()
			$tCur = _Date_Time_SystemTimeToDateTimeStr($tCur)
			$date = "[" & stringreplace($tCur,"/","-") & "] "
			return $date
		EndFunc
		Func _EndLog()
			ConsoleWrite('++_EndLog() = '& @crlf)
			FileWriteLine($hLogFile,"..............................................................................." )
			FileWriteLine($hLogFile,_NowCalcDate()   & @TAB& "End of activities")
			FileWriteLine($hLogFile,"..............................................................................." & @CRLF)
			FileClose($hLogFile)
		EndFunc
	#endregion
	Func _AreYouSureYesNo($question)
		If $question<>"" then
			$ans=MsgBox(4+32+256+4096, "Confirmation required", $question, 0)
			If $ans=6 Then Return true
			Return false
		endif
		Return true
	EndFunc
	Func _AreYouSureWarning($question)
		If $question<>"" then
			$ans=MsgBox(4+48+256+4096, "Warning execution errors", $question, 0)
			If $ans=6 Then Return true
			Return false
		endif
		Return true
	EndFunc
	Func _AreYouSureYesNoCancel($question)
		;$answerCANCEL=2		$answerYES=6		$answerNO=7
		If $question<>"" then
			$ans=MsgBox(3+32+256+4096, "Confirmation required", $question, 0)
			If $ans=2 or $ans=6 or $ans=7 Then Return $ans
		endif
		Return false
	EndFunc
	Func _FillTableSQL($tableCtrl,$arrsql,$autosize=0,$startColumn=1,$oneToTrue=0,$columnsToInverse=-1)  ; $columnsToInverse multiple columns separated by | starts a "0"
		ConsoleWrite('++_FillTableSQL() =' &$tableCtrl& @crlf )
		$inverseColumnsArr=StringSplit($columnsToInverse,"|")
;~ 		_printFromArray($inverseColumnsArr)
		_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($tableCtrl))
		_GUICtrlListView_BeginUpdate(GUICtrlGetHandle($tableCtrl))
		local $iColumns
		For $iRows = 1 To UBound($arrsql,1)-1
			local $linea=""
			For $iColumns = $startColumn To UBound($arrsql,2)-1
				If $oneToTrue=1 Then
					Switch $arrsql[$iRows][$iColumns]
						Case "1"
							If _ArraySearch($inverseColumnsArr,$iColumns)>0 Then
								$linea &= "No|"
							else
								$linea &= "Yes|"
							endif
						Case "0"
							If _ArraySearch($inverseColumnsArr,$iColumns)>0 Then
								$linea &= "Yes|"
							else
								$linea &= "No|"
							endif
						Case Else
							$linea &= $arrsql[$iRows][$iColumns] & "|"
					EndSwitch
				else
					$linea &= $arrsql[$iRows][$iColumns] & "|"
				endif
			next
			GUICtrlCreateListViewItem(StringTrimRight($linea,1),$tableCtrl)
		next
		_ResizeListViewColumns($tableCtrl,$arrsql,$iColumns,$autosize)
		_GUICtrlListView_EndUpdate(GUICtrlGetHandle($tableCtrl))
	EndFunc
	Func _ResizeListViewColumns($tableCtrl,$arrsql,$iColumns,$autosize=3)
		ConsoleWrite('++_ResizeListViewColumns() = '& @crlf)
		For $iColumn=0  To $iColumns
			$aColumn = _GUICtrlListView_GetColumn($tableCtrl, $iColumn)
			$aColumnTitleLen = StringLen(StringStripWS($aColumn[5],3))
			$maxCollen=0
			for $r=0 to UBound($arrsql)
				$aItem=_GUICtrlListView_GetItem($tableCtrl,$r,$iColumn)
				if $maxCollen<stringlen($aItem[3]) then $maxCollen=stringlen($aItem[3])
			next
			Select
				Case $autosize=1
					_GUICtrlListView_SetColumnWidth($tableCtrl, $iColumn, $LVSCW_AUTOSIZE)
				Case $autosize=2
					_GUICtrlListView_SetColumnWidth($tableCtrl, $iColumn, $LVSCW_AUTOSIZE_USEHEADER)
				case $autosize=0
					_GUICtrlListView_SetColumnWidth($tableCtrl, $iColumn, 90)
				Case $autosize=3
					if $aColumnTitleLen >= $maxCollen then
						_GUICtrlListView_SetColumnWidth($tableCtrl, $iColumn, $LVSCW_AUTOSIZE_USEHEADER)
					else
						_GUICtrlListView_SetColumnWidth($tableCtrl, $iColumn, $LVSCW_AUTOSIZE)
					endif
				Case else
					_GUICtrlListView_SetColumnWidth($tableCtrl, $iColumn, 10)
			EndSelect
		next
	EndFunc
	Func _FillComboSQL($ComboCtrl,$arrsql,$exclude="-",$iColumns=0)
		ConsoleWrite('++_FillComboSQL() = dimensions '& ubound($arrsql,0)& @crlf )
		GUICtrlSetData($ComboCtrl,"")
		local $linea=""
;~ 		ConsoleWrite('ubound($arrsql,0) = ' & ubound($arrsql,0) & @crlf )
		if ubound($arrsql,0)=1 then
			For $iRows = 1 To UBound($arrsql)-1
				If $exclude<>$arrsql[$iRows] Then $linea &= $arrsql[$iRows]& "|"
			next
			GUICtrlSetData($ComboCtrl,$linea)
		endif
		if ubound($arrsql,0)=2 then
			$iColumns = 0
			For $iRows = 1 To UBound($arrsql)-1
				If $exclude<>$arrsql[$iRows][$iColumns] Then $linea &= $arrsql[$iRows][$iColumns] & "|"
			next
			GUICtrlSetData($ComboCtrl,$linea)
		endif
		if ubound($arrsql,0)>2 then

		endif
	EndFunc
	Func _NoexistInList($listObject,$stringToFind,$columna=0) ;sart on zero first column
		ConsoleWrite('++_NOexistInList() = '& @crlf )
		$arr=_GUICtrlListView_CreateArray($listObject)
		$counter=0
		For $i=0 To UBound($arr)-1
			If StringStripWS($arr[$i][$columna],3)=$stringToFind Then $counter=$counter+1
		Next
		If $counter>0 Then
			Return False
		Else
			Return True
		endif
	EndFunc
	Func _GetIndexInList($listObject,$stringToFind,$columna=0) ;sart on zero first column
		ConsoleWrite('++_GetIndexInList() = '& @crlf )
		$arr=_GUICtrlListView_CreateArray($listObject)
		For $i=0 To UBound($arr)-1
			If StringStripWS($arr[$i][$columna],3)=$stringToFind Then Return $i-1
		Next
		Return -1
	EndFunc
	Func _NoexistInSTRinList($listObject,$InstringToFind,$columna=-1) ;sart on zero first column
		ConsoleWrite('++_NoexistInSTRinList() = '& @crlf )
		$arr=_GUICtrlListView_CreateArray($listObject)
		$counter=0
		For $i=1 To UBound($arr)-1
			If $columna=-1 Then
				$campo=$arr[$i][0]
			Else
				$campo=$arr[$i][$columna-1]
			endif
			If StringInStr(StringStripWS($campo,3),$InstringToFind)>0 Then $counter=$counter+1
		Next
		If $counter>0 Then
			Return False
		Else
			Return True
		endif
	EndFunc
	Func _ExistSTRinJOBList($listObject,$stringToFind,$columna=-1) ;sart on zero first column
		ConsoleWrite('++_NoexistInSTRinList() = '& @crlf )
		$arr=_GUICtrlListView_CreateArray($listObject)
		$counter=0
		For $i=1 To UBound($arr)-1
			If $columna=-1 Then
				$campo=$arr[$i][0]
			Else
				$campo=$arr[$i][$columna-1]
			endif
			If  StringStripWS($campo,3) = StringStripWS($stringToFind,3)  Then $counter=$counter+1
		Next
		If $counter>0 Then
			Return True
		Else
			Return False
		endif
	EndFunc
	func _GUICtrlListView_CreateArray_fromColumn($listObject,$columna=0)
		$ArrOut=""
		if _GUICtrlListView_GetItemCount($listObject)>0 then
			$arr=_GUICtrlListView_CreateArray($listObject)
			Dim $ArrOut[1]
			For $i=1 To UBound($arr)-1
				$ArrOut[$i-1]=$arr[$i][$columna]
				ReDim $ArrOut[$i+1]
			Next
			ReDim $ArrOut[$i-1]
			_printFromArray($ArrOut)
		endif
		return $ArrOut
	endfunc
	Func _CheckListIfInSTR($listObject,$InstringToSearch,$columna=-1) ;sart on zero first column - testeo cuando se usa PATH
		ConsoleWrite('++_CheckListIfInSTR() = '& @crlf )
		$arr=_GUICtrlListView_CreateArray($listObject)
		$counter=0
		For $i=1 To UBound($arr)-1
			If $columna=-1 Then
				$campo=$arr[$i][0]
			Else
				$campo=$arr[$i][$columna-1]
;~ 				ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $campo = ' & $campo & @crlf )
			endif
			If StringInStr($InstringToSearch,StringStripWS($campo,3)&"\")>0 Then $counter=$counter+1
		Next
		If $counter>0 Then
			Return True
		Else
			Return False
		endif
	EndFunc
	Func _CheckDuplicatesIn2Lists($listObject1,$listObject2,$columna=0) ;sart on zero first column
		ConsoleWrite('++_CheckDuplicatesIn2Lists() = '& @crlf )
		$arr1=_GUICtrlListView_CreateArray($listObject1)
		$arr2=_GUICtrlListView_CreateArray($listObject2)
		$counter=0
		For $i=1 To UBound($arr1)-1
			$campo1=$arr1[$i][$columna]
			For $j=1 To UBound($arr2)-1
				$campo2=$arr2[$j][$columna]
				If StringStripWS($campo1,3)=StringStripWS($campo2,3) and StringStripWS($campo1,3)<>"_dummyserver" and StringStripWS($campo2,3)<>"_dummyserver" Then $counter=$counter+1
			next
		Next
		If $counter>0 Then
			Return True
		Else
			Return False
		endif
	EndFunc
	Func _GetLineInList($listObject,$columna=0,$stringToFind="")
		ConsoleWrite('++_GetLineInList() = '& @crlf)
		$arr=_GUICtrlListView_CreateArray($listObject)
		$counter=0
		For $i=0 To UBound($arr)-1
			If StringStripWS($arr[$i][$columna],3)=$stringToFind Then
				$counter=$counter+1
				$lineValues=_GUICtrlListView_GetItemTextArray($listObject)
				Return $lineValues
			endif
		Next
		Dim $lineValues[1]
		$lineValues[0]=""
		Return $lineValues[0]
	EndFunc
	Func _CTRLRead($ctrlHandle)
		$res=StringStripWS(GUICtrlRead($ctrlHandle),3)
		If $res="0" Then $res=""
		Return $res
	EndFunc
	Func _GetSubItemText($nCtrlID, $nItemID, $nColumn) ; Retrieve the text of a listview item in a specified column
		Local $stLvfi = DllStructCreate("uint;ptr;int;int[2];int")
		Local $nIndex, $stBuffer, $stLvi, $sItemText

		DllStructSetData($stLvfi, 1, $LVFI_PARAM)
		DllStructSetData($stLvfi, 3, $nItemID)

		$stBuffer = DllStructCreate("char[260]")

		$nIndex = GUICtrlSendMsg($nCtrlID, $LVM_FINDITEM, -1, DllStructGetPtr($stLvfi));

		$stLvi = DllStructCreate("uint;int;int;uint;uint;ptr;int;int;int;int")

		DllStructSetData($stLvi, 1, $LVIF_TEXT)
		DllStructSetData($stLvi, 2, $nIndex)
		DllStructSetData($stLvi, 3, $nColumn)
		DllStructSetData($stLvi, 6, DllStructGetPtr($stBuffer))
		DllStructSetData($stLvi, 7, 260)

		GUICtrlSendMsg($nCtrlID, $LVM_GETITEMA, 0, DllStructGetPtr($stLvi));

		$sItemText = DllStructGetData($stBuffer, 1)

		$stLvi = 0
		$stLvfi = 0
		$stBuffer = 0

		Return $sItemText
	EndFunc   ;==>GetSubItemText
	Func _cleanLSTduplicates($listObject)
		ConsoleWrite('++_cleanLSTduplicates() = '& @crlf)
		Local $Topindex=_GUICtrlListView_GetItemCount($listObject)
		If $Topindex > 1 Then
			Local $avArray[1]
			For $i=0 To $Topindex -1
				$lineLST=_GUICtrlListView_GetItemTextString($listObject, $i)
				$inx=_ArraySearch($avArray,$lineLST)
				If @error =6 Then _ArrayAdd($avArray,$lineLST)
				_printFromArray($avArray)
			Next
			_GUICtrlListView_DeleteAllItems($listObject)
			For $i=1 To UBound($avArray)-1
				GUICtrlCreateListViewItem($avArray[$i],$listObject)
			next
		endif
	EndFunc
	Func _cleanLSTCheckboxes($listObject)
		ConsoleWrite('++_cleanLSTCheckboxes() = '& @crlf)
		Local $Topindex=_GUICtrlListView_GetItemCount($listObject)
		If $Topindex > 1 Then
			For $i=0 To $Topindex-1
				_GUICtrlListView_SetItemChecked($listObject,$i,false)
			Next
		endif
	EndFunc
	Func _HasLSTCheckBoxCheched($listObject)
		ConsoleWrite('++_HasLSTCheckBoxCheched() = '& @crlf)
		Local $Topindex=_GUICtrlListView_GetItemCount($listObject)
		$counterDataInLST=0
		If $Topindex > 1 Then
			For $i=0 To $Topindex-1
				If _GUICtrlListView_GetItemChecked($listObject,$i) Then $counterDataInLST+=1
			Next
		endif
		If $counterDataInLST>0 Then Return true
		Return false
	EndFunc
	Func _GUICtrlListView_GetItemsSelectedByColumn($lstOBJ,$column)
		ConsoleWrite('++_GUICtrlListView_GetItemsSelectedByColumn() = '& @crlf)
		$aDdata=""
		$aSelcted = _GUICtrlListView_GetSelectedIndices($lstOBJ, True)
		If $aSelcted[0] > 0 Then
			Dim $aDdata[$aSelcted[0] + 1]
			$aDdata[0] = $aSelcted[0]
			For $i = 1 To $aSelcted[0]
				$lstOBJarr = _GUICtrlListView_GetItem($lstOBJ, $aSelcted[$i],$column)
				$aDdata[$i] = $lstOBJarr[3]
			Next
		EndIf
		If IsArray($aDdata) Then
			_printFromArray($aDdata)
			Return $aDdata
		Else
			Return False
		endif
	EndFunc
	#region ================================ general                      =======================
		Func _TableCheckSSet($tableCtrl,$arrsql,$CheckCol)
			ConsoleWrite('++_TableCheckSSet() = '& @crlf )
			_GUICtrlListView_BeginUpdate(GUICtrlGetHandle($tableCtrl))
			If $CheckCol>UBound($arrsql,2) Then
;~ 				MsgBox(0,"_TableCheckSSet",$CheckCol & "-"&UBound($arrsql,2) ,4)
			else
				For $iRows = 1 To UBound($arrsql,1)-1
					if $arrsql[$iRows][$CheckCol]=1 Then _GUICtrlListView_SetItemChecked(GUICtrlGetHandle($tableCtrl),$iRows-1,True)
				next
			endif
			_GUICtrlListView_EndUpdate(GUICtrlGetHandle($tableCtrl))
		EndFunc
		Func _ControlStateEmpty($CheckCtlr,$SetCtrl)
			ConsoleWrite('++ControlStateEmpty() = '& @crlf )
			if _CtrlRead($CheckCtlr)="" then
				GUICtrlSetState($SetCtrl,$GUI_DISABLE)
			Else
				GUICtrlSetState($SetCtrl,$GUI_ENABLE)
			endif
		EndFunc
		Func _FormMinSize($formHandle,$MinW = 150, $MinH = 150)
			$size = WinGetPos($formHandle)
			If $size[2] < $MinW Then WinMove($formHandle, "", $size[0], $size[1], $MinW, $size[3])
			If $size[3] < $MinH Then WinMove($formHandle, "", $size[0], $size[1], $size[2], $MinH)
		EndFunc
		Func _MergeSQLdbQry2D($avArrayTarget,$avArraySource,$iColumn=0,$iunique=0) ;$iColumn is the one to merge, all other collumns are discarded
			ConsoleWrite('++_MergeSQLdbQry2D() = '& @crlf)
			ConsoleWrite(" >>$avArrayTarget Rows="&ubound($avArrayTarget,1)&"   Cols="&ubound($avArrayTarget,2)&@crlf)
			_printFromArray($avArrayTarget)
			ConsoleWrite(" >>$avArraySource Rows="&ubound($avArraySource,1)&"   Cols="&ubound($avArraySource,2)&@crlf)
			_printFromArray($avArraySource)

			dim $avArrayTargetC[1]
			for $i=0 to UBound($avArrayTarget)-1
				_ArrayAdd($avArrayTargetC,$avArrayTarget[$i][$iColumn])
			next
			_ArrayDelete($avArrayTargetC,0)

			dim $avArraySourceC[1]
			for $i=0 to UBound($avArraySource)-1
				_ArrayAdd($avArraySourceC,$avArraySource[$i][$iColumn])
			next
			_ArrayDelete($avArraySourceC,0)

			Select
				Case IsArray($avArrayTargetC) And IsArray($avArraySourceC)
					_ArrayDelete($avArraySourceC,0)
					_ArrayConcatenate($avArrayTargetC,$avArraySourceC)
					$err=@error
					If $err Then
					Else
						ConsoleWrite('$iunique = ' & $iunique & @crlf )
						if $iunique=1 then
							$avArrayTargetC=_ArrayUnique($avArrayTargetC)
							_ArrayDelete($avArrayTargetC,0)
						endif
							ConsoleWrite(" >>$avArrayTargetC Rows="&ubound($avArrayTargetC)&@crlf)
							_printFromArray($avArrayTargetC)
						Return $avArrayTargetC
					endif
				Case IsArray($avArrayTargetC)
					ConsoleWrite("! >>$avArrayTargetC  NOT Unique Rows="&ubound($avArrayTargetC)&@crlf)
					Return $avArrayTargetC
				Case IsArray($avArraySourceC)
					ConsoleWrite("! >>$avArraySourceC  NOT Unique Rows="&ubound($avArraySourceC)&@crlf)
					Return $avArraySourceC
			endselect

			Switch $err
				Case 1
					ConsoleWrite("!$avArrayTarget is not an array " & @crlf)
				Case 2
					ConsoleWrite("!$avArraySource is not an array  " & @crlf)
				Case 3
					ConsoleWrite("! $avArrayTarget is not a 1 dimensional array " & @crlf)
				Case 4
					ConsoleWrite("!$avArraySource is not a 1 dimensional array" & @crlf)
				Case 5
					ConsoleWrite("! $avArrayTarget and $avArraySource are not a 1 dimensional array " & @crlf)
				Case Else
			EndSwitch

			Dim $arr[1]
			$arr[0]=""
			Return $arr
		EndFunc
		Func _MergeSQLdbQry1D($avArrayTarget,$avArraySource,$iunique=0)
			ConsoleWrite('++_MergeSQLdbQry1D() = '& @crlf)
			_printFromArray($avArrayTarget)
			_printFromArray($avArraySource)
			Select
				Case IsArray($avArrayTarget) And IsArray($avArraySource)
					_ArrayDelete($avArraySource,0)
					_ArrayConcatenate($avArrayTarget,$avArraySource)
					$err=@error
					If $err Then
					Else
						if $iunique=1 then _ArrayUnique($avArrayTarget)
						_printFromArray($avArrayTarget)
						Return $avArrayTarget
					endif
				Case IsArray($avArrayTarget)
					Return $avArrayTarget
				Case IsArray($avArraySource)
					Return $avArraySource
			endselect

			Switch $err
				Case 1
					ConsoleWrite("!$avArrayTarget is not an array " & @crlf)
				Case 2
					ConsoleWrite("!$avArraySource is not an array  " & @crlf)
				Case 3
					ConsoleWrite("! $avArrayTarget is not a 1 dimensional array " & @crlf)
				Case 4
					ConsoleWrite("!$avArraySource is not a 1 dimensional array" & @crlf)
				Case 5
					ConsoleWrite("! $avArrayTarget and $avArraySource are not a 1 dimensional array " & @crlf)
				Case Else
			EndSwitch

			Dim $arr[1]
			$arr[0]=""
			Return $arr
		EndFunc
		Func _ArrayMoveMemberToEnd1D($arr,$idxString)
			ConsoleWrite('++_ArrayMoveMemberToEnd1D() = '& @crlf)
			Local $iIndex=_ArraySearch($arr,$idxString, 0, 0, 0, 1)
			$err=@error
			If $err Then
				MsgBox(48+4096,"Error reading Projects from DB ","An error reading Projects from DB FGMbase. ErrNo 2021" & @CRLF ,0,0)
			EndIf
			Local $value=$arr[$iIndex]
			If @error Then
				ConsoleWrite("Was not found in the array.")
				return $arr
			Else
				_ArrayDelete($arr,$iIndex)
				_ArrayAdd($arr,$value)
				return $arr
			EndIf
		EndFunc
		Func IconButton($BItext, $BIleft, $BItop, $BIwidth, $BIheight, $BIconSize, $BIDLL, $BIconNum = -1)
			GUICtrlCreateIcon($BIDLL, $BIconNum, $BIleft + 5, $BItop + (($BIheight - $BIconSize) / 2), $BIconSize, $BIconSize)
			GUICtrlSetState( -1, $GUI_DISABLE)
			GUICtrlSetResizing(-1,$GUI_DOCKleft+$GUI_DOCKTOP+$GUI_DOCKSIZE)
			$XS_btnx = GUICtrlCreateButton($BItext, $BIleft, $BItop, $BIwidth, $BIheight, $WS_CLIPSIBLINGS)   ;,$WS_EX_TOPMOST
			Return $XS_btnx
		EndFunc
		Func _ExistInCMB($cmbObject,$needle)
			ConsoleWrite('++_ExistInCMB() = '& @crlf)
			$counterDataInCMB=0
			$aList = _GUICtrlComboBox_GetListArray($cmbObject)
			_printFromArray($aList)
			For $x = 1 To $aList[0]
				If StringStripWS($aList[$x],3)=StringStripWS($needle,3) Then $counterDataInCMB +=1
			Next
			If $counterDataInCMB=0 Then Return False
			Return true
		EndFunc
		Func _LoopTimerInit()
			ConsoleWrite('!++_LoopTimerInit() = '& @crlf)
			Global $LoopTimer = TimerInit()
		EndFunc
		Func _LoopTimerEnd()
			ConsoleWrite('!++_LoopTimerEnd() = '& @crlf)
			Global $LoopTimer = TimerInit()
		EndFunc
		Func _LoopTimerCheck($seconds)
			ConsoleWrite('!++_LoopTimerCheck() = ')
			$miliseconds=$seconds*1000
			$diff=TimerDiff($LoopTimer)
			if $diff>$miliseconds then
				ConsoleWrite(' True '& $diff&@crlf)
				return true
			Else
				ConsoleWrite(' false '& $diff&@crlf)
				return false
			endif
		EndFunc
		#region Sort list
			Func LVSortReport($hWnd, $nItem1, $nItem2, $nColumn)  ; HAY QUE PONER LOGICA EN -> Case -108 ;$NM_CLICK
				Local $val1, $val2, $nResult
				; Switch the sorting direction
				If $nColumn = $nCurCol Then
					If Not $bSet Then
						$nSortDir = $nSortDir * - 1
						$bSet = 1
					EndIf
				Else
					$nSortDir = 1
				EndIf
				$nCol = $nColumn
				;$nCurCol = $nColumn
				$val1 = GetSubItemText($hWnd, $nItem1, $nColumn)
				$val2 = GetSubItemText($hWnd, $nItem2, $nColumn)
				$nResult = 0 ; No change of item1 and item2 positions
				If $val1 < $val2 Then
					$nResult = -1 ; Put item2 before item1
				ElseIf $val1 > $val2 Then
					$nResult = 1 ; Put item2 behind item1
				EndIf
				$nResult = $nResult * $nSortDir
				Return $nResult
			EndFunc   ;==>LVSort
			Func GetSubItemText($nCtrlID, $nItemID, $nColumn)    ;~ ; Retrieve the text of a listview item in a specified column
				Local $stLvfi = DllStructCreate("uint;ptr;int;int[2];int")
				Local $nIndex, $stBuffer, $stLvi, $sItemText

				DllStructSetData($stLvfi, 1, $LVFI_PARAM)
				DllStructSetData($stLvfi, 3, $nItemID)

				$stBuffer = DllStructCreate("char[260]")

				$nIndex = GUICtrlSendMsg($nCtrlID, $LVM_FINDITEM, -1, DllStructGetPtr($stLvfi));

				$stLvi = DllStructCreate("uint;int;int;uint;uint;ptr;int;int;int;int")

				DllStructSetData($stLvi, 1, $LVIF_TEXT)
				DllStructSetData($stLvi, 2, $nIndex)
				DllStructSetData($stLvi, 3, $nColumn)
				DllStructSetData($stLvi, 6, DllStructGetPtr($stBuffer))
				DllStructSetData($stLvi, 7, 260)

				GUICtrlSendMsg($nCtrlID, $LVM_GETITEMA, 0, DllStructGetPtr($stLvi));

				$sItemText = DllStructGetData($stBuffer, 1)

				$stLvi = 0
				$stLvfi = 0
				$stBuffer = 0

				Return $sItemText
			EndFunc   ;==>GetSubItemText
		#endregion
	#endregion
#endregion
#region ==================================== Forms                        =======================
	#region ******************************** FORM Common                  ***********************
		Func _CheckTaskID()
			ConsoleWrite('++_CheckTaskID() = '& @crlf)
			$newtask=0
			If $taskID=0 Then
				$newtask=1
				_CreateTaskID()  ; create a unike task id
			endif
		EndFunc
		Func _CheckCRTLRegex($field)
			ConsoleWrite('++_CheckCRTLRegex() = ' & @crlf)
			Switch $field
				Case $TXT_TaskFolderCreation_SourceZIPFilter
					ConsoleWrite('$TXT_TaskFolderCreation_SourceZIPFilter'& @crlf)
					If _ctrlread($CMB_jobcreation_selecttask)="Decompression Task" Then
						Return StringRegExp(_ctrlRead($field),"(\A[a-zA-Z0-9\s_*?.]+\Z)",0)
					Else
						Return StringRegExp(_ctrlRead($field),"((\A([a-zA-Z0-9\s_*?]+[.]+)+[a-zA-Z0-9~_*?]+\Z)|(\A[*]\Z))",0)
					endif
				Case $TXT_TaskFolderCreation_SourcePath,$TXT_TaskFolderCreation_TargetPath
					ConsoleWrite('$TXT_TaskFolderCreation_SourcePath,$TXT_TaskFolderCreation_TargetPath'& @crlf)
					$resShare= StringRegExp(_CtrlRead($field),"(\A(\\{1}[a-zA-Z0-9\s_.]+)+\z)",0)
					$resNormal=StringRegExp(_CtrlRead($field),"(\A[c-zC-Z]{1}:{1}(\\{1}[a-zA-Z0-9\s_.$*]+)+\Z)",0)
					$resNormalroot= StringRegExp(_CtrlRead($field),"(\A[c-zC-Z]{1}:{1}\\{1}\Z)",0)
					$resto= ($resShare or $resNormal Or $resNormalroot)
					Return 	$resto
				Case $TXT_TaskFolderCreation_TargetPathFilter  ;repetido de $TXT_TaskFolderCreation_SourceZIPFilter
					ConsoleWrite('$TXT_TaskFolderCreation_TargetPathFilter'& @crlf)
					Return StringRegExp(_ctrlRead($field),"((\A([a-zA-Z0-9\s_*?]+[.]+)+[a-zA-Z0-9~_*?$]+\Z)|(\A[*]\Z))",0)
				Case $TXT_TaskFolderCreation_TargetZIPfilename
					ConsoleWrite('$TXT_TaskFolderCreation_TargetZIPfilename'& @crlf)
					If _ctrlRead($field)="Autonaming" Then Return True
					Return StringRegExp(_ctrlRead($field),"(\A([a-zA-Z0-9\s_\[\]]+[.]+)+zip\Z)",0)
				Case $TXT_custsharepath
					ConsoleWrite('$TXT_custsharepath'& @crlf)
					$resShare= StringRegExp(_ctrlRead($field),"(\A\\{2}[a-zA-Z0-9.]+(\\{1}[a-zA-Z0-9]+)\z)",0)
					$resPesos= StringRegExp(_ctrlRead($field),"(\A\\{2}[a-zA-Z0-9.]+\\{1}[a-zA-Z]{1}[$]{1}((\\{1}[a-zA-Z0-9]+)+\z)?\z)",0)
					$resto= ($resShare or $resPesos)
					Return 	$resto
				Case $TXT_TaskExecution_TargetPath
					$resNormal=StringRegExp(_CtrlRead($field),"(\A[c-zC-Z]{1}:{1}(\\{1}[a-zA-Z0-9\s_.$*]+)+\Z)",0)
					Return 	$resNormal
				case $TXT_settingspref_ExecutableWorkingFolder
					$resNormal=StringRegExp(_CtrlRead($field),"(\A[c-zC-Z]{1}:{1}(\\{1}[a-zA-Z0-9\s_.$*]+)+\Z)",0)
					Return 	$resNormal
				Case Else
					MsgBox(4096,"caca","la cagaste , por aqui no se pasa",0)
;~ 					ConsoleWrite('++_CheckCRTLRegex() = caca la cagaste , por aqui no se pasa' & @crlf)
			EndSwitch
		EndFunc
		Func _PosXaxis($formWidth,$posX)
			ConsoleWrite('++_PosXaxis() = '& @crlf)
	;~ 		$posxis= $posX-(($formWidth-$ParentWide)/2)
			If $posX-$formWidth/2< 0 Then
				$posxis= 0
			Else
				$posxis= $posX-$formWidth/2
			endif
			Return $posxis
		EndFunc
		Func _lineaV($leftIndent,$top,$wd=100)
			GUICtrlCreateButton("", $leftIndent, $top, $wd, 3)  ; linea separadora
				GUICtrlSetState(-1,$GUI_DISABLE)
		EndFunc
		Func _setTypeUpdate($objCK,$vertice)
			ConsoleWrite('++_setTypeUpdate() = '& @crlf)
			if _CheckIfTypeUpdate($vertice) then  GUICtrlSetState($objCK,$GUI_CHECKED)
		EndFunc
		Func _TypeUpdatedFlag($vertice)
			ConsoleWrite('++_TypeUpdatedTRGFlag() = '& @crlf)
			if $vertice="TargetLoc"  then
				If _IsChecked($CK_TaskForms_UpdateTypesTRG) Then return 1
			endif
			if $vertice="SourceLoc" then
				If _IsChecked($CK_TaskForms_UpdateTypesSRC) Then return 1
			endif
			return 0
		EndFunc
		Func _Fill_Task_LST($listObject,$vertice,$startColumn=0)
			ConsoleWrite('++_Fill_Task_LST() = ' & @crlf )
			if $vertice="TargetLoc" or $vertice="SourceLoc" then
				if _CheckIfTypeUpdate($vertice) then _TypeUpdateDB($vertice)
			endif
			$query='SELECT type,unit,filter  FROM tasks WHERE taskuid="' & $taskid & '" AND vertice="' & $vertice & '";'
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
			If  IsArray($qryResult) then _FillTableSQL($listObject,$qryResult,3,$startColumn)
		EndFunc
		Func _CheckIfTypeUpdate($vertice)
			ConsoleWrite('++_CheckIfTypeUpdate() = '&$vertice & @crlf)
			if $vertice="TargetLoc" or $vertice="SourceLoc" then
				$query='SELECT typeUpdate  FROM tasks WHERE taskuid="' & $taskid & '" AND vertice="' & $vertice & '";'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) AND UBound($qryResult)>1  then
					ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $qryResult[1][0] = ' & $qryResult[1][0] & @crlf )
					if $qryResult[1][0]=0 then return False
					Return true
				endif
				return false
			Else
				return false
			endif
		EndFunc
		Func _TypeUpdateDB($vertice)
			ConsoleWrite('!++_TypeUpdateDB() $vertice'&$vertice& @crlf)
			;get the distinct types
				$query='SELECT distinct(type||"|"||filter) FROM tasks WHERE taskuid="' & $taskid & '" AND vertice="' & $vertice & '";'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				$distinctTypesArr = $qryResult
			;delete vertice rows sourceloc o targetloc  having localhost-groups-custon groups
				If  IsArray($distinctTypesArr) AND UBound($distinctTypesArr)>1 then
					for $ic=1 to ubound($distinctTypesArr)-1
						$distinctTypes = StringSplit($distinctTypesArr[$ic][0],"|")
						$type = $distinctTypes[1]
						$Grupo = $distinctTypes[2]  ; columnn filter
						Select
							Case $type = "Localhost"
;~ 								$query='UPDATE tasks SET unit="' & @ComputerName & '" WHERE type="Localhost" AND taskuid="' & $taskid & '" AND vertice="' & $vertice & '";'
								;_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
							Case ($type = "Groups" OR $type = "Custom Groups" )
							;get row data
								$query='SELECT taskuid,tasktype,vertice,type,unit,jobuid,taskname,domain,login,taskorder,filter,active,commands,Grupo,TypeUpdate FROM tasks ' & _
									   ' WHERE taskuid="' & $taskid & '" AND vertice="' & $vertice & '" AND filter="' & $Grupo & '" AND type="' & $type & '"   LIMIT 2 ;'								;_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
								_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
								$rowData = $qryResult
								_printFromArray($rowData,"_TypeUpdateDB")
							;get list of servers
								$id='SELECT groupid FROM servergroups where servergroupname="'& $Grupo &'"'
								$query='SELECT Servers.servername FROM Servers INNER JOIN RServerGroup ON RServerGroup.serverID = Servers.serverid ' & _
									'INNER JOIN servergroups ON RServerGroup.groupid  = servergroups.groupid WHERE servergroups.groupid=(' & $id & ') order by Servers.servername;'
								_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
								$serversInGroup = $qryResult
;~ 							; delete and insert
								$queryA='BEGIN TRANSACTION;DELETE FROM tasks WHERE taskuid="' &$taskid& '" AND vertice="' &$vertice& '" AND filter="' &$Grupo& '" AND type="' &$type& '" ;'
								If  IsArray($serversInGroup) AND UBound($serversInGroup)>1 then
									for $iv=1 to ubound($serversInGroup)-1
										$servername = $serversInGroup[$iv][0]
										$queryA&='INSERT INTO tasks VALUES (null,' & _
											$rowData[1][0] & ',"' & $rowData[1][1] & '","' & $rowData[1][2] & '","' & $rowData[1][3] & '","' & $servername  & '",' & _
											$rowData[1][5] & ',"' & $rowData[1][6] & '","' & $rowData[1][7] & '","' & $rowData[1][8] & '",' & $rowData[1][9] & ',"' & _
											$rowData[1][10] & '",' & $rowData[1][11] & ',"' & $rowData[1][12] & '","' & $rowData[1][13] & '",' & $rowData[1][14] & ' );'
									Next
									$queryA&="COMMIT;"
									if _SQLITErun($queryA,$profiledbfile,$quietSQLQuery) Then
										Return true
									Else
										MsgBox(48+4096,"Auto Type Update error","An error While Type Updating . ErrNo 994" & @CRLF & $query,0,0)
										Return false
									EndIf
								endif
								Return false
							Case $type = "Servers"
							Case $type = "Shares"
							Case Else
								MsgBox(0,"imposible error","this error shouldnt happend.  Type do not exist or not found. ErrNo 993" & @crlf& $type ,0)
						EndSelect
					next
				endif
				Return false
		EndFunc
	#endregion
	#region ******************************** FORM Main                    ***********************
		Func  Menu_help_Pressed()
			ConsoleWrite('++Menu_help_Pressed() = '& @crlf)
			MsgBox(0, "Help      FileGodMode Version " & $version , "" & _
					   "        FileGodMode      Version "& $version & _
			@CRLF  &   "_____________________________________________________________"  & @CRLF  & @CRLF  & @CRLF  & _
			@CRLF  &   "Feddback & comments , please send to:  "  & _
			@CRLF  &   " Roberto.p.Iralour@accenture.com  or MarceloSaied@gmail.com"  & _
			@CRLF  &  _
			@CRLF  &    "                                            Thanks          " , 10)
			Sleep(1000)
			$correWD=ShellExecute($FgmDataFolderResources & "\FGMhelp.CHM")
		EndFunc
		Func  Menu_About_Pressed()
			ConsoleWrite('++Menu_About_Pressed() = '& @crlf)
			ShowAboutForm()
		EndFunc
		Func  Menu_Update_Pressed()
			ConsoleWrite('++Menu_Update_Pressed() = '& @crlf)
			_checkVersion(1)
		EndFunc
		Func  Menu_CheckVersion_Pressed()
			ConsoleWrite('++Menu_CheckVersion_Pressed() = '& @crlf)
			_checkVersion()
		EndFunc
		Func  Menu_CheckPrjDB_Pressed()
			ConsoleWrite('++Menu_CheckPrjDB_Pressed() = '& @crlf)
			_CkeckPrjDBRepoFiles(1) ; $flagForceUpdateRepodb=1
			_FillDatabaseListbox()
			$LBLTimerBegin = TimerInit()
			$FlagLBLhide=1
		EndFunc
		Func  Menu_Settings_Pressed($nID=3000)
			ConsoleWrite('++Menu_Settings_Pressed() = $nID='&$nID & "  TAB="&$nID-3000& @crlf)
			if $nID=3000 then
				ShowSettingsForm($nID-3000)
			Else
				ShowSettingsForm($nID-3001)
			EndIf
		EndFunc
		Func _CheckcomputerMembership()
			ConsoleWrite('++_CheckcomputerMembership() = '& @crlf)
			$query='SELECT servergroups.servergroupname FROM Servers INNER JOIN RServerGroup ON RServerGroup.ServerID = Servers.serverid ' & _
				' INNER JOIN servergroups ON RServerGroup.groupID =  servergroups.groupid  WHERE Servers.servername LIKE "%'&@ComputerName&'%"  AND Servers.custom=0;'
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
			If  IsArray($qryResult) Then
				if UBound($qryResult)>1 then
					_printFromArray($qryResult)
					$res=$qryResult[1][0]
					If $res<>"" And $res<>"-" Then
						Return "  member of  " & $res
					Else
						Return ""
					endif
				endif
			endif
			Return ""
		EndFunc
		Func _MainFormBTNdisable($st)
			ConsoleWrite('++_MainFormBTNdisable() = '& @crlf)
			If $st Then
				GUICtrlSetState($btn_CreateJob,$GUI_ENABLE)
				GUICtrlSetState($btn_config,$GUI_ENABLE)
				GUICtrlSetState($B_Close,$GUI_ENABLE)
			Else
				GUICtrlSetState($btn_CreateJob,$GUI_DISABLE)
				GUICtrlSetState($btn_config,$GUI_DISABLE)
				GUICtrlSetState($B_Close,$GUI_DISABLE)
			endif
			if _CtrlRead($CMB_DatabaseSelect)=_ActiveDatabaseValue() And _CtrlRead($CMB_DatabaseSelect)<>"" then
				GUICtrlSetstate($btn_CreateJob,$GUI_ENABLE)
				GUICtrlSetstate($btn_config,$GUI_ENABLE)
				GUICtrlSetstate($B_setDB,$GUI_disable)
			Else
				GUICtrlSetstate($btn_CreateJob,$GUI_disable)
				GUICtrlSetstate($btn_config,$GUI_disable)
			EndIf
		EndFunc
		Func _FillDatabaseListbox()
			ConsoleWrite('++_FillDatabaseListbox() = '& @crlf )
			_GUICtrlComboBox_ResetContent($CMB_DatabaseSelect)
			$query="SELECT value FROM Configuration WHERE config='FGMdatabase';"
			_SQLITEqry($query,$Basedbfile,$quietSQLQuery)
			$qryResult1=$qryResult
			_verifyProjectsInProfileDB()
			$query="SELECT value FROM Configuration WHERE config='FGMdatabase';"
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
			$qryResult2=$qryResult
			$qryResult=_MergeSQLdbQry2D($qryResult1,$qryResult2,0,1)
			If  IsArray($qryResult) Then
				if UBound($qryResult)>1 then
					$qryResult=_ArrayMoveMemberToEnd1D($qryResult,"No Project")
				EndIf
			else
				MsgBox(48+4096,"Error reading Projects from DB ","An error reading Projects from DB FGMbase. ErrNo 2022" & @CRLF ,0,0)
			EndIf
			If IsArray($qryResult) then
				if UBound($qryResult)>1 then
					_FillComboSQL($CMB_DatabaseSelect,$qryResult)
				endif
			endif
			_GUICtrlComboBox_AddString($CMB_DatabaseSelect,"")
			_GUICtrlComboBox_SelectString($CMB_DatabaseSelect,_ActiveDatabaseValue())
			If _ctrlread($CMB_DatabaseSelect)="" Then GUICtrlSetstate($LBL_setdb,$GUI_SHOW)
		EndFunc
		Func _loadDatabase($sDB)
			ConsoleWrite('!!++loadDatabase() = '& @crlf)
			$query='UPDATE Configuration SET value="'&$sDB& '" , key="'&_GetDatabaseFile($sDB)&'" WHERE Config="FGMactive"'
			if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
			Else
				MsgBox(48+4096,"Setting project database error","An error setting the project database. ErrNo 1050" & @CRLF & $query,0,0)
			EndIf
		EndFunc
		Func _Clear_TaskCreation_Variables()
			ConsoleWrite('++_Clear_TaskCreation_Variables() = '& @crlf)
			_TaskFormsInit()
		EndFunc
		Func _CheckTaskDescription()
			ConsoleWrite('++_CheckTaskDescription() = ' & $jobID& @crlf )
			$query='SELECT taskname FROM tasks WHERE taskuid=' & $taskID
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
			If  IsArray($qryResult) then
				If UBound($qryResult)>1 then
					Return $qryResult[1][0]
				Else
					Return ""
				endif
			endif
		EndFunc
	#endregion
	#region ******************************** FORM SETTINGS                ***********************
		#include <Func_FormSettings.au3>
	#endregion
	#region ******************************** FORM CREATEJOB               ***********************
		Func _CreateTaskID()
			ConsoleWrite('++_CreateTaskID() = '& @crlf )
			$TaskID=@YDAY&@HOUR&@MIN&@sec&Random(0,99,1)
			Sleep(100)
		EndFunc
		Func _CreateJobID()
			ConsoleWrite('++_CreateJobID() = '& @crlf )
			$JobID=@YDAY&@HOUR&@MIN&@sec
		EndFunc
		Func _FilljobcreationFormData()
			ConsoleWrite('++_FilljobcreationFormData() = '& @crlf )
			_DeleteCredassert()
			_FillJobList()
			$taskID=0
			$jobID=0
		EndFunc
		Func _FillJobList()
			ConsoleWrite('++_FillJobList() = '& @crlf )
			If GUICtrlRead($CK_JobCreation_Showjob)=$GUI_CHECKED Then
				$query='SELECT jobname,jobdesc,backup FROM jobs;'
			Else
				$query='SELECT jobname,jobdesc,backup FROM jobs WHERE backup=0;'
			endif
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
			If  IsArray($qryResult) then
				_FillTableSQL($LST_JobCreation_JobList,$qryResult,3,0,1)
			endif
		EndFunc
		Func _selectJobInList()
			ConsoleWrite('++_selectJobInList() = '& @crlf)
			If StringStripWS($jobid,3) <> "" then
				$query='SELECT jobname FROM jobs WHERE jobuid=' & $jobid
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) and UBound($qryResult,1)>1 then  ;[columnas][lineas]
					$res=$qryResult[1][0]
					If StringStripWS($res,3)<>"" then
						$res=_GetIndexInList($LST_JobCreation_JobList,$res,0)
						_GUICtrlListView_SetItemSelected($LST_JobCreation_JobList, $res)
					endif
				endif
			endif
		EndFunc
		Func _FillTaskJobList($selectedIndex=0)
			ConsoleWrite('++_FillTaskJobList() = '& @crlf )
			If $jobid<>"" Then
				$query='SELECT tasktype,taskname,taskuid,active FROM tasks WHERE jobuid=' & $jobid & ' GROUP BY taskuid ORDER BY taskorder;'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					$listUpdateFlag_tasklist=true
					_FillTableSQL($LST_jobcreation_tasklist,$qryResult,3,0)
					$listUpdateFlag_tasklist=False
				endif
				_TableCheckSSet($LST_jobcreation_tasklist,$qryResult,3)
				_GUICtrlListView_SetColumnWidth($LST_jobcreation_tasklist, 2, 1)
			endif
			if $selectedIndex<>0 then
				$listUpdateFlag_tasklist=true
				_GUICtrlListView_SetHotItem($LST_jobcreation_tasklist, $selectedIndex)
				$listUpdateFlag_tasklist=False
			endif
		EndFunc
		Func _CheckJobId()
			ConsoleWrite('++_CheckJobId() = '& @crlf )
			If _NOexistInList($LST_JobCreation_JobList,GUICtrlRead($TXT_JobCreation_jobname),0) Then
				_CreateJobID()
			Else
				$query='SELECT jobuid FROM jobs WHERE jobname="' & GUICtrlRead($TXT_JobCreation_jobname) & '"'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					If UBound($qryResult)>1 then
						$JobID=$qryResult[1][0]
						Return $JobID
					Else
						Return 0
					endif
				endif
			endif
		EndFunc
		Func _CheckJobDescription()
			ConsoleWrite('++_CheckJobDescription() = ' & $jobID& @crlf )
			If $jobID<>"" Then
				$query='SELECT jobdesc FROM jobs WHERE jobuid=' & $jobID
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					If UBound($qryResult)>1 then
						Return $qryResult[1][0]
					Else
						Return ""
					endif
				endif
			endif
			Return ""
		EndFunc
		Func _JobCreationDeleteTask()
			ConsoleWrite('++_JobCreationDeleteTask() = '& @crlf )
			If _GUICtrlListView_GetSelectedCount($LST_jobcreation_tasklist)=1 Then
				$lineValues=_GUICtrlListView_GetItemTextArray($LST_jobcreation_tasklist)
				$taskid=$lineValues[3]   ; task uid
				$taskorder=_Get_TaskOrder()
				$query='DELETE FROM tasks WHERE taskuid="' & $taskid& '";'
				_SQLITErun($query,$profiledbfile,$quietSQLQuery)  ; delete it
				$taskOrderTop=_Get_TaskOrderTop()
				For $i=$taskorder To $taskOrderTop
					_update_TaskOrder($i,$i+1)
				next
				_JobCreation_disabletasks()
			endif
		EndFunc
		Func _Get_TaskOrder()
			ConsoleWrite('++_Get_TaskOrder() = '& @crlf)
			$query='SELECT taskorder FROM tasks WHERE taskUID=' & $taskid
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)  ; task order
			If  IsArray($qryResult) then
				If UBound($qryResult)>1 then
					Return $qryResult[1][0]
				endif
			endif
			Return 0
		EndFunc
		Func _Get_TaskOrderTop()
			ConsoleWrite('++_Get_TaskOrderTop() = '& @crlf)
			$query='SELECT taskorder FROM tasks WHERE jobUID=' & $jobid & " ORDER BY taskorder DESC"
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)   ; get top task order for the task
			If  IsArray($qryResult) then
				If UBound($qryResult)>1 then
					Return $qryResult[1][0]
				endif
			endif
			Return 0
		EndFunc
		Func _update_TaskOrder($tskorderNew,$tskorderbefore)
			ConsoleWrite('++_update_TaskOrder() = '&$tskorderNew& "  " & $tskorderbefore& @crlf)
			$query='UPDATE tasks SET taskorder='&$tskorderNew&' WHERE jobuid='&$jobid&' and taskorder='&  $tskorderbefore
			if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
			Else
				MsgBox(48+4096,"Saving Task data error","An error saving Task data. ErrNo 1011" & @CRLF & $query,0,0)
			EndIf
		EndFunc
		Func _JobCreationDeleteJob()
			ConsoleWrite('++_JobCreationDeleteJob() = '& @crlf )
			_CheckJobId()
			$query='BEGIN TRANSACTION;DELETE FROM tasks WHERE jobuid='&$jobid&';DELETE FROM jobs WHERE jobuid='&$jobid&';END TRANSACTION;'
			if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
;~ 				MsgBox(64+4096,"Saving Task data","The Task data was stored",0,0)
			Else
				MsgBox(48+4096,"Deleting Job Task error","An error Deleting Job Task data. ErrNo 1006" & @CRLF & $query,0,0)
			EndIf
			_JobCreation_disabletasks()
			GUICtrlSetData($TXT_JobCreation_jobdescription,"")
			GUICtrlSetData($TXT_JobCreation_jobname,"")
		EndFunc
		Func _TaskUpDown($updown)
			ConsoleWrite('++_TaskUpDown() = ' & $updown & @crlf )
;~ 			TASK UP   -> $updown=-1
;~ 			TASK DOWN -> $updown=1
			$taskOrderSelected=_GUICtrlListView_GetSelectedIndices($LST_jobcreation_tasklist)+1
			ConsoleWrite('------------$taskOrderSelected = ' & $taskOrderSelected & @crlf )
			$taskorderLast=_GUICtrlListView_GetItemCount($LST_jobcreation_tasklist)
			ConsoleWrite('------------$taskorderLast = ' & $taskorderLast & @crlf )
			;subiendo
			ConsoleWrite('ultimo o menor pero no el primero y UP = ' & ($taskOrderSelected >0 And $taskOrderSelected < $taskorderLast And $updown=1)  & @crlf )
			ConsoleWrite('primero o mas pero no el ultimo y DOWN = ' & ($taskOrderSelected >1 And $taskOrderSelected <= $taskorderLast And $updown=-1) & @crlf )
			if   ($taskOrderSelected >0 And $taskOrderSelected < $taskorderLast And $updown=1)  _   ; el primero o mas de la lista pero no el ultimo y UP
			  or ($taskOrderSelected >1 And $taskOrderSelected <= $taskorderLast And $updown=-1) _  ; el ultimo o menor  pero no el primero  y DOWN
			  then
;~ 				(($taskOrderSelected=$taskorderLast or $taskOrderSelected=1) And $taskorderLast=1 )
				$query='BEGIN TRANSACTION;'& _
						'UPDATE tasks SET taskorder=1000 WHERE taskorder=' & $taskOrderSelected+(1*$updown) & ' AND jobuid='& $jobid &' ;'& _
						'UPDATE tasks SET taskorder=' & $taskOrderSelected+(1*$updown)&  ' WHERE taskorder=' & $taskOrderSelected  & ' AND jobuid='& $jobid & ' ;'& _
						'UPDATE tasks SET taskorder=' & $taskOrderSelected &  ' WHERE taskorder=1000 AND jobuid='& $jobid & ' ;'& _
						'END TRANSACTION;'
				if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
					return $taskOrderSelected+(1*$updown)
				Else
					MsgBox(48+4096,"Moving Task error","An error Moving Task. ErrNo 1007" & @CRLF & $query,0,0)
					return 0
				EndIf
			EndIf
			return 0
		EndFunc
		Func  JobCreationFormClose()
			ConsoleWrite('++JobCreationFormClose() = '& @crlf )
			$mensaje=""
			If _CtrlRead($TXT_JobCreation_jobname)<>"" And _
				_NOexistInList($LST_JobCreation_JobList,_CtrlRead($TXT_JobCreation_jobname),0) Then
				$mensaje="Did You saved your Job?" & @CRLF & "Unsaved Job config will be lost"
			endif
			If _AreYouSureYesNo($mensaje)  Then
				GUIDelete($JobConsoleForm)
				GUIDelete($JobCreationForm)
				_JobsVarsInit()
				_TaskFormsInit()
				_SettingsVarInit()
				_ReduceMemory()
				$hotKeyKill=1
				$d=GUISetState(@SW_SHOW,$MainfORM)
			endif
		EndFunc
		Func _UpdateTaskActive($taskNumber,$active)
			ConsoleWrite('++_UpdateTaskActive() = '&$taskNumber&" "&$active &@crlf )
			$query='UPDATE tasks SET active='&$active&' WHERE taskuid="'&$taskNumber&'"'
			if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
			Else
				MsgBox(48+4096,"Saving Task data error","An error saving Task data. ErrNo 1009" & @CRLF & $query,0,0)
			EndIf
		EndFunc
		Func _JobDuplicate($jobIDorig)
			ConsoleWrite('++JobDuplicate() = '& @crlf)
			$query='SELECT taskuid,tasktype,vertice,type,unit,taskname,domain,login,taskorder,filter,active,commands,Grupo,TypeUpdate FROM tasks WHERE Jobuid="'&$jobIDorig&'" ORDER BY taskuid;'
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
			If IsArray($qryResult) then
				$arr_formPos=WinGetPos ("Job Creation")
				showRotatingRing($arr_formPos[0],$arr_formPos[1],$arr_formPos[2])
				_CreateJobID()
				$TaskUIDOrig=1
				For $iRows = 1 To UBound($qryResult,1)-1
					If StringStripWS($TaskUIDOrig,3)<>StringStripWS($qryResult[$iRows][0],3) Then _CreateTaskID()
					$query='INSERT INTO tasks VALUES (null,' & _
								$TaskID & ',"' & _
								$qryResult[$iRows][1] & '","' & _
								$qryResult[$iRows][2] & '","' & _
								$qryResult[$iRows][3] & '","' & _
								$qryResult[$iRows][4] & '",' & _
								$JobId & ',"' & _
								$qryResult[$iRows][5] & '","' & _
								$qryResult[$iRows][6] & '","' & _
								$qryResult[$iRows][7] & '",' & _
								$qryResult[$iRows][8] & ',"' & _
								$qryResult[$iRows][9] & '",' & _
								$qryResult[$iRows][10] & ',"' & _
								$qryResult[$iRows][11] & '","' & _
								$qryResult[$iRows][12] & '",' & _
								$qryResult[$iRows][13] & ' );'
					if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
					Else
						MsgBox(48+4096,"Job Duplication error","An error Duplication the Job. ErrNo 1010" & @CRLF & $query,0,0)
						Return false
					EndIf
					$TaskUIDOrig=$qryResult[$iRows][0]
				next
;~ 				_JobCreation_disableGral()
				stopRotatingRing()
				Return true
			endif
			Return false
		EndFunc
		Func _JobCreation_disableGral()
			ConsoleWrite('++JobCreation_disableGral() = '& @crlf)
			_JobCreation_disabletasks()
			_JobCreation_disableJobs()
			ControlCommand ($JobCreationForm, "", $CMB_jobcreation_selecttask, "SelectString", " ")
;~ 			If GUICtrlRead($TXT_JobCreation_jobdescription)<>"" Then GUICtrlSetData($TXT_JobCreation_jobdescription,"")
;~ 			If GUICtrlRead($TXT_JobCreation_jobname)<>"" Then GUICtrlSetData($TXT_JobCreation_jobname,"")
		EndFunc
		Func _JobCreation_disableJobs()
			ConsoleWrite('++_JobCreation_disableJobs() = '& @crlf)
			GUICtrlSetState($BTN_JobCreation_duplicatejob,$GUI_DISABLE)
			GUICtrlSetState($BTN_JobCreation_deletejob,$GUI_DISABLE)
			GUICtrlSetState($BTN_JobCreation_runjob,$GUI_DISABLE)
			GUICtrlSetState($BTN_JobCreation_Archivejob,$GUI_DISABLE)
		EndFunc
		Func _JobCreation_EnableJobs()
			ConsoleWrite('++_JobCreation_EnableJobs() = '& @crlf)
			GUICtrlSetState($BTN_JobCreation_duplicatejob,$GUI_ENABLE)
			GUICtrlSetState($BTN_JobCreation_deletejob,$GUI_ENABLE)
			GUICtrlSetState($BTN_JobCreation_runjob,$GUI_ENABLE)
			GUICtrlSetState($BTN_JobCreation_Archivejob,$GUI_ENABLE)
		EndFunc
		Func _JobCreation_disabletasks()
			ConsoleWrite('++JobCreation_disableTasks() = '& @crlf)
			GUICtrlSetState($BTN_createjob_deletetask,$GUI_DISABLE)
			GUICtrlSetState($BTN_createjob_Edittask,$GUI_DISABLE)
			GUICtrlSetState($BTN_createjob_taskUp,$GUI_DISABLE)
			GUICtrlSetState($BTN_createjob_taskDown,$GUI_DISABLE)
			GUICtrlSetState($BTN_createjob_DuplicateTask,$GUI_DISABLE)
			GUICtrlSetState($BTN_createjob_DescribeTask,$GUI_DISABLE)
		EndFunc
		Func _JobCreation_enabletasks()
			ConsoleWrite('++JobCreation_disableTasks() = '& @crlf)
			GUICtrlSetState($BTN_createjob_deletetask,$GUI_ENABLE)
			GUICtrlSetState($BTN_createjob_Edittask,$GUI_ENABLE)
			GUICtrlSetState($BTN_createjob_taskUp,$GUI_ENABLE)
			GUICtrlSetState($BTN_createjob_taskDown,$GUI_ENABLE)
			GUICtrlSetState($BTN_createjob_DuplicateTask,$GUI_ENABLE)
			GUICtrlSetState($BTN_createjob_DescribeTask,$GUI_ENABLE)
		EndFunc
		Func  JobConsole_inputbox2Close()
			ConsoleWrite('++JobConsole_inputbox2Close() = '& @crlf )
			$flagInputbox2=1
		EndFunc
		Func _JobCreation_Archive($archive)
			ConsoleWrite('++_JobCreation_Archive() = '& @crlf)
			$query='UPDATE jobs SET backup='&$archive&' WHERE jobuid="'&$jobID&'"'
			if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
			Else
				MsgBox(48+4096,"Saving job archive data error","An error saving job archive data. ErrNo 1012" & @CRLF & $query,0,0)
			EndIf
			GUICtrlSetData($TXT_JobCreation_jobdescription,"")
			GUICtrlSetData($TXT_JobCreation_jobname,"")
		EndFunc
		Func _UpdateJobDescription()
			ConsoleWrite('++_UpdateJobDescription() = ' &@crlf )
			$query='UPDATE jobs SET jobdesc="'&_ctrlRead($TXT_JobCreation_jobdescription)&'" WHERE jobuid="'&$jobID&'"'
			if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
			Else
				MsgBox(48+4096,"Updating description data error","An error updating description data. ErrNo 1020" & @CRLF & $query,0,0)
			EndIf
		EndFunc
		Func _updateJobDescriptionBTN()
			ConsoleWrite('++_updateJobDescriptionBTN() = '& @crlf)
			$lineValues=_GUICtrlListView_GetItemTextArray($LST_JobCreation_JobList)
			If _ctrlRead($TXT_JobCreation_jobdescription)<>$lineValues[2] And _GUICtrlListView_GetSelectedCount($LST_JobCreation_JobList)=1 Then
				GUICtrlSetState($BTN_JobCreation_updatejob,$GUI_Enable)
;~ 				consoleWrite("!!!!!!!!!!!!!!$GUI_Enable"& @CRLf)
				return
			endif
;~ 			consoleWrite("!!!!!!!!!!!!!!$GUI_DISABLE"& @CRLf)
			GUICtrlSetState($BTN_JobCreation_updatejob,$GUI_DISABLE)
		EndFunc
		Func _TaskDuplicate($tsk)
			ConsoleWrite('++_TaskDuplicate() = '& @crlf)
			$lastTask=_getLastTaskOrder($jobID,$tsk)
			$query='SELECT taskuid,tasktype,vertice,type,unit,taskname,domain,login,taskorder,filter,active,commands,Grupo,TypeUpdate FROM tasks WHERE Jobuid="'&$jobID&'" AND taskuid="'&$tsk&'";'
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
			If IsArray($qryResult) then
				_CreateTaskID()
				For $iRows = 1 To UBound($qryResult,1)-1
					$query='INSERT INTO tasks VALUES (null,' & _
							$TaskID & ',"' & _
							$qryResult[$iRows][1] & '","' & _
							$qryResult[$iRows][2] & '","' & _
							$qryResult[$iRows][3] & '","' & _
							$qryResult[$iRows][4] & '",' & _
							$JobId & ',"' & _
							"duplicate "&$qryResult[$iRows][5] & '","' & _
							$qryResult[$iRows][6] & '","' & _
							$qryResult[$iRows][7] & '",' & _
							$lastTask & ',"' & _
							$qryResult[$iRows][9] & '",' & _
							$qryResult[$iRows][10] & ',"' & _
							$qryResult[$iRows][11] & '","' & _
							$qryResult[$iRows][12] & '",' & _
							$qryResult[$iRows][13] & ' );'
					if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
					Else
						MsgBox(48+4096,"Task Duplication error","An error Duplication the Task ErrNo 1022" & @CRLF & $query,0,0)
						Return false
					EndIf
				next
				Return true
			endif
			Return false
		EndFunc
		Func _getLastTaskOrder($jobID,$tsk)
			ConsoleWrite('++_getLastTaskOrder() = '& @crlf)
			$query='SELECT max(taskorder) FROM tasks WHERE Jobuid="'&$jobID&'";'
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
			If IsArray($qryResult) then
				If UBound($qryResult)>1 then
					$last=$qryResult[1][0]
					$last=$last+1
					Return $last
				endif
			EndIf
			Return 100
		EndFunc
	#endregion
	#region ******************************** FORM task describe           ***********************
		Func ConsoleDescribe_FormClose()
			ConsoleWrite('++ConsoleDescribe_FormClose() = '& @crlf )
			GUIRegisterMsg($WM_SIZE, "")
			GUIRegisterMsg($WM_PAINT, "")
			_ReduceMemory()
			GUISetState(@SW_HIDE,$ConsoleDescribeForm)
			GUICtrlSetState($BTN_JobCreation_runjob,$GUI_ENABLE)
			 WinActivate ($JobCreationForm, "")
		 EndFunc
	#endregion
	#region ******************************** FORM task folder creation    ***********************
		Func TaskFolderCreationClose()
			ConsoleWrite('++TaskFolderCreationClose() = '& @crlf )
			If GUICtrlGetState($BTN_FolderCreation_save)=144 Then ; 144 = 128 + 16 (Disabled + visible) and 80 = 64 + 16 (Enabled + visible).
				$mensaje=""
			ELSE
				$mensaje="Did You saved your task?" & @CRLF & "Unsaved task config will be lost"
			ENDIF
			If $taskFormActivity=0 Then $mensaje=""
			If _AreYouSureYesNo($mensaje) Then
				$selectedJob=_ctrlread($TXT_JobCreation_jobname)
				GUIDelete($TaskFolderCreation)
				$taskID=0
				$taskFormActivity=0
				_ReduceMemory()
				GUISetState(@SW_SHOW,$JobCreationForm)
				$WM_Notify_Silent=1
				_FillJobList()
				_FillTaskJobList()
				_JobCreation_disableGral()
				_Clear_TaskCreation_Variables()
				_selectJobInList()
;~ 				GUICtrlSetData($TXT_JobCreation_jobdescription,"")
				$WM_Notify_Silent=0
				GUICtrlSetData($TXT_JobCreation_jobname,$selectedJob)
			endif
		EndFunc
		Func _Fill_CMB_TaskFolderCreation_SelType($table)
			ConsoleWrite('++_Fill_CMB_TaskFolderCreation_SelType() = '& @crlf )
			;optionds of tasks Servers|Custom Groups|Shares
			;servers
			switch $table
				case "Servers"
					GUICtrlSetData($CMD_TaskFolderCreation_SelServerShare, "", "")
					$query='SELECT servername FROM servers order by servername ;'
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						_FillComboSQL($CMD_TaskFolderCreation_SelServerShare,$qryResult)
					endif
				case "Localhost"
					GUICtrlSetData($CMD_TaskFolderCreation_SelServerShare,"")
;~ 					GUICtrlSetData($CMD_TaskFolderCreation_SelServerShare, @ComputerName, @ComputerName)
					GUICtrlSetData($CMD_TaskFolderCreation_SelServerShare, "localhost", "localhost")
				case "Custom Groups"
					GUICtrlSetData($CMD_TaskFolderCreation_SelServerShare, "", "")
					$query='SELECT distinct(servergroupname) FROM servergroups WHERE custom=1 order by servergroupname;'
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						_FillComboSQL($CMD_TaskFolderCreation_SelServerShare,$qryResult)
					endif
				case "Shares"
					GUICtrlSetData($CMD_TaskFolderCreation_SelServerShare, "", "")
					$query='SELECT sharename FROM customshares ORDER BY sharename;'
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						_FillComboSQL($CMD_TaskFolderCreation_SelServerShare,$qryResult)
					endif
				case "Groups"
					GUICtrlSetData($CMD_TaskFolderCreation_SelServerShare, "", "")
					$query='SELECT distinct(servergroupname) FROM servergroups WHERE custom=0 order by servergroupname;'
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						_FillComboSQL($CMD_TaskFolderCreation_SelServerShare,$qryResult)
					endif
			EndSwitch
		EndFunc
		Func _TaskFormCreation_SaveBTN()
			ConsoleWrite('++_TaskFormCreation_SaveBTN() = '& @crlf )
			;count lists with data
			$counterDataInLST=0
			If _GUICtrlListView_GetItemCount($LST_TaskFolderCreation_TargetPaths)>0  Then $counterDataInLST+=1
			If _GUICtrlListView_GetItemCount($LST_TaskFolderCreation_TargetLoc)>0    Then $counterDataInLST+=1
			If _GUICtrlListView_GetItemCount($LST_TaskFolderCreation_SourcePaths)>0  Then $counterDataInLST+=1
			If _GUICtrlListView_GetItemCount($LST_TaskFolderCreation_SourceLoc)>0    Then $counterDataInLST+=1

			;detect If miniform Or big form
;~ 			If GUICtrlGetState($BTN_FolderCreation_save)=$GUI_DISABLE+$GUI_SHOW Then
				If $LST_TaskFolderCreation_SourcePaths>0 And $LST_TaskFolderCreation_SourceLoc>0 Then   ;big form
					If $counterDataInLST=4 Then
						GUICtrlSetState($BTN_FolderCreation_save,$GUI_ENABLE)
						return
					endif
				Else   ; mini form
					If $counterDataInLST=2 Then
						GUICtrlSetState($BTN_FolderCreation_save,$GUI_ENABLE)
						return
					endif
				EndIf
;~ 			endif
			GUICtrlSetState($BTN_FolderCreation_save,$GUI_DISABLE)
;~ 			If Not  GUICtrlGetState($BTN_FolderCreation_save)=$GUI_DISABLE+$GUI_SHOW Then GUICtrlSetState($BTN_FolderCreation_save,$GUI_DISABLE)
		EndFunc
		#region task data save
			Func _TaskFormCreationFillLocList($listObject)
				ConsoleWrite('++_TaskFormCreationFillLocList() = '& @crlf )
				switch GUICtrlRead($CMB_TaskFolderCreation_SelType)
					case "Servers","Localhost"
						Dim $arr[2]
						$arr[1]=GUICtrlRead($CMB_TaskFolderCreation_SelType) & "|" & GUICtrlRead($CMD_TaskFolderCreation_SelServerShare)
					case "Groups","Custom Groups"
						$id='SELECT groupid FROM servergroups where servergroupname="'& GUICtrlRead($CMD_TaskFolderCreation_SelServerShare) &'"'
						$query='SELECT Servers.servername, servergroups.servergroupname FROM Servers INNER JOIN RServerGroup ON RServerGroup.serverID = Servers.serverid ' & _
							'INNER JOIN servergroups ON RServerGroup.groupid  = servergroups.groupid WHERE servergroups.groupid=(' & $id & ') order by Servers.servername;'
						_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
						$arr= _CreateLineLOC($CMB_TaskFolderCreation_SelType,$CMD_TaskFolderCreation_SelServerShare)
					case "Shares"
						$query='SELECT sharepath FROM customshares WHERE sharename="' & GUICtrlRead($CMD_TaskFolderCreation_SelServerShare) & '";'
						_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
						$arr= _CreateLineLOC($CMB_TaskFolderCreation_SelType,$CMD_TaskFolderCreation_SelServerShare)
				EndSwitch

				For $i=1 To UBound($arr)-1
					$arrunit=StringSplit($arr[$i],"|")
					If _NOexistInList($listObject,$arrunit[2],1) then
						GUICtrlCreateListViewItem($arr[$i],$listObject)
					endif
				next
				_ResizeListViewColumns($listObject,$arr,2,3)
			EndFunc
			Func _CreateLineLOC($SelType,$SelServerShare)
				ConsoleWrite('++_CreateLineLOC() = '& @crlf )
				If  IsArray($qryResult) then
					Dim $arr[UBound($qryResult)]
					For $iRows = 1 To UBound($qryResult)-1
						$arr[$iRows]=GUICtrlRead($SelType)& "|" & $qryResult[$iRows][0]& "|" & GUICtrlRead($SelServerShare)
					next
					Return $arr
				endif
			EndFunc
			Func _LST_TaskCreationDeleteTaskUID()
				ConsoleWrite('++_LST_TaskCreationDeleteTaskUID() = '& @crlf )
				$query='DELETE FROM tasks WHERE taskuid="'&$taskID&'"'
				_SQLITErun($query,$profiledbfile,$quietSQLQuery)
			EndFunc
			Func _LST_TaskCreation_LocStore($sTitle,$vertice,$listObject,$CMB_CredOBJ,$TXT_taskdesc,$TaskActive=1)
				ConsoleWrite('++_LST_TaskCreation_LocStore() $taskID= '& $taskID & ' $vertice=' & $vertice & @crlf )
				$arr=_GUICtrlListView_CreateArray($listObject)
				$counter=0
				Switch $vertice
					Case "TargetLoc","SourceLoc"
						$arrCred=_CredArr($CMB_CredOBJ)   ;   $CMB_TaskFolderCreation_TargetCred   $CMB_TaskFolderCreation_SourceCred
					Case else
						$arrCred=_CredArr(0)
				EndSwitch
				For $i=1 To UBound($arr)-1
					$Locunit=StringStripWS($arr[$i][1],3)
					$LocGroup=StringStripWS($arr[$i][2],3)
					local $id='SELECT taskid FROM tasks WHERE unit="' & $Locunit  & _
								'" And taskuid="' &  $taskID  & '" And vertice="' &  $vertice  & '"'
					$query='REPLACE INTO tasks VALUES ((' & $id & '),' & $taskID & ',"' & $sTitle  & '","' & $vertice & '","' & _
							StringStripWS($arr[$i][0],3) & '","' & $Locunit & '",' & $JobID & ',"' & _
							clearstring(_CtrlRead($TXT_taskdesc)) & '","' & $arrCred[1] & _
							'","' & $arrCred[2] & '",' & $taskorder & ',"' & $LocGroup & '",'& $TaskActive &',"","",'&_TypeUpdatedFlag($vertice)&');'
					if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
						$counter=$counter+1
					Else
						MsgBox(48+8192,"Saving Task data error","An error saving Task data. ErrNo 1005" & @CRLF & $query,0,0)
					EndIf
				next
				If $counter>0 Then
					Return True
				Else
					Return False
				endif
			EndFunc
			Func _LST_TaskCreation_PathStore($sTitle,$vertice,$listObject,$TaskActive=1)
				ConsoleWrite('++_LST_TaskCreation_PathStore() $taskID= '& $taskID & '  $vertice=' & $vertice & @crlf )
				$arr=_GUICtrlListView_CreateArray($listObject)
				$counter=0
				For $i=1 To UBound($arr)-1
					$Locunit=StringStripWS($arr[$i][1],3)
					$query='REPLACE INTO tasks VALUES (null,' & $taskID & ',"' & $sTitle  & '","' & $vertice & '","Exec","' & _
								StringStripWS($arr[$i][0],3) & '",' & $JobID & ',"' & _
								clearstring(_CtrlRead($TXT_FolderCreation_taskdesc)) & _
								'","-","-",' & $taskorder & ',"' & $Locunit & '",'& $TaskActive &',"","",0);'
					if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
						$counter=$counter+1
					Else
						MsgBox(48+4096,"Saving Task data error","An error saving Task data. ErrNo 1005" & @CRLF & $query,0,0)
					EndIf
				next
				If $counter>0 Then
					Return True
				Else
					Return False
				endif
			EndFunc
			Func _CredArr($cmbObject)
				ConsoleWrite('++_CredArr() = ' & @crlf )
				If  _CtrlRead($cmbObject)<>"" then
					$arr=StringSplit(GUICtrlRead($cmbObject),"\")
					Return $arr
				Else
					Dim $arr[3]
					$arr[1]="-"
					$arr[2]="-"
					Return $arr
				endif
			EndFunc
			Func _TaskCreation_registerJOB()
				ConsoleWrite('++_TaskCreation_registerJOB() $taskID= ' & @crlf )
				local $id='SELECT jobID FROM jobs WHERE jobUID=' & $jobid
				$query='REPLACE INTO jobs VALUES ((' & $id & '),' & $jobid & ',"' & _
						GUICtrlRead($TXT_JobCreation_jobname) & '","' & _
						clearstring(GUICtrlRead($TXT_JobCreation_jobdescription)) &  '",0);'
				if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
					Return true
				Else
					MsgBox(48+4096,"Saving Task data error........","An error saving Task data. ErrNo 1006" & @CRLF & $query,0,0)
					Return false
				EndIf
			EndFunc
			Func _GetNextTaskOrder()
				ConsoleWrite('++_GetTaskOrder()' & @crlf )
				$taskorder=0
				$query='SELECT taskorder FROM tasks WHERE taskuid="'&$taskID&'"'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					If UBound($qryResult)>1 Then $taskorder=$qryResult[1][0]
				endif
				If $taskorder=0 Then
					$taskorder=""
					$query='SELECT taskorder FROM tasks WHERE jobUID=' & $jobid & " ORDER BY taskorder DESC"
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						If UBound($qryResult)>1 then
							$taskorder=$qryResult[1][0]
						Else
							$taskorder=""
						endif
					endif
					If $taskorder="" Then
						$taskorder=1
					Else
						$taskorder=$taskorder+1
					endif
				endif
				Return $taskorder
			EndFunc
			Func _CheckTaskActive($taskNumber)
				ConsoleWrite('++_CheckTaskActive() = '&$taskNumber &@crlf )
				If $taskNumber<>"" Then
					$query='SELECT active FROM tasks WHERE taskuid="'&$taskNumber&'"'
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) Then
						If UBound($qryResult)>1 then
							return $qryResult[1][0]
						Else
							return 0
						endif
					endif
				else
					Return 0
				endif
			EndFunc
		#endregion
		#region fill task data
			Func _Fill_TaskFolderCreation_Data($sTitle)
				ConsoleWrite('++_Fill_TaskFolderCreation_Data() = ' & $sTitle  & @crlf )
				GUISetCursor(15, 1,$TaskFolderCreation)
				Switch $sTitle
					Case "Folder Creation Task","Deletion Task"
						if $newtask=0 then
							_Fill_Task_LST($LST_TaskFolderCreation_TargetLoc,"TargetLoc",0)
							_Fill_Task_LST($LST_TaskFolderCreation_TargetPaths,"TargetPath",1)
							GUICtrlSetData($TXT_FolderCreation_taskdesc,_CheckTaskDescription())
						endif
						_setTypeUpdate($CK_TaskForms_UpdateTypesTRG,"TargetLoc")
						GUICtrlSetData($LBL_TargetLoc,"Cant:"&_GUICtrlListView_GetItemCount($LST_TaskFolderCreation_TargetLoc)  )
						_Fill_task_credCMB($CMB_TaskFolderCreation_TargetCred)
						_select_task_credCMB($TaskFolderCreation,$CMB_TaskFolderCreation_TargetCred,"TargetLoc")
					Case "Execution Task","Compression Task","Decompression Task"
						if $newtask=0 then
							_Fill_Task_LST($LST_TaskFolderCreation_SourceLoc,"SourceLoc",0)
							_Fill_Task_LST($LST_TaskFolderCreation_TargetLoc,"TargetLoc",0)
							_Fill_Task_LST($LST_TaskFolderCreation_SourcePaths,"SourcePath",1)
							_Fill_Task_LST($LST_TaskFolderCreation_TargetPaths,"TargetPath",1)
							GUICtrlSetData($TXT_FolderCreation_taskdesc,_CheckTaskDescription())
						endif
						_setTypeUpdate($CK_TaskForms_UpdateTypesTRG,"TargetLoc")
						_setTypeUpdate($CK_TaskForms_UpdateTypesSRC,"SourceLoc")
						GUICtrlSetData($LBL_SourceLoc,"Cant:"&_GUICtrlListView_GetItemCount($LST_TaskFolderCreation_SourceLoc)  )
						GUICtrlSetData($LBL_TargetLoc,"Cant:"&_GUICtrlListView_GetItemCount($LST_TaskFolderCreation_TargetLoc)  )
						_Fill_task_credCMB($CMB_TaskFolderCreation_SourceCred)
						_select_task_credCMB($TaskFolderCreation,$CMB_TaskFolderCreation_SourceCred,"SourceLoc")
						_Fill_task_credCMB($CMB_TaskFolderCreation_TargetCred)
						_select_task_credCMB($TaskFolderCreation,$CMB_TaskFolderCreation_TargetCred,"TargetLoc")
				EndSwitch
				GUISetCursor(-1, 1,$TaskFolderCreation)
			EndFunc
			Func _Fill_task_credCMB($cmbObject)
				ConsoleWrite('++_Fill_task_credCMB() = '& @crlf )
;~ 				$query='SELECT domain||"\"||userid FROM credentials;'
				$query='SELECT domain,userid FROM credentials;'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				Local $iColumna=0  ;columna de domain
				$qryResultUnHashed=_HashingColumnArray($qryResult,$iColumna,0)
				Local $iColumna=1  ;columna de username
				$qryResultUnHashed=_HashingColumnArray($qryResultUnHashed,$iColumna,0)
				local $domainUser[1][1]
				for $ic=0 to ubound($qryResultUnHashed)-1
					redim $domainUser[$ic+1][1]
					$domainUser[$ic][0]=$qryResultUnHashed[$ic][0]&"\"&$qryResultUnHashed[$ic][1]
				next
				If  IsArray($domainUser) then
					_FillComboSQL($cmbObject,$domainUser)
				endif
				_GUICtrlComboBox_AddString($cmbObject, ".\Logged User")
			EndFunc
			Func _select_task_credCMB($formHandle,$cmbObject,$vertice)
				ConsoleWrite('++_select_task_credCMB() = ' & @crlf )
				$query='SELECT domain||"\"||login FROM tasks WHERE taskuid="' & $taskid & '" AND vertice="' & $vertice & '";'
				_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
				If  IsArray($qryResult) then
					If UBound($qryResult)>1 then
						$toselect=$qryResult[1][0]
						If Not _ExistInCMB($cmbObject,$toselect) Then $toselect=".\Logged User"
						ControlCommand ($formHandle, "", $cmbObject, "SelectString", $toselect)
					Else
;~ 						ControlCommand ($TaskFolderCreation, "", $cmbObject, "SelectString", @LogonDomain&"\"&@UserName )
;~ 						$res=_GUICtrlComboBox_SelectString($cmbObject, @LogonDomain&"\"&@UserName)
;~ 						If $res=-1 Then _GUICtrlComboBox_SelectString($cmbObject, ".\Logged User")
						_GUICtrlComboBox_SelectString($cmbObject, ".\Logged User")
					endif
				endif
			EndFunc
		#endregion
	#endregion
	#region ******************************** FORM Copy Task form          ***********************
		Func _Fill_TaskCopy_Data($sTitle)
			ConsoleWrite('++_Fill_TaskFolderCreation_Data() = ' & $sTitle  & @crlf )
			GUISetCursor(15, 1,$TasKCopyCreation)
			if $newtask=0 then
				_Fill_Task_LST($LST_TaskFolderCreation_SourceLoc,"SourceLoc",0)
				_Fill_Task_LST($LST_TaskFolderCreation_TargetLoc,"TargetLoc",0)
				_Fill_Task_LST($LST_TaskFolderCreation_SourcePaths,"SourcePath",1)
				_Fill_Task_LST($LST_TaskFolderCreation_TargetPaths,"TargetPath",1)
				GUICtrlSetData($TXT_FolderCreation_taskdesc,_CheckTaskDescription())
			endif
			_setTypeUpdate($CK_TaskForms_UpdateTypesSRC,"SourceLoc")
			_setTypeUpdate($CK_TaskForms_UpdateTypesTRG,"TargetLoc")
			GUICtrlSetData($LBL_SourceLoc,"Cant:"&_GUICtrlListView_GetItemCount($LST_TaskFolderCreation_SourceLoc)  )
			GUICtrlSetData($LBL_TargetLoc,"Cant:"&_GUICtrlListView_GetItemCount($LST_TaskFolderCreation_TargetLoc)  )
			_Fill_task_credCMB($CMB_TaskFolderCreation_SourceCred)
			_select_task_credCMB($TasKCopyCreation,$CMB_TaskFolderCreation_SourceCred,"SourceLoc")
			_Fill_task_credCMB($CMB_TaskFolderCreation_TargetCred)
			_select_task_credCMB($TasKCopyCreation,$CMB_TaskFolderCreation_TargetCred,"TargetLoc")
			_CopyForm_OnMirror_Checks(1)
			GUISetCursor(-1, 1,$TasKCopyCreation)
		EndFunc
		Func _CopyForm_OnMirror_Checks($init=0)
			ConsoleWrite('++_CopyForm_OnMirror_Checks() = '& @crlf)

			if  Int(_GUICtrlListView_GetItemCount($LST_TaskFolderCreation_SourcePaths)) > 0 Then
				ConsoleWrite('-- se registro source path > 0' & @crlf )
;~ 				GUICtrlSetState($RD_CopyTask_Mirror,$GUI_CHECKED)
;~ 				GUICtrlSetState($RD_CopyTask_Copy,$GUI_UNCHECKED)
				GUICtrlSetState($RD_CopyTask_Mirror, $GUI_DISABLE)
;~ 				GUICtrlSetState($TXT_TaskFolderCreation_SourcePath, $GUI_DISABLE)
;~ 				GUICtrlSetState($RD_CopyTask_Copy, $GUI_DISABLE)
;~ 				GUICtrlSetState($RD_CopyTask_Move, $GUI_DISABLE)
;~ 				GUICtrlSetState($BTN_TaskFolderCreation_AddSourcePath, $GUI_DISABLE)
;~ 				GUICtrlSetState($BTN_TaskFolderCreation_AddToSourceLoc, $GUI_DISABLE)
;~ 				GUICtrlSetState($TXT_TaskFolderCreation_SourceZIPFilter, $GUI_DISABLE)
				return
			endif
			if  (  _IsChecked($RD_CopyTask_Mirror) And Int(_GUICtrlListView_GetItemCount($LST_TaskFolderCreation_SourcePaths)) > 0 ) Then
				ConsoleWrite('-- se registro RB Mirror y source path > 0' & @crlf )
				GUICtrlSetState($RD_CopyTask_Mirror,$GUI_CHECKED)
				GUICtrlSetState($RD_CopyTask_Copy,$GUI_UNCHECKED)
				GUICtrlSetState($RD_CopyTask_Mirror, $GUI_DISABLE)
				GUICtrlSetState($TXT_TaskFolderCreation_SourcePath, $GUI_DISABLE)
				GUICtrlSetState($RD_CopyTask_Copy, $GUI_DISABLE)
				GUICtrlSetState($RD_CopyTask_Move, $GUI_DISABLE)
				GUICtrlSetState($BTN_TaskFolderCreation_AddSourcePath, $GUI_DISABLE)
				GUICtrlSetState($BTN_TaskFolderCreation_AddToSourceLoc, $GUI_DISABLE)
				GUICtrlSetState($TXT_TaskFolderCreation_SourceZIPFilter, $GUI_DISABLE)
				return
			endif
			if _GUICtrlListView_GetItemCount($LST_TaskFolderCreation_SourceLoc)>1 Then
				ConsoleWrite('-- se registro source loc > 1' & @crlf )
				GUICtrlSetState($RD_CopyTask_Mirror, $GUI_DISABLE)
				return
			endif
			If _NoexistInSTRinList($LST_TaskFolderCreation_SourcePaths,"[M]",2)=False  Then ;  se registro un Mirror en la lista de source
				ConsoleWrite('-- se registro un Mirror en la lista de source' & @crlf )
				GUICtrlSetState($RD_CopyTask_Mirror,$GUI_CHECKED)
				GUICtrlSetState($RD_CopyTask_Copy,$GUI_UNCHECKED)
				GUICtrlSetState($RD_CopyTask_Mirror, $GUI_DISABLE)
				GUICtrlSetState($TXT_TaskFolderCreation_SourcePath, $GUI_DISABLE)
				GUICtrlSetState($RD_CopyTask_Copy, $GUI_DISABLE)
				GUICtrlSetState($RD_CopyTask_Move, $GUI_DISABLE)
				GUICtrlSetState($BTN_TaskFolderCreation_AddSourcePath, $GUI_DISABLE)
				GUICtrlSetState($BTN_TaskFolderCreation_AddToSourceLoc, $GUI_DISABLE)
				GUICtrlSetState($TXT_TaskFolderCreation_SourceZIPFilter, $GUI_DISABLE)
				return
			endif
			ConsoleWrite('-- se registro Nada' & @crlf )
			GUICtrlSetState($RD_CopyTask_Mirror, $GUI_ENABLE)
			GUICtrlSetState($RD_CopyTask_Move, $GUI_ENABLE)
			GUICtrlSetState($RD_CopyTask_Copy, $GUI_ENABLE)
;~ 			GUICtrlSetState($RD_CopyTask_Copy,$GUI_CHECKED)
;~ 			GUICtrlSetState($RD_CopyTask_Mirror, $GUI_UNCHECKED)
;~ 			GUICtrlSetState($RD_CopyTask_Move, $GUI_UNCHECKED)

			GUICtrlSetState($TXT_TaskFolderCreation_SourcePath, $GUI_ENABLE)
			GUICtrlSetState($TXT_TaskFolderCreation_SourceZIPFilter, $GUI_ENABLE)
			GUICtrlSetState($CK_TaskFolderCreation_Recurse,$GUI_ENABLE)
			GUICtrlSetState($TXT_TaskFolderCreation_olderThan,$GUI_ENABLE)
			GUICtrlSetState($DT_olderThan,$GUI_ENABLE)
			If $init=1 Then
				ConsoleWrite('!-- se registro $init' & @crlf )
				GUICtrlSetState($BTN_TaskFolderCreation_AddSourcePath, $GUI_DISABLE)
			endif
			return
		EndFunc
		Func _CopyForm_OnDeleteMirror_Checks()
			ConsoleWrite('++_CopyForm_OnDeleteMirror_Checks() = '& @crlf)
			If _IsChecked($RD_CopyTask_Mirror) then
				GUICtrlSetState($RD_CopyTask_Mirror, $GUI_ENABLE)
				GUICtrlSetState($RD_CopyTask_Move, $GUI_ENABLE)
				GUICtrlSetState($RD_CopyTask_Copy, $GUI_ENABLE)

				GUICtrlSetState($TXT_TaskFolderCreation_SourcePath, $GUI_ENABLE)
				GUICtrlSetState($TXT_TaskFolderCreation_SourceZIPFilter, $GUI_ENABLE)
				GUICtrlSetState($CK_TaskFolderCreation_Recurse,$GUI_ENABLE)
				GUICtrlSetState($TXT_TaskFolderCreation_olderThan,$GUI_ENABLE)
				GUICtrlSetState($DT_olderThan,$GUI_ENABLE)
				GUICtrlSetState($BTN_TaskFolderCreation_AddSourcePath, $GUI_ENABLE)
			endif
		EndFunc
		Func TaskCopyCreationClose()
			ConsoleWrite('++TaskCopyCreationClose() = '& @crlf )
			If GUICtrlGetState($BTN_FolderCreation_save)=144 Then ; 144 = 128 + 16 (Disabled + visible) and 80 = 64 + 16 (Enabled + visible).
				$mensaje=""
			ELSE
				$mensaje="Did You saved your task?" & @CRLF & "Unsaved task config will be lost"
			ENDIF
			If $taskFormActivity=0 Then $mensaje=""
			If _AreYouSureYesNo($mensaje) Then
				GUICtrlSetState($RD_CopyTask_Copy, $GUI_CHECKED)
				$selectedJob=_ctrlread($TXT_JobCreation_jobname)
				GUIDelete($TasKCopyCreation)
				$taskID=0
				$taskFormActivity=0
				_ReduceMemory()
				GUISetState(@SW_SHOW,$JobCreationForm)
				$WM_Notify_Silent=1
				_FillJobList()
				_FillTaskJobList()
				_JobCreation_disableGral()
				_Clear_TaskCreation_Variables()
				_selectJobInList()
;~ 				GUICtrlSetData($TXT_JobCreation_jobdescription,"")
				$WM_Notify_Silent=0
				GUICtrlSetData($TXT_JobCreation_jobname,$selectedJob)

			endif
		EndFunc
	#endregion
	#region ******************************** FORM Deploy Agent Task form  ***********************
		Func TaskDeployAgentClose()
			ConsoleWrite('++TaskDeployAgentClose() = '& @crlf )
			If GUICtrlGetState($BTN_TaskDeployAgent_save)=144 Then ; 144 = 128 + 16 (Disabled + visible) and 80 = 64 + 16 (Enabled + visible).
				$mensaje=""
			ELSE
				$mensaje="Did You saved your task?" & @CRLF & "Unsaved task config will be lost"
			ENDIF
			If $taskFormActivity=0 Then $mensaje=""
			If _AreYouSureYesNo($mensaje) Then
				$selectedJob=_ctrlread($TXT_JobCreation_jobname)
				GUIDelete($TaskDeployAgentForm)
				$taskID=0
				$taskFormActivity=0
				_ReduceMemory()
				GUISetState(@SW_SHOW,$JobCreationForm)
				$WM_Notify_Silent=1
				_FillJobList()
				_FillTaskJobList()
				_JobCreation_disableGral()
				_Clear_TaskCreation_Variables()
				_selectJobInList()
;~ 				GUICtrlSetData($TXT_JobCreation_jobdescription,"")
				$WM_Notify_Silent=0
				GUICtrlSetData($TXT_JobCreation_jobname,$selectedJob)
			endif
		EndFunc
		Func _TaskDeployAgent_SaveBTN()
			ConsoleWrite('++_TaskDeployAgent_SaveBTN() = '& @crlf)
			;count lists with data
			$counterDataInLST=0
			If _GUICtrlListView_GetItemCount($LST_TaskDeployAgent_TargetLoc)>0   Then $counterDataInLST+=1
			If $counterDataInLST=1 Then
				GUICtrlSetState($BTN_TaskDeployAgent_save,$GUI_ENABLE)
			Else
				GUICtrlSetState($BTN_TaskDeployAgent_save,$GUI_DISABLE)
			endif
		EndFunc
		Func _TaskDeployAgent_FillLocList($listObject)
			ConsoleWrite('++_TaskDeployAgent_FillLocList() = '& @crlf )
			switch GUICtrlRead($CMB_TaskDeployAgent_SelType)
				case "Servers","Localhost"
					Dim $arr[2]
					$arr[1]=GUICtrlRead($CMB_TaskDeployAgent_SelType) & "|" & GUICtrlRead($CMD_TaskDeployAgent_SelServerShare)
				case "Groups","Custom Groups"
					$id='SELECT groupid FROM servergroups where servergroupname="'& GUICtrlRead($CMD_TaskDeployAgent_SelServerShare) &'"'
					$query='SELECT Servers.servername,servergroups.servergroupname FROM Servers INNER JOIN RServerGroup ON RServerGroup.serverID = Servers.serverid ' & _
						'INNER JOIN servergroups ON RServerGroup.groupid  = servergroups.groupid WHERE servergroups.groupid=(' & $id & ') order by Servers.servername;'
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					$arr= _CreateLineLOC($CMB_TaskDeployAgent_SelType,$CMD_TaskDeployAgent_SelServerShare)
			EndSwitch

			For $i=1 To UBound($arr)-1
				$arrunit=StringSplit($arr[$i],"|")
				If _NOexistInList($listObject,$arrunit[2],1) then
					GUICtrlCreateListViewItem($arr[$i],$listObject)
				endif
			next
			GUICtrlSetData($LBL_TargetLoc,"Cant:"&_GUICtrlListView_GetItemCount($listObject)  )
		EndFunc
		Func _Fill_CMB_TaskDeployAgent_SelType($table)
			ConsoleWrite('++_Fill_CMB_TaskDeployAgent_SelType() = '& @crlf )
			;optionds of tasks Servers|Custom Groups|Shares
			;servers
			switch $table
				case "Servers"
					GUICtrlSetData($CMD_TaskDeployAgent_SelServerShare, "", "")
					$query='SELECT servername FROM servers order by servername ;'
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						_FillComboSQL($CMD_TaskDeployAgent_SelServerShare,$qryResult)
					endif
				case "Localhost"
					GUICtrlSetData($CMD_TaskDeployAgent_SelServerShare,"")
;~ 					GUICtrlSetData($CMD_TaskDeployAgent_SelServerShare, @ComputerName, @ComputerName)
					GUICtrlSetData($CMD_TaskDeployAgent_SelServerShare, "localhost", "localhost")
				case "Custom Groups"
					GUICtrlSetData($CMD_TaskDeployAgent_SelServerShare, "", "")
					$query='SELECT distinct(servergroupname) FROM servergroups WHERE custom=1 order by servergroupname;'
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						_FillComboSQL($CMD_TaskDeployAgent_SelServerShare,$qryResult)
					endif
				case "Groups"
					GUICtrlSetData($CMD_TaskDeployAgent_SelServerShare, "", "")
					$query='SELECT distinct(servergroupname) FROM servergroups WHERE custom=0 order by servergroupname;'
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						_FillComboSQL($CMD_TaskDeployAgent_SelServerShare,$qryResult)
					endif
			EndSwitch
		EndFunc
		Func _Fill_TaskDeployAgent_Data($sTitle)
			ConsoleWrite('++_Fill_TaskDeployAgent_Data() = ' & $sTitle  & @crlf )
			GUISetCursor(15, 1,$TaskDeployAgentForm)
			if $newtask=0 then
				_Fill_Task_LST($LST_TaskDeployAgent_TargetLoc,"TargetLoc",0)
				GUICtrlSetData($TXT_TaskDeployAgent_taskdesc,_CheckTaskDescription())
			endif
			_setTypeUpdate($CK_TaskForms_UpdateTypesTRG,"TargetLoc")
			GUICtrlSetData($LBL_TargetLoc,"Cant:"&_GUICtrlListView_GetItemCount($LST_TaskDeployAgent_TargetLoc)  )
			_Fill_task_credCMB($CMB_TaskDeployAgent_TargetCred)
			_select_task_credCMB($TaskDeployAgentForm,$CMB_TaskDeployAgent_TargetCred,"TargetLoc")
			If _CheckTaskDeployAgentDeployAction() Then
				GUICtrlSetState($RD_TaskDeployAgent_Install,$GUI_CHECKED)
			Else
				GUICtrlSetState($RD_TaskDeployAgent_Uninstall,$GUI_CHECKED)
			endif
			GUISetCursor(-1, 1,$TaskDeployAgentForm)
		EndFunc
		Func _DeployAgentData_Store($sTitle,$Deploy,$TaskActive=1)
			ConsoleWrite('++_DeployAgentData_Store() $taskID= '& $taskID & @crlf )
			$vertice="DeployTask"
			$query='REPLACE INTO tasks VALUES (null,' & $taskID & ',"' & $sTitle  & '","' & $vertice & '","Deploy","-",' &  _
								$JobID & ',"' & clearstring(_CtrlRead($TXT_TaskDeployAgent_taskdesc)) & _
						'","-","-",' & $taskorder & ',"' & $Deploy & '",'& $TaskActive &',"","",0);'
			if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
				Return True
			Else
;~ 					MsgBox(48+4096,"Saving Task data error","An error saving Task data. ErrNo 1005" & @CRLF & $query,0,0)
				Return False
			EndIf
		EndFunc
		Func _CheckTaskDeployAgentDeployAction($tID=$taskID)
			ConsoleWrite('++_CheckTaskDeployAgentDeployAction() = ' & @crlf )
			$query='SELECT filter FROM tasks WHERE type="Deploy" and taskuid=' & $tID
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
			If  IsArray($qryResult) then
				If UBound($qryResult)>1 then
					If $qryResult[1][0]=4 Then Return false
					If $qryResult[1][0]=1 Then Return true
				Else
					Return true
				endif
			endif
		EndFunc
	#endregion
	#region ******************************** FORM Execution Task form     ***********************
		Func _TaskExecution_FillLocList($listObject)
			ConsoleWrite('++_TaskExecution_FillLocList() = '& @crlf )
			switch GUICtrlRead($CMB_TaskExecution_SelType)
				case "Servers","Localhost"
					Dim $arr[2]
					$arr[1]=GUICtrlRead($CMB_TaskExecution_SelType) & "|" & GUICtrlRead($CMD_TaskExecution_SelServerShare)
				case "Groups","Custom Groups"
					$id='SELECT groupid FROM servergroups where servergroupname="'& GUICtrlRead($CMD_TaskExecution_SelServerShare) &'"'
					$query='SELECT Servers.servername,servergroups.servergroupname FROM Servers INNER JOIN RServerGroup ON RServerGroup.serverID = Servers.serverid ' & _
						'INNER JOIN servergroups ON RServerGroup.groupid  = servergroups.groupid WHERE servergroups.groupid=(' & $id & ') order by Servers.servername;'
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					$arr= _CreateLineLOC($CMB_TaskExecution_SelType,$CMD_TaskExecution_SelServerShare)
			EndSwitch

			For $i=1 To UBound($arr)-1
				$arrunit=StringSplit($arr[$i],"|")
				If _NOexistInList($listObject,$arrunit[2],1) then
					GUICtrlCreateListViewItem($arr[$i],$listObject)
				endif
			next
			_ResizeListViewColumns($listObject,$arr,2,3)
			GUICtrlSetData($LBL_TargetLoc,"Cant:"&_GUICtrlListView_GetItemCount($listObject)  )
		EndFunc
		Func _Fill_CMB_TaskExecution_SelType($table)
			ConsoleWrite('++_Fill_CMB_TaskExecution_SelType() = '& @crlf )
			;optionds of tasks Servers|Custom Groups|Shares
			;servers
			switch $table
				case "Servers"
					GUICtrlSetData($CMD_TaskExecution_SelServerShare, "", "")
					$query='SELECT servername FROM servers order by servername ;'
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						_FillComboSQL($CMD_TaskExecution_SelServerShare,$qryResult)
					endif
				case "Localhost"
					GUICtrlSetData($CMD_TaskExecution_SelServerShare,"")
;~ 					GUICtrlSetData($CMD_TaskExecution_SelServerShare, @ComputerName, @ComputerName)
					GUICtrlSetData($CMD_TaskExecution_SelServerShare, "localhost", "Localhost")
				case "Custom Groups"
					GUICtrlSetData($CMD_TaskExecution_SelServerShare, "", "")
					$query='SELECT distinct(servergroupname) FROM servergroups WHERE custom=1 order by servergroupname;'
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						_FillComboSQL($CMD_TaskExecution_SelServerShare,$qryResult)
					endif
				case "Groups"
					GUICtrlSetData($CMD_TaskExecution_SelServerShare, "", "")
					$query='SELECT distinct(servergroupname) FROM servergroups WHERE custom=0 order by servergroupname;'
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						_FillComboSQL($CMD_TaskExecution_SelServerShare,$qryResult)
					endif
			EndSwitch
		EndFunc
		Func _TaskExecution_SaveBTN()
			ConsoleWrite('++_TaskExecution_SaveBTN() = '& @crlf )
			;count lists with data
			$counterDataInLST=0
			If _CheckCRTLRegex($TXT_TaskExecution_TargetPath) Then $counterDataInLST+=1
;~ 			If FileExists(_CTRLRead($TXT_TaskExecution_ExtraFile)) Then $counterDataInLST+=1
			If _GUICtrlListView_GetItemCount($LST_TaskExecution_TargetLoc)>0   Then $counterDataInLST+=1
			if 	( StringInStr(_CTRLread($CMB_TaskExecution_mode),"Script file")>0        and  _CTRLread($TXT_TaskExecution_scriptfile)<>"") or _
				( StringInStr(_CTRLread($CMB_TaskExecution_mode),"Execution commands")>0 and StringStripWS(_CTRLread($EDT_TaskExecution_commands),1+2) <> ""  ) then $counterDataInLST+=1
			If $counterDataInLST=3 Then
				GUICtrlSetState($BTN_TaskExecution_save,$GUI_ENABLE)
			Else
				GUICtrlSetState($BTN_TaskExecution_save,$GUI_DISABLE)
			endif
			if _ctrlread($TXT_TaskExecution_ExtraFile)<>"" then
				GUICtrlSetState($BTN_TaskExecution_addFile, $GUI_enable)
			Else
				GUICtrlSetState($BTN_TaskExecution_addFile, $GUI_Disable)
			endif
		EndFunc
		Func _Fill_TaskExecution_Data($sTitle)
			ConsoleWrite('++_Fill_TaskExecution_Data() = ' & $sTitle  & @crlf )
			GUISetCursor(15, 1,$TaskExecutionForm)
			if $newtask=0 then
				_Fill_Task_LST($LST_TaskExecution_TargetLoc,"TargetLoc",0)
				GUICtrlSetData($TXT_TaskExecution_taskdesc,_CheckTaskDescription())
				_FillcommandScript()
				$CheckTaskExtraFiles=_CheckTaskExtraFiles()
				_GUICtrlListView_AddArray($LST_TaskExecution_extraFiles,$CheckTaskExtraFiles)
			endif
			_setTypeUpdate($CK_TaskForms_UpdateTypesTRG,"TargetLoc")
			GUICtrlSetData($TXT_TaskExecution_TargetPath,_CheckTaskTargetPath())
			GUICtrlSetData($LBL_TargetLoc,"Cant:"&_GUICtrlListView_GetItemCount($LST_TaskExecution_TargetLoc)  )
			_Fill_task_credCMB($CMB_TaskExecution_TargetCred)
			_select_task_credCMB($TaskExecutionForm,$CMB_TaskExecution_TargetCred,"TargetLoc")
			$executeFileFolderDefault = _GetAppSettings("ExecutableFileFolderDefault",@WorkingDir)
			GUISetCursor(-1, 1,$TaskExecutionForm)
		EndFunc
		Func _FillcommandScript()
			ConsoleWrite('++_FillcommandScript()() = '& @crlf )
			$restast=_CheckTaskCommands()
			if IsArray($restast) then
				$res=stringreplace($restast[1],"|\n",@crlf)
				if stringinstr($res,"SCRIPT")=1 then
					GUICtrlSetData($TXT_TaskExecution_scriptfile,StringRegExpReplace($res,'^SCRIPT',"") )
					ControlCommand ($TaskExecutionForm, "", $CMB_TaskExecution_mode, "SelectString", "Script file (CMD/BAT/PS1)")
				Else
					GUICtrlSetData($EDT_TaskExecution_commands,$res)
					ControlCommand ($TaskExecutionForm, "", $CMB_TaskExecution_mode, "SelectString", "Execution commands")
				endif
			endif
		EndFunc
		Func _CheckTaskCommands($taskIDentifier=$taskID)
			ConsoleWrite('++_CheckTaskCommands() = ' & $jobID&" - " & $taskIDentifier& @crlf )
			$query='SELECT commands FROM tasks WHERE vertice="TargetPath"  and taskuid=' & $taskIDentifier
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
			If  IsArray($qryResult) then
				If UBound($qryResult)>1 then
					$res=stringsplit($qryResult[1][0],"|extraFiles|",1)
					Return $res
				Else
					Return ""
				endif
			endif
		EndFunc
		Func _GetTaskCommands($taskIDentifier)
			ConsoleWrite('++_GetTaskCommands()= '& @crlf )
			$res=_CheckTaskCommands($taskIDentifier)
			return $res
		EndFunc
		Func _CheckTaskExtraFiles()
			ConsoleWrite('++_CheckTaskExtraFiles() = ' & $jobID&" - " & $taskID& @crlf )
			$query='SELECT commands FROM tasks WHERE vertice="TargetPath" and taskuid=' & $taskID
			_SQLITEqry($query,$profiledbfile)  ;$quietSQLQuery
			If  IsArray($qryResult) then
				If UBound($qryResult)>1 then
					$resArr=stringsplit($qryResult[1][0],"|extraFiles|",1)
					if $resArr[2]<>"" then
						$resArr1=stringsplit($resArr[2],"|",2)
						Local $aItems[UBound($resArr1)][1]
						For $iI = 0 To UBound($resArr1) - 1
							$aItems[$iI][0] = $resArr1[$iI]
						Next
						Return $aItems
					Else
						Return ""
					endif
				Else
					Return ""
				endif
			endif
		EndFunc
		Func _CheckTaskTargetPath()
			ConsoleWrite('++_CheckTaskTargetPath() = ' & $jobID&" - " & $taskID& @crlf )
			$query='SELECT unit FROM tasks WHERE vertice="TargetPath" and taskuid=' & $taskID
			_SQLITEqry($query,$profiledbfile)  ;$quietSQLQuery
			If  IsArray($qryResult) then
				If UBound($qryResult)>1 then
					Return $qryResult[1][0]
				Else
					Return _GetAppSettings("ExecutableWorkingFolder","c:\tmp")
				endif
			endif
		EndFunc
		Func TaskExecutionClose()
			ConsoleWrite('++TaskExecutionClose() = '& @crlf )
			If GUICtrlGetState($BTN_TaskExecution_save)=144 Then ; 144 = 128 + 16 (Disabled + visible) and 80 = 64 + 16 (Enabled + visible).
				$mensaje=""
			ELSE
				$mensaje="Did You saved your task?" & @CRLF & "Unsaved task config will be lost"
			ENDIF
			If $taskFormActivity=0 Then $mensaje=""
			If _AreYouSureYesNo($mensaje) Then
				$selectedJob=_ctrlread($TXT_JobCreation_jobname)
				GUIDelete($TaskExecutionForm)
				$taskID=0
				$taskFormActivity=0
				_ReduceMemory()
				GUISetState(@SW_SHOW,$JobCreationForm)
				$WM_Notify_Silent=1
				_FillJobList()
				_FillTaskJobList()
				_JobCreation_disableGral()
				_Clear_TaskCreation_Variables()
				_selectJobInList()
;~ 				GUICtrlSetData($TXT_JobCreation_jobdescription,"")
				$WM_Notify_Silent=0
				GUICtrlSetData($TXT_JobCreation_jobname,$selectedJob)
			endif
		EndFunc
		Func _selectExecuteFile()
			ConsoleWrite('++_selectExecuteFile' & @crlf )
			Local Const $sMessage = "Select file to execute"
			If _CTRLRead($TXT_TaskExecution_ExtraFile)<>"" Then $executeFileFolderDefault=GetDir(_CTRLRead($TXT_TaskExecution_ExtraFile))
			Local $sFileOpenDialog = FileOpenDialog($sMessage, $executeFileFolderDefault & "\", _
						"Executables (*.exe;*.msi;*.msu;*.cmd;*.bat)|All Files (*.*)",1+2,"",$TaskExecutionForm)
			If @error Then
;~ 				MsgBox(64+4096, "", "No file was selected.")
;~ 				GUICtrlSetData($TXT_TaskExecution_ExtraFile,"")
			Else
				GUICtrlSetData($TXT_TaskExecution_ExtraFile,$sFileOpenDialog)
			EndIf
			FileChangeDir($sWorkingDir)
		EndFunc
		Func _selectExecuteScript()
			ConsoleWrite('++_selectExecuteScript' & @crlf )
			Local Const $sMessage = "Select Script to execute"
			If _CTRLRead($TXT_TaskExecution_scriptfile)<>"" Then $executeFileFolderDefault=GetDir(_CTRLRead($TXT_TaskExecution_scriptfile))
			Local $sFileOpenDialog = FileOpenDialog($sMessage, $executeFileFolderDefault & "\", _
						"Scripts (*.ps1;*.cmd;*.bat)|All Files (*.*)",1+2,"",$TaskExecutionForm)
			If @error Then
;~ 				MsgBox(64+4096, "", "No file was selected.")
;~ 				GUICtrlSetData($TXT_TaskExecution_ExtraFile,"")
			Else
				GUICtrlSetData($TXT_TaskExecution_scriptfile,$sFileOpenDialog)
			EndIf
			FileChangeDir($sWorkingDir)
		EndFunc
		Func _ExecutionData_Store($sTitle,$commands,$execPath,$extraFiles,$TaskActive=1)
			ConsoleWrite('++_ExecutionData_Store() $taskID= '& $taskID & @crlf )
			$vertice="TargetPath"
			$filter=""
			$commands=StringReplace($commands,@crlf,"|\n")
			$commands=StringReplace($commands,"'","''")
			$commands=$commands&"|extraFiles|"&$extraFiles
			$query='REPLACE INTO tasks VALUES (null,' & $taskID & ',"' & $sTitle  & '","' & $vertice & '","Path","' & _
						$execPath & '",' & $JobID & ',"' & clearstring(_CtrlRead($TXT_TaskExecution_taskdesc)) & _
						'","-","-",' & $taskorder & ',"' & $filter & '",'& $TaskActive & ',"' & $commands &'","",0);'
			ConsoleWrite('!!@@ Debug(' & @ScriptLineNumber & ') : $query = ' & $query & @crlf )

			if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
				Return True
			Else
;~ 					MsgBox(48+4096,"Saving Task data error","An error saving Task data. ErrNo 1005" & @CRLF & $query,0,0)
				Return False
			EndIf
		EndFunc
		Func _CommandHashedFile($path,$stringToAdd)
			ConsoleWrite('++++_CommandHashedFile() = '& @crlf )
			$filaName=_CreateTempfile($path)
			Local $fileh = FileOpen($filaName, 1)
			If $fileh = -1 Then
				MsgBox(48+4096, "Error Creating Minion Execution file Job", "Unable to open file "&$filaName&" for Command execution Minion File."&@crlf&"ErrNo: 2200")
				Return false
			EndIf
				FileWriteLine($fileh, _Hashing($stringToAdd,0) & @CRLF)
			FileClose($fileh)
			Return $filaName
		EndFunc
	#endregion
	#region ******************************** FORM Run Job Console form    ***********************
		Func JobConsole_FormClose()
			ConsoleWrite('++JobConsole_FormClose() = '& @crlf )
			GUIRegisterMsg($WM_SIZE, "")
			GUIRegisterMsg($WM_PAINT, "")
			HotKeySet("{F10}")
			HotKeySet("{F9}")
			$HotKeyPause=0
			$hotKeyKill=0
			GUICtrlSetData($LBL_RUNalert,"  Running Job  ")
			GUICtrlSetstate($LBL_RUNalert,$GUI_HIDE)
			_ReduceMemory()
			GUISetState(@SW_HIDE,$JobConsoleForm)
			GUICtrlSetState($BTN_JobCreation_runjob,$GUI_ENABLE)
			GUICtrlSetState($CK_JobConsole_RunOneByOne,$GUI_UNCHECKED)
			GUICtrlSetState($CK_JobConsole_progress,$GUI_UNCHECKED)
			 WinActivate ($JobCreationForm, "")
		EndFunc
		Func _TrashAlert($arrsrv)
			ConsoleWrite('++_TrashAlert() = '& @crlf)
			_printFromArray($arrsrv,"_TrashAlert")
			$res=""
			For $i=1 To UBound($arrsrv)-1
				If $arrsrv[$i][0]<>@ComputerName and $arrsrv[$i][0]<>"localhost" And StringRegExp($arrsrv[$i][0],"^\\\\")=0 Then
					If _CheckIfTrash($arrsrv[$i][0]) Then
						$res=@tab&@tab&$arrsrv[$i][0]
						ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $res = ' & $res & @crlf )
						return $res
					EndIf
				EndIf
			next
			return $res
		EndFunc
		Func _CheckIfTrash($servidor)
			ConsoleWrite('+++_CheckIfTrash() = '&$servidor& @crlf)
			$query='SELECT servername FROM servers WHERE servername="' & $servidor & '" AND trash=1 AND custom=0;'
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
			If  IsArray($qryResult) then
				If UBound($qryResult)>1 Then Return true
				Return false
			endif
		EndFunc
		Func _DeletedAlert($arrsrv)
			ConsoleWrite('++_DeletedAlert() = '& @crlf)
			$res=""
			For $i=1 To UBound($arrsrv)-1
				If $arrsrv[$i][0]<>@ComputerName and $arrsrv[$i][0]<>"localhost" And StringRegExp($arrsrv[$i][0],"^\\\\")=0 Then
					If _CheckIfDeleted($arrsrv[$i][0]) Then
						$res=@tab&@tab&$arrsrv[$i][0]
						return $res
					EndIf
				EndIf
			next
			return $res
		EndFunc
		Func _CheckIfDeleted($servidor)
			ConsoleWrite('+++_CheckIfDeleted() = '&$servidor& @crlf)
			$query='SELECT servername FROM servers WHERE servername="' & $servidor & '";'
			_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
			If  IsArray($qryResult) then
				If UBound($qryResult)=1 Then Return true
				Return false
			endif
		EndFunc
	#endregion
	#region ******************************** FORM About                   ***********************
	Func FormAboutClose()
		ConsoleWrite('++FormAboutClose() = '& @crlf)
		GUIDelete ( $FormAbout )
		_AboutVarsInit()
		AdlibUnRegister ( '_WaterBlob' )
		_FlattenWater ()
		_DisableWater ()
		DllClose ( $hWaterDll )
		_GDIPlus_ShutDown ()
		_ReduceMemory()
		GUICtrlSetState($B_Close,$GUI_ENABLE)
	EndFunc
	#endregion
#endregion
#region config initial
	Func _SetDesktopShortcut()
		ConsoleWrite('++_SetDesktopShortcut() = '& @crlf )
		if $GUI_CHECKED=_GetAppSettings("CreateDesktopShortcut",$GUI_CHECKED) then
			FileCreateShortcut(@ScriptFullPath ,@DesktopDir & "\FileGodMode.lnk")
		endif
	EndFunc
	func _ConfigDBInitial($flagForceUpdateProjectData=0)
		ConsoleWrite('++ConfigDBInitial() = '& @crlf )
		$quiet=true
		_SQLite_down()
		; -------config dbs
			_DBvarInit()
			if @Compiled then
				$profiledbfile=@AppDataDir &"\FGM\" & $profiledbfile
			endif
			$Basedbfile=@AppDataDir &"\FGM\" & $Basedbfile
			FileCopy($tempDir & "\profilebase.db",$profiledbfile,0)
			FileCopy($tempDir & "\FGMbase.db",$Basedbfile,0)
		; -------check if SQLIte profile db exist
			SQLite_init()
			$SQLq="SELECT name FROM sqlite_temp_master WHERE type='table';"
			_SQLITErun($SQLq,$profiledbfile,$quietSQLQuery)
			ConsoleWrite('! $profiledbfile = ' & $profiledbfile & @crlf )
;~ 		; ---------- update projects db files packaged  . listed in fileIncludes.au3
;~ 			for $i=0 to UBound($packagedDBs)-1
;~ 				_UpdatePrjDBprofile($FgmDataFolder & "\" & $packagedDBs[$i])
;~ 			next
		;----------  check schema nad update profile db
			_CheckProfileDbSchema()
		; ------ check configed db fgm
			$FGMdbFile=_ActiveDatabaseFile()
			_SQLite_down()
			;-  check if proyect database was already updated for this version compilation
			;   $flagForceUpdateProjectData=0  ; Force project data update
			if _CheckProyectDBupdate() or $flagForceUpdateProjectData then
				if $flagForceUpdateProjectData=1 then ConsoleWrite('! Force project data update  $flagForceUpdateProjectData=1 '& @crlf)
				GUICtrlSetstate($LBL_ProgressGui_Load,$GUI_SHOW)
				If $FGMdbFile<>"" Then
					; -------check SQLIte profile db
;~ 					$dbtemp= $FGMdbFile
					$FGMdbFile=$FgmDataFolder & "\" &  $FGMdbFile
;~ 					$res=Filecopy($tempDir & "\"&$dbtemp,$FGMdbFile,1)
					SQLite_init()
					$SQLq="SELECT name FROM sqlite_temp_master WHERE type='table';"
					_SQLITErun($SQLq,$FGMdbFile,$quietSQLQuery)
					;-----------  profile database merge on upgrade
	;~ 				If _CheckIfUpgraded() Then
						ConsoleWrite('! profile database merge on upgrade '& @crlf)
;~ 						_LoadTimerPrint("before Mergedb " & @ScriptLineNumber )
						;---------- merge  FGM.db to profile servers  Mergedb.au3
						_CopyTableFromDB($FGMdbFile,"servers",$profiledbfile,"FGMservers",'',$quiet)
;~ 						_LoadTimerPrint("after _CopyTableFromDB() " & $FGMdbFile)
						_CopyTableFromDB($FGMdbFile,"servergroups",$profiledbfile,"FGMservergroups",'',$quiet)
;~ 						_LoadTimerPrint("after _CopyTableFromDB() " & $FGMdbFile)
						_CopyTableFromDB($FGMdbFile,"RServerGroup",$profiledbfile,"FGMRServerGroup",'',$quiet)
;~ 						_LoadTimerPrint("after _CopyTableFromDB() " & $FGMdbFile)
						If _UpdateFromServersFGM($quiet) Then
							_MarkUpdated("UpdatedDB")
						Else
							_MarkUpdated("UpdateDB")
						endif
						If Not @Compiled Then _MarkUpdated("UpdateDB")
						_SQLite_Close()
	;~ 				endif
					;-----------------------------
					_updateProyectDBupdateValue($version)
				Else
					ConsoleWrite('!!! no merger nada porque no hay fgmdb seleccionada ' & @crlf )
				endif
				GUICtrlSetstate($LBL_ProgressGui_Load,$GUI_HIDE)
			else
				ConsoleWrite('!!! No Update of Proyect data, since its has bee updated earlier in this version ' & @crlf )
			endif
		;------------ add dummy server --------
			_Update_DummyServer()
		;-------- delete credential that do not match login
			_DeleteCredassert()
		;-------- Init Log
			_initLog()
		;------------------------------------------------------------------------------
	EndFunc
#cs
	#RequireAdmin
	_Associate (".fgm", "FGMFile", @ScriptDir)

	Func  _Associate($EXT , $FileType, $FileName)
		$f=RegWrite("HKCR\" & $EXT & "\", $FileType)
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $f = ' & $f & @crlf )
		RegWrite("HKCR\" & $FileType & "\", "MY file")
		RegWrite("HKCR\" & $FileType & "\DefaultIcon\", $FileName)
		RegWrite("HKCR\" & $FileType & "\shell\open\command\", $FileName & " %L")

		RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & $EXT & "\Application")
		RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & $EXT & "\Application", $FileName)
		RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & $EXT & "\OpenWithList\")
		RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & $EXT & "\OpenWithList\a", $FileName)
	Endfunc
	;~ #endregion
#ce










