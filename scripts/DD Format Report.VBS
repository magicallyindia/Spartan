'-------------------------------------------------------------------------------
'-- Spartan VBS script file
'-- Updated on 04/18/2013 
'-- Author: James Brunner
'-- Summary:
'   This is a generic "PlotEngineScript" file called from "SpartanDD Generate Report.vbs".
'   The Main() subroutine name (without parameters) is the required signature.
'-------------------------------------------------------------------------------
Option Explicit         ' This setting requires explicit variable allocation in script.
AutoIgnoreError = 1     ' 1 turns off any error popups. 0 Enables popups

Sub Main()

    ScriptInclude(CurrentScriptPath & "DD Library.vbs") ' Common functions for DD format includes S2P, ASCII

    Call Debug(CurrentScriptName, "====== Entering ======>")

    PicFrame = 0 ' Turn off frame around a plot
    PicDefByIdent = 1  ' Name-Oriented channel referencing
    
    Dim reportTDR, reportPath, processingStage, isPreview
    Dim pageWidth, pageHeight, pixWidth, pixHeight, plotOrientation
    Dim pageBottom, headerBottom    
    Dim plotCount, px, plotStyle, pimAxisType

    T1 = "ERROR"

    reportPath = Lookup("REPORT_PATH", T3, "")
    
    ' is this a preview report?
    isPreview = (CInt(UpC(Lookup("PREVIEW", T3, "0"))) = 1)
  
    ' Figure out how many plots (1, 2, or 4)
    plotCount = CInt(UpC(Lookup("Plot_count", T3, "1")))
  
    Call Debug(CurrentScriptName, "  formatting " & plotCount & " plots...")

    ' choose the approprate TDR according to number of plots
    reportTDR = "Report One Plot" ' default is single plot
    Select Case (plotCount)
        Case 2
            reportTDR = "Report Two Plot"
        Case 4
            reportTDR = "Report Four Plot"
        Case Else
            plotCount = 1 ' ensure equals 1 for default
    End Select

    ' set the page width/height (inches)
    pageWidth = CDbl(Lookup("Template_dwidth", T3, "8.5") )
    pageHeight = CDbl(Lookup("Template_dHeight", T3, "11.0") )
    
    ' default Portrait
    PrintTopMarg = 0.24 
    PrintLeftMarg = 0.24 
    PrintWidth = 8.03 
    PicRatio = 1.29
    reportTDR = reportTDR & " PORTRAIT.TDR"
    pixWidth = 550
    pixHeight = 792
    plotOrientation = "PORTRAIT"  

    ' adjust for page orientation and margins (inches)
    If (pageWidth > pageHeight) Then
        PrintTopMarg = 0.24 
        PrintLeftMarg = 0.24 
        PrintWidth = 10.36
        picratio = 0.775
        reportTDR = reportTDR & " LANDSCAPE.TDR"
        pixWidth = 792
        pixHeight = 550
        plotOrientation = "LANDSCAPE"
    End If

    processingStage = Lookup("PlotEngine", T3, "")
    
    ' pre-process the report page
    Call PrePageProcessing(reportTDR, reportPath, processingStage, pageWidth, pageHeight)
        
    ' fill in the header and any custom fields
    pageBottom = 4
    headerBottom = CreatePageHeader(pageBottom, reportTDR, isPreview)

    ' adjust plots now that header is filled
    Call ShiftPlots(plotCount, headerBottom, pageBottom, plotOrientation)

    ' Previews are generated without filling in data...
    If isPreview Then
        Call Debug(CurrentScriptName, "Creating Preview: " & reportPath)

        ' for each of the plots
        For px = 1 To plotCount
    
            plotStyle = Lookup("Plot" & px & "_STYLE", T3, "S PARAMETER")
            Call Debug(CurrentScriptName, "adding " & plotStyle & " plot")
        
            Select Case UPC(plotStyle)
                Case "S PARAMETER"          
                    Call GRAPHObjOpen("Plot" & px & "_Y_Label")
                        TxtTxt = y_unit_label ( Lookup("Plot"&pX&"_Y_Format",T3,"dBm"),Lookup("Plot"&pX&"_Curve1_parameter",T3,"s11")) & " (" & Y_UNIT_STRING( Lookup("Plot"&pX&"_Y_Format",T3,"dBm")) & ")"
                    Call GRAPHObjClose("Plot"&pX&"_Y_Label")
                    
                    Call GRAPHObjOpen("Plot" & px & "_X_Label")
                        TxtTxt = "Frequency (" & X_UNIT_STRING(Lookup("Plot"&pX&"_X_Unit",T3,"")) & ")"
                    Call GRAPHObjClose("Plot" & pX & "_X_Label") 
        
                Case "PIM"
                    Call GRAPHObjOpen("Plot" & px &"_Y_Label")
                        TxtTxt = Lookup("Plot" & px & "_Curve1_parameter", T3, "3rd") & " Order IM Power (" & Lookup("Plot" & px & "_Y_Format", T3, "dBm") & ")"
                    Call GRAPHObjClose("Plot"&pX&"_Y_Label")
            
                    pimAxisType = Lookup("Plot" & px & "_AxisType", T3, "")
                    Select Case UPC(pimAxisType)
                        Case "SWEPT FREQ", "FREQUENCY", "SWEPT FREQUENCY SCATTER", "FREQUENCY MAX/AVG", "SWEPT FREQUENCY STATISTICS SIGMA"
                            Call GRAPHObjOpen("Plot" & px & "_X_Label")
                                TxtTxt = "IM Frequency ("&Lookup("Plot"&pX&"_X_Unit",T3,"")&")"
                            Call GRAPHObjClose("Plot" & px & "_X_Label") 
            
                        Case "TIME", "FIXED PAIR"
                            Call Debug(CurrentScriptName, "PIM axis type: " & pimAxisType)
                            
                            Call GRAPHObjOpen("Plot" & px & "_X_Label")
                                TxtTxt = "Time (" & X_UNIT_STRING(Lookup("Plot" & px &"_X_Unit", T3, "")) & ")"
                            Call GRAPHObjClose("Plot" & px & "_X_Label") 
                        
                        Case Else
                            ' nothing required  
                    End Select ' pimAxisType
            
            Case Else
            ' nothing required
        End Select  ' plotStyle
        
        Next ' plot
 
        Call PicUpdate ' update the Report in DIAdem
        
        ' export the report as a PNG graphic (for previews)
        Call PicExport(reportPath, "PNG", False, pixHeight, pixWidth, "rgb 24", Null, "NoCompression")
        
        ' tell Spartan where to find the exported graphic
        T7 = reportPath
    
    Else ' not a preview - a full-fledged report
    
        ' Create each plot
        For px = 1 To plotCount
        
            plotStyle = Lookup("Plot" & px & "_STYLE", T3, "S PARAMETER")
            Call Debug(CurrentScriptName, "  creating a " & plotStyle & " style plot...")
            
            Select Case UPC(plotStyle)
                Case "S PARAMETER"
                    Call CreateSParameterPlot(px)
                
                Case "PIM"
                    Call CreatePimPlot(px)
                
                Case Else
                    ' nothing required
            End Select
        Next
    
        Call PostPageProcessing(reportTDR, reportPath, processingStage)    
        Call Debug(CurrentScriptName, "Report created: " & reportPath)
    End If

    T1 = T7

    Call Debug(CurrentScriptName, "<====== Exiting")
End Sub