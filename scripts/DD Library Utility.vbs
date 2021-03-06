'-------------------------------------------------------------------------------
'-- Spartan VBS script file
'-- Created on 04/19/2013 15:42:51
'-- Author: James Brunner
'-- Comment: utility routines (formerly emebeded within "DD LIB.vbs")
'-------------------------------------------------------------------------------
Option Explicit ' Forces the explicit declaration of all the variables in a script.
AutoIgnoreError = 1 ' 1 turns off any error popups. 0 Enables popups

Call Subsequence("DD Library Utility") ' makes sure this script is not called standalone

' escape/parse string constants
Const APOSTROPHE_ESCAPE_STRING = "XXXXXX"
Const AMPERSAND_ESCAPE_STRING = "ZZZZZZ"
Const AT_ESCAPE_STRING = "@@@"
Const CR_ESCAPE_STRING = "::"
Const SPARTAN_SERIAL_NUMBER_PREFIX = "$SSN$"


'--- String handling

' unescape apostrophes
Function unescapeApostrophes(escapedString)

    Dim splitString, result, i

    splitString = Split(escapedString, APOSTROPHE_ESCAPE_STRING)
    result = ""
    
    If (UBound(splitString) > 0) Then
        For i = 0 To UBound(splitString)
            If i > 0 Then
                result = result & "'" & splitString(i)
            Else
                result = splitString(i)
            End If
        Next
        
    Else
        result = escapedString
    
    End If
    
    unescapeApostrophes = result  
End Function

' escape apostrophes
Function escapeApostrophes(regularString)

    Dim splitString, result, i
    
    splitString = Split(regularString, "'")
    result = ""
    
    If (UBound(splitString) > 0) Then
    
        For i = 0 To UBound(splitString)
            If i > 0 Then
                result = result & APOSTROPHE_ESCAPE_STRING & splitString(i)
            Else
                result = splitString(i)
            End If
        Next
        
    Else
        result = regularString
    End If
    
    escapeApostrophes = result
    
End Function

' unescape ampersands
Function unescapeAmpersand(escapedString)
    Dim splitString, result, i

    splitString = Split(escapedString, AMPERSAND_ESCAPE_STRING)
    result = ""
    
    If (UBound(splitString) > 0) Then
        For i = 0 To UBound(splitString)
            If i > 0 Then
                result = result & "&" & splitString(i)
            Else
                result = splitString(i)
            End If
        Next
        
    Else
        result = escapedString
    
    End If
    
    unescapeAmpersand = result  
End Function

' escape ampersands
Function escapeAmpersand(regularString)

    Dim splitString, result, i
    
    splitString = Split(regularString, "&")
    result = ""
    
    If (UBound(splitString) > 0) Then
    
        For i = 0 To UBound(splitString)
            If i > 0 Then
                result = result & AMPERSAND_ESCAPE_STRING & splitString(i)
            Else
                result = splitString(i)
            End If
        Next
        
    Else
        result = regularString
    End If
    
    escapeAmpersand = result
    
End Function

' escape @ - DIAdem needs these escaped to print them in reports
Function escapeAt(regularString)
    Dim splitString, result, i
    
    splitString = Split(regularString, "@")
    result = ""
    
    If (UBound(splitString) > 0) Then
    
        For i = 0 To UBound(splitString)
            If i > 0 Then
                result = result & AT_ESCAPE_STRING & splitString(i)
            Else
                result = splitString(i)
            End If
        Next
        
    Else
        result = regularString
    End If
    
    escapeAt = result
End Function

' unescape Newlines
Function unescapeCR(escapedString)

    Dim splitString, result, i

    splitString = Split(escapedString, CR_ESCAPE_STRING)
    result = ""
    
    If (UBound(splitString) > 0) Then
        For i = 0 To UBound(splitString)
            If i > 0 Then
                result = result & vbNewline & splitString(i)
            Else
                result = splitString(i)
            End If
        Next
        
    Else
        result = escapedString
    
    End If
    
    unescapeCR = result  
End Function




'--- Formatting

' Remove LF, CR, TAB
Function trimLfCrTab(regularString)
    If (Instr(regularString, vbLf)) Then
        regularString = Left(regularString, Instr(regularString, vbLF) - 1)
    End If

    If (Instr(regularString, vbCr)) Then
        regularString = Left(regularString, Instr(regularString, vbCr) - 1)
    End If

    If (Instr(regularString, vbTab)) Then
        regularString = Left(regularString, Instr(regularString, vbTab) - 1)
    End If

    trimLfCrTab = regularString
End Function


' Removes extra $SSN$ and zeros from the Spartan SSN
' Converts "$SSN$ 00000000000000001" TO "1"
Function ssnStr(SSN)
    Dim tempstr
    If (Pos(SPARTAN_SERIAL_NUMBER_PREFIX, SSN) = 1) Then   'Look For $SSN$ in the first position of string.
        tempstr = Split(SSN, SPARTAN_SERIAL_NUMBER_PREFIX) 'Split that part off from the 00000# part
        ssnStr  = CStr(CLng(tempstr(1)))                   'converts 0000# TO # Then back to string.
    Else
        ssnStr = SSN  'not a "$SSN$ 0000#" string.
    End If
End Function


' Format datetime string
Function SpartanDateTime(dt, format)
    ' SpartanDateTime (  ,"MM/DD/YYYY hh:nn AMPM")
    If IsNumeric(dt) Then
        SpartanDateTime = Rtt(dt + 60084266399, format)
    Else
        SpartanDateTime = "ERROR"
    End If
End Function


