{ *********************************************************************** }
{                                                                         }
{ Serial connection unit v1.0                                             }
{                                                                         }
{ Copyright (c) 2011-2016 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit PMCW.Serial;

{$IFDEF FPC}{$mode delphiunicode}{$ENDIF}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
{$IFDEF FPC}
  {$IFDEF UNIX}termio, BaseUnix, Unix,{$ENDIF}
{$ENDIF}
  Classes, SysUtils;

const
  /// <summary>
  ///   The default serial sleep time in milliseconds.
  /// </summary>
  SERIAL_SLEEP = 25;

{$IFDEF MSWINDOWS}
  { Missing DCB constants }
  DCB_BINARY            = $00000001;
  DCB_PARITY            = $00000002;
  DCB_TXCONTINUEXONXOFF = $00000080;
  DCB_OUTX              = $00000100;
  DCB_INX               = $00000200;
  DCB_ERRORCHAR         = $00000400;
  DCB_NULL              = $00000800;
{$ELSE}
  INVALID_HANDLE_VALUE  = THandle(-1);
{$ENDIF}

type
  /// <summary>
  ///   Possible stop bits.
  /// </summary>
  TStopBits = (sbOne, {$IFDEF MSWINDOWS}sbOnePtFive, {$ENDIF}sbTwo);

  /// <summary>
  ///   Possible data bits.
  /// </summary>
  TDataBits = (dbFive, dbSix, dbSeven, dbEight);

  /// <summary>
  ///   Possible parity bits.
  /// </summary>
  TParityBits = (pbNone, pbOdd, pbEven{$IFDEF MSWINDOWS}, pbMark, pbSpace{$ENDIF});

  /// <summary>
  ///   Supported baudrates.
  /// </summary>
  TBaudRate = (br110, br300, br600, br1200, br2400, br4800, br9600,
    {$IFDEF MSWINDOWS}br14400,{$ENDIF} br19200, br38400, br57600, br115200,
    {$IFDEF MSWINDOWS}br128000, br256000{$ELSE}br230400{$ENDIF});

  TBaudRateHelper = record helper for TBaudRate

    /// <summary>
    ///   Converts a <see cref="TBaudRate"/> value to decimal representation.
    /// </summary>
    /// <returns>
    ///   The baudrate.
    /// </returns>
    function ToBaudRate(): Integer;

    /// <summary>
    ///   Converts a baudrate to a <see cref="TBaudRate"/> value.
    /// </summary>
    /// <returns>
    ///   The baudrate.
    /// </returns>
    function FromBaudRate(ABaudRate: Integer): TBaudRate;
  end;

  /// <summary>
  ///   Serial connection exception class.
  /// </summary>
  ESerialException = class(Exception);

  /// <summary>
  ///   The <c>TSerialConnection</c> class provides methods to establish a
  ///   serial connection and read or write binary data.
  /// </summary>
  TSerialConnection = class(TObject)
  private
    FSerial: THandle;
    FSerialPort: string;
    FBaudRate: TBaudRate;
    FStopBits: TStopBits;
    FDataBits: TDataBits;
    FParityBits: TParityBits;
  {$IFDEF MSWINDOWS}
    FXOnChar,
    FXOffChar,
    FErrorChar: AnsiChar;
    FXOnLim,
    FXOffLim: Word;
    FStripNull,
  {$ENDIF}
    FFlowControl: Boolean;
    FTimeout: Word;
    FOnOpen,
    FOnClose: TNotifyEvent;
    procedure CheckSerial(AStatus: {$IFDEF MSWINDOWS}BOOL{$ELSE}Integer{$ENDIF});
    procedure Setup();
    procedure SetBaudRate(const ABaudRate: TBaudRate);
    procedure SetDataBits(const ADataBits: TDataBits);
    procedure SetFlowControl(const AFlowControl: Boolean);
    procedure SetParityBits(const AParityBits: TParityBits);
    procedure SetStopBits(const AStopBits: TStopBits);
{$IFDEF MSWINDOWS}
    procedure SetErrorChar(const AErrorChar: AnsiChar);
    procedure SetXOffChar(const AXOffChar: AnsiChar);
    procedure SetXOnChar(const AXOnChar: AnsiChar);
    procedure SetXOffLim(const AXOffLim: Word);
    procedure SetXOnLim(const AXOnLim: Word);
    procedure SetStripNull(const AStripNull: Boolean);
  protected
    function CanEvent(AEvent: DWORD; ATimeout: Integer): Boolean;
{$ENDIF}
  public
    /// <summary>
    ///   Constructor for creating a <c>TSerialConnection</c> instance.
    /// </summary>
    constructor Create;

    /// <summary>
    ///   Destructor for destroying a <c>TSerialConnection</c> instance.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    ///   Gets the number of bytes in the read buffer.
    /// </summary>
    /// <returns>
    ///   The number of bytes that can be read.
    /// </returns>
    function BytesToRead(): Cardinal;

    /// <summary>
    ///   Gets the number of bytes in the write buffer.
    /// </summary>
    /// <returns>
    ///   The number of bytes that can be written.
    /// </returns>
    function BytesToWrite(): Cardinal;

    /// <summary>
    ///   Checks if data can be read on the serial connection.
    /// </summary>
    /// <param name="ATimeout">
    ///   The period of time to check the serial connection in milliseconds.
    ///   If set to <c>0</c> the function returns immediately. If set to <c>-1</c>
    ///   the function blocks and waits until data can be read.
    /// </param>
    /// <param name="AMinBytesAvailable">
    ///   Optional: The minimum bytes that should be available.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the specified number of bytes can be read or <c>False</c>
    ///   otherwise.
    /// </returns>
    function CanRead(ATimeout: Integer; AMinBytesAvailable: Cardinal = 1): Boolean;

    /// <summary>
    ///   Checks if data can be written on the serial connection.
    /// </summary>
    /// <param name="ATimeout">
    ///   The period of time to check the serial connection in milliseconds.
    ///   If set to <c>0</c> the function returns immediately. If set to <c>-1</c>
    ///   the function blocks and waits until data can be written.
    /// </param>
    /// <param name="AMinBytesAvailable">
    ///   Optional: The minimum bytes that should be available.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the specified number of bytes can be written or
    ///   <c>False</c> otherwise.
    /// </returns>
    function CanWrite(ATimeout: Integer; AMinBytesAvailable: Cardinal = 1): Boolean;

    /// <summary>
    ///   Purges remaining packets and terminates the serial connection.
    /// </summary>
    procedure ClosePort();

    /// <summary>
    ///   Flushes the buffers of the serial connection and causes all buffered
    ///   data to be written.
    /// </summary>
    procedure Flush();

    /// <summary>
    ///   Checks if the serial connection is opened.
    /// </summary>
    /// <returns>
    ///   <c>True</c> if the connection is opened or <c>False</c> otherwise.
    /// </returns>
    function IsOpened(): Boolean;

    /// <summary>
    ///   Opens a serial connection on the specified COMM port.
    /// </summary>
    /// <param name="APort">
    ///   The serial port. Under Windows this is e.g. <c>COM3</c>. Under Linux
    ///   it is e.g. <c>/dev/ttyUSB0</c>.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the connection was opened or <c>False</c> otherwise.
    /// </returns>
    function OpenPort(const APort: string): Boolean;

    /// <summary>
    ///   Purges remaining packets.
    /// </summary>
    procedure Purge();

    /// <summary>
    ///   Reads a single byte from the serial connection.
    /// </summary>
    /// <returns>
    ///   The read byte.
    /// </returns>
    function Read(): Byte; overload;

    /// <summary>
    ///   Reads data from the serial connection.
    /// </summary>
    /// <param name="ABytesToRead">
    ///   The number of bytes to read.
    /// </param>
    /// <returns>
    ///   A buffer containing the read data.
    /// </returns>
    function Read(ABytesToRead: Cardinal): TBytes; overload;

    /// <summary>
    ///   Reads data from the serial connection.
    /// </summary>
    /// <param name="AData">
    ///   A buffer receiving the data.
    /// </param>
    /// <param name="ABytesToRead">
    ///   The number of bytes to read.
    /// </param>
    /// <returns>
    ///   The number of bytes read.
    /// </returns>
    function Read(var AData; ABytesToRead: Cardinal): Cardinal; overload;

    /// <summary>
    ///   Reads a stream of data from the serial connection.
    /// </summary>
    /// <param name="AData">
    ///   The stream to store the received data.
    /// </param>
    /// <returns>
    ///   The number of bytes read.
    /// </returns>
    function Read(var AData: TMemoryStream): Cardinal; overload;

    /// <summary>
    ///   Reads a stream of data from the serial connection.
    /// </summary>
    /// <param name="AData">
    ///   The stream to store the received data.
    /// </param>
    /// <param name="ABytesToRead">
    ///   The number of bytes to read.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the specified number of bytes were read or <c>False</c>
    ///   otherwise.
    /// </returns>
    function Read(var AData: TMemoryStream; ABytesToRead: Cardinal): Boolean; overload;
  {$IFDEF MSWINDOWS}
    /// <summary>
    ///   Resumes a previously suspended character transmission.
    /// </summary>
    procedure Resume();
  {$ENDIF}
    /// <summary>
    ///   Suspends character transmission.
    /// </summary>
    /// <param name="ADuration">
    ///   Optional: The duration in milliseconds to suspend the connection.
  {$IFDEF MSWINDOWS}
    ///   After this duration <c>Resume()</c> is called. If set to <c>-1</c> the
    ///   <c>Resume()</c> must be called manually.
  {$ENDIF}
    /// </param>
    procedure Suspend(ADuration: Integer{$IFDEF MSWINDOWS} = -1{$ENDIF});

    /// <summary>
    ///   Writes a single byte on the serial connection.
    /// </summary>
    /// <param name="AByte">
    ///   The byte to be written.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the byte was written or <c>False</c> otherwise.
    /// </returns>
    function Write(AByte: Byte): Boolean; overload;

    /// <summary>
    ///   Writes data on the serial connection.
    /// </summary>
    /// <param name="AData">
    ///   A buffer containing the data to be written.
    /// </param>
    /// <returns>
    ///   The number of bytes written.
    /// </returns>
    function Write(const AData: TBytes): Cardinal; overload;

    /// <summary>
    ///   Writes data on the serial connection.
    /// </summary>
    /// <param name="AData">
    ///   A buffer containing the data to be written.
    /// </param>
    /// <returns>
    ///   The number of bytes written.
    /// </returns>
    function Write(const AData: TMemoryStream): Cardinal; overload;

    /// <summary>
    ///   Writes data on the serial connection.
    /// </summary>
    /// <param name="AData">
    ///   A buffer containing the data to be written.
    /// </param>
    /// <param name="ALength">
    ///   The length of bytes to be written.
    /// </param>
    /// <returns>
    ///   The number of bytes written.
    /// </returns>
    function Write(const AData; ALength: Cardinal): Cardinal; overload;

    /// <summary>
    ///   Gets or sets the baudrate.
    /// </summary>
    property BaudRate: TBaudRate read FBaudRate write SetBaudRate default br9600;

    /// <summary>
    ///   Gets or sets the used data bits.
    /// </summary>
    property DataBits: TDataBits read FDataBits write SetDataBits default dbEight;
  {$IFDEF MSWINDOWS}
    /// <summary>
    ///   Gets or sets the error character used to replace bytes received with
    ///   a parity error.
    /// </summary>
    property ErrorChar: AnsiChar read FErrorChar write SetErrorChar default #0;
  {$ENDIF}
    /// <summary>
    ///   Gets or sets the usage of flow control.
    /// </summary>
    property FlowControl: Boolean read FFlowControl write SetFlowControl default False;

    /// <summary>
    ///   Occurs when the connection has been established.
    /// </summary>
    property OnOpen: TNotifyEvent read FOnOpen write FOnOpen;

    /// <summary>
    ///   Occurs when the connection has been terminated.
    /// </summary>
    property OnClose: TNotifyEvent read FOnClose write FOnClose;

    /// <summary>
    ///   Gets or sets the used parity bits.
    /// </summary>
    property Parity: TParityBits read FParityBits write SetParityBits default pbNone;

    /// <summary>
    ///   Gets the used serial port.
    /// </summary>
    property Port: string read FSerialPort;

    /// <summary>
    ///   Gets or sets the used stop bits.
    /// </summary>
    property StopBits: TStopBits read FStopBits write SetStopBits default sbOne;
  {$IFDEF MSWINDOWS}
    /// <summary>
    ///   Gets or sets the if null chars <c>#0</c> should be stipped off.
    /// </summary>
    property StripNullChars: Boolean read FStripNull write SetStripNull default False;
  {$ENDIF}
    /// <summary>
    ///   Gets or sets the timeout in milliseconds.
    /// </summary>
    property Timeout: Word read FTimeout write FTimeout default 3000;
  {$IFDEF MSWINDOWS}
    /// <summary>
    ///   Gets or sets the XON/XOFF flow control XON char.
    /// </summary>
    property XOnChar: AnsiChar read FXOnChar write SetXOnChar default #17;

    /// <summary>
    ///   Gets or sets the XON/XOFF flow control XON limit.
    /// </summary>
    property XOnLim: Word read FXOnLim write SetXOnLim default 1024;

    /// <summary>
    ///   Gets or sets the XON/XOFF flow control XOFF char.
    /// </summary>
    property XOffChar: AnsiChar read FXOffChar write SetXOffChar default #19;

    /// <summary>
    ///   Gets or sets the XON/XOFF flow control XOFF limit.
    /// </summary>
    property XOffLim: Word read FXOffLim write SetXOffLim default 2048;
  {$ENDIF}
  end;

implementation

{ TBaudRateHelper }

function TBaudRateHelper.FromBaudRate(ABaudRate: Integer): TBaudRate;
begin
  case ABaudRate of
    110:    Result := br110;
    300:    Result := br300;
    600:    Result := br600;
    1200:   Result := br1200;
    2400:   Result := br2400;
    4800:   Result := br4800;
    9600:   Result := br9600;
  {$IFDEF MSWINDOWS}
    14440:  Result := br14400;
  {$ENDIF}
    19200:  Result := br19200;
    38400:  Result := br38400;
    57600:  Result := br57600;
    115200: Result := br115200;
  {$IFDEF MSWINDOWS}
    128000: Result := br128000;
    256000: Result := br256000;
  {$ELSE}
    230400: Result := br230400;
  {$ENDIF}
    else    raise EArgumentException.Create('Unsupported baudrate!');
  end;  //of case
end;

function TBaudRateHelper.ToBaudRate(): Integer;
begin
  Result := 0;

  case Self of
    br110:    Result := 110;
    br300:    Result := 300;
    br600:    Result := 600;
    br1200:   Result := 1200;
    br2400:   Result := 2400;
    br4800:   Result := 4800;
    br9600:   Result := 9600;
  {$IFDEF MSWINDOWS}
    br14400:  Result := 14400;
  {$ENDIF}
    br19200:  Result := 19200;
    br38400:  Result := 38400;
    br57600:  Result := 57600;
    br115200: Result := 115200;
  {$IFDEF MSWINDOWS}
    br128000: Result := 128000;
    br256000: Result := 256000;
  {$ELSE}
    br230400: Result := 230400;
  {$ENDIF}
  end;  //of case
end;


{ TSerialConnection }

constructor TSerialConnection.Create();
begin
  inherited Create;
  FBaudRate := br9600;
  FDataBits := dbEight;
  FStopBits := sbOne;
  FSerial := INVALID_HANDLE_VALUE;
{$IFDEF MSWINDOWS}
  FXOnChar := #17;
  FXOnLim := 1024;
  FXOffChar := #19;
  FXOffLim := 2048;
{$ENDIF}
  FTimeout := 3000;
end;

destructor TSerialConnection.Destroy;
begin
  ClosePort();
  inherited Destroy;
end;

procedure TSerialConnection.Flush();
begin
  if IsOpened() then
  {$IFDEF MSWINDOWS}
    FlushFileBuffers(FSerial);
  {$ELSE}
    tcdrain(FSerial);
  {$ENDIF}
end;

procedure TSerialConnection.SetBaudRate(const ABaudRate: TBaudRate);
begin
  if (FBaudRate <> ABaudRate) then
  begin
    FBaudRate := ABaudRate;
    Setup();
  end;  //of begin
end;

procedure TSerialConnection.SetParityBits(const AParityBits: TParityBits);
begin
  if (FParityBits <> AParityBits) then
  begin
    FParityBits := AParityBits;
    Setup();
  end;  //of begin
end;

procedure TSerialConnection.SetDataBits(const ADataBits: TDataBits);
begin
  if (FDataBits <> ADataBits) then
  begin
    FDataBits := ADataBits;
    Setup();
  end;  //of begin
end;

procedure TSerialConnection.SetFlowControl(const AFlowControl: Boolean);
begin
  if (FFlowControl <> AFlowControl) then
  begin
    FFlowControl := AFlowControl;
    Setup();
  end;  //of begin
end;

procedure TSerialConnection.SetStopBits(const AStopBits: TStopBits);
begin
  if (FStopBits <> AStopBits) then
  begin
    FStopBits := AStopBits;
    Setup();
  end;  //of begin
end;

{$IFDEF MSWINDOWS}
procedure TSerialConnection.SetErrorChar(const AErrorChar: AnsiChar);
begin
  if (FErrorChar <> AErrorChar) then
  begin
    FErrorChar := AErrorChar;
    Setup();
  end;  //of begin
end;

procedure TSerialConnection.SetStripNull(const AStripNull: Boolean);
begin
  if (FStripNull <> AStripNull) then
  begin
    FStripNull := AStripNull;
    Setup();
  end;  //of begin
end;

procedure TSerialConnection.SetXOffChar(const AXOffChar: AnsiChar);
begin
  if (FXOffChar <> AXOffChar) then
  begin
    FXOffChar := AXOffChar;
    FFlowControl := True;
    Setup();
  end;  //of begin
end;

procedure TSerialConnection.SetXOffLim(const AXOffLim: Word);
begin
  if (FXOffLim <> AXOffLim) then
  begin
    FXOffLim := AXOffLim;
    Setup();
  end;  //of begin
end;

procedure TSerialConnection.SetXOnChar(const AXOnChar: AnsiChar);
begin
  if (FXOnChar <> AXOnChar) then
  begin
    FXOnChar := AXOnChar;
    FFlowControl := True;
    Setup();
  end;  //of begin
end;

procedure TSerialConnection.SetXOnLim(const AXOnLim: Word);
begin
  if (FXOnLim <> AXOnLim) then
  begin
    FXOnLim := AXOnLim;
    Setup();
  end;  //of begin
end;
{$ENDIF}

procedure TSerialConnection.CheckSerial(AStatus: {$IFDEF MSWINDOWS}BOOL{$ELSE}Integer{$ENDIF});
begin
  if {$IFDEF MSWINDOWS}not AStatus{$ELSE}(AStatus <> 0){$ENDIF} then
    raise ESerialException.Create(SysErrorMessage({$IFDEF MSWINDOWS}GetLastError(){$ELSE}fpgeterrno(){$ENDIF}));
end;

procedure TSerialConnection.Setup();
var
  Settings: {$IFDEF MSWINDOWS}TDCB{$ELSE}TTermios{$ENDIF};
{$IFNDEF MSWINDOWS}
  BaudRateFlag: Cardinal;
{$ENDIF}

begin
  if not IsOpened() then
    Exit;

  FillChar(Settings, SizeOf(Settings), 0);
{$IFDEF MSWINDOWS}
  CheckSerial(GetCommState(FSerial, Settings));

  // Set baud rate
  Settings.BaudRate := FBaudRate.ToBaudRate();

  // Set stop bits
  case FStopBits of
    sbOne:       Settings.StopBits := ONESTOPBIT;
    sbOnePtFive: Settings.StopBits := ONE5STOPBITS;
    sbTwo:       Settings.StopBits := TWOSTOPBITS;
  end;  //of case

  // Set length of used data bits
  case FDataBits of
    dbFive:  Settings.ByteSize := 5;
    dbSix:   Settings.ByteSize := 6;
    dbSeven: Settings.ByteSize := 7;
    dbEight: Settings.ByteSize := 8;
  end;  //of case

  // Set parity bits
  case FParityBits of
    pbNone:  Settings.Parity := NOPARITY;
    pbOdd:   Settings.Parity := ODDPARITY;
    pbEven:  Settings.Parity := EVENPARITY;
    pbMark:  Settings.Parity := MARKPARITY;
    pbSpace: Settings.Parity := SPACEPARITY;
  end;  //of case

  if (FParityBits <> pbNone) then
  begin
    Settings.Flags := Settings.Flags or DCB_PARITY or DCB_ERRORCHAR;
    Settings.ErrorChar := FErrorChar;
  end;  //of begin

  // Usage of flow control?
  if FFlowControl then
  begin
    Settings.Flags := Settings.Flags or DCB_INX or DCB_OUTX or DCB_TXCONTINUEXONXOFF;
    Settings.XonChar := FXOnChar;
    Settings.XoffChar := FXOffChar;
  end;  //of begin

  // Strip null chars?
  if FStripNull then
    Settings.Flags := Settings.Flags or DCB_NULL;

  CheckSerial(SetCommState(FSerial, Settings));
{$ELSE}
  CheckSerial(TCGetAttr(FSerial, Settings));
  CFMakeRaw(Settings);
  Settings.c_cflag := Settings.c_cflag or CREAD or CLOCAL or HUPCL;

  // Set baud rate
  case FBaudRate of
    br110:    BaudRateFlag := B110;
    br300:    BaudRateFlag := B300;
    br600:    BaudRateFlag := B600;
    br1200:   BaudRateFlag := B1200;
    br2400:   BaudRateFlag := B2400;
    br4800:   BaudRateFlag := B4800;
    br9600:   BaudRateFlag := B9600;
  {$IFDEF MSWINDOWS}
    br14400:  BaudRateFlag := B14400;
  {$ENDIF}
    br19200:  BaudRateFlag := B19200;
    br38400:  BaudRateFlag := B38400;
    br57600:  BaudRateFlag := B57600;
    br115200: BaudRateFlag := B115200;
    br230400: BaudRateFlag := B230400;
  end;  //of case

  CFSetOSpeed(Settings, BaudRateFlag);
  CFSetISpeed(Settings, BaudRateFlag);

  // Set stop bits
  case FStopBits of
    sbOne: Settings.c_cflag := Settings.c_cflag and (not CSTOPB);
    sbTwo: Settings.c_cflag := Settings.c_cflag and CSTOPB;
  end;  //of case

  // Set length of used data bits
  Settings.c_cflag := Settings.c_cflag and (not CSIZE);

  case FDataBits of
    dbFive:  Settings.c_cflag := Settings.c_cflag or CS5;
    dbSix:   Settings.c_cflag := Settings.c_cflag or CS6;
    dbSeven: Settings.c_cflag := Settings.c_cflag or CS7;
    dbEight: Settings.c_cflag := Settings.c_cflag or CS8;
  end;  //of case

  // Set parity bits
  case FParityBits of
    pbOdd:   Settings.c_cflag := Settings.c_cflag or PARODD;
    pbEven:  Settings.c_cflag := Settings.c_cflag and (not PARODD);
  end;  //of case

  if (FParityBits <> pbNone) then
    Settings.c_cflag := Settings.c_cflag or PARENB
  else
    Settings.c_cflag := Settings.c_cflag and (not PARENB);

  Settings.c_cflag := Settings.c_cflag and (not CRTSCTS);

  // Usage of flow control?
  if FFlowControl then
    Settings.c_iflag := Settings.c_iflag and (IXON or IXOFF or IXANY)
  else
    Settings.c_iflag := Settings.c_iflag and (not (IXON or IXOFF or IXANY));

  CheckSerial(TCSetAttr(FSerial, TCSANOW, Settings));
{$ENDIF}
end;

procedure TSerialConnection.Suspend(ADuration: Integer);
begin
  if not IsOpened() then
    Exit;

{$IFDEF MSWINDOWS}
  SetCommBreak(FSerial);
{$ENDIF}

  if (ADuration >= 0) then
  begin
  {$IFDEF MSWINDOWS}
    Sleep(ADuration);
    Resume();
  {$ELSE}
    TCSendBreak(FSerial, ADuration);
  {$ENDIF}
  end;  //of begin
end;

function TSerialConnection.OpenPort(const APort: string): Boolean;
const
  Prefix = {$IFDEF MSWINDOWS}'COM'{$ELSE}'/dev/tty'{$ENDIF};

begin
  if (StrLComp(PChar(APort), PChar(Prefix), Length(Prefix)) <> 0) then
    raise ESerialException.Create('Invalid port!');

  // Already opened?
  if ((FSerialPort = APort) and IsOpened()) then
  begin
    Result := True;
    Exit;
  end;  //of begin

  if IsOpened() then
    ClosePort();

  FSerialPort := APort;
{$IFDEF MSWINDOWS}
  FSerial := CreateFileW(PChar(FSerialPort), GENERIC_READ OR GENERIC_WRITE,
    0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED, 0);
{$ELSE}
  FSerial := FpOpen(FSerialPort, O_RDWR or O_SYNC);
{$ENDIF}
  Result := IsOpened();

  if Result then
  begin
    Setup();

    if Assigned(FOnOpen) then
      FOnOpen(Self);
  end;  //of begin
end;

{$IFDEF MSWINDOWS}
function TSerialConnection.CanEvent(AEvent: DWORD; ATimeout: Integer): Boolean;
var
  Overlapped: TOverlapped;
  LastError, EventMask: DWORD;

begin
  Result := False;

  if not IsOpened() then
    Exit;

  ZeroMemory(@Overlapped, SizeOf(Overlapped));
  LastError := ERROR_SUCCESS;
  EventMask := 0;
  Overlapped.hEvent := CreateEvent(nil, True, False, nil);

  try
    SetCommMask(FSerial, AEvent);

    if ((AEvent = EV_RXCHAR) and (BytesToRead() > 0)) then
      Exit(True);

    if not WaitCommEvent(FSerial, EventMask, @Overlapped) then
      LastError := GetLastError();

    if (LastError = ERROR_IO_PENDING) then
    begin
      WaitForSingleObject(Overlapped.hEvent, ATimeout);
      SetCommMask(FSerial, 0);
      GetOverlappedResult(FSerial, Overlapped, LastError, True);
    end;  //of begin

    Result := (EventMask and AEvent) = AEvent;

  finally
    SetCommMask(FSerial, 0);
    CloseHandle(Overlapped.hEvent);
  end;  //of try
end;
{$ENDIF}

function TSerialConnection.BytesToRead(): Cardinal;
{$IFDEF MSWINDOWS}
var
  LastError: DWORD;
  ComStat: TComStat;
{$ENDIF}

begin
  Result := 0;

  if not IsOpened() then
    Exit;

{$IFDEF MSWINDOWS}
  ClearCommError(FSerial, LastError, @ComStat);
  Result := ComStat.cbInQue;
{$ELSE}
  FpIOCtl(FSerial, FIONREAD, @Result);
{$ENDIF}
end;

function TSerialConnection.BytesToWrite(): Cardinal;
{$IFDEF MSWINDOWS}
var
  LastError: DWORD;
  ComStat: TComStat;
{$ENDIF}

begin
  Result := 0;

  if not IsOpened() then
    Exit;

{$IFDEF MSWINDOWS}
  ClearCommError(FSerial, LastError, @ComStat);
  Result := ComStat.cbOutQue;
{$ENDIF}
end;

function TSerialConnection.CanRead(ATimeout: Integer;
  AMinBytesAvailable: Cardinal = 1): Boolean;
{$IFNDEF MSWINDOWS}
var
  FDSet: TFDSet;
{$ENDIF}

begin
  Result := (BytesToRead() > AMinBytesAvailable);

  if not Result then
{$IFDEF MSWINDOWS}
    Result := CanEvent(EV_RXCHAR, ATimeout) or (BytesToRead() >= AMinBytesAvailable);
{$ELSE}
  begin
    fpFD_ZERO(FDSet);
    fpFD_SET(FSerial, FDSet);

    if (FpSelect(FSerial + 1, @FDSet, nil, nil, ATimeout) > 0) then
      Result := (fpFD_ISSET(FSerial, FDSet) > 0) and (BytesToRead() >= AMinBytesAvailable);
  end;  //of begin
{$ENDIF}
end;

function TSerialConnection.CanWrite(ATimeout: Integer;
  AMinBytesAvailable: Cardinal = 1): Boolean;
{$IFNDEF MSWINDOWS}
var
  FDSet: TFDSet;
{$ENDIF}

begin
  Result := (BytesToWrite() >= AMinBytesAvailable);

  if not Result then
{$IFDEF MSWINDOWS}
    Result := CanEvent(EV_TXEMPTY, ATimeout);
{$ELSE}
  begin
    fpFD_ZERO(FDSet);
    fpFD_SET(FSerial, FDSet);

    if (FpSelect(FSerial + 1, nil, @FDSet, nil, ATimeout) > 0) then
      Result := (fpFD_ISSET(FSerial, FDSet) > 0);
  end;  //of begin
{$ENDIF}
end;

procedure TSerialConnection.ClosePort();
begin
  Purge();
  FileClose(FSerial);
  FSerial := INVALID_HANDLE_VALUE;

  if Assigned(FOnClose) then
    FOnClose(Self);
end;

function TSerialConnection.IsOpened(): Boolean;
begin
  Result := (FSerial <> INVALID_HANDLE_VALUE);
end;

procedure TSerialConnection.Purge();
begin
  if IsOpened() then
  {$IFDEF MSWINDOWS}
    PurgeComm(FSerial, PURGE_TXABORT or PURGE_TXCLEAR or PURGE_RXABORT or PURGE_RXCLEAR);
  {$ELSE}
    FpIOCtl(FSerial, TCFLSH, Pointer(PtrInt(TCIOFLUSH)));
  {$ENDIF}
end;

function TSerialConnection.Read(): Byte;
begin
  Read(Result, 1);
end;

function TSerialConnection.Read(var AData; ABytesToRead: Cardinal): Cardinal;
{$IFDEF MSWINDOWS}
var
  LastError: DWORD;
  Overlapped: TOverlapped;
{$ENDIF}

begin
  if not IsOpened() then
    raise ESerialException.Create('No port was opened yet!');

{$IFDEF MSWINDOWS}
  ZeroMemory(@Overlapped, SizeOf(Overlapped));
  LastError := ERROR_SUCCESS;

  if not ReadFile(FSerial, AData, ABytesToRead, Result, @Overlapped) then
    LastError := GetLastError();

  if (LastError = ERROR_IO_PENDING) then
  begin
    if (WaitForSingleObject(FSerial, FTimeout) = WAIT_TIMEOUT) then
      PurgeComm(FSerial, PURGE_RXABORT)
    else
      GetOverlappedResult(FSerial, Overlapped, Result, False);
  end  //of begin
  else
    if (LastError <> ERROR_SUCCESS) then
      raise ESerialException.Create(SysErrorMessage(LastError));

  ClearCommError(FSerial, LastError, nil);
{$ELSE}
  Result := FileRead(FSerial, AData, ABytesToRead);

  if (Result = Cardinal(INVALID_HANDLE_VALUE)) then
    raise ESerialException.Create(SysErrorMessage(fpgeterrno()));
{$ENDIF}
end;

function TSerialConnection.Read(ABytesToRead: Cardinal): TBytes;
var
  BytesRead: Cardinal;

begin
  SetLength(Result, ABytesToRead);
  BytesRead := Read(Result[0], ABytesToRead);

  if (ABytesToRead <> BytesRead) then
    SetLength(Result, BytesRead);
end;

function TSerialConnection.Read(var AData: TMemoryStream): Cardinal;
begin
  Result := BytesToRead();

  if not Read(AData, Result) then
    Result := 0;
end;

function TSerialConnection.Read(var AData: TMemoryStream; ABytesToRead: Cardinal): Boolean;
var
  Data: TBytes;

begin
  Result := CanRead(FTimeout, ABytesToRead);

  if Result then
  begin
    Data := Read(ABytesToRead);
    AData.Write(Data, Length(Data));
  end;  //of begin
end;

{$IFDEF MSWINDOWS}
procedure TSerialConnection.Resume();
begin
  if IsOpened() then
    ClearCommBreak(FSerial);
end;
{$ENDIF}

function TSerialConnection.Write(AByte: Byte): Boolean;
begin
  Result := (Write(AByte, 1) = 1);
end;

function TSerialConnection.Write(const AData; ALength: Cardinal): Cardinal;
{$IFDEF MSWINDOWS}
var
  LastError: DWORD;
  Overlapped: TOverlapped;
{$ENDIF}

begin
  if not IsOpened() then
    raise ESerialException.Create('No port was opened yet!');

{$IFDEF MSWINDOWS}
  ZeroMemory(@Overlapped, SizeOf(Overlapped));
  LastError := ERROR_SUCCESS;

  if not WriteFile(FSerial, AData, ALength, Result, @Overlapped) then
    LastError := GetLastError();

  if (LastError = ERROR_IO_PENDING) then
  begin
    if (WaitForSingleObject(FSerial, FTimeout) = WAIT_TIMEOUT) then
      PurgeComm(FSerial, PURGE_TXABORT)
    else
      GetOverlappedResult(FSerial, Overlapped, Result, False);
  end  //of begin
  else
    if (LastError <> ERROR_SUCCESS) then
      raise ESerialException.Create(SysErrorMessage(GetLastError()));

  ClearCommError(FSerial, LastError, nil);
{$ELSE}
  Result := FileWrite(FSerial, AData, ALength);

  if (Result = Cardinal(INVALID_HANDLE_VALUE)) then
    raise ESerialException.Create(SysErrorMessage(fpgeterrno()));
{$ENDIF}
end;

function TSerialConnection.Write(const AData: TBytes): Cardinal;
begin
  Result := Write(AData[0], Length(AData));
end;

function TSerialConnection.Write(const AData: TMemoryStream): Cardinal;
begin
  Result := Write(AData.Memory^, AData.Size);
end;

end.
