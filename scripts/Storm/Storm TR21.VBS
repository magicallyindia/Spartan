'-- VBS script file
'© 2009 Summitek Instruments All Rights Reserved
'-- This script will create a table PDF

Option Explicit         ' This setting requires explicit variable allocation in script.
Sub Main()

  AutoIgnoreError = 1     ' 1 turns off any error popups. 0 Enables popups
  PicDefByIdent = 1 ' Name-Oriented channel referencing

  ScriptInclude (AutoActPath&"\DD Lib.vbs") ' Common FunctionS

  Dim ReportDirectory, ReportName, XYPointsStrings, ColumnsPerPage, TestType
  Dim NameVSWR1, NameLoss, NameDelay, NamePhaseLow, NamePhaseHigh, NameVSWR2
  Dim TTop, TBottom, TLeft, TRight
  Dim RowLabelStrings, X, Y, Pages, RowsPerPage, TotalRows
  Dim sTableLabel, StartPageNumber, ChannelStart, Frequency, F
  Dim fl, fld, fd, cw

  'Call Debug("Enter Storm TR21")
  ' These T variables are For the Spartan Script Engine to use.
  ReportDirectory = Lookup("T2",T3,"")   ' T2 has the report directory.  Put your report here.
  sTableLabel = Lookup("sTableLabel",T3,"") ' sTableLable is the label provided by the user.
  TestType = Lookup("T8",T3,"")

  If sTableLabel = "" Then
    sTableLabel = "Storm TR21"
  End If

  Randomize ' Initialize the Random number generator

  RowsPerPage = 20
  TTop        = 100 - 72.4
  TBottom     = 26
  TLeft       = 5.88
  TRight      = 5.88
  StartPageNumber = L1

  Call PREPage_Processing("Storm TR21.tdr", ReportName)
  Call Load_Table_Data(XYPointsStrings, RowLabelStrings, ColumnsPerPage, TotalRows, Lookup("T3",T3,""))
  Call Create_Pages(XYPointsStrings, RowLabelStrings, ColumnsPerPage, TotalRows, RowsPerPage, "Storm TR21.tdr", "", TTop, TBottom, TLeft, TRight, 0, "Verdana", 1.2, False)

  Select Case(UPC(Lookup("T7",T3,"")))
    Case "PNG"
      ReportName = ReportDirectory&"\"&sTableLabel&" "&CStr(INT(65535*Rnd()))&".png"
      Call PicUpdate
      Call PicExport(ReportName, "PNG", False, 792, 550, "RGB 24", , "NoCompression")  'Exports the current sheet as WMF file
      T7 = ReportName

    Case Else 'PDF
      If (TestType <> "S Parameter") Then
        T1 = "The data file test types are invalid for this datasheet. Please select only S Parameter data files for the Storm TR6 Template."
        T10 = "True" ' Set error variable to true
        Exit Sub
      End If

      ChannelStart = GlobUsedChn
      If ChannelStart > 0 Then
        ChannelStart = ChannelStart + 1
      End If

      ReportName = ReportDirectory&"\"&sTableLabel&" "&CStr(Int(65535*Rnd()))&".pdf"
      Call DataFileLoadSel(Lookup("T5",T3,""), "TDMS", Lookup("T6",T3,"")& "/*","")

      Frequency     = Add_Group("Frequency")
      NameDelay     = TransForm_Data ("S21 Phase", "Phase", "",1 )
      NameDelay     = TransForm_Data ("S21 Phase ULimit", "Phase", "",1 )
      NameLoss      = TransForm_Data ("S21 Mag LLimit", "Loss", "",1 )
      NameVSWR1     = TransForm_Data ("S11 Mag ULimit", "SWR", "",1 )
      NameVSWR2     = TransForm_Data ("S22 Mag ULimit", "SWR", "",1 )
      NamePhaseLow  = TransForm_Data ("S12 Phase LLimit", "Phase", "",1 )
      NamePhaseHigh = TransForm_Data ("S12 Phase ULimit", "Phase", "",1 )

      ChnCharacter(NamePhaseLow)
      ChnCharacter(NamePhaseHigh)

      Call Debug("NamePhaseLow "&NamePhaseLow)
      Call Debug("NamePhaseHigh "&NamePhaseHigh)
      Call Debug("NameVSWR1 "&NameVSWR1)
      Call Debug("NameVSWR2 "&NameVSWR2)
      
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

      Pages = ((TotalRows) \ RowsPerPage)
      If ((TotalRows) Mod RowsPerPage) > 0 Then
      Pages = Pages +1
      End If


      For X = 1 To Pages ' How many sheets?
      ' Make sure we are referencing that sheet
      GraphSheetRefSet("Spartan Report " & (X + StartPageNumber - 1))

      'Operator Initials
      Call GraphObjNew("FreeText", "OP"&X)
      Call GraphObjOpen("OP"&X)
        '------------------- Text -----------------------------
        TxtTxt           = Safe_GroupPropGet(GroupCount - 1, Lookup("FieldID_5", T3, ""))
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 87
        TxtPosY          = 20
        TxtAng           = 0
        TxtRelPos        = "Right"
      Call GraphObjClose("OP"&X)

      'Customer
      Call GraphObjNew("FreeText", "Cust"&X)
      Call GraphObjOpen("cust"&X)
        '------------------- Text -----------------------------
        TxtTxt           = Safe_GroupPropGet(GroupCount - 1, Lookup("FieldID_1", T3, ""))
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 25
        TxtPosY          = 84.285
        TxtAng           = 0
        TxtRelPos        = "Right"
      Call GraphObjClose("Cust"&X)

      'Contract Number
      Call GraphObjNew("FreeText", "CNum"&X)
      Call GraphObjOpen("CNum"&X)
        '------------------- Text -----------------------------
        TxtTxt           = Safe_GroupPropGet(GroupCount - 1, Lookup("FieldID_2", T3, ""))
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 25
        TxtPosY          = 81.85
        TxtAng           = 0
        TxtRelPos        = "Right"
      Call GraphObjClose("CNum"&X)

      'Job Number
      Call GraphObjNew("FreeText", "JNum"&X)
      Call GraphObjOpen("JNum"&X)
        '------------------- Text -----------------------------
        TxtTxt           = Safe_GroupPropGet(GroupCount - 1, Lookup("FieldID_3", T3, ""))
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 25
        TxtPosY          = 79.49
        TxtAng           = 0
        TxtRelPos        = "Right"
      Call GraphObjClose("JNum"&X)

      'Revision
      Call GraphObjNew("FreeText", "Rev"&X)
      Call GraphObjOpen("Rev"&X)
        '------------------- Text -----------------------------
        TxtTxt           = Safe_GroupPropGet(GroupCount-1,Lookup("fieldID_4",T3,""))
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 70
        TxtPosY          = 81.95
        TxtAng           = 0
        TxtRelPos        = "Right"
      Call GraphObjClose("Rev"&X)

      'Date
      Call GraphObjNew("FreeText", "Date"&X)
      Call GraphObjOpen("Date"&X)
        '------------------- Text -----------------------------
        TxtTxt           = SpartanDateTime(cdbl(Safe_GroupPropGet(GroupCount - 1, "Start_timestamp")), "MM/DD/YYYY")
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 25
        TxtPosY          = 77.11905
        TxtAng           = 0
        TxtRelPos        = "Right"
      Call GraphObjClose("Date"&X)

      'Model Number
      Call GraphObjNew("FreeText", "MN"&X)
      Call GraphObjOpen("MN"&X)
        '------------------- Text -----------------------------
        TxtTxt           = RootPropGet("Model_Number")
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 70
        TxtPosY          = 84.28571
        TxtAng           = 0
        TxtRelPos        = "Right"
      Call GraphObjClose("MN"&X)

      'Frequency
      Call GraphObjNew("FreeText", "Frequency"&X)
      Call GraphObjOpen("Frequency"&X)
        '------------------- Text -----------------------------
        TxtTxt           = Set_X_Unit(safe_chnpropget(Frequency,"minimum"),"GHZ")& " - "& Set_X_Unit(safe_chnpropget(Frequency,"MAXIMUM"),"GHZ")&" GHz"
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 70
        TxtPosY          = 79.5238
        TxtAng           = 0
        TxtRelPos        = "Right"
      Call GraphObjClose("Frequency"&X)

      'VSWR
      Call GraphObjNew("FreeText", "VSWR"&X)
      Call GraphObjOpen("VSWR"&X)
        '------------------- Text -----------------------------
        If (NameVSWR1 = "") Then
          TxtTxt         = "No Limit"
        Else
          TxtTxt         = SafeFormatNumber(chd(1, NameVSWR1), 2)
        End If
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 30.88
        TxtPosY          = 71
        TxtAng           = 0
        TxtRelPos        = "Cent."
      Call GraphObjClose("VSWR"&X)

      'VSWR2
      Call GraphObjNew("FreeText", "VSWER2"&X)
      Call GraphObjOpen("VSWR2"&X)
        '------------------- Text -----------------------------
        If (NameVSWR2 = "") Then
          TxtTxt         = "No Limit"
        Else
          TxtTxt         = SafeFormatNumber(chd(1, NameVSWR2), 2)
        End If
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 48.61
        TxtPosY          = 71
        TxtAng           = 0
        TxtRelPos        = "Cent."
      Call GraphObjClose("VSWR2"&X)

      'Loss
      Call GraphObjNew("FreeText", "Loss"&X)
      Call GraphObjOpen("Loss"&X)
        '------------------- Text -----------------------------
        If (NameLoss = "") Then
          TxtTxt = "No Limit"
        Else
          TxtTxt           = SafeFormatNumber(chd(1,NameLoss),2)
        End If
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 66.2
        TxtPosY          = 71
        TxtAng           = 0
        TxtRelPos        = "Cent."
      Call GraphObjClose("Loss"&X)

      'Phase
      Call GraphObjNew("FreeText", "Phase"&X)
      Call GraphObjOpen("Phase"&X)
        '------------------- Text -----------------------------
        Call Debug(NamePhaseHigh &chd(1, NamePhaseHigh))
        If (NamePhaseHigh = "") Then
          TxtTxt         = "No Limit"
        Else
          F              = " "" "&NamePhaseHigh&" "" "
          F              = "not isnull(Ch( "&F&"))"
          fd             = Chd(ChnFind(F), NamePhaseHigh)
          fl             = " "" "&NamePhaseLow&" "" "
          fl             = "not isnull(Ch( "&fL&"))"
          fld            = Chd(ChnFind(fl), NamePhaseLow)
          If (FD = -fLD) Then
            TxtTxt       = "+/- "&SafeFormatNumber(fd, 0)& "° at "& SafeFormatNumber(Set_X_Unit(Chd(ChnFind(fl), Frequency),"GHz"), 0)&" GHz"
          Else
            TxtTxt       = SafeFormatNumber(fd, 0)& "° / "  & SafeFormatNumber(fld, 0)&"° at "& SafeFormatNumber(Set_X_Unit(chd(ChnFind(fl), Frequency), "GHz"),0)&" GHz"
          End If
        End If
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 84.5
        TxtPosY          = 71
        TxtAng           = 0
        TxtRelPos        = "Cent."
      Call GraphObjClose("Phase"&X)

      'Frames
      Call GraphObjNew("FreeFrame", "LBox"&x)
      Call GraphObjOpen("LBox"&X)
        '------------------- Frame --------------------------
        AreaLineColor    = "Black"
        AreaLineColorRGB = 33554432
        AreaLineWidth    = "Min"
        AreaLineType     = "Solid"
        AreaBackColor    = "White"
        AreaBackRGB      = 50331647
        AreaBackRGB2     = 15263976
        AreaBackFMode    = "Vertical"
        AreaBackFVariant = "From Bottom"
        '------------------- Shadow -----------------------
        AreaShadow       = "NoShadow"
        AreaShadowColor  = "Other Colors"
        AreaShadowRGB    = 8421504
        AreaShadowDx     = 1
        AreaShadowDy     = 1
        '------------------- Position -----------------------
        AreaLinePt(1)    = 5.72
        AreaLinePt(2)    = 69.97
        AreaLinePt(3)    = 23.49
        AreaLinePt(4)    = 74.51
      Call GraphObjClose("Lbox"&X)

      cw=17.65
      Call GraphObjNew("FreeFrame", "L1Box"&x)
      Call GraphObjOpen("L1Box"&X)
        '------------------- Frame --------------------------
        AreaLineColor    = "Black"
        AreaLineColorRGB = 33554432
        AreaLineWidth    = "Min"
        AreaLineType     = "Solid"
        AreaBackColor    = "White"
        '------------------- Shadow -----------------------
        AreaShadow       = "NoShadow"
        '------------------- Position -----------------------
        AreaLinePt(1)    = 23.49
        AreaLinePt(2)    = 72.4
        AreaLinePt(3)    = 23.49 + 1 * cw
        AreaLinePt(4)    = 74.51
      Call GraphObjClose("L1Box"&X)

      Call GraphObjNew("FreeFrame","L2box"&x)
      Call GraphObjOpen( "L2box"&X)
        '------------------- Frame --------------------------
        AreaLineColor    = "Black"
        AreaLineColorRGB = 33554432
        AreaLineWidth    = "Min"
        AreaLineType     = "Solid"
        AreaBackColor    = "White"
        AreaBackRGB      = 50331647
        AreaBackRGB2     = 15263976
        AreaBackFMode    = "Vertical"
        AreaBackFVariant = "From Bottom"
        '------------------- Shadow -----------------------
        AreaShadow       = "NoShadow"
        AreaShadowColor  = "Other Colors"
        AreaShadowRGB    = 8421504
        AreaShadowDx     = 1
        AreaShadowDy     = 1
        '------------------- Position -----------------------
        AreaLinePt(1)    =  23.49 + 1 * cw
        AreaLinePt(2)    = 72.4
        AreaLinePt(3)    = 23.49 + 2 * cw
        AreaLinePt(4)    = 74.51
      Call GraphObjClose("L2Box"&X)

      Call GraphObjNew("FreeFrame", "L3Box"&X)
      Call GraphObjOpen("L3Box"&X)
        '------------------- Frame --------------------------
        AreaLineColor    = "Black"
        AreaLineColorRGB = 33554432
        AreaLineWidth    = "Min"
        AreaLineType     = "Solid"
        AreaBackColor    = "White"
        AreaBackRGB      = 50331647
        AreaBackRGB2     = 15263976
        AreaBackFMode    = "Vertical"
        AreaBackFVariant = "From Bottom"
        '------------------- Shadow -----------------------
        AreaShadow       = "NoShadow"
        AreaShadowColor  = "Other Colors"
        AreaShadowRGB    = 8421504
        AreaShadowDx     = 1
        AreaShadowDy     = 1
        '------------------- Position -----------------------
        AreaLinePt(1)    = 23.49 + 2 * cw
        AreaLinePt(2)    = 72.4
        AreaLinePt(3)    = 23.49 + 3 * cw
        AreaLinePt(4)    = 74.51
      Call GraphObjClose("L3Box"&X)

      Call GraphObjNew("FreeFrame", "L4Box"&X)
      Call GraphObjOpen("L4Box"&X)
        '------------------- Frame --------------------------
        AreaLineColor    = "Black"
        AreaLineColorRGB = 33554432
        AreaLineWidth    = "Min"
        AreaLineType     = "Solid"
        AreaBackColor    = "White"
        AreaBackRGB      = 50331647
        AreaBackRGB2     = 15263976
        AreaBackFMode    = "Vertical"
        AreaBackFVariant = "From Bottom"
        '------------------- Shadow -----------------------
        AreaShadow       = "NoShadow"
        AreaShadowColor  = "Other Colors"
        AreaShadowRGB    = 8421504
        AreaShadowDx     = 1
        AreaShadowDy     = 1
        '------------------- Position -----------------------
        AreaLinePt(1)    = 23.49 + 3 * cw
        AreaLinePt(2)    = 72.4
        AreaLinePt(3)    = 23.49 + 4 * cw
        AreaLinePt(4)    = 74.51

      Call GraphObjClose("L4Box"&X)

      Call GraphObjNew("FreeText", "L1T"&X)
      Call GraphObjOpen("L1T"&X)
        '------------------- Text -----------------------------
        TxtTxt           = "VSWR (S11)"
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 32.3
        TxtPosY          = 73.5
        TxtAng           = 0
        TxtRelPos        = "Cent."
      Call GraphObjClose("L1T"&X)

      Call GraphObjNew("FreeText", "L2T"&X)
      Call GraphObjOpen("L2T"&X)
        '------------------- Text -----------------------------
        TxtTxt           = "VSWR (S22)"
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 50
        TxtPosY          = 73.5
        TxtAng           = 0
        TxtRelPos        = "Cent."
      Call GraphObjClose("L2T"&X)

      Call GraphObjNew("FreeText", "L3T"&X)
      Call GraphObjOpen("L3T"&X)
        '------------------- Text -----------------------------
        TxtTxt           = "Insertion Loss (S21)"
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 67.6
        TxtPosY          = 73.5
        TxtAng           = 0
        TxtRelPos        = "Cent."
      Call GraphObjClose("L3T"&X)

      Call GraphObjNew("FreeText", "L4T"&X)
      Call GraphObjOpen("L4T"&X)
        '------------------- Text -----------------------------
        TxtTxt           = "Phase (S12)"
        TxtSize          = 1.2
        TxtColor         = "Black"
        TxtFont          = "Verdana"
        '------------------- Position -----------------------
        TxtPosX          = 85.3
        TxtPosY          = 73.5
        TxtAng           = 0
        TxtRelPos        = "Cent."
      Call GraphObjClose("L4T"&X)

      Call GraphObjNew("FreeText", "Text20"&X)
      Call GraphObjOpen("Text20"&X)
        '------------------- Text -----------------------------
        TxtTxt           = "Serial Number"
        TxtFont          = "Verdana"
        TxtSize          = 1.2
        TxtColor         = "Black"
        '------------------- Position -----------------------
        TxtPosX          = 14.699
        TxtPosY          = 72.3
        TxtAng           = 0
        TxtRelPos        = "Cent."
      Call GraphObjClose("Text20"&X)
    Next
    Call POSTPage_Processing("Storm TR21.tdr", ReportName)
  End Select
  T10 = "False" ' Set the error variable to false
  Call Debug(T10)
  T1 = T7       ' T1 must be set to the file path of the generated report.
  T10 = "False" ' Set the error variable to false
'Call Debug("Exit Storm TR21")
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