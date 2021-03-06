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

    Dim FSO, FILEREF
    Dim TDM_FILE, REPORT_DIRECTORY, REPORT_PATH
    Dim TestType, SerialNumber, ModelNumber, Filepathstring, Filenamestring, Filenameparts, TestRuns, RunName
    Dim X,Y, TT,MN,SN,RUN,DATAPATH, format,SXX,CHSTART,cal_ch,FREQUENCY,DATANAME,Adj_Frequency,INDEX,AXIS
    Dim auto_x,x_min,x_max,x_unit,y_unit,auto_y,Plot_Limiton,AxisID,curve_count,ploT,baseformat
    dim RefV ,Refp,Scale,Y_min,Y_max,chstr,w,h,PIXW,PIXH,LABELS,LABEL,TAG,PMN,PSN,startpagenum,pagecount,ptt
    Dim IM,num_sweeps,LIMITNAME,axistype,Xchannel,LEGEND,Adj_XCHANNEL,PAGE,xs,UPCOLOR,DNCOLOR,uplabel,dnlabel,prefix
    
    Dim stage, isPreview

    ' Load and initialize variables
    X           = 0 
    plot        = 1
    PAGE        = UpC(Lookup("Plot1_Page", T3, "ALL"))
    DATAPATH    = Lookup("DATA_PATH", T3, "")
    REPORT_PATH = Lookup("report_path", T3, "")

    isPreview = (CInt(UpC(Lookup("PREVIEW", T3, "0"))) = 1)
    
    format      = Lookup("plot1_y_format", T3, "")
    axistype    = UpC(Lookup("Plot1_AxisType", T3, ""))
    SXX         = Lookup("plot1_curve1_parameter", T3, "")
    IM          = pimSTRING(SXX)
    auto_x      = CInt(Lookup("Plot1_auto_X", T3, "1"))
    x_min       = CDbl(Lookup("Plot1_x_min", T3, "0"))
    x_max       = Cdbl(Lookup("Plot1_x_max", T3, "100"))
    x_unit      = Lookup("Plot1_x_unit", T3, "MHz")

    y_unit      = Lookup("Plot1_y_format", T3, "LOG MAG")
    auto_y      = cint(Lookup("Plot1_auto_y", T3, "1"))

    TT          = Lookup("ITEM0_TT", T3, "S PARAMETER")
        
    Select Case UpC(TT)
        Case "S PARAMETER"          
            RefV  = CDbl(Lookup("Plot1_REFERENCE", T3, "0"))
            Refp  = CDbl(Lookup("Plot1_position", T3, "0"))
            Scale = CDbl(Lookup("Plot1_scale", T3, "0"))
            Y_min = RefV - (Scale * RefP)
            Y_max = RefV + (Scale * (10 - RefP))
        Case "PIM"
            Y_min = CDbl(Lookup("Plot1_Y_min", T3, "-160"))
            Y_max = CDbl(Lookup("Plot1_Y_max", T3, "-60"))        
        Case Else
            ' nothing
    End Select
      
    curve_count = 0
    AxisID      = "2DAxis" & plot
    AXIS        = 1 
    Plot_Limiton = Lookup("plot1_curve1_limiton", T3, "1")
    chstr = ""

    w = CDbl(Lookup("Template_dwidth", T3, "8.5"))
    h = CDbl(Lookup("Template_dHeight", T3, "11.0"))
    
    stage = Lookup("PlotEngine", T3, "")

    Call PrePageProcessing(CurrentScriptPath & "Report One Plot Overlay.tdr", REPORT_PATH, stage , w, h)
    Call add_page_number()

    If (w > h) Then 'landscape
        PIXW = 792
        PIXH = 550
        Call GraphObjOpen("2DAxis1")
            D2LegPosX    = 10
            D2AxisLeft   = 10
            D2LegSizeGlX = 80
        Call GraphObjClose("2DAxis1")
    
    Else 'portrait
        PIXW =550
        PIXH =792
        Call GraphObjOpen("2DAxis1")
            D2LegPosX    = 15
            D2AxisLeft   = 15
            D2LegSizeGlX = 75
        Call GraphObjClose("2DAxis1")
    
    End If

    startpagenum = L1

    If isPreview Then
        Call GraphObjNew("FreeText", "title")
        Call GraphObjOpen("title")
          TxtTxt    = "Multi Item Overlay Plot"
          TxtPosX   = 50
          TxtPosY   = 95
          TxtRelPos = "center"
          TxtSize   = 4
        Call GraphObjClose("title")

        Select Case UpC(TT)
            Case "S PARAMETER"          
                Call GraphObjOpen("plot1_Y_Label")
                    TxtTxt = y_unit_label(Y_UNIT,sxx) & " (" & Y_UNIT_STRING(Y_UNIT) & ")"
                Call GraphObjClose("plot1_Y_Label")
                
                Call GraphObjOpen("plot1_X_Label")
                    TxtTxt = "Frequency (" & X_UNIT_STRING(X_UNIT) & ")"
                Call GraphObjClose("plot1_X_Label") 
  
             Case "PIM"
                Call GraphObjOpen("plot1_Y_Label")
                      TxtTxt = Lookup("Plot1_Curve1_parameter",T3,"3rd")&" Order IM Power ("&Y_UNIT&")"
                Call GraphObjClose("plot1_Y_Label")
                
                Select Case UpC(AxisType)
                    Case "SWEPT FREQ", "FREQUENCY","SWEPT FREQUENCY SCATTER","FREQUENCY MAX/AVG","SWEPT FREQUENCY STATISTICS SIGMA"
                        Call GraphObjOpen("plot1_X_Label")
                            TxtTxt = "IM Frequency ("&X_UNIT&")"
                        Call GraphObjClose("plot1_X_Label") 
                      
                    Case "TIME","FIXED PAIR"
                        Call GraphObjOpen("plot1_X_Label")
                            TxtTxt = "Time (" & X_UNIT_STRING(X_UNIT) & ")"
                        Call GraphObjClose("plot1_X_Label") 
                      
                End Select  
        End Select

        ' export the PNG preview
        Call PicExport(REPORT_path, "PNG", False, PIXH, PIXW, "rgb 24", ,"NoCompression")
        T7 = REPORT_path

    Else ' not isPrevew - creating an actual report
        
        PMN = Lookup("ITEM0_MN", T3, "")
        PSN = Lookup("ITEM0_SN", T3, "")
        PTT = Lookup("ITEM0_TT", T3, "")
        Y = 0
        pagecount=1
        
        While ((Lookup("ITEM"&X&"_TT",T3,"")  <> "") And (curve_count < 250))
        
            If (PAGE = "ALL") And (Lookup("ITEM9_TT",T3,"")  <> "") Then
                LABELS = "NO"
            Else
                LABELS = "YES"
            End If
            
            ' keep track of which group we are using
            chstart = GlobUsedChn
            If chstart > 0 Then
                chstart = chstart + 1 
            End If
        
            TT  = Lookup("ITEM"&X&"_TT",T3,"")
            MN  = Lookup("ITEM"&X&"_MN",T3,"")
            SN  = Lookup("ITEM"&X&"_SN",T3,"")
            RUN = Lookup("ITEM"&X&"_RUN",T3,"")
            
            ' load the item's TDMS data file
            Call DataFileLoadSel(Lookup("ITEM"&X&"_path",T3,""), "TDMS", RUN & "/*", "")  

            Call Debug(CurrentScriptName, TT &" "&MN&" "&SN&" "&RUN)
            Call Debug(CurrentScriptName, PMN &" = "&MN&" ---"&PSN&" = "&SN)
            Call Debug(CurrentScriptName, Lookup("ITEM"&X&"_path",T3,""))
            
            If (PAGE <> "ALL") And ( (PMN <> MN ) Or (PSN <> SN) Or (PTT <> TT) ) Then
                Call AddTextBox(PMN & "  " & PSN, 50, 89, "center", axisid)
                Call PAGHEEXTRAS(X_UNIT,Y_UNIT,AxisID, Auto_X, X_MIN, X_MAX,Auto_Y, Y_MIN, Y_MAX,PLOT,curve_count-Y,TT,UPC(AXISTYPE))
                
                pagecount = pagecount + 1
                L1 = L1 + 1
                
                Call PicFileAppend(CurrentScriptPath & "Report One Plot Overlay.TDR")
                Call GraphSheetNGet(pagecount + startpagenum - 1)
                
                Call GraphSheetRename(GraphSheetName, "Spartan Report " & (pagecount + startpagenum - 1))
                Call GraphSheetRefSet("Spartan Report " & (pagecount + startpagenum - 1))
                
                curve_count = 0
            End If
              
              
            Select Case UpC(TT)
                Case "S PARAMETER"
                    Call Debug(CurrentScriptName, "S PARAMETER OVERLAY")
                    
                    ' Change to desired frequency units
                    Frequency = Calc_X_Units("Frequency", X_Unit,chstart)
                    CAL_ch = -1
                      
                    Select Case UpC(Format) ' Depending on SXX get channel or transform to proper format
                        Case "PHASE"
                            baseformat = "PHASE"
                            Dataname = SXX&" PHASE"
                            CAL_ch = CNo(Dataname,chstart)
      
                        Case "DELAY"
                            baseformat = "PHASE"
                            Dataname = Transform_Data (SXX&" PHASE", "DELAY", "",chstart )
                            CAL_ch = CNo(SXX&" PHASE",chstart)
    
                        Case "EXPANDED PHASE"
                            baseformat = "PHASE"
                            Dataname = Transform_Data (SXX&" PHASE", "EXPANDED PHASE", "",chstart )
                            CAL_ch = CNo(SXX&" PHASE",chstart) 

                        Case "LOSSa", "ISOLATION", "RETLOSS"  
                            ' If a user is plotting in the Loss format, i.e. Return Loss, Isolation, or Insertion Loss, the template should 
                            ' be looking for the opposite limit, i.e. if looking to plot an upper limit it should look for lower limits.
                            If (Cno(Add_group(SXX & " MAG LLimit"), chstart) > 0) Then
                                Call ChnPropSet(Cno(Add_group(SXX & " MAG LLimit"), chstart), "name", SXX & " MAG ULimittemp")
                            End If
                          
                            If (Cno(Add_group(SXX & " MAG ULimit"), chstart) > 0) Then
                                Call ChnPropSet(CNO(Add_group(SXX&" MAG ULimit"),chstart), "name", SXX&" MAG LLimit")
                            End If
                            
                            If (Cno(Add_group(SXX & " MAG ULimittemp"), chstart) > 0) Then
                                Call ChnPropSet(Cno(Add_group(SXX & " MAG ULimittemp"), chstart), "name", SXX & " MAG ULimit")
                            End If
                            
                            baseformat = "MAG"
                            Dataname = Transform_Data(SXX & " MAG", Format, "", chstart)
 
                        Case Else
                            baseformat = "MAG"
                            Dataname = Transform_Data(SXX & " MAG", Format, "", chstart) 
                            CAL_ch = CNo(SXX&" MAG",chstart)
                            
                    End Select ' format
                          
                    If (CAL_ch > 0) Then
                                    
                        PicDefByIdent = 1       ' Name-Oriented channel referencing
                        LABEL = ""
                        
                        Call Debug(CurrentScriptName, PAGE & " " & prefix & " " & TAG & " " & LABEL)
                        If (LABELS = "YES") Then
                            TAG = Safe_GroupPropGet(groupcount, "STEP_TAG")
                            
                            If (PAGE <> "ALL") Then
                                prefix = ""
                            Else
                                prefix = MN & " " & ssnStr(SN) & " "
                            End If
                                    
                            If TAG ="" Then
                                LABEL = prefix & RUN
                            Else 
                                LABEL = prefix & TAG
                            End If
                          
                            Call Debug(CurrentScriptName, PAGE & " " & prefix & " " & TAG & " " & LABEL)
                        End If

                        ' Create a channel that is zoomed if user wants that
                        Adj_Frequency = AutoX_Adjust(AxisID, Frequency, Frequency, AUTO_X, X_MIN, X_MAX, AUTO_Y, "", chstart)
                        Dataname = AutoX_Adjust(AxisID, Dataname, Frequency,  AUTO_X, X_MIN, X_MAX, AUTO_Y, "", chstart)

                        If ((Plot_Limiton = "1") And (curve_count=0)) Then
                            Call Debug(CurrentScriptName, curve_count & " " & MN & " " & SN)
                            
                            Y = curve_count
                            curve_count = Add_Limit("LLIMIT",curve_count,sxx,Format,chstart,AxisID,frequency,AUTO_X, X_MIN,X_MAX,AUTO_Y,"",Adj_Frequency,plot,   Dataname,"0"       ,AXIS,"","YES",SXX&" Lower Limit")
                            curve_count = Add_Limit("ULIMIT",curve_count,sxx,Format,chstart,AxisID,frequency,AUTO_X, X_MIN,X_MAX,AUTO_Y,"",Adj_Frequency,plot,   Dataname,"0"       ,AXIS,"","YES",SXX&" Upper Limit")
                            curve_count = Check_filter_limits(Format,curve_count,sxx,baseformat,chstart,AxisID,frequency,AUTO_X, X_MIN,X_MAX,AUTO_Y,"",Adj_Frequency,plot,Dataname,"",AXIS,"")
                            Y = curve_count - y
                        End If
                        
                         ' Now add the data, may be new zoomed CH
                        Index = Add_Curve(AxisID, curve_count, Adj_Frequency , Dataname, Auto_X, X_min, X_Max, Auto_Y, chstart, plot, "0", AXIS, Assign_Curve_Color_old(curve_count), LABELS, LABEL)
                        curve_count = curve_count + 1 
                                                    
                    End If 'END if data exists
                          
                    Call Debug(CurrentScriptName, "EXIT - S PARAMETER OVERLAY")
  

                Case "PIM"  ' PIM plot overlay
                
                    Select Case UpC(Format)
                        Case "DBM"
                            Dataname = Add_group(IM & " POWER 1")
                            limitname = Add_group("ref limit 1")
                        Case "DBC"
                            Dataname = Add_group(IM & " POWER 2")
                            limitname = Add_group("ref limit 2")
                    End Select

                    PicDefByIdent = 1       ' Name-Oriented channel referencing
   
                    Select Case UpC(AXISTYPE)
                        Case "FREQUENCY","SWEPT FREQ", "SWEPT FREQUENCY"
                            Call Debug(CurrentScriptName, "PIM OVERLAY-FREQUENCY")
                           
                            LABEL = ""
                            If (LABELS = "YES") And (Lookup("ITEM9_TT", T3, "") <> "") Then
                                TAG = Safe_GroupPropGet(groupcount, "STEP_TAG")
                                
                                If (PAGE <> "ALL") Then
                                    prefix = ""
                                Else
                                    prefix = MN & " " & ssnStr(SN) & " "
                                End If
                                
                                If ((TAG = "") Or (tag = "-")) Then
                                    LABEL = prefix & RUN
                                Else 
                                    LABEL = prefix & TAG
                                End If
                             
                            End If
                            
                            Xchannel = Calc_X_Units(IM & " Frequency", X_Unit, chstart)
                            Num_Sweeps = Split_sweeps(dataname, xchannel, chstart, x_unit)
        
                            If num_sweeps > 249 Then 
                                num_sweeps = 249
                            End If
                            
                            CAL_ch = CNo(Dataname, chstart)
                            
                            For Xs = 1 To Num_sweeps 
                                If Xs = 1 And (Lookup("ITEM9_TT", T3, "") <> "") Then
                                    LABELS = "YES"
                                    UPCOLOR = "blue"
                                    DNCOLOR = "red"
                                    uplabel = " UP"
                                    dnlabel = " DN"
                                Else
                                    LABELS = "NO"
                                    uplabel = ""
                                    dnlabel=""
                                End If
                                      
                                ' Create a channel that is zoomed IF user wants that
                                Adj_XCHANNEL = AutoX_Adjust(AxisID, Add_group("tx1 frequency scan"), Add_group("tx1 frequency scan"), AUTO_X, X_MIN, X_MAX, AUTO_Y, "", chstart)
                                Dataname = AutoX_Adjust(AxisID, Add_group("tx1 sweep " & xs), Add_group("tx1 frequency scan"),  AUTO_X, X_MIN, X_MAX, AUTO_Y, "", chstart)
                                
                                ' Now add the data, may be new zoomed CH
                                Index = Add_Curve(AxisID, curve_count, Adj_XCHANNEL, Dataname, Auto_X, X_min, X_Max, Auto_Y, chstart, PLOT, "0", AXIS, UPCOLOR, LABELS, LABEL & uplabel)
                                curve_count = curve_count + 1
                                
                                ' Create a channel that is zoomed IF user wants that
                                Adj_XCHANNEL = AutoX_Adjust(AxisID, Add_group("tx2 frequency scan"), Add_group("tx2 frequency scan"), AUTO_X, X_MIN,X_MAX,AUTO_Y,"",chstart)
                                Dataname = AutoX_Adjust(AxisID, Add_group("tx2 sweep " & xs), Add_group("tx2 frequency scan"),  AUTO_X, X_MIN, X_MAX, AUTO_Y, "", chstart)
                                
                                ' TX2 - Now add the data, may be new zoomed CH
                                Index = Add_Curve(AxisID, curve_count, Adj_XCHANNEL , Dataname, Auto_X, X_min, X_Max, Auto_Y, chstart, PLOT, "0", AXIS, DNCOLOR, LABELS, LABEL & dnlabel)
                                curve_count = curve_count + 1

                                ' Check TO see IF we are plotting Limits
                                If ((Plot_Limiton = "1") And (curve_count <= 2)) Then
                                    Y = curve_count
                                    Adj_XCHANNEL = AutoX_Adjust(AxisID, Xchannel, Xchannel, AUTO_X, X_MIN, X_MAX, AUTO_Y, "", chstart)
                                    Dataname = AutoX_Adjust(AxisID, limitname, Xchannel, AUTO_X, X_MIN, X_MAX, AUTO_Y, "", chstart)
                                    Index = Add_Curve(AxisID, curve_count, Adj_XCHANNEL, Dataname, Auto_X, X_min, X_Max, Auto_Y, chstart, PLOT, "0", AXIS, "blACK", "YES", "Specification Limit")
                                    curve_count = curve_count + 1
                                    Y = curve_count - y 
                                End If
                                
                            Next ' sweep
                                
                        Case "TIME","FIXED PAIR"
                            'Call Debug(CurrentScriptName, "PIM OVERLAY-TIME")
                            LABEL = ""
                            
                            If (LABELS = "YES") Then
                                TAG = Safe_GroupPropGet(GroupCount, "STEP_TAG")
                                
                                If ((TAG = "") Or (tag = "-")) Then
                                    LABEL = MN & " " & ssnStr(SN) & " " & RUN
                                Else 
                                    LABEL = MN & " " & ssnStr(SN) & " " & TAG
                                End If
                                            
                            End If
                                  
                            Xchannel = Calc_X_Units("Elapsed Time", X_Unit, chstart)
                            CAL_ch = Cno(Dataname, chstart)

                            ' Create a channel that is zoomed IF user wants that
                            Adj_XCHANNEL = AutoX_Adjust(AxisID, XCHANNEL, XCHANNEL, AUTO_X, X_MIN, X_MAX, AUTO_Y, "", chstart)
                            Dataname = AutoX_Adjust(AxisID, Dataname, XCHANNEL, AUTO_X, X_MIN, X_MAX, AUTO_Y, "", chstart)
                            
                             ' Now add the data, may be new zoomed CH
                            Index = Add_Curve(AxisID, curve_count, Adj_XCHANNEL, DatanamE, Auto_X, X_min, X_Max, Auto_Y, chstart, PLOT, "0", AXIS, Assign_Curve_Color_old(curve_count), LABELS, LABEL)
                            curve_count = curve_count + 1
                            
                             ' Check TO see IF we are plotting Limits
                            If ((Plot_Limiton = "1") And (curve_count = 1)) Then 
                                Y = curve_count
                                Adj_XCHANNEL = AutoX_Adjust(AxisID, Xchannel, Xchannel, AUTO_X, X_MIN, X_MAX, AUTO_Y, "", chstart)
                                
                                Call Set_limit_samples(limitname, chstart)
                                
                                Dataname = AutoX_Adjust(AxisID, limitname, Xchannel, AUTO_X, X_MIN, X_MAX, AUTO_Y, "", chstart)
                                Index = Add_Curve(AxisID, curve_count, Adj_XCHANNEL, Dataname, Auto_X, X_min, X_Max, Auto_Y, chstart, PLOT, "0", AXIS, "blACK", "YES", "Specification Limit" )
                                curve_count = curve_count + 1
                                Y = curve_count - y 
                            End If
                                  
                            Call GraphObjOpen(AxisID)
                                Call GraphObjOpen(D2AxisxObj(1))
                                    D2AxisXFormat = "d.d"
                                Call GraphObjClose(D2AxisxObj(1))
                            Call GraphObjClose(AxisID) 
                            
                    End Select  ' pim axis type

            End Select ' plot type
            
            x = x + 1
            Call Debug(CurrentScriptName, "next item- "&Lookup("ITEM"&X&"_TT",T3,"")&" "&Lookup("ITEM"&X&"_mn",T3,"") )
            
            PMN = MN
            PSN = SN
            
        Wend ' while items
        
        If (PAGE <> "ALL") Then
            Aall AddTextBox(PMN & "  " & PSN, 50, 89, "center", axisid)
        End If
        
        Call PAGHEEXTRAS(X_UNIT,Y_UNIT,AxisID, Auto_X, X_MIN, X_MAX,Auto_Y, Y_MIN, Y_MAX,PLOT,curve_count-Y,TT,UPC(AXISTYPE),sxx)
        
        Call PostPageProcessing(CurrentScriptPath & "Report One Plot Overlay.TDR", REPORT_PATH, stage)
        
    End If

    Call Debug(CurrentScriptName, "<====== Exiting ======")
    T1 = T7   ' T1 must be set to the file path of the generated report.

