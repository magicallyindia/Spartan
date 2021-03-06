'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 06/20/2005 15:46:14
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------








For iteration = 1 to 10 
  DataX(Iteration) = 800 + Iteration
  DataY(Iteration) = Int((6 * Rnd) + 1)
  LimitUpper(Iteration) = 5.5
  LimitLower(Iteration) = 1.5
Next

'-- Delete any current sheets
Call GraphDeleteAll()

'-- Create a New Sheet 
Call GraphSheetNew("VSWR Report")
'-- Set to Portrait layout
  PicRatio = 1.4
'-- 
' 
Call GraphObjNew("FreeFrame","FrameCompany")
Call GraphObjOpen("FrameCompany")
   AreaLinePt(1) = 8
   AreaLinePt(2) = 84
   AreaLinePt(3) = 48
   AreaLinePt(4) = 92
Call GraphObjClose("FrameCompany")
'-- 
Call GraphObjNew("FreeFrame","FrameDateOp")
Call GraphObjOpen("FrameDateOp")
   AreaLinePt(1) = 48
   AreaLinePt(2) = 84
   AreaLinePt(3) = 92
   AreaLinePt(4) = 92
Call GraphObjClose("FrameDateOp")
'-- 
Call GraphObjNew("FreeFrame","FrameRequired")
Call GraphObjOpen("FrameRequired")
   AreaLinePt(1) = 8
   AreaLinePt(2) = 75
   AreaLinePt(3) = 92
   AreaLinePt(4) = 84
Call GraphObjClose("FrameRequired")
'-- 
IF CustomLength > 0 then
 Call GraphObjNew("FreeFrame","FrameCustom")
 Call GraphObjOpen("FrameCustom")
   AreaLinePt(1) = 8
   AreaLinePt(2) = 72 - ((Customlength+1)\2)*3
   AreaLinePt(3) = 92
   AreaLinePt(4) = 75
 Call GraphObjClose("FrameCustom")
end if 

'-- Put the Custom Labels on the page
CustomCounter = 0
for Iteration = 1 to (RequiredTotal + CustomLength)
  Call GraphObjNew("FreeText","Field"&Iteration)
  Call GraphObjOpen("Field"&Iteration)
  txtrelpos = "right"
  txtsize = 2
  txtframe = FALSE
    Select Case iteration
    case 1         
      TxtPosX = 10
      TxtPosY = 90
      TxtTxt = CompanyID
    case 2         
      TxtPosX = 50
      TxtPosY = 90
      TxtTxt = DateTime 
    case 3         
      TxtPosX = 50
      TxtPosY = 87
      TxtTxt = Operator 
    case 4         
      TxtPosX = 10
      TxtPosY = 81
      TxtTxt = SerialNumber 
    case 5         
      TxtPosX = 50
      TxtPosY = 81
      TxtTxt = ModelNumber 
    case 6         
      TxtPosX = 10
      TxtPosY = 78
      TxtTxt = SeqID 
    case 7         
      TxtPosX = 50
      TxtPosY = 78
      TxtTxt = InstID 
    case else        
      if (CustomCounter mod 2 )= 0 then
          TxtPosX = 10
      else
          TxtPosX = 50
      End if
      TxtPosY = 72 - (CustomCounter\2)*3
      TxtTxt = Custom(CustomCounter+1) 
      CustomCounter = CustomCounter +1
  End Select
  Call GraphObjClose("Field"&Iteration)
Next
'-- 
'-- 
Call GraphObjNew("2D-Axis","2DAxis1") 
Call GraphObjOpen("2DAxis1")         
  D2AxisBottom = 20
  D2AxisTop = 81 - (5* (iteration - RequiredTotal))
  D2AxisLeft = 20
  D2AxisRight = 20
Call GraphObjClose("2DAxis1")  
Call PicUpdate
