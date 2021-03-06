'-------------------------------------------------------------------------------
'-- Spartan VBS script file
'-- Created on 04/19/2013 14:11:30
'-- Author: James Brunner
'-- Comment: Pre- and Post-page report processing (formerly held within DD LIB.vbs)
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.
AutoIgnoreError = 1     ' 1 turns off any error popups. 0 Enables popups

Call Subsequence("DD Library PageProcessing") ' makes sure this script is not called standalone

' report globals
Const FONT_FAMILY = "Calibri"
Const TEXT_SIZE = 1.6    
Const LABEL_BOLD_FONT = True

Dim STATUS_PASS_COLOR_RGB, STATUS_FAIL_COLOR_RGB
STATUS_PASS_COLOR_RGB = RGB(108, 176, 66) ' Kaelus Green
STATUS_FAIL_COLOR_RGB = RGB(176, 37, 47) ' Kaelus Red

' Process page with general items before continuing to gerenate the datasheet.
Sub PrePageProcessing(reportTDR, reportPath, stage, pageWidth, pageHeight)
    
    Call Debug(CurrentScriptName, "Pre-processing page (stage " & stage & "): " & reportTDR & " (" & pageWidth & " x " & pageHeight & ")")
  
    Select Case UpC(stage)
        Case "NEW"
            Call PicDelete ' Delete any existing report
            Call DataDelAll(1)
            L1 = 1 ' Page Number
            PrintName = "winspool, DIAdem PDF Export, LPT1:"
            PDFFileName = reportPath
            T7 = reportPath

            ' delete the old PDF file, if it exists
            If FileExist(PDFFileName) Then Call FileDelete(PDFFileName)

            ' set some PDF parameters
            PDFResolution = "150 DPI"  '  "2400 DPI" ,  "DEFAULT"
            PDFOptimization = True
            PDFFontsEmbedded = False
            PDFJPGCompressed = "high"
        
            Call WndShow("Report")
            Call DocStart ' Begin multi-page document/print job
            Call PicLoad(reportTDR)   ' Load Requested Report

            ' Set document margins
            PrintTopMarg  = 0.25
            PrintLeftMarg = 0.25
            If (pageWidth > pageHeight) Then
                PrintWidth    = 10.5
                PicRatio      = 0.76
                Call PrintMaxScale("Report")
            Else
                PrintWidth    = 8
                PicRatio      = 1.31
            End If

            Call Debug(CurrentScriptName, "  margin[top, left] = [" & PrintTopMarg & ", " & PrintLeftMarg & "], pageWidth = " & PrintWidth & ", picRatio = " & PicRatio)

            Call GraphSheetNGet(1)
            Call GraphSheetRename(GraphSheetName, "Spartan Datasheet " & L1)

        Case "APPEND", "DONE"
            L1 = L1 + 1 ' update page number
            Call PicLoad(reportTDR )   ' Load Requested Report

            ' Set document margins
            PrintTopMarg  = 0.25
            PrintLeftMarg = 0.25
            If (pageWidth > pageHeight) Then
                PrintWidth = 10.5
                PicRatio = 0.76
                Call PrintMaxScale("Report")
            Else
                PrintWidth = 8
                PicRatio = 1.31
            End If

            Call Debug(CurrentScriptName, "  margin[top, left] = [" & PrintTopMarg & ", " & PrintLeftMarg & "], pageWidth = " & PrintWidth & ", picRatio = " & PicRatio)

            Call GraphSheetNGet(1)
            Call GraphSheetRename(GraphSheetName, "Spartan Datasheet " & L1)

        Case "PDF"
            Call PicDelete ' Delete any existing report
            Call DataDelAll(1)
            L1 = 1
            If reportTDR <> "" Then Call PicLoad(reportTDR)   ' Load Requested Report

        Case Else
            ' DO NOTHING - ERROR
            
    End Select
End Sub


