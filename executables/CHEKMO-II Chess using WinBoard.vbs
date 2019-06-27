' Uses a pair of virtual serial ports created by the com-0-com virtual null modem. 
' In the pdp8.ini file, configure the SIMH PDP-8 simulator to use the first virtual serial port of the pair for its console. 
' In the wb_chekmo.ini file, configure the wb_chekmo application to use the second virtual serial port of the pair.

'Create the WScript object
Set WshShell=WScript.CreateObject("WScript.Shell")

'start the PDP-8 SIMH simulator minimized, don't wait
ReturnCode=WshShell.Run("pdp8.exe chess.ini",2,false)

'wait one half second for the PDP-8 SIMH simulator to start
WScript.Sleep 500

'run WinBoard, wait until it exits (WinBoard starts and stops WB_CHEKMO automatically)
ReturnCode=WshShell.Run("winboard.exe /cp /fcp wb_chekmo.exe",1,true)

'kill the pdp8.exe task after WinBoard exits
returnCode=WshShell.Run("taskkill /im pdp8.exe", ,true)


