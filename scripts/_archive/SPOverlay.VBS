'-------------------------------------------------------------------------------
'-- VBS script file
'-- This script will create the S#P file.
'-- Load and execute Query TDM File 
Option Explicit         ' This setting requires explicit variable allocation in script.

SUB MAIN()
AutoIgnoreError = 1     ' 1 turns off any error popups. 0 Enables popups
PicDefByIdent = 1       ' Name-Oriented channel referencing

  ScriptInclude (AutoActPath&"\DD Lib.vbs") 'Common functions

DIM FSO, FILEREF
DIM TDM_FILE, REPORT_DIRECTORY, REPORT_PATH
DIM TestType, SerialNumber, ModelNumber, Filepathstring, Filenamestring, Filenameparts, TestRuns, RunName
DIM X,Y, TT,MN,SN,RUN,DATAPATH, format,SXX,CHSTART,cal_ch,FREQUENCY,DATANAME,Adj_Frequency,INDEX,AXIS
DIM auto_x,x_min,x_max,x_unit,y_unit,auto_y,Plot_Limiton,AxisID,curve_count,ploT,baseformat
dim RefV ,Refp,Scale,Y_min,Y_max,chstr,w,h,PIXW,PIXH,LABELS,LABEL,TAG,PMN,PSN,startpagenum,pagecount,ptt
DIM IM,num_sweeps,LIMITNAME,axistype,Xchannel,LEGEND,Adj_XCHANNEL,PAGE,xs,UPCOLOR,DNCOLOR,uplabel,dnlabel,prefix
'call debug ("ENTER spoverlay.vbs")
' Load and initialize variables
X           = 0 
plot        = 1
PAGE        = UPC(Lookup("Plot1_Page",T3,"ALL"))
DATAPATH    = Lookup("DATA_PATH",T3,"")
REPORT_PATH = Lookup("report_path",T3,"")
format      = Lookup("plot1_y_format",T3,"")
axistype    = UPC(Lookup("Plot1_AxisType",T3,""))
SXX         = Lookup("plot1_curve1_parameter",T3,"")
IM          = pimSTRING(SXX)
auto_x      = cint(Lookup("Plot1_auto_X",T3,"1"))
x_min       = cdbl(Lookup("Plot1_x_min",T3,"0"))
x_max       = cdbl(Lookup("Plot1_x_max",T3,"100"))
x_unit      = Lookup("Plot1_x_unit",T3,"MHz")


y_unit      = Lookup("Plot1_y_format",T3,"LOG MAG")
auto_y      = cint(Lookup("Plot1_auto_y",T3,"1"))

            TT  = Lookup("ITEM0_TT",T3,"S PARAMETER")
       SELECT CASE UPC(TT)
              CASE "S PARAMETER"          
                RefV        = cdbl(Lookup("Plot1_REFERENCE",T3,"0"))
                Refp        = cdbl(Lookup("Plot1_position",T3,"0"))
                Scale       = cdbl(Lookup("Plot1_scale",T3,"0"))
                Y_min       = RefV - (Scale * RefP)
                Y_max       = RefV + (Scale * (10 - RefP))
          CASE "PIM"
                Y_min     = cdbl(Lookup("Plot1_Y_min",T3,"-160"))
                Y_max     = cdbl(Lookup("Plot1_Y_max",T3,"-60"))
       END SELECT  
      

     

curve_count = 0
AxisID      = "2DAxis"&plot
AXIS        = 1 
Plot_Limiton = Lookup("plot1_curve1_limiton",T3,"1")
chstr=""
' for each item
CALL prePage_Processing(AutoActPath&"Report one plot overlay.TDR",REPORT_PATH)   ' Load Requested Report
call add_page_number()


w = cdbl(Lookup("Template_dwidth",T3,"8.5") )
h = cdbl(Lookup("Template_dHeight",T3,"11.0") )

IF (w > h) THEN 'landscape
      PIXW =792
      PIXH =550
Call GraphObjOpen("2DAxis1")
   D2LegPosX        = 10
   D2AxisLeft =10
   D2LegSizeGlX=80
Call GraphObjClose("2DAxis1")
ELSE 'portrait
Call GraphObjOpen("2DAxis1")
    D2LegPosX        = 15
    D2AxisLeft =15
    D2LegSizeGlX=75
Call GraphObjClose("2DAxis1")

      PIXW =550
      PIXH =792
END IF


