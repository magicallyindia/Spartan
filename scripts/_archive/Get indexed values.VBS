'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 10/27/2006 14:20:09
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------

Dim oMyProperties, oMyQueryForm, mypropnames, myoutput
DIM Search_Property, Search_type, Search_Comp, Search_Value

' Select Property Name
Search_Property = "registertxt2"
'Search_property = "Operator"
'Search_property = "Test_Type"

' Select level of property
'Search_type = eSearchChannelGroup   
Search_type = eSearchFile

'Select Search Condition Type
Search_Comp = "="

'Select Search Value
Search_Value = "6*"


Set oMyQueryForm = Navigator.Display.CurrDataProvider.QueryForm
Set oMyProperties = oMyQueryForm.GetIndexedProperties(Search_type)
Set MyAdaptiveQuery = Navigator.CreateQuery(eAdvancedQuery)
Call MyAdaptiveQuery.Conditions.Add(Search_type, Search_Property, Search_Comp, Search_Value)

'MsgBox oMyProperties.Count

For x =1 to oMyProperties.Count
  'msgbox oMyProperties.Item(x).name & " " & oMyProperties.Item(x).datatype
  If ((oMyProperties.Item(x).name = Search_Property) AND (oMyProperties.Item(x).datatype = datatypestring )) Then 
    
    set mypropnames = oMyProperties.Item(x).getvaluelist(MyAdaptiveQuery)

    myoutput = oMyProperties.Item(x).name & " = {
    for i = 1 to mypropnames.count
      MyOutput = MyOutput & "; " & mypropnames.Values(i)
    next
    Myoutput = myoutput & "}
    msgbox myoutput
  End If
next

' see indexed properties to get values of an item



