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
    

  Dim ROOT_PATH
  Dim TDM_FILE, REPORT_DIRECTORY, REPORT_NAME
  Dim XYPointsStrings, columnsperpage
  Dim W,H
  Dim c_index,rowlabelstrings,X,Y,pages,rowsperpage,totalrows,pixh,pixw

  ' These T variables are for the Spartan Script Engine to use.
  TDM_FILE = Lookup("t1",T3,"")          ' T1 is the TDM file to load for processing.
  REPORT_DIRECTORY = Lookup("t2",T3,"")   ' T2 has the report directory.  Put your report here.

  Randomize ' Initialize the Random number generator
  Call PREPage_Processing("Table.tdr", REPORT_DIRECTORY)
  Call LOAD_TABLE_DATA(XYPointsStrings, rowlabelstrings, columnsperpage, totalrows, Lookup("t3",T3,""))
  
  ' Get page orientation
  W = Cdbl(Lookup("Template_dWidth", T3, "8.5"))
  H = Cdbl(Lookup("Template_dHeight", T3, "11.0"))

  If W < H Then ' WIDTH < HEIGHT
    'Portrait
    PIXW =550
    PIXH =792
    PrintWidth    =8.03
    picRatio = 1.29
  Else
    'Landscapes
    PIXW =792
    PIXH =550
    PrintWidth = 10.36
    picRatio = 0.775
  End If
  
  PrintTopMarg  = 0.24
  PrintLeftMarg = 0.24
  rowsperpage = 25

  Select Case (UPC(Lookup("t7",T3,"pdf")))
    Case "PNG"
      REPORT_NAME = REPORT_DIRECTORY&"\"&Lookup("sTableLabel",T3,"")&"_"&CStr(INT(65535*Rnd()))&".png"
      Call CreatePages(XYPointsStrings, rowlabelstrings, columnsperpage, totalrows, rowsperpage, "Table.tdr", Lookup("sTableLabel",T3,""), 2.5, "Calibri", 2, TRUE)
      Call picupdate
      Call PicExport(REPORT_NAME, "PNG", false, pixh, pixw, "rgb 24", , "NoCompression")  'Exports the current sheet as WMF file
      T7=REPORT_NAME
    Case Else 'PDF
      REPORT_NAME = REPORT_DIRECTORY&"\"&Lookup("sTableLabel",T3,"")&"_"&CStr(INT(65535*Rnd()))&".pdf"
      Call CreatePages(XYPointsStrings, rowlabelstrings, columnsperpage, totalrows, rowsperpage, "Table.tdr", Lookup("sTableLabel",T3,""), 2.5, "Calibri", 2, TRUE)
      Call POSTPage_Processing("", REPORT_NAME)
  End Select

  T1 = T7   ' T1 must be set to the file path of the generated report.
End Sub

'-------------------------------------------------------------------------------
' Create the pages
'-------------------------------------------------------------------------------

