'-------------------------------------------------------------------------------
'-- VBS script file
'-- This script will create the S#P file.
'-- Load and execute Query TDM File 
Option Explicit         ' This setting requires explicit variable allocation in script.
AutoIgnoreError = 1     ' 1 turns off any error popups. 0 Enables popups

Dim FSO, FILEREF
DIM TDM_FILE, REPORT_DIRECTORY, REPORT_NAME
DIM VAR_T3, VAR_T4, VAR_T5, VAR_T6, VAR_T7, VAR_T8, VAR_T9, VAR_T10
DIM TestType, SerialNumber, ModelNumber, Filepathstring, Filenamestring, Filenameparts, TestRuns, RunName
DIM XYPointsStrings, Xpoints,Ypoints, X, tempstring,x_index,Y_index,count,binwidth
'ScriptInclude (AutoActPath&"\convert lvtime to string.vbs")
'ScriptInclude (AutoActPath&"\Load Channel.vbs")

' These T variable loads are for DEBUG
'T1  = "C:\Development\SPARTAN\data\tdm\S Parameter_20_63433.tdms"
'T2  = "C:\Development\SPARTAN\www\users\ssumjwest"
'T10 = "Run 1"


' These T variables are for the Spartan Script Engine to use.
TDM_FILE = T1           ' T1 is the TDM file to load for processing.
REPORT_DIRECTORY = T2   ' T2 has the report directory.  Put your report here.
RunName = T10           ' RunID or Group name In Storage Lingo

' Fake data for script development
'T3 =     "-64.640,1.000;"   
'T3 = T3 +"-59.707,2.000;"   
'T3 = T3 +"-54.774,1.000;"   
'T3 = T3 +"-49.842,20.000;"  
'T3 = T3 +"-44.909,55.000;"  
'T3 = T3 +"-39.976,174.00;"  
'T3 = T3 +"-35.043,490.000;" 
'T3 = T3 +"-30.111,1003.00;" 
'T3 = T3 +"-25.178,843.000;" 
'T3 = T3 +"-20.245,217.000;" 
'T3 = T3 +"-15.245,17.000;"  

'T4 = "S11 Log Mag"
'T5 = "dBm"
'T6 = "Model Number = 63433;" 
'T6 = T6 + "Serial Number = *;" 
'T6 = T6 +  "Number of Bins 10;"
'T6 = T6 + "Bin Width 4.933;"
'T7 = "Count"
VAR_T4 =   split(T4,":")  ' bin select: <channel>
if (ubound(var_t4) >0 ) then T4 = VAR_T4(1) end if
VAR_T5 =   split(T5,"(")  ' bin center(<unit>)
if (ubound(var_t5) >0 ) then 
   VAR_T6 =   split(VAR_T5(1),")") 
  T5 = VAR_T6(0)
end if '<unit>)

T6 = Replace(T6, ";", vbnewline)   

Randomize ' Initialize the Random number generator
   
   CALL DATADELALL(1)                     ' Delete all data in data portal
   ON ERROR RESUME NEXT
   
     '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ' vvvvvv Generate your Report vvvvv
   ' This example creates a text file based on the passed parameters.
   '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  REPORT_NAME = REPORT_DIRECTORY&"\Histogram_"&CStr(INT(65535*Rnd()))&".pdf"

   ' Create the File for the Report
  CALL PICLOAD(ROOT_PATH & "\scripts\histogram.tdr")   ' Load Requested Report
  'msgbox(T3)
  XYPointsStrings = split(T3,";")
  CALL ChnAlloc("X", ubound(XYPointsStrings), 1, DataTypeFloat64)  'Create destination FOR Data
  X_Index = CNo("X")
  
  CALL ChnAlloc("Y", ubound(XYPointsStrings), 1, DataTypeFloat64)  'Create destination FOR Data
  Y_Index = CNo("Y") 
  
  FOR X= 0 to  ubound(XYPointsStrings)-1
   'msgbox(XYPointsStrings(X))
    tempstring = split(XYPointsStrings(X),",")
    CHD(X+1,X_Index)= tempstring(0)
    xpoints(X)      = tempstring(0)
    CHD(X+1,Y_Index)= tempstring(1)
    ypoints(X)      = tempstring(1)
  NEXT
  count = ubound(XYPointsStrings)-1
  binwidth = Xpoints(1)-Xpoints(0)
  '------------------- Curve and axis definition ---------------------
  Call GraphObjOpen("2DAxis1")
        '------------------- Axis parameters --------------------------
        '------------------- X scaling --------------------------------
        Call GraphObjOpen("2DXAxis1_1")
          D2AxisXDivMode      = "linear"
          D2AxisXScaleType    = "complete automatic"
          D2AxisXTickDist     = "read from tick channel"
          D2AxisXTickChn      = "[1]/X"
          D2AxisXMiniTick     = 1
          D2AxisXTickType     = "both sides"
          D2AxisXTickChnN     = "[1]/X"
        Call GraphObjClose("2DXAxis1_1")
        '------------------- Y scaling --------------------------------
        Call GraphObjOpen("2DYAxis1_1")
          D2AxisYDivMode      = "linear"
          IF (instr(T7,"Percentage") = 0) THEN  ' Counts
                D2AxisYScaleType    = "complete automatic"
          ELSE                         ' Percentages 
                D2AxisYScaleType    = "begin/end manual"
                D2AxisYBegin        = 0
                D2AxisYEnd          = 100
                D2AxisYOrigin       = 0
                D2AxisYSpanWidth    = 100
          END IF
       Call GraphObjClose("2DYAxis1_1")
  Call GraphObjClose("2DAxis1")
   
  CALL PICUPDATE 
  CALL PICpdfexport(REPORT_NAME)  
   '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ' ^^^^^ END Generate your Report ^^^^^
   '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

T1 = REPORT_NAME   ' T1 must be set to the file path of the generated report.
'*****************************************************************
' END OF Script
'*****************************************************************