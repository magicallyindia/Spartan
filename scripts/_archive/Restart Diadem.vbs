'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 10/08/2009 10:29:57
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.

  FileModification = "ignore" ' ignore data changes

  Call DeskSave(AutoActPath & "Last.DDD") ' ignore desktop changes
  ' use CMD line to restart DD
  'Call ExtProgram(ProgramDrv & "DIAdem.exe", """/CScriptStart('" & AutoActFile & "')""") 
  Call ProgramExit


 
