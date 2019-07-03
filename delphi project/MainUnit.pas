/////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                         //
// WinBoard interface to CHEKMO running the SIMH emulator.                                 //
//                                                                                         //
// Thanks to Dr. Maciej Szmit for his WBUnit that makes the interface to WinBoard trivial. //
// Thanks to the people at Async Pro for their Terminal demo which served as the basis for //
// this application.                                                                       //
//                                                                                         //
/////////////////////////////////////////////////////////////////////////////////////////////

unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, StrUtils,
  Dialogs, OoMisc, ADTrmEmu, Menus, AdPort, AdXPort, AdSelCom, WBUnit, HH, INIFiles, ShellApi;

type
  TMainForm = class(TForm)
    AdTerminal1: TAdTerminal;
    MainMenu1: TMainMenu;
    mnuFile: TMenuItem;
    nmuEdit: TMenuItem;
    nmuSetup: TMenuItem;
    mnuHelp: TMenuItem;
    ApdComPort1: TApdComPort;
    FontDialog1: TFontDialog;
    mnuSetUpFont: TMenuItem;
    mnuFileExit: TMenuItem;
    mnuEditClear: TMenuItem;
    mnuHelpHelp: TMenuItem;
    mnuHelpAbout: TMenuItem;
    mnuSetupSerialPort: TMenuItem;
    mnuSetupColor: TMenuItem;
    ColorDialog1: TColorDialog;
    procedure AdTerminal1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure mnuSetUpFontClick(Sender: TObject);
    procedure mnuFileExitClick(Sender: TObject);
    procedure mnuEditClearClick(Sender: TObject);
    procedure mnuHelpAboutClick(Sender: TObject);
    procedure ApdComPort1TriggerAvail(CP: TObject; Count: Word);
    procedure mnuHelpHelpClick(Sender: TObject);
    procedure mnuSetupSerialPortClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mnuSetupColorClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ParseLine(LineToParse: string);
  private
    { Private declarations }
  public
    { Public declarations }
    WbThread : TWbThread;
    procedure WinBoardMessage(var Msg: TMessage); message CW_WBMSG;
  end;

  PieceColors = (White,Black,Undetermined);  // used to indicate what color CHEKMO is playing
  Turns = (WhitesTurn,BlacksTurn);

var
  MainForm: TMainForm;
  IniFileName,fromCHEKMO: string;
  CHEKMOcolor: PieceColors;
  WhoseTurn: Turns;
  simhStarted: boolean;

implementation

uses CopyrightUnit, WBMonitorUnit, CKMonitorUnit;

{$R *.dfm}

procedure Delay(Milliseconds: Integer);
var Tick: DWORD;
    Event: THandle;
begin
   Event := CreateEvent(nil, False, False, nil);
   try
      Tick := GetTickCount + DWORD(Milliseconds);
      while (Milliseconds > 0) and (MsgWaitForMultipleObjects(1, Event, False, Milliseconds, QS_ALLINPUT) <> WAIT_TIMEOUT) do
         begin
            Application.ProcessMessages;
            Milliseconds := Tick - GetTickCount;
         end;
   finally
      CloseHandle(Event);
   end;
end;

//------------------------------------------------------------------------------//
// Control C to display the CHEKMO "monitor" window.                            //
// Control W to display the WinBoard "monitor" window.                          //
// Convert all other keys to upper case for OS/8.                               //
//------------------------------------------------------------------------------//
procedure TMainForm.AdTerminal1KeyPress(Sender: TObject; var Key: Char);
begin
   case Key of
      #3:  begin  // Control C displays the CHEKMO monitor window
              CKMonitorForm.Show;
              Key := #0;
           end;
      #23: begin  // Control W displays the WinBoard monitor window
              WBMonitorForm.Show;
              Key := #0;
           end;
      else Key := Upcase(Key); // convert everything to uppercase for OS/8
   end;
