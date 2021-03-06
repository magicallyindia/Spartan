'-------------------------------------------------------------------------------
'VBS script file
'Created on 05/12/2011
'Author: Christopher Bauer
'-------------------------------------------------------------------------------
Option Explicit         'This setting requires explicit variable allocation in script.
Sub main()
  AutoIgnoreError = 1     '1 turns off any error popups. 0 Enables popups
  PicFrame        = 0     'Turn off frame around a plot

  ScriptInclude (AutoActPath&"\DD Lib.vbs") 'Common functions

  Dim bottom, fieldBottom, reportTDR, reportPath, plotCount, plot_orientation, pixelWidth, pixelHeight

  reportPath = Lookup("Report_Path", T3, "")
  plotCount = CInt(UPC(Lookup("Plot_count", T3, "1")))
  pixelWidth = 550
  pixelHeight = 792
  reportTDR = "Times C.tdr"

  Call PREPage_Processing(reportTDR, reportPath)

  'Fill in the header and any custom fields
  bottom = 16
  fieldBottom = Assign_Text_Fields(bottom, reportTDR)

  'These Calls move plot elements around based on number of custom fields
  Call Shift_Two_Plot(fieldBottom, bottom, "Portrait")

  'Refresh the plot
  If CInt(UPC(Lookup("Preview", T3, "0"))) = 1 Then
    Call GraphObjOpen("Plot1_X_Label")
    TxtTxt = UPC(Lookup("Plot1_Style", T3, "S Parameter")) & " Plot"
    Call GraphObjClose("Plot1_X_Label")
    Call GraphObjOpen("Plot2_X_Label")
    TxtTxt = UPC(Lookup("Plot2_Style", T3, "S Parameter")) & " Plot"
    Call GraphObjClose("Plot2_X_Label")
    Call PicUpdate
    Call PicExport(reportPath, "PNG", false, pixelHeight, pixelWidth, "RGB 24", , "NoCompression")  'Exports the current sheet as WMF file
    T7 = reportPath
  Else
    'Create each plot
    Call Create_Plot(1)
    Call Create_Plot(2)
    Call addTimesBoxes()
    Call POSTPage_Processing(reportTDR, reportPath)
  End If
  T1 = T7
End Sub

'-------------------------------------------------------------------------------
'This Function adds the Times boxes to the bottom of the datasheet.
'-------------------------------------------------------------------------------
Sub addTimesBoxes ()
  Dim timesVM, timesQA, VMTestStatus, VMOperator, QATestStatus, QAOperator, modelNumber, serialNumber, testSequence, channelStart, TempArray
  timesVM = Lookup("FieldID_1", T3, "") '"Visual & Mechanical" Set FieldID_1 in the template INI to the display name selected by Times For Visual & Mechanical
  timesQA = Lookup("FieldID_2", T3, "") '"Final QA" Set FieldID_2 in the template INI to the display name selected by Times For Final QA

  TempArray= Split(Lookup("Model_Number_txt", T3, ""), "::", -1, 1)
  modelNumber = escat(TempArray(1))
  
  TempArray= Split(Lookup("Serial_Number_txt", T3, ""), "::", -1, 1)
  serialNumber = escat(TempArray(1))
  
  TempArray= Split(Lookup("Test_Sequence", T3, ""), "::", -1, 1)
  testSequence = escat(TempArray(1))

  'SP Test Status
  Call GraphObjOpen("SP Test Status")
    TxtTxt = SAFE_grouppropget(ChnGroup(GlobUsedChn - 1), "Test_Status")
  Call GraphObjClose("SP Test Status")
  'SP Operator
  Call GraphObjOpen("SP Operator")
    TxtTxt = SAFE_grouppropget(ChnGroup(GlobUsedChn - 1), "Operator")
  Call GraphObjClose("SP Operator")

  channelStart = GlobUsedChn
  If channelStart > 0 Then
    channelStart = channelStart + 1
  End If

  'Add value to Visual & Mechanical
  Call Load_Channel(modelNumber, serialNumber, "Prompted Inputs", timesVM)
  If CNO(timesVM, channelStart) > 0 Then
    VMTestStatus = CHT(1, CNO(timesVM, channelStart))
    VMOperator = SAFE_grouppropget(ChnGroup(GlobUsedChn), "Operator")
  Else
    VMTestStatus = ""
    VMOperator = ""
  End If

  'VM Test Status
  Call GraphObjOpen("VM Test Status")
    TxtTxt = VMTestStatus
  Call GraphObjClose("VM Test Status")
  'VM Operator
  Call GraphObjOpen("VM Operator")
    TxtTxt = VMOperator
  Call GraphObjClose("VM Operator")

  'Add value to QA Approved
  Call Load_Channel(modelNumber, serialNumber, "Prompted Inputs", timesQA)
  If CNO(timesQA, channelStart) > 0 Then
    QATestStatus = CHT(1, CNO(timesQA, channelStart))
    QAOperator = SAFE_grouppropget(ChnGroup(GlobUsedChn), "Operator")
  Else
    QATestStatus = ""
    QAOperator = ""
  End If
  
  'QA Test Status
  Call GraphObjOpen("QA Test Status")
    TxtTxt = QATestStatus
  Call GraphObjClose("QA Test Status")
  'QA Operator
  Call GraphObjOpen("QA Operator")
    TxtTxt = QAOperator
  Call GraphObjClose("QA Operator")

  'Add serial number and test sequence barcodes
  Call GraphObjOpen("Serial Number Barcode")
  TxtTxt = "*" & serialNumber & "*"
  Call GraphObjClose("Serial Number Barcode")
  Call GraphObjOpen("Test Sequence Barcode")
  TxtTxt = "*" & testSequence & "*"
  Call GraphObjClose("Test Sequence Barcode")
End Sub