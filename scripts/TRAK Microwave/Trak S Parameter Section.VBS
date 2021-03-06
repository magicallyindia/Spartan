'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 06/20/2005 15:46:14
'-- Author: J. Brunner
'-- Comment: Sets up a Spartan S Parameter Data Section
'-------------------------------------------------------------------------------
Option Explicit

' Load Spartan Report Routines
Call ScriptInclude("Spartan Report Routines.vbs")

'--------------------------------------------------------------------------------
'   Text Formatting for this layout...
'--------------------------------------------------------------------------------
Dim PlotTitle, RunLabel
Dim FstartLabel, FstopLabel
Dim Ch1Label, Cal1Label
Dim Ch2Label, Cal2Label
Dim PFLabel

Set PlotTitle = New TextClass
With PlotTitle
  .RelPos = "bottom"
  .Size   = 2.0
  .Frame  = False
  .Font   = "Verdana"
  .Bold   = True
  .Italic = False
  .Color  = "black"
End With

Set RunLabel = New TextClass
With RunLabel
  .RelPos = "bottom"
  .Size   = 1.8
  .Frame  = False
  .Font   = "Verdana"
  .Bold   = True
  .Italic = False
  .Color  = "black"
End With

Set FstartLabel = New TextClass
With FstartLabel
  .RelPos = "r-bot"
  .Size   = 1.4
  .Frame  = False
  .Font   = "Verdana"
  .Bold   = False
  .Italic = False
  .Color  = "black"
End With

Set FstopLabel = New TextClass
With FstopLabel
  .RelPos = "l-bot"
  .Size   = 1.4
  .Frame  = False
  .Font   = "Verdana"
  .Bold   = False
  .Italic = False
  .Color  = "black"
End With

Set Ch1Label = New TextClass
With Ch1Label
  .RelPos = "r-top"
  .Size   = 1.2
  .Frame  = False
  .Font   = "Verdana"
  .Bold   = False
  .Italic = False
  .Color  = "black"
End With

Set Ch2Label = New TextClass
With Ch2Label
  .RelPos = "r-bot"
  .Size   = 1.2
  .Frame  = False
  .Font   = "Verdana"
  .Bold   = False
  .Italic = False
  .Color  = "blue"
End With

Set Cal1Label = New TextClass
With Cal1Label
  .RelPos = "l-top"
  .Size   = 1.2
  .Frame  = False
  .Font   = "Verdana"
  .Bold   = False
  .Italic = False
  .Color  = "black"
End With

Set Cal2Label = New TextClass
With Cal2Label
  .RelPos = "l-bot"
  .Size   = 1.2
  .Frame  = False
  .Font   = "Verdana"
  .Bold   = False
  .Italic = False
  .Color  = "blue"
End With

Set PFLabel = New TextClass
With PFLabel
  .RelPos = "l-bot"
  .Size   = 3.0
  .Frame  = False
  .Font   = "Verdana"
  .Bold   = True
  .Italic = False
  .Color  = "white"
End With

'--------------------------------------------------------------------------------
'   Plot Trace Formatting for this layout...
'--------------------------------------------------------------------------------
Dim Ch1Data, Ch1ULim, Ch1LLim, Ch1Fail
Dim Ch2Data, Ch2ULim, Ch2LLim, Ch2Fail

Set Ch1Data = New Trace
With Ch1Data
  .Color     = "dark grey"
  .LineType  = "solid"
  .LineWidth = "0.7"
  .MarkType  = "none"
  .MarkColor = "black"
  .MarkSize  = .1
End With

Set Ch1Fail = New Trace
With Ch1Fail
  .Color     = "red"
  .LineType  = "solid"
  .LineWidth = "min"
  .MarkType  = "circle"
  .MarkColor = "red"
  .MarkSize  = 1
End With

Set Ch1ULim = New Trace
With Ch1ULim
  .Color     = "dark grey"
  .LineType  = "solid"
  .LineWidth = "0.7"
  .MarkType  = "none"
  .MarkColor = "black"
  .MarkSize  = 1
End With

Set Ch1LLim = New Trace
With Ch1LLim
  .Color     = "dark grey"
  .LineType  = "solid"
  .LineWidth = "0.7"
  .MarkType  = "none"
  .MarkColor = "black"
  .MarkSize  = 1
End With

Set Ch2Data = New Trace
With Ch2Data
  .Color     = "blue"
  .LineType  = "solid"
  .LineWidth = "0.25"
  If Eval(TDM("UseSyms", "FALSE")) Then
    .MarkType  = "circle"
  Else
    .MarkType  = "none"
  End If
  .MarkColor = "blue"
  .MarkSize  = 1