end;

//------------------------------------------------------------------------------//
// Message received from WinBoard through the WBThread...                       //
// See http://www.open-aurec.com/wbforum/WinBoard/engine-intf.html for details  //
// about the Chess Engine Communcations Protocol.
//------------------------------------------------------------------------------//
procedure TMainForm.WinBoardMessage(var Msg: TMessage);
var fromWinboard,toCHEKMO,toSend:string;
begin
   fromWinBoard := WbThread.WinBoardCommand;                        // get the data received from WinBoard
   WBMonitorForm.meWBMonitor.Lines.Add('from WinB: '+fromWinBoard);

   if pos('quit',fromWinBoard) > 0 then	Close

   else if pos('protover 2',fromWinBoard) > 0 then                  // this WinBoard speaks protocol version 2
      begin
         toSend := 'feature time=0';                                // winboard will not send the "time" and "otim" commands to update the engine's clocks
         WBThread.SendCommand(toSend);
         WBMonitorForm.meWBMonitor.Lines.Add('to   WinB: '+toSend);

         toSend := 'feature myname="CHEKMO"';
         WBThread.SendCommand(toSend);
         WBMonitorForm.meWBMonitor.Lines.Add('to   WinB: '+toSend);

         toSend := 'feature option="Blitz Mode -button"';           // button on WinBoard menu "Engine" --> "Engine #1 Settings..."
         WBThread.SendCommand(toSend);
         WBMonitorForm.meWBMonitor.Lines.Add('to   WinB: '+toSend);

         toSend := 'feature option="Normal Mode -button"';          // button on WinBoard menu "Engine" --> "Engine #1 Settings..."
         WBThread.SendCommand(toSend);
         WBMonitorForm.meWBMonitor.Lines.Add('to   WinB: '+toSend);

         toSend := 'feature done=1"';                               // end timeout, start normal operation.
         WBThread.SendCommand(toSend);
         WBMonitorForm.meWBMonitor.Lines.Add('to   WinB: '+toSend);
      end

   else if pos('new',fromWinBoard) > 0 then                         // Reset the board to the standard chess starting position. Set White on move. Leave force mode and set the engine to play Black.
      begin
         if simhStarted then
            begin
               MainForm.ApdComPort1.PutString('RE'^M);                    // send "REset" command over serial link to CHEKMO, end with <CR>
               Delay(250);
               MainForm.ApdComPort1.PutString('PB'^M);                    // send "Play Black" command over serial link to CHEKMO, end with <CR>
               CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'RE');
               CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'PB');
               CHEKMOcolor := Undetermined;                               // we don't know what color CHEKMO will play next game
               WhoseTurn := WhitesTurn;                                   // but white always moves first
            end
         else
            begin
               MainForm.ApdComPort1.PutString('R CHESS'^M);               // send "Run CHESS" command
               Delay(250);
               MainForm.ApdComPort1.PutString('PB'^M);                    // send "Play Black" command
               CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'R CHESS');
               CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'PB');
               simhStarted := true;
            end;
      end

   else if pos('result',fromWinBoard) > 0 then                      // Winboard reports the result at the end of the game
      begin
         MainForm.ApdComPort1.PutString('RE'^M);                    // send "REset" command over serial link to CHEKMO, end with <CR>
         CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'RE');
         CHEKMOcolor := Undetermined;                               // we don't know what color CHEKMO will play next game
         WhoseTurn := WhitesTurn;                                   // but white always moves first
      end

   else if pos('draw',fromWinBoard) > 0 then                        // The engine's opponent offers the engine a draw.
      begin
         MainForm.ApdComPort1.PutString('RE'^M);                    // send "REset" command over serial link to CHEKMO, end with <CR>
         CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'RE');
         CHEKMOcolor := Undetermined;                               // we don't know what color CHEKMO will play next game
         WhoseTurn := WhitesTurn;                                   // but white always moves first
      end

  else if pos('white',fromWinBoard) > 0 then                        // set CHEKMO to play white
      begin
         MainForm.ApdComPort1.PutString('PN'^M);                    // "Play Neither" command cancels previous "Play Black" command
         Delay(250);
         MainForm.ApdComPort1.PutString('PW'^M);                    // send "Play White" command over serial link to CHEKMO, end with <CR>
         CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'PN');
         CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'PW');
         CHEKMOcolor := Undetermined;                               // we don't know what color CHEKMO will play next game
         WhoseTurn := WhitesTurn;                                   // but white always moves first
      end

  else if pos('black',fromWinBoard) > 0 then                        // set CHEKMO to play black
      begin
         MainForm.ApdComPort1.PutString('PN'^M);                    // "Play Neither" command cancels previous "Play White" command
         Delay(250);
         MainForm.ApdComPort1.PutString('PB'^M);                    // send "Play Black" command over serial link to CHEKMO, end with <CR>
         CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'PN');
         CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'PB');
         CHEKMOcolor := Undetermined;                               // we don't know what color CHEKMO will play next game
         WhoseTurn := WhitesTurn;                                   // but white always moves first
      end

  else if pos('blitz mode',fromWinBoard) > 0 then                   // WinBoard "blitz mode" button clicked
      begin
         MainForm.ApdComPort1.PutString('BM'^M);                    // send "Blitz Mode" command to CHEKMO
         CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'BM');
      end

  else if pos('normal mode',fromWinBoard) > 0 then                  // WinBoard "normal mode" button clicked
      begin
         MainForm.ApdComPort1.PutString('TM'^M);                    // send "Thoughtful Mode" command to CHEKMO
         CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'TM');
      end

   else if pos('xboard',fromWinBoard) > 0 then                      // This command will be sent once immediately after your engine process is started. You can use it to put your engine into "xboard mode"
      begin
         WBThread.SendNewLine;                                      // respond with newline
         WBMonitorForm.meWBMonitor.Lines.Add('to   WinB: '+'\n');
      end

   else if pos('random',fromWinBoard) > 0 then                      // This command is specific to GNU Chess 4. You can ignore it completely.
      begin
      end

   else if pos('level',fromWinBoard) > 0 then                       // Set time controls
      begin
      end

   else if pos('force',fromWinBoard) > 0 then                       // Set the engine to play neither color ("force mode"). Stop clocks.
      begin
      end

   else if pos('go',fromWinBoard) > 0 then                          // Leave force mode and set the engine to play the color that is on move.
      begin
      end

   else if pos('easy',fromWinBoard) > 0 then                        // Turn off pondering
      begin
      end

   else if pos('hard',fromWinBoard) > 0 then                        // Turn on pondering (thinking on the opponent's time, also known as "permanent brain").
      begin
      end

   else if pos('time',fromWinBoard) > 0 then                        // Set the clock that belongs to the engine.
      begin
      end

   else if pos('otime',fromWinBoard) > 0 then                       // Set the clock that belongs to the opponent.
      begin
      end

   // has a 'move' been received from WinBoard?
   // WinBoard sends its moves in algebraic chess notation as 'frfr' where f=file or column and r=rank or row
   else if (fromWinBoard[1] in ['a'..'h']) and  // file or column of the piece that is moving
           (fromWinBoard[2] in ['1'..'8']) and  // rank or row of the piece that is moving
           (fromWinBoard[3] in ['a'..'h']) and  // file or column of the square that the piece is moving to
           (fromWinBoard[4] in ['1'..'8']) then // rank or row  of the square that the piece is moving to
           begin
             toCHEKMO := LeftStr(fromWinBoard,4);
             if (length(fromWinBoard)=5) then toCHEKMO := toCHEKMO+'='+fromWinBoard[5]; // pawn promotion!
             MainForm.ApdComPort1.PutString(UpperCase(toCHEKMO)+#13);  // pass the move over the serial link on to CHEKMO, end with <CR>
             CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+UpperCase(toCHEKMO));
           end;
