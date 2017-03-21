#Region ### START Koda GUI section ### Form=\Main.kxf
	$MainfORM = GUICreate($mainformname & $version & "            " & @ComputerName & _CheckcomputerMembership(), 630, 480, -1, -1)
	$Pic1 = GUICtrlCreatePic( $FgmDataFolderImages & "\Transfer.jpg", 8, 8, 289, 385)

	#region Menu
		; Create File menu
		$hFile = _GUICtrlMenu_CreateMenu()
	;~ 	_GUICtrlMenu_InsertMenuItem($hFile, 0, "&New", $idNew)
	;~ 	_GUICtrlMenu_InsertMenuItem($hFile, 1, "&Open", $idOpen)
	;~ 	_GUICtrlMenu_InsertMenuItem($hFile, 2, "&Save", $idSave)
	;~ 	_GUICtrlMenu_InsertMenuItem($hFile, 3, "", 0)
		_GUICtrlMenu_InsertMenuItem($hFile, 0, "E&xit", $idExit)

		; Create Edit menu
	;~ 	$hEdit = _GUICtrlMenu_CreateMenu()
	;~ 	_GUICtrlMenu_InsertMenuItem($hEdit, 0, "&Cut", $idCut)
	;~ 	_GUICtrlMenu_InsertMenuItem($hEdit, 1, "C&opy", $idCopy)
	;~ 	_GUICtrlMenu_InsertMenuItem($hEdit, 2, "&Paste", $idPaste)

		; Create option menu
		$hOption = _GUICtrlMenu_CreateMenu()
		_GUICtrlMenu_InsertMenuItem($hOption, 0, "Settings", $idSettings)
		_GUICtrlMenu_InsertMenuItem($hOption, 1, "Credentials", $idSettingsCredentials)
		_GUICtrlMenu_InsertMenuItem($hOption, 2, "Server CRUD", $idSettingsServers)
		_GUICtrlMenu_InsertMenuItem($hOption, 3, "Groups && Shares", $idSettingsCustom)
		_GUICtrlMenu_InsertMenuItem($hOption, 4, "Application preferences", $idSettingApplications)
		_GUICtrlMenu_InsertMenuItem($hOption, 5, "Database maintenance", $idSettingsDB)

		; Create update menu
		$hUpdt = _GUICtrlMenu_CreateMenu()
		_GUICtrlMenu_InsertMenuItem($hUpdt, 0, "Update &Project's DB repository", $idprj)
		_GUICtrlMenu_InsertMenuItem($hUpdt, 1, "&Update version", $idUpdate)
		_GUICtrlMenu_InsertMenuItem($hUpdt, 2, "&Check version", $idCheckVersion)


		; Create Help menu
		$hHelp = _GUICtrlMenu_CreateMenu()
		_GUICtrlMenu_InsertMenuItem($hHelp, 0, "&Help", $idHelp)
		_GUICtrlMenu_InsertMenuItem($hHelp, 1, "&About", $idAbout)

		; ----Create Main menu
		$hMain = _GUICtrlMenu_CreateMenu()
		_GUICtrlMenu_InsertMenuItem($hMain, 0, "&File", 0, $hFile)
	;~ 	_GUICtrlMenu_InsertMenuItem($hMain, 1, "&Edit", 0, $hEdit)
		_GUICtrlMenu_InsertMenuItem($hMain, 1, "&Options", 0, $hOption)
		_GUICtrlMenu_InsertMenuItem($hMain, 2, "&Updates", 0, $hUpdt)
		_GUICtrlMenu_InsertMenuItem($hMain, 3, "&Help", 0, $hHelp)

		; -------Set window menu
		_GUICtrlMenu_SetMenu($MainfORM, $hMain)
	#endregion

		If $dev=1 Then
			GUICtrlCreateLabel(" DEV VERSION", 330, 12, 130, 22)
			GUICtrlSetBkColor(-1,_color("RED"))
			$font = "Comic Sans MS"
			GUICtrlSetFont(-1, 12, 700, 0, $font)
		endif
		GUICtrlCreateLabel("Select project DataBase", 330, 32, 130, 17)
		$CMB_DatabaseSelect = GUICtrlCreateCombo("", 330, 48, 130, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))

		$B_setDB = IconButton("Set", 480, 48, 89, 25, 16, $FgmDataFolderImages & "\wizard.ico")
			GUICtrlSetOnEvent(-1, "SetDatabase")
			GUICtrlSetstate($B_setDB,$GUI_disable)
			GUICtrlSetColor(-1, _color("black"))

		$LBL_setdb=GUICtrlCreateLabel("No Project selected "&@crlf&"Select a Database from list", 330, 80, 260, 50)
			GUICtrlSetColor($LBL_setdb,_color("RED"))
			$font = "Comic Sans MS"