' post-process the report page after plots/graphics/etc have been added
Sub PostPageProcessing(reportTDR, reportPath, stage)
    
    Dim templateId
    
    ' at what stage of report generation are we?
    templateId = Lookup("sxTemplateId", T3, "NOT FOUND")
    
    Call Debug(CurrentScriptName, "Post-processing page (stage " & stage & "): " & reportTDR) 
    Call Debug(CurrentScriptName, "  margin[top, left] = [" & PrintTopMarg & ", " & PrintLeftMarg & "], pageWidth = " & PrintWidth & ", picRatio = " & PicRatio)  

    Call CreatePageFooter(templateId)

    Call PicUpdate
    
    Select Case UpC(stage)
    
        Case "NEW","APPEND"
            Call PicPrint("WinPrint")  ' Add a page to be printed
        
        Case "DONE"
            PDFFileName = T7
            Call PicPrint("WinPrint")  ' Add a page to be printed
            Call DocEnd   ' End multi-page document/print job
            Call Debug(CurrentScriptName, "Done processing: " & PDFFileName)
        
        Case "PDF"
            Call PicPDFExport(reportPath)
            Call Debug(CurrentScriptName, "====== PDF saved: " & reportPath)
            T7 = reportPath

        Case Else
            ' DO NOTHING - ERROR
    End Select
End Sub


' adjusts the plot positions based on header field entry sizes
Sub ShiftPlots(count, plotTop, plotBottom, orient)

    Select Case count            
        Case 2
            Call ShiftTwo(plotTop, plotBottom, orient)
    
        Case 4
            Call ShiftFour(plotTop, plotBottom, orient)
            
        Case Else ' 1 plot is default
            Call ShiftOne(plotTop, plotBottom)
    End Select 

End Sub

Sub ShiftOne(top, bottom)
    'TOP = 72 
    'BOTTOM = 5.38  '17 For TIMES REPORT

    Dim  leftSide, rightSide, middle, height, halfHeight
    Call Debug(CurrentScriptName, "shifting ONE plot....")

    leftSide = 5
    rightSide = 4

    height = top - bottom
    halfHeight = height/2
    middle = top - halfHeight

    Call GraphObjOpen("plot1_X_Label")
        TxtPosX   = 52
        TxtPosY   = bottom
        TxtAng    = 0
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("plot1_X_Label")

    Call GraphObjOpen("plot1_Y_Label")
        TxtPosX   = 4
        TxtPosY   = bottom + halfHeight
        TxtAng    = 90
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("plot1_Y_Label")

    Call GraphObjOpen("2DAxis1")
        D2AxisTop     = 100 - (top - 4.5)
        D2AxisBottom  = bottom + .1 * halfHeight
        D2AxisLeft    = 12
        D2AxisRight   = 4
        D2LegSizeGlX  = 84
        D2LegPSizeGlY = 2
        D2LegPosX     = 12
        D2LegPosY     = top - 0.5
        D2LegMove     = "automatic"
        D2LegRelPos   = "top left"
    Call GraphObjClose("2DAxis1")

    Call Debug(CurrentScriptName, "...done shifting ONE plot")
End Sub

