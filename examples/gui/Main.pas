{ *********************************************************************** }
{                                                                         }
{ ZFM Manager Main Unit                                                   }
{                                                                         }
{ Copyright (c) 2011-2016 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit Main;

{$IFDEF FPC}{$mode delphi}{$ENDIF}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls,
{$IFNDEF FPC}
  System.UITypes, Vcl.Samples.Spin,
{$ELSE}
  LCLType, Spin,
{$ENDIF}
  PMCW.Serial, PMCW.Serial.ZFM;

type
  /// <summary>
  ///   ZFM log event.
  /// </summary>
  /// <param name="Sender">
  ///   The sender.
  /// </param>
  /// <param name="AMessage">
  ///   The message.
  /// </param>
  /// <param name="AMessageType">
  ///   The message type.
  /// </param>
  TZfmLogEvent = procedure(Sender: TThread; const AMessage: string; AMessageType: TMsgDlgType) of object;

  /// <summary>
  ///   ZFM sensor method signature to be used by <see cref="TZfmSensorThread"/>.
  /// </summary>
  /// <param name="AZfmSensor">
  ///   The ZFM sensor.
  /// </param>
  TZfmSensorMethod = procedure(ACaller: TThread; const AZfmSensor: TZfmSensor) of object;

  /// <summary>
  ///   Thread which calls ZFM methods async.
  /// </summary>
  TZfmSensorThread = class(TThread)
  private
    FOnProgress: TZfmProgressEvent;
    FSensor: TZfmSensor;
    FOnStart: TNotifyEvent;
    FMethod: TZfmSensorMethod;
    FOnLog: TZfmLogEvent;
    FMessage: string;
    FMessageType: TMsgDlgType;
    FProgress,
    FProgressMax: Cardinal;
    procedure DoNotifyOnLog();
    procedure DoNotifyOnStart();
    procedure DoNotifyOnProgress();
    procedure OnZfmProgress(Sender: TObject; const AProgress, ATotal: Cardinal;
      var ACancel: Boolean);
  protected
    procedure Execute(); override; final;
  public
    /// <summary>
    ///   Contructor for creating a <c>TZfmSensorThread</c> instance.
    /// </summary>
    /// <param name="ASensor">
    ///   The ZFM sensor.
    /// </param>
    constructor Create(ASensor: TZfmSensor); reintroduce;

    /// <summary>
    ///   Logs a message with specified message type.
    /// </summary>
    /// <param name="AMessage">
    ///   The message to log.
    /// </param>
    /// <param name="AMessageType">
    ///   The message type.
    /// </param>
    procedure Log(const AMessage: string; AMessageType: TMsgDlgType = mtInformation);

    /// <summary>
    ///   A ZFM method.
    /// </summary>
    property Method: TZfmSensorMethod write FMethod;

    /// <summary>
    ///   Occurs when a message has to be logged.
    /// </summary>
    property OnLog: TZfmLogEvent read FOnLog write FOnLog;

    /// <summary>
    ///   Occurs when the method has started.
    /// </summary>
    property OnStart: TNotifyEvent read FOnStart write FOnStart;

    /// <summary>
    ///   Occurs during a long serial operation.
    /// </summary>
    property OnProgress: TZfmProgressEvent read FOnProgress write FOnProgress;
  end;

  { TMain }

  TMain = class(TForm)
    bSearch: TButton;
    bImage: TButton;
    cbxPacketLength: TComboBox;
    gbConnection: TGroupBox;
    cbxBaudrate: TComboBox;
    lBaudrate: TLabel;
    lPacketLength: TLabel;
    ProgressBar: TProgressBar;
    seComPort: TSpinEdit;
    lComPort: TLabel;
    eSensorAddress: TLabeledEdit;
    eSensorPassword: TLabeledEdit;
    gbTemplates: TGroupBox;
    bAdd: TButton;
    lbTemplates: TListBox;
    bRemove: TButton;
    bApply: TButton;
    bClose: TButton;
    lbLog: TListBox;
    bRefresh: TButton;
    bClear: TButton;
    procedure bCloseClick(Sender: TObject);
    procedure bAddClick(Sender: TObject);
    procedure bImageClick(Sender: TObject);
    procedure bRemoveClick(Sender: TObject);
    procedure bApplyClick(Sender: TObject);
    procedure bSearchClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure bClearClick(Sender: TObject);
    procedure bRefreshClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FSensor: TZfmSensor;
    FZfmSensorThread: TZfmSensorThread;
    procedure AddTemplate(ACaller: TThread; const AZfmSensor: TZfmSensor);
    procedure Clear(ACaller: TThread; const AZfmSensor: TZfmSensor);
    procedure Log(Sender: TThread; const AMessage: string;
      AMessageType: TMsgDlgType = mtInformation);
    procedure OnZfmSensorThreadFinish(Sender: TObject);
    function ValidSensorAddress(out ASensorAddress: Int64): Boolean;
    function ValidSensorPassword(out ASensorPassword: Int64): Boolean;
    procedure Refresh(ACaller: TThread; const AZfmSensor: TZfmSensor);
    procedure ReadImage(ACaller: TThread; const AZfmSensor: TZfmSensor);
    procedure RemoveTemplate(ACaller: TThread; const AZfmSensor: TZfmSensor);
    procedure StartThread(AMethod: TZfmSensorMethod);
    procedure Apply(ACaller: TThread; const AZfmSensor: TZfmSensor);
    procedure DownloadImage(ACaller: TThread; const AZfmSensor: TZfmSensor);
    procedure OnZfmSensorProgress(Sender: TObject; const AProgress, ATotal: Cardinal;
      var ACancel: Boolean);
    procedure Search(ACaller: TThread; const AZfmSensor: TZfmSensor);
  end;

var
  MainForm: TMain;

implementation

{$R *.lfm}

{ TZfmSensorThread }

constructor TZfmSensorThread.Create(ASensor: TZfmSensor);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FSensor := ASensor;
end;

procedure TZfmSensorThread.Log(const AMessage: string; AMessageType: TMsgDlgType);
begin
  FMessage := AMessage;
  FMessageType := AMessageType;
  Synchronize(DoNotifyOnLog);
end;

procedure TZfmSensorThread.DoNotifyOnLog();
begin
  if Assigned(FOnLog) then
    FOnLog(Self, FMessage, FMessageType);
end;

procedure TZfmSensorThread.DoNotifyOnStart();
begin
  if Assigned(FOnStart) then
    FOnStart(Self);
end;

procedure TZfmSensorThread.DoNotifyOnProgress();
var
  Cancel: Boolean;

begin
  if Assigned(FOnProgress) then
  begin
    Cancel := False;
    FOnProgress(Self, FProgress, FProgressMax, Cancel);

    if Cancel then
      Terminate();
  end;  //of begin
end;

procedure TZfmSensorThread.OnZfmProgress(Sender: TObject; const AProgress,
  ATotal: Cardinal; var ACancel: Boolean);
begin
  FProgress := AProgress;
  FProgressMax := ATotal;
  ACancel := Terminated;
  Synchronize(DoNotifyOnProgress);
end;

procedure TZfmSensorThread.Execute();
begin
  Synchronize(DoNotifyOnStart);

  try
    Assert(Assigned(FMethod), 'Property "Method" not assigned!');
    FSensor.OnProgress := OnZfmProgress;
    FMethod(Self, FSensor);

  except
    on E: Exception do
    begin
      FMessage := E.Message;
      FMessageType := mtError;
      Synchronize(DoNotifyOnLog);
    end;
  end;  //of try
end;


{ TMain }

procedure TMain.FormCreate(Sender: TObject);
begin
  seComPort.MaxValue := 255;
{$IFDEF MSWINDOWS}
  seComPort.MinValue := 3;
{$ELSE}
  seComPort.MinValue := 0;
{$ENDIF}
  bRefresh.Click;
end;

procedure TMain.Log(Sender: TThread; const AMessage: string; AMessageType: TMsgDlgType);
begin
  if (AMessageType = mtError) then
    MessageDlg(AMessage, AMessageType, [mbOk], 0);

  lbLog.TopIndex := lbLog.Items.Add(AMessage);;
end;

procedure TMain.OnZfmSensorThreadFinish(Sender: TObject);
begin
  // Clear the lock
  // NOTE: Thread is ref-counted!
  FZfmSensorThread := nil;
end;

function TMain.ValidSensorAddress(out ASensorAddress: Int64): Boolean;
var
  SensorAddress: Int64;

begin
  Result := TryStrToInt64('$'+ eSensorAddress.Text, SensorAddress);

  if not Result then
  begin
    MessageDlg('Invalid address!', mtError, [mbOk], 0);
    ASensorAddress := $FFFFFFFF;
  end  //of begin
  else
    ASensorAddress := SensorAddress;
end;

function TMain.ValidSensorPassword(out ASensorPassword: Int64): Boolean;
var
  SensorPassword: Int64;

begin
  Result := TryStrToInt64('$'+ eSensorPassword.Text, SensorPassword);

  if not Result then
  begin
    MessageDlg('Invalid password!', mtError, [mbOk], 0);
    ASensorPassword := 0;
  end  //of begin
  else
    ASensorPassword := SensorPassword;
end;

procedure TMain.Apply(ACaller: TThread; const AZfmSensor: TZfmSensor);
var
  SensorPassword, SensorAddress: Int64;

begin
  // Change sensor baudrate
  AZfmSensor.BaudRate := AZfmSensor.BaudRate.FromBaudRate(StrToInt(cbxBaudRate.Text));

  // Change sensor password
  ValidSensorPassword(SensorPassword);
  AZfmSensor.Password := SensorPassword;

  // Change sensor address
  ValidSensorAddress(SensorAddress);
  AZfmSensor.Address := SensorAddress;

  // Change packet length
  AZfmSensor.PacketLength := TZfmPacketLength(cbxPacketLength.ItemIndex);

  Log(nil, 'Successful!', mtInformation);
end;

procedure TMain.DownloadImage(ACaller: TThread; const AZfmSensor: TZfmSensor);
begin
  ReadImage(ACaller, AZfmSensor);
  AZfmSensor.DownloadImage('fingerprint.bmp');
end;

procedure TMain.OnZfmSensorProgress(Sender: TObject; const AProgress,
  ATotal: Cardinal; var ACancel: Boolean);
begin
  ProgressBar.Max := ATotal;
  ProgressBar.Position := AProgress;
end;

procedure TMain.Search(ACaller: TThread; const AZfmSensor: TZfmSensor);
var
  SearchResult: TZfmTemplateSearchResult;

begin
  (ACaller as TZfmSensorThread).Log('Waiting for finger ...');
  ReadImage(ACaller, AZfmSensor);
  AZfmSensor.ConvertImage(cbOne);
  SearchResult := AZfmSensor.SearchTemplate(cbOne);

  if (SearchResult.TemplateIndex = -1) then
    (ACaller as TZfmSensorThread).Log('Template not found!')
  else
    (ACaller as TZfmSensorThread).Log(Format('Template found at %d with accuracy %d!',
      [SearchResult.TemplateIndex, SearchResult.Accuracy]));
end;

procedure TMain.Refresh(ACaller: TThread; const AZfmSensor: TZfmSensor);
var
  Indices: TZfmTemplateIndex;
  i, Index: Integer;
  Page: TZfmTemplatePage;

begin
  TThread.Synchronize(nil, lbTemplates.Items.Clear);
  (ACaller as TZfmSensorThread).Log(Format('%d/%d templates used', [AZfmSensor.GetTemplateCount(), AZfmSensor.StorageCapacity]));
  Index := 0;

  for Page := Low(TZfmTemplatePage) to High(TZfmTemplatePage) do
  begin
    Indices := AZfmSensor.GetTemplateIndex(Page);

    for i := Low(Indices) to High(Indices) do
    begin
      if Indices[i] then
        lbTemplates.Items.Append(IntToStr(Index));

      Inc(Index);
    end;  //of for
  end;  //of for

  cbxPacketLength.ItemIndex := Ord(AZfmSensor.PacketLength);
end;

procedure TMain.ReadImage(ACaller: TThread; const AZfmSensor: TZfmSensor);
var
  Timeout: Byte;

begin
  Timeout := 15;

  while not AZfmSensor.ReadImage() and (Timeout > 0) do
    Dec(Timeout);

  if (Timeout = 0) then
    raise EAbort.Create('Timeout limit exceeded!');
end;

procedure TMain.RemoveTemplate(ACaller: TThread; const AZfmSensor: TZfmSensor);
var
  TemplatePosition: string;

begin
  // Already validated
  TemplatePosition := lbTemplates.Items[lbTemplates.ItemIndex];

  // Remove template from sensor
  AZfmSensor.DeleteTemplate(StrToInt(TemplatePosition));

  lbTemplates.Items.Delete(lbTemplates.ItemIndex);
  (ACaller as TZfmSensorThread).Log(Format('Template at %s removed', [TemplatePosition]));
end;

procedure TMain.StartThread(AMethod: TZfmSensorMethod);
var
  SensorAddress, SensorPassword: Int64;

begin
  // Mutex: Only one thread permitted to communicate with ZFM!
  if Assigned(FZfmSensorThread) then
  begin
    ShowMessage('Another operation is pending! Please wait ...');
    Exit;
  end;  //of begin

  if not ValidSensorAddress(SensorAddress) then
    Exit;

  if not ValidSensorPassword(SensorPassword) then
    Exit;

  if not Assigned(FSensor) then
    FSensor := TZfmSensor.Create(SensorAddress, SensorPassword);

  try
    FSensor.Connect({$IFDEF MSWINDOWS}'COM'{$ELSE}'/dev/ttyUSB'{$ENDIF}+ IntToStr(seComPort.Value), StrToInt(cbxBaudRate.Text));

  except
    on E: Exception do
    begin
      FreeAndNil(FSensor);
      Log(nil, E.Message, mtError);
      Exit;
    end;
  end;  //of try

  FZfmSensorThread := TZfmSensorThread.Create(FSensor);

  with FZfmSensorThread do
  begin
    OnLog := Self.Log;
    OnTerminate := OnZfmSensorThreadFinish;
    OnProgress := OnZfmSensorProgress;
    Method := AMethod;
    Start();
  end;  //of with
end;

procedure TMain.AddTemplate(ACaller: TThread; const AZfmSensor: TZfmSensor);
var
  SearchResult: TZfmTemplateSearchResult;
  TemplatePosition: SmallInt;

begin
  try
    (ACaller as TZfmSensorThread).Log('Waiting for finger ...');
    ReadImage(ACaller, AZfmSensor);
    AZfmSensor.ConvertImage(cbOne);
    SearchResult := AZfmSensor.SearchTemplate(cbOne);

    if (SearchResult.TemplateIndex = -1) then
    begin
      (ACaller as TZfmSensorThread).Log('Waiting for same finger again ...');
      Sleep(500);
      ReadImage(ACaller, AZfmSensor);
      AZfmSensor.ConvertImage(cbTwo);

      // Finger does not match?
      if (AZfmSensor.CompareCharacteristics() = 0) then
        AZfmSensor.RaiseError();

      AZfmSensor.CreateTemplate();
      TemplatePosition := AZfmSensor.StoreTemplate(cbOne);
      (ACaller as TZfmSensorThread).Log(Format('Stored template at %d', [TemplatePosition]));
      Refresh(ACaller, AZfmSensor);
    end  //of begin
    else
      (ACaller as TZfmSensorThread).Log(Format('Template already exists at %d with accuracy %d',
        [SearchResult.TemplateIndex, SearchResult.Accuracy]));

  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOk], 0);
  end;
