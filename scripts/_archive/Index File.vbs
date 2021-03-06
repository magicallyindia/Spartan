'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 10/04/2010 13:19:02
'-- Author: Christopher Bauer
'-- Comment: This will index a specified file and wait until the index is complete.
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.
AutoIgnoreError = 1     ' 1 turns off any error popups. 0 Enables popups
ScriptInclude (AutoActPath&"\DD Lib.vbs") 'Common functions
'T3 = "C:\Development\Spartan\data\TDM\RF Vrs Temp 0 dbXXXXXXs (25 degree)\00000\RF Vrs Temp 0 dbXXXXXXs (25 degree) 1 DC Attenuation.tdms" 'Uncomment to debug
'T4 = "My DataFinder" 'Uncomment to debug
'T5 = -1 'Uncomment to debug (-1 = Wait, 0 = Don't Wait)
'Call logfilewrite(Now & " - Enter Update Index.vbs")
On Error Resume Next
Dim DataFinder, TDMSPath, ErrNum, Wait', StartTime, Query, Count
TDMSPath = ADD_APOST(T3) ' TDMS Path
Wait = T5 ' Wait or not
'Call logfilewrite(Now & " - Indexing - " & TDMSPath)
Set DataFinder = Navigator.ConnectDataFinder(T4)
'DataFinder.IndexerStatus = 2 'Pause DataFinder after it is done with the file it is currently working on
Call DataFinder.Indexer.IndexFile(TDMSPath, TRUE, Wait) 'Index file
'DataFinder.IndexerStatus = 1 'Start DataFinder indexing again with current file at the front of the queue
'StartTime = Timer
'Call logfilewrite(Now & " - Exit Update Index.vbs")
ErrNum = Err.Number
On Error Goto 0
If ErrNum <> 0 Then
  T1 = "1,-100100,The DataFinder has too many jobs in its queue. Indexing of " & TDMSPath & " not complete."
Else
  T1 = "0,0,Success"
'   If Wait = "-1" Then
'     Set DataFinder = Navigator.ConnectDataFinder("My DataFinder")
'     Set Query = Navigator.CreateQuery(eAdvancedQuery)
'     Call Query.Conditions.Add(eSearchFile, "FullPath", "=", TDMSPath)
'     Call Query.Conditions.Add(eSearchFile, "IndexStatus", "=", "eIndexedSuccess")
' 
'     For Count = 0 to 2000
'       If (Timer - StartTime) <= 60 Then
'         Call DataFinder.Search(Query)
'         If DataFinder.Results.Count > 0 Then
'           Exit For
'         End If
'       Else
'         T1 = "1,-100101,The data file index timed out. Indexing of " & TDMSPath & " not complete."
'         Exit For
'       End If
'     Next
' 
'     Call logfilewrite(Now & " - Count - " & Count)
'     Call logfilewrite(Now & " - Index Time - " & Timer - StartTime)
'     Call logfilewrite(Now & " - T1 - " & T1)
'   End If
End If