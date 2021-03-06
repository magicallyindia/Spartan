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
NumberCalc = ChnLength("CHANNEL_1")

CALL ChnAlloc("MAX_Trace"  , NumberCalc, 1, DataTypeFloat64)    'Create destination FOR Data
CALL ChnAlloc("MIN_Trace"  , NumberCalc, 1, DataTypeFloat64)    'Create destination FOR Data
CALL ChnAlloc("AVG_Trace"  , NumberCalc, 1, DataTypeFloat64)    'Create destination FOR Data
CALL ChnAlloc("STDEV_Trace", NumberCalc, 1, DataTypeFloat64)  'Create destination FOR Data

FOR intLoop = 1 to NumberCalc  ' For each Data Point
  
    FOR CHloop = 1 TO NumberChannels              ' For Each channel
       CHindex = Cno("CHANNEL_"&chloop)
       'msgbox ("Current Value is "& CHD(intLoop,CHindex))
       IF CHLoop = 1  THEN
             MAX_PT = CHD(intLoop,CHindex)
             MIN_PT = CHD(intLoop,CHindex)
             'msgbox ("Setting max-min initial values to "&CHD(intLoop,CHindex))
       ELSE 
             IF MAX_PT > CHD(intLoop,CHindex) THEN
                  ' DO NOTHING
             ELSE
                  MAX_PT = CHD(intLoop,CHindex)
                  'msgbox ("Setting max values to "&CHD(intLoop,CHindex))
             END IF
             IF MIN_PT < CHD(intLoop,CHindex) THEN
                  ' DO NOTHING
             ELSE
                  MIN_PT = CHD(intLoop,CHindex)
                  'msgbox ("Setting max values to "&CHD(intLoop,CHindex))
             END IF
       END IF

    NEXT
    CHD(intLoop,"MAX_Trace") = MAX_PT
    CHD(intLoop,"MIN_Trace") = MIN_PT

NEXT