end;

//-------------------------------------------------------------------------------//
// this procedure parses the line of text received from CHEKMO.                 //
//-------------------------------------------------------------------------------//
procedure TMainForm.ParseLine(LineToParse: string);
const ResetRejected: boolean = false;
      LastLine: string = '';
var i: integer;
    toSend:string;
begin
   CKMonitorForm.meCKMonitor.Lines.Add('from CKMO: '+LineToParse);

   // whose move is it currently according to CHEKMO?
   if pos('W.',LineToParse) = 1 then        // "W." at the beginning of the line from CHEKMO, it's white's turn
      WhoseTurn := WhitesTurn
   else if pos('B.',LineToParse) = 1 then   // "B." at the beginning of the line from CHEKMO, it's black's turn
      WhoseTurn := BlacksTurn;

   // this part of the code detects if CHEKMO has not yet been started on SIMH
   if (LineToParse = 'RE?') then ResetRejected := true              // SIMH does not understand the "REset" command
   else if (LineToParse = 'PB?') and ResetRejected then             // SIMH does not understand th "Play Black" command, ergo CHEKMO hasn't been started yet
      begin
         //MainForm.ApdComPort1.PutString('R CHESS'^M);               // send "Run CHESS" command
         //Delay(250);
         //MainForm.ApdComPort1.PutString('PB'^M);                    // send "Play Black" command
         //CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'R CHESS');
         //CKMonitorForm.meCKMonitor.Lines.Add('to   CKMO: '+'PB');
         ResetRejected := false;
      end

   else if pos('CHECKMATE',LineToParse) > 0 then
      begin
         case ord(WhoseTurn) of
            0: toSend := '1-0 {White mates}';
            1: toSend := '1-0 {White mates}';
         end;
         WBThread.SendCommand(toSend);
         WBMonitorForm.meWBMonitor.Lines.Add('to   WinB: '+toSend);
      end

   else if pos('STALEMATE',LineToParse) > 0 then
      begin
         toSend := '1/2-1/2 {Stalemate}';
         WBThread.SendCommand(toSend);
         WBMonitorForm.meWBMonitor.Lines.Add('to   WinB: '+toSend);
      end

   else if pos('O-O-O',LineToParse) > 0 then      // CHEKMO says to castle queen side?
      begin
         case ord(CHEKMOcolor) of
            0: toSend := 'e1c1';                  // castle queen side is E1-C1 when playing white
            1: toSend := 'e8c8';                  // castle queen side is E8-C8 when playng black
         end;
         WBThread.SendMove(toSend);
         WBMonitorForm.meWBMonitor.Lines.Add('to   WinB: '+toSend);
      end

   else
      if pos('O-O',LineToParse) > 0 then          // CHEKMO says to castle king side?
      begin
         case ord(CHEKMOcolor) of
            0: toSend := 'e1g1';                  // castle king side is E1-G1 when playing white
            1: toSend := 'e8g8';                  // castle king side is E8-G8 when playing black
         end;
         WBThread.SendMove(toSend);
         WBMonitorForm.meWBMonitor.Lines.Add('to   WinB: '+toSend);
      end

   else
      begin
         // CHEKMO sends its moves in algebraic chess notation as FR-FR or FR:FR  where F=file or column and R=rank or row
         i := pos('-',LineToParse);               // move coordinates are separated by '-', example: D7-D5
         if i=0 then i := pos(':',LineToParse);   // move coordinates are separated by ':' when capturing, example: D7:D5
         if i>2 then                              // '-' or ':' found as the third character in the data received from CHEKMO...
            begin
              // so, is it actually a 'move' from CHEKMO?
              if (LineToParse[i-2] in ['A'..'H']) and   // file or column of the piece that is moving
                 (LineToParse[i-1] in ['1'..'8']) and   // rank or row of the piece that is moving
                 (LineToParse[i+1] in ['A'..'H']) and   // file or column of the square that the piece is moving to
                 (LineToParse[i+2] in ['1'..'8']) then  // rank or row  of the square that the piece is moving to
                 begin
                    toSend := lowercase(LineToParse[i-2]+LineToParse[i-1]+LineToParse[i+1]+LineToParse[i+2]);
                    WbThread.SendMove(toSend);
                    WBMonitorForm.meWBMonitor.Lines.Add('to   WinB: '+toSend);

                    if (CHEKMOcolor = Undetermined) then
                       begin // we need to determine what color CHEKMO is playing for later castling moves
                          if (LineToParse[i-1] < LineToParse[i+2]) then CHEKMOcolor := White  // if the first move is from a lower to a higher rank (e.g. D2-D4), CHEKMO must be playing white
                                                                   else CHEKMOcolor := Black; // else the first move is from a higher to a lower rank (e.g. D7-D5), CHEKMO must be playing black
                       end;
                 end;
            end; // if i>2 then
      end;
      LastLine := LineToParse;  //save the line for use next time