End With

Set Ch2Fail = New Trace
With Ch2Fail
  .Color     = "red"
  .LineType  = "solid"
  .LineWidth = "min"
  If Eval(TDM("UseSyms", "FALSE")) Then
    .MarkType  = "triangle"
  Else
    .MarkType  = "none"
  End If  
  .MarkColor = "red"
  .MarkSize  = 1
End With

Set Ch2ULim = New Trace
With Ch2ULim
  .Color     = "blue"
  .LineType  = "solid"
  .LineWidth = "0.7"
  .MarkType  = "none"
  .MarkColor = "blue"
  .MarkSize  = 1
End With

Set Ch2LLim = New Trace
With Ch2LLim
  .Color     = "blue"
  .LineType  = "solid"
  .LineWidth = "0.7"
  .MarkType  = "none"
  .MarkColor = "blue"
  .MarkSize  = 1
End With


'--------------------------------------------------------------------------------
'   Begin Main Program
'--------------------------------------------------------------------------------
'  Add in a Report Section which draws Title, Run, and Pass/Fail Status
'  Report Layout must have already defined "RS0" (all positioning is
'  relative to RS0).
Call SetCoordsRel("RS0", 0, 0, 0, 0)

'  Call DrawText("Title", PlotTitle, TDM("PlotTitle", "Plot Title"),    50.00,  1.00)
'  Call DrawText("Run", RunLabel,  TDM("RunLabel", ""), 50.00,  4.00)
'  Call DrawPFLabel(TDM("registertxt1", "FAIL"),  99.50,  0.50)

  Dim plots ' counts number of plots
  Select Case Ucase(TDM("Plots", "QUAD")) ' SINGLE, DOUBLE, or QUAD; default is SINGLE
    Case "SINGLE"
      '  This puts a single large plot
      Call AddDataSection(1.00, 9.00, 98.00, 90.00, True)      ' single big plot
      plots = 1

    Case "DOUBLE"
      '  This will draw two plots (over/under):
      Call AddDataSection(1.00,  9.00, 98.00, 44.50, True)     ' top plot
      Call AddDataSection(1.00, 54.50, 98.00, 44.50, True)     ' bottom plot
      plots = 2

    Case "QUAD"
      '  This will draw four plots (quad):
      Call AddDataSection( 1.00,  1.00, 48.50, 44.50, True)    ' top-left plot
      Call AddDataSection(50.50,  1.00, 48.50, 44.50, True)    ' top-right plot
      Call AddDataSection( 1.00, 50.50, 48.50, 44.50, True)    ' lower-left plot
      Call AddDataSection(50.50, 50.50, 48.50, 44.50, True)    ' lower-right plot
      plots = 4

    Case Else ' SINGLE
      '  This puts a single large plot
      Call AddDataSection(1.00, 9.00, 98.00, 90.00, True)      ' single big plot
      plots = 1

End Select

Call UnSetCoords()  ' done with relative positioning

'  Add in Plots for each DataSections Frame above
Dim P(), i

For i = 0 to plots - 1

  ReDim Preserve P(1, i)
 
  Set  P(0, i) = New ChParams ' new channel parameters for trace 1
  With P(0, i)
    Select Case i
      Case 0
        .Sxx       = TDM("P" & i + 1 & "Ch1Sxx", "S11")
      Case 1
        .Sxx       = TDM("P" & i + 1 & "Ch1Sxx", "S12")
      Case 2
        .Sxx       = TDM("P" & i + 1 & "Ch1Sxx", "S21")
      Case 3
        .Sxx       = TDM("P" & i + 1 & "Ch1Sxx", "S22")
      Case Else
    End Select
    .SxxFormat = TDM("P" & i + 1 & "Ch1SxxFormat", "LOG MAG")
    .RefP      = Val(TDM("P" & i + 1 & "Ch1RefP", "5"))
    .RefV      = Val(TDM("P" & i + 1 & "Ch1RefV", "0"))
    .Scale     = val(TDM("P" & i + 1 & "Ch1Scale", "10"))
    .Auto      = TDM("P" & i + 1 & "Ch1Auto", "FALSE")
    .Syms      = TDM("P" & i + 1 & "Ch1Syms", "FALSE")
  End With

  Set P(1, i) = New ChParams ' new channel parameters for trace 2
