'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 12/12/2006 08:29:57
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.
Option Explicit Dim oOutlookApp
Dim oOutlookMail
Dim cnByValue     : cnByValue = 1
Dim cnMailItem    : cnMailItem = 0 
' Get Outlook Application Object
Set oOutlookApp = CreateObject("Outlook.Application") 

' Create Mail Item
Set oOutlookMail = oOutlookApp.CreateItem(cnMailItem) 

' Set Mail Values

With oOutlookMail  
  .To      = "myname@mydomain.com"  
  .Subject = "Mail Subject"  
  .Body    = "Mail Body"   
  
  ' Add Attachement  
  Call .Attachments.Add( "c:\Attachement.pdf", cnByValue, 1 )   
  
  ' Send Mail  
  Call .Send()
  
  End With
