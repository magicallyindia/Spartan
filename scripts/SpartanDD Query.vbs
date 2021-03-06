'-------------------------------------------------------------------------------
'-- Spartan VBS script file
'-- Updated on 04/18/2013 
'-- Author: James Brunner
'-- Summary:
'   This script is called when Spartan uses DIAdem to run data queries.
'-------------------------------------------------------------------------------
Option Explicit         ' This setting requires explicit variable allocation in script.
AutoIgnoreError = 1     ' 1 turns off any error popups. 0 Enables popups

On Error Resume Next ' inline error processing

ScriptInclude(CurrentScriptPath & "DD Library.vbs")

Call Debug("====== SpartanDD Query ======>")

Dim QueryString, ConditionCount, QueryIndex, QueryType, MaxResults, X, Y
Dim AdvancedQuery, MyDataFinder, MyResults, ResultString, ConditionArray(100, 4), ResultColumns

Dim Element, resultFilePath, Temp

' Variables that need to be passed in from LabVIEW
QueryString = T1 ' T1 is set by the LabVIEW control program  (DIADEM Daemon.vi)
ResultColumns = Split(T3, vbTab, -1, 1) ' parse T3 for result columns

T1 = ""
ResultString = ""

Set AdvancedQuery = Navigator.CreateQuery(eAdvancedQuery)

' This will load up the query (but not execute it)
Call LoadQueryString(QueryString, AdvancedQuery, QueryType, ConditionCount, ConditionArray, MaxResults)

'Debug helper to figure out result columns
'MsgBox Navigator.Display.CurrDataProvider.ResultsList.Columns(2).GetPath(eSearchChannelGroup)

If (Not AdvancedQuery.IsEmpty) Then ' do we have a valid query?

    ' Execute the Query
    Set MyDataFinder = Navigator.ConnectDataFinder(Spartan_DF)
    MyDataFinder.Results.MaxCount = MaxResults

    Call Debug("Searching for data...")
    Call MyDataFinder.Search(AdvancedQuery) ' This will return MaxResults
    
    Set MyResults = MyDataFinder.Results
    Call Debug("Query returned " & MyResults.count & " results")

    If (MyDataFinder.Results.IsIncomplete) Then
        T1 = "ERROR: Too many results returned.  Only " & MaxResults & " results can be returned. Please narrow your search and try again."
    Else
        ' Process the Results
        If MyResults.count > 0 Then
            X = 1
            
            Call Debug("Processing query results...")
            
            For Each Element in MyResults
                If (X <= Int(MaxResults)) Then
                    Select Case LoC(QueryType) ' Only allow group queries
                        Case "esearchchannelgroup"
                            resultFilePath = Element.Properties("root.parent.parent.FullPath").value
                            ResultString = ResultString & resultFilePath  ' File Path of TDMS file
                            ResultString = ResultString & vbTab
                            ' The root.parent.parent.fullpath is workaround from Brad Turpin of NI
                            
                            ResultString = ResultString & Element.Properties("root.test_type").Value                ' Test Type
                            ResultString = ResultString & vbTab

                            ResultString = ResultString & Element.Properties("root.model_number").Value             ' Model Number
                            ResultString = ResultString & vbTab

                            ResultString = ResultString & Element.Properties("root.serial_number").Value            ' Serial Number
                            ResultString = ResultString & vbTab

                            ResultString = ResultString & Element.Properties("Name").Value                          ' Run Number
                            ResultString = ResultString & vbTab

                            ResultString = ResultString & CStr(Element.Properties("Start_timestamp").Value )        ' Start Timestamp
                            ResultString = ResultString & vbTab
                            
                            ' You may wonder why the & vbTab is on a separate line.  In the case where the property
                            ' is missing that line will error out.  Originally had Result + Property + vbtab.  This
                            ' didn't work when the property was missing.
            
                        Case Else
                            ResultString = ResultString & "ERROR"
                            
                    End Select
                    
                    ' Add each Conditions values to the returned result
                    For Y = 0 To UBound(ResultColumns)
                    
                        Call Debug("ResultColumn: " & ResultColumns(Y))
                        
                        ' remove any Cr and Lf
                        ResultColumns(Y) = Replace(ResultColumns(Y), vbCr, "")
                        ResultColumns(Y) = Replace(ResultColumns(Y), vbLf, "")
                       
                        ' filter "prompted input" result values
                        If (InStr(ResultColumns(Y), "(Prompted Input)") = 0) Then
                            Select Case Trim(Loc(ResultColumns(Y)))
                                Case "model_number", "serial_number", "test_type"
                                    ResultString = ResultString & Element.Properties("root." & ResultColumns(Y)).value
                                    
                                Case Else
                                    Temp = trimLfCrTab(Cstr(Element.Properties(ResultColumns(Y)).Value))
                                    
                                    If (Element.Properties(ResultColumns(Y)).Value = "") Then
                                        Temp = "--"
                                    End If
                                    
                                    Call Debug("Value: " & Temp)
                                    ResultString = ResultString & Temp
                            End Select
                        Else
                        
                            ResultString = ResultString & "--"
                        End If

                        If (Y < (Ubound(ResultColumns))) Then
                        
                            ResultString = ResultString & vbTab ' Don't put tab at end of line
                        
                        End If                        
                    Next ' Column Count
        
                Else
                    Exit For ' End loop if less than MaxResults
                
                End If 

                X = X + 1 ' next element
                ResultString = ResultString & vbCr ' new row
            
            Next ' result Element

            ' Send data back to LabVIEW via T1 parameter
            Call Debug(CurrentScriptName, "Sending Data: " & ResultString)
            T1 = ResultString
            ResultString = ""
        
        Else
            Call Debug("No results")
        
        End If ' End if there were no results
  
    End If ' End if there were too many results

End If ' End If there is a valid query

Call Debug("<====== SpartanDD Query ======")
