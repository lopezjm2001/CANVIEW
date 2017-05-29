  
  If mm.device$="Colour Maximite" then 
    Mode 3 : Cls
    LoadBMP "logo.bmp",30,150
  Endif
  If mm.device$<>"Colour Maximite" then Cls : LoadBMP "DMlogo.bmp",30,30
  Pause 1000
  Cls
  If mm.device$="Colour Maximite" then Mode 2,4
  Run "autostt.bas"