Sub ShiftTwo(top, bottom, orient)

    Dim  leftSide, rightSide, middle, height, halfHeight
    Call Debug(CurrentScriptName, "shifting TWO plot....")

    leftSide = 12
    rightSide = 4

    If UpC(orient) = "LANDSCAPE" Then
        leftSide = 10
        rightSide = 4
    End If

    height = top - bottom
    halfHeight = height/2
    middle = top - halfHeight

    Call GraphObjOpen("plot1_X_Label")
        TxtPosX   = leftSide + 0.5*(100 - leftSide - rightSide)
        TxtPosY   = middle
        TxtAng    = 0
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("plot1_X_Label")

    Call GraphObjOpen("plot1_Y_Label")
        TxtPosX   = 4
        TxtPosY   = middle + .5 * halfHeight
        TxtAng    = 90
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("plot1_Y_Label")

    Call GraphObjOpen("2DAxis1")
        D2AxisTop    = 100 - (top - 6)
        D2AxisBottom = middle + .1 * halfHeight
        D2AxisLeft   = leftSide
        D2AxisRight  = rightSide
        D2LegSizeGlX = 100 - leftSide - rightSide
        D2LegPosX    = leftSide
        D2LegPosY    = top - 0.5
        D2LegMove    = "automatic"
        D2LegRelPos  = "top left"
    Call GraphObjClose("2DAxis1")

    '+++++++++++++++++++++++++++

    Call GraphObjOpen("2DAxis2")
        D2AxisTop    = 100 - (middle - 6)
        D2AxisBottom = bottom + .1 * halfHeight
        D2AxisLeft   = leftSide
        D2AxisRight  = rightSide
        D2LegSizeGlX = 100 - leftSide - rightSide
        D2LegPosX    = leftSide
        D2LegPosY    = middle - 2.0
        D2LegMove    = "automatic"
        D2LegRelPos  = "top left"
    Call GraphObjClose("2DAxis2")
    
    Call GraphObjOpen("plot2_Y_Label")
        TxtPosX   = 4
        TxtPosY   = bottom + .5 * halfHeight
        TxtAng    = 90
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("plot2_Y_Label")

    Call GraphObjOpen("plot2_X_Label")
        TxtPosX   = leftSide + 0.5 * (100 - leftSide - rightSide)
        TxtPosY   = bottom
        TxtAng    = 0
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("plot2_X_Label")

    Call Debug(CurrentScriptName, "...done shifting TWO plot")
End Sub

Sub ShiftFour(top, bottom, orient)

    Dim  leftSide, rightSide, middle, height, halfHeight
    Dim  width, midSpace
    Call Debug(CurrentScriptName, "shifting FOUR plot....")

    leftSide = 12
    rightSide = 4
    width = 36
    midSpace = 10

    If UpC(orient) = "LANDSCAPE" Then
        leftSide = 8
        rightSide = 4
        width = 40
        midSpace = 6
    End If

    height = top - bottom
    halfHeight = height/2
    middle = top - halfHeight

    Call GraphObjOpen("2DAxis1")
        D2AxisTop    = 100 - (top - 4.5)
        D2AxisBottom = middle + .1 * halfHeight
        D2AxisLeft   = leftSide
        D2AxisRight  = 100 - (width + leftSide)
        D2LegSizeGlX = width
        D2LegPosX    = leftSide
        D2LegPosY    = top - 0.5
        D2LegMove    = "automatic"
        D2LegRelPos  = "top left"
    Call GraphObjClose("2DAxis1")

    Call GraphObjOpen("plot1_Y_Label")
        TxtPosX   = 4
        TxtPosY   = middle + .5 * halfHeight
        TxtAng    = 90
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("plot1_Y_Label")

    Call GraphObjOpen("plot1_X_Label")
        TxtPosX   = leftSide + 0.5 * width
        TxtPosY   = middle + .025 * halfHeight
        TxtAng    = 0
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("plot1_X_Label")

    '+++++++++++++++++++++++++++

    Call GraphObjOpen("2DAxis2")
        D2AxisTop    = 100 - (top -4.5)
        D2AxisBottom = MIDDLE + .1 * halfHeight
        D2AxisLeft   = 100 - (rightSide + width)
        D2AxisRight  = rightSide
        D2LegSizeGlX = width
        D2LegPosX    = 100 - (rightSide + width)
        D2LegPosY    = top - 0.5
        D2LegMove    = "automatic"
        D2LegRelPos  = "top left"
    Call GraphObjClose("2DAxis2")

    Call GraphObjOpen("plot2_Y_Label")
        TxtPosX   = 100 - (rightSide + width) - 0.75*midSpace
        TxtPosY   = middle + .5 * halfHeight
        TxtAng    = 90
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("plot2_Y_Label")

    Call GraphObjOpen("plot2_X_Label")
        TxtPosX   = 100 - width - midSpace + leftSide - rightSide + 0.5*width
        TxtPosY   = middle + .025*halfHeight
        TxtAng    = 0
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("plot2_X_Label")

    '+++++++++++++++++++++++++++

    Call GraphObjOpen("2DAxis3")
        D2AxisTop    = 100 - (middle - 5.0)
        D2AxisBottom = bottom + .1*halfHeight
        D2AxisLeft   = leftSide
        D2AxisRight  = 100 - (width + leftSide)
        D2LegSizeGlX = width
        D2LegPosX    = leftSide
        D2LegPosY    = middle - 1.0
        D2LegMove    = "automatic"
        D2LegRelPos  = "top left"
    Call GraphObjClose("2DAxis3")

    Call GraphObjOpen("ploT3_Y_Label")
        TxtPosX   = 4
        TxtPosY   = bottom + .5*halfHeight
        TxtAng    = 90
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("ploT3_Y_Label")

    Call GraphObjOpen("ploT3_X_Label")
        TxtPosX   = leftSide + 0.5*width
        TxtPosY   = bottom
        TxtAng    = 0
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("ploT3_X_Label")

    '+++++++++++++++++++++++++++

    Call GraphObjOpen("2DAxis4")
        D2AxisTop    = 100 - (middle - 5.0)
        D2AxisBottom = bottom + .1*halfHeight
        D2AxisLeft   = 100 - (rightSide + width)
        D2AxisRight  = rightSide
        D2LegSizeGlX = width
        D2LegPosX    = 100 - (rightSide + width)
        D2LegPosY    = middle - 1.0
        D2LegMove    = "automatic"
        D2LegRelPos  = "top left"    
    Call GraphObjClose("2DAxis4")

    Call GraphObjOpen("ploT4_Y_Label")
        TxtPosX   = 100 - (rightSide + width) - 0.75*midSpace
        TxtPosY   = bottom + .5*halfHeight
        TxtAng    = 90
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("ploT4_Y_Label")

    Call GraphObjOpen("ploT4_X_Label")
        TxtPosX   = 100 - width - midSpace + leftSide - rightSide + 0.5*width
        TxtPosY   = bottom
        TxtAng    = 0
        TxtRelPos = "cent."
        TxtSize   = TEXT_SIZE
        TxtFont   = FONT_FAMILY
    Call GraphObjClose("ploT4_X_Label")

    Call Debug(CurrentScriptName, "...done shifting FOUR plot")
