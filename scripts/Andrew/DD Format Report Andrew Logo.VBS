'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 06/20/2005 14:46:50
'-- Author: James West
'-------------------------------------------------------------------------------
Option Explicit         ' This setting requires explicit variable allocation in script.

sub main()

AutoIgnoreError = 1     ' 1 turns off any error popups. 0 Enables popups
PICFRAME        = 0     ' Turn off frame around a plot
PicDefByIdent   = 1       ' Name-Oriented channel referencing
ScriptInclude (AutoActPath&"\DD Lib.vbs") 'Common functions

DIM px, S2P_OUTPUT_NAME, TAB_OUTPUT_NAME, BOTTOM, FIELD_BOTTOM, REPORT_TDR,REPORT_PATH
DIM PLOT_OUTPUT, plot_count, plot_orientation,PREVIEW,PIXW,PIXH,w,h,tempstring

t1 = "ERROR"
REPORT_PATH=Lookup("REPORT_PATH",T3,"")
'msgbox(t3)
'call debug ("Enter DD_FORMAT_REPORT")
T3 = ADD_APOST(T3)

T3 = Replace(T3, "logo.jpg", "andrew logo.jpg")

plot_count       = cint(UPC(Lookup("Plot_count",T3,"1")))
SELECT CASE (plot_count)
   CASE 1
      REPORT_TDR = "REPORT one plot"
   CASE 2
      REPORT_TDR = "REPORT TWO plot"
   CASE 4
      REPORT_TDR = "REPORT FOUR plot"
   CASE ELSE
      plot_count = 1
      REPORT_TDR = "REPORT one plot"
END SELECT

w = cdbl(Lookup("Template_dwidth",T3,"8.5") )
h = cdbl(Lookup("Template_dHeight",T3,"11.0") )

IF (w > h) THEN
 PrintTopMarg  = 0.24 
 PrintLeftMarg = 0.24 
 PrintWidth    = 10.36
 picratio = 0.775
ELSE 
 PrintTopMarg  = 0.24 
 PrintLeftMarg = 0.24 
 PrintWidth    =8.03 
 picratio = 1.29
END IF
IF (w > h) THEN
      REPORT_TDR = REPORT_TDR & " LANDSCAPE.TDR"
      PIXW =792
      PIXH =550
      plot_orientation = "LANDSCAPE"

ELSE
      REPORT_TDR = REPORT_TDR & " PORTRAIT.TDR"
      PIXW =550
      PIXH =792
      plot_orientation = "PORTRAIT"

END IF

CALL PREPage_Processing(REPORT_TDR,REPORT_PATH)
 
' fill in the header and any custom fields
BOTTOM = 4
FIELD_BOTTOM = Assign_Text_Fields (BOTTOM,REPORT_TDR)
'these calls move plot elements around based on number of custom fields
SELECT CASE UPC(REPORT_TDR)
    CASE "REPORT ONE PLOT PORTRAIT.TDR","REPORT ONE PLOT LANDSCAPE.TDR"
        CALL shift_one_plot(FIELD_BOTTOM,BOTTOM)
    CASE "REPORT TWO PLOT PORTRAIT.TDR","REPORT TWO PLOT LANDSCAPE.TDR"
         CALL shift_TWO_plot(FIELD_BOTTOM,BOTTOM,plot_orientation)
    CASE "REPORT FOUR PLOT PORTRAIT.TDR","REPORT FOUR PLOT LANDSCAPE.TDR"
         CALL shift_FOUR_plot(FIELD_BOTTOM,BOTTOM,plot_orientation)
END SELECT 

                                   ' Refresh the Plot
IF cint(UPC(Lookup("PREVIEW",T3,"0"))) = 1 THEN
call debug ("CREATED PREVIEW:"&REPORT_PATH)
    FOR px = 1 TO plot_count
 call debug (Lookup("Plot"&pX&"_STYLE",T3,"S PARAMETER"))

        SELECT CASE UPC(Lookup("Plot"&pX&"_STYLE",T3,"S PARAMETER"))
              CASE "S PARAMETER"          
                  CALL GRAPHObjOpen("Plot"&pX&"_Y_Label")
                        TXTTXT           =y_unit_label ( Lookup("Plot"&pX&"_Y_Format",T3,"dBm"),Lookup("Plot"&pX&"_Curve1_parameter",T3,"s11")) & " (" & Y_UNIT_STRING( Lookup("Plot"&pX&"_Y_Format",T3,"dBm")) & ")"
                  CALL GRAPHObjClose("Plot"&pX&"_Y_Label")
                  CALL GRAPHObjOpen("Plot"&pX&"_X_Label")
                        TXTTXT           = "Frequency (" & X_UNIT_STRING(Lookup("Plot"&pX&"_X_Unit",T3,"")) & ")"
                  CALL GRAPHObjClose("Plot"&pX&"_X_Label") 
  
             CASE "PIM"
                  CALL GRAPHObjOpen("Plot"&pX&"_Y_Label")
                      TXTTXT           =Lookup("Plot"&pX&"_Curve1_parameter",T3,"3rd")&" Order IM Power ("& Lookup("Plot"&pX&"_Y_Format",T3,"dBm")&")"
                  CALL GRAPHObjClose("Plot"&pX&"_Y_Label")
                  SELECT CASE UPC(Lookup("Plot"&pX&"_AxisType",T3,""))
                      CASE "SWEPT FREQ", "FREQUENCY","SWEPT FREQUENCY SCATTER","FREQUENCY MAX/AVG","SWEPT FREQUENCY STATISTICS SIGMA"
                          CALL GRAPHObjOpen("Plot"&pX&"_X_Label")
                              TXTTXT           = "IM Frequency ("&Lookup("Plot"&pX&"_X_Unit",T3,"")&")"
                          CALL GRAPHObjClose("Plot"&pX&"_X_Label") 
                      
                      CASE "TIME","FIXED PAIR"
                          CALL GRAPHObjOpen("Plot"&pX&"_X_Label")
                            TXTTXT           = "Time (" & X_UNIT_STRING(Lookup("Plot"&pX&"_X_Unit",T3,"")) & ")"
                          CALL GRAPHObjClose("Plot"&pX&"_X_Label") 
                      
                    END SELECT  
         END SELECT  
   NEXT   
   call picupdate
   Call PicExport(REPORT_PATH,"PNG",false,PIXH,PIXW,"rgb 24",,"NoCompression")  'Exports the current sheet as WMF file
   T7=REPORT_PATH
ELSE
    ' Create each plot
    FOR px = 1 TO plot_count
      SELECT CASE UPC(Lookup("Plot"&pX&"_STYLE",T3,"S PARAMETER"))
          CASE "S PARAMETER"
            CALL Create_Plot (pX)
          CASE "PIM"
            CALL Create_PIM_Plot(pX)
      END SELECT
    NEXT

 CALL POSTPage_Processing(REPORT_TDR,REPORT_PATH)    
 
'call debug ("CREATED REPORT:"&REPORT_PATH)
END IF

    T1 = T7

'call debug ("EXIT DD_FORMAT_REPORT")
END SUB