Sub CreatePages(XYPointsStrings, rowlabelstrings, columnsperpage, totalrows, rowsperpage, tdr, title, heading, font, fontSize, adjust)

  Dim pages, X, C_INDEX, tempstring, Y, rndnum, startpagenum, tablegroup, chstart, maxlen, biggest, Scaling, SW, SH, Logo_Ratio, CompanyID_Txt
  Call GraphSheetInfos
  
  ' Determine number of pages
  startpagenum = L1
  pages = ((totalrows) \ rowsperpage)
  If ((totalrows) MOD rowsperpage) >0 Then
    pages = pages + 1
  End If

  For X = 1 TO pages ' How many sheets?
    If (x = 1) Then
      Call GraphSheetNGet(x)
      Call GraphSheetRename(GraphSheetName,"Spartan Datasheet "&L1)
    Else
      Call PICFILEAPPEnd(autoactpath &"\"&tdr)   ' Load Requested Report
      Call GraphSheetNGet(x)
      Call GraphSheetRename(GraphSheetName,"Spartan Datasheet " & (X + startpagenum - 1))
    End If

    ' Make sure we are referencing that sheet
    GraphSheetRefSet("Spartan Datasheet " & (X + startPageNum - 1))

    ' Remove auto scaling
    Call GraphObjNew("2D-Table", "2DTable"&X)
    Call GraphObjOpen("2DTable"&X)
      D2TabYDoubleLine = 0
      D2TabTxtAutoScal = 0
      D2TabNumAutoScal = 0
    Call GraphObjClose("2DTable"&X)

    ' Add a title
    Call GraphObjNew("FreeText", "Title")
    Call GraphObjOpen("Title")
      TxtTxt           = escat(title)
    Call GraphObjClose("Title")

    ' Add page Number
    Call add_page_number()
    If X < PAGES Then
      L1 = L1 + 1
    End If
    
    ' Calculate actual hole size
    sw = (30/100)*PicWidthInScal
    sh = (10/100)*PicHeightInScal
    scaling = sw/sh
    logo_ratio = (cdbl(Lookup("logo_width",T3,"30"))/cdbl(Lookup("logo_height",T3,"10")))

    ' Add logo
    CompanyID_Txt = Lookup("Company", T3, "")
    If FilEx(CompanyID_txt) Then
      Call GraphObjOpen("Logo")
        MtaRelPos = "r-bot."
        MtaFileName = Insert_CR(CompanyID_txt)
        MtaPosX = 3
        MtaPosY = 97
        If scaling <  logo_ratio Then
          MtaWidth = 30
        Else
          MtaWidth = (30 * (logo_ratio/scaling))
        End If
      Call GraphObjClose("Logo")

      Call GraphObjOpen("Company")
        TxtTxt = ""
      Call GraphObjClose("Company")
    Else
      Call GraphObjOpen("Logo")
        MtaFileName = ""
      Call GraphObjClose("Logo")

      Call GraphObjOpen("Company")
        TxtTxt = escat(Insert_CR(CompanyID_txt))
      Call GraphObjClose("Company")
    End If
  Next

  chstart = GlobUsedChn
  If chstart > 0 Then
    chstart =chstart +1
  End If
  ' Create a channel For each column
  ' Later, we will assign channel For each column
  tablegroup = GroUPCreate("tablegroup",,TRUE) ' Create new group
  Call GroupDEFAULTSet(GROUPINDEXGET(tablegroup))
  c_index= ChnAlloc("column1", totalrows, columnsperpage, DataTypeString,"Text")  'Create destination For Data

  reDim maxlen((columnsperpage-1))
  biggest=0

  For Y= 0 TO (columnsperpage-1)
    maxlen(y)= len (rowlabelstrings(Y))*1.5 ' header uses bigger font
    If maxlen(y)>biggest Then
      biggest=maxlen(y)
    End If
  Next

  For Y= 0 TO (columnsperpage-1)
    Call Debug("HEADER-"&Y&" "&maxlen(y)&" "&biggest)
  Next

  ' Populate the Channels For each column
  For X= 1 TO  totalrows ' skip label row
    tempstring = SPLIT(XYPointsStrings(X),",")
    For Y= 0 TO  UBound(tempstring)
      CHT(X, c_index(Y))= tempstring(Y)
      If maxlen(y)< len (tempstring(Y)) Then
        maxlen(y)= len (tempstring(Y))
        If maxlen(y)>biggest Then
          biggest=maxlen(y)
        End If
      End If
      Call Debug("row-"&x&" "&maxlen(y)&" "&biggest)
    Next
  Next
  
  ' Populate each sheet with right data
  PicDefByIdent = 1 ' Name-Oriented channel referencing

  For X = 1 TO pages
    GraphSheetRefSet("Spartan Datasheet " & (X + startpagenum - 1))
    Call GraphObjOpen("2DTable"&X)
      D2TabAutoScalTyp = "fixed"
      D2TabBegin       = (X-1)*rowsperpage + 1
      D2TabEnd         = ((X-1)*rowsperpage) + rowsperpage
      D2TabNoDist      = 1
      D2TabGrid(1)     = 1
      D2TabGrid(2)     = 1
      D2TabTxtSize     = HEADING
      D2TabTxtFont     = FONT
      D2TabNumAutoScal = 0

      '------------------- Table --------------------------
      For Y= 0 TO  (columnsperpage-1)
        D2TabDataType(1) = "Channel"
        D2TabVariable(Y+1) = ""
        D2TabChnNAME(Y+1)      =  c_index(Y)
        If (ADJUST = TRUE) Then
          D2TabRelWidth(Y+1) = maxlen(y)/biggest
        Else
          D2TabRelWidth(Y+1) = 1
        End If
        Call Debug(Y&" "&(maxlen(y)/biggest))
          D2TabOptionalLen(Y+1)= ""
          D2TabTxtType(Y+1)  = "column defined headline"
          D2TabHeaderTxt(Y+1,1)= rowlabelstrings(Y)
          D2TabHeaderTxt(Y+1,2)= ""
          D2TabHeaderTxt(Y+1,3)= ""
          D2TabNumSize(Y+1)  = FONTSIZE
          D2TabNumFont(y+1)  = FONT
      Next
    Call GraphObjClose("2DTable"&X)
  Next
End Sub
