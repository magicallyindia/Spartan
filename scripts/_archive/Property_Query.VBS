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
T1 = ""
ON ERROR RESUME NEXT

ScriptInclude(AutoActPath&"Load_Query String.vbs")

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

    SET MyDataFinder  = Navigator.ConnectDataFinder(Spartan_DF)
    SET oMyProperties = MyDataFinder.GetIndexedProperties(Search_type)

    'msgbox Search_Property
    'msgbox Search_type

    ' The 0MYproperties returns a list of all indexed properties like registertxt1, registertxt 2 etc
    REDIM mypropnames( oMyProperties.Count)
    '     msgbox oMyProperties.Count
    FOR X = 1 TO oMyProperties.Count  ' Now loop through all the indexed properties
         SELECT CASE (oMyProperties.Item(X).DataType)
                CASE DataTypeUnknown
                     ResultString = ResultString +  oMyProperties.Item(X).name  + vbtab + "unknown"    + vbcr  
                CASE DataTypeInt32
                     ResultString = ResultString +  oMyProperties.Item(X).name  + vbtab + "int"        + vbcr  
                CASE DataTypeString
                     ResultString = ResultString +  oMyProperties.Item(X).name  + vbtab + "text"       + vbcr  
                CASE DataTypeFloat64
                     ResultString = ResultString +  oMyProperties.Item(X).name  + vbtab + "float"      + vbcr  
 
                CASE ELSE
                       ResultString = ResultString  
             END SELECT
       'ResultString = ResultString +  oMyProperties.Item(X).name  + vbtab + oMyProperties.Item(X).name + vbcr  

     NEXT ' For each oMyProperties.Count

' Save the data back to Spartan
T1 = ResultString   

END IF ' If there were any results

