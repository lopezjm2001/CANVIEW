DISCLAIMER - USE AT OWN RISK

Release date: 26 May 2014 (C)John Lopez

Program now includes interface with EV Display Unit from www.cleanpowerauto.com using bluetooth modules. Also includes four temperature measurements of the PHEV
battery pack using RTD's.

This basic program was written for the Duinomite Mega or the CGcolormax (Colour Maximite) with a CANbus port. Designed to be used as a CANVIEW
for a Toyota Prius Second Generation (2004 - 2008).

To be used with mmBasic V4.4.

Watchdogtimer command now included. Watchdogtimer timing out to zero will cause file "RESTART.BAS" TO RUN which in turn will run file "AUTORUN.BAS".

WARNING: Watching the CANVIEW v4.0 screen whilst driving is dangerous and any subsequent 
accident due to not watching the road is entirely your fault. The police can charge you with 
negligent driving as a result of doing so. So be warned.....do not watch the CANview V4.0 LCD 
screen whilst driving!!

CANVIEW V4 - WWW.HYBRIDINTERFACES.CA
 
Based on the original Canview V4 by Norm Dick

This version by lopezjm2001@priuschat.com

This BASIC program is intended for a Duinomite Mega using a keyboard and a VGA monitor.
At a later date it will be updated for a touch screen as shown here

http://www.thebackshed.com/forum/forum_posts.asp?TID=5291&PN=7

Setup for BMSplus end voltage range 195v - 235v in 5v steps (default value is now 210, 
same as Norm's Canview). 

When R1-R4 = 0 relay is energised.

The HV battery fan speed runs in either:-
  
	auto   - controlled by HV battery temperature limit i.e. 25degC or
	Manual - set speed by pressing number 1 to 6 on keyboard to change speed

In manual it will run at a speed lower than 6 for a fixed period of time and then 
automatically change to 6 being maximum speed.
 
The files required are available for free @ WWW.Priuschat.com at

http://priuschat.com/threads/my-duinomite-mega-canview-v4-equivalent-project.112429/

This basic program autorun.bas is compatible with using the latest version of mmbasic V4.4 by Geoff Graham with 
John Harding's CAN COMMAND implementation available for free at
 
http://priuschat.com/attachments/duinomite-canb2-zip.42794/

or
 
http://geoffg.net/Downloads/Maximite/MMBasic%20with%20CAN.zip

Files (autorun.bas and logo.bmp and AHTMEM.TXT and restart.bas) must be stored in the root directory of the microSD card of your Duinomite Mega.

The program is saved as "AUTORUN.BAS" as it will be loaded and will run automatically 
from the micro SD card and must be saved into the root directory on the micro SD card. Any other 
file name has to manually loaded and executed.

An Amp Hour meter is now included. The updating time varies depending on whether data logging is active and which page you are looking at . 
On Prius power down the amp hour reading is saved to a text file called AHTMEM.TXT and on Prius power up it is loaded from the same file.
The Amp Hour meter counts up. The text file AHTMEM.TXT must exist in the root direct of the SD card. If the file does not exist the Basic interpretor 
will stop the program and show an error that file does not exist. Pressing the ESC button three times quickly will reset the Amp Hour meter to 0.00.

If you press the "t" key on your keyboard at bootup you can run the program without
the Duinomite Mega board having to be hooked up to a live CANbus port. It will skip the intro and
will not wait for CANbus data.

Canview V4.0 Basic Program Pages

Keyboard button - page description

F1  - EV man/auto
F2  - Enginer Converter 1 button AUTO/OFF, now used to switch on "Warning Active", when PHEV battery
      is depleted you will get a warning. Press F4 to exit.
F3  - Enginer Converter 2 button AUTO/OFF, now used to switch between all pages except F7 and F9. I have added somwe gauge screens which are only accessible
      by pressing the F3 keyboard button.
F4  - PHEV/ORIG 
F5  - OEM Nimh cell voltages
F6  - OEM NIMH cell resistances
F7  - Plot a graph, press F7 again to select two variables to plot.
F8  - Data analysis page. 
F9  - Data logging page. Press ESC to finish logging. Data is saved to DATA1.CSV, DATA2.CSV,DATA3.CSV,DATA4.CSV and DATA5.CSV.
       You can navigate between pages whilst data logging but you can only END logging on F9 page by pressing the ESC key. 
        Data logging is now appended to data files. A date$ and time$ stamp is included at start of each data logging session. 
        The date$ and time$ value will be lost when Duinomite Mega is powered down and will change to default values (Year 2000, time 00:00:00)when powered up 
         unless a Lipo battery is plugged into the Duinomite Mega JST connector.
        The LiPo battery with 3.7V 1400mA capacity and JST connector for DuinoMite-Mega is available
         from Olimex. At maximum frequency with a VGA monitor connected the consumption is 125mA which
         will allow the DuinoMite-Mega to run about 10 hours on battery.
         A asterix will blink on every page when data logging is active.
F10 - HV battery fan AUTO/MANUAL speed button. Press 1 to 6 on keyboard when in manual mode.
         to adjust  speed when in MANUAL. 
F11 - get DTC codes and log DTC codes to a Excel file.
F12 - clear DTCs and log DTC codes to a Excel file.
m  -  memory page
s     - BMSplus H555 canbus message
p     - PSD page - Power Split Device.
t     - Temperature page
q     - quit
z     - Toggle foreground and background colours.
ESC - Goes back to main page, If on F9 - "Data Logging page" pressing the ESC key will END Data Logging. Press ESC three times to reset AmpHour meter.

DISCLAIMER - USE AT OWN RISK

------------------------------------------------------------------------------------------------------

SETUP PAGE

The setup page is only accessible in accessories 1 mode. In this mode there is no CAN communicatons in the Prius.

m - metric system.
i - imperial
d - date i.e. dd-mm-yyyy then press enter.
t - time i.e. hh:mm:ss then press enter.

You can set the time and date and Change from metric to imperial for temperature readings oC/oF. 