End Sub


' Adds all header text fields - returns the bottom of the header once filled
Function CreatePageHeader(pageBottom, reportTDR, isPreview)

    Dim headerBottom, customFields
    Dim txtMN, txtSN, txtRun, txtInstId, txtSeqId, txtDatetime, txtOperator, txtCompany, txtTestStatus
    Dim txtRunValue
    Dim statusColor, statusTextColor
    Dim offset, yBase
    Dim logoHoleRatio, logoFileRatio
    Dim tempArray, tempRunValue, linesCount, i

    ' retrieve header text values
    txtMN       = Lookup("Model_Number_txt",  T3, "")
    txtSN       = Lookup("Serial_Number_txt", T3, "")
    txtRun      = Lookup("Test_Run_Txt",      T3, "")
    txtInstId   = Lookup("Test_Station_Name", T3, "")
    txtSeqId    = Lookup("Test_Sequence",     T3, "")
    txtDatetime = Lookup("DateTime",          T3, "")
    txtOperator = Lookup("Operator",          T3, "")
    txtCompany  = Lookup("Company",           T3, "")

    offset = 3.275
    yBase = 96 - 4 * offset

    If FilEx(txtCompany) Then     ' Put the logo in If it exists
        
        ' Calculate actual hole size for company logos
        logoHoleRatio = ((30/100)*PicWidthInScal) / ((12/100)*PicHeightInScal)
        logoFileRatio = (CDbl(Lookup("logo_width", T3, "30"))) / (CDbl(Lookup("logo_height", T3, "12")))

        Call GraphObjOpen("Metafile1")
            MtaRelPos = "cent."
            MtaFileName = unescapeCR(txtCompany)
            MtaPosX = 18.5
            MtaPosY = 89.45 '95.83
            If logoHoleRatio <  logoFileRatio Then
                MtaWidth = 30
            Else
                MtaWidth = 30 * (logoFileRatio/logoHoleRatio)
            End If
        Call GraphObjClose("Metafile1")

        Call GraphObjOpen("CompanyID")
            TxtTxt = ""
        Call GraphObjClose("CompanyID")
    Else
        Call GraphObjOpen("Metafile1")
            MtaFileName = "" ' Blank out the link TO the logo
        Call GraphObjClose("Metafile1")
    
        Call GraphObjOpen("CompanyID")
            TxtTxt = escapeAt(unescapeCR(txtCompany))
        Call GraphObjClose("CompanyID")
    End If

    ' For text adjust yBase down a little
    yBase = yBase - 0.9

    tempArray = Split(txtSN, "::", -1, 1)
    ' remove Spartan auto-numbering prefix ($SSN$)
    Call AddLabeledField("SNTitle", "SerialNumber", tempArray(0), SSNstr(tempArray(1)), 66, yBase + 4 * offset)

    tempArray = Split(txtMN, "::", -1, 1)
    Call AddLabeledField("MNTitle", "ModelNumber", tempArray(0), tempArray(1), 35, yBase + 4 * offset)

    ' Test Run(s) (comma-separated list)
    txtRunValue = ""
    If Not isPreview Then
        For i = 1 To CInt(UpC(Lookup("Plot_count",T3,"1")))
            tempRunValue = Lookup("Plot" & i &"_run_id", T3, "")
            If i > 1 and tempRunValue = "" Then
                tempRunValue = Lookup("Plot1_RUN_ID", T3, "run 1")
            End If
            
            txtRunValue = txtRunValue &  tempRunValue
            
            If i < CInt(UpC(Lookup("Plot_count", T3, "1")))Then
                txtRunValue = txtRunValue & ", "
            End If
        Next
    End If
    Call AddLabeledField("RunIdTitle", "RunId", txtRun, txtRunValue, 66, yBase + 3 * offset)
        
    tempArray = Split(txtSeqId, "::", -1, 1)
    Call AddLabeledField("SequenceIdTitle", "SequenceId", tempArray(0), tempArray(1), 35, yBase + 3 * offset)


    tempArray = Split(txtDatetime, "::", -1, 1)
    Call AddLabeledField("DateTimeTitle", "DateTime", tempArray(0), tempArray(1), 35, yBase + offset)

    tempArray = Split(txtOperator, "::", -1, 1)
    Call AddLabeledField("OperatorTitle", "Operator", tempArray(0), tempArray(1), 66, yBase + 2 * offset)

    tempArray = Split(txtInstId, "::", -1, 1)
    Call AddLabeledField("InstIdTitle", "InstrumentId", tempArray(0), tempArray(1), 35, yBase + 2 * offset)
  
    txtTestStatus = Lookup("Test_Status", T3, "")
    statusColor = ""
    statusTextColor = RGB(0, 0, 0) ' "Black"
    If (Pos("pass", LoC(txtTestStatus)) > 0) Then
        statusTextColor = RGB(255, 255, 255) ' "White"
        statusColor = STATUS_PASS_COLOR_RGB
    ElseIf (Pos("fail", LoC(txtTestStatus)) > 0) Then
        statusTextColor = RGB(255, 255, 255) ' "White"
        statusColor = STATUS_FAIL_COLOR_RGB
    End If
    
    Call GraphObjNew("FreeFrame", "StatBox")
    Call GraphObjOpen("StatBox")
        AreaLinePt(1) = 65
        AreaLinePt(2) = 96 - 3 * offset
        AreaLinePt(3) = 96 - 0.2
        AreaLinePt(4) = 96 - 4 * offset + 0.1
        AreaBackColor = "other colors"
        AreaBackRGB = statusColor
        AreaLineWidth = "Min"
        AreaLineColor = ""
    Call GraphObjClose("StatBox")
    Call GraphObjNew("FreeText", "Status")
    Call GraphObjOpen("Status")
        TxtTxt  = UpC(txtTestStatus)
        TxtPosX = 80
        TxtPosY = yBase + 0.8 * offset
        TxtRelPos = "cent."
        TxtSize = 2 * TEXT_SIZE
        TxtFont = FONT_FAMILY
        TxtColor = "other colors"
        TxtColorRGB = statusTextColor
    Call GraphObjClose("Status")

    customFields = AddCustomFields(yBase + 0.9, pageBottom, isPreview)
    headerBottom = yBase + 0.9 - (Trunc(2 * (customFields + 1)/2)) + (0.1 * (customFields + 1)/2)

    ' add vertical/horizontal lines on the header
    linesCount = 4
    If customFields <> 0 Then
        linesCount = 5
    End If

    For i = 0 To linesCount ' Horizontal Lines
        Call GraphObjNew("Arrow", "TitleC1" & i)
        Call GraphObjOpen("TitleC1" & i)
            If i = 0 Or i = 4 Then
                ArrowPTX(1) = 3
                ArrowPTX(2) = 96
                ArrowPTY(1) = 96 - i * offset
                ArrowPTY(2) = 96 - i * offset
            ElseIf i = 5 Then
                ArrowPTX(1) = 3
                ArrowPTX(2) = 96
                ArrowPTY(1) = headerBottom
                ArrowPTY(2) = headerBottom
            Else
                ArrowPTX(1) = 34
                ArrowPTX(2) = 96
                ArrowPTY(1) = 96 - i * offset
                ArrowPTY(2) = 96 - i * offset
            End If
        
            ArrowLnType = "Solid"
            ArrowLineWidth = "Min"
            ArrowSymbolBegin = "NoArrow"
            ArrowSymbolEnd = "NoArrow"
        Call GraphObjClose("TitleC1" & i)
    Next  ' horizontal line

    linesCount = 3
    If customFields <> 0 Then
        linesCount = 4
    End If

    For i = 0 To linesCount ' Verticle Lines
        Call GraphObjNew("Arrow", "TitleC2" & i)
        Call GraphObjOpen("TitleC2" & i)
            If i = 0 Or i = 3 Then
                ArrowPTX(1) = 3 + i * 31
                ArrowPTX(2) = 3 + i * 31
                ArrowPTY(1) = 96
                ArrowPTY(2) = headerBottom
            ElseIf i = 4 Then
                ArrowPTX(1) = 49
                ArrowPTX(2) = 49
                ArrowPTY(1) = yBase + 0.9
                ArrowPTY(2) = headerBottom
            Else
                ArrowPTX(1) = 3 + i * 31
                ArrowPTX(2) = 3 + i * 31
                ArrowPTY(1) = 96
                ArrowPTY(2) = 96 - 4 * offset
            End If
            ArrowLnType = "Solid"
            ArrowLineWidth = "Min"
            ArrowSymbolBegin = "NoArrow"
            ArrowSymbolEnd = "NoArrow"
        Call GraphObjClose("TitleC2" & i)
    Next ' vertical line

    CreatePageHeader = headerBottom