end;


//-------------------------------------------------------------------------------//
// this procedure is triggered when characters are available from the comm port. //
// check to see if the data is coming from CHEKMO...                             //
//-------------------------------------------------------------------------------//
procedure TMainForm.ApdComPort1TriggerAvail(CP: TObject; Count: Word);
const fromCHEKMO: string = '';
var j: integer;
    c: char;
begin
   for j := 1 to Count do
      begin
         c := ApdComPort1.GetChar;
         case c of
            #10: begin end;     // ignore line feeds
            #13: begin          // carriage return means end of line
                    if length(fromCHEKMO) > 0 then ParseLine(fromCHEKMO);
                    fromCHEKMO := '';
                 end;
            else fromCHEKMO := fromCHEKMO+c;
         end;
      end;
end;

//------------------------------------------------------------------------------//
// MainForm OnCreate handler...                                                 //
//------------------------------------------------------------------------------//
procedure TMainForm.FormCreate(Sender: TObject);
var IniFile: TiniFile;
begin
   // start the thread for interfacing with WinBoard
   WbThread := TWbThread.Create(false,Handle);

   // set up the Help File
   Application.HelpFile := ChangeFileExt(Application.ExeName,'.CHM');

   // we don't yet know what color CHEKMO will be playing next game
   CHEKMOcolor := Undetermined;

   // white always moves first
   WhoseTurn := WhitesTurn;

   // use the application name for the ini file
   IniFileName := ChangeFileExt(Application.ExeName,'.ini');
   IniFile := TIniFile.Create(IniFileName);
   try
      // retrieve the Main Window Title bar caption
      MainForm.Caption := IniFile.ReadString('Options','Title','PDP-8 Terminal');

      // retrieve the comm port number and baud rate, default to COM3, 19200bps, 7 data bits, Mark parity and 1 stop bit
      ApdComPort1.ComNumber := StrToInt(IniFile.ReadString('Comm','ComNumber','3'));
      ApdComPort1.Baud      := StrToInt(IniFile.ReadString('Comm','BaudRate','19200'));
      ApdComPort1.Parity    := TParity(StrToInt(IniFile.ReadString('Comm','Parity','3')));
      ApdComPort1.StopBits  := StrToInt(IniFile.ReadString('Comm','StopBits','1'));
      ApdComPort1.DataBits  := StrToInt(IniFile.ReadString('Comm','DataBits','7'));

      // retrieve the font selection, default to Courier New
      AdTerminal1.Font.Name    := IniFile.ReadString('Terminal Font', 'Name', 'Courier New');
      AdTerminal1.Font.CharSet := TFontCharSet(IniFile.ReadInteger('Terminal Font', 'CharSet', 0));
      AdTerminal1.Font.Color   := TColor(IniFile.ReadInteger('Terminal Font', 'Color', 0));
      AdTerminal1.Font.Size    := IniFile.ReadInteger('Terminal Font', 'Size', 11);
      AdTerminal1.Font.Style   := TFontStyles(Byte(IniFile.ReadInteger('Terminal Font', 'Style', Byte(0))));

      // retrieve the Terminal color selection, default to Black
      AdTerminal1.Color        := TColor(IniFile.ReadInteger('Terminal Color', 'Color', 0));

      AdTerminal1.Rows         := IniFile.ReadInteger('Terminal Size', 'Rows', 32);
      AdTerminal1.Columns      := IniFile.ReadInteger('Terminal Size', 'Columns', 80);
      AdTerminal1.Width        := (AdTerminal1.CharWidth * AdTerminal1.Columns)+40;
      AdTerminal1.Height       := (AdTerminal1.CharHeight * AdTerminal1.Rows)+20;
      MainForm.Width           := IniFile.ReadInteger('Terminal Position', 'Width',AdTerminal1.Width+GetSystemMetrics(SM_CXVSCROLL));
      MainForm.Height          := IniFile.ReadInteger('Terminal Position', 'Height',AdTerminal1.Height+(2*GetSystemMetrics(SM_CYEDGE))+(2*GetSystemMetrics(SM_CYSIZEFRAME))+GetSystemMetrics(SM_CYCAPTION)+GetSystemMetrics(SM_CYMENU));
      MainForm.Left            := IniFile.ReadInteger('Terminal Position', 'Left', 450);
      MainForm.Top             := IniFile.ReadInteger('Terminal Position', 'Top', 150);

   finally
      IniFile.Free;
   end;

   // resize the main form to match the terminal window using the font from above

   //make the terminal active
   AdTerminal1.Active := true;
   simhStarted := false;

   if IsPortAvailable(ApdComPort1.ComNumber) then
      begin
        // open the comm port
        ApdComPort1.Open := true;
      end
   else
      begin
         MessageDlg('Sorry, comm port '+IntToStr(ApdComPort1.ComNumber)+' is not available.',mtError, [mbOK], 0);
      end;
