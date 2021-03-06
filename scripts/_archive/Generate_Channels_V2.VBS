'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 01/30/2006 14:58:43
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Numbercalc = 10
NumberChannels = 20

CALL ChnAlloc("INDEX", NumberCalc, 1, DataTypeFloat64)  'Create destination FOR Data
FOR intLoop = 1 TO NumberCalc              ' FOR Each point
             CHD(intLoop,"INDEX") = intloop
NEXT
' This simulates loading of the data 
FOR CHLoop = 1 to NumberChannels  ' Create twenty Channels
    New_Name = "CHANNEL_"&chloop
    CALL ChnAlloc(New_Name, NumberCalc, 1, DataTypeFloat64)  'Create destination FOR Data

    New_Chan_Index = CNo(New_Name)   ' What is the index of the calculated Data

    FOR intLoop = 1 TO NumberCalc              ' FOR Each point
        CHD(intLoop,New_Chan_Index) = CHLoop*1.5 + Random(5)  ' Perform calc
    NEXT

NEXT

' Assume that the data channels are the same length.

For I = 1 To 22
  StatSel(I) = "No"
Next
StatSel(4) = "Yes" ' Minimum
StatSel(5) = "Yes" ' Maximum
StatSel(6) = "Yes" ' Arith. mean
Statsel(14) = "Yes" ' Standard Deviation
StatResChn = TRUE
Call StatBlockCalc("Block","1-","'Channel_1'-'Channel_20'")

CALL ChnAlloc("TOP_SDEV", NumberCalc, 1, DataTypeFloat64)  'Create destination FOR Data
CALL ChnAlloc("BOT_SDEV", NumberCalc, 1, DataTypeFloat64)  'Create destination FOR Data

Top_index = CNo("TOP_SDEV")
bot_index = CNo("BOT_SDEV")
msgbox(Top_index &" "& bot_index)
msgbox( ChD(1,CNo("Arithm_mean")))
msgbox( ChD(1,CNo("Standard_dev")))
msgbox(ChD(1,CNo("Arithm_mean"))+ ChD(1,CNo("Standard_dev")))
For intloop = 1 To NumberCalc
  ChD(intloop,Top_index) = ChD(intloop,CNo("Arithm_mean"))+ ChD(intloop,CNo("Standard_dev"))
  ChD(intloop,Bot_index) = ChD(intloop,CNo("Arithm_mean"))- ChD(intloop,CNo("Standard_dev"))
Next