End Function


' adds the custom fields to the page header - returns how many were added
Function AddCustomFields(top, bottom, isPreview)

    Dim customCount, addedCount, i
    Dim name, displayName, tempArray 
    
    customCount = CInt(Lookup("Custom_Count", T3, "0"))
    Call Debug(CurrentScriptName, "Adding " & customCount & " custom fields to header...")
  
    addedCount = 0
    For i = 1 To customCount
        name = "Cus_Text_" & i
        displayName = Lookup("Custom" & i & "sDisplayName", T3, "")
    
        tempArray = Split(LoadCustomField(Lookup("Custom" & i, T3, "")), ": ", -1, 1)
        
        If UBound(tempArray) > 0 Or isPreview Then
        
            If tempArray(1) <> "" Or isPreview Then
            
                Call GraphObjNew("FreeText", name & "Label")
                Call GraphObjOpen(name & "Label")
                    If (addedCount Mod 2) = 0 Then
                        TxtPosX  = 4
                    Else
                        TxtPosX  = 50
                    End If

                    TxtPosY   = (top - 1) - (Trunc(addedCount/2) * 1.8)

                    TxtRelPos = "Right"
                    TxtColor  = "Black"
                    TxtBold   = LABEL_BOLD_FONT                    
                    TxtFont   = FONT_FAMILY
          
                    If displayName <> "" Then
                        TxtTxt = escapeAt(displayName & ":")
                    Else
                        TxtTxt = escapeAt(Trim(tempArray(0)) & ":")
                    End If

                    If Len(Join(tempArray)) > 65 Then
                        TxtSize = 1.0
                    Else
                        TxtSize = TEXT_SIZE
                    End If

                Call GraphObjClose(name & "Label")

                If Not isPreview Then
                    Call GraphObjNew("FreeText", name)
                    Call GraphObjOpen(name)

                        If (addedCount Mod 2) = 0 Then
                            TxtPosX  = 48
                        Else
                            TxtPosX  = 95
                        End If

                        TxtPosY   = (top - 1) - (Trunc(addedCount/2) * 1.8)
                        TxtRelPos = "Left"
                        TxtColor  = "Black"
                        TxtFont   = FONT_FAMILY
                        
                        If tempArray(0) = "End Timestamp" Or _
                           tempArray(0) = "Instrument Calibration Date" Or _
                           tempArray(0) = "Instrument Calibration Due Date" Then
                            TxtTxt = Trim(escapeAt(SpartanDateTime(CDbl(tempArray(1)), "MM/DD/YYYY Hh:nn AMPM")))
                        Else
                            TxtTxt = Trim(escapeAt(tempArray(1)))
                        End If

                        If Len(Join(tempArray)) > 65 Then
                            TxtSize = 1.0
                        Else
                            TxtSize = TEXT_SIZE
                        End If

                    Call GraphObjClose(name)
                
                End If ' not isPreview

                addedCount = addedCount + 1
                
            End If ' non-empty field value or isPreview
        
        End If ' good custom field or isPreview
    
    Next ' custom field

    AddCustomFields = addedCount ' return how many we added
    Call Debug(CurrentScriptName, "...added " & addedCount & " custom fields to header")
    