startpagenum =L1
IF cint(UPC(Lookup("PREVIEW",T3,"0"))) = 1 THEN
 'CALL  LABELS(TT,Y_UNIT,X_UNIT,AxisType) 
CALL Graphobjnew("FreeText", "title")
        CALL GRAPHObjOpen("title")
          TXTTXT  = "Multi Item Overlay Plot"
          TxtPosX = 50
          TxtPosY = 95
          TXTrelpos = "center"
          txtsize = 4
        CALL GRAPHObjClose("title")

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
        Call PicExport(REPORT_path,"PNG",false,PIXH,PIXW,"rgb 24",,"NoCompression")  'Exports the current sheet as WMF file
        T7 = REPORT_path
ELSE 'PDF
            PMN  = Lookup("ITEM0_MN",T3,"")
            PSN  = Lookup("ITEM0_SN",T3,"")
            PTT  = Lookup("ITEM0_TT",T3,"")
            Y=0
            pagecount=1
        WHILE ((Lookup("ITEM"&X&"_TT",T3,"")  <> "") AND (curve_count < 250))
              IF (PAGE = "ALL") AND(Lookup("ITEM9_TT",T3,"")  <> "") THEN
                LABELS = "NO"
              ELSE
                LABELS = "YES"
              END IF
'                call debug ("LABELS "&LABELS)
            ' keep track of which group we are using
            chstart = GlobUsedChn
            IF chstart > 0 THEN 
              chstart =chstart +1 
            END IF
        
            TT  = Lookup("ITEM"&X&"_TT",T3,"")
            MN  = Lookup("ITEM"&X&"_MN",T3,"")
            SN  = Lookup("ITEM"&X&"_SN",T3,"")
            RUN = Lookup("ITEM"&X&"_RUN",T3,"")
            
            CALL DATAFILELOADSEL(Lookup("ITEM"&X&"_path",T3,""),"TDMS",RUN& "/*","")  

            call debug (TT &" "&MN&" "&SN&" "&RUN)
            call debug (PMN &" = "&MN&" ---"&PSN&" = "&SN)
            call debug (Lookup("ITEM"&X&"_path",T3,""))
            
            IF (PAGE <> "ALL") AND ((PMN <> MN ) OR( PSN <> SN) OR( PTT <> TT)) THEN
                     call Text_box(PMN& "  "&PSN,50,89,3,"center",axisid)
                     CALL PAGHEEXTRAS(X_UNIT,Y_UNIT,AxisID, Auto_X, X_MIN, X_MAX,Auto_Y, Y_MIN, Y_MAX,PLOT,curve_count-Y,TT,UPC(AXISTYPE))
                     pagecount=pagecount +1
                     l1=l1+1
                     CALL PICFILEAPPEND(AutoActPath&"Report one plot overlay.TDR")   ' Load Requested Report
                     Call GraphSheetNGet(pagecount+startpagenum-1)

                     Call GraphSheetRename(GraphSheetName,"Spartan Report " & (pagecount+startpagenum-1))
                     CALL GraphSheetRefSet("Spartan Report " & (pagecount+startpagenum-1))
                    
                    curve_count=0
              END IF
              
              
             SELECT CASE UPC(TT)
