
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=images\TransferDEV.ico
#AutoIt3Wrapper_Outfile=.\release\FileGodMode.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=Development version - File Deployer - Management & Automation
#AutoIt3Wrapper_Res_Description=Development version - File Deployer - Management & Automation
#AutoIt3Wrapper_Res_Fileversion=0.4.4.808
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductVersion=0.4.4
#AutoIt3Wrapper_Res_LegalCopyright=Marcelo N. Saied & Roberto P Iralour . All rights reserved
#AutoIt3Wrapper_Res_Field=Productname|FileGodMode
#AutoIt3Wrapper_Res_Field=ProductVersion|Version 0.4.4
#AutoIt3Wrapper_Res_Field=Manufacturer |Marcelo N. Saied & Roberto P Iralour . All rights reserved
#AutoIt3Wrapper_Res_Field=Compile date|%longdate% %time%
#AutoIt3Wrapper_Run_Before=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\CopySecretsBefore.cmd
#AutoIt3Wrapper_Run_Before=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\updaterCompilerDEV.cmd
#AutoIt3Wrapper_Run_Before=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\versioncheckerCompiler.cmd
#AutoIt3Wrapper_Run_Before=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\FGMminionCompiler.cmd
#AutoIt3Wrapper_Run_Before=start c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\FGMagentCompilerDev.cmd
#AutoIt3Wrapper_Run_After=start c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\deployDEV.cmd  %fileversion%
#AutoIt3Wrapper_Run_After=start c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\deployDEVfilegodmode.azurewebsites.net.cmd  %fileversion%
#AutoIt3Wrapper_Run_After=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\CopySecretsAfter.cmd
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/mergeonly
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; *** End added by AutoIt3Wrapper ***
;~ #Obfuscator_Parameters=/cs=1 /cn=1 /cf=1 /cv=1 /sf=1 /sv=1
;~ #Obfuscator_Parameters=/cs=1 /cn=1 /cf=1 /cv=1 /sf=1

#include <main.au3>