end;

//------------------------------------------------------------------------------//
// MainForm OnShow handler...                                                   //
//------------------------------------------------------------------------------//
procedure TMainForm.FormShow(Sender: TObject);
begin
   if not ApdComPort1.Open then MainForm.mnuSetupSerialPort.Click;
   AdTerminal1.SetFocus;
end;

//------------------------------------------------------------------------------//
// MainForm OnClose handler...                                                  //
//------------------------------------------------------------------------------//
procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var IniFile: TiniFile;

begin
   IniFile := TIniFile.Create(IniFileName);
   try
      // save the comm port parameters for next time...
      IniFile.WriteString('Comm','ComNumber',IntToStr(ApdComPort1.ComNumber));
      IniFile.WriteString('Comm','BaudRate',IntToStr(ApdComPort1.Baud));
      IniFile.WriteString('Comm','Parity',IntToStr(Ord(ApdComPort1.Parity)));
      IniFile.WriteString('Comm','StopBits',IntToStr(Ord(ApdComPort1.StopBits)));
      IniFile.WriteString('Comm','DataBits',IntToStr(ApdComPort1.DataBits));

      // save the font selection for next time...
      IniFile.WriteString('Terminal Font', 'Name', AdTerminal1.Font.Name);
      IniFile.WriteInteger('Terminal Font', 'CharSet', AdTerminal1.Font.CharSet);
      IniFile.WriteInteger('Terminal Font', 'Color', AdTerminal1.Font.Color);
      IniFile.WriteInteger('Terminal Font', 'Size', AdTerminal1.Font.Size);
      IniFile.WriteInteger('Terminal Font', 'Style', Byte(AdTerminal1.Font.Style));

      IniFile.WriteInteger('Terminal Color', 'Color', AdTerminal1.Color);

      IniFile.WriteInteger('Terminal Position', 'Left', MainForm.Left);
      IniFile.WriteInteger('Terminal Position', 'Top', MainForm.Top);
      IniFile.WriteInteger('Terminal Position', 'Height', MainForm.Height);
      IniFile.WriteInteger('Terminal Position', 'Width', MainForm.Width);

   finally
      IniFile.Free;
   end;
