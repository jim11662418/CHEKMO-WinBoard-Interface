/////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                         //
// WinBoard interface to CHEKMO running on my Spare Time Gizmos SBC6120-RC  PDP-8 replica. //
//                                                                                         //
// Thanks to Dr. Maciej Szmit for his WBUnit that makes the interface to WinBoard trivial. //
// Thanks to the people at Async Pro for their Terminal demo which served as the basis for //
// this application.                                                                       //
//                                                                                         //
/////////////////////////////////////////////////////////////////////////////////////////////

program WB_CHEKMO;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  AdXPort {in '..\ADXPORT.PAS'},
  CopyrightUnit in 'CopyrightUnit.pas' {CopyrightForm},
  WBunit in 'WBunit.pas',
  WBMonitorUnit in 'WBMonitorUnit.pas' {WBMonitorForm},
  CKMonitorUnit in 'CKMonitorUnit.pas' {CKMonitorForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'WinBoard to CHEKMO Interface';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TComPortOptions, ComPortOptions);
  Application.CreateForm(TCopyrightForm, CopyrightForm);
  Application.CreateForm(TWBMonitorForm, WBMonitorForm);
  Application.CreateForm(TCKMonitorForm, CKMonitorForm);
  Application.Run;
end.
