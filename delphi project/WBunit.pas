//***************************************************************
//
// WBunit (C) dr Maciej Szmit 2005
// Inspirations:
//      Unit_Winboard (C) Norbert Dudek
//      MyChess       (C) Grzegorz Olczak
//      Geko          (C) Giuseppe Canella
//
//***************************************************************

unit WBunit;

interface
uses
	Classes, Windows, Messages, SysUtils;

type
	TWbThread	= class(TThread)
	private
		HFormHandle: THandle;
	protected
		procedure Execute; override;        //sends standard Winddos message to mainform window
	public
    WinboardCommand	: String;
		constructor Create(CreateSuspended: Boolean; Form: THandle);
    procedure Send(msg: string);
    procedure SendCommand(msg: string); //sends command to winboard
    procedure SendMove(mv : string);    //sends move (with 'move ') prefix to winboard
    procedure SendNewLine;
	end;

const
	CW_WBMSG=WM_USER+1000;

implementation

uses WBMonitorUnit;


{TWbThread}
constructor TWbThread.Create(CreateSuspended: Boolean; Form: THandle);
begin
  AllocConsole;
  SetConsoleTitle(PChar('WinBoard Thread'));
  ShowWindow(FindWindow(nil, PChar('WinBoard Thread')),SW_HIDE);

	inherited Create(CreateSuspended);
	HFormHandle := Form;
  WinboardCommand:='';
end;

procedure TWbThread.Execute;
var Command: string;
	  ch: char;
begin
	while (true) do
  	begin
	  	Command := '';
      ch := #0;
  		repeat
	  		try
		  		read(input,ch);
			  except
				  Suspend;
				  exit;
  			end;
	  		if ch <> #10 then
		  		Command := Command+ch;
  		until (ch = #10);
      WinboardCommand:= Command;
		  SendCommand(Command); //sends "acknowledgement" to Winboard
  		sendMessage(HFormHandle,CW_WBMSG,0,0);
      //SendMessage not PostMessage only synchronous execution allowed !!!
  	end;
end;

procedure TWbThread.SendNewLine;
begin
   write(#10);
   flush(output);
end;


procedure TWbThread.Send(msg:string);
begin
   write(msg+#10);
   flush(output);
end;

procedure TWbThread.SendCommand(msg:string);
begin
   if (length(msg)<>0)and(msg[1]<>'O') then
      begin
         write(lowercase(msg)+#10);
         flush(output);
      end;
end;

procedure TWbThread.SendMove(mv : string);
begin
 	SendCommand('move '+mv);
end;

end.