'-------------------------------------------------------------------------------
'-------------------------------------------------------------------------------
              CASE "S PARAMETER"
                           CALL DEBUG("S PARAMETER OVERLAY")
                         ' Change to desired frequency units
                          Frequency = Calc_X_Units ("Frequency", X_Unit,chstart)
                          CAL_ch = -1
                      
                          SELECT CASE UPC(Format) ' Depending on SXX get channel or transform to proper format
                              CASE "PHASE"
                              baseformat = "PHASE"
                                Dataname = SXX&" PHASE"
                                CAL_ch = CNo(Dataname,chstart)
                              CASE "DELAY"
                              baseformat = "PHASE"
                                Dataname = Transform_Data (SXX&" PHASE", "DELAY", "",chstart )
                                CAL_ch = CNo(SXX&" PHASE",chstart)
                              CASE "EXPANDED PHASE"
                              baseformat = "PHASE"
                                Dataname = Transform_Data (SXX&" PHASE", "EXPANDED PHASE", "",chstart )
                                CAL_ch = CNo(SXX&" PHASE",chstart) 
                               CASE "LOSSa", "ISOLATION", "RETLOSS"  
                        ' If a user is plotting in the Loss format, i.e. Return Loss, Isolation, or Insertion Loss, the template should 
                        ' be looking for the opposite limit, i.e. if looking to plot an upper limit it should look for lower limits.
                          IF (CNO(Add_group(SXX&" MAG LLimit"),chstart)>0) THEN
                             Call ChnPropSet(CNO(Add_group(SXX&" MAG LLimit"),chstart), "name", SXX&" MAG ULimittemp")
                            END IF
                          IF (CNO(Add_group(SXX&" MAG ULimit"),chstart)>0) THEN
                             Call ChnPropSet(CNO(Add_group(SXX&" MAG ULimit"),chstart), "name", SXX&" MAG LLimit")
                            END IF
                          IF (CNO(Add_group(SXX&" MAG ULimittemp"),chstart)>0) THEN
                             Call ChnPropSet(CNO(Add_group(SXX&" MAG ULimittemp"),chstart), "name", SXX&" MAG ULimit")
                            END IF
                          baseformat = "MAG"
                          Dataname = Transform_Data (SXX&" MAG", Format, "",chstart )
 
                              CASE ELSE
                              baseformat = "MAG"
                                Dataname = Transform_Data (SXX&" MAG", Format, "",chstart ) 
                                CAL_ch = CNo(SXX&" MAG",chstart)
                          END SELECT
                          
                          IF (CAL_ch > 0) THEN
                                PicDefByIdent = 1       ' Name-Oriented channel referencing
                                LABEL=""
                                call debug (PAGE &" "&prefix&" "&TAG&" "&LABEL)
                                IF ( LABELS = "YES") THEN
                                    TAG=SAFE_grouppropget(groupcount,"STEP_TAG")
                                    IF (PAGE <> "ALL") THEN
                                      prefix=""
                                      ELSE
                                      prefix=MN&" "&SSNstr(SN)&" "
                                    END IF
                                    IF TAG ="" THEN
                                      LABEL=prefix&RUN
                                    ELSE 
                                      LABEL=prefix&TAG
                                    END IF
                                    call debug (PAGE &" "&prefix&" "&TAG&" "&LABEL)
                                
                                    
                                END IF
                                ' Create a channel that is zoomed if user wants that
                                Adj_Frequency = AutoX_Adjust ( AxisID, Frequency, Frequency, AUTO_X, X_MIN,X_MAX,AUTO_Y,"",chstart)              ' Zoom on X if required
                                Dataname      = AutoX_Adjust ( AxisID, Dataname, Frequency,  AUTO_X, X_MIN,X_MAX,AUTO_Y,"",chstart)              ' Zoom on X if required

                                IF ((Plot_Limiton = "1") AND (curve_count=0)) THEN 
                                    call debug (curve_count &" "&MN&" "&SN)
                                    Y=curve_count
                                    curve_count = Add_Limit("LLIMIT",curve_count,sxx,Format,chstart,AxisID,frequency,AUTO_X, X_MIN,X_MAX,AUTO_Y,"",Adj_Frequency,plot,   Dataname,"0"       ,AXIS,"","YES",SXX&" Lower Limit")
                                    curve_count = Add_Limit("ULIMIT",curve_count,sxx,Format,chstart,AxisID,frequency,AUTO_X, X_MIN,X_MAX,AUTO_Y,"",Adj_Frequency,plot,   Dataname,"0"       ,AXIS,"","YES",SXX&" Upper Limit")
                                    curve_count = Check_filter_limits(Format,curve_count,sxx,baseformat,chstart,AxisID,frequency,AUTO_X, X_MIN,X_MAX,AUTO_Y,"",Adj_Frequency,plot,Dataname,"",AXIS,"")
                                     Y=curve_count-y
                                END IF 'END  Limit
                                Index         = Add_Curve    ( AxisID, curve_count, Adj_Frequency , Dataname,Auto_X, X_min,X_Max,Auto_Y,chstart,plot,"0",AXIS,Assign_Curve_Color_old (curve_count),LABELS,LABEL) ' Now add the data, may be new zoomed CH
                               curve_count = curve_count +1 
                                                    
                        END IF 'END if data exists
                              CALL DEBUG("EXIT - S PARAMETER OVERLAY")
  
'-------------------------------------------------------------------------------
'-------------------------------------------------------------------------------
                  CASE "PIM"  
