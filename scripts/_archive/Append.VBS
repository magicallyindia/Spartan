'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 03/13/2007 10:35:30
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.
AutoIgnoreError = 1     ' 1 turns off any error popups. 0 Enables popups

DIM Chan_Index, Number_jpegs, X, JPEG_String, JPEG_array, JPEG_Path, JPEG_type
DIM Qarray

' Delete any existing report
CALL PICDELETE                                    
CALL DATADELALL(1)  
Call GraphDeleteAll()

' T1 will have the path to the file used to store the list of JPEG files.
' T2 will have the path the name of the file desired.
' T3 will have the path scripts directory

' Test Code
'T1 = "I:\Engineering\Development\SPARTAN\Scripts\temp tdr\jpeglist239.tdm"
'T2 = "I:\Engineering\Development\SPARTAN\Scripts\temp tdr\APPENDED.pdf"
'T3 = "I:\Engineering\Development\SPARTAN\Scripts\"

Qarray = Split(T1, vbCr, -1, 1)

Number_jpegs = ubound(qarray)

FOR X = 1 TO Number_jpegs

        JPEG_String = Qarray(Chan_Index)
        JPEG_array = Split(JPEG_String,",", -1, 1)
        JPEG_Path = JPEG_array(0)
        JPEG_TYPE = JPEG_array(1)

        SELECT CASE UPC(JPEG_TYPE)
            CASE "PORTRAIT"
                 JPEG_type = "Blank_Portrait.tdr"
            CASE "LANDSCAPE"
                 JPEG_type = "Blank_Landscape.tdr"
            CASE ELSE
                ' Error      
        END SELECT 

        IF (X = 1) THEN
            CALL PICLOAD(T3&"\"&JPEG_type)
        ELSE
            CALL PicFileAppend(T3&"\"&JPEG_type)
        END IF

        Call GraphObjNew("FreeGraph","Reportgraphic"&X) 

        CALL GRAPHObjOpen("Reportgraphic"&X)
          MtaFileName = JPEG_Path
          MTARATIOADAPT    =1
          MTABACKCOLOR     =""
          MTABACKRGB       =0
          MtaPosX = 50
          Mtaposy = 50
          MtaWidth = 99.9
          MtaHeight = 99.9
        CALL GRAPHObjClose("Reportgraphic"&X)

NEXT

' Update all the TDRs.
Call PicUpdate

'Export the PDF
CALL PICpdfexport(T2)