;~ 			GUICtrlSetBkColor($LBL_setdb,_color("rose"))
			GUICtrlSetFont(-1, 12, 700, 0, $font)
			GUICtrlSetstate($LBL_setdb,$GUI_hide)

		$msg_LBL_noRepo="Project repository cannot be reached."&@crlf& _
					"Configure the repository "&@crlf& '"Settings -> Application preferences"'
		$LBL_noRepo=GUICtrlCreateLabel($msg_LBL_noRepo, 330, 130, 260, 60)
			GUICtrlSetColor($LBL_noRepo,_color("RED"))
;~ 			GUICtrlSetBkColor($LBL_noRepo,_color("green"))
			$font = "Comic Sans MS"
			GUICtrlSetFont(-1, 8, 700, 0, $font)
			GUICtrlSetstate($LBL_noRepo,$GUI_hide)

		$LBL_noInet=GUICtrlCreateLabel("  No Internet access.", 330, 190, 150, 20)
			GUICtrlSetColor($LBL_noInet,_color("RED"))
			GUICtrlSetBkColor($LBL_noInet,_color("rose"))
			$font = "Comic Sans MS"
			GUICtrlSetFont(-1, 10, 700, 0, $font)
			GUICtrlSetstate($LBL_noInet,$GUI_hide)

;~ 	$btn_manageJobs = GUICtrlCreateButton("Manage Jobs", 480, 8, 137, 41)

	$btn_CreateJob = IconButton("Jobs", 480, 270, 137, 41,32, $FgmDataFolderImages & "\CodelessDrill.ico")
		GUICtrlSetOnEvent(-1, "ShowJobCreationForm")
		GUICtrlSetstate($btn_CreateJob,$GUI_disable)
		GUICtrlSetColor(-1, _color("black"))

	$btn_config = IconButton("Settings", 480, 320, 137, 41,32, $FgmDataFolderImages & "\cog.ico")
		SetOnEventA($btn_config, "ShowSettingsForm",$paramByVal,0)
		GUICtrlSetstate($btn_config,$GUI_disable)
		GUICtrlSetColor(-1, _color("black"))

	$B_Close = IconButton("close", 528, 416, 89, 25, 16, $FgmDataFolderImages & "\close.ico")
		GUICtrlSetOnEvent(-1, "MainClose")
		GUICtrlSetColor(-1, _color("black"))

$lblLeft=200
$lblwide=320
$lblancho=80
;~ 	$LBL_CheckUpdate=GUICtrlCreateLabel("   Ckecking Project DB repository", $lblLeft, 400, $lblwide, 25)
	$LBL_CheckRepo=GUICtrlCreateLabel("", $lblLeft-$lblancho, 400, $lblwide+$lblancho, 25)
		GUICtrlSetBkColor(-1,_color("RED"))
		$font = "Comic Sans MS"
		GUICtrlSetFont(-1, 12, 700, 0, $font)
		GUICtrlSetstate($LBL_CheckRepo,$GUI_hide)

;~ 	$LBL_CheckUpdate=GUICtrlCreateLabel("   Ckecking for updates", $lblLeft, 430, $lblwide, 25)
	$LBL_CheckUpdate=GUICtrlCreateLabel("", $lblLeft, 430, $lblwide, 25)
		GUICtrlSetBkColor(-1,_color("RED"))
		$font = "Comic Sans MS"
		GUICtrlSetFont(-1, 12, 700, 0, $font)
		GUICtrlSetstate($LBL_CheckUpdate,$GUI_hide)

	GUICtrlCreateLabel("By Marcelo N. Saied && Roberto P. Iralour ", 10, 435, 190, 17)
	GUICtrlSetFont(-1, 8.5, 400)


; --------------   functions for the forl
		_MainFormBTNdisable(0)
	 ; if not seteed . the set the project database to the default harcoded
		_UpdateAppSettings_PrjDBRepo()
	; check the ini file and set the repository for the project database
		;_checkRepo()  ; check the ini file and set the repository for the project database
		_CheckSetProxy_InetRead()    ; set proxy server
		_CkeckPrjDBRepoFiles(0)    ; 0= update only if newer in repo  1= force update
		_FillDatabaseListbox()
		$LBLTimerBegin = TimerInit()
		$FlagLBLhide=1

		GUISetState(@SW_SHOW)
		_LoadTimerPrint("after Main Form Load()")

#EndRegion ### END Koda GUI section ###


