'-------------------------------------------------------------------------------
'-- VBS script file
'-- Load and execute Query TDM File
'Option Explicit ' This setting requires explicit variable allocation in script.
AutoIgnoreError = 0 ' 1 turns off any error popups. 0 Enables popups
Dim QueryString, Cond_Count, Query_Index, Query_Type, Max_Results, X, Y, AdvancedQuery, MyDataFinder, MyResults, ResultString, Cond_array(100,4)
On Error Resume Next

ResultString = ""

' Variables that need to be passed in from LabVIEW
'TDMFILE = "I:\Engineering\Development\SPARTAN\www\cgi-bin\cgi-lib\Database\Datafinder\Channel_query.tdm"
QueryString = T1 ' T1 is set by the LabVIEW control program  (DIADEM Daemon.vi)
QueryString = ADD_APOST(QueryString) 'Put apostrophes back into string
T1 = ""

'msgbox(AutoActPath&"\Load_Query String.vbs")
ScriptInclude(AutoActPath&"Load_Query String.vbs")
ScriptInclude (AutoActPath&"\DD Lib.vbs") 'Common functions
Set AdvancedQuery = Navigator.CreateQuery(eAdvancedQuery)
Call Load_Query_String (QueryString, AdvancedQuery, query_type, Cond_Count, Cond_array, Max_Results)

