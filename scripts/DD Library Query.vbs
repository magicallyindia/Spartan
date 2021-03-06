'-------------------------------------------------------------------------------
'-- Spartan VBS script file
'-- Created on 04/23/2013 16:23:18
'-- Author: James Brunner
'-- Comment: Library of routines to query against the Spartan DataFinder
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.
AutoIgnoreError = 1 ' 1 turns off any error popups. 0 Enables popups\

Call Subsequence("DD Library Query") ' makes sure this script is not called standalone

Sub LoadQueryString(QueryString, AdvancedQuery, Query_type, Cond_count, Cond_array, Max_Results)

    Dim Query_Index, X, Y, Channel_MAXTIME, Channel_X, Qarray, Qcond

    Call Debug(CurrentScriptName, "====== Entering LoadQueryString ======>")
    'Call Debug(CurrentScriptName, "QueryString: " & QueryString)

    ' Set default values
    Query_Type = "esearchchannelgroup"
    Max_Results = 32000
    Cond_Count = 0

    ' Parse parameters
    Qarray = Split(QueryString, vbCr, -1, 1)
    Query_Type = Qarray(0)
    Max_Results = Qarray(1)
    Cond_Count = Qarray(2)

    If Cond_Count > 0 Then  ' Don't do Query if there are no conditions.
        ' Define the Return type
        If (Max_Results < 0) Then
            Max_Results = 32000
        End If 'Will be set to -1 for all results

        Call Debug(CurrentScriptName, "Query_Type: " & Query_Type)
  
        Select Case LoC(Query_Type)
            Case "esearchfile"
                AdvancedQuery.ReturnType = eSearchFile
    
            Case "esearchchannelgroup"
                AdvancedQuery.ReturnType = eSearchChannelGroup
            
            Case "esearchchannel"
                AdvancedQuery.ReturnType = eSearchChannel
            
            Case Else ' search runs by default
                AdvancedQuery.ReturnType = eSearchChannelGroup
        End Select
  
        ' Load the Conditions for the Query
        ' Conditions are stored [ <Type>, <property name>, <comparison>, <Value>]
        For X = 0 To Cond_Count - 1
            qcond = Split(Qarray(X+3), vbTab, -1, 1)
            Cond_array(X,0) = qcond(0)
            Cond_array(X,1) = qcond(1)
            Cond_array(X,2) = qcond(2)
            Cond_array(X,3) = qcond(3)

            Call  Debug("Query condition(" & x & "): " & qcond(1) & " " & qcond(2) & " " & qcond(3))
    
            Select Case LoC(qcond(0))
                Case "esearchfile"
                    Call AdvancedQuery.Conditions.Add(eSearchFile, qcond(1),qcond(2),qcond(3))
                
                Case "esearchchannelgroup"
                    Call AdvancedQuery.Conditions.Add(eSearchChannelGroup, qcond(1),qcond(2),qcond(3))
      
                Case "esearchchannel"
                    Call AdvancedQuery.Conditions.Add(eSearchChannel, qcond(1),qcond(2),qcond(3))
                    
                Case Else ' unknown query condition!
                    ' ERROR
            End Select
        Next
        
    End If

    Call Debug(CurrentScriptName, "<====== Exiting LoadQueryString ======")
End Sub

' runs query to load specific TDMS channel from mn and sn
Sub LoadRunChannel(mn, sn, chName)
    
    Dim AdvancedQuery, MyDataFinder, MyResults, Element
    Dim i, chIndex, chMaxStartTime

    Call Debug(CurrentScriptName, "[LoadRunChannel] mn: " & mn & ", sn: " & sn & ", channel: " & chName)
    
    ' Open new Query to search groups (runs)
    Set AdvancedQuery = Navigator.CreateQuery(eAdvancedQuery)
    AdvancedQuery.ReturnType = eSearchChannelGroup
    
    ' add mn, sn, channelName search conditions on FILE
    Call AdvancedQuery.Conditions.Add(eSearchFile, "MODEL_NUMBER", "=", mn)
    Call AdvancedQuery.Conditions.Add(eSearchFile, "SERIAL_NUMBER", "=", sn)

    ' add chName condition on CHANNEL
    Call AdvancedQuery.Conditions.Add(eSearchChannel, "name", "=", chName)

    ' Execute the Query
    Set MyDataFinder = Navigator.ConnectDataFinder(Spartan_DF)
    Call MyDataFinder.Search(AdvancedQuery) ' This will return only 500

    'Process the Results
    Set MyResults = MyDataFinder.Results

    i = 1
    chMaxStartTime = 0
    chIndex = 0
    
    If MyResults.Count = 0 Then
        Call Debug(CurrentScriptName, "No results to load")
        Exit Sub
    End If
    
    ' find channel with greatest start timestamp
    For Each Element In MyResults
        If chMaxStartTime < Element.Properties("START_TIMESTAMP").value Then
            chIndex = i
            chMaxStartTime = Element.Properties("START_TIMESTAMP").value
        End If
        
        i = i + 1
    Next ' result
    
    i = 1
    ' now retrive the desired channel
    For Each Element in MyResults
        If (i = chIndex)  Then
            Call Navigator.LoadData(Element, "Load")
            Exit For
        End If
        
        i = i + 1
    Next ' result

End Sub

