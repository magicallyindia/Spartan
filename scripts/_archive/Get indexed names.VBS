'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 10/27/2006 14:20:09
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------

Dim oMyProperties, oMyQueryForm, mypropnames, myoutput
Set oMyQueryForm = Navigator.Display.CurrDataProvider.QueryForm
Set oMyProperties = oMyQueryForm.GetIndexedProperties(eSearchChannel) ' Select level
'Set oMyProperties = oMyQueryForm.GetIndexedProperties(eSearchChannelGroup) ' Select level
'Set oMyProperties = oMyQueryForm.GetIndexedProperties(eSearchFile)
MsgBox oMyProperties.Count

For x =1 to oMyProperties.Count
   myoutput= oMyProperties.Item(x).name &  " = { "
    IF (oMyProperties.Item(x).datatype = datatypestring) THEN
        set mypropnames = oMyProperties.Item(x).getvaluelist  ' Get values only works for datatypestring
        for i = 1 to mypropnames.count
            MyOutput = MyOutput & " " & mypropnames.Values(i)
        next
        MyOutput = MyOutput & " }"
    ELSE
        MyOutput = MyOutput & " <Can't get values not string> }"
    END IF
    msgbox myoutput
next

' see indexed properties to get values of an item