End Function


' Get custom field from Prompted Input if necessary
Function LoadCustomField(key)
    Dim channelId, mn, sn
    
    If (InStr(key, "LOAD:")) > 0 Then
        ' the keys in T3 have been escaped (url-encoded)
        mn = unescape(Lookup("Model_Number", T3, ""))
        sn = unescape(Lookup("Serial_Number", T3, ""))
    
        channelId = Trim(Mid(key, 6))
        
        Call Debug(CurrentScriptName, "Have to read Prompted Input - mn(" & mn & "), sn(" & sn & "), ch(" & channelId & ")")
        
        LoadCustomField = ReadPromptedInput(mn, sn, channelId)
    Else
    
        LoadCustomField = key
    End If
End Function


' Retrieves a measurement from a  file based on search
Function ReadPromptedInput(mn, sn, channelId)

    Dim piFormattedValue, piValueUnit, piTestStatus
    Dim chStart, chIndex, chResult, chDisplayName

    ' get next available channel
    chStart = GlobUsedChn 
    If chStart > 0 Then
        chStart = chStart + 1
    End If
    
    ' Load specific RUN from TDMS file    
    Call LoadRunChannel(mn, sn, channelId)

    chIndex = CNo(channelId, chStart)
    If chIndex > 0 Then
        chResult = "[" & groupCount & "]/" & channelId
        chDisplayName = Safe_ChnPropGet(chResult, "sdisplayname")
        
        If (Safe_ChnPropGet(chResult, "valuetype") = "String" ) Then
            ' read string value
            ReadPromptedInput = chDisplayName & ": " & CHT(1, chIndex)        
        
        Else
            ' read numeric value
            piFormattedValue = Safe_FormatNumber(CHD(1, chIndex), 3)
            piValueUnit = ChnDim(chIndex)
            piTestStatus = SAFE_grouppropget(groupCount, "TEST_STATUS")
            
            ReadPromptedInput = chDisplayName & ": " & piFormattedValue &" " & piValueUnit & " - " & piTestStatus
        End If

    Else ' item had no results
    
        ReadPromptedInput = channelId & ": "
    End If
    
