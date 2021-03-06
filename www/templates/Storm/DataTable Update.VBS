'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 09/15/2008 13:43:23
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.

ScriptInclude ("Spartan Base.vbs")             ' Spartan Base functions


Sub Update()
  Dim i, j
  
  Dim rows : rows = 22
  Dim cols : cols = 3

  For i=2 To rows - 1
  
    For j=2 To 2
  
      Call SpartanChnCopy("DataTable/DataTable_cell_" & i & "_1", "DataTable/DataTable_cell_" & i & "_2")
      Call ChnPropValSet("DataTable/DataTable_cell_" & i & "_1", "XPos", 50)
      Call ChnPropDel("DataTable/DataTable_cell_" & i & "_2", "o_DataTable_cell_" & i & "_1_Content")
      Call ChnPropCreate("DataTable/DataTable_cell_" & i & "_2", "o_DataTable_cell_" & i & "_2_Content", DataTypeString)
      
      Call SpartanChnCopy("DataTable/DataTable_cell_" & i & "_1_Content", "DataTable/DataTable_cell_" & i & "_2_Content")
      Call ChnPropValSet("DataTable/DataTable_cell_" & i & "_2_Content", "Value", "o_DataTable_cell_" & i & "_2_Content_Value")     
      
      Call SpartanChnCopy("DataTable/DataTable_cell_" & i & "_1_Content_Value", "DataTable/DataTable_cell_" & i & "_2_Content_Value")
      Call ChnPropValSet("DataTable/DataTable_cell_" & i & "_2_Content_Value", "SummaryChannel", "S22")     
      
    Next

  Next

End Sub

Call UIAutoRefreshSet(False) ' runs faster w/o refresh
Call Update()
Call UIAutoRefreshSet(True) ' turn screen update back on