'  With P(1, i)
'    .Sxx       = TDM("P" & i + 1 & "Ch2Sxx", "S21")
'    .SxxFormat = TDM("P" & i + 1 & "Ch2SxxFormat", "LOG MAG")
'    .RefP      = Val(TDM("P" & i + 1 & "Ch2RefP", "5"))
'    .RefV      = Val(TDM("P" & i + 1 & "Ch2RefV", "0"))
'    .Scale     = Val(TDM("P" & i + 1 & "Ch2Scale", "10"))
'    .Auto      = TDM("P" & i + 1 & "Ch2Auto", "FALSE")
'    .Syms      = TDM("P" & i + 1 & "Ch2Syms", "FALSE")
'  End With

  Call Add2ChSparamPlot(i, gTDMRun, TDM("FreqUnits", "MHz"), P(0, i), P(1, i))
Next

Call PicUpdate() 
'------------------------------------------------------------------------------
'   End Main Program
'------------------------------------------------------------------------------


'------------------------------------------------------------------------------
'  ChParams
'  This class used to hold plot parameters for a display channel
Class ChParams
  Private s, sformat, srefp, srefv, sscale, sauto, ssyms

  Property Get Sxx()
    Sxx = s
  End Property
  Property Let Sxx(snew)
    s = snew
  End Property
  
  Property Get SxxFormat()
    SxxFormat = sformat
  End Property
  Property Let SxxFormat(fnew)
    sformat = fnew
  End Property

  Property Get RefP()
    RefP = srefp
  End Property
  Property Let RefP(rpnew)
    srefp = rpnew
  End Property

  Property Get RefV()
    RefV = srefv
  End Property
  Property Let Refv(rvnew)
    srefv = rvnew
  End Property

 Property Get Scale()
    Scale = sscale
  End Property
  Property Let Scale(scalenew)
    sscale = scalenew
  End Property

  Property Get Auto()
    Auto = sauto
  End Property
  Property Let Auto(anew)
    sauto = anew
  End Property

  Property Get Syms()
    Syms = ssyms
  End Property
  Property Let Syms(snew)
    ssyms = snew
  End Property

End Class


'------------------------------------------------------------------------------
'   Subroutines
'------------------------------------------------------------------------------


'------------------------------------------------------------------------------
'  Add2ChSparamPlot(...)
'  This is the main S-P plot layout routine
'  Everything is scaled to fit within "frame" object (it must already exist)
'  Underlying TDM file must have already been loaded
Sub Add2ChSparamPlot(FrameNo, run, funits, Ch1, Ch2)

  Dim PCh1, PCh2
  Dim FCh
  Dim ptitle

  FCh  = "[" & run & "]/Frequency"

  ' Set positioning relative to the "DS0" box
  ' (these DataSections were created at the top of this script)
  Call SetCoordsRel("DS" & FrameNo, 0, 0, 0, 0)

    ' If there's a valid Sxx on the Display Channel then
    '   1)   Draw the first display channel
    '   2)   Add the Channel Data Traces 
    '   3)   Scale the plot y-axes
    '   4)   Read back the values (to handle Autoscaling)
    '   5)   Add reference lines
    '   6)   Add the channel description scale/ref unit strings
    '   7)   Add the calibration state text
    
    If Ch1.Sxx <> "" Then    
      PCh1 = Draw2DPlot("P" & FrameNo & "Ch1", 2.00, 2.00, 96.00, 96.00, FCh, funits, True)
      Call AddPlotDataChannel(PCh1, FCh, funits, Ch1.Sxx, Ch1.SxxFormat)
      Call Scale2DAxes(PCh1, Ch1.RefP, Ch1.RefV, Ch1.Scale, Ch1.Auto)
      Call Read2DAxesScale(PCh1, Ch1.RefP, Ch1.RefV, Ch1.Scale)
      Call Add2DAxesRef(PCh1, Ch1.RefP, True)
      Call DrawChLabel(1, Ch1.Sxx, Ch1.SxxFormat, Ch1.Scale, Ch1.RefV, 2.00, 2.00)
      Set ptitle = New TextClass
      With ptitle
        .RelPos = "l-top"
        .Size   = 2.5
        .Frame  = False
        .Font   = "Verdana"
        .Bold   = True
        .Italic = False
        .Color  = "dark grey"
      End With

      Select Case Ucase(Ch1.Sxx)
        Case "S11"
          Call DrawText("pt1", ptitle, "Port 1 Return Loss", 100.00, 2.00)
        Case "S12"
          Call DrawText("pt2", ptitle, "Isolation", 100.00, 2.00)
        Case "S21"
          Call DrawText("pt3", ptitle, "Insertion Loss", 100.00, 2.00)
        Case "S22"
          Call DrawText("pt4", ptitle, "Port 2 Return Loss", 100.00, 2.00)
        Case Else
      End Select
   
 '     Call DrawCalLabel(1, Ch1.Sxx, 95.00, 6.50)
    End If

    If Ch2.Sxx <> "" Then
      PCh2 = Draw2DPlot("P" & FrameNo & "Ch2", 10.00, 10.00, 80.00, 80.00, FCh, funits, False)  
      Call AddPlotDatachannel(PCh2, FCh, funits, Ch2.Sxx, Ch2.SxxFormat)
      Call Scale2DAxes(PCh2, Ch2.RefP, Ch2.RefV, Ch2.Scale, Ch2.Auto)
      Call Read2DAxesScale(PCh2, Ch2.RefP, Ch2.RefV, Ch2.Scale)
      Call Add2DAxesRef(PCh2, Ch2.RefP, False)
      Call DrawChLabel(2, Ch2.Sxx, Ch2.SxxFormat, Ch2.Scale, Ch2.RefV, 5.00, 6.50)
      Call DrawCalLabel(2, Ch2.Sxx, 95.00, 6.50)
    End If

  Call UnSetCoords()       ' Done setting relative coords

