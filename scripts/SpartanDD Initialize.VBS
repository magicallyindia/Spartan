'-------------------------------------------------------------------------------
'-- Spartan VBS script file
'-- Updated on 04/19/2013
'-- Author: James Brunner
'-- Comment: 
'   This script runs when Spartan starts DIAdem.
'-------------------------------------------------------------------------------
Option Explicit         ' This setting requires explicit variable allocation in script.
AutoIgnoreError = 1     ' 1 turns off any error popups. 0 Enables popups

' Clear out the workspace
Call PicDelete           ' Delete any existing reports
Call DataDelAll(1)       ' Delete any existing Data in Data Portal

' Define global variables - these become accessible to all scripts
Call OdsValAlloc("Spartan_DF", "Ods_TYPE_STRING", 0)
Call OdsValAlloc("SpartanVersion", "Ods_TYPE_STRING", 0)

Spartan_DF = T1 ' gets DataFinder to use from Spartan (set in Spartan Server.ini)
If Spartan_DF = "" Then
   Spartan_DF = "My DataFinder" ' default desktop DataFinder
End If

SpartanVersion = T2 ' so we can add to DIAdem outputs
If SpartanVersion = "" Then
    SpartanVersion = "X.X.XXXX"
End If

T3 = DeskDrv
