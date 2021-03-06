'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 10/31/2006 14:25:40
'-- Author: Jim West
'-- Comment: Script to build a query condition for an advanced query
'-------------------------------------------------------------------------------
Option Explicit 'Forces the explicit declaration of all the variables in a script.
AutoIgnoreError = 1 ' 1 turns off any error popups. 0 Enables popups

' Calling Script must preallocate the AdvancedQuery with "Navigator.CreateQuery(eAdvancedQuery)"
' Query_type, Cond_count, Max_Results are returned as with variables set.
ScriptInclude (AutoActPath&"\DD Lib.vbs") ' Common functions for DD format includes S2P, ASCII

Sub Load_Query_String (QueryString, AdvancedQuery, Query_type, Cond_count, Cond_array, Max_Results)

Dim Query_Index, X, Y, Channel_MAXTIME, Channel_X, Qarray, Qcond
'Call debug("enter Load_Query_String")

' Set default values
Query_Type = "esearchchannelgroup"
Max_Results = 32000
Cond_Count = 0
'msgbox(QueryString)
Qarray = Split(QueryString, vbCr, -1, 1)
Query_Type  = Qarray(0)
Max_Results = Qarray(1)
Cond_Count  = Qarray(2)

'-----------------------------Start IF COND_COUNT > 0 --------------------------------
If Cond_Count >0 Then  ' Don't do Query if there are no conditions.
  ' Define the Return type
  If (Max_Results < 0) Then
    Max_Results = 32000
  End If 'Will be set to -1 for all results
'  Call debug("query Query_Type "&Query_Type)
  Select Case Loc(Query_Type)
    Case "esearchfile"
      AdvancedQuery.ReturnType = eSearchFile
    Case "esearchchannelgroup"
      AdvancedQuery.ReturnType = eSearchChannelGroup
    Case "esearchchannel"
      AdvancedQuery.ReturnType = eSearchChannel
    Case Else
      AdvancedQuery.ReturnType = eSearchChannelGroup
  End Select
  ' Load the Conditions for the Query
  ' Conditions are stored [ <Type>, <property name>, <comparison>, <Value>]
  For X = 0 To Cond_Count-1
    qcond = Split(Qarray(X+3), vbTab, -1, 1)
    Cond_array(X,0) = qcond(0)
    Cond_array(X,1) = qcond(1)
    Cond_array(X,2) = qcond(2)
    Cond_array(X,3) = qcond(3)

'    Call  debug("query condition "&x&" "&qcond(1)&" "&qcond(2)&" "&qcond(3))
    Select Case Loc(qcond(0))
      Case "esearchfile"
        Call AdvancedQuery.Conditions.Add(eSearchFile, qcond(1),qcond(2),qcond(3))
      Case "esearchchannelgroup"
        Call AdvancedQuery.Conditions.Add(eSearchChannelGroup, qcond(1),qcond(2),qcond(3))
      Case "esearchchannel"
        Call AdvancedQuery.Conditions.Add(eSearchChannel, qcond(1),qcond(2),qcond(3))
      Case Else
        ' ERROR
      End Select
  Next
End If
' Calling Script should now execute the query
'Call debug("exit Load_Query_String")
End Sub