End Sub



'------------------------------------------------------------------------------
' FormatCalText(ChName)
'  This function reads the hard-coded "registerint2" for the calibration
'  state saved by the S Parameter test and converts it to a string value
FUNCTION FormatCalText(ChName)

  DIM c

  If ChanExists(ChName) Then
    c = ChnPropGet(ChName, "registerint2")

    Select Case c
        Case 0
          FormatCalText = "No Cal"
        Case 1
          FormatCalText = "Resp"
        Case 2
          FormatCalText = "Resp & Isol"
        Case 3
          FormatCalText = "Full 1-Port"
        Case 4
          FormatCalText = "Full 1-Port"
        Case 5
          FormatCalText = "Full 2-Port"
        Case 6
          FormatCalText = "One Path 2-Port"
        Case 7
          FormatCalText = "TRL/LRM 2-Port"
        Case Else
          FormatCalText = ""    
     End Select
  Else
    FormatCalText = ""
  End If
End Function


'------------------------------------------------------------------------------
'  Draws a 2D two-channel plot
'    name   : user-defined plot name
'    x      : x position % from left
'    y      : y position % from top
'    width  : width as % of parent width
'    height : height as % of parent height
Function Draw2DPlot(name, x, y, width, height, xchan, xunits, grid)

  Dim FstartLbl, FstartTxt, FstopLbl, FstopTxt
  Dim PFLbl
  Dim fstart, fstop

  ' These are some convenience variables to shorten
  ' the calls below.  They will hold the display-formatted
  ' values for frequency and Y scale ranges
  fstart = FormatFreq(ChnValMin(CNo(xchan)), xunits)
  fstop  = FormatFreq(ChnValMax(CNo(xchan)), xunits)

  ' Add the 2D Axis and then Scale it appropriately
  ' Potential Autoscaling forces a Read2DAxesScale to update
  ' the scaling parameters.
  name = Draw2DAxes(name, x, y, width, height, fstart, fstop, grid)

  FstartTxt = "Start " & Str(fstart, "d.dddddd") & " " & xunits
  FstartLbl = DrawText("Fstart", FstartLabel, FstartTxt, x, y + height + 1)

  FstopTxt = "Stop " & Str(fstop, "d.dddddd") & " " & xunits
  FstopLbl = DrawText("Fstop", FstopLabel, FstopTxt, x + width, y + height + 1)

  Draw2DPlot = name
End Function


'------------------------------------------------------------------------------
' DrawPFLabel(...) - Adds and colors Pass/Fail text box
Function DrawPFLabel(pftext, x, y)

  Dim PFLbl

  PFLbl = DrawText("PF", PFLabel, Ucase(pftext), x, y)
  GraphObjOpen(PFLbl)
    Select Case UCase(pftext)
      Case "FAIL"
        TxtBackColor = "red"
      Case "PASS"
        TxtBackColor = "green"
      Case Else
        TxtBackColor = "dark grey"
    End Select
  GraphObjClose(PFLbl)

  DrawPFLabel = PFLbl
End Function

