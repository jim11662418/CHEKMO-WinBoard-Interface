unit CKMonitorUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TCKMonitorForm = class(TForm)
    meCKMonitor: TMemo;
    btnClear: TButton;
    procedure btnClearClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CKMonitorForm: TCKMonitorForm;

implementation

{$R *.dfm}

procedure TCKMonitorForm.btnClearClick(Sender: TObject);
begin
   CKMonitorForm.meCKMonitor.Clear;
end;

end.
