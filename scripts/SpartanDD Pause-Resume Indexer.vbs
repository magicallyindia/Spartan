'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 01/04/2011 6:42:22
'-- Author: Christopher Bauer
'-- Comment: This will either pause or resume the indexer
'-------------------------------------------------------------------------------
Option Explicit ' Forces the explicit declaration of all the variables in a script.
AutoIgnoreError = 1 ' 1 turns off any error popups. 0 Enables popups

ScriptInclude(CurrentScriptPath & "DD Library.vbs") ' debugging and text routines

Dim DataFinder, Action
Action = T4 ' "Pause" or "Resume" from Spartan

Set DataFinder = Navigator.ConnectDataFinder(Spartan_DF) ' set in "SpartanDD Initialize.vbs"

If Action = "Pause" Then
    DataFinder.IndexerStatus = 2 'Pause DataFinder after it is done with the file it is currently working on
ElseIf Action = "Resume" Then
    DataFinder.IndexerStatus = 1 'Start DataFinder indexing again
End If

Call Debug(CurrentScriptName, "Set DataFinder(" & Action & ")") 