If (Not AdvancedQuery.IsEmpty) Then
  ' Execute the Query
  Set MyDataFinder = Navigator.ConnectDataFinder(Spartan_DF)

  Call MyDataFinder.Search(AdvancedQuery) ' This will return only 500
  'Process the Results
  Set MyResults = MyDataFinder.Results

  If((MyDataFinder.Results.IsIncomplete) And (Max_Results > MyResults.count)) Then
    MyDataFinder.Results.MaxCount = 32000 ' This only works on a current data set
    Call MyDataFinder.Search(AdvancedQuery) 'Must requery to get all the results
  End If
  'msgbox(MyResults.count)
  ' Create new group to hold the results
  If MyResults.count > 0 Then
    ' Populate each Channel with the Result Data
    ' [1] is Full Path to the file with the result - Returned with all queries
    ' [2] is the Model Number stored in the registertxt2 variable
    ' [3] is the Serial Number stored in the registertxt1 variable
    ' [4] is the Group name (RUN #) - Only returned for Group Queries and CHannel Queries
    ' [5] is the Channel ID         - Only returned for Group Queries and CHannel Queries
    ' [6..N] are the results associated with each Condition.  These are returned as 'columns.'
    X = 1
    '---------------------------------------FOR EACH ELEMENT--------------------------------------------------
    For Each Element in MyResults          ' Process each element of the results
      If (X <= Int(Max_Results)) Then
      'Create Destination Channel
        Select Case Loc(Query_Type) ' Depending on the query result type - Change way of referencing field
          Case "esearchfile"
            ResultString = ResultString + Element.Properties("FullPath").value + vbTab      ' File Path of TDM
            ResultString = ResultString + Element.Properties("registertxt2").value + vbTab  ' AKA Model Number
            ResultString = ResultString + Element.Properties("registertxt1").value + vbTab  ' AKA Serial Number
            ResultString = ResultString + "" + vbTab                                        ' Group Name is not available
            ResultString = ResultString + "" + vbTab                                        ' Channel Name is not Available
          Case "esearchchannelgroup"
            ResultString = ResultString + Element.Properties("root.parent.parent.FullPath").value + vbTab ' File Path of TDM
            ' The root.parent.parent.fullpath is workaround from Brad Turpin of NI
            ResultString = ResultString + Element.Properties("root.registertxt2").value + vbTab           ' AKA Model Number
            ResultString = ResultString + Element.Properties("root.registertxt1").value + vbTab           ' AKA Serial Number
            ResultString = ResultString + Element.Properties("Name").value                                ' Group Name AKA RUN #
            ResultString = ResultString + vbTab
            ' The following elements are accessed now since properties are available.
            ' They are used to build the data tree in review.vit
            ResultString = ResultString + CStr(Element.Properties("Start_Timestamp").value)
            ResultString = ResultString + vbTab
            ResultString = ResultString + CStr(Element.Properties("End_Timestamp").value)
            ResultString = ResultString + vbTab
            ResultString = ResultString + Element.Properties("Step_tag").value
            ResultString = ResultString + vbTab
            ResultString = ResultString + Element.Properties("Test_status").value
            ResultString = ResultString + vbTab
            ResultString = ResultString + Element.Properties("Operator").value
            ResultString = ResultString + vbTab
            ResultString = ResultString + Element.Properties("Test_Station").value
            ResultString = ResultString + vbTab
            ' You may wonder why the +vbTab is on a separate line.  In the case where the property
            ' is missing that line will error out.  Orginally had Result + Property+vbtab.  this
            ' didn't work when the property was missing.
          Case "esearchchannel"
            ResultString = ResultString + Element.Properties("Group.root.parent.parent.FullPath").value + vbTab ' File Path of TDM
            ' The root.parent.parent.fullpath is workaround from Brad Turpin of NI
            ResultString = ResultString + Element.Properties("Group.root.registertxt2").value + vbTab           ' AKA Model Number
            ResultString = ResultString + Element.Properties("Group.root.registertxt1").value + vbTab           ' AKA Serial Number
            ResultString = ResultString + Element.Properties("Group.Name").value + vbTab                        ' Group Name AKA RUN #
            ResultString = ResultString + Element.Properties("Name").value + vbTab                              ' Channel Name
          Case Else
            ResultString = ResultString + "ERROR - Bad Query Type:"&Query_Type
        End Select
        ' Add each Conditions values to the returned result
        '---------------------------------FOR COND_COUNT-----------------------------------------------------
        For Y = 0 To Cond_Count -1
          If (Loc(Cond_array(Y,1)) = "registerval1") And (Loc(Query_Type) <> "esearchchannel") Then ' Special logic for Time query
            ResultString = ResultString + Cond_array(Y,0)&" "&Cond_array(Y,1)& " Parameter Not Available during "&Query_Type&" search"
          Else
            '---------------------------START ELSE-----------------------------------------------------
            Select Case Loc(Query_Type) ' Depending on the query result type - Change way of referencing field
              Case "esearchfile"
                '---------------------------------------------------------------------------
                Select Case (Loc(Cond_array(Y,0))) ' Depending on Condition type - Change way of referencing field
                  Case "esearchfile"
                    ResultString = ResultString + Element.Properties(Cond_array(Y,1)).value
                  Case Else
                    ResultString = ResultString + Cond_array(Y,0)&" "&Cond_array(Y,1)& " Property Not Available during FILE Search"
                End Select
              '---------------------------------------------------------------------------
              Case "esearchchannelgroup"
                '---------------------------------------------------------------------------
                Select Case (Loc(Cond_array(Y,0))) ' Depending on Condition type - Change way of referencing field
                  Case "esearchfile"
                    Select Case (Loc(Cond_array(Y,1)))
                      Case "filename","fullpath"
                        ' These two properities are special.  Below is workaround.  All other properties
                        ' are accessed like root.registertxt1.  There may be others but we use these in queries.
                        ResultString = ResultString + Element.Properties("root.parent.parent."&Cond_array(Y,1)).value
                      Case Else
                        ResultString = ResultString + Element.Properties("root."&Cond_array(Y,1)).value
                    End Select
                  Case "esearchchannelgroup"
                    'msgbox(Cond_array(Y,1)&"="&Element.Properties(Cond_array(Y,1)).value)
                    ResultString = ResultString + cstr(Element.Properties(Cond_array(Y,1)).value)
                  Case "esearchchannel"
                    ResultString = ResultString + cstr(Element.Properties("channels."&Cond_array(Y,1)).value)
                  Case Else
                    'msgbox((Cond_array(Y,0))&" "&LOC(Cond_array(Y,1))&" "&LOC(Cond_array(Y,2))&" "&LOC(Cond_array(Y,3)))
                    ResultString = ResultString + "ERROR - Bad Query Type:"&Cond_array(Y,0)
                End Select
              '---------------------------------------------------------------------------
              Case "esearchchannel"
                '---------------------------------------------------------------------------
                Select Case (Loc(Cond_array(Y,1))) ' Depending on Condition type - Change way of referencing field
                  Case "esearchfile"
                    ResultString = ResultString + cstr(Element.Properties("Group.root."&Cond_array(Y,2)).value)
                  Case "esearchchannelgroup"
                    ResultString = ResultString + cstr(Element.Properties("Group."&Cond_array(Y,2)).value)
                  Case "esearchchannel"
                    ResultString = ResultString + cstr(Element.Properties(Cond_array(Y,2)).value)
                  Case Else
                    ResultString = ResultString + "ERROR - Bad Query Type:"&Cond_array(Y,1)
                End Select
                '---------------------------------------------------------------------------
              Case Else
                ResultString = ResultString + "ERROR - Bad Query Type:"&Cond_array(Y,1)
            End Select
            '------------------------------END ELSE--------------------------------------------------
          End If
          'msgbox(ResultString)
          If (Y < Cond_Count -1) Then
            ResultString = ResultString + vbtab
          End If
        Next
        '-----------------------------------END FOR COND_COUNT----------------------------------------------------
      Else
        Exit For
      End If ' END IF less than Max_Results
      X = X + 1
      ResultString = ResultString + vbCR
    Next
    '----------------------------------END FOR ELEMENT-------------------------------------------------------
    ' Save the data back to the TDM file
    'msgbox("Saving Data")
    T1 = RemoveApostrophe(ResultString)
  End If ' If there were any results
End If ' ENDING IF THERE ARE Greater than zero Conditions
'-----------------------------END IF COND_COUNT > 0 --------------------------------
'  If you need to know the result column name use item below to recall from results array.
'MsgBox Navigator.Display.CurrDataProvider.ResultsList.Columns(2).GetPath(eSearchChannelGroup)