' This provides safe number formatting
Function Safe_FormatNumber(num, format)

    If IsNull(num) Then
        Safe_FormatNumber = "-"
    Else
        If Abs(num) > 0.001 Then
            Safe_FormatNumber = FormatNumber(num, format)
        Else
            Safe_FormatNumber = Str(num, "d.ddde")
        End If
    End If
End Function


'--- Dictionary (keyed array) Routines

' Retrieves a parameter value from the keyed array
Function Lookup(parameter, parameters, defaultValue)

    Dim keypos, eqpos, appos, tempstr

    keypos = 1
    eqpos = 1
    appos = 1

    keypos = InStr(1, "&" & parameters, "&" & parameter & "=", 1) ' Where is key?
    If keypos > 0 Then
        tempstr = Mid(parameters, keypos) ' Remainder of string
        eqpos = InStr(1, tempstr, "=", 1)' Where is equals.
        tempstr = Mid(tempstr, eqpos + 1) ' remainder of string
        appos  = InStr(1, tempstr, "&", 1) ' where is &?

        If appos = 0 Then
            Lookup = tempstr ' must be last key.
        Else
            Lookup = Mid(tempstr, 1, appos - 1) ' get value
        End If
    Else
        Lookup = defaultValue
    End If
End Function

' Replaces a parameter value in the keyed array
Function ReplaceKey(parameter, parameters, value)

    Dim keypos, eqpos, appos, beginstr, endstr, tempstr
    keypos = 1
    eqpos = 1
    appos = 1

    keypos = InStr(1, "&" & parameters, "&" & parameter & "=", 1) ' Where is key?
    If keypos > 0 Then
        beginstr = Mid(parameters, 1, keypos - 1) ' Beginning of the string up to the Key
        tempstr = Mid(parameters, keypos) ' Remainder of string
        eqpos = InStr(1, tempstr, "=", 1)' Where is equals.
        tempstr = Mid(tempstr, eqpos + 1) ' Remainder of string
        appos  = InStr(1, tempstr, "&", 1) ' Where is &?

        If appos = 0 Then
            endstr = "" ' Must be last key.
        Else
            endstr = Mid(tempstr, appos) ' End of string
        End If

        ReplaceKey = beginstr & "" & parameter & "=" & value & "" & endstr
    Else
        ReplaceKey = parameters
    End If
End Function


'--- Data (Group(run), channel) handling

Function Add_Group(channelname)
  If (Pos("/", channelname)> 0) Then ' group already present
      Add_Group =channelname
  Else
     Add_Group ="["&groUPCounT&"]/"&channelname
  End If
End Function

Function Strip_Group(channelname)
Dim chnameonly
chnameonly = SPLIT(channelname,"/")
If UBound(chnameonly) > 0 Then
  Strip_Group =chnameonly(1)
Else
  strip_group = channelname
End If

End Function


' GroupPropValGet returns error for property that does not exist
Function Safe_GroupPropGet(group, prop)
    'Call Debug(CurrentScriptName, group & " " & prop & "  " & GroupPropExist(group, prop))
    
    Safe_GroupPropGet = "" ' empty if not exist
    
    If GroupPropExist(group, prop) Then
        Safe_GroupPropGet = GroupPropValGet(group, prop)
    End If
End Function

' ChnPropValGet returns error on property that does not exist
Function Safe_ChnPropGet(channel, prop)
    
    Safe_ChnPropGet = "-" ' default for not exist

    If IsNumeric(channel) Then
        If channel <> 0 Then
            If (ChnPropExist(channel, prop)) Then
                Safe_ChnPropGet = ChnPropValGet(channel,prop)
            End If
        End If

    Else
        If (ChnPropExist(channel, prop)) Then
            Safe_ChnPropGet = ChnPropValGet(channel, prop)

        End If
    End If

End Function



'--- Unit Conversions

Function dBmToWatt(dbm)
    'Watt = (10^(dBm/10))/1000
    dBmToWatt = Eex(dbm/10)/1000
End Function

' parameter f is in MHz
Function FrequencyToMHz(f, fUnits)

    Select Case UpC(fUnits)  ' HZ, KHZ, MHZ, GHZ
        Case "HZ"
            FrequencyToMHz = f * 1000000

        Case "KHZ"
            FrequencyToMHz = f * 1000

        Case "GHZ"
            FrequencyToMHz = f * 0.001
            
        Case Else ' default "MHZ"
            FrequencyToMHz = f

    End Select
End Function

' parameter t is in Seconds
Function TimeToSeconds(t, tUnits)

    Select Case UpC(tUnits)

        Case "MINUTES","MINUTE(S)"
            TimeToSeconds = t / (60)
  
        Case "HOURS", "HOUR(S)"
            TimeToSeconds = t / (3600)

        Case "DAYS" ,"DAY(S)"
            TimeToSeconds = t / (86400)

        Case Else ' default "SECONDS", "SECOND(S)"
            TimeToSeconds = t

    End Select

End Function


'--- Supplemental Math

' calculate log base 10
Function Log10(X)
   Log10 = Log(X) / Log(10)
End Function

' log magnitude (voltage)
Function LogMag(X)
  Dim SXX
  SXX = Abs(X)
  If ((SXX <> 1) AND (SXX <> 0)) Then
    LogMag = 20 * Log10(SXX)
  Else
    LogMag = NOVALUE
  End If
End Function


'--- Miscellaneous

' numeric array sorting
Sub BubbleSort(temp)

    Dim i, best_value
    Dim best_j, j

    For i = 0 TO UBound(temp)-1
        best_value = temp(i)
        best_j = i
        
        For j = i + 1 TO UBound(temp)-1
        
            If best_value > temp(j) Then
                best_value = temp(j)
                best_j = j
            End If
        Next
        
        temp(best_j) = temp(i)
        temp(i) = best_value

    Next

End Sub