End Function


' adds a labelled box with value
Sub AddLabeledField(labelName, valueName, labelString, valueString, x, y)

    Call GraphObjNew("FreeText", labelName)
    Call GraphObjOpen(labelName)
        TxtTxt = escapeAt(labelString)
        TxtPosX = x
        TxtPosY = y
        TxtRelPos = "Right"
        TxtBold = LABEL_BOLD_FONT
        TxtSize = TEXT_SIZE
        TxtFont = FONT_FAMILY
    Call GraphObjClose(labelName)
    
    Call GraphObjNew("FreeText", valueName)
    Call GraphObjOpen(valueName)
        TxtTxt = escapeAt(valueString)
        TxtPosX = x
        TxtPosY = y - TEXT_SIZE
        TxtRelPos = "Right"
        TxtSize = TEXT_SIZE
        TxtFont = FONT_FAMILY
    Call GraphObjClose(valueName)

End Sub


' adds copyright, page number and template/version information
'     tId is the Template id used to create the report
Sub CreatePageFooter(tId)
    Call GraphSheetInfos ' updates GraphSheetXXX variables
    
    Call GraphObjNew("FreeText", "page" & GraphSheetCount)
    Call GraphObjOpen("page" & GraphSheetCount)
        '------------------- Text -----------------------------
        TxtTxt           = "Page " & L1
        TxtFont          = FONT_FAMILY
        TxtSize          = 1
        TxtColor         = "black"
        TxtColorRGB      = 0
        TxtBold          = 1
        TxtItal          = 0
        TxtUndl          = 0
        TxtStrOut        = 0
        TxtFrame         = 0
        TxtBackColor     = ""
        TxtBackRGB       = 0
        TxtBackRGB2      = 14737616
        TxtBackFMode     = "Vertical"
        TxtBackFVariant  = "From bottom"
        
        '------------------- Position -----------------------
        TxtPosX          = 50
        TxtPosY          = 0
        TxtAng           = 0
        TxtRelPos        = "top"
    Call GraphObjClose("page" & GraphSheetCount)

    'Copyright
    Call GraphObjOpen("Copywrite")
        TxtTxt = "© " & RTT(Now, "YYYY") & " Kaelus Inc. All Rights Reserved"
    Call GraphObjClose("Copywrite")

    'Version
    Call GraphObjOpen("Version")
        TxtTxt = "Spartan v" & SpartanVersion & " Template: " & tId
    Call GraphObjClose("Version")
    