end;

procedure TMain.bAddClick(Sender: TObject);
begin
  StartThread(AddTemplate);
end;

procedure TMain.bImageClick(Sender: TObject);
begin
  StartThread(DownloadImage);
end;

procedure TMain.bRefreshClick(Sender: TObject);
begin
  StartThread(Refresh);
end;

procedure TMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSensor);
end;

procedure TMain.bRemoveClick(Sender: TObject);
var
  TemplatePosition: string;

begin
  if (lbTemplates.ItemIndex = -1) then
  begin
    MessageDlg('No template selected!', mtWarning, [mbOk], 0);
    Exit;
  end;  //of begin

  TemplatePosition := lbTemplates.Items[lbTemplates.ItemIndex];

  if (MessageDlg(Format('Do really want to remove template at index %s?',
    [TemplatePosition]), mtWarning, mbYesNo, 0) = IDNO) then
    Exit;

  StartThread(RemoveTemplate);
end;

procedure TMain.Clear(ACaller: TThread; const AZfmSensor: TZfmSensor);
begin
  // Remove templates from sensor
  AZfmSensor.ClearDatabase();
  Refresh(ACaller, AZfmSensor);
end;

procedure TMain.bApplyClick(Sender: TObject);
var
  SensorPassword: Int64;

begin
  if (MessageDlg('Store settings on ZFM?', mtConfirmation, mbYesNo, 0) = IDNO) then
    Exit;

  // Sensor password is highly recommended
  if TryStrToInt64('$'+ eSensorPassword.Text, SensorPassword) and (SensorPassword = 0) then
    MessageDlg('A password is highly recommeded!', mtWarning, [mbOk], 0);

  StartThread(Apply);
end;

procedure TMain.bSearchClick(Sender: TObject);
begin
  StartThread(Search);
end;

procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if Assigned(FZfmSensorThread) then
  begin
    FZfmSensorThread.Terminate();
    FZfmSensorThread.WaitFor();
  end;  //of begin
end;

procedure TMain.bClearClick(Sender: TObject);
begin
  if (MessageDlg('Are you sure to delete all templates?', mtWarning, mbYesNo, 0) = IDYES) then
    StartThread(Clear);
end;

procedure TMain.bCloseClick(Sender: TObject);
begin
  Close;
end;

end.
