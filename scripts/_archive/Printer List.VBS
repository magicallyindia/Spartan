'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 07/11/2005 11:28:11
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Option Compare Database
Option Explicit

Const PRINTER_ENUM_CONNECTIONS = &H4
Const PRINTER_ENUM_LOCAL = &H2

Type PRINTER_INFO_1
   flags As Long
   pDescription As String
   PName As String
   PComment As String
End Type

Type PRINTER_INFO_4
   pPrinterName As String
   pServerName As String
   Attributes As Long
End Type

Declare Function EnumPrinters Lib "winspool.drv" Alias _
   "EnumPrintersA" (ByVal flags As Long, ByVal name As String, _
   ByVal Level As Long, pPrinterEnum As Long, ByVal cdBuf As Long, _
   pcbNeeded As Long, pcReturned As Long) As Long
Declare Function PtrToStr Lib "Kernel32" Alias "lstrcpyA" _
   (ByVal RetVal As String, ByVal Ptr As Long) As Long
Declare Function StrLen Lib "Kernel32" Alias "lstrlenA" _
   (ByVal Ptr As Long) As Long
   


Sub EnumeratePrintersWin()

   Dim Success As Boolean, cbRequired As Long, cbBuffer As Long
   Dim Buffer() As Long, nEntries As Long
   Dim I As Long, PFlags As Long, PDesc As String, PName As String
   Dim PComment As String, Temp As Long

   cbBuffer = 3072
   ReDim Buffer((cbBuffer \ 4) - 1) As Long
   Success = EnumPrinters(PRINTER_ENUM_CONNECTIONS Or _
                         PRINTER_ENUM_LOCAL, _
                         vbNullString, _
                         1, _
                         Buffer(0), _
                         cbBuffer, _
                         cbRequired, _
                         nEntries)
   If Success Then
      If cbRequired > cbBuffer Then
         cbBuffer = cbRequired
         Debug.Print "Buffer too small.  Trying again with " & _
                  cbBuffer & " bytes."
         ReDim Buffer(cbBuffer \ 4) As Long
         Success = EnumPrinters(PRINTER_ENUM_CONNECTIONS Or _
                             PRINTER_ENUM_LOCAL, _
                             vbNullString, _
                             1, _
                             Buffer(0), _
                             cbBuffer, _
                             cbRequired, _
                             nEntries)
         If Not Success Then
            Debug.Print "Error enumerating printers."
            Exit Sub
         End If
      End If
   Debug.Print "There are " & nEntries & _
                " local and connected printers."
   For I = 0 To nEntries - 1
      PFlags = Buffer(4 * I)
      PDesc = Space$(StrLen(Buffer(I * 4 + 1)))
      Temp = PtrToStr(PDesc, Buffer(I * 4 + 1))
      PName = Space$(StrLen(Buffer(I * 4 + 2)))
      Temp = PtrToStr(PName, Buffer(I * 4 + 2))
      PComment = Space$(StrLen(Buffer(I * 4 + 2)))
      Temp = PtrToStr(PComment, Buffer(I * 4 + 2))
      Debug.Print PFlags, PDesc, PName, PComment
   Next I
   Else
      Debug.Print "Error enumerating printers."
   End If
End Sub

