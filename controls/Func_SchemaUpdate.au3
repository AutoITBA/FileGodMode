	#region ====================================  Database Schema =======================================================
	Func _CheckProfileDbSchema()
		ConsoleWrite('++_CheckProfileDbSchema() = '& @crlf)
		;----------  check schema nad update profile db
		$DataBaseSchemaProfile=_GetDBSchemaVersion()
		ConsoleWrite('$DataBaseSchemaProfile = ' & $DataBaseSchemaProfile &' == $DataBaseSchemaAplication = ' & $DataBaseSchemaAplication & @crlf )
		If $DataBaseSchemaAplication>$DataBaseSchemaProfile Then  ; the apllication usses a higer shema version
			ConsoleWrite('++ConfigDBInitial() = Schema version = '&$DataBaseSchemaProfile & @crlf )
			_UpdateProfileDbSchema()
		endif
	EndFunc
	Func _GetDBSchemaVersion()
		ConsoleWrite('++_GetDBSchemaVersion() = '& @crlf)
		$query='SELECT value FROM configuration WHERE config="DataBaseSchema" ;'
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) then
			If UBound($qryResult)>1 then
				return $qryResult[1][0]
			endif
		endif
		Return 0
	EndFunc
	; -------------------------------------------------------------------
	Func _CheckProyectDBupdate()
		ConsoleWrite('++_CheckProyectDBupdate() = '& @crlf)
		;----------  check if profile db was already updated-  the update should be onlo done at version change -  update profile db
		$ProyectDBupdateVersion=_GetProyectDBupdate()
		ConsoleWrite('$ProyectDBupdateVersion = ' & $ProyectDBupdateVersion &'== $version = ' & $version & @crlf )
		If $version<>$ProyectDBupdateVersion Then  ; the apllication usses a higer shema version
			return 1
		Else
			return 0
		endif
		return 0
	EndFunc
	Func _GetProyectDBupdate()
		ConsoleWrite('++_GetProyectDBupdate() = '& @crlf)
		$query='SELECT key FROM configuration WHERE config="ProyectDBupdate" ;'
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) Then
			if UBound($qryResult)>1 then
				return $qryResult[1][0]
			EndIf
			return 0
		endif
		Return 0
	EndFunc
	Func _updateProyectDBupdateValue($version)
		ConsoleWrite('++_updateProyectDBupdateValue() = '&$version& @crlf)
		$query='UPDATE configuration SET key="'& $version & '" WHERE config="ProyectDBupdate";'
		if _SQLITErun($query,$profiledbfile,$quietSQLQuery) Then
		Else
			MsgBox(48,"Error Updating DataBase","Critical Error ErrNo 98a"&@crlf&"Error updating Database for  ProyectDBupdate version "&@crlf& _
						"Contact system administrator for mor assistance." ,0)
			exit
		endif
	EndFunc
	; -------------------------------------------------------------------
	Func _UpdateProfileDbSchema()   ;  updatear $DataBaseSchemaAplication=6 en variables.au3
		ConsoleWrite('XXXXXXXXXXXXXXXXXXXXXXxxx++_UpdateProfileDbSchema()XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX = '&$DataBaseSchemaProfile & _
		"=="& $DataBaseSchemaAplication&@crlf)
		For $i=$DataBaseSchemaProfile To $DataBaseSchemaAplication-1
			Switch $i
				Case 1
					; crear columna in configuration table ; add row with fGMactive
					$query="ALTER TABLE Configuration ADD key VARCHAR(30);"
					$query=$query&"INSERT INTO Configuration  (Config) VALUES ('FGMactive');"
					_ExecuteUpdateSchemaDb($query,$profiledbfile)
					_updateSchemaVersionDbValue(2)
				Case 2
					;crear un index a configuration en profile.db (config,value)
					$query="CREATE UNIQUE INDEX IF NOT EXISTS Confvalue ON Configuration (Config,value);"
					_ExecuteUpdateSchemaDb($query,$profiledbfile)
					_updateSchemaVersionDbValue(3)
				Case 3
					$query="INSERT INTO Configuration  (Config,value,key) VALUES ('ProyectDBupdate','updatedVersion','1');"
					_ExecuteUpdateSchemaDb($query,$profiledbfile)
					_updateSchemaVersionDbValue(4)
				Case 4
					$query="CREATE UNIQUE INDEX IF NOT EXISTS Confvalue ON Configuration (Config,value);"
					_ExecuteUpdateSchemaDb($query,$profiledbfile)
					$exist=0
					$query="PRAGMA table_info(tasks);"
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						If UBound($qryResult)>1 then
							_printfromarray($qryResult)
							for $r=0 to UBound($qryResult)-1
								if $qryResult[$r][1] = "commands" then $exist=1
							next
						Else
							MsgBox(48,"Error Upgrading DataBase","Critical Error ErrNo 99"&@crlf&"Error Upgrading Database from Schema version "&$DataBaseSchemaProfile& " to "&$DataBaseSchemaAplication&@crlf&"The application cannot use and incompatible Schema version"&@crlf& "Contact system administrator for mor assistance." ,0)
							exit
						endif
					endif
					if $exist=0 then
						$query="ALTER TABLE Tasks ADD commands TEXT;"
						_ExecuteUpdateSchemaDb($query,$profiledbfile)
						_updateSchemaVersionDbValue(5)
					endif
				Case 5
					$exist=0
					$query="PRAGMA table_info(tasks);"
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						If UBound($qryResult)>1 then
							_printfromarray($qryResult)
							for $r=0 to UBound($qryResult)-1
								if $qryResult[$r][1] = "Group" then $exist=1
							next
						Else
							MsgBox(48,"Error Upgrading DataBase","Critical Error ErrNo 991"&@crlf&"Error Upgrading Database from Schema version "&$DataBaseSchemaProfile& " to "&$DataBaseSchemaAplication&@crlf&"The application cannot use and incompatible Schema version"&@crlf& "Contact system administrator for mor assistance." ,0)
							exit
						endif
					endif
					if $exist=0 then
						$query="ALTER TABLE Tasks ADD Grupo VARCHAR(150);"
						_ExecuteUpdateSchemaDb($query,$profiledbfile)
						_updateSchemaVersionDbValue(6)
					endif
				Case 6
					$exist=0
					$query="PRAGMA table_info(tasks);"
					_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
					If  IsArray($qryResult) then
						If UBound($qryResult)>1 then
							_printfromarray($qryResult)
							for $r=0 to UBound($qryResult)-1
								if $qryResult[$r][1] = "TypeUpdate" then $exist=1
							next
						Else
							MsgBox(48,"Error Upgrading DataBase","Critical Error ErrNo 992"&@crlf&"Error Upgrading Database from Schema version "&$DataBaseSchemaProfile& " to "&$DataBaseSchemaAplication&@crlf&"The application cannot use and incompatible Schema version"&@crlf& "Contact system administrator for mor assistance." ,0)
							exit
						endif
					endif
					if $exist=0 then
						$query="ALTER TABLE Tasks ADD TypeUpdate BOOLEAN DEFAULT 0;"
						_ExecuteUpdateSchemaDb($query,$profiledbfile)
						_updateSchemaVersionDbValue(7)
					endif
				Case 7
					_ExecuteUpdateSchemaDb($query,$profiledbfile)
					_updateSchemaVersionDbValue(8)
				Case 8
					_ExecuteUpdateSchemaDb($query,$profiledbfile)
					_updateSchemaVersionDbValue(9)
				Case 9
					_ExecuteUpdateSchemaDb($query,$profiledbfile)
					_updateSchemaVersionDbValue(10)
				Case 10
					_ExecuteUpdateSchemaDb($query,$profiledbfile)
					_updateSchemaVersionDbValue(11)
				Case Else
					MsgBox(48,"Error Upgrading DataBase","Critical Error ErrNo 99"&@crlf&"Error Upgrading Database from Schema version "&$DataBaseSchemaProfile& _
								" to "&$DataBaseSchemaAplication&@crlf&"The application cannot use and incompatible Schema version"&@crlf& _
								"Contact system administrator for mor assistance." ,0)
					exit
			EndSwitch
		next
	EndFunc
	Func _ExecuteUpdateSchemaDb($query,$profiledbfile)
		ConsoleWrite('++_ExecuteUpdateSchemaDb() = '& @crlf)
		if _SQLITErun($query,$profiledbfile) Then
		Else
			MsgBox(48,"Error Upgrading DataBase","Critical Error ErrNo 98"&@crlf&"Error Upgrading Database from Schema version "&$DataBaseSchemaProfile& _
						" to "&$DataBaseSchemaAplication&@crlf&"The application cannot use and incompatible Schema version"&@crlf& _
						"Contact system administrator for mor assistance." ,0)
			exit
		endif
	EndFunc
	Func _updateSchemaVersionDbValue($Schemaver)
		ConsoleWrite('++_updateSchemaVersionDbValue() = '&$Schemaver& @crlf)
		$query='UPDATE configuration SET value="'&$Schemaver& '" WHERE config="DataBaseSchema";'
		if _SQLITErun($query,$profiledbfile) Then
		Else
			MsgBox(48,"Error Upgrading DataBase","Critical Error ErrNo 98"&@crlf&"Error Upgrading Database from Schema version "&$DataBaseSchemaProfile& _
						" to "&$DataBaseSchemaAplication&@crlf&"The application cannot use and incompatible Schema version"&@crlf& _
						"Contact system administrator for mor assistance." ,0)
			exit
		endif
	EndFunc
	Func _ActiveDatabaseValue()
		ConsoleWrite('++_ActiveDatabase() = '& @crlf)
		$res=""
		$query="SELECT value FROM Configuration WHERE Config='FGMactive' ;"
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) then
			If UBound($qryResult)>1 then
				$res=$qryResult[1][0]
			endif
		endif
		Return $res
	EndFunc
	Func _GetDatabaseFile($sdb)
		ConsoleWrite('++_GetDatabaseFile() = '& @crlf)
		$res=""
		$query="SELECT key FROM Configuration WHERE Config='FGMdatabase' AND value='" & $sdb  & "' ;"
		_SQLITEqry($query,$Basedbfile)
		If  IsArray($qryResult) then
			If UBound($qryResult)>1 then
				$res=$qryResult[1][0]
			endif
		endif
		Return $res
	EndFunc
	Func _ActiveDatabaseFile()
		ConsoleWrite('++_ActiveDatabaseFile() = '& @crlf)
		$res=""
		$query="SELECT key FROM Configuration WHERE Config='FGMactive' ;"
		_SQLITEqry($query,$profiledbfile,$quietSQLQuery)
		If  IsArray($qryResult) then
			If UBound($qryResult)>1 then
				$res=$qryResult[1][0]
			endif
		endif
		Return $res
	EndFunc
	Func _Update_DummyServer()
		ConsoleWrite('++_Update_DummyServer() = '& @crlf )
		$query='select count(*) from servers where servername="_dummyserver";'
		if _SQLITEqry($query,$profiledbfile,$quietSQLQuery) Then
			If  IsArray($qryResult) then
				$res=$qryResult[1][0]
				if $res=0 then
					$query='INSERT INTO servers VALUES (null,"_dummyserver","Placeholder","0.0.0.0",0,0);'
					if _SQLITErun($query,$profiledbfile) Then
						return true
					Else
						MsgBox(48+4096,"Updatting server data","An error opdating Dummyserver into server data. ErrNo 2014",0)
						return false
					endif
				endif
			Else
				MsgBox(48+4096,"Updatting server data","An error opdating Dummyserver into server data. ErrNo 2013",0)
				return false
			endif
		Else
			MsgBox(48+4096,"Updatting server data","An error opdating Dummyserver into server data. ErrNo 2012",0)
			return false
		EndIf
	EndFunc
	#endregion