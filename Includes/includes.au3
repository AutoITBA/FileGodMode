#region system
	#include <ButtonConstants.au3>
	#include <ComboConstants.au3>
	#include <DateTimeConstants.au3>
	#include <EditConstants.au3>
	#include <GUIConstantsEx.au3>
;~ 	#include <..\udf\APIConstants.au3>
;~ 	#include <WinAPIEx.au3>
	#include <StaticConstants.au3>
	#include <WindowsConstants.au3>
	#include <ScrollBarConstants.au3>
	#include <TabConstants.au3>
	#include <GUIConstants.au3>
	#include <Constants.au3>
	#Include <ProgressConstants.au3>
	#include <WinAPI.au3>
	#include <IE.au3>
	#include <Array.au3>
	#include <Date.au3>
	#include <GuiComboBox.au3>
	#include <GuiTreeView.au3>
;~ 	Global Const $SC_CLOSE = 0xF060;
	#include <GUIListBox.au3>
	#include <GuiStatusBar.au3>
	#include <GuiListView.au3>
	#include <GuiReBar.au3>
	#include <GuiToolbar.au3>
	#include <GuiEdit.au3>
	#include <Crypt.au3>
	#include <String.au3>
	#include <GuiComboBoxEx.au3>
	#include <GuiRichEdit.au3>
	#include <..\udf\GuiCTRLRichEdit.au3>
	#include <File.au3>
	#include <GuiMenu.au3>
	#Include <GDIPlus.au3>
	#include <GuiIPAddress.au3>
	#include <SQLite.dll.au3>
	#include <GuiTab.au3>
	#include <GuiButton.au3>
	#include <Excel.au3>
	#include <Inet.au3>
#endregion
#include <..\variables.au3>
#region UDFs
	#include <..\udf\ReduceMem.au3>
	;#include <..\udf\ErrHandeler.au3> ; replaced by the au3 general functions
	#include <..\udf\_GUICtrlListView_CreateArray.au3>
	#include <..\udf\_PrintFromArray.au3>
	#include <..\udf\GUICtrlRichEdit_WriteLine.au3>
	#include <..\udf\inputbox2.au3>
	#include <..\udf\_Zip.au3>
;~ 	#include <..\udf\Zip.au3>  old zip udf
	#include <..\udf\rotatingRing.au3>
	#include <..\udf\miliseconds.au3>
	#include <..\udf\FileNew.au3>
	#include <..\udf\_ValidIP.au3>
	#include <..\udf\__ArrayConcatenate.au3>
	#include <..\udf/_DateCluster.au3>
	#include <..\SQLite\SQLite.au3>
	#include <..\udf\onEventFunc.au3>
	#include <..\udf\DTC.au3>
	#include <..\udf\WinHttpConstants.au3>
	#include <..\udf\WinHttp.au3>
	#include <..\udf\WinHttpPostGet.au3>
	#include <..\udf\resources.au3>
#endregion
#region application
	#include <..\controls\func_general.au3>
	#include <..\Includes\FileIncludes.au3>
	#include <..\controls\functions.au3>
	#include <..\controls\controles.au3>
	#include <..\sqlite\SQLite_Functions.au3>
	#include <..\controls\Func_WM_SYSCOMMAND.au3>
	#include <..\controls\Func_WM_COMMAND.au3>
	#include <..\controls\Func_WM_NOTIFY.au3>
	#include <..\controls\Func_WM_SIZE.au3>
	#include <..\controls\Func_WM_PAINT.au3>
	#include <..\controls\RunFunctions.au3>
	#include <..\controls\Func_FGMagentconnector.au3>
	#include <..\controls\Func_PrjRepo.au3>
;~ 	#include <..\controls\update.au3>
	#include <..\controls\WebService.au3>
	#include <..\controls\Mergedb.au3>
	#include <..\controls\Func_SchemaUpdate.au3>
	#include <..\controls\Func_Zipmakecab.au3>
	#include <..\sqlite\cleanstring.au3>
;~ 	#include <Authentication.au3>
#endregion
#region forms
	#include <..\forms/FormSettings.au3>
	#include <..\forms/FormJobCreation.au3>
	#include <..\forms/FormFolderCreationTask.au3>
	#include <..\forms/FormConsole.au3>
	#include <..\forms/FormJobimport.au3>
	#include <..\forms/FormAbout.au3>
	#include <..\forms/FormCOPYTask.au3>
	#include <..\forms/FormExecuteTask.au3>
	#include <..\forms/FormDeployAgentTask.au3>
	#include <..\forms/FormDescribe.au3>
	#include <..\forms/FormExportImportServers.au3>
	#include <..\forms/FormResetServers2Template.au3>
#endregion



