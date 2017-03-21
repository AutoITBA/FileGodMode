#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\images\versionchecker.ico
#AutoIt3Wrapper_Outfile=versionChecker.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=By Marcelo Saied
#AutoIt3Wrapper_Res_Description=FileGodMode Version checker helper
#AutoIt3Wrapper_Res_Fileversion=1.0.0.327
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductVersion=1.0.0
#AutoIt3Wrapper_Res_LegalCopyright=By Marcelo Saied
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Productname|FileGodMode Version checker helper
#AutoIt3Wrapper_Res_Field=ProductVersion|Version 1.0.0
#AutoIt3Wrapper_Res_Field=Manufacturer|Marcelo Saied
#AutoIt3Wrapper_Run_Obfuscator=y
;~ #Obfuscator_Parameters=/cs=1 /cn=1 /cf=1 /cv=1 /sf=1
#Obfuscator_Parameters=/mergeonly
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#region variables
	Global $oMyError = ObjEvent("AutoIt.Error","MyErrFunc")
	Global $WebServiceaddr="Http://acnalert.cloudapp.net/FGM"
	Global $WebServiceaddr="Https://filegodmode.azurewebsites.net/FGM"
	Const $HTTPREQUEST_SETCREDENTIALS_FOR_PROXY = 1
	Global $profiledbfile="profile.db"  ; re setted at ConfigInitial()
	If Not @Compiled Then
		If @UserName="marcelo" or @UserName="a127314"  then
			Global $profiledbfile="c:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\profileMarcelo.db"
		endif
		If @UserName="roberto.p.iralour" then
			Global $profiledbfile="c:\Dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\profileRoberto.db"
		endif
	endif
	$quietSQLQuery=0
	$qryResult=""
	$FgmDataFolder=@UserProfileDir & "\AppData\Roaming\FGM"
	$FgmDataFolderResources=$FgmDataFolder & "\Resources"
	$sSQliteDll=""
	Global $FGMdbFile=""
	Global $Basedbfile=""
	Global $EncryptDB=true
	if $EncryptDB  then
		#include <..\..\secrets/dbEncriptionPass.secret>
	Else
		Global $FGMencript=""
		Global $profiledbencript=""
		Global $basedbencript=""
		Global $defaultdbencript=""
	endif
	global $qryResult
	$HashingPassword = ""
	#include <..\..\secrets/HashingPassword.secret>
#endregion
#region udf
	#include <GUIConstantsEx.au3>
	#include <WindowsConstants.au3>
	#include <IE.au3>
	#include <String.au3>
	#include <SQLite.dll.au3>
	#include <..\..\SQLite\SQLite.au3>
	#include <..\..\SQLite\SQLite_Functions.au3>
	#include <..\..\SQLite\CleanString.au3>
#endregion
#region check version
	$stade=StringStripWS($CmdLine[1],1+2)
	SQLite_init()
	$versionpath = _CheckNewVersion($stade)
	ConsoleWrite( $versionpath )
	Exit
#endregion
#region functions
	Func _CheckNewVersion($stade="prod")
		if $stade="prod" then
			$qry="/?VPROD=T"
		Else
			$qry="/?VP=T"
		endif
			$sURL=$WebServiceaddr & $qry
			$oXHR = ObjCreate("MSXML2.XMLHTTP.6.0")
			$oXHR.open("GET", $sURL, False)

			;  next 4 lines if using a proxy server
;~ 			$GUI_UNCHECKED=4
;~ 			$GUI_CHECKED=1
			$useproxy=_GetAppSettings("UseProxy",$GUI_UNCHECKED)
			if $GUI_CHECKED=$useproxy then
				Local $ProxyExceptions =""
				;set credentials
					Local $proxyuser  = _GetAppSettings("ProxyUser",""); add proxy server name
					$arrcred=StringSplit($proxyuser,"\")
					$proxyPass=_get_passwd($arrcred[1],$arrcred[2])
					if $arrcred[1]="." then $proxyuser=$arrcred[2]
				;set proxy
				if $GUI_UNCHECKED=_GetAppSettings("UseProxyIE",$GUI_UNCHECKED) then
					Local $proxyserver  = _GetAppSettings("ProxyHttp",""); add proxy server name
					Local $proxyport  = _GetAppSettings("ProxyPort","") ; add proxy server port
					if $proxyserver<>"" and $proxyport<>"" then
						$oXHR.setProxy("2", $proxyserver & ":" & $proxyport)
						if $proxyuser<>"" and $proxyPass<>"" then
							$oXHR.SetCredentials($proxyuser, $proxyPass, $HTTPREQUEST_SETCREDENTIALS_FOR_PROXY)
						endif
					endif
				Else
					$proxyIEarr= StringSplit(RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyServer"),":",2)
					Local $proxyserver  = $proxyIEarr[0]
					Local $proxyport  = $proxyIEarr[1]
					Local $ProxyExceptions = RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyOverride") ; get any proxy exceptions
					$oXHR.setProxy("2", $proxyserver & ":" & $proxyport, $ProxyExceptions)
				endif
			endif

			$oXHR.send()
			$err=@error

			If $err = 0 Then
				$versionpath = $oXHR.responseText
				$versionpath =ClearEmptyLines($versionpath)
				If StringInStr($versionpath,"FileVersion")>0 Then
					$fversionArr=StringSplit($versionpath,"FileVersion",1)
					If $fversionArr<>"" Then return $fversionArr[2]
				endif
				return "No data"
			else
				return "error"
			EndIf
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
	Func MyErrFunc()
		Local $HexNumber = Hex($oMyError.Number, 8)
	;~ 	ConsoleWrite("! COM Error !  Number: " & $HexNumber & @crlf &  "! ScriptLine: " & $oMyError.scriptline & @crlf & _
	;~ 	"! Source: "  & $oMyError.source & @crlf & "! Description:" & $oMyError.WinDescription  & @LF & _
	;~ 	"! Lastdllerror: " & $oMyError.lastdllerror & @crlf )
		SetError(1)
	 Endfunc
	Func _GetAppSettings($value,$defstatus,$upsert=0)  ;$upsert=1 if data is empty then instert it
;~ 		ConsoleWrite('++_GetAppSettings() = '&$value& @crlf)
		$res=$defstatus
		$query="SELECT key FROM Configuration WHERE value='"& $value &"';"
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) then
			if UBound($qryResult)>1 then
				$res=$qryResult[1][0]
				Return $res
			endif
		endif
		if $upsert=1 then
			$query='INSERT OR REPLACE INTO Configuration VALUES ("AppSettings","' & $value & '","' & $defstatus & '");'
			if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
			Else
				MsgBox(48+8192,"Saving Configuration error","An error saving configuration data. ErrNo 1054  _GetAppSettings" & @CRLF & $query,0,0)
			EndIf
		endif
		Return $res
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
	Func _Hashing($Password,$Hashflag=0)   ; 1 decrypt  to , 0 to  encrypt.
			if $Hashflag=0 then
				Local $bEncrypted = _StringEncrypt(1,$Password,$HashingPassword,1)  ;1 to encrypt, 0 to decrypt.
			Else
				Local $bEncrypted = _StringEncrypt(0,$Password,$HashingPassword,1) ;1 to encrypt, 0 to decrypt.
			EndIf
		return $bEncrypted
	EndFunc



#endregion