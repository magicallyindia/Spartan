'-------------------------------------------------------------------------------
'VBS script file
'Created on 06/20/2005
'Author: James West
'-------------------------------------------------------------------------------
Option Explicit         'This setting requires explicit variable allocation in script.
SUB main()
  AutoIgnoreError = 1     '1 turns off any error popups. 0 Enables popups
  PICFRAME        = 0     'Turn off frame around a plot

  ScriptInclude (AutoActPath&"\DD LIB.vbs") 'Common functions

  DIM px, bottom, fieldBottom, reportTDR, reportPath, plotCount, plot_orientation, pixelWidth, pixelHeight

  reportPath = Lookup("REPORT_PATH",T3,"")
  plotCount = CINT(UPC(Lookup("Plot_count",T3,"1")))
  pixelWidth = 550
  pixelHeight = 792

  SELECT CASE (plotCount)
    CASE 1
      reportTDR = "Times Report One Plot Portrait.tdr"
    CASE 2
      reportTDR = "Times Report Two Plot Portrait.tdr"
    CASE ELSE
      plotCount = 1
      reportTDR = "Times Report One Plot Portrait.tdr"
  END SELECT

  CALL PREPage_Processing(reportTDR, reportPath)

  'Fill in the header and any custom fields
  bottom = 16
  fieldBottom = Assign_Text_Fields(bottom, reportTDR)

  'These calls move plot elements around based on number of custom fields
  SELECT CASE UPC(reportTDR)
    CASE "TIMES REPORT ONE PLOT PORTRAIT.TDR"
      CALL shift_one_plot(fieldBottom, bottom)
    CASE "TIMES REPORT TWO PLOT PORTRAIT.TDR"
      CALL shift_two_plot(fieldBottom, bottom, "PORTRAIT")
  END SELECT

  'Refresh the plot
  IF CINT(UPC(Lookup("PREVIEW", T3, "0"))) = 1 THEN
    FOR px = 1 TO plotCount
      CALL GRAPHObjOpen("plot"&pX&"_X_Label")
      TXTTXT = UPC(Lookup("Plot"&pX&"_STYLE", T3, "S PARAMETER"))&" Plot"
      CALL GRAPHObjClose("plot"&pX&"_X_Label")
    NEXT
    CALL picupdate
    CALL PicExport(reportPath, "PNG", false, pixelHeight, pixelWidth, "rgb 24", , "NoCompression")  'Exports the current sheet as WMF file
    T7 = reportPath
  ELSE
    'Create each plot
    FOR px = 1 TO plotCount
      SELECT CASE UPC(Lookup("Plot"&pX&"_STYLE", T3, "S PARAMETER"))
        CASE "S PARAMETER"
          CALL Create_Plot(px)
      END SELECT
    NEXT
    CALL addTimesBoxes()
    CALL POSTPage_Processing(reportTDR, reportPath)
  END IF
  T1 = T7
END SUB

'-------------------------------------------------------------------------------
'This function adds the TIMES QA boxes to the bottom of the report.
'-------------------------------------------------------------------------------
SUB addTimesBoxes ()
  DIM timesVM, timesQA
  timesVM = Lookup("FieldID_1", T3, "") '"Visual & Mechanical" Set FieldID_1 in the template INI to the display name selected by Times for Visual & Mechanical
  timesQA = Lookup("FieldID_2", T3, "") '"Final QA" Set FieldID_2 in the template INI to the display name selected by Times for Final QA

  DIM VMText, VMUser, QAText, QAUser, MN, SN, channelStart,TempArray
  
  TempArray= Split(  Lookup("Model_Number_txt", T3, ""), "::", -1, 1)
  MN  = escat(TempArray(1))
  
  TempArray= Split(  Lookup("Serial_Number_txt", T3, ""), "::", -1, 1)
  SN  = escat(TempArray(1))

  'Add value to Electrical box
  CALL add_text("EResult", SAFE_grouppropget(ChnGroup(GLOBUSEDCHN - 1), "Test_Status"), 16, 12)
  CALL add_text("EResultUser", SAFE_grouppropget(ChnGroup(GLOBUSEDCHN - 1), "Operator"), 16, 10)

  channelStart = GlobUsedChn
  IF channelStart > 0 THEN
    channelStart = channelStart + 1
  END IF

  'Add value to Visual & Mechanical box
  CALL Load_Channel(MN, SN, "Prompted Inputs", timesVM)
  IF CNO(timesVM, channelStart)> 0 THEN
    VMText = CHT(1, CNO(timesVM, channelStart))
    VMUser = SAFE_grouppropget(ChnGroup(GLOBUSEDCHN), "Operator")
  ELSE
    VMText = ""
    VMUser = ""
  END IF
  CALL add_text("VMResult", VMText, 47, 12)
  CALL add_text("VMResultUser", VMUser, 47, 10)

  'Add value to Final QA box
  CALL Load_Channel(MN, SN, "Prompted Inputs", timesQA)
  IF CNO(timesQA, channelStart)> 0 THEN
    QAText = CHT(1, CNO(timesQA, channelStart))
    QAUser = SAFE_grouppropget(ChnGroup(GLOBUSEDCHN), "Operator")
  ELSE
    QAText = ""
    QAUser = ""
  END IF
  CALL add_text("QAResult", QAText, 78, 12)
  CALL add_text("QAResultUser", QAUser, 78, 10)
END SUB