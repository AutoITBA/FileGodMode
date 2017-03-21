#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=.\images\transfer.ico
#AutoIt3Wrapper_Outfile=.\release\prod\FileGodMode.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=File Deployer - Management & Automation
#AutoIt3Wrapper_Res_Description=File Deployer - Management & Automation
#AutoIt3Wrapper_Res_Fileversion=0.4.4.811
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductVersion=0.4.4
#AutoIt3Wrapper_Res_LegalCopyright=Marcelo N. Saied & Roberto P. Iralour . All rights reserved
#AutoIt3Wrapper_Res_Field=Productname|FileGodMode
#AutoIt3Wrapper_Res_Field=ProductVersion|Version 0.4.4
#AutoIt3Wrapper_Res_Field=Manufacturer |Marcelo N. Saied & Roberto P. Iralour . All rights reserved
#AutoIt3Wrapper_Res_Field=Compile date|%longdate% %time%
#AutoIt3Wrapper_Run_Before=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\prod\CopySecretsBefore.cmd
#AutoIt3Wrapper_Run_Before=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\prod\updaterCompiler.cmd
#AutoIt3Wrapper_Run_Before=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\prod\versioncheckerCompiler.cmd
#AutoIt3Wrapper_Run_Before=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\prod\FGMminionCompiler.cmd
#AutoIt3Wrapper_Run_Before=start c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\prod\FGMagentCompiler.cmd
#AutoIt3Wrapper_Run_After=start c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\prod\deployPROD.cmd  %fileversion%
#AutoIt3Wrapper_Run_After=start c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\prod\deployfilegodmode.azurewebsites.net.cmd  %fileversion%
#AutoIt3Wrapper_Run_After=cmd /c c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\prod\CopySecretsAfter.cmd
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#Obfuscator_Parameters=/mergeonly
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;~ #AutoIt3Wrapper_Run_After=start c:\dropbox\Shared\RobertoI@MarceloSaied\FileGodMode\Release\prod\deployPublic.cmd  %fileversion%
;~ #AutoIt3Wrapper_Run_Obfuscator=y

#include <mainProd.au3>