End Sub


'-------------------------------------------------------------------------------
'-------------------------------------------------------------------------------
' RENDER COMMON PLOT ELEMENTS

SUB PAGHEEXTRAS(X_UNIT,Y_UNIT,AxisID, Auto_X, X_MIN, X_MAX,Auto_Y, Y_MIN, Y_MAX,PLOT,X,TT,AXISTYPE,sxx)
'call debug ("ENTER PAGHEEXTRAS")
CALL Graphobjnew("FreeText", "title")
        CALL GRAPHObjOpen("title")
          TXTTXT  = Lookup("plot_label",T3,"Multi Item Overlay Plot")
          TxtPosX = 50
          TxtPosY = 95
          TXTrelpos = "center"
          txtsize = 4
        CALL GRAPHObjClose("title")
        CALL Graphobjnew("FreeText", "title2")
        CALL GRAPHObjOpen("title2")
          TXTTXT  = x&" traces plotted"
          TxtPosX = 50
          TxtPosY = 92
          TXTrelpos = "center"
          txtsize = 3
        CALL GRAPHObjClose("title2")
        ' Set the X unit text
  CALL  LABELS(TT,Y_UNIT,X_UNIT,AxisType,sxx)      
        
        Call GRAPHObjOpen(AxisID) 
            IF y_unit ="DELAY" THEN
                Call GraphObjOpen(D2AxisYObj(1))
                    D2AxisYFormat    = "d.dde"
                Call GraphObjClose(D2AxisYObj(1))
            END IF
            D2LEGTXTSIZEAUT = 1
        CALL GRAPHObjClose(AxisID)
        
        CALL FORMAT_X_PLOT (AxisID, Auto_X, X_MIN, X_MAX) 
        CALL FORMAT_Y_PLOT (AxisID, 1, Auto_Y, Y_MIN, Y_MAX)
        call add_page_number()
