'-------------------------------------------------------------------------------
'-- VBS script file
'© 2009 Summitek Instruments All Rights Reserved
'-- This script will create a table PDF

Option Explicit         ' This setting requires explicit variable allocation in script.
Sub MAIN()
AutoIgnoreError = 1     ' 1 turns off any error popups. 0 Enables popups
PicDefByIdent = 1 ' Name-Oriented channel referencing

ScriptInclude (AutoActPath&"\DD Lib.vbs") ' Common FunctionS

Dim TDM_FILE, REPORT_DIRECTORY, REPORT_NAME, TestType
Dim XYPointsStrings, columnsperpage       ,freq,tempstring
Dim TTOP,TBOTTOM,TLEFT,TRIGHT,namevswr,nameloss,namedelay
Dim c_index,rowlabelstrings,X,Y,pages,rowsperpage,totalrows
Dim sTableLabel    ,startpagenum,chstart

  ' These T variables are For the Spartan Script Engine to use.
  TDM_FILE = Lookup("t1",T3,"")           ' T1 is the TDM file to load For processing.
  REPORT_DIRECTORY = Lookup("t2",T3,"")   ' T2 has the report directory.  Put your report here.
  sTableLabel = Lookup("sTableLabel",T3,"") ' sTableLable is the label provided by the user.
  TestType = Lookup("T8",T3,"")

If sTableLabel = "" Then
  sTableLabel = "Storm TR10"
End If

Randomize ' Initialize the Random number generator

  rowsperpage = 20
  TTop         = 100-72.4
  TBottom      = 26
  TLeft        = 5.88
  TRight       = 5.88
   startpagenum =L1

'  Call debug("enter stormtr10")
  Call PREPage_Processing("storm tr10.tdr",REPORT_NAME)
  Call LOAD_TABLE_DATA(XYPointsStrings,rowlabelstrings,columnsperpage,totalrows,Lookup("T3",T3,""))
  Call CREATE_PAGES(XYPointsStrings,rowlabelstrings,columnsperpage,totalrows,rowsperpage,"storm tr10.tdr","",TTOP,TBOTTOM,TLEFT,TRIGHT,0,"VERDANA",1.2,FALSE)

 Select CASE (UPC(Lookup("T7",T3,"")))
   CASE "PNG"
        REPORT_NAME = REPORT_DIRECTORY&"\"&sTableLabel&" "&CStr(INT(65535*Rnd()))&".png"
        Call picupdate
        Call PicExport(REPORT_NAME,"PNG",false,792,550,"rgb 24",,"NoCompression")  'Exports the current sheet as WMF file
        T7=REPORT_NAME
   CASE Else 'PDF

  If (TestType <> "S Parameter") Then
    T1 = "The data file test types are invalid for this datasheet. Please select only S Parameter data files for the Storm TR6 Template."
    T10 = "True" ' Set error variable to true
    Exit Sub
  End If
  
    chstart = GlobUsedChn
    If chstart > 0 Then 
       chstart =chstart +1 
    End If
    
    REPORT_NAME = REPORT_DIRECTORY&"\"&sTableLabel&" "&CStr(INT(65535*Rnd()))&".pdf"
    Call DATAFILELOADSEL(Lookup("T5",T3,"") ,  "TDMS"  ,  Lookup("T6",T3,"")& "/*","")
    
      freq=add_group("FREQUENCY")
      namedelay = TransForm_Data ("s21 PHASE", "DELAY", "",1 )
      namedelay = TransForm_Data ("s21 PHASE ulimit", "DELAY", "",1 )
      nameloss = TransForm_Data ("s21 mag llimit", "loss", "",1 )
      namevswr = TransForm_Data ("s11 mag ulimit", "swr", "",1 )