'------------------------------------------------------------------------------
' DrawChLabel(...)
' Adds a channel description string:
' CHX SXX     log MAG     X dB/ REF X dB Cal State
Function DrawChLabel(ChNo, Sxx, ChFormat, ChScale, ChRefV, x, y)

  Dim chlbl, slbl, flbl, sclbl, reflbl, catlbl, dcl
                                                                      ' e.g. (spaces= "." for visibility)
  chlbl  = "CH" & ChNo & Chr(32)                                      '      CH1. 
  slbl   = Sxx & "     "                                              '      S11.....
  flbl   = ChFormat & "     "                                         '      log MAG.....
  sclbl  = Str(ChScale, "d.d") & "  " & GetScaleUnits(ChFormat) & "/  " '    10..dB/..
  reflbl = "REF " & Str(ChRefV, "d.d") & " " & GetScaleUnits(ChFormat)  '    REF.0.dB
  
  catlbl = chlbl & slbl & flbl & sclbl & reflbl

  If ChNo = 1 Then
    DrawChLabel = DrawText("ChLbl", Ch1Label, catlbl, x, y)
  Else
    DrawChLabel = DrawText("ChLbl", Ch2Label, catlbl, x, y)
  End If

End Function



'------------------------------------------------------------------------------
' DrawCalLabel(...)
' Adds a calibration label to the channel
Function DrawCalLabel(ChNo, Sxx, x, y)
  Dim corlbl

  corlbl = FormatCalText(Sxx & " Mag") ' mag data channel will hold cal state

  If ChNo = 1 Then
    DrawCalLabel = DrawText("CalLbl", Cal1Label, corlbl, x, y)
  Else
    DrawCalLabel = DrawText("CalLbl", Cal2Label, corlbl, x, y)
  End If
End Function
'------------------------------------------------------------------------------
'  Adds a "Data Channel" to an existing plot axes
'  Each data channel consists of up to four traces:
'    trace 0 : data
'    trace 1 : upper limit
'    trace 2 : lower limit
'    trace 3 : limit failures (not implemented yet)
Sub AddPlotDataChannel(PlotId, FreqChan, FreqUnits, Sxx, SxxFormat)

Dim XChName

  If Sxx <> "" Then  ' don't do nuttin' if no parameter

    ' Open Plot for the requested Y-channel axis
    Call GraphObjOpen(PlotId) 

      ' Figure out the Frequency Channel (x-axis)
      XChName = FormatFreqCh(FreqChan, FreqUnits)

      ' Add Data, Upper Limit, Lower Limit, and Failures traces:

      If Right(PlotId, 1) = "1" Then
        Call AddTraceToPlot(PlotId & "data", Ch1Data, XChName, FormatSxxCh(Sxx, SxxFormat, ""))
        Call AddTraceToPlot(PlotId & "ulim", Ch1ULim, XChName, FormatSxxCh(Sxx, SxxFormat, "ulim"))
        Call AddTraceToPlot(PlotId & "llim", Ch1LLim, XChName, FormatSxxCh(Sxx, SxxFormat, "llim"))
       'Call AddTraceToPlot(PlotId & "fail", Ch1Fail, XChName, FormatSxxCh(Sxx, SxxFormat, "fail"))
      Else
        Call AddTraceToPlot(PlotId & "data", Ch2Data, XChName, FormatSxxCh(Sxx, SxxFormat, ""))
        Call AddTraceToPlot(PlotId & "ulim", Ch2ULim, XChName, FormatSxxCh(Sxx, SxxFormat, "ulim"))
        Call AddTraceToPlot(PlotId & "llim", Ch2LLim, XChName, FormatSxxCh(Sxx, SxxFormat, "llim"))
       'Call AddTraceToPlot(PlotId & "fail", Ch2Fail, XChName, FormatSxxCh(Sxx, SxxFormat, "fail"))
      End If

    Call GraphObjClose(PlotId)

  End If
End Sub


'------------------------------------------------------------------------------
' FormatFreq(Freq, FreqUnits)
'   Freq      :    Input Frequency in MHz
'   FreqUnits :    Freq units to transform the  freq channel into
' Formats a frequency channel in terms of the default
' frequency channel storage units (MHz), and returns
' the name of the frequency channel to use
Function FormatFreq(Freq, FreqUnits)

  Select Case Ucase(FreqUnits)

    Case "HZ"
      FormatFreq = Freq * 100000

    Case "KHZ"
      FormatFreq = Freq * 1000

    Case "MHZ" ' no transform required 
      FormatFreq = Freq

    Case "GHZ"
      FormatFreq = Freq * .001

    Case Else  ' unknown units - return original
    FormatFreq   = Freq

  End Select
