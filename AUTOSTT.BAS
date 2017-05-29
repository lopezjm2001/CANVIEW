' AUTOSTT.BAS -  Username: lopezjm2001 at www.Priuschat.com

' Release date: 11 April 2014 (C)John Lopez 

' This program was written for both the CGCOLORMAX with a CANBUS by www.circuitgizmos.com or
' the COLOUR MAXIMITE or the monochrome VGA of the Duinomite Mega.

' To be used with mmBasic 4.4, Watchdog timer is used, disabled during keyboard input.

' DTC check is now logged automatically when either F11 or F12 buttons are pressed.

' DISCLAIMER - USE AT OWN RISK

' START OF USER DEFINED SUBROUTINES BELOW:

Sub pidrequest(header, mode, pid, more)
  Local txData(8), txok, txId : txId = header
  txData(3) = 0 : txData(4) = 0 : txData(5) = 0 : txData(6) = 0 : txData(7) = 0
  txData(0) = &H2 : txData(1) = mode : txData(2) = pid
  CAN TX 0,txId,0,8,txData(0),txOk : Pause 10
  If more = 1 Then
    txData(0)=&H30 : txData(1)=0 : txData(2)=0 : CAN TX 0,txId,0,8,txData(0),txOk
  EndIf
End Sub

Sub filter2104 ' - &H7E0 - &H7E8
  Local rxData(8), rxOk, looper, D1 : looper=0 : D1=0
  Looper6:
    CAN RX 19,rxData(0),rxOk 'CHANNEL 19 - tx&H7E0 to rx&H7E8
    If rxOk=1 Then
      If D1=0 And rxData(0)=&H3 And rxData(1)=&H61 And rxData(2)=&H4 Then
        Cload=rxdata(3)*0.3906 : D1=1
        If Cload=>99 Then Cload=99
      EndIf
      If D1=1 Then D1=0 : Exit Sub
    EndIf
    looper = looper + 1 : If looper>10 Then Exit Sub
  GoTo Looper6
End Sub

Sub filter21C3 '- &H7E2 - &H7EA
  Local rxData(8), rxOk, looper, D1, D2, D3, D4, D5, MEM, Ebuf
  D1=0 : D2 = 0 : D3=0 : D4=0 : D5=0 : looper = 0
  Looper7:
    CAN RX 21,rxData(0),rxOk 'CHANNEL 21 - tx&H7E2 to rx&H7EA
    If rxOk = 1 Then
      If D1=0 And rxData(0)=&H10 And rxData(1)=&H27 And rxData(2)=&H61 And rxData(3)=&HC3 Then
        MG2TQ = (32*rxData(6))+(0.125*rxData(7))-500
        MG2rpm=((256*rxData(4))+rxData(5))-16383 : D1=1
      EndIf
      If D2=0 And rxData(0)=&H21 Then
        TRB=4.000*rxData(2) : RB=4.000*rxData(1) : MG1rpm=((rxData(3)*256)+rxData(4))-16383 : D2=1
        MG1TQ=(32*rxData(5))+(0.125*rxData(6))-500 : PowReq=(2560.000*rxData(7))+10.000*MEM
      EndIf
      If D3=0 And rxData(0)=&H22 Then
        MEM=rxData(1) : MCT=(4.000*rxData(7))-512 : D3=1
        Ebuf=rxData(2) : Ebuf=rxData(3) : Ebuf=rxData(4) : Ebuf=rxData(5) : Ebuf=rxData(6)
      EndIf
      If D4=0 And rxData(0)=&H23 Then
        INV1t=rxData(7)-50 : DisReq=rxData(4) : Drivecond=rxdata(6) : D4=1
        HVPI=rxData(3)-40800
        HVPO=rxData(2)*320
      EndIf
      If D5=0 And rxData(0)=&H24 Then
        INV2t=rxData(1)-50 : MG1t=rxData(2)-50 : MG2t=rxData(3)-50 : D5=1
        Volts=rxData(4)*2.000 : current=((rxData(5)+(rxData(6)*2))-256)*-1 : BattKW=volts*current/1000
        Nettkw = icekw - battkw
        If log=0 Then
          AHf=Timer : Timer=0
        EndIf
        If log=1 Then
          AHf=Timer-timer1 : timer1=Timer
        EndIf
        If AHf=0 Then AHf=1000    'Prevents divide by zero overflow error
        AH=(current*-1)/(3600*(1000/AHf)) 
        If ready=1 And Standby=0 And ACC=0 And Running=1 Then AHT=AHT+AH
        If AHT=>100 Then AHT=0
      EndIf
      If D1=1 And D2=1 And D3=1 And D4=1 And D5=1 then Exit Sub
    EndIf
    looper = looper + 1 : If looper > 10 Then Exit Sub
  GoTo Looper7
End Sub

Sub F1
  If R1 = 0 Then R1 = 1 Else R1 = 0
  If page<>7 And page<>8 And page<>100 Then
    If R1 = 1 Then Font 1 : Print @(20,415) CLR$(Black,Green)+"EV MAN ";
    If R1 = 0 Then Font 1 : Print @(20,415) CLR$(Black,Green)+"EV AUTO";
  EndIf
End Sub

Sub F2
  ' If R2 = 0 Then R2 = 1 Else R2 = 0   'Was used for Enginer kit
  If Warningpage=1 Then Warningpage=0 Else Warningpage=1
End Sub

Sub F3
  ' If R3 = 0 Then R3 = 1 Else R3 = 0   'Was used for Enginer Kit
  UnloadLibFile()
  page=page+1
  If page=1 Then fg=1 : bg=0 : GoSub M17screen : Library Load "PAGE0.LIB" : Drawlabels_LHS()
  If page=2 Then page=5
  If page=5 Then GoSub M17screen : Library Load "F5.LIB" : F5()
  If page=6 Then GoSub M17screen : Library Load "F6.LIB" : F6()
  If page=7 Then page=13
  If page=13 Then GoSub M17screen : Library Load "GAUGE13.LIB" : Gauge13()
  If page=14 Then GoSub M17screen : Library Load "PSD.LIB" : PSD()
  If page=15 Then GoSub M17screen : Library Load "BMSPLUS.LIB" : BMSplus()
  If page=16 Then GoSub M17screen : Library Load "GAUGE16.LIB" : Gauge16()
  If page=17 Then GoSub M17screen : Library Load "GAUGE17.LIB" : Gauge17()
  If page=18 Then GoSub M17screen : Library Load "PHEV.LIB" : PHEV()
  If page=19 Then GoSub M17screen : Library Load "TEMP.LIB" : Temp()
  If page=20 Then Page=24
  If page=24 And RS232=1 Then GoSub M17screen : Library Load "EVDIS.LIB" : EVDIS()
  If page=24 And RS232=0 Then page=25
  If page=>25 Then GoSub M17screen : Library Load "PAGE0.LIB" : page=1 : Drawlabels_LHS()
  If page<1 Then page=14
End Sub

Sub F4
  If R4=0 Then R4=1 Else R4=0
  Pin(18) = R4
  If R4=1 Then
    Font 1 : GoSub SendORIG
    If page<>7 And page<>8 And page<>100 Then Print @(93,415) CLR$(Black,Green)+"ORIG";
  EndIf
  If R4=0 Then
    Font 1 : bmsvolts = 210 : GoSub SendPHEV : Pause 500
    If page<>7 And page <> 8 And page<>100 Then Print @(93,415) CLR$(Black,Green)+"PHEV";
  EndIf
End Sub

Sub F10
  If HVfan = 0 Then HVfan = 1 Else HVfan = 0 ' HVfan = 1 - MANUAL MODE = 0 - AUTO MODE
End Sub

Sub UpdateF1
  Local rxData(8), rxOk, loops
  If forcedev = 1 Then Exit Sub
  If R1=0 Then
    Looper8:
      CAN RX 17,rxData(0),rxOk
      If rxOK=1 Then
        evMode = rxData(4)
        If (ForcedEV=0 And evMode<>64 And R1=0 And kph<45 And soc>40 And ready=1 And H3C8data0<>6) Then
          Pin(15) = 0 : Pause 10 : Pin(15) = 1 : Exit Sub
        EndIf
      EndIf
      loops = loops + 1 : If loops > 1 Then Exit Sub
    GoTo Looper8
  EndIf
End Sub

Sub UpdateF4
  If R4=1 Then
    Font 1
    If page<>7 And page<>8 And page<>100 Then Print @(93,415) CLR$(Black,Green)+"ORIG";
  EndIf
  If R4=0 Then
    Font 1
    If page<>7 And page<>8 And page<>100 Then Print @(93,415) CLR$(Black,Green)+"PHEV";
  EndIf
End Sub

