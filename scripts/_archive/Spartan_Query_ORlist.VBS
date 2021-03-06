'-------------------------------------------------------------------------------
'-- VBS script file
'-- Load and execute Query TDM File 
'Option Explicit         ' This setting requires explicit variable allocation in script.
AutoIgnoreError = 0     ' 1 turns off any error popups. 0 Enables popups

DIM TDMFILE, Cond_Count, Query_Index, Query_Type, Max_Results
DIM X, Y, Z
DIM AdvancedQuery
DIM MyDataFinder, MyResults, Total_Results
DIM MNSNLIST

' Variables that need to be passed in from LabVIEW
'TDMFILE = "I:\Engineering\Development\SPARTAN\www\cgi-bin\cgi-lib\Database\Datafinder\Channel_query.tdm"
TDMFILE = T1   ' T1 is set by the LabVIEW control program  (DIADEM Daemon.vi)
'msgbox(AutoActPath)
ScriptInclude(AutoActPath&"\Load_Query.vbs")

SET AdvancedQuery=Navigator.CreateQuery(eAdvancedQuery)
Call Load_Query (TDMFILE, AdvancedQuery, query_type, Cond_Count, Max_Results)
CALL Load_MNSNLIST(MNSNLIST, MNSN_Count)

Total_results = 0
NewGroupName = GroupCreate("Spartan_Results",1)
FOR Z = 1 to MNSN_COUNT 
    'msgbox("mn = "&MNSNLIST(Z,1)&"SN = "&MNSNLIST(Z,2))

    CALL AdvancedQuery.Conditions.Add(eSearchFile,"registertxt2","=",MNSNLIST(Z,1))
    CALL AdvancedQuery.Conditions.Add(eSearchFile,"registertxt1","=",MNSNLIST(Z,2))

    IF (NOT AdvancedQuery.IsEmpty) THEN
          ' Execute the Query
        SET MyDataFinder = Navigator.ConnectDataFinder(Spartan_DF)
        Call MyDataFinder.Search(AdvancedQuery) ' This will return only 500
         'Process the Results
        set MyResults  = MyDataFinder.Results
               
        IF ((MyDataFinder.Results.IsIncomplete) AND (Max_Results > MyResults.count) )THEN
              MyDataFinder.Results.MaxCount = 5000 ' This only works on a current data set
              CALL MyDataFinder.Search(AdvancedQuery)  'Must requery to get all the results
        END IF
        'msgbox(MyResults.count)
        ' Create new group to hold the results        
        IF MyResults.count > 0 THEN
     

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
            IF (X <= int(Max_Results)) THEN

             'Create Destination Channel
             MyChnName = ChnAlloc("Result"&(X+Total_Results), 5 + Cond_Count, 1, DataTypeString, "text", GroupIndexGet("Spartan_Results"))

             SELECT CASE LOC (Query_Type) ' Depending on the query result type - Change way of referencing field
                CASE "esearchfile"
                     CHT(1,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("FullPath").value      ' File Path of TDM
                     CHT(2,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("registertxt2").value  ' AKA Model Number
                     CHT(3,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("registertxt1").value  ' AKA Serial Number
                     CHT(4,"Spartan_Results/Result"&(X+Total_Results))= ""                                        ' Group Name is not available
                     CHT(5,"Spartan_Results/Result"&(X+Total_Results))= ""                                        ' Channel Name is not Available
               CASE "esearchchannelgroup"
                     CHT(1,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("root.parent.parent.FullPath").value   ' File Path of TDM
                     ' The root.parent.parent.fullpath is workaround from Brad Turpin of NI
                     CHT(2,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("root.registertxt2").value             ' AKA Model Number
                     CHT(3,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("root.registertxt1").value             ' AKA Serial Number
                     CHT(4,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("Name").value                          ' Group Name AKA RUN #
                     CHT(5,"Spartan_Results/Result"&(X+Total_Results))= ""                                                        ' Channel Name is not Available
               CASE "esearchchannel"
                     CHT(1,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("Group.root.parent.parent.FullPath").value  ' File Path of TDM
                     ' The root.parent.parent.fullpath is workaround from Brad Turpin of NI
                     CHT(2,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("Group.root.registertxt2").value            ' AKA Model Number
                     CHT(3,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("Group.root.registertxt1").value            ' AKA Serial Number
                     CHT(4,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("Group.Name").value                         ' Group Name AKA RUN #
                     CHT(5,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("Name").value                               ' Channel Name
                 CASE ELSE
                     CHT(1,"Spartan_Results/Result"&(X+Total_Results))= "ERROR - Bad Query Type:"&Query_Type
             END SELECT
             ' Add each Conditions values to the returned result
             '---------------------------------FOR COND_COUNT-----------------------------------------------------
             FOR Y = 1 TO Cond_Count
              'msgbox(Y)
                IF (LOC(CHT(2,Y)) = "registerval1") AND ( LOC (Query_Type) <> "esearchchannel") THEN ' Special logic for Time query
                   CHT(5+Y,"Spartan_Results/Result"&(X+Total_Results))= CHT(1,Y)&" "&CHT(2,Y)& " Parameter Not Available during "&Query_Type&" search"  
                ELSE
                   '---------------------------START ELSE-----------------------------------------------------
                   SELECT CASE LOC (Query_Type)  ' Depending on the query result type - Change way of referencing field
                      CASE "esearchfile" 
                         '---------------------------------------------------------------------------
                          SELECT CASE (LOC(CHT(1,Y)))  ' Depending on Condition type - Change way of referencing field
                             CASE "esearchfile"
                                  CHT(5+Y,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties(CHT(2,Y)).value
                             CASE ELSE
                                  CHT(5+Y,"Spartan_Results/Result"&(X+Total_Results))= CHT(1,Y)&" "&CHT(2,Y)& " Property Not Available during FILE Search"
                          END SELECT
                        '---------------------------------------------------------------------------
                      CASE "esearchchannelgroup"
                        '---------------------------------------------------------------------------
                         SELECT CASE (LOC(CHT(1,Y)))  ' Depending on Condition type - Change way of referencing field
                             CASE "esearchfile"
                                SELECT CASE (LOC(CHT(2,Y)))
                                    CASE "filename","fullpath"
                                         ' These two properities are special.  Below is workaround.  All other properties
                                         ' are accessed like root.registertxt1.  There may be others but we use these in queries.
                                         CHT(5+Y,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("root.parent.parent."&CHT(2,Y)).value
                                    CASE ELSE
                                        CHT(5+Y,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("root."&CHT(2,Y)).value
                                    END SELECT
                             CASE "esearchchannelgroup"
                                 CHT(5+Y,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties(CHT(2,Y)).value
                             CASE "esearchchannel"
                                  'CHT(5+Y,"Spartan_Results/Result"&X)= CHT(1,Y)&" "&CHT(2,Y)& " Property Not Available during GROUP Search"
                                  CHT(5+Y,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("channels."&CHT(2,Y)).value
                             CASE ELSE
                                  CHT(5+Y,"Spartan_Results/Result"&(X+Total_Results))= "ERROR - Bad Query Type:"&CHT(1,Y)
                          END SELECT
                         '---------------------------------------------------------------------------
                     CASE "esearchchannel"
                         '---------------------------------------------------------------------------
                          SELECT CASE (LOC(CHT(1,Y)))  ' Depending on Condition type - Change way of referencing field
                             CASE "esearchfile"
                                 CHT(5+Y,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("Group.root."&CHT(2,Y)).value
                             CASE "esearchchannelgroup"
                                 CHT(5+Y,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties("Group."&CHT(2,Y)).value
                             CASE "esearchchannel"
                                  CHT(5+Y,"Spartan_Results/Result"&(X+Total_Results))= Element.Properties(CHT(2,Y)).value
                             CASE ELSE
                                  CHT(5+Y,"Spartan_Results/Result"&(X+Total_Results))= "ERROR - Bad Query Type:"&CHT(1,Y)
                          END SELECT
                        '---------------------------------------------------------------------------
                      CASE ELSE
                             CHT(1,"Spartan_Results/Result"&(X+Total_Results))= "ERROR - Bad Query Type:"&CHT(1,Y)
                   END SELECT   
                   '------------------------------END ELSE--------------------------------------------------
                END IF
             NEXT
            '-----------------------------------END FOR COND_COUNT----------------------------------------------------
            ELSE
               EXIT FOR
                     
            END IF ' END IF less than Max_Results
             X = X+1
          NEXT
          '----------------------------------END FOR ELEMENT-------------------------------------------------------
  Total_Results = Total_Results + (X-1)
  AdvancedQuery.Conditions.Remove(Cond_Count)
  AdvancedQuery.Conditions.Remove(Cond_Count +1)
       END IF ' If there were any results
       END IF ' ENDING IF THERE ARE Greater than zero Conditions

NEXT ' Z
' ---------------- END FOR each MN SN item

          ' Save the data back to the TDM file
          'msgbox("Saving Data")
          Call DataFileSave(TDMFILE,"TDM")
  


'-----------------------------END IF COND_COUNT > 0 --------------------------------
'  If you need to know the result column name use item below to recall from results array. 
'MsgBox Navigator.Display.CurrDataProvider.ResultsList.Columns(2).GetPath(eSearchChannelGroup) 