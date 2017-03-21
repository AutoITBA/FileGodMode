
	Func _CopyTableFromDB($hdb1,$tbl1,$hdb2,$tbl2,$sqlqTail='',$quiet=true)
		if $sqlqTail then  ConsoleWrite('!!!!!!!!!!!!!!!!!!!!! $sqlqTail = ' & $sqlqTail & @crlf )
		ConsoleWrite('++_CopyTableFromDB() = $quiet = '&$quiet& @crlf)
		Local $arrsql,$irows,$icolumns
		;load from $hdb1
		Local $hDskDb = _SQLite_Open($hdb1)
		If @error Then
			MsgBox(48, "SQLite Error", "Can't open or create a permanent Database! " &$hdb1 & " Err.1031")
			Return false
		EndIf
		_SQLite_Close($hDskDb)

		$sqlq="SELECT * FROM "&$tbl1
		If _SQLITEqry($SQLq,$hdb1,$quiet,0) Then
			If  IsArray($qryResult) then
				$arrsql=$qryResult
			endif
		Else
			MsgBox(48+4096,"Error Loading Data","Error Merging data. ErrNo 1030  -> "& $sqlq,0)
			Return false
		endif

		; insert into $hdb2
		$sqlq='DELETE FROM '&$tbl2
		if _SQLITErun($sqlq,$hdb2,$quiet,0) Then
		Else
			MsgBox(48+4096,"Error Loading Data","Error Merging data. ErrNo 1032  -> "& $sqlq,0)
			Return false
		EndIf

		$sqlq="BEGIN;"
		For $iRows = 1 To UBound($arrsql,1)-1
			$sqlq&="INSERT INTO "&$tbl2&' VALUES ("'
			For $iColumns = 0 To UBound($arrsql,2)-2
				$sqlq&= $arrsql[$iRows][$iColumns] & '","'
			next
			$sqlq&= $arrsql[$iRows][$iColumns] & '"'
			$sqlq&= $sqlqTail&');'
			if stringlen($sqlq)>900000 then
	;~ 			ConsoleWrite("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"&  stringlen($sqlq) & " line  "  & @ScriptLineNumber &@crlf)
				$sqlq&="END;"
				if _SQLITErun($sqlq,$hdb2,$quiet,0) Then
				Else
					MsgBox(48+4096,"Error Loading Data","Error Merging data. ErrNo 1033  -> "& $sqlq,0)
					Return false
				EndIf
				$sqlq="BEGIN;"
			endif
		next
		if $sqlq<>"BEGIN;" then
	;~ 		ConsoleWrite("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"&  stringlen($sqlq) & " line  "  & @ScriptLineNumber &@crlf)
			$sqlq&="END;"
			if _SQLITErun($sqlq,$hdb2,$quiet,0) Then
			Else
				MsgBox(48+4096,"Error Loading Data","Error Merging data. ErrNo 1033  -> "& $sqlq,0)
				Return false
			EndIf
		EndIf
	EndFunc

	Func _UpdateFromServersFGM($quiet=false)
		ConsoleWrite('++_UpdateFromServersFGM() = $quiet = '& $quiet & @crlf)
	;-Servers
	;  leer la lista de servers de fgm
	;  poner como trash los servers que no existen en fgm pero existen en servers
	;  		anular la relacion de los servers que no estan en FGM y el grupo a que pertenecen
	;  detectar nuevos servers y agregar la relacion Rservergroup a "-"    PART 1
	;  upsertear los servers de FGM a servers table y poner trash en "0".
	;  detectar nuevos servers y agregar la relacion Rservergroup a "-"    PART 2
	;-servergroups
	;  deletear los grupos de servergroups que no sean custom y no estan en FGM. y sacar la relacion en rservergropu
	;  upsertear los grupos de fgm a serversgroup
	;-relations
	;  desasociar los la relacion de los server Rservergroup que y no estan relacionados con custom groupservers table
	;  crear las relaciones entre los servers y los groupos no custom basado en los datos de FGM
	#region  servers
		#region        leer la lista de servers de fgm
			$sqlq="SELECT serverid,servername,description,ip FROM FGMServers"
			_SQLITEqry($sqlq,$profiledbfile,$quiet,0)
			If  IsArray($qryResult) then
				$Dservers=$qryResult
			Else
				MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1034  -> "& $sqlq,0)
				Return false
			EndIf
		#endregion
		_LoadTimerPrint("after " & @ScriptLineNumber )
		#region        poner como trash los servers que no existen en fgm pero existen en servers table.
			$set_trash=1
			if $set_trash=1 then
				ConsoleWrite('>>_UpdateFromServersFGM() = poner como trash los servers que no existen en fgm pero existen en servers '& @crlf)
				$sqlq="SELECT Servers.servername FROM Servers " & _
						"left OUTER JOIN FGMServers ON lower(fgmServers.servername) = lower(Servers.servername) " & _
						"WHERE FGMServers.servername is NULL AND  Servers.custom=0 "
				_SQLITEqry($sqlq,$profiledbfile,$quiet,0)
				If  IsArray($qryResult) then
					If UBound($qryResult) >1 Then
						$DserversTrash=$qryResult
						$sqlq="BEGIN;"
						For $iRows = 1 To UBound($DserversTrash)-1
							Local $srvid='Select serverID FROM servers WHERE servername="' & StringLower($DserversTrash[$iRows][0]) & '" '
							$sqlq&='UPDATE servers SET trash=1 WHERE servername="'& StringLower($DserversTrash[$iRows][0]) & '";'
							$sqlq&='UPDATE RserverGroup SET groupID=1 WHERE ServerID=(' & $srvid & ') ;'
							if stringlen($sqlq)>900000 then
								ConsoleWrite("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"&  stringlen($sqlq) & " line  "  & @ScriptLineNumber &@crlf)
								$sqlq&="END;"
								if _SQLITErun($sqlq,$profiledbfile,$quiet,1) Then
								Else
									MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1035  -> "& $sqlq,0)
									Return false
								EndIf
								$sqlq="BEGIN;"
							endif
						next
						if _AUXcommit($sqlq,$profiledbfile,"Error Merging Data","Error Merging data. ErrNo 1035  -> ",$quiet)=false then return false
					endif
				Else
					MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1036  -> "& $sqlq,0)
					Return false
				EndIf
			Else
				ConsoleWrite('!!!!!!!!!!!!!!!!!!!!!!    $set_trash=1  mergedb.au3 !!!!!!!!!!!!!!!>>_UpdateFromServersFGM() = poner como trash los servers que no existen en fgm pero existen en servers  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'& @crlf)
			endif
		#endregion
		_LoadTimerPrint("after " & @ScriptLineNumber )
		#region        detectar nuevos servers y agregar la relacion Rservergroup a "1"    PART 1
			ConsoleWrite('>>_UpdateFromServersFGM() = detectar nuevos servers y agregar la relacion Rservergroup a "-" '& @crlf)
			$DserversNew=""
			$sqlq='SELECT FGMServers.servername FROM FGMServers left OUTER JOIN Servers ON lower(fgmServers.servername) = lower(Servers.servername) ' & _
							'WHERE Servers.servername is NULL '
			_SQLITEqry($sqlq,$profiledbfile,$quiet,0)
			If  IsArray($qryResult) then
				If UBound($qryResult) >1 Then
					$DserversNew=$qryResult
				endif
			Else
				MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1037  -> "& $sqlq,0)
				Return false
			EndIf
		#endregion
		_LoadTimerPrint("after " & @ScriptLineNumber )
		#region        upsertear los servers de FGM a servers table y poner trash en "0".
			ConsoleWrite('>>_UpdateFromServersFGM() = upsertear los servers de FGM a servers table y poner trash en "0".  '& @crlf)
			$sqlq="BEGIN;"
			For $iRows = 1 To UBound($Dservers,1)-1    ; for each server row
				Local $srvid='Select serverID FROM servers WHERE servername="' & StringLower($Dservers[$iRows][1]) & '" '
				$sqlq&='REPLACE INTO servers VALUES ((' & $srvid & '),"' & StringLower($Dservers[$iRows][1]) & _
								'","'&$Dservers[$iRows][2]&'","'&$Dservers[$iRows][3]&'",0,0);'
				if stringlen($sqlq)>900000 then
					ConsoleWrite("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"&  stringlen($sqlq) & " line  "  & @ScriptLineNumber &@crlf)
					$sqlq&="END;"
					if _SQLITErun($sqlq,$profiledbfile,$quiet,1) Then
					Else
						MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1038  -> "& $sqlq,0)
						Return false
					EndIf
					$sqlq="BEGIN;"
				endif
			next
			if _AUXcommit($sqlq,$profiledbfile,"Error Merging Data","Error Merging data. ErrNo 1038  -> ",$quiet)=false then return false
		#endregion
		_LoadTimerPrint("after " & @ScriptLineNumber )
		#region        detectar nuevos servers y agregar la relacion Rservergroup a "1"    PART 2
			If  IsArray($DserversNew) then
				$sqlq="BEGIN;"
				For $iRows = 1 To UBound($DserversNew)-1
					Local $srvid='Select serverID FROM servers WHERE servername="' & StringLower($DserversNew[$iRows][0]) & '" '
					$sqlq&='INSERT into RServerGroup VALUES ((' & $srvid & '),1);'
					if stringlen($sqlq)>900000 then
						ConsoleWrite("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"&  stringlen($sqlq) & " line  "  & @ScriptLineNumber &@crlf)
						$sqlq&="END;"
						if _SQLITErun($sqlq,$profiledbfile,$quiet,1) Then
						Else
							MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1039  -> "& $sqlq,0)
							Return false
						EndIf
						$sqlq="BEGIN;"
					endif
				next
				if _AUXcommit($sqlq,$profiledbfile,"Error Merging Data","Error Merging data. ErrNo 1039  -> ",$quiet)=false then return false
			endif
		#endregion
		_LoadTimerPrint("after " & @ScriptLineNumber )
	#endregion
	#region serversgroups
	;deletear lo que no esta en fgm
	;agregar lo que esta en fgm
		#region        deletear los grupos de servergroups que no sean custom y no estan en FGM. y sacar la relacion en rservergropu y reeplazarla con "1"
			ConsoleWrite('>>_UpdateFromServersFGM() = deletear los grupos de servergroups que no sen custom  '& @crlf)
			$sqlq='SELECT servergroups.servergroupname FROM servergroups ' & _
			  'left OUTER JOIN FGMservergroups ON lower(FGMservergroups.servergroupname) = lower(servergroups.servergroupname) ' & _
			  'WHERE FGMservergroups.servergroupname is NULL AND  servergroups.custom=0 '
			_SQLITEqry($sqlq,$profiledbfile,$quiet,0)
			If  IsArray($qryResult) then
				If UBound($qryResult) >1 Then
					$DServersGroupOld=$qryResult
					For $iRows = 1 To UBound($DServersGroupOld)-1
						If $DServersGroupOld[$iRows][0]<>"-" Then
							local $grpid='SELECT groupid FROM servergroups WHERE servergroupname="' & $DServersGroupOld[$iRows][0] & '" '
							$sqlq='UPDATE RserverGroup SET groupID=1 WHERE groupID=(' & $grpid & ') ;'
							$sqlq&='DELETE FROM servergroups WHERE servergroupname="'& $DServersGroupOld[$iRows][0] & '";'
							if _SQLITErun($sqlq,$profiledbfile,$quiet,0) Then
							Else
								MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1040  -> "& $sqlq,0)
								Return false
							EndIf
						endif
					next
				endif
			Else
				MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1041  -> "& $sqlq,0)
				Return false
			EndIf
		#endregion
		_LoadTimerPrint("after " & @ScriptLineNumber )
		#region        upsertear los grupos de fgm a serversgroup
			; upsert groups  ----------------------------------------------
			ConsoleWrite('>>_UpdateFromServersFGM() = upsert groups '& @crlf)
			$sqlq="SELECT servergroupname FROM FGMservergroups"
			_SQLITEqry($sqlq,$profiledbfile,$quiet,0)
			If  IsArray($qryResult) then
				$DGroups=$qryResult
			Else
				MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1041  -> "& $sqlq,0)
				Return false
			EndIf
			For $iRows = 1 To UBound($DGroups,1)-1    ; for each group row
				local $grpid='SELECT groupid FROM servergroups WHERE servergroupname="'& StringLower($DGroups[$iRows][0]) & '" '
				$sqlq='REPLACE INTO servergroups VALUES ((' & $grpid & '),"' & StringLower($DGroups[$iRows][0]) & '",0); '
				if _SQLITErun($sqlq,$profiledbfile,$quiet,0) Then
				Else
					MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1042  -> "& $sqlq,0)
					Return false
				EndIf
			next
		#endregion
	#endregion
	#region RserverGrop
		#region        desasociar los la relacion de los server Rservergroup que y no estan relacionados con custom groupservers table
			ConsoleWrite('>>_UpdateFromServersFGM() = desasociar los la relacion de los server Rservergroup que y no estan relacionados con custom groupservers table '& @crlf)
			$sqlq="SELECT Servers.serverid,Servers.servername,servergroups.groupid,servergroups.servergroupname FROM servergroups " & _
					"INNER JOIN RServerGroup ON servergroups.groupid=RServerGroup.groupID  " & _
					"INNER JOIN Servers ON RServerGroup.ServerID = Servers.serverid  " & _
					"WHERE servergroups.custom=0 AND servergroups.servergroupname<>'-' ;"
			_SQLITEqry($sqlq,$profiledbfile,$quiet,0)
			If  IsArray($qryResult) then
				$DserversGroups=$qryResult
			Else
				MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1043  -> "& $sqlq,0)
				Return false
			EndIf
			$sqlq="BEGIN;"
			For $iRows = 1 To UBound($DserversGroups)-1
				$grpid=StringLower($DserversGroups[$iRows][2])
				$srvid=StringLower($DserversGroups[$iRows][0])
				$sqlq&='UPDATE RserverGroup SET groupID=1 WHERE groupid=(' & $grpid& ') AND serverid=(' & $srvid & ');'
				if stringlen($sqlq)>900000 then
					ConsoleWrite("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"&  stringlen($sqlq) & " line  "  & @ScriptLineNumber &@crlf)
					$sqlq&="END;"
					if _SQLITErun($sqlq,$profiledbfile,false,0) Then
					Else
						MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1044  -> "& $sqlq,0)
						Return false
					EndIf
					$sqlq="BEGIN;"
				endif
			next
			if _AUXcommit($sqlq,$profiledbfile,"Error Merging Data","Error Merging data. ErrNo 1044  -> ",$quiet)=false then return false
		#endregion
		_LoadTimerPrint("after " & @ScriptLineNumber )
		#region  crear las relaciones entre los servers y los groupos no custom basado en los datos de FGM
			ConsoleWrite('crear las relaciones entre los servers y los groupos no custom basado en los datos de FGM' & @crlf)
			$sqlq='SELECT Servers.serverid,servergroups.groupid FROM servergroups ' & _
					  'INNER JOIN FGMservergroups ON FGMservergroups.servergroupname = servergroups.servergroupname ' & _
					  'INNER JOIN FGMRServerGroup ON FGMservergroups.groupid = FGMRServerGroup.groupID ' & _
					  'INNER JOIN FGMServers ON FGMRServerGroup.ServerID = FGMServers.serverid ' & _
					  'INNER JOIN Servers ON FGMServers.servername = Servers.servername	;'
			_SQLITEqry($sqlq,$profiledbfile,$quiet,0)
			If  IsArray($qryResult) then
				$DserversGroups=$qryResult
			Else
				MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1045  -> "& $sqlq,0)
				Return false
			EndIf
			$sqlq="BEGIN;"
			For $iRows = 1 To UBound($DserversGroups)-1
				$grpid=StringLower($DserversGroups[$iRows][1])
				$srvid=StringLower($DserversGroups[$iRows][0])
				$sqlq&='UPDATE RserverGroup SET groupid=' & $grpid& ' WHERE serverid=' & $srvid & ';'
				if stringlen($sqlq)>900000 then
					ConsoleWrite("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"&  stringlen($sqlq) & " line  "  & @ScriptLineNumber &@crlf)
					$sqlq&="END;"
					if _SQLITErun($sqlq,$profiledbfile,$quiet,0) Then
					Else
						MsgBox(48+4096,"Error Merging Data","Error Merging data. ErrNo 1046  -> "& $sqlq,0)
						Return false
					EndIf
				endif
			next
			if _AUXcommit($sqlq,$profiledbfile,"Error Merging Data","Error Merging data. ErrNo 1046  -> ",$quiet)=false then return false
		#endregion
		_LoadTimerPrint("after " & @ScriptLineNumber )
	#endregion
		Return true
	EndFunc

	Func _AUXcommit($sqlq,$profiledbfile,$title,$msg,$quiet=false)
	;~ 	ConsoleWrite('++_AUXcommit() = '&stringlen($sqlq) & @crlf)
		if $sqlq<>"BEGIN;" then
			$sqlq&="END;"
			if _SQLITErun($sqlq,$profiledbfile,$quiet,0) Then
				Return true
			Else
				MsgBox(48+4096,$title,$msg& $sqlq,0)
				Return false
			EndIf
		endif
		Return true
	EndFunc