'   call debug ("EXIT PAGHEEXTRAS")     
    END SUB
'-------------------------------------------------------------------------------
'-------------------------------------------------------------------------------
SUB LABELS(TT,Y_UNIT,X_UNIT,AxisType,sxx)
         SELECT CASE UPC(TT)
              CASE "S PARAMETER"          
                  CALL GRAPHObjOpen("plot1_Y_Label")
                        TXTTXT           =y_unit_label (Y_UNIT,sxx) & " (" & Y_UNIT_STRING(Y_UNIT) & ")"
                  CALL GRAPHObjClose("plot1_Y_Label")
                  CALL GRAPHObjOpen("plot1_X_Label")
                        TXTTXT           = "Frequency (" & X_UNIT_STRING(X_UNIT) & ")"
                  CALL GRAPHObjClose("plot1_X_Label") 
  
             CASE "PIM"
                  CALL GRAPHObjOpen("plot1_Y_Label")
                      TXTTXT           =Lookup("Plot1_Curve1_parameter",T3,"3rd")&" Order IM Power ("&Y_UNIT&")"
                  CALL GRAPHObjClose("plot1_Y_Label")
                  SELECT CASE UPC(AxisType)
                      CASE "SWEPT FREQ", "FREQUENCY","SWEPT FREQUENCY SCATTER","FREQUENCY MAX/AVG","SWEPT FREQUENCY STATISTICS SIGMA"
                          CALL GRAPHObjOpen("plot1_X_Label")
                              TXTTXT           = "IM Frequency ("&X_UNIT&")"
                          CALL GRAPHObjClose("plot1_X_Label") 
                      
                      CASE "TIME","FIXED PAIR"
                          CALL GRAPHObjOpen("plot1_X_Label")
                            TXTTXT           = "Time (" & X_UNIT_STRING(X_UNIT) & ")"
                          CALL GRAPHObjClose("plot1_X_Label") 
                      
                    END SELECT  
         END SELECT  
 END SUB
  