End Function


'------------------------------------------------------------------------------
' FormatFreqCh(FreqChName, FreqUnits)
'   FreqChId  :    Identifier of the channel to be interpreted as Freq in MHz
'   FreqUnits :    Freq units to transform the named freq channel into
' Formats a frequency channel in terms of the default
' frequency channel storage units (MHz), and returns
' the name of the frequency channel to use
Function FormatFreqCh(FreqChId, FreqUnits)

  Select Case Ucase(FreqUnits)

    Case "HZ"
      Call FormulaCalc("Ch('" & FreqChId & FreqUnits & "'):= 1000000*('" & FreqChId & "')")
      FormatFreqCh = FreqChId & FreqUnits

    Case "KHZ"
      Call FormulaCalc("Ch('" & FreqChId & FreqUnits & "'):= 1000*('" & FreqChId & "')")
      FormatFreqCh = FreqChId & FreqUnits

    Case "MHZ" ' no transform required 
      FormatFreqCh = FreqChId

    Case "GHZ"
      Call FormulaCalc("Ch('" & FreqChId & FreqUnits & "'):= .001*('" & FreqChId & "')")
      FormatFreqCh = FreqChId & FreqUnits

    Case Else  ' unknown units - return original
    FormatFreqCh = FreqChId

  End Select
End Function


Function GetScaleUnits(Format)
 
  Select Case Ucase(Format)

    Case "LOG MAG"
      GetScaleUnits = "dB"

    Case "LIN MAG"
      GetScaleUnits = "U"

    Case "SWR", "VSWR"
      GetScaleUnits = ""

    Case "LOSS"
      GetScaleUnits = "dB"

    Case "PHASE"
      GetScaleUnits = "°"

    Case "DELAY"
      GetScaleUnits = "sec"

    Case Else
      GetScaleUnits = Format ' pass back value for unknown
  End Select

End Function


Function FormatSxx(Sxx, ChFormat)
  
  Select Case Ucase(ChFormat)

    Case "LOG MAG"
      FormatSxx = 20*Log10(Abs(Sxx))

    Case "LIN MAG"
      FormatSxx = Sxx

    Case "SWR", "VSWR"
      FormatSxx = (1 + Abs(Sxx)) / (1 - Abs(Sxx))

    Case "LOSS"
      FormatSxx = -20*Log10(Abs(Sxx))

    Case "PHASE"
      FormatSxx = Sxx

    Case "DELAY"
      FormatSxx = Sxx ' no single-point delays!

    Case Else
      FormatSxx = Sxx ' pass back value for unknown
  End Select

End Function


Function FormatSxxCh(Sxx, ChFormat, Limit)

  Dim ChIdStr

  Select Case Ucase(ChFormat)
    Case "PHASE", "DELAY"
      ChIdStr = Sxx & " Phase"
    Case Else
      ChIdStr = Sxx & " Mag"
  End Select

  Select Case Ucase(Limit)
    Case "ULIM"
      ChIdStr = ChIdStr & " ULimit"
    Case "LLIM"
      ChIdStr = ChIdStr & " LLimit"
    Case Else
  End Select

  FormatSxxCh = ""
  ' Underlying channel must exist for calculations...
  If ChanExists(ChIdStr) Then
    
    Select Case Ucase(ChFormat)

      Case "LOG MAG" 
        Call FormulaCalc("Ch('" & ChIdStr & "_" & ChFormat & "'):= 20*Log('" & ChIdStr & "')")
        FormatSxxCh = ChIdStr & "_" & ChFormat

      Case "LIN MAG"
        FormatSxxCh = ChIdStr

      Case "SWR", "VSWR"
        Call FormulaCalc("Ch('" & ChIdStr & "_" & ChFormat & "'):= (1 + Abs('" & ChIdStr & "')) / (1 - Abs('" & ChIdStr & "'))")
        FormatSxxCh = ChIdStr & "_" & ChFormat

      Case "LOSS"
        Call FormulaCalc("Ch('" & ChIdStr & "_" & ChFormat & "'):= -20*Log('" & ChIdStr & "')")
        FormatSxxCh = ChIdStr & "_" & ChFormat

      Case "PHASE"
        FormatSxxCh = ChIdStr

      Case "DELAY"
        FormatSxxCh = ChIdStr

      Case Else
        FormatSxxCh = ChIdStr
    End Select

  End If ' If ChanExists

End Function