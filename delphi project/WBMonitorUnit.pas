unit WBMonitorUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TWBMonitorForm = class(TForm)
    meWBMonitor: TMemo;
    btnClear: TButton;
    procedure btnClearClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WBMonitorForm: TWBMonitorForm;

implementation

{$R *.dfm}

procedure TWBMonitorForm.btnClearClick(Sender: TObject);
begin
   WBMonitorForm.meWBMonitor.Clear;
end;

end.
