'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 03/22/2006 12:38:01
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Option Explicit         ' This setting requires explicit variable allocation in script.

DIM SN,MN,TEST,CHANNELID

SN = "200"
MN = "ALLPARA"
TEST = "Prompted Inputs"
'ChannelID = "Weight"
ChannelID = "Leak Rate"

msgbox( Get_Meas_String(TEST,MN,SN,ChannelID))
       'ChannelIndex = cno(channelid)
       'msgbox(len(CHNdim(ChannelIndex)))
'msgbox( MID (CHNdim(ChannelIndex),6, (len(CHNdim(ChannelIndex))-6)))

'+++++++++++++++++++++++++++++

FUNCTION Get_Meas_String(TEST,MN,SN,ChannelID)
    DIM AdvancedQuery,MyDataFinder,MyResults
    DIM X, Max_time_index,Max_time_Value,ChannelIndex

    SET AdvancedQuery=Navigator.CreateQuery(eAdvancedQuery)
    AdvancedQuery.ReturnType=eSearchChannel
    CALL AdvancedQuery.Conditions.Add(eSearchFile,"registertxt1","=",SN)
    CALL AdvancedQuery.Conditions.Add(eSearchFile,"registertxt2","=",MN)
    CALL AdvancedQuery.Conditions.Add(eSearchFile,"name","=","*"&TEST&"*")
    CALL AdvancedQuery.Conditions.Add(eSearchChannel,"name","=",ChannelID)
    CALL AdvancedQuery.Conditions.Add(eSearchChannel,"registerval1",">","0")

    ' Execute the Query
    set MyDataFinder = Navigator.ConnectDataFinder(Spartan_DF)
    Call MyDataFinder.Search(AdvancedQuery)

    'Process the Results
    set MyResults  = MyDataFinder.Results
    IF MyResults.count > 0 THEN
       '---------------------------------------FOR EACH ELEMENT--------------------------------------------------
       X = 1
       Max_time_index= 1
       Max_time_Value = 0
       FOR EACH Element IN MyResults          ' Process each element of the results
           IF Element.Properties("registerval1").value > Max_time_Value THEN
               Max_time_Value = Element.Properties("registerval1").value
               Max_time_index = X
           END IF
           X = X+1
       NEXT
  
       ' Now that I have found it. put in Datafinder
       ' The loop looks stupid because it is.  I can't figure out how to
       ' reference a single item once it is in the RESULTS object.
       X = 1
       FOR EACH Element IN MyResults          ' Process each element of the results
           IF X = Max_time_index THEN
              Call Navigator.LoadData(element, "Load")
           END IF
           X = X+1
       NEXT
       ChannelIndex = cno(channelid)
       IF (instr (CHNdim(ChannelIndex), "ENUM[")) > 0 THEN 
          Get_Meas_String = channelid &" : "& MID (CHNdim(ChannelIndex),6, (len(CHNdim(ChannelIndex))-6))
       ELSE
          Get_Meas_String = channelid &" : "& str( CHD (1,ChannelIndex), "d.ddd")&" "&CHNdim(ChannelIndex)
       END IF

     ELSE
       Get_Meas_String = channelid &" : "
     END IF


END FUNCTION