'                        CALL DEBUG("PIM OVERLAY")
'                        CALL debug(IM&" "&format&" "&axistype)
                        SELECT CASE UPC(Format)
                            CASE "DBM"
                                  Dataname = Add_group(IM&" POWER 1")
                                  limitname = Add_group("ref limit 1")
                            CASE "DBC"
                                  Dataname = Add_group(IM&" POWER 2")
                                  limitname = Add_group("ref limit 2")
                        END SELECT

                            PicDefByIdent = 1       ' Name-Oriented channel referencing
   
                        SELECT CASE UPC(AXISTYPE)
                            CASE "FREQUENCY","SWEPT FREQ", "SWEPT FREQUENCY"
                            CALL DEBUG("PIM OVERLAY-FREQUENCY")
                           LABEL=""
                            IF ( LABELS = "YES") and  (Lookup("ITEM9_TT",T3,"")  <> "") THEN
                                    TAG=SAFE_grouppropget(groupcount,"STEP_TAG")
                                    IF (PAGE <> "ALL") THEN
                                      prefix=""
                                      ELSE
                                      prefix=MN&" "&SSNstr(SN)&" "
                                    END IF
                                    IF ((TAG ="") OR (tag="-")) THEN
                                      LABEL=prefix&RUN
                                    ELSE 
                                      LABEL=prefix&TAG
                                    END IF
                                   
                            END IF
                                  Xchannel = Calc_X_Units (IM&" Frequency", X_Unit,chstart)  ' Change TO desired units
                                  Num_Sweeps = Split_sweeps(dataname,xchannel,chstart,x_unit)
        
                                  if num_sweeps >249 then 
                                    num_sweeps =249
                                  end if
                                  CAL_ch = CNo(Dataname,chstart)    
                                  FOR Xs = 1 TO Num_sweeps 
                                      IF Xs =1 and  (Lookup("ITEM9_TT",T3,"")  <> "") THEN
                                        LABELS = "YES"
                                        UPCOLOR="blue"
                                        DNCOLOR="red"
                                        uplabel = " UP"
                                        dnlabel = " DN"
                                      ELSE
                                        LABELS = "NO"
                                        uplabel = ""
                                        dnlabel=""
                                      END IF
                                      ' Create a channel that is zoomed IF user wants that
                                      Adj_XCHANNEL  = AutoX_Adjust ( AxisID, Add_group("tx1 frequency scan"),Add_group("tx1 frequency scan"), AUTO_X, X_MIN,X_MAX,AUTO_Y,"",chstart)              ' Zoom on X IF required
                                      Dataname      = AutoX_Adjust ( AxisID, Add_group("tx1 sweep "&xs), Add_group("tx1 frequency scan"),  AUTO_X, X_MIN,X_MAX,AUTO_Y,"",chstart)              ' Zoom on X IF required
                                      Index         = Add_Curve    ( AxisID, curve_count, Adj_XCHANNEL , Dataname,Auto_X, X_min,X_Max,Auto_Y,chstart,PLOT,"0",AXIS,UPCOLOR,LABELS,LABEL&uplabel) ' Now add the data, may be new zoomed CH
                                      curve_count = curve_count +1
                                      ' Create a channel that is zoomed IF user wants that
                                      Adj_XCHANNEL  = AutoX_Adjust ( AxisID, Add_group("tx2 frequency scan"),Add_group("tx2 frequency scan"), AUTO_X, X_MIN,X_MAX,AUTO_Y,"",chstart)              ' Zoom on X IF required
                                      Dataname      = AutoX_Adjust ( AxisID, Add_group("tx2 sweep "&xs), Add_group("tx2 frequency scan"),  AUTO_X, X_MIN,X_MAX,AUTO_Y,"",chstart)              ' Zoom on X IF required
                                      Index         = Add_Curve    ( AxisID, curve_count, Adj_XCHANNEL , Dataname,Auto_X, X_min,X_Max,Auto_Y,chstart,PLOT,"0",AXIS,DNCOLOR,LABELS,LABEL&dnlabel) ' Now add the data, may be new zoomed CH
                                      curve_count = curve_count +1
                                  
                                  
                                  IF ((Plot_Limiton = "1") AND (curve_count<=2))  THEN  ' Check TO see IF we are plotting Limits
                                      Y=curve_count
                                      Adj_XCHANNEL  = AutoX_Adjust ( AxisID, Xchannel,Xchannel, AUTO_X, X_MIN,X_MAX,AUTO_Y,"",chstart)              ' Zoom on X IF required
                                      Dataname      = AutoX_Adjust ( AxisID, limitname, Xchannel,  AUTO_X, X_MIN,X_MAX,AUTO_Y,"",chstart)              ' Zoom on X IF required
                                      Index         = Add_Curve    ( AxisID, curve_count, Adj_XCHANNEL , Dataname,Auto_X, X_min,X_Max,Auto_Y,chstart,PLOT,"0",AXIS,"blACK","YES","Specification Limit" ) ' Now add the data, may be new zoomed CH
                                      curve_count = curve_count +1
                                      Y=curve_count-y 
                                  END IF
                                NEXT
                                
                          CASE "TIME","FIXED PAIR"