'      Call debug("namedelay "&namedelay)
'      Call debug("nameloss "&nameloss)
'      Call debug("namevswr "&namevswr)

  ' Convert to two digits of precision.
  For X = 1 To TotalRows ' skip label row
    TempString = split(XYPointsStrings(X), ",")
    For Y = 0 To UBound(TempString)
      If Y = 0 Then
        XYPointsStrings(X) = TempString(Y)
      Else
        XYPointsStrings(X) = XYPointsStrings(X)&"," &FormatNumber(CDbl(TempString(Y)), 2)
      End If
    Next
  Next

  pages =((totalrows) \ rowsperpage)
  If ((totalrows) MOD rowsperpage) >0 Then
    pages = pages +1
  End If

   
  
  For X = 1 TO pages ' How many sheets?
  
      ' Make sure we are referencing that sheet 
    GraphSheetRefSet("Spartan Report " & (X+startpagenum-1))
      Call GraphObjNew("FreeText", "op"&X)
     Call GraphObjOpen("op"&X)
        '------------------- Text -----------------------------
        TxtTxt           = safe_grouppropget(GROUPCOUNT-1,Lookup("fieldID_5",T3,""))' Operator Initials
        TxtSize          = 1.2
        TxtColor         = "black"
        TXTFONT          = "vERDANA"
        '------------------- Position -----------------------
        TxtPosX          = 87
        TxtPosY          = 20
        TxtAng           = 0
        TxtRelPos        = "right"
     Call GraphObjClose("op"&X)
 
    Call GraphObjNew("FreeText", "cust"&X)
     Call GraphObjOpen("cust"&X)
        '------------------- Text -----------------------------
        TxtTxt           = safe_grouppropget(GROUPCOUNT-1,Lookup("fieldID_1",T3,""))' customer
        TxtSize          = 1.2
        TxtColor         = "black"
        TXTFONT          = "vERDANA"
        '------------------- Position -----------------------
        TxtPosX          = 25
        TxtPosY          = 84.285
        TxtAng           = 0
        TxtRelPos        = "right"
     Call GraphObjClose("cust"&X)
     Call GraphObjNew("FreeText", "cnum"&X)
     Call GraphObjOpen("cnum"&X)
        '------------------- Text -----------------------------
        TxtTxt           = safe_grouppropget(GROUPCOUNT-1,Lookup("fieldID_2",T3,""))'contract number
        TxtSize          = 1.2
        TxtColor         = "black"
        TXTFONT          = "vERDANA"
        '------------------- Position -----------------------
        TxtPosX          = 25
        TxtPosY          = 81.85
        TxtAng           = 0
        TxtRelPos        = "right"
     Call GraphObjClose("cnum"&X)  
     Call GraphObjNew("FreeText", "jnum"&X)
     Call GraphObjOpen("jnum"&X)
        '------------------- Text -----------------------------
        TxtTxt           = safe_grouppropget(GROUPCOUNT-1,Lookup("fieldID_3",T3,""))'job number
        TxtSize          = 1.2
        TxtColor         = "black"
        TXTFONT          = "vERDANA"
        '------------------- Position -----------------------
        TxtPosX          = 25
        TxtPosY          = 79.49
        TxtAng           = 0
        TxtRelPos        = "right"
     Call GraphObjClose("jnum"&X)  
     Call GraphObjNew("FreeText", "rev"&X)
     Call GraphObjOpen("rev"&X)
        '------------------- Text -----------------------------
        TxtTxt           = safe_grouppropget(GROUPCOUNT-1,Lookup("fieldID_4",T3,""))'revision
        TxtSize          = 1.2
        TxtColor         = "black"
        TXTFONT          = "vERDANA"
        '------------------- Position -----------------------
        TxtPosX          = 70
        TxtPosY          = 81.95
        TxtAng           = 0
        TxtRelPos        = "right"
     Call GraphObjClose("rev"&X)   ' Add a DATE
     Call GraphObjNew("FreeText", "DATE"&X)
     Call GraphObjOpen("DATE"&X)
        '------------------- Text -----------------------------
        TxtTxt           =  SpartanDateTime(cdbl(SAFE_grouppropget(GROUPCOUNT-1,"Start_timestamp")),"MM/DD/YYYY")
        TxtSize          = 1.2
        TxtColor         = "black"
        TXTFONT          = "vERDANA"
        '------------------- Position -----------------------
        TxtPosX          = 25
        TxtPosY          = 77.11905
        TxtAng           = 0
        TxtRelPos        = "right"
     Call GraphObjClose("DATE"&X)
    ' Add a DATE
     Call GraphObjNew("FreeText", "MN"&X)
     Call GraphObjOpen("MN"&X)
        '------------------- Text -----------------------------
        TxtTxt           = rootpropget("Model_number")
        TxtSize          = 1.2
        TxtColor         = "black"
        TXTFONT          = "vERDANA"
        '------------------- Position -----------------------
        TxtPosX          = 70
        TxtPosY          = 84.28571
        TxtAng           = 0
        TxtRelPos        = "right"
     Call GraphObjClose("MN"&X)
        ' Add a DATE
     Call GraphObjNew("FreeText", "FREQ"&X)
     Call GraphObjOpen("FREQ"&X)
        '------------------- Text -----------------------------
        TxtTxt           = Set_X_Unit(safe_chnpropget(freq,"minimum"),"GHZ")& " - "& Set_X_Unit(safe_chnpropget(freq,"MAXIMUM"),"GHZ")&" GHz"
        TxtSize          = 1.2
        TxtColor         = "black"
        TXTFONT          = "vERDANA"
        
        '------------------- Position -----------------------
        TxtPosX          = 70
        TxtPosY          = 79.5238
        TxtAng           = 0
        TxtRelPos        = "right"
     Call GraphObjClose("FREQ"&X)
     Call GraphObjNew("FreeText", "VSWR"&X)
     Call GraphObjOpen("VSWR"&X)
        '------------------- Text -----------------------------
        If (namevswr = "") Then
        TXTTXT = "No Limit"
        Else
        TxtTxt           = SafeFormatNumber(chd(1,namevswr),2)
        End If
        TxtSize          = 1.2
        TxtColor         = "black"
        TXTFONT          = "vERDANA"
        '------------------- Position -----------------------
        TxtPosX          = 38.97
        TxtPosY          = 71
        TxtAng           = 0
        TxtRelPos        = "cent."
     Call GraphObjClose("VSWR"&X)  
     Call GraphObjNew("FreeText", "LOSS"&X)
     Call GraphObjOpen("LOSS"&X)
        '------------------- Text -----------------------------
        If (nameloss = "") Then
        TXTTXT = "No Limit"
        Else
        TxtTxt           = SafeFormatNumber(chd(1,nameloss),2)
        End If
        TxtSize          = 1.2
        TxtColor         = "black"
        TXTFONT          = "vERDANA"
        '------------------- Position -----------------------
        TxtPosX          = 61.02
        TxtPosY          = 71
        TxtAng           = 0
        TxtRelPos        = "cent."
     Call GraphObjClose("LOSS"&X)  
         Call GraphObjNew("FreeText", "DELAY"&X)
     Call GraphObjOpen("DELAY"&X)
        '------------------- Text -----------------------------
        If (namedelay = "") Then
        TXTTXT = "No Limit"
        Else
        TxtTxt           = str(chd(1,namedelay),"d.ddde")
        End If
        TxtSize          = 1.2
        TxtColor         = "black"
        TXTFONT          = "vERDANA"
        '------------------- Position -----------------------
        TxtPosX          = 83.08
        TxtPosY          = 71
        TxtAng           = 0
        TxtRelPos        = "cent."
     Call GraphObjClose("DELAY"&X)  

    
    Call GraphObjNew("FreeFrame","Lbox"&x)
    Call GraphObjOpen( "Lbox"&X)
  '------------------- Frame --------------------------
  AreaLineColor    = "black"
  AreaLineColorRGB = 33554432
  AreaLineWidth    = "min"
  AreaLineType     = "solid"
  AreaBackColor    = "white"
  AreaBackRGB      = 50331647
  AreaBackRGB2     = 15263976
  AreaBackFMode    = "Vertical"
  AreaBackFVariant = "From bottom"
  '------------------- Shadow -----------------------
  AreaShadow       = "NoShadow"
  AreaShadowColor  = "other colors"
  AreaShadowRGB    = 8421504
  AreaShadowDx     = 1
  AreaShadowDy     = 1
  '------------------- Position -----------------------
  AreaLinePt(1)    = 5.75
  AreaLinePt(2)    = 70
  AreaLinePt(3)    = 27.941
  AreaLinePt(4)    = 74.545

    Call GraphObjClose( "Lbox"&x)
         Call GraphObjNew("FreeText", "text20"&x)    
    Call GraphObjOpen("text20"&x)
  '------------------- Text -----------------------------
  TxtTxt           = "Serial Number"
  TxtFont          = "Verdana"
  TxtSize          = 1.2
  TxtColor         = "black"

  '------------------- Position -----------------------
  TxtPosX          = 16.9117647058823
  TxtPosY          = 72.3
  TxtAng           = 0
  TxtRelPos        = "cent."
