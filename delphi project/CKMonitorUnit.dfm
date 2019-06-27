object CKMonitorForm: TCKMonitorForm
  Left = 71
  Top = 743
  BorderStyle = bsDialog
  Caption = 'CHEKMO Monitor'
  ClientHeight = 570
  ClientWidth = 570
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 168
  TextHeight = 24
  object meCKMonitor: TMemo
    Left = 24
    Top = 24
    Width = 525
    Height = 470
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Lucida Sans Typewriter'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btnClear: TButton
    Left = 227
    Top = 516
    Width = 113
    Height = 38
    Caption = 'Clear'
    TabOrder = 1
    OnClick = btnClearClick
  end
end
