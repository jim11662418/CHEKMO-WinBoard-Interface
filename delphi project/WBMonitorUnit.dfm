object WBMonitorForm: TWBMonitorForm
  Left = 66
  Top = 113
  BorderStyle = bsDialog
  Caption = 'WinBoard Monitor'
  ClientHeight = 570
  ClientWidth = 570
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -21
  Font.Name = 'Courier New'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 168
  TextHeight = 23
  object meWBMonitor: TMemo
    Left = 22
    Top = 24
    Width = 525
    Height = 470
    TabStop = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Lucida Sans Typewriter'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
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