'                                  CALL DEBUG("PIM OVERLAY-TIME")
                                    LABEL=""
                                    IF ( LABELS = "YES") THEN
                                            TAG=SAFE_grouppropget(groupcount,"STEP_TAG")
                                            IF ((TAG ="") OR (tag="-")) THEN
                                              LABEL=MN&" "&SSNstr(SN)&" "&RUN
                                            ELSE 
                                              LABEL=MN&" "&SSNstr(SN)&" "&TAG
                                            END IF
                                            
                                    END IF
                                          Xchannel = Calc_X_Units ("Elapsed Time", X_Unit,chstart)  ' Change TO desired units
                                  CAL_ch = CNo(Dataname,chstart)  
'         call debug (LABEL &" "&MN&" "&SN)
                                  ' Create a channel that is zoomed IF user wants that
                                  Adj_XCHANNEL  = AutoX_Adjust ( AxisID, XCHANNEL,XCHANNEL, AUTO_X, X_MIN,X_MAX,AUTO_Y,"",chstart)              ' Zoom on X IF required
                                  Dataname      = AutoX_Adjust ( AxisID, Dataname, XCHANNEL,  AUTO_X, X_MIN,X_MAX,AUTO_Y,"",chstart)              ' Zoom on X IF required
                                  Index         = Add_Curve    ( AxisID, curve_count, Adj_XCHANNEL , DatanamE,Auto_X, X_min,X_Max,Auto_Y,chstart,PLOT,"0",AXIS,Assign_Curve_Color_old (curve_count),LABELS,LABEL) ' Now add the data, may be new zoomed CH
                                  curve_count = curve_count +1
                                  IF ((Plot_Limiton = "1") AND (curve_count=1))  THEN  ' Check TO see IF we are plotting Limits
                                      Y=curve_count
                                      Adj_XCHANNEL  = AutoX_Adjust ( AxisID, Xchannel,Xchannel, AUTO_X, X_MIN,X_MAX,AUTO_Y,"",chstart)              ' Zoom on X IF required
                                      CALL Set_limit_samples(limitname,chstart)
                                      Dataname      = AutoX_Adjust ( AxisID, limitname, Xchannel,  AUTO_X, X_MIN,X_MAX,AUTO_Y,"",chstart)              ' Zoom on X IF required
                                      Index         = Add_Curve    ( AxisID, curve_count, Adj_XCHANNEL ,Dataname,Auto_X, X_min,X_Max,Auto_Y,chstart,PLOT,"0",AXIS,"blACK","YES","Specification Limit" ) ' Now add the data, may be new zoomed CH
                                      curve_count = curve_count +1
                                       Y=curve_count-y 
                                  END IF
                                  Call GraphObjOpen(AxisID)
                                        Call GraphObjOpen(D2AxisxObj(1))
                                          D2AxisXFormat    = "d.d"
                                        Call GraphObjClose(D2AxisxObj(1))
                                  Call GraphObjClose(AxisID) 
                    END SELECT  
'-------------------------------------------------------------------------------
'-------------------------------------------------------------------------------
               END SELECT
          x=x+1  
          call debug ("next item- "&Lookup("ITEM"&X&"_TT",T3,"")&" "&Lookup("ITEM"&X&"_mn",T3,"") )
          PMN = MN
          PSN = SN
        WEND      
        IF (PAGE <> "ALL") THEN
            call Text_box(PMN& "  "&PSN,50,89,3,"center",axisid)
        END IF
        CALL PAGHEEXTRAS(X_UNIT,Y_UNIT,AxisID, Auto_X, X_MIN, X_MAX,Auto_Y, Y_MIN, Y_MAX,PLOT,curve_count-Y,TT,UPC(AXISTYPE),sxx)
        CALL POSTPage_Processing(AutoActPath&"Report one plot overlay.TDR",REPORT_PATH)
        
        call debug ("CREATED REPORT:"&REPORT_PATH)
        
eND if
 
T1 = T7   ' T1 must be set to the file path of the generated report.
END SUB
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
  