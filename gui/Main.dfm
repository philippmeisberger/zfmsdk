object Main: TMain
  Left = 345
  Height = 354
  Top = 136
  Width = 379
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'ZFM Manager'
  ClientHeight = 354
  ClientWidth = 379
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  Position = poScreenCenter
  LCLVersion = '1.6.0.4'
  object gbConnection: TGroupBox
    Left = 8
    Height = 216
    Top = 8
    Width = 161
    Anchors = [akTop, akLeft, akRight]
    Caption = 'Connection'
    ClientHeight = 201
    ClientWidth = 157
    TabOrder = 2
    object lBaudrate: TLabel
      Left = 81
      Height = 13
      Top = 16
      Width = 52
      Caption = 'Baudrate'
      ParentColor = False
    end
    object lComPort: TLabel
      Left = 16
      Height = 13
      Top = 16
      Width = 23
      Caption = 'Port'
      ParentColor = False
    end
    object cbxBaudrate: TComboBox
      Left = 81
      Height = 23
      Top = 35
      Width = 65
      ItemHeight = 0
      ItemIndex = 3
      Items.Strings = (
        '9600'
        '19200'
        '38400'
        '57600'
        '115200'
      )
      Style = csDropDownList
      TabOrder = 1
      Text = '57600'
    end
    object seComPort: TSpinEdit
      Left = 16
      Height = 22
      Top = 35
      Width = 59
      AutoSelect = False
      AutoSize = False
      MaxValue = 256
      TabOrder = 0
    end
    object eSensorAddress: TLabeledEdit
      Left = 16
      Height = 23
      Top = 79
      Width = 130
      EditLabel.AnchorSideLeft.Control = eSensorAddress
      EditLabel.AnchorSideRight.Control = eSensorAddress
      EditLabel.AnchorSideRight.Side = asrBottom
      EditLabel.AnchorSideBottom.Control = eSensorAddress
      EditLabel.Left = 16
      EditLabel.Height = 13
      EditLabel.Top = 63
      EditLabel.Width = 130
      EditLabel.Caption = 'Address'
      EditLabel.ParentColor = False
      MaxLength = 8
      TabOrder = 2
      Text = 'FFFFFFFF'
    end
    object eSensorPassword: TLabeledEdit
      Left = 16
      Height = 23
      Top = 123
      Width = 130
      EditLabel.AnchorSideLeft.Control = eSensorPassword
      EditLabel.AnchorSideRight.Control = eSensorPassword
      EditLabel.AnchorSideRight.Side = asrBottom
      EditLabel.AnchorSideBottom.Control = eSensorPassword
      EditLabel.Left = 16
      EditLabel.Height = 13
      EditLabel.Top = 107
      EditLabel.Width = 130
      EditLabel.Caption = 'Password'
      EditLabel.ParentColor = False
      MaxLength = 8
      TabOrder = 3
      Text = '00000000'
    end
    object cbxPacketLength: TComboBox
      Left = 16
      Height = 23
      Top = 168
      Width = 128
      DropDownCount = 4
      ItemHeight = 0
      ItemIndex = 2
      Items.Strings = (
        '32'
        '64'
        '128'
        '256'
      )
      Style = csDropDownList
      TabOrder = 4
      Text = '128'
    end
    object lPacketLength: TLabel
      Left = 16
      Height = 13
      Top = 152
      Width = 76
      Caption = 'Packet length'
      ParentColor = False
    end
  end
  object gbTemplates: TGroupBox
    Left = 175
    Height = 217
    Top = 7
    Width = 196
    Caption = 'Database'
    ClientHeight = 202
    ClientWidth = 192
    TabOrder = 3
    object bAdd: TButton
      Left = 104
      Height = 28
      Top = 9
      Width = 81
      Caption = 'Add'
      OnClick = bAddClick
      TabOrder = 1
    end
    object lbTemplates: TListBox
      Left = 16
      Height = 183
      Top = 9
      Width = 75
      ItemHeight = 0
      ScrollWidth = 73
      TabOrder = 0
      TopIndex = -1
    end
    object bRemove: TButton
      Left = 104
      Height = 28
      Top = 40
      Width = 81
      Caption = 'Remove'
      OnClick = bRemoveClick
      TabOrder = 2
    end
    object bRefresh: TButton
      Left = 104
      Height = 28
      Top = 104
      Width = 81
      Caption = 'Refresh'
      OnClick = bRefreshClick
      TabOrder = 4
    end
    object bClear: TButton
      Left = 104
      Height = 28
      Top = 72
      Width = 81
      Caption = 'Clear'
      OnClick = bClearClick
      TabOrder = 3
    end
    object bSearch: TButton
      Left = 104
      Height = 26
      Top = 136
      Width = 81
      Caption = 'Search'
      OnClick = bSearchClick
      TabOrder = 5
    end
    object bImage: TButton
      Left = 104
      Height = 26
      Top = 166
      Width = 81
      Caption = 'Image'
      OnClick = bImageClick
      TabOrder = 6
    end
  end
  object bApply: TButton
    Left = 8
    Height = 37
    Top = 309
    Width = 175
    Caption = 'Apply'
    Default = True
    OnClick = bApplyClick
    TabOrder = 0
  end
  object bClose: TButton
    Left = 196
    Height = 37
    Top = 309
    Width = 175
    Cancel = True
    Caption = 'Quit'
    OnClick = bCloseClick
    TabOrder = 1
  end
  object lbLog: TListBox
    Left = 8
    Height = 58
    Top = 245
    Width = 363
    ItemHeight = 0
    ScrollWidth = 361
    TabOrder = 4
    TopIndex = -1
  end
  object ProgressBar: TProgressBar
    Left = 8
    Height = 11
    Top = 232
    Width = 363
    Smooth = True
    TabOrder = 5
  end
end
