Dim $filesArray[20]
$k=0
$k = $k + 1
$filesArray[$k]="C:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Main.au3"
$k = $k + 1
$filesArray[$k]="C:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\MainProd.au3"
$k = $k + 1
$filesArray[$k]="C:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\func_pos.au3"
$k = $k + 1
$filesArray[$k]="c:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\controls\controles.au3"
$k = $k + 1
$filesArray[$k]="c:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\controls\Functions.au3"
;~ $k = $k + 1
;~ $filesArray[$k]="C:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\controls\Func_FormSettings.au3"
$k = $k + 1
$filesArray[$k]="c:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\controls\Func_general.au3"
;~ $k = $k + 1
;~ $filesArray[$k]="c:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\controls\Func_WM_NOTIFY.au3"
;~ $k = $k + 1
;~ $filesArray[$k]="C:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\controls\Func_WM_COMMAND.au3"
$k = $k + 1
$filesArray[$k]="C:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\controls\RunFunctions.au3"
$k = $k + 1
$filesArray[$k]="c:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\variables.au3"
;~ $k = $k + 1
;~ $filesArray[$k]="c:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\controls\Func_PrjRepo.au3"
;~ $k = $k + 1
;~ $filesArray[$k]="c:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\controls\Func_Zipmakecab.au3"
;~ $k = $k + 1
;~ $filesArray[$k]="C:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\controls\Func_FGMagentconnector.au3"
;~ $k = $k + 1
;~ $filesArray[$k]="C:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\forms\formexportimportservers.au3"

#region minion
;~ 	$k = $k + 1
;~ 	$filesArray[$k]="C:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\helpers\minion\minion.au3"
;~ 	$k = $k + 1
;~ 	$filesArray[$k]="C:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\helpers\minion\Functions.au3"
;~ 	$k = $k + 1
;~ 	$filesArray[$k]="C:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\helpers\minion\Includes.au3"
;~ 	$k = $k + 1
;~ 	$filesArray[$k]="C:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\helpers\minion\variables.au3"
#endregion

$sessionFile="ms.session"
Local $fileSession = FileOpen($sessionFile, 2)

For $i=1 to UBound($filesArray)
	Local $file = FileOpen( $filesArray[$i], 0)

	; Check if file opened for reading OK
	If $file = -1 Then
		ConsoleWrite("Unable to open file." &  $filesArray[$i])
		Exit
	EndIf
	$counter=0
	$result=""
	While 1
		$counter=$counter+1
		Local $line = FileReadLine($file)
		If @error = -1 Then ExitLoop
		If (StringInStr($line,"Func ")>0 And StringInStr($line,"EndFunc ")=0) Or StringInStr($line,"Case ")>0 Or _
			StringInStr($line,"#region f-")>0 Or StringInStr($line,"#region f#")>0 Or StringInStr($line,"#cs")>0 Or _
			StringInStr($line,"; #FUNCTION#")>0 Or StringInStr($line,"; #CURRENT#")>0 Or StringInStr($line,"; #INDEX#")>0 Or _
			StringInStr($line,"; #INDEX#")>0 Then
			$result=$result&","&$counter
		endif
	WEnd
	$linea='buffer.'&$i&'.path='& $filesArray[$i]
	FileWriteLine($fileSession,$linea)
	$linea='buffer.'&$i&'.folds='& StringTrimLeft($result,1)
	FileWriteLine($fileSession,$linea)
	ConsoleWrite('$result = ' & StringTrimLeft($result,1) & @crlf )
	FileClose($file)
next

FileClose($fileSession)
