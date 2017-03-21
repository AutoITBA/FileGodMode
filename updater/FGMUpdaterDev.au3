#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\images\Recycle_win7.ico
#AutoIt3Wrapper_Outfile=FGMupdater.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=By Marcelo Saied
#AutoIt3Wrapper_Res_Description=FileGodMode Updater
#AutoIt3Wrapper_Res_Fileversion=1.0.0.233
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductVersion=1.0.0
#AutoIt3Wrapper_Res_LegalCopyright=By Marcelo Saied
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Productname|FileGodMode Mode Updater
#AutoIt3Wrapper_Res_Field=ProductVersion|Version 1.0.0
#AutoIt3Wrapper_Res_Field=Manufacturer|Marcelo Saied
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/cs=1 /cn=1 /cf=1 /cv=1 /sf=1
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

 ; allow only one instance
#include <Misc.au3>
If _Singleton(@ScriptName, 1) = 0 Then
    Exit
EndIf

#region variables
	Global $oMyError = ObjEvent("AutoIt.Error","MyErrFunc")

	Global $WebServiceaddr="acnalert.cloudapp.net/FGM"
	Global $WebServiceaddr="https://www.dropbox.com/sh/bhvi2ft3c2jwj17/AADz8OonRkWQEQrl-AQKbvdla?dl=0"
	Global $WebServiceaddr="filegodmode.azurewebsites.net/FGM"
	$FGMshare="\\10.11.100.44\share\FGM\FileGodMode.exe"
	$ACNalertDataFolder=@UserProfileDir & "\AppData\Roaming\FGM"
	$UpdatedStatus=0

	$handle_read = ""
	$scriptfolder =""
	$versionpath=""
	$errvalue=""
	$tempdir=_GetTempDir()
#endregion
#region includes
	#include <INet.au3>
	#include <Array.au3>
	#include <IE.au3>
	#include <Array.au3>
	#include <GUIConstants.au3>
	#include <GUIConstantsEx.au3>
	#include <webservice.au3>
	#include <WindowsConstants.au3>
	#Include <ProgressConstants.au3>
	#include <WindowsConstants.au3>
	;~ #include <..\UDF\Coroutine.au3>
	;~ #include <DelACNalert.au3>
;~ 	#include <..\help\News.au3>
#endregion
#region pre init
	; close acnalert all treads
	ProcessClose("FileGodMode.exe")
	sleep(2000)
#endregion
#region Form
   $wide=300
   $hight=120
   $left=(@DesktopWidth/2)-($wide/2)
   $top=(@DesktopHeight/2)-($hight/2)
   $progressbarwide=250
   $UpdaterBox = GuiCreate("FileGodMode Updater",$wide,$Hight,-1,-1)

	$labelTitle=GuiCtrlCreateLabel("New version of FileGodMode for download.",10,5,210,15)
	$label=GuiCtrlCreateLabel("0%",270,35,170,15)

	$label1=GuiCtrlCreateLabel("0 Mb /0 Mb",($wide/2)-30,55,170,15)
	$Progress1 = GUICtrlCreateProgress(10, 35, $progressbarwide, 17)
	$buttonupdate=GuiCtrlCreateButton("Update",90,75,50,30)
	$buttonClose=GuiCtrlCreateButton("Close",160,75,50,30)
	GUISetState(@SW_SHOW)
