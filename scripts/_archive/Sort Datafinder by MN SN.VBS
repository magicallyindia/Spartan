'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 08/15/2008 14:16:38
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.

DIM MyDataFinder, MyResults, ResultString
DIM AdvancedQuery,ELEMENT,i, MyResultsCopy, MN, SN, Inx

SET AdvancedQuery=Navigator.CreateQuery(eAdvancedQuery)

CALL AdvancedQuery.Conditions.Add(eSearchFile,"registertxt2","=","WD-50066 DICOM-1900")
CALL AdvancedQuery.Conditions.Add(eSearchFile,"registertxt1","=","*")

SET MyDataFinder = Navigator.ConnectDataFinder(Spartan_DF)

Call MyDataFinder.Search(AdvancedQuery) ' This will return only 500
'Process the Results
Inx  = Sort_Results(MyDataFinder.Results)

'For Each Element in MyResults          ' Process each element of the results

FOR i = 1 to MyDataFinder.Results.count
   msgbox (MyDataFinder.Results.Item(Inx(i)).Properties("registertxt2").value & " " & MyDataFinder.Results.Item(Inx(i) ).Properties("registertxt1").value )
NEXT

'------------------------------------------------------------------------------------------------
'------------------------------------------------------------------------------------------------
' The function returns index array that can be used to index the items in
' the proper sort order. MyResults is a results object from datafinder query
' This is a basic selection sort.
'------------------------------------------------------------------------------------------------
'------------------------------------------------------------------------------------------------
' The original attempt tried to use the actual results object.  It didn't work. Object is readonly.
' The object cannot be copied either.  Code is here for reference.
'  Dim best_value
'  Dim best_j,j
'
'   FOR i = 1 to MyResults.count -1
'        Set best_value = MyResults.Item(i)
'        best_j = i
'        For j = i + 1 To MyResults.count
'            If ((StrComp(MyResults.Item(j).Properties("registertxt2").value,best_value.Properties("registertxt1").value) = -1) AND (CDbl (MyResults.Item(j).Properties("registertxt1").value) < CDbl(best_value.Properties("registertxt1").value))) Then
'                best_value = MyResults.Item(j)
'                best_j = j
'            End If
'        Next 
'        Set MyResults.Item(best_j) =  MyResults.Item(i)
'        Set MyResults.Item(i) = best_value
'    Next 
'------------------------------------------------------------------------------------------------
'------------------------------------------------------------------------------------------------

FUNCTION Sort_Results (MyResults)

DIM MN, SN, Ix

redim MN(MyResults.count)
redim SN(MyResults.count)
redim Ix(MyResults.count)
  
Dim best_value_MN,best_value_SN,best_value_Ix
Dim best_j,j, MNCOMP, SNCOMP
  
'For Each Element in MyResults          ' Process build array that I can sort
FOR i = 1 to MyResults.count
      MN(i) = MyResults.Item(i).Properties("registertxt2").value
      SN(i) = MyResults.Item(i).Properties("registertxt1").value
      Ix(i) = i
NEXT

   FOR i = 1 to MyResults.count -1
        best_value_mn =  MN(i)
        best_value_sn =  SN(i)
        best_value_Ix =  Ix(i)
        best_j = i
        For j = i + 1 To MyResults.count
            MNCOMP = StrComp(MN(j),best_value_mn)        
            SNCOMP = EXSN(SN(j)) < EXSN(best_value_sn)
            If (MNCOMP = -1) OR ((MNCOMP = 0) AND (SNCOMP)) Then
                best_value_mn =  MN(j)
                best_value_sn =  SN(j)
                best_value_Ix =  Ix(j)
                best_j = j
            End If
        Next
        mn(best_j) = mn(i)
        mn(i) = best_value_mn
        Sn(best_j) = SN(i)
        Sn(i) = best_value_SN
        Ix(best_j) = Ix(i)
        Ix(i) = best_value_Ix
    Next 
Sort_Results = Ix

END FUNCTION

'------------------------------------------------------------------------------------------------
'------------------------------------------------------------------------------------------------
' This function extracts the Numeric portion of a SN string so that the proper comparison is made.
'------------------------------------------------------------------------------------------------
FUNCTION EXSN (SNString)

          Dim RetStr,regEx, Match, Matches      ' Create variable.
          dim comp_num
          
          EXSN = 0                    ' Default response is a 0
          Set regEx = New RegExp      ' Create a regular expression.
          regEx.Pattern = "[0-9]+"    ' Set pattern.
          regEx.IgnoreCase = True     ' Set case insensitivity.
          regEx.Global = True         ' Set global applicability.
          
          ' Look for the first group of numbers starting from the right.
          Set Matches = regEx.Execute(strreverse (SNString))   ' Execute search.
          
          ' If I find a number then return it; else we return 0
          IF Matches.count > 0 THEN 
              EXSN = cdbl(strreverse(Matches.item(0).value))
          END IF
          
END FUNCTION
'------------------------------------------------------------------------------------------------