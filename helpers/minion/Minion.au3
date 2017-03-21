#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Minion-reading-icon.ico
#AutoIt3Wrapper_Outfile=FGMminion.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=FGM Minion Worker Agent - Management & Automation
#AutoIt3Wrapper_Res_Description=File God Mode Minion Worker Agent
#AutoIt3Wrapper_Res_Fileversion=0.1.0.36
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductVersion=0.1
#AutoIt3Wrapper_Res_LegalCopyright=Marcelo N. Saied & Roberto P Iralour . All rights reserved
#AutoIt3Wrapper_Res_Field=Productname|File God Mode Worker Agent
#AutoIt3Wrapper_Res_Field=ProductVersion|Version 1.0.0.0
#AutoIt3Wrapper_Res_Field=Manufacturer |Marcelo N. Saied & Roberto P Iralour . All rights reserved
#AutoIt3Wrapper_Res_Field=Compile date|%longdate% %time
#AutoIt3Wrapper_Add_Constants=n
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/mergeonly
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;~ #Obfuscator_Parameters=/cs=1 /cn=1 /cf=1 /cv=1 /sf=1 /sv=1
;~ #Obfuscator_Parameters=/cs=1 /cn=1 /cf=1 /cv=1 /sf=1
;~
$UnitTest=0
;===================================================================
;===================================================================
;===                                                             ===
;===   Name = FGMminion.exe                                      ===
;===          FGM Minion Worker Agent - Management & Automation  ===
;===                                                             ===
;===   Description:FGM worker agent - remote execution agent     ===
;===                                                             ===
;===   Author: Marcelo N. Saied                                  ===
;===           marcelosaied@gmail.com                            ===
;===                                                             ===
;===   Design: Roberto P. Iralour                                ===
;===           RobertoIralour@gmail.com                          ===
;===                                                             ===
;===   Automation and Scripting Language: AUTOIT  v3.3.8.1       ===
;===           http://www.autoitscript.com/site/                 ===
;===                                                             ===
;===   Created on: Jan 31 , 2017                                 ===
;===                                                             ===
;===================================================================
;===================================================================
#region LoadInit
	#include <includes.au3>
	If _Singleton(@ScriptName, 1) = 0 Then ; allow only one instance
		_ConsoleWrite("Warning - An occurence of FGMminion "& $version & " is already running")
		Exit
	EndIf
	_ConsoleWrite('FGMminion ' & FileGetVersion(@ScriptName)& @crlf )
	_ReduceMemory()
#endregion
#Region  ------------ init
#EndRegion
#Region  ------------ Modules
#EndRegion
#Region  -----------------------------  parse arguments ------------------------------
; Help
   $helpText="Help:                                                                     " & @crlf & _
			"                                                                           " & @crlf & _
			"      Usage:                                                               " & @crlf & _
			"            FGMminion.exe -b <Batch File name>                             " & @crlf & _
			"                                                                           " & @crlf & _
			"            -b   Batch File name                                           " & @crlf & _
			"                                                                           " & @crlf & _
			"                                                                           " & @crlf & _
			"            Author: Saied, Marcelo                                         " & @crlf & _
			"            Design: Roberto, P. Iralour                                    " & @crlf & _
			"                                                                           " & @crlf & _
			"            Developed for FILEGODMODE.   2014-2017                         " & @crlf & _
			"                                                                           " & @crlf & _
			"                                                                           " & @crlf & _
			"                                                                           " & @crlf & _
			"                                                                           "

   if $CmdLine[0]=0 then
	  ConsoleWrite($helpText)
	   exit 1
   endif
   if StringStripWS($CmdLine[1],4)="?"   then  ; output help
	  ConsoleWrite($helpText)
	    exit 3
	endif
    if $CmdLine[0]<>2 then  ; if no 3 argumentes then exit    -f filename  -u username -p password  ([-d][-nd])
	  ConsoleWrite("No enough arguments. <Usage>: FGMminion.exe -b <Batch File name>  ")
	  exit 5
   endif

   for $x=1 to $CmdLine[0]-1
	  Select
	  case $CmdLine[$x] = "-b"
			$x = $x + 1
			if StringLen($CmdLine[$x]) > 2 then   $filaName=$CmdLine[$x]
		 Case Else
			ConsoleWrite("No enough arguments <Usage>: FGMminion.exe -b <Batch File name>   ")
			ConsoleWrite("                             FGMminion.ex ?  for help  ")
			ConsoleWrite(@CRLF)
			exit 6
	  EndSelect
   Next
#EndRegion

$commands=_GetCommandHashedFile($filaName)
_ConsoleWrite($commands)







_exit()