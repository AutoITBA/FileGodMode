#region General
	$version=FileGetVersion(@ScriptName)
	$LogFile="FGMminion.log"
	$hLogFile=0
#endregion
#region Hashing
	$HashingPassword = ""
	#include <..\..\secrets/HashingPassword.secret>
#endregion