end;

//------------------------------------------------------------------------------//
// Main menu "Setup", "Font" click handler...                                   //
//------------------------------------------------------------------------------//
procedure TMainForm.mnuSetUpFontClick(Sender: TObject);
begin
   FontDialog1.Font := AdTerminal1.Font;
   if FontDialog1.Execute then
      begin
         AdTerminal1.Font   := FontDialog1.Font;
         AdTerminal1.Width  := (AdTerminal1.CharWidth * AdTerminal1.Columns)+40;
         AdTerminal1.Height := (AdTerminal1.CharHeight * AdTerminal1.Rows)+20;
         MainForm.Width     := AdTerminal1.Width+GetSystemMetrics(SM_CXVSCROLL);
         MainForm.Height    := AdTerminal1.Height+(2*GetSystemMetrics(SM_CYEDGE))+(2*GetSystemMetrics(SM_CYSIZEFRAME))+GetSystemMetrics(SM_CYCAPTION)+GetSystemMetrics(SM_CYMENU);
         MainForm.Invalidate;
      end;
end;

//------------------------------------------------------------------------------//
// Main menu "Setup", "Color" click handler...                                  //
//------------------------------------------------------------------------------//
procedure TMainForm.mnuSetupColorClick(Sender: TObject);
begin
   if ColorDialog1.Execute then
      begin
         AdTerminal1.Color := ColorDialog1.Color;
      end;