Sub UpdateF10
    Local rxData(8), rxOk, rxId, rxLen, txData(8),txOk, inLoop, rxType
    txData(0)=&H4 : txData(1)=&H30 : txData(2)=&H81 : txData(3)=6 : rxId = &H7EB
    txData(4)=fanspeed : txData(5)=0 : txData(6)=0 : txData(7)=0 : inLoop=0
    If HVfan = 1 Then
      CAN TX 0,&H7E3,0,8,txData(0),txOk ' HV FAN MANUAL MODE
      If (txOk=1) Then
        Looper3:
          CAN RX 22,rxId,rxType,rxLen,rxData(0),rxOk 'CHA22 - tx&H7E3 to &H7EB
          If (rxOK=1) And (Page<>7) And (Page<>8) And (Page<>100) Then
            If (rxData(0) = &H2) And (rxData(1) = &H70) Then
              Font 1 : Print @(120,65) CLR$(Black,Green)+"HV FAN"; CLR$(Black,Green)+Format$(fanspeed,"% g"); : Exit Sub
            EndIf
          EndIf
          inLoop = inLoop + 1 : If inLoop > 6 Then Exit Sub
        GoTo Looper3
      EndIf
    EndIf
    If HVfan = 0 Then
      If page<>7 And page<>8 And page<>100 Then Font 1 : Print @(120,65) CLR$(Black,Green)+"FAN AUTO";
      If (BatDegCh > 25) Then
        txData(4) = 6 : CAN TX 0,&H7E3,0,8,txData(0),txOk ' HV FAN AUTO MODE
        If txOk = 1 Then
          Looper4:
            CAN RX 22,RxData(8),rxOk 'CHANNEL 22 - tx&H7E3 to rx&H7EB
            If (rxOK = 1) Then
              If (rxData(0) = &H2 And rxData(1) = &H70) Then Exit Sub
            EndIf
            inLoop = inLoop + 1 : If inLoop > 6 Then Exit Sub
          GoTo Looper4
        EndIf
      EndIf
    EndIf
End Sub

Function getS12(hi, lo)
  If (hi >= &B1000) Then getS12 = (lo + ((hi - &B10000) * 256)) * -1
  If (hi <  &B1000) Then getS12 = ((hi * 256) + lo) * -1
End Function

Function getU16(hi, lo)
  getU16 = (hi*256) + lo
End Function

Sub getCanData   'Receive passive CANbus messages
  Local rxData(8), rxOk : BMS=0
  CAN RX 18,rxData(0),rxOk : If (rxOk=1) Then ect = rxData(1) / 2  ' H52C
  CAN RX 1,rxData(0),rxOk : ' H3C8 - ICE
  If (rxOk=1) Then
     icerpm = (getU16(rxData(2), rxData(3)))/8
     fuelflowa = rxData(4)
     H3C8data0 = rxData(0) : H3C8data1 = rxData(1) : H3C8data3 = rxData(3) : H3C8data2 = rxdata(2)
  EndIf
  CAN RX 3,rxData(0),rxOk : If (rxOk=1) Then throt = (rxData(6)/2)
  If throt > 99 Then throt = 99
  CAN RX 4,rxData(0),rxOk : If (rxOk=1) Then brake = (rxData(4)*100)/128
  CAN RX 5,rxData(0),rxOk : If (rxOk=1) Then kph = (getU16(rxData(5), rxData(6))*10)/1024
  CAN RX 6,rxData(0),rxOk : If (rxOk=1) Then ICEkw = rxData(1) * 0.25
  CAN RX 7,rxData(0),rxOk
  If (rxOk=1) Then   'H520 fuel flow
    H520data0 = rxData(0) : fuelflowb = rxData(1) : fuelflowc = rxData(2)
    fuelflow = fuelflowa * fuelflowc * 0.001 * fuelflowb
    If H039data1=2 Then fuelflow=0
  EndIf
  CAN RX 8,rxData(0),rxOk : ' H3CB - HV battery
  If (rxOk=1) Then
    Dmax = rxData(0) * -1 : Cmax = rxData(1) : soc = (getU16(rxData(2), rxData(3)))/2
    BatDegCl=rxData(5) : BatDegCh=rxData(4)
    If metric=0 Then BatdegFl=(rxData(5)*9/5)+32 : BatDegFh=(rxData(4)*9/5)+32 
  EndIf
  CAN RX 9,rxData(0),rxOk : ' H555 - BMSplus
  If (rxOk=1) Then BMS=1 Else BMS=0
  SocORIG = rxData(0) : CCLORIG = rxData(1) : DCLORIG = rXData(2)
  BMS0 = rxData(3) : BMS1 = rxData(4) : BMS2 = rxData(5) : BMS3 = rxData(6) : BMS4 = rxData(7)
  CAN RX 10,rxData(0),rxOk : ' H03A - Actual power
  If (rxOk=1) Then
    Power = rxdata(1)*4
    If power > 900 Then power = power - 1028
    H03Adata0 = rxData(0) : H03Adata2 = rxData(2)
    H03Adata3 = rxdata(3) : H03Adata4 = rxdata(4) : H03Adata5 = rxdata(5)
  EndIf
  CAN RX 11,rxData(0),rxOk : ' H3CA - Target power
  If (rxOk=1) Then
    ' If rxData(1) =>256 Then targetPower = (((rxdata(1) + 256)) - 32)*2
    ' If rxData(1) < 256 Then
    targetPower = (rxData(1) - 32)*2
  EndIf
  CAN RX 12,rxData(0),rxOk :  If (rxOk=1) Then intaket1=rxData(0) : ambient=rxData(1) : intaket3=rxData(2) ' H3CF
  CAN RX 13,rxData(0),rxOk
  If (rxOk=1) Then
    ICEt=rxData(0) : H039data1=rxData(1) : H039data2=rxData(2) : VVTi=rxData(2)
  EndIf
  ' CAN RX 14,rxData(0),rxOk : If (rxOk=1) Then VVTi=rxData(1)
  CAN RX 15,rxData(0),rxOk : If (rxOk=1) Then gastank = ((rxData(1) / 44) * 100)  ' H5A4 - Gas Tank %
  CAN RX 16,rxData(0),rxOk : ' H348 - ICE
  If (rxOk=1) Then
    H348data0=rxdata(0) : H348data1=rxdata(1) : Trpm=rxdata(2)*25.6 : TTQH = rxdata(3) : TTQL = rxData(4) : TTQ=TTQH+TTQL/10
  EndIf
  CAN RX 23,rxData(0),rxOk : ' H540 - Shift lever
  If (rxOk=1) Then
    shift = rxData(1)
    If shift=128 Then shift$="P"
    If shift=16 Then shift$ ="D"
    If shift=0 Then shift$="B"
    If shift=64 Then shift$ ="R"
    If shift=32 Then shift$="N"
  EndIf
End Sub

Sub Updatewarn
  If warningpage=1 And bms=1 Then
    If (R4=0 And SoC<=73 And SoC<>65 And Warn=0) Then
      cn=cn+1
      If cn=3 Then
        UnloadLibFile() : page=100 : warn=1 : cn=0 : GoSub warningVGA
      EndIf
      If cn=1 Or cn=2 Then Exit Sub
    EndIf
    cn=0
    If R4=1 And Warn=1 Then
      warn=0
      warningpage=0
    EndIf
  EndIf
  Font 1
  If page=1 Or page=5 Or page=6 Or page=9 Or page=18 Or page=11 Or page=12 Or page=14 Or page=15 Or page=16 Or page=17 Or page=18 Or page=19 Or page=20 Or page=21 Or page=22 Or page=23 Or page=24 Or page=100 Then
    If Warningpage=1 Then Print @(15,380) CLR$(fg,bg)+"Warning ACTIVE"; Else Print @(15,380) CLR$(fg,bg)+"               ";
  EndIf
End Sub

Sub UnloadLibFile
  If page=1 Then Library UNLOAD "PAGE0.LIB"
  If page=5 Then Library UNLOAD "F5.LIB"
  If page=6 Then Library UNLOAD "F6.LIB"
  If page=7 Then Library UNLOAD "F7.LIB"
  If page=8 Then Library UNLOAD "F8.LIB" 
  If page=9 And Log=0 Then Library UNLOAD "F9.LIB"
  If page=11 or page=12 Then Library UNLOAD "DTC.LIB"
  If page=13 Then Library UNLOAD "GAUGE13.LIB"
  If page=14 Then Library UNLOAD "PSD.LIB"
  If page=15 Then Library UNLOAD "BMSPLUS.LIB"
  If page=16 Then Library UNLOAD "GAUGE16.LIB"
  If page=17 Then Library UNLOAD "GAUGE17.LIB"
  If page=18 Then Library UNLOAD "PHEV.LIB"
  If page=19 Then Library UNLOAD "TEMP.LIB"
End Sub

