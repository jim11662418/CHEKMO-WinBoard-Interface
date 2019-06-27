object MainForm: TMainForm
  Left = 448
  Top = 148
  Width = 952
  Height = 934
  HorzScrollBar.Position = 2
  Caption = 'PDP-8 Terminal'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 168
  TextHeight = 24
  object AdTerminal1: TAdTerminal
    Left = -2
    Top = 0
    Width = 1370
    Height = 806
    CaptureFile = 'APROTERM.CAP'
    Columns = 40
    ComPort = ApdComPort1
    CursorType = ctUnderline
    MouseSelect = False
    Rows = 40
    Scrollback = True
    UseLazyDisplay = False
    WantAllKeys = False
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clSilver
    Font.Height = -28
    Font.Name = 'Lucida Sans Typewriter'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 0
    OnKeyPress = AdTerminal1KeyPress
  end
  object MainMenu1: TMainMenu
    Left = 8
    Top = 8
    object mnuFile: TMenuItem
      Caption = '&File'
      object mnuFileExit: TMenuItem
        Caption = '&Exit'
        OnClick = mnuFileExitClick
      end
    end
    object nmuEdit: TMenuItem
      Caption = '&Edit'
      object mnuEditClear: TMenuItem
        Caption = '&Clear Screen'
        OnClick = mnuEditClearClick
      end
    end
    object nmuSetup: TMenuItem
      Caption = '&Setup...'
      object mnuSetUpFont: TMenuItem
        Caption = '&Font...'
        OnClick = mnuSetUpFontClick
      end
      object mnuSetupColor: TMenuItem
        Caption = '&Color'
        OnClick = mnuSetupColorClick
      end
      object mnuSetupSerialPort: TMenuItem
        Caption = '&Serial Port'
        OnClick = mnuSetupSerialPortClick
      end
    end
    object mnuHelp: TMenuItem
      Caption = '&Help'
      object mnuHelpHelp: TMenuItem
        Caption = '&Help'
        OnClick = mnuHelpHelpClick
      end
      object mnuHelpAbout: TMenuItem
        Caption = '&About'
        OnClick = mnuHelpAboutClick
      end
    end
  end
  object ApdComPort1: TApdComPort
    ComNumber = 3
    Parity = pMark
    DataBits = 7
    AutoOpen = False
    BufferFull = 3686
    BufferResume = 409
    TraceName = 'APRO.TRC'
    TraceHex = False
    LogName = 'APRO.LOG'
    LogHex = False
    UseEventWord = False
    TapiMode = tmOff
    OnTriggerAvail = ApdComPort1TriggerAvail
    Left = 48
    Top = 8
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 88
    Top = 8
  end
  object ColorDialog1: TColorDialog
    Left = 128
    Top = 8
  end
end