end;

//------------------------------------------------------------------------------//
// Main menu "Setup", "Serial Port" click handler...                            //
//------------------------------------------------------------------------------//
procedure TMainForm.mnuSetupSerialPortClick(Sender: TObject);
begin
   if (ApdComPort1 <> nil) then
      begin
         ComPortOptions.ComPort := ApdComPort1;
         if ComPortOptions.Execute then
            begin
               if (ComPortOptions.ComPort <> nil) then
                  begin
                    // Close the open com ports
                    ApdComPort1.Open := false;
                    // reassign the new com port properties
                    ApdComPort1.Assign(ComPortOptions.ComPort);
                    // tell the terminal that we want to be active
                    AdTerminal1.Active := true;
                    // open the com port
                    ApdComPort1.Open := true;
                 end;
            end;
      end;
end;

//------------------------------------------------------------------------------//
// Main menu "File", "Exit" click handler...                                    //
//------------------------------------------------------------------------------//
procedure TMainForm.mnuFileExitClick(Sender: TObject);
begin
   Close;
end;


//------------------------------------------------------------------------------//
// Main menu "File", "Clear" click handler...                                   //
//------------------------------------------------------------------------------//
procedure TMainForm.mnuEditClearClick(Sender: TObject);
begin
   AdTerminal1.ClearAll;
end;

//------------------------------------------------------------------------------//
// Main menu "Help", "About" click handler...                                   //
//------------------------------------------------------------------------------//
procedure TMainForm.mnuHelpAboutClick(Sender: TObject);
begin
   CopyrightForm.ShowModal;
end;

//------------------------------------------------------------------------------//
// Main menu "Help", "Help" click handler...                                    //
//------------------------------------------------------------------------------//
procedure TMainForm.mnuHelpHelpClick(Sender: TObject);
begin
   HtmlHelp(GetDesktopWindow, PChar(Application.HelpFile), HH_DISPLAY_TOPIC, 0); // HTML Help
end;


end.