Sub CalcPHEV
   ' This subroutine calculates the four PHEV battery pack temperatures derived from
   ' measuring four NTC thermistors, 10Kohm at 25oC, MF52-103/3435 from Ebay.
   ' Using the Steinheart formula
   '
   ' Vs(3.3v)----o
   '             !
   '            Rt1 (thermistor)
   '             !
   ' Vo1---------o
   '             !
   '             R  (Fixed resistor 10Kohm)
   '             !
   '            GND
   '
   ' Vo1 to V04 are measured from analog inputs Pins 1 to 4.

   Local A, B, C, Rt1, Rt2, Rt3, Rt4, Temp1old, Temp2old, Temp3old, Temp4old
   If test=0 Then Vo1 = Pin(1) : Vo2 = Pin(2) : Vo3 = Pin(3) : Vo4 = Pin(4)   'May need to disable this line if you are not using thermistor analog inputs
   If Vo1=0 Or Vo2=0 Or Vo3=0 Or Vo4=0 Then Exit Sub
   Rt1 = 10000*((3.3/Vo1)-1)
   Rt2 = 10000*((3.3/Vo2)-1)
   Rt3 = 10000*((3.3/Vo3)-1)
   Rt4 = 10000*((3.3/Vo4)-1)
   A = 0.9439329096e-3
   B = 2.461834640e-4
   C = 1.825764757e-7
   If Temp1<>0 Then Temp1old=Temp1
   If Temp2<>0 Then Temp2old=Temp2
   If Temp3<>0 Then Temp3old=Temp3
   If Temp4<>0 Then Temp4old=Temp4
   Temp1 = ( 1/( A + (B*Log(Rt1)) + (C*Log(Rt1)*Log(Rt1)*Log(Rt1)) ) ) - 273.15 : Temp1=(Temp1old+Temp1)/2
   Temp2 = ( 1/( A + (B*Log(Rt2)) + (C*Log(Rt2)*Log(Rt2)*Log(Rt2)) ) ) - 273.15 : Temp2=(Temp2old+Temp2)/2
   Temp3 = ( 1/( A + (B*Log(Rt3)) + (C*Log(Rt3)*Log(Rt3)*Log(Rt3)) ) ) - 273.15 : Temp3=(Temp3old+Temp3)/2
   Temp4 = ( 1/( A + (B*Log(Rt4)) + (C*Log(Rt4)*Log(Rt1)*Log(Rt4)) ) ) - 273.15 : Temp4=(Temp4old+Temp4)/2
   If Metric=0 Then
     Temp1F=(Temp1*9/5)+32
     Temp2F=(Temp2*9/5)+32
     Temp3F=(Temp3*9/5)+32
     Temp4F=(Temp4*9/5)+32
   Endif
   Temp1=Cint(Temp1) : Temp2=Cint(Temp2) :Temp3=Cint(Temp3) :Temp4=Cint(Temp4)
   If metric=0 Then
     Temp1F=Cint(Temp1F) : Temp2F=Cint(Temp2F) :Temp3F=Cint(Temp3F) :Temp4F=Cint(Temp4F) 
   Endif
   Tempmax=Temp1
   If Temp2 > Tempmax Then Tempmax=Temp2
   If Temp3 > Tempmax Then Tempmax=Temp3
   If Temp4 > Tempmax Then Tempmax=Temp4
   If test=1 Then Temp4 = 60 : Tempmax = 60     'Alarm test line
   TempmaxF=(Tempmax*9/5)+32
   If Standby=1 Then
     If Tempmax=>50 Or Tempmax=<5 Then
       If metric=1 Then
         Font 2, ,1 : Print @(172,29) CLR$(fg,bg)+"     ";
         Print @(172,29) CLR$(fg,bg)+Format$(Tempmax,"% -3.0f"); : Font 1, ,1
         Print CLR$(fg,bg)+"o"; : Font 2, ,1 : Print CLR$(fg,bg)+"C";
       Endif
       If metric=0 Then
         Font 2, ,1 : Print @(172,29) CLR$(fg,bg)+"     ";
         Print @(172,29) CLR$(fg,bg)+Format$(TempmaxF,"% -3.0f"); : Font 1, ,1
         Print CLR$(fg,bg)+"o"; : Font 2, ,1 : Print CLR$(fg,bg)+"F";
       Endif
     EndIf
     If Tempmax<50 And Tempmax>5 Then
       If metric=1 Then
         Font 2 : Print @(172,29) CLR$(fg,bg)+"     ";
         Print @(172,29) CLR$(fg,bg)+Format$(Tempmax,"% -3.0f"); : Font 1
         Print CLR$(fg,bg)+"o"; : Font 2 :     Print CLR$(fg,bg)+"C";
       Endif
       If metric=0 Then
         Font 2 : Print @(172,29) CLR$(fg,bg)+"     ";
         Print @(172,29) CLR$(fg,bg)+Format$(TempmaxF,"% -3.0f"); : Font 1
         Print CLR$(fg,bg)+"o"; : Font 2 :     Print CLR$(fg,bg)+"F";
       Endif
     EndIf
   Endif
   If page=18 Then Font 2 : Print @(170,250) CLR$(fg,bg)+"   " : Print @(170,280) CLR$(fg,bg)+"   "
   If Temp1>50 Or Temp2>50 Or Temp3>50 Or Temp4>50 Then
     R2=0      'Switch on R2(relay2) to terminate charging.
     If page=18 Then Font 2, ,1 : Print @(170,250) CLR$(fg,bg)+">50"
   EndIf
   If Temp1<5 Or Temp2<5 Or Temp3<5 Or Temp4<5 Then
     R2=0      'Switch on R2(relay2) to terminate charging.
     If page=18 Then Font 2, ,1 : Print @(170,280) CLR$(fg,bg)+"<5"
   EndIf
   If Temp1<50 And Temp2<50 And Temp3<50 And Temp4<50 And Temp1>5 And Temp2>5 And Temp3>5 And Temp4>5 Then R2=1
   Pin(16)=R2
End Sub

Sub UpdateSetup
  Font 2
  Print @(280,90) CLR$(fg,bg)+Date$; 
  Print @(280,120) CLR$(fg,bg)+Time$;
  If metric=1 Then Print @(280,150) CLR$(fg,bg)+"Metric  ";
  If metric=0 Then Print @(280,150) CLR$(fg,bg)+"Imperial";
  Ky$ = Inkey$
  If Ky$="d" Or K$="D" Then
    Print @(20,360) ""; : Line Input "Date(dd-mm-yyyy)?", Date1$
    Date$ = Date1$
    Print @(20,360) "                                  ";
  EndIf
  If Ky$="t" Or K$="T" Then
    Print @(20,360) ""; : Line Input "Time(hh:mm:ss)?", Time1$
    Time$ = Time1$
    Print @(20,360) "                                  ";
  EndIf
  If Ky$="m" or Ky$="M" Then metric=1 
  If Ky$="i" or Ky$="I" Then metric=0
End Sub

'''''''''''''
' MAIN Starts here
  Open "b:AHTMEM.TXT" For input As #10
  Input #10, AHT,page,log
  Close #10  
  Open "b:METRIC.TXT" For input As #10
  Input #10, metric
  Close #10
  If metric<>1 And metric<>0 Then metric=1 
  If MM.Device$="Colour Maximite" Then
    Mode 1,7 : fg=1 : bg=0   
  EndIf
  
  GoSub FindBMS : GoSub setrelays : bmsvolts = 210 : GoSub inversebyte : ready = 1
  Ky$ = Inkey$
  If Ky$="t" Then test=1 : GoSub Chconfig
  If Ky$ <> "t" Then
     GoSub Chconfig : First=1 : GoSub waitForCanData
  EndIf
  Gosub Printheader
  GoSub RS232comm    'This subroutine checks if RS232/BT is active.
  GoSub Clearsubscreen : fg=1 : bg=0
  Library Load "DTC.LIB"
  F11()      'This subroutine checks for DTC and will set FORCED EV mode if relevant DTC is found.
  If ForcedEV=1 Then
    F12() : Pause 50 : F12 : Pause 50 : F12   'This clears (Forced EV) DTC code at start up.
  EndIf
  Library Unload "DTC.LIB"
  If rs232=0 And page=24 Then page=14    'Select which page you want to power up with (page=??)
  If rs232=1 Then page=24    'If EVdisplay comms is available then start with page=24 for EV display Unit
  F2() : 'log=1   , enable battery depletion warning (F2), start data logging(log=1), here.
  GoSub M17screen : fg=1 : bg=0
  If log=1 Then Library Load "F9.LIB" : F9()
  If log=1 And Page<>24 Then Library Load "EVDIS.LIB" : EVDL=1
  If page=1 Then Library Load "PAGE0.LIB" : Drawlabels_LHS()
  If page=5 Then Library Load "F5.LIB" : F5()
  If page=6 Then Library Load "F6.LIB" : F6()
  If page=7 Then Library Load "F7.LIB" : F7()
  If page=8 Then Library Load "F8.LIB" : F8()
  If page=13 Then Library Load "GAUGE13.LIB" : Gauge13()
  If page=14 Then Library Load "PSD.LIB" : PSD()
  If page=15 Then Library Load "BMSPLUS.LIB" : BMSplus()
  If page=16 Then Library Load "GAUGE16.LIB" : Gauge16()
  If page=17 Then Library Load "GAUGE17.LIB" : Gauge17()
  If page=18 Then Library Load "PHEV.LIB" : PHEV()
  If page=19 Then Library Load "TEMP.LIB" : Temp()
  If page=24 And EVDL=0 Then Library Load "EVDIS.LIB" : EVDIS()
  If page=24 And EVDL=1 Then EVDIS()
  If page<1 Or page=>25 Or page=11 Or page=12 or page=23 Then
    If rs232=1 And EVDL=0 Then page=24 : Library Load "EVDIS.LIB" : EVDIS() 
    If rs232=1 And EVDL=1 Then page=24 : EVDIS()
    If rs232=0 Then Library Load "PSD.LIB" : PSD() : page=14
  Endif