#endregion
#region Update
	#region check version
		$handle_read = FileOpen($tempdir & "\temp.tgm", 0)
		$line = FileReadLine($handle_read , 1)
		FileClose($handle_read)
		$linearr =StringSplit($line,"::",1)
		$scriptfolder=$linearr[2]
		$scriptname=$linearr[3]
		$version=$linearr[1]

		$versionpath = _CheckNewVersion()
		If $versionpath="" then
			GUICtrlSetState($buttonupdate,$GUI_DISABLE)
			MsgBox(4096,"FileGodMode Version update" , "Error Checking the new version of FileGodMode " & @CRLF & " Try again Later." ,15)
			$correWD=Run($scriptfolder & "\"&$scriptname)
			GUISetState(@SW_HIDE,$UpdaterBox)
			GUIDelete()
			exit
		EndIf
		$versionpath="http://"&$WebServiceaddr&"/release/"&$scriptname
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : versionpath = ' & $versionpath & @crlf )
	#endregion
	#region download
;~ $sURL="Http://" & $WebServiceSite & "/index.php"
	if FileExists($tempdir  & "\"&$scriptname) then filedelete($tempdir  & "\"&$scriptname)
	$size=0

	$autodownload=TimerInit()
	$difautodownload=0
	While 1
		$difautodownload = TimerDiff($autodownload)
	  $msg=GuiGetMsg()
	  Select
		Case $msg = $GUI_EVENT_CLOSE
			ExitLoop
		Case $msg = $buttonupdate Or $difautodownload>60000
			$labelTitle=GuiCtrlCreateLabel("Downloading New version. This will take a moment.",10,5,290,15)
			GUICtrlSetState($buttonClose,$GUI_DISABLE)
			GUICtrlSetState($buttonupdate,$GUI_DISABLE)
			sleep (1000)
			if $versionpath <> "" And $versionpath <> "" then
;~ 				If FileExists($FGMshare) Then ;$FGMshare download
;~ 					ConsoleWrite('@@(' & @ScriptLineNumber & ') : $FGMshare = ' & $FGMshare & @crlf)
;~ 					Local $size = FileGetSize($FGMshare)
;~ 					GUICtrlSetData($label1, "0 Mb /" & Round($size/1024/1024,2) & " Mb")
;~ 					GUICtrlSetData($Progress1,  "30 %")
;~ 					Local $hDownload =FileCopy($FGMshare,$tempdir & "\"&$scriptname,1)
;~ 					GUICtrlSetData($label1,  round($size/1024/1024,2) & " Mb/" & round($size/1024/1024,2) & " Mb" )
;~ 					GUICtrlSetData($Progress1,  "100 %")
;~ 					GUICtrlSetData($label, "100 %")
;~ 				Else           					;Dropbox download
					Local $size = InetGetSize($versionpath)
					ConsoleWrite('@@(' & @ScriptLineNumber & ') : $versionpath = ' & $versionpath & @crlf)
					GUICtrlSetData($label1, "0 Mb /" & Round($size/1024/1024,2) & " Mb")
					Local $hDownload =InetGet($versionpath,$tempdir  & "\"&$scriptname,1,1)
					Local $aData = InetGetInfo($hDownload)
					Local $begin = TimerInit()
					Do
						Local $BytesDownloaded = INetGetInfo($hDownload, 0)
						Local $FileProgress = Floor(($BytesDownloaded / $size) * 100)
						GUICtrlSetData($label1, round($BytesDownloaded/1024/1024,2) & " Mb /" & round($size/1024/1024,2) & " Mb")
						GUICtrlSetData($Progress1, $FileProgress & " %")
						GUICtrlSetData($label, $FileProgress & " %")
						Sleep(250)
						if TimerDiff($begin)>300000 then exitloop
					Until InetGetInfo($hDownload, 2)
					if InetGetInfo($hDownload, 3)=False then ExitLoop
					GUICtrlSetData($label1,  round($size/1024/1024,2) & " Mb/" & round($size/1024/1024,2) & " Mb" )
					GUICtrlSetData($Progress1,  "100 %")
					GUICtrlSetData($label, "100 %")
;~ 				endif
			Else
				GUICtrlSetState($buttonClose,$GUI_ENABLE)
;~ 				GUICtrlSetState($buttonupdate,$GUI_ENABLE)
				MsgBox(4096,"Version Update", "Error updating the new version of FileGodMode " & @CRLF & _
				" Try again Later. "   ,0)
				ExitLoop
			endif

			$localsize=FileGetSize($tempdir & "\"&$scriptname)
			if FileExists($tempdir & "\"&$scriptname) and $localsize = $size and FileGetSize($tempdir  & "\"&$scriptname) <>0 then
				if FileExists($scriptfolder   & "\"&$scriptname) Then
					$r=filedelete($scriptfolder  & "\"&$scriptname)
				endif
				$r=FileCopy($tempdir  & "\"&$scriptname, $scriptfolder ,1)
				If $r=1 Then _MarkUpdated()
				GUICtrlSetState($buttonClose,$GUI_ENABLE)
;~ 				GUICtrlSetState($buttonupdate,$GUI_ENABLE)
				ExitLoop
			Else
				GUICtrlSetState($buttonClose,$GUI_ENABLE)
;~ 				GUICtrlSetState($buttonupdate,$GUI_ENABLE)
				MsgBox(4096,"FileGodMode Version update" , "Error while updating the new version of FileGodMode " & @CRLF & _
				"The File " & $scriptname & " remote size of " & $localsize  & " and  downloaded sizeof  " & $size  	& _
				" on DIR  " & $tempdir & " created an exception. "  & @CRLF & _
				" Try again Later." & @CRLF ,0)
			EndIf
			ExitLoop
		 Case $msg = $buttonClose
			ExitLoop
		EndSelect
	Wend

	#endregion
#endregion

	sleep (2000)
	If @Compiled Then $correWD=Run($scriptfolder   & "\"&$scriptname)
	GUISetState(@SW_HIDE,$UpdaterBox)
	GUIDelete()
	exit

	Func _CheckNewVersion()
			$sURL="Http://" & $WebServiceaddr & "/?VP=T"
			ConsoleWrite(') : $sURL = ' & $sURL & @crlf)
			$oXHR = ObjCreate("MSXML2.XMLHTTP.6.0")
			$oXHR.open("GET", $sURL, False)
			$oXHR.send()
			If @error = 0 Then
				$versionpath = $oXHR.responseText
				ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $versionpath = ' & $versionpath & @crlf )
				$versionpath =ClearEmptyLines($versionpath)
	;~ 			$versionpath = StringSplit($versionpath, '</br>',1)
				If StringInStr($versionpath,"FileVersion")>0 Then
					$fversionArr=StringSplit($versionpath,"FileVersion",1)
					_printfromarray($fversionArr)
					If $fversionArr<>"" Then return $fversionArr[2]
				endif
				return "No data"
			else
				return "error"
			EndIf
	EndFunc
	Func MyErrFunc()
		Local $HexNumber = Hex($oMyError.Number, 8)
		ConsoleWrite("! COM Error !  Number: " & $HexNumber & @crlf &  "! ScriptLine: " & $oMyError.scriptline & @crlf & _
		"! Source: "  & $oMyError.source & @crlf & "! Description:" & $oMyError.WinDescription  & @LF & _
		"! Lastdllerror: " & $oMyError.lastdllerror & @crlf )
		SetError(1)
	 Endfunc
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
	Func _PrintFromArray(ByRef Const $aArray, $iBase = Default, $iUBound = Default, $sDelimeter = "|")
		; Check if we have a valid array as input
		If Not IsArray($aArray) Then Return SetError(1, 0, 0)

		; Check the number of dimensions
		Local $iDims = UBound($aArray, 0)
		If $iDims > 2 Then Return SetError(2, 0, 0)

		; Determine last entry of the array
		Local $iLast = UBound($aArray) - 1
		If $iUBound = Default Or $iUBound > $iLast Then $iUBound = $iLast
		If $iBase < 0 Or $iBase = Default Then $iBase = 0
		If $iBase > $iUBound Then Return SetError(3, 0, 0)

		If $sDelimeter = Default Then $sDelimeter = "|"

		; Write array data to the console
		ConsoleWrite("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF)
		Switch $iDims
			Case 1
				For $i = $iBase To $iUBound
					ConsoleWrite("[" & $i - $iBase & "] " & $aArray[$i] & @CRLF)
				Next
			Case 2
				Local $sTemp = ""
				Local $iCols = UBound($aArray, 2)
				For $i = $iBase To $iUBound
					$sTemp = $aArray[$i][0]
					For $j = 1 To $iCols - 1
						$sTemp &= $sDelimeter & $aArray[$i][$j]
					Next
					ConsoleWrite("[" & $i - $iBase & "] " & $sTemp & @CRLF)
				Next
			EndSwitch
			ConsoleWrite("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF)
		Return 1
	EndFunc   ;==>_PrintFromArray
	Func _MarkUpdated()
		$handle_write = FileOpen($tempdir & "\temp.tgm", 2)   ; record  script folderb
		FileWriteLine($handle_write,"UpdateDB::" & @ScriptDir)
		FileClose($handle_write)
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