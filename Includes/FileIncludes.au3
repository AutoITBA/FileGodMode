If Not FileExists($FgmDataFolder) Then  DirCreate($FgmDataFolder);crear El folder fgm en El profile
If Not FileExists($FgmDataFolderImages) Then  DirCreate($FgmDataFolderImages);crear El folder fgm en El profile
If Not FileExists($FgmDataFolderResources) Then  DirCreate($FgmDataFolderResources);crear El folder fgm en El profile

#region load databases
;   ---------- using resources ----------------
;~ 	Local $array[5] = ["profilebase.db","FGMbase.db","FGMmme.db","FGMadfs.db","FGM.db"]
;~ 	For $i = 0 to ubound($array)-1
;~ 	   $size1 = _ResourceSaveToFile($tempDir & "\" &$array[$i] , $array[$i])
;~ 	   ConsoleWrite('!! Debug(' & @ScriptLineNumber & ') : $size1 = ' & $size1 & @crlf )
;~ 	Next
; ----------------------------------------------

	FileInstall("resources/profilebase.db", $tempDir & "\profilebase.db" , 1 )
	FileInstall("resources/FGMbase.db",     $tempDir & "\FGMbase.db"     , 1 )
	FileInstall("resources/FGM.db",         $tempDir & "\FGM.db"         , 1 )

;~ 	$packagedDBs=StringSplit("FGMmme.db|FGMadfs.db","|",2)
;~ 		FileInstall("resources/FGMadfs.db",     $FgmDataFolder & "\" & $packagedDBs[1]  , 1 )
;~ 		FileInstall("resources/FGMmme.db",      $FgmDataFolder & "\" & $packagedDBs[0]  , 1 )
#endregion
#region INI
	FileInstall("resources/FGM.ini", $INIfile , 1 )
#endregion
#region SQLITE
	FileInstall("sqlite/System.Data.SQLite.32.2012.dll", $FgmDataFolderResources &"\System.Data.SQLite.32.2012.dll" , 1 )
#endregion
#region help
	FileInstall("help/FGMhelp.CHM", $FgmDataFolderResources & "\FGMhelp.CHM" , 1 )
#endregion
#region template servers import
	FileInstall("resources/ProjectServersForImport.csv", $FgmDataFolderResources & "\ProjectServersForImport.csv" , 1 )
#endregion
#region ZIppers
	FileInstall("resources/makecab32.exe", $FgmDataFolderResources & "\makecab32.exe" , 1 )
	FileInstall("resources/makecab64.exe", $FgmDataFolderResources & "\makecab64.exe" , 1 )

	FileInstall("resources/zip.exe", $FgmDataFolderResources & "\zip.exe" , 1 )
	FileInstall("resources/zip32z64.dll", $FgmDataFolderResources & "\zip32z64.dll" , 1 )
	FileInstall("resources/bzip2.dll", $FgmDataFolderResources & "\bzip2.dll" , 1 )
#endregion
#region iconos
	FileInstall("images/Transfer.jpg", $FgmDataFolderImages & "\Transfer.jpg" , 1 )
	FileInstall("images/Transfer.bmp", $FgmDataFolderImages & "\Transfer.bmp" , 1 )

	FileInstall("images/RotatingRing01.bmp", $FgmDataFolderImages & "\RotatingRing01.bmp" , 1 )
	FileInstall("images/RotatingRing01.bmp", $FgmDataFolderImages & "\RotatingRing02.bmp" , 1 )
	FileInstall("images/RotatingRing01.bmp", $FgmDataFolderImages & "\RotatingRing03.bmp" , 1 )
	FileInstall("images/RotatingRing01.bmp", $FgmDataFolderImages & "\RotatingRing04.bmp" , 1 )

	FileInstall("images/close.ico", $FgmDataFolderImages & "\close.ico" , 1 )
	FileInstall("images/cog.ico", $FgmDataFolderImages & "\cog.ico" , 1 )
	FileInstall("images/CodelessDrill.ico", $FgmDataFolderImages & "\CodelessDrill.ico" , 1 )
	FileInstall("images/delete_16.ico", $FgmDataFolderImages & "\delete_16.ico" , 1 )
	FileInstall("images/Door2.ico", $FgmDataFolderImages & "\Door2.ico" , 1 )
	FileInstall("images/uparrow.ico", $FgmDataFolderImages & "\uparrow.ico" , 1 )
	FileInstall("images/downarrow.ico", $FgmDataFolderImages & "\downarrow.ico" , 1 )
	FileInstall("images/Crayons.ico", $FgmDataFolderImages & "\Crayons.ico" , 1 )
	FileInstall("images/Cleaner.ICO", $FgmDataFolderImages & "\Cleaner.ICO" , 1 )
	FileInstall("images/ToolBox.ico", $FgmDataFolderImages & "\ToolBox.ico" , 1 )
	FileInstall("images/copy.ico", $FgmDataFolderImages & "\copy.ico" , 1 )
	FileInstall("images/dna.ico", $FgmDataFolderImages & "\dna.ico" , 1 )
	FileInstall("images/Padlock.ico", $FgmDataFolderImages & "\Padlock.ico" , 1 )
	FileInstall("images/SNAIL.ICO", $FgmDataFolderImages & "\SNAIL.ICO" , 1 )
	FileInstall("images/wizard.ico", $FgmDataFolderImages & "\wizard.ico" , 1 )
	FileInstall("images/hammer.ico", $FgmDataFolderImages & "\hammer.ico" , 1 )
	FileInstall("images/twirl.ico", $FgmDataFolderImages & "\twirl.ico" , 1 )
	FileInstall("images/iLearning.ICO", $FgmDataFolderImages & "\iLearning.ICO" , 1 )
	FileInstall("images/eye.ICO", $FgmDataFolderImages & "\eye.ICO" , 1 )
	FileInstall("images/OpenCSV.ico", $FgmDataFolderImages & "\OpenCSV.ico" , 1 )
#endregion
#region  Helpers exes
	FileInstall("helpers\VersionChecker\versionchecker.exe", $FgmDataFolder & "\versionChecker.exe" , 1 )
	FileInstall("updater/FGMUpdater.exe", $FgmDataFolder & "\FGMUpdater.exe" , 1 )
;~ 	FileInstall("includes/FGMagent.exe", $FgmDataFolder & "\FGMagent.exe" , 1 )
	FileInstall("helpers\minion\FGMminion.exe", $MinionExecutablePath, 1 )
	FileInstall("helpers/sendtelegram/sendtelegram.exe", $FgmDataFolder & "\sendtelegram.exe" , 1 )
#endregion
#region C install
;~ 	FileInstall("resources/vcredist_x86.exe", $tempDir & "\vcredist_x86.exe" , 1 )
	Local $var1 = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\11.0\VC\Runtimes\x86", "Installed")
	Local $var2 = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\12.0\VC\Runtimes\x86", "Installed")
	If $var1<>1 And $var2<>1 Then
		MsgBox(48+4096, "Component needed.", "Microsoft Visual C++ is not installed."&@crlf & _
						" Please install " & _
						" Microsoft Visual C++ 2012 Redistributable (x86) - 11.0.61030 or later."&@crlf & _
						" https://www.microsoft.com/en-us/download/details.aspx?id=30679",0)
						$vcrerist="https://www.microsoft.com/en-us/download/details.aspx?id=30679"
						_IECreate($vcrerist, 0, 1, 0,1)
		exit
		RunWait(@ComSpec & " /c " & $tempDir & "\vcredist_x86.exe /quiet /norestart /install", $tempDir ,@SW_HIDE)
	endif
#endregion