Do
  WatchDog off 
  UpdateF1()
  K$ = Inkey$
  Do While KeyDown And K$ <> "" : Loop
'  Watchdog=10000      'This was added to restart program file "RESTART.BAS" if for some unknown reason the basic program stopped running.
  If (K$="q") Or (K$="Q")  Then CAN FREE : Cls 1 : Font 2 : Print CLR$(fg,bg)+"        CANPORT CLOSED" : End
  If k$=Chr$(145)  Then F1() ' F1 - AUTO EV BUTTON - Pressing F1 toggles between AUTO and MANUAL mode for the EV switch
  If K$=Chr$(146)  Then F2() ' Enable/disable PHEV battery "Battery Pack Depleted Warning"
  If K$=Chr$(147)  Then F3() ' Toggle page number to navigate through all screen pages
  If K$=Chr$(148)  Then        ' F4 - PHEV/ORIG BUTTON - Pressing F4 toggles between PHEV and ORIGINAL mode
    F4() : If Warn=1 Then 
      If RS232=0 Then UnloadLibFile() :  page=14 : GoSub M17screen  : Library Load "PSD.LIB" : PSD() ' Power spit device
      If RS232=1 Then UnloadLibFile() :  page=24 : GoSub M17screen  : Library Load "EVDIS.LIB" : EVDIS()
    Endif
  EndIf
  If K$=Chr$(149) And page<>5  Then UnloadLibFile() : page=5 : GoSub M17screen :   Library Load "F5.LIB" : F5() ' Pres F5 then get x14 HV Battery block voltage values
  If K$=Chr$(150) And page<>6  Then UnloadLibFile() : page=6 : GoSub M17screen :   Library Load "F6.LIB" : F6() ' Press F6 then get x14 HV Battery block internal resistance values
  If K$=Chr$(151) And page=7   Then UnloadLibFile() : GoSub M17screen : Library Load "F7.LIB" : F7()
  If K$=Chr$(151) And page<>7  Then UnloadLibFile() : page=22 : GoSub M17screen : Library Load "F7.LIB" : F7() : page=7 
  If k$=Chr$(152) And page<>8  Then UnloadLibFile() : page=8 : GoSub M17screen  : Library Load "F8.LIB" : F8()       'HV flags

  If page=9 Then
    If K$=Chr$(27) And log=1 Then
      If RS232=0 Then Endlog() : Unloadlibfile() : page=14 : GoSub M17screen  : Library Load "PSD.LIB" : PSD()
      If RS232=1 Then Endlog() : Unloadlibfile() : page=24 : GoSub M17screen :  Library Load "EVDIS.LIB" : EVDIS()
    Endif
  EndIf

  If K$=Chr$(153) And log=0 Then
    UnloadLibFile() : page=9 : GoSub M17screen
    Library Load "F9.LIB" : F9() : log=1 ' DATA LOGGING
  EndIf

  If K$=Chr$(153) And log=1 Then page=9 : GoSub M17screen

  If K$="m" Then
    UnloadLibFile()
    If MM.Device$="Colour Maximite" Then Colour fg,bg : Cls 3
    If MM.Device$<>"Colour Maximite" Then Cls
    page=3 : GoSub Clearsubscreen : Font 1,1 : Print @(0,200) "" : Memory ' Memory check page
  EndIf

  If K$="p" And page<>14 Then UnloadLibFile() : page=14 : GoSub M17screen : Library Load "PSD.LIB" : PSD() ' Power spit device
  If K$="s" And page<>15 Then UnloadLibFile() : page=15 : GoSub M17screen : Library Load "BMSPLUS.LIB" : BMSplus()
  If K$="z" Then GoSub toggle : GoSub REP    'Pressing "z" toggles the foreground and background colors.
  If K$="t" And page<>19 Then UnloadLibFile() : page=19 : GoSub M17screen : Library Load "TEMP.LIB" : Temp()
  If K$="v"  Then page=100 :  warn=1 : cn=0 : GoSub warningVGA ' Test warning page
  If K$=Chr$(154) Then F10()  ' HV FAN AUTO/MANUAL BUTTON - Pressing F10 toggles beteen AUTO and MANUAL mode for HV battery fan
  If K$=Chr$(155) Then unloadLibFile() : page=11 : GoSub M17screen : Library Load "DTC.LIB" : F11()  ' If press F11 - then DTC check screen
  If K$=Chr$(156) Then unloadLibFile() : page=12 : GoSub M17screen : Library Load "DTC.LIB" : F11() : F12()  ' If press F12 - Clear DTCs
  If K$="0" Then fanspeed=0
  If K$="1" Then fanspeed=1
  If K$="2" Then fanspeed=2
  If K$="3" Then fanspeed=3
  If K$="4" Then fanspeed=4
  If K$="5" Then fanspeed=5
  If K$="6" Then fanspeed=6
  If K$=Chr$(128) And page<>23 Then oldpage=page : page=23 : GoSub bmsvoltsup : GoSub updateBMS ' Press the up arrow key and BMS end volts increases by 5 volts
  If K$=Chr$(129) And page<>23 Then oldpage=page : page=23 : GoSub bmsvoltsdown : GoSub updateBMS  ' Press the down rrow key and BMS end volts decreases by 5 volts

  If K$=Chr$(27) And Page<>100 Then
    If RS232=1 And page<>24 Then UnloadLibFile() : page=24 : GoSub M17screen : Library Load "EVDIS.LIB" : EVDIS() 
    If RS232=0 And page<>14 Then UnloadLibFile() : page=14 : GoSub M17screen : Library Load "PSD.LIB" : PSD()
    counter=counter+1
    If counter=>3 Then AHT=0
  EndIf

  getcandata()

  If page=3 Then
    Font 1,1 : Colour fg,bg : Print @(0,200) "" : Memory
    Font 1
    Print @(20,270) "MMbasic "MM.Ver
    Print @(20,280)"Date: "Date$
    Print @(20,290)"Time: "Time$
    Print @(20,300)"AHT: " AHT
    Print @(20,320)"FG: " FG
    Print @(20,330)"BG: " BG
    Print @(20,340)"page: " page
  EndIf

  If page=5 Then ' "F5" - HV battery cell voltages
    pidrequest(&H7E3,&H21,&HCE,1) : Filter21CE()
    pidrequest(&H7E3,&H21,&HD0,1) : Filter21D0()  'min/max battery block values