End Sub


' adds generic text box on plot axis
Sub AddTextBox(message, x, y, position, axisId)

    Dim boxId
    
    If message = "" Then
        Exit Sub
    End If
    
    boxId = axisId & "Status" & CInt(x)
    
    Call GraphObjNew("FreeText", boxId)
    Call GraphObjOpen(boxId)
        TxtTxt       = escapeAt(" "& message & " ")
        TxtFrame     = False
        TxtPosX      = x
        TxtPosY      = y
        TxtRelPos    = position  ' "l-bot."
        TxtSize      = TEXT_SIZE
        TxtFont      = FONT_FAMILY
        TxtColor     = "other colors"
        TxtBackColor = "other colors"
        
        If (Pos("pass", LoC(message))= 1) Then
            TxtColorRGB = RGB(255, 255, 255) ' white
            TxtBackRGB  = STATUS_PASS_COLOR_RGB
            
        ElseIf (Pos("fail", LoC(message))=1) Then
            TxtColorRGB = RGB(255, 255, 255) ' white
            TxtBackRGB  = STATUS_FAIL_COLOR_RGB
        Else
            TxtColorRGB = RGB(0, 0, 0) ' black
            TxtBackRGB  = RGB(255, 255, 255) ' white
        End If
    
    Call GraphObjClose(boxId)

End Sub