Call GraphObjClose("text20"&x)
    Next
       Call POSTPage_Processing("storm tr10.tdr",REPORT_NAME)
 End Select
'Call debug("exit stormtr10")

  T1 = T7       ' T1 must be set to the file path of the generated report.
  T10 = "False" ' Set the error variable to false
End Sub

'-------------------------------------------------------------------------------
' Build the pages
'-------------------------------------------------------------------------------

Sub CREATE_PAGES(XYPointsStrings, rowlabelstrings, columnsperpage, totalrows, rowsperpage, tdr, TITLE, TTOP, TBOTTOM, TLEFT, TRIGHT, HEADING, FONT, FONTSIZE, ADJUST)

Dim pages,X,C_INDEX,tempstring,Y,rndnum,startpagenum,tablegroup,chstart,maxlen,biggest
Call Debug("CREATE_PAGES")
Call GraphSheetInfos
startpagenum =L1
  pages =((totalrows) \ rowsperpage)
  If ((totalrows) MOD rowsperpage) >0 Then 
    pages = pages +1
  End If
Call Debug("CREATE_PAGES "&PAGES)
  For X = 1 TO pages ' How many sheets?
    If tdr ="" Then
       If (x = 1) Then ' DD always has one sheet in report
         Call GraphSheetNGet(x)
         Call GraphSheetRename(GraphSheetName,"Spartan Datasheet "&L1)
       Else 
         Call GraphSheetNew("Spartan Datasheet " & (X+startpagenum-1))
       End If
             
    Else
       If (x = 1) Then
         Call GraphSheetNGet(x)
         Call GraphSheetRename(GraphSheetName,"Spartan Datasheet "&L1)
       Else
         Call PICFILEAPPEnd(autoactpath &"\"&tdr)   ' Load Requested Report
         Call GraphSheetNGet(x)
         Call GraphSheetRename(GraphSheetName,"Spartan Datasheet " & (X+startpagenum-1))
       End If

    End If

    ' Make sure we are referencing that sheet
    GraphSheetRefSet("Spartan Datasheet " & (X + startPageNum - 1))
 
    ' Add a table
     Call GraphObjNew("2D-Table", "2DTable"&X)
     Call GraphObjOpen("2DTable"&X)
            '------------------- Position -----------------------
          D2TabTop         = TTOP
          D2TabBottom      = TBOTTOM
          D2TabLeft        = TLEFT
          D2TabRight       = TRIGHT
          D2TabYDoubleLine = 0
          D2TabTxtAutoScal = 0
          D2TabNumAutoScal = 0
     Call GraphObjClose("2DTable"&X)
    
 ' Add a title
      Call GraphObjNew("FreeText", "title"&X)
      Call GraphObjOpen("title"&X)
'         '------------------- Text -----------------------------
         TxtTxt           = escat(TITLE)
        TxtFont          = FONT
        TxtSize          = 6
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
        TxtPosY          = 98
        TxtAng           = 0
        TxtRelPos        = "cent."
      Call GraphObjClose("title"&X)
      
      ' Add Copywrite
     Call GraphObjNew("FreeText", "Copywrite")
     Call GraphObjOpen("Copywrite")
         '------------------- Text -----------------------------
         TxtTxt           = "© {Year} Kaelus Inc. All Rights Reserved"
         TxtFont          = FONT
         TxtSize          = 1
         TxtColor         = "black"
         TxtColorRGB      = 0
         TxtBold          = 0
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
         TxtPosX          = 1
         TxtPosY          = 2
         TxtAng           = 0
         TxtRelPos        = "r-bot."
       Call GraphObjClose("Copywrite")

      ' Version
      Call GraphObjNew("FreeText", "Version")
       Call GraphObjOpen("Version")
         '------------------- Text -----------------------------
         TxtTxt           = "Spartan Datasheet {Version}"
         TxtFont          = FONT
         TxtSize          = 1
         TxtColor         = "black"
         TxtColorRGB      = 0
         TxtBold          = 0
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
         TxtPosX          = 99
         TxtPosY          = 2
         TxtAng           = 0
         TxtRelPos        = "l-bot."
       Call GraphObjClose("Version")

    ' Add page Number
     Call add_page_number()
     If X < PAGES Then
       L1=L1+1
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
     GraphSheetRefSet("Spartan Datasheet " & (X+startpagenum-1))
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

                  'D2HdTxtSize(Y+1)   = FONTSIZE
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
Call Debug("EXIT-CREATE_PAGES")
End Sub