'    pidrequest(&H7E3,&H21,&HCF,1) : filter21CF()  'DeltaSOC
  EndIf

  If page=6 Then ' "F6" - HV battery cell internal resistances
    pidrequest(&H7E3,&H21,&HD0,1) : Filter21D0()
  EndIf

  If page=1 Then
   ' pidrequest(&H7E0,&H21,&H43,0) : filter2143() ' vehicle load
   ' pidrequest(&H7E0,&H1,&H43,0)  : filter0143() ' Absolute load
    pidrequest(&H7E3,&H21,&HCF,1) : filter21CF()  ' HV battery values
   ' pidrequest(&H7E2,&H21,&HC4,1) : filter21C4()  ' Converter temp & HV flags
    updateVGA_LHS()
  EndIf

  If page=7 Then   ' "F7" - graph page
     pidrequest(&H7E2,&H21,&HC4,1) : filter21C4()  'Converter temp & HV flags
     pidrequest(&H7E0,&H21,&H04,0) : filter2104()  'Calculated load
  '  pidrequest(&H7E0,&H21,&H43,0) : filter2143()  'vehicle load
  '  pidrequest(&H7E0,&H21,&H3D,0) : filter213D()   'cat1
  '  pidrequest(&H7E0,&H21,&H3F,0) : filter213F()   'cat2
    updateF7()
    Font 2 
    If HVfan = 0 And (BatDegCh >  25) Then 
      Font 2, ,1 
      If Metric=1 Then
        Print @(280,5) CLR$(fg,bg)+"     "; @(280,5) CLR$(fg,bg)+Format$(BatDegCh,"% -3.0f"); : Font 1, ,1 
        Print CLR$(fg,bg)+"o"; : Font 2, ,1 : Print CLR$(fg,bg)+"C";
      Endif
      If Metric=0 Then
        Print @(280,5) CLR$(fg,bg)+"     "; @(280,5) CLR$(fg,bg)+Format$(BatDegFh,"% -3.0f"); : Font 1, ,1 
        Print CLR$(fg,bg)+"o"; : Font 2, ,1 : Print CLR$(fg,bg)+"F";
      Endif
    Endif
    If HVfan = 0 And (BatDegCh =< 25) Then
      If metric=1 Then 
        Font 2 : Print @(280,5) CLR$(fg,bg)+"     "; @(280,5) CLR$(fg,bg)+Format$(BatDegCh,"% -3.0f") ; : Font 1 
        Print CLR$(fg,bg)+"o"; : Font 2 : Print CLR$(fg,bg)+"C";
      Endif
      If metric=0 Then 
        Font 2 : Print @(280,5) CLR$(fg,bg)+"     "; @(280,5) CLR$(fg,bg)+Format$(BatDegFh,"% -3.0f") ; : Font 1 
        Print CLR$(fg,bg)+"o"; : Font 2 : Print CLR$(fg,bg)+"F";
      Endif
    Endif 
    If HVfan = 1 Then
      If metric=1 Then 
        Font 2 : Print @(280,5) CLR$(fg,bg)+"     "; @(280,5) CLR$(fg,bg)+Format$(BatDegCh,"% -3.0f"); : Font 1 
        Print CLR$(fg,bg)+"o"; : Font 2 : Print CLR$(fg,bg)+"C";
      Endif
      If metric=0 Then 
        Font 2 : Print @(280,5) CLR$(fg,bg)+"     "; @(280,5) CLR$(fg,bg)+Format$(BatDegFh,"% -3.0f"); : Font 1 
        Print CLR$(fg,bg)+"o"; : Font 2 : Print CLR$(fg,bg)+"F";
      Endif
    Endif 
    Font 2
    If Tempmax=>50 Or Tempmax=<5 Then
      If metric=1 Then
        Font 2, ,1 : Print @(360,5) CLR$(fg,bg)+"     ";
        Print @(360,5) CLR$(fg,bg)+Format$(Tempmax,"% -3.0f"); : Font 1, ,1 
        Print CLR$(fg,bg)+"o"; : Font 2, ,1 : Print CLR$(fg,bg)+"C";
      Endif
      If metric=0 Then
        Font 2, ,1 : Print @(360,5) CLR$(fg,bg)+"     "; : TempmaxF=(tempmax*9/5)+32
        Print @(360,5) CLR$(fg,bg)+Format$(TempmaxF,"% -3.0f"); : Font 1, ,1 
        Print CLR$(fg,bg)+"o"; : Font 2, ,1 : Print CLR$(fg,bg)+"F";
      Endif
    EndIf
    If Tempmax<50 And Tempmax>5 Then
      If metric=1 Then
        Font 2 : Print @(360,5) CLR$(fg,bg)+"     ";
        Print @(360,5) CLR$(fg,bg)+Format$(Tempmax,"% -3.0f"); : Font 1 : Print CLR$(fg,bg)+"o"; : Font 2 
        Print CLR$(fg,bg)+"C";
      Endif
      If metric=0 Then
        Font 2 : Print @(360,5) CLR$(fg,bg)+"     "; : TempmaxF=(tempmax*9/5)+32
        Print @(360,5) CLR$(fg,bg)+Format$(TempmaxF,"% -3.0f"); : Font 1 : Print CLR$(fg,bg)+"o"; : Font 2
        Print CLR$(fg,bg)+"F";
      Endif
    EndIf
  Endif
  
  If page=8 Then ' "F8" - HV flags
    pidrequest(&H7E0,&H21,&H04,0) : filter2104()  'Calculated load
 '  pidrequest(&H7E0,&H21,&H43,0) : filter2143()  'vehicle load
    pidrequest(&H7E2,&H21,&HC4,1) : filter21C4()  'CONVerter Temp & HV flags
    updateF8() 'Test ICE flags page
  EndIf

  If page<>8 And page<>100 Then GoSub UpdateVGA_RHS

  CalcPHEV()

  If page=18 Then UpdatePHEV()             'PHEV battery pack temperatures

  If page=14 Then ' "P" - PSD page
    pidrequest(&H7E0,&H21,&H04,0) : filter2104()  'Calculated load
    updatePSD()
  EndIf

  If log=1 Then  ' "F9" - DATA LOGGER
    pidrequest(&H7E0,&H21,&H04,0) : filter2104()  'Calculated load
    pidrequest(&H7E0,&H21,&HCD,1) : filter21CD()  'Tank outlet water temp
    pidrequest(&H7E2,&H21,&HC4,1) : filter21C4()  'CONVerter Temp & HV flags
    pidrequest(&H7E3,&H21,&HCF,1) : filter21CF()  'HV battery values
  '  pidrequest(&H7E3,&H21,&HD0,1) : Filter21D0()  'min/max battery block values
  '  pidrequest(&H7E0,&H21,&H3D,0) : filter213D()   'cat1
  '  pidrequest(&H7E0,&H21,&H3F,0) : filter213F()   'cat2
    Updatef9()
  EndIf

  If page=13 Then
    pidrequest(&H7E0,&H21,&H04,0) : filter2104()  ' Calculated load
    Updategauge13()
  EndIf

  If page=14 Then ' "P" - PSD page
    pidrequest(&H7E0,&H21,&H04,0) : filter2104()  'Calculated load
    updatePSD()
  EndIf

  If page=15 Then UpdateBMSplus()  ' "s" - BMSplusH555 page

  If page=16 Then
    pidrequest(&H7E0,&H21,&H04,0) : filter2104()  ' Calculated load
    Updategauge16()
  EndIf

  If page=17 Then
    pidrequest(&H7E3,&H21,&HCE,1) : Filter21CE()
  EndIf

 If page=19 Then ' "T" - Temperature page
    pidrequest(&H7E3,&H21,&HCF,1) : filter21CF()  ' HV battery values
    pidrequest(&H7E2,&H21,&HC4,1) : filter21C4()  'CONVerter Temp & HV flags
    pidrequest(&H7E0,&H21,&HCD,1) : filter21CD()  'Tank outlet water temp
  ' pidrequest(&H7E0,&H21,&H3D,0) : filter213D()   'cat1
  ' pidrequest(&H7E0,&H21,&H3F,0) : filter213F()   'cat2
    updateVGATemp()
  EndIf

  If page=23 Then
    cntr=cntr+1 
    If cntr=3 then GoSub Clearsubscreen : page=oldpage : cntr=0 : GoSub REP 
  Endif

  If (page=24 Or Log=1) And Rs232=1 Then UpdateEVdis()

  If page=100 Then
    Font 2,1 : Print @(292,76) CLR$(fg,bg)+"SOC%:"
    Print @(360,76) CLR$(fg,bg)+Format$(soc,"% -3.0f");
    If (warningpage=1 And R4=0 And SoC<=73 And SoC<>65) Then Print @(360,76) CLR$(4,1)+Format$(soc,"% -3.0f");
  EndIf

  pidrequest(&H7E2,&H21,&HC3,1) : filter21C3()  'MG1 and MG2

  If Test=0 Then GoSub Firstscanready

  GoSub Priusreadysignal : GoSub Updatestatus : GoSub updatehvfan : UpdateF4() : updateWarn()

  If HVfan=1 Then stepper=stepper + 1 : If stepper > 100 Then fanspeed=6 : stepper=0

  If (looper=3) Then GoSub updateBMS : updateF10() 'HV battery fan speed

  Font 2 : Print @(260,404) CLR$(fg,bg)+Hex$(looper); : looper = looper + 1

  UpdateF1() : UpdateF4()

  If looper => 10 Then
   looper=0 : counter=0
  EndIf
Loop

' END OF MAIN PROGRAM

' START OF NON USER DEFINED SUBROUTINES BELOW:

Chconfig:
  Local ok
  CAN CONFIG ok : CAN SETSPEED 500000, ok : CAN ADDTXCHNL 0,1,ok
  CAN ADDRXCHNL 1,&h3C8,0,1,ok : CAN ADDRXCHNL 2,&h03B,0,1,ok ' Passive PIDs
  CAN ADDRXCHNL 3,&h244,0,1,ok : CAN ADDRXCHNL 4,&h030,0,1,ok
  CAN ADDRXCHNL 5,&h0B4,0,1,ok : CAN ADDRXCHNL 6,&h038,0,1,ok
  CAN ADDRXCHNL 7,&h520,0,1,ok : CAN ADDRXCHNL 8,&h3CB,0,1,ok
  CAN ADDRXCHNL 9,&h555,0,1,ok : CAN ADDRXCHNL 10,&h03A,0,1,ok
  CAN ADDRXCHNL 11,&h3CA,0,1,ok : CAN ADDRXCHNL 12,&h3CF,0,1,ok
  CAN ADDRXCHNL 13,&h039,0,1,ok : CAN ADDRXCHNL 14,&h526,0,1,ok
  CAN ADDRXCHNL 15,&h5A4,0,1,ok : CAN ADDRXCHNL 16,&H348,0,1,ok
  CAN ADDRXCHNL 17,&H529,0,1,ok : CAN ADDRXCHNL 18,&h52C,0,1,ok
  CAN ADDRXCHNL 19,&H7E8,0,1,ok  'tx&H7E0 to rx&H7E8 F11 - GET DTC codes ' Active PIDs
  CAN ADDRXCHNL 20,&H7E9,0,10,ok 'tx&H7E1 to rx&H7E9
  CAN ADDRXCHNL 21,&H7EA,0,10,ok 'tx&H7E2 to rx&H7EA
  CAN ADDRXCHNL 22,&H7EB,0,10,ok 'tx&H7E3 to rx&H7EB
  CAN ADDRXCHNL 23,&H540,0,1,ok
  CAN ADDRXCHNL 24, 0, 0, 32, ok
  CAN ENABLE ok :  Font 2 : CAN PRINTCONFIG
Return

Toggle:     'This subroutine toggles the value of the foreground and backgorund colour
  If fg=1 Then fg=0 Else fg=1
  If bg=1 Then bg=0 Else bg=1
  GoSub Clearsubscreen
Return

REP:
  If page=1 Then Drawlabels_LHS()
  If page=5 Then F5()
  If page=6 Then F6()
'  If page=7 Then F7()
  If page=8 Then F8()
'  If page=9 Then F9()
  If page=13 Then Gauge13()
  If page=14 Then PSD()
  If page=15 Then BMSplus()
  If page=16 Then Gauge16()
  If page=17 Then Gauge17()
  If page=18 Then PHEV()
  If page=19 Then Temp()
  If page=24 Then EVDIS()
Return

M17screen:      'Change screen colors for each page here
  If page=5 Then Mode 1,7 :  ScanLine Red,0,20 : ScanLine Yellow,20,92  : ScanLine Cyan,92,390 : ScanLine Green,390,460
  If page=6 Then Mode 1,7 :  ScanLine Red,0,20 : ScanLine Yellow,20,92  : ScanLine Cyan,92,390 : ScanLine Green,390,460
  If page=7 or page=22 Then Mode 1,7 :  ScanLine Cyan,0,460
  If page=8 Then Mode 1,7 :  ScanLine Cyan,0,460
  If page=9 Then Mode 1,7 :  ScanLine Red,0,20 : ScanLine Yellow,20,92  : ScanLine Cyan,92,390 : ScanLine Green,390,460
  If page=13 Then Mode 1,7 :  ScanLine Red,0,20 : ScanLine Yellow,20,92  : ScanLine Cyan,92,390 : ScanLine Green,390,460
  If page=14 Then Mode 1,7 :  ScanLine Red,0,20 : ScanLine Yellow,20,92  : ScanLine Cyan,92,390 : ScanLine Green,390,460
  If page=15 Then Mode 1,7 :  ScanLine Red,0,20 : ScanLine Yellow,20,92  : ScanLine Cyan,92,390 : ScanLine Green,390,460
  If page=16 Then Mode 1,7 :  ScanLine Red,0,20 : ScanLine Yellow,20,92  : ScanLine Cyan,92,390 : ScanLine Green,390,460
  If page=17 Then Mode 1,7 :  ScanLine Red,0,20 : ScanLine Yellow,20,92  : ScanLine Cyan,92,390 : ScanLine Green,390,460
  If page=18 Then Mode 1,7 :  ScanLine Red,0,20 : ScanLine Yellow,20,92  : ScanLine Cyan,92,390 : ScanLine Green,390,460
  If page=19 Then Mode 1,7 :  ScanLine Red,0,20 : ScanLine Yellow,20,92  : ScanLine Cyan,92,390 : ScanLine Green,390,460
  If page=24 Then Mode 1,7 :  ScanLine Red,0,20 : ScanLine Yellow,20,92  : ScanLine Cyan,92,390 : ScanLine Green,390,460
  If page<>7 And page<>8 And page<>22 then GoSub Clearsubscreen
Return

RS232comm:       'RS232 comms via Bluetooth device HC-05 (set as master at 9600 baud, 1 stop bit, no parity and no flow control
  Open "COM2:9600,45" As #10 : Pause 1000
  If Input$(1,#10)<>"" Then Print "RS232/BT for EV Display - Active" : RS232=1     'RS232 via Bluetooth
  If Input$(1,#10)="" Then Print "RS232/BT for EV Display - NOT ACTIVE" : RS232=0
  Pause 2000
Return

Updatestatus:
  If evMode=0 And icerpm=0 And kph=0 And forcedev=0 Then ev$="          "
  If forcedev=0 And H039data1=&H02 And H348data1<>&H60 And H348data1<>&H62 And H348data1<>&H70 And H348data1=&H01 Then ev$=" ICE Stop "
  If H348data1=&H60 Or H348data1=&H62 Or H348data1=&H70 Then ev$=" ICE Run  "
  If H3C8data0=&H06 Then ev$=" Warm up  "
  If H039data1=&H02 And H348data1=&H60 Then ev$=" ICEspin  "
  If KPH>45 And H039data1=&H02 And H348data1=&H01 And forcedev=0 Then ev$=" STEALTH  "
  If forcedev=1 Then ev$="FORCED EV "
  If page<>7 And page<>8 And page<>100  Then
    Font 1
    Print @(190,380) CLR$(fg,bg)+"    " @(190,380) CLR$(fg,bg)+Format$(evMode,"% g");
    Print @(152,408) CLR$(Black,Green)+"          " @(152,408) CLR$(Black,Green)+ev$
  EndIf
Return

Updatehvfan:
  If page<>7 And page<>8 And page<>100 Then
    Font 2
    If HVfan = 0 And (BatDegCh >  25) Then 
      If Metric=1 Then
        Font 2, ,1 : Print @(172,53) CLR$(fg,bg)+"     "; @(172,53) CLR$(fg,bg)+Format$(BatDegCh,"% -3.0f") ;
        Font 1, ,1 : Print CLR$(fg,bg)+"o"; : Font 2, ,1 : Print CLR$(fg,bg)+"C";
      Endif
    If Metric=0 Then
        Font 2, ,1 : Print @(172,53) CLR$(fg,bg)+"     "; @(172,53) CLR$(fg,bg)+Format$(BatDegFh,"% -3.0f") ;
        Font 1, ,1 : Print CLR$(fg,bg)+"o"; : Font 2, ,1 : Print CLR$(fg,bg)+"F";
      Endif    
    Endif
    If HVfan = 0 And (BatDegCh =< 25) Then 
      If metric=1 Then
        Font 2 : Print @(172,53) CLR$(fg,bg)+"     "; @(172,53) CLR$(fg,bg)+Format$(BatDegCh,"% -3.0f") ;
        Font 1 : Print     CLR$(fg,bg)+"o"; : Font 2     : Print CLR$(fg,bg)+"C";
      Endif
      If metric=0 Then
        Font 2 : Print @(172,53) CLR$(fg,bg)+"     "; @(172,53) CLR$(fg,bg)+Format$(BatDegFh,"% -3.0f") ;
        Font 1 : Print     CLR$(fg,bg)+"o"; : Font 2     : Print CLR$(fg,bg)+"F";
      Endif
    Endif
    If HVfan = 1 Then 
      If metric=1 Then
        Font 2 : Print @(172,53) CLR$(fg,bg)+"     "; @(172,53) CLR$(fg,bg)+Format$(BatDegCh,"% -3.0f"); : Font 1
        Print CLR$(fg,bg)+"o"; : Font 2 : Print CLR$(fg,bg)+"C";
      Endif
      If metric=0 Then
        Font 2 : Print @(172,53) CLR$(fg,bg)+"     "; @(172,53) CLR$(fg,bg)+Format$(BatDegFh,"% -3.0f"); : Font 1
        Print CLR$(fg,bg)+"o"; : Font 2 : Print CLR$(fg,bg)+"F";
      Endif
    Endif
    If Tempmax=>50 Or Tempmax=<5 Then
      If metric=1 Then
        Font 2, ,1 : Print @(172,29) CLR$(fg,bg)+"     ";
        Print @(172,29) CLR$(fg,bg)+Format$(Tempmax,"% -3.0f"); : Font 1, ,1 
        Print CLR$(fg,bg)+"o"; : Font 2, ,1 : Print CLR$(fg,bg)+"C";
      Endif
      If metric=0 Then
        Font 2, ,1 : Print @(172,29) CLR$(fg,bg)+"     "; : TempmaxF=(Tempmax*9/5)+32
        Print @(172,29) CLR$(fg,bg)+Format$(TempmaxF,"% -3.0f"); : Font 1, ,1
        Print CLR$(fg,bg)+"o"; : Font 2, ,1 : Print CLR$(fg,bg)+"F";
      Endif
    EndIf
    If Tempmax<50 And Tempmax>5 Then
      If metric=1 Then
        Font 2 : Print @(172,29) CLR$(fg,bg)+"     ";
        Print @(172,29) CLR$(fg,bg)+Format$(Tempmax,"% -3.0f"); : Font 1
        Print CLR$(fg,bg)+"o"; : Font 2 :     Print CLR$(fg,bg)+"C";
      Endif
      If metric=0 Then
        Font 2 : Print @(172,29) CLR$(fg,bg)+"     "; : TempmaxF=(Tempmax*9/5)+32
        Print @(172,29) CLR$(fg,bg)+Format$(TempmaxF,"% -3.0f"); : Font 1
        Print CLR$(fg,bg)+"o"; : Font 2 :     Print CLR$(fg,bg)+"F";
      Endif
    EndIf
  EndIf
Return

UpdateBMS:
  Local inLoop : Font 1
  If R4=0 Then GoSub SendPHEV
  If R4=1 Then GoSub SendORIG
  inLoop = 0
  Looper1:
    If bms=1 Then
      If page<>7 And page<>8 And page<>100 Then
        If R4=1 Then 
          If page=23 Then GoSub Clearsubscreen : Font 2,2 : Print @(20,150) "ORIG" @(20,200) "@"bmsvolts" V";
          Font 1 : Print @(16,28) CLR$(fg,bg)+"BMS MODE : ORIG @" bmsvolts ; : Print @(141,28) CLR$(fg,bg)+" V "; : Exit Sub         
        Endif
        If R4=0 Then 
          If page=23 Then GoSub Clearsubscreen : Font 2,2 : Print @(20,150) "AUTO" @(20,200) "@"bmsvolts" V";
          Font 1 : Print @(16,28) CLR$(fg,bg)+"BMS MODE : AUTO @" bmsvolts ; : Print @(141,28) CLR$(fg,bg)+" V "; : Exit Sub
        Endif
      EndIf
    EndIf
  inLoop = inLoop + 1 : If inLoop > 5 Then Exit Sub
  GoTo Looper1
Return

SendPHEV:  ' 195v - 235v
  Local txData(8), txOk : GoSub inversebyte
  txData(0) = bmsvolts : txData(1) = voltsbms : ' Inverse of bmsvolts
  CAN TX 0,&H556,0,8,txData(0),txOk
  If txOk = 0 Then Print @(16,28) CLR$(fg,bg)+"Could not send PHEV 556 @"; bmsvolts; CLR$(fg,bg)+" V to BMS+"
Return

SendORIG:  ' 238v
  Local txData(3), txOk : txData(0) = &HEE : txData(1) = &H11
  txData(2) = &H00 : CAN TX 0,&H556,0,3,txData(0),txOk : bmsvolts = 238 : GoSub inversebyte
  Print @(16,28) CLR$(fg,bg)+"BMS MODE: ORIGINAL" bmsvolts CLR$(fg,bg)+" V";
  If txOk = 0 Then Print @(16,28) CLR$(fg,bg)+"Could not send ORIG 556 @"; bmsvolts; CLR$(fg,bg)+" V to BMS+"
Return

bmsvoltsdown:
  bmsvolts = bmsvolts - 5
  If (bmsvolts < 195) Then bmsvolts = 195
  GoSub inversebyte
Return

bmsvoltsup:
  bmsvolts = bmsvolts + 5
  If (bmsvolts > 235) Then bmsvolts = 235
  GoSub inversebyte
Return

setrelays:
  SetPin 15,9 : SetPin 16,9 : SetPin 17,9 : SetPin 18,9
  SetPin 1,1 : SetPin 2,1 : SetPin 3,1 : SetPin 4,1
  Pin(15)=1 : Pin(16) = 1 : Pin(17) = 1 : Pin(18) = 1 : Pause 1000 : Pin(18) = R4
Return

Firstscanready:
  If running=1 And ready=0 And ACC=0 Then
    Close #10
    Open "b:AHTMEM.TXT" For output As #10
    Write #10, AHT,page,log
    Close #10 : running=0
  EndIf
  If ready=1 or ACC=1 Then running=1 : Exit Sub
  GoSub waitforCanData : R1=0 : Cls 1  : Run "autorun.bas"
Return

Priusreadysignal:
  Local rxData(8), rxOk, inLoop, cn : inLoop = 0
  Looper2:
    CAN RX 6,rxData(0),rxOk : ' H038 Ready Signal
    If rxOk=1 And rxData(0)=>192 Then  Ready=1 : ACC=0 : cn=0
    If rxOk=1 And rxData(0)=192 Then
      If Page<>7 And Page<>8 And Page<>100 Then
        Font 1 : Print @(78,50) CLR$(fg,bg)+"      "; @(78,50) CLR$(fg,bg)+"READY"; 
      EndIf
      cn=0 : Pin(18) = R4 
    EndIf
    If rxOk=1 And (rxData(0)=204 or rxData(0)=200 or rxData(0)=196) Then
      If Page<>7 And Page<>8 And Page<>100 Then
        Font 1 : Print @(78,50) CLR$(fg,bg)+"      "; @(78,50) CLR$(fg,bg)+"YAHOO";   'Pressing the gas pedal too hard..
      EndIf
      cn=0 : Pin(18) = R4 
    EndIf
    If rxOk=1 And rxData(0)=128 Then
      If Page<>7 And Page<>8 And Page<>100 Then
        Font 1 : Print @(78,50) CLR$(fg,bg)+"      "; @(78,50) CLR$(fg,bg)+"ACC";    'Power button - Accessories 2nd position.. press power button twice after off
      EndIf
      ACC = 1 : cn=0
    EndIf
    If rxOk=1 And Page<>7 And Page<>8 And Page<>100 Then Font 1 : Print @(76,70) CLR$(fg,bg)+Format$(rxData(0),"% g"); : cn=0
    If rxOk=1  And rxData(0)=192 Then Exit Sub
    If rxOk=1 And rxData(0)<192 Then Ready=0 : Pin(15)=1 : Pin(18)=1 : Exit Sub
    If rxOk=0 Then 
      cn=cn+1
      If cn=10 Then Ready=0 : ACC=0 : Pin(15)=1 : Pin(18)=1 : cn=0 : Exit Sub
    Endif
  GoTo Looper2
Return

waitForCanData:
  Local rxData(8), rxOk, cn : rxOk=0
  If first=0 Then Gosub RS232comm
  Looper5:
    CAN RX 1,rxData(0),rxOk
    If rxOk=1 And Standby=1 Then
      Open "b:METRIC.TXT" For output As #10
      Write #10, metric
      Close #10
      Standby=0 : cn=0 : First=0 : Exit Sub
    Endif
    If rxOk=0 And Standby=0 Then cn=cn+1
    If Standby=0 And cn=10 Then 
      Standby=1 : GoSub Printheader : Font 2,2 : Print @(20,390) "STANDBY"; : cn=0 : Font 2
      If first=0 Then Close #10
      Open "b:METRIC.TXT" For input As #10
      Input #10, metric
      Close #10 : running=0
      Print @(20,40) CLR$(fg,bg)+"SETUP";
      Print @(20,90) CLR$(fg,bg)+"Date(dd-mm-yyyy): ";
      Print @(20,120) CLR$(fg,bg)+"Time  (hh:mm:ss): ";
      Print @(20,150) CLR$(fg,bg)+"Units(Metr/Impe): ";
      Print @(20,180) CLR$(fg,bg)+"MMbasic "MM.Ver
      Print @(20,220) CLR$(fg,bg)+"": Memory 
'      If First=0 And RS232=1 Then EVdis()
    Endif
'    If Standby=1 And Log=1 And First=0 Then UpdateF9()
'    If Standby=1 And First=0 And RS232=1 Then UpdateEVdis()
    If Standby=1 Then UpdateSetup()
    If Standby=1 And First=0 Then CalcPHEV() 
    ' Watchdog=10000
  GoTo Looper5
Return

findBMS:
  Local rxData(8), rxOk, looper : looper = 0
  If (BMS=0 And page<>7 And page<>8 And page<>100) Then Font 1 : Print @(16,28) CLR$(fg,bg)+"No BMS+ installation found";
  Looper9:
    CAN RX 9,rxData(0),rxOk
    If (rxOk=1) And (page<>7) And (page<>8) And (page<>100) Then
      Print @(16,28) CLR$(fg,bg)+"BMS MODE : AUTO @" bmsvolts  @(141,28) CLR$(1,3) +" V         "; : Exit Sub
    EndIf
    looper = looper + 1
    If looper > 5 Then Exit Sub
  GoTo Looper9
Return

clearsubscreen:   ' Clear screen
  GoSub Printheader : GoSub Drawlabels_RHS : GoSub Drawboxes
Return

drawBoxes:
  If page<>8 Then
    If MM.Device$="Colour Maximite" Then Line(15,395)-(66,428),Green,BF 'F1(EV)
    If MM.Device$="Colour Maximite" Then Line(15,395)-(66,428),Black,B  'F1(EV)
    If MM.Device$<>"Colour Maximite" Then Line(15,395)-(66,428),Green,B 'F1(EV)
    Font 1 : Print @(35,400) CLR$(Black,Green)+"F1";
    Font 1 : Print @(20,415) CLR$(Black,Green)+"EV AUTO";
    If MM.Device$="Colour Maximite" Then Line(80,395)-(131,428),Green,BF'F4(PHEV) box
    If MM.Device$="Colour Maximite" Then Line(80,395)-(131,428),Black,B 'F4(PHEV) box outline
    If MM.Device$<>"Colour Maximite" Then Line(80,395)-(131,428),Green,B 'F4(PHEV
    Print @(100,400) CLR$(Black,Green)+"F4"; @(93,415) CLR$(Black,Green)+"   ";
    If MM.Device$="Colour Maximite" Then Line(145,395)-(217,428),Green,BF ' status box
    If MM.Device$="Colour Maximite" Then Line(145,395)-(217,428),Black,B   ' status box outline
    If MM.Device$<>"Colour Maximite" Then Line(145,395)-(217,428),Green,B   ' sta
    If MM.Device$="Colour Maximite" Then Line(15,45)-(66,77),Green,BF 'F12 box
    If MM.Device$="Colour Maximite" Then Line(15,45)-(66,77),Black,B 'F12 box outline
    If MM.Device$<>"Colour Maximite" Then Line(15,45)-(66,77),Green,B 'F12 box
    Print @(32,50) CLR$(Black,Green)+"F12"; : Print @(20,65) CLR$(Black,Green)+"CLR DTC";
    If MM.Device$="Colour Maximite" Then Line(115,45)-(170,77),Green,BF 'F10 box
    If MM.Device$="Colour Maximite" Then Line(115,45)-(170,77),Black,B  'F10 box outline
    If MM.Device$<>"Colour Maximite" Then Line(115,45)-(170,77),Green,B  'F10 box
    Print @(132,50) CLR$(Black,Green)+"F10  "; @(120,65) CLR$(Black,Green)+"FAN AUTO";
  EndIf
Return

printHeader:
  If page<>8 Then
    Line(0,0)-(820,480),bg,bf : Font 2
    If MM.Device$="Colour Maximite" Then Print @(15,0) CLR$(Black,Green)+"CGCOLORMAX-CANVIEW V4/BMS+ PRIUS G2";
    If MM.Device$<>"Colour Maximite" Then Print @(15,0) CLR$(Black,Green)+"DUINOMITE-CANVIEW V4/BMS+ PRIUS G2";
  EndIf
Return

drawlabels_rhs:
  If page<>8 Then
    Font 2 : Print @(280,35) CLR$(fg,bg)+"Volts:"  @(293,70) CLR$(fg,bg)+"Amps:"
    Print @(280,106) CLR$(fg,bg)+"A-MAX:" @(280,142) CLR$(fg,bg)+"A+MAX:";
    If page=14 Then Print @(294,182) CLR$(fg,bg)+"Load:" Else Print @(306,182) CLR$(fg,bg)+"RPM:"
    Print @(268,218) CLR$(fg,bg)+"BRAKE%:" @(292,256) CLR$(fg,bg)+"SOC%:" @(266,290) CLR$(fg,bg)+"THROT%:";
    Print @(268,328) CLR$(fg,bg)+"ICE KW:"
    If ((page=<7 Or page=>9) And page<100 And page<>0) Then Print @(307,363) CLR$(fg,bg)+" AH: "; ' Else Print @(307,363) "KPH:"
    Print @(307,398) CLR$(fg,bg)+"ECT:";
  EndIf
Return

updateVGA_RHS:
  Font 3 : Print @(360,26) CLR$(fg,bg)+Format$(volts,"% -3.0f");
  Print @(360,62) CLR$(fg,bg)+Format$(current,"%+-5.0f");
  Print @(360,96)  CLR$(fg,bg)+Format$(Dmax,"% -4.0f");
  Print @(360,132) CLR$(fg,bg)+Format$(Cmax,"% -4.0f");
  If page=14 Then Print @(360,172) CLR$(fg,bg)+Format$(Cload,"% -2.0f"); Else Print @(360,172) CLR$(fg,bg)+Format$(icerpm,"% -5.0f");
  Print @(360,210) CLR$(fg,bg)+Format$(brake,"% -3.0f");
  Print @(360,246) CLR$(fg,bg)+Format$(soc,"% -3.0f");
  If (warningpage=1 And R4=0 And SoC<=73 And SoC<>65) Then Print @(360,246) CLR$(bg,fg)+Format$(soc,"% -3.0f");
  Print @(360,280) CLR$(fg,bg)+Format$(throt,"% -3.0f");
  Print @(360,316) CLR$(fg,bg)+Format$(ICEkw,"% -3.0f");
  If RS232=0 then
    If ((page=<7 Or page=>9) And page<100 And page<>0) Then Print @(360,352) CLR$(fg,bg)+ Format$(AHT,"%04.1f");
  Endif
  If RS232=1 or log=1 then
    If page=24 Then Print @(360,352) CLR$(fg,bg)+ Format$(EVah,"%04.1f");
    If ((page=<7 Or page=>9) And page<100 And page<>0 And page<>24) Then Print @(360,352) CLR$(fg,bg)+ Format$(AHT,"%04.1f");
  Endif
  If metric=1 Then
    Font 3 : Print @(360,390) CLR$(fg,bg)+"     ";
    Print @(360,390) CLR$(fg,bg)+Format$(ect,"% -3.0f"); : Font 1
    Print CLR$(fg,bg)+"o"; : Font 3 : Print CLR$(fg,bg)+"C";
  Endif
  If metric=0 Then
    ectf=(ect*9/5)+32
    Font 3 : Print @(360,390) CLR$(fg,bg)+"     ";
    Print @(360,390) CLR$(fg,bg)+Format$(ectf,"% -3.0f"); : Font 1
    Print CLR$(fg,bg)+"o"; : Font 3 : Print CLR$(fg,bg)+"F";
  Endif
  If page<>7 And page<>8 And page<>100 Then Font 2, ,1 : Print @(230,404) shift$
Return

inversebyte:
  If bmsvolts = &HC3 Then voltsbms = &H3C   'PHEV mode 195v
  If bmsvolts = &HC8 Then voltsbms = &H8C   'PHEV mode 200v
  If bmsvolts = &HCD Then voltsbms = &HDC   'PHEV mode 205v
  If bmsvolts = &HD2 Then voltsbms = &H2D   'PHEV mode 210v
  If bmsvolts = &H7D Then voltsbms = &HD7   'PHEV mode 215v
  If bmsvolts = &HDC Then voltsbms = &HCD   'PHEV mode 220v
  If bmsvolts = &HE1 Then voltsbms = &H1E   'PHEV mode 225v
  If bmsvolts = &HE6 Then voltsbms = &H6E   'PHEV mode 230v
  If bmsvolts = &HEB Then voltsbms = &HBE   'PHEV mode 235v
  If bmsvolts = &HEE Then voltsbms = &HEE   'Original mode 238v
Return

WarningVGA:
  If warn=1 Then
    Cls 1 : Font 2,2,1 : Print @(80,150) CLR$(fg,bg)+"!! WARNING !!"
    Font 2,1,0 : Print @(100,250) CLR$(fg,bg)+"PHEV battery pack depleted"
    Print @(100,300) CLR$(fg,bg)+"Press F4 to exit"
  EndIf
Return









