# CHEKMO WinBoard Interface
This Delphi 7 project allows the use of "WinBoard" as a graphical user interface to the ancient (written in the '70s) chess program "CHEKMO-II" running on the SIMH PDP-8 Simulator. Using WinBoard you move your chess pieces by dragging and dropping with your mouse rather than typing in the chess board coordinates for each move.

Documentation for the CHEKMO-II chess program can be found [here](https://www.grc.com/pdp-8/docs/CHEKMO-II_PDP-8_Chess.pdf).

The Delphi source files are found in the "delphi project" folder. If you don't have the Delphi compiler, all the binaries needed are found in the "executables" folder.

The SIMH PDP-8 simulator and WinBoard communicate through a pair of virtual serial ports created by the com-0-com virtual serial port driver. The com-0-com setup application is found in the "executables" folder. In my setup, the two virtual serial ports are COM9 and COM10. If your use different ports, you will need to edit "chess.ini" and "wb_chekmo.ini".

The VBScript "CHEMKO-II Chess using WinBoard.vbs" is used load and start the interface
<p align="center">My "Blitz Mode" game against CHEKMO. I'm playing white.</p><br>
<p align="center"><img src="/images/20190627_115202.gif"/>
