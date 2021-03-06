'-------------------------------------------------------------------------------
'-- VBS script file
'-- Load and execute Query TDM File 
'Option Explicit         ' This setting requires explicit variable allocation in script.

DIM TDMFILE, Cond_Count, Query_Index, Query_type, Max_Results
DIM X, Y, I
DIM AdvancedQuery
DIM MyDataFinder, MyResults, MyChnName, oMyValues
Dim oMyProperties, oMyQueryForm, mypropnames, myoutput
DIM Search_Property, Search_type, Search_Comp, Search_Value
DIM Cond_array(100,4), QueryString

' Variables that need to be passed in from LabVIEW
'TDMFILE = "I:\Engineering\Development\SPARTAN\www\cgi-bin\cgi-lib\Database\Datafinder\Channel_query.tdm"
QueryString = T1   ' T1 is set by the LabVIEW control program  (DIADEM Daemon.vi)
T1=""
ON ERROR RESUME NEXT

ScriptInclude(AutoActPath&"Load_Query String.vbs")

' Select Property Name
'Search_Property = "registertxt2"
'Search_property = "Operator"
'Search_property = "Test_Type"

' Select level of property
'Search_type = eSearchChannelGroup   
'Search_type = eSearchFile

'Select Search Condition Type
'Search_Comp = "="

'Select Search Value
'Search_Value = "*"

SET AdvancedQuery=Navigator.CreateQuery(eAdvancedQuery)
Call Load_Query_String (QueryString, AdvancedQuery, query_type, Cond_Count, Cond_array, Max_Results)

ResultString = ""

SELECT CASE LOC (Query_Type) ' Depending on the query result type - Change way of referencing field
                CASE "esearchfile"
                      Search_type = esearchfile 
                CASE "esearchchannelgroup"
                      Search_type = eSearchChannelGroup   
                CASE "esearchchannel"
                      Search_type = esearchchannel   
                CASE ELSE
                      Search_type = eSearchChannelGroup  
             END SELECT

IF (NOT AdvancedQuery.IsEmpty) THEN

    Search_Property = AdvancedQuery.conditions.item(1).property

    'msgbox Search_Property
    'msgbox Search_type

    SET MyDataFinder  = Navigator.ConnectDataFinder(Spartan_DF)
    SET oMyProperties = MyDataFinder.GetIndexedProperties(Search_type)

    ' The 0MYproperties returns a list of all indexed properties like registertxt1, registertxt 2 etc

    FOR X = 1 TO oMyProperties.Count  ' Now look through all the indexed properties for the one we want

          'msgbox oMyProperties.Item(X).name & " " & oMyProperties.Item(X).datatype
          IF ((oMyProperties.Item(X).name = Search_Property) AND (oMyProperties.Item(X).datatype = datatypestring )) THEN 
              
               SET mypropnames = oMyProperties.Item(x).getvaluelist(AdvancedQuery)      
               IF ERR.number > 0 THEN 
                 ResultString = ""
                 EXIT FOR 
               END IF 
          
              ON ERROR RESUME NEXT

              WHILE   ((mypropnames.isIncomplete) AND (Max_Results > mypropnames.count) )
                  MyDataFinder.ValueMaxCount = MyDataFinder.ValueMaxCount + 1000
                  Set mypropnames = oMyProperties.Item(x).getvaluelist(AdvancedQuery)
              WEND


              FOR I = 1 TO mypropnames.count
                  ResultString = ResultString + mypropnames.Values(I)+ vbcr

              NEXT ' For each mypropnames.count
              EXIT FOR ' Since I found the property I am looking for exit the loop
         
           END IF  ' If this is the right property and String variable

     NEXT ' For each oMyProperties.Count

     ' Save the data back to the TDM file
    'msgbox ResultString
T1 = ResultString   

END IF ' If there were any results

