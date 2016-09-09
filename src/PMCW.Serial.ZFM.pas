{ *********************************************************************** }
{                                                                         }
{ ZhianTec Fingerprint Module (ZFM) unit                                  }
{                                                                         }
{ Copyright (c) 2011-2016 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit PMCW.Serial.ZFM;

{$IFDEF FPC}{$mode delphiunicode}{$ENDIF}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ELSE}
  LCLType,
{$ENDIF}
  SysUtils, Classes, Graphics, PMCW.Serial;

const
  { Baotou start bytes }
  ZFM_STARTCODE                     = $EF01;

  { Packet identification }
  ZFM_COMMANDPACKET                 = $01;
  ZFM_DATAPACKET                    = $02;
  ZFM_ACKPACKET                     = $07;
  ZFM_ENDDATAPACKET                 = $08;

  { Instruction codes }
  ZFM_READIMAGE                     = $01;
  ZFM_CONVERTIMAGE                  = $02;
  ZFM_COMPARECHARACTERISTICS        = $03;
  ZFM_SEARCHTEMPLATE                = $04;
  ZFM_CREATETEMPLATE                = $05;
  ZFM_STORETEMPLATE                 = $06;
  ZFM_LOADTEMPLATE                  = $07;
  ZFM_DOWNLOADCHARACTERISTICS       = $08;
  ZFM_UPLOADCHARACTERISTICS         = $09;
  ZFM_DOWNLOADIMAGE                 = $0A;
  ZFM_UPLOADIMAGE                   = $0B;
  ZFM_DELETETEMPLATE                = $0C;
  ZFM_CLEARDATABASE                 = $0D;
  ZFM_SETSYSTEMPARAMETER            = $0E;
  ZFM_GETSYSTEMPARAMETERS           = $0F;
  ZFM_SETPASSWORD                   = $12;
  ZFM_VERIFYPASSWORD                = $13;
  ZFM_GENERATERANDOMNUMBER          = $14;
  ZFM_SETADDRESS                    = $15;
  ZFM_WRITENOTEPAD                  = $18;
  ZFM_READNOTEPAD                   = $19;
  ZFM_TEMPLATECOUNT                 = $1D;
  ZFM_TEMPLATEINDEX                 = $1F;

  { Packet reply confirmations }
  ZFM_SUCCESS                       = $00; // command execution complete
  ZFM_ERROR_COMMUNICATION           = $01; // error when receiving data package
  ZFM_ERROR_NOFINGER                = $02; // no finger on the sensor
  ZFM_ERROR_READIMAGE               = $03; // fail to enroll the finger
  ZFM_ERROR_MESSYIMAGE              = $06; // fail to generate character file due to the over-disorderly fingerprint image
  ZFM_ERROR_FEWFEATUREPOINTS        = $07; // fail to generate character file due to lackness of character point or over-smallness of fingerprint image
  ZFM_ERROR_NOTMATCHING             = $08; // finger does not match
  ZFM_ERROR_NOTEMPLATEFOUND         = $09; // fail to find the matching finger
  ZFM_ERROR_CHARACTERISTICSMISMATCH = $0A; // fail to combine the character files
  ZFM_ERROR_INVALIDPOSITION         = $0B; // addressing PageID is beyond the finger library
  ZFM_ERROR_LOADTEMPLATE            = $0C; // error when reading template from library or the template is invalid
  ZFM_ERROR_DOWNLOADCHARACTERISTICS = $0D; // error when uploading template
  ZFM_ERROR_PACKETRESPONSEFAIL      = $0E; // Module cannot receive the following data packages
  ZFM_ERROR_DOWNLOADIMAGE           = $0F; // error when uploading image
  ZFM_ERROR_DELETETEMPLATE          = $10; // fail to delete the template
  ZFM_ERROR_CLEARDATABASE           = $11; // fail to clear finger library
  ZFM_ERROR_WRONGPASSWORD           = $13; // incorrect password
  ZFM_ERROR_INVALIDIMAGE            = $15; // fail to generate the image for the lackness of valid primary image
  ZFM_ERROR_FLASH                   = $18; // error when writing flash
  ZFM_ERROR_INVALIDREGISTER         = $1A; // invalid register number
  ZFM_ERROR_ADDRCODE                = $20; // wrong address code
  ZFM_ERROR_PASSVERIFY              = $21; // the password must be verified first
  ZFM_ERROR_BADPACKET               = $FE; // unexpected packet
  ZFM_ERROR_TIMEOUT                 = $FF; // timeout exceeded

  { System constants  }
  ZFM_FINGERPRINT_IMAGE_HEIGHT      = 288;
  ZFM_FINGERPRINT_IMAGE_WIDTH       = 256;
  ZFM_CHARACTERISTICS_COUNT         = 512;
  ZFM_NOTEPAD_DATA_COUNT            = 32;

type
  /// <summary>
  ///   Possible ZFM packet types.
  /// </summary>
  TZfmPacketType = (

    /// <summary>
    ///   Command packet. This is a request packet to be send to the sensor.
    /// </summary>
    ptCmd,

    /// <summary>
    ///   Data packet. Used during up- and downloads.
    /// </summary>
    ptData,

    /// <summary>
    ///   Acknowledgement packet. This is the response by the sensor after
    ///   a command packet has been received.
    /// </summary>
    ptAck,

    /// <summary>
    ///   End data packet. This signals the last packet of an up- or download.
    /// </summary>
    ptEndData
  );

  /// <summary>
  ///   The packet of a ZFM (without header).
  /// </summary>
  TZfmPacket = record

    /// <summary>
    ///   The packet type.
    /// </summary>
    PacketType: TZfmPacketType;

    /// <summary>
    ///   The packet data.
    /// </summary>
    PacketPayload: TBytes;

    /// <summary>
    ///   Creates a one byte command packet.
    /// </summary>
    /// <param name="ACommand">
    ///   A ZFM command.
    /// </param>
    constructor Create(ACommand: Byte);
  end;

  /// <summary>
  ///   Possible ZFM packet lengths.
  /// </summary>
  TZfmPacketLength = (

    /// <summary>
    ///  32 byte packets
    /// </summary>
    pl32Byte,

    /// <summary>
    ///  64 byte packets
    /// </summary>
    pl64Byte,

    /// <summary>
    ///  128 byte packets
    /// </summary>
    pl128Byte,

    /// <summary>
    ///  256 byte packets
    /// </summary>
    pl256Byte
  );

  TZfmPacketLengthHelper = record helper for TZfmPacketLength

    /// <summary>
    ///   Gets the packet length in bytes.
    /// </summary>
    function NumberOfBytes(): Word;
  end;

  /// <summary>
  ///   Available template pages of a ZFM.
  /// </summary>
  TZfmTemplatePage = 0..3;

  /// <summary>
  ///   A boolean array representing the internal storage.
  /// </summary>
  TZfmTemplateIndex = array of Boolean;

  /// <summary>
  ///   Available <c>CharBuffer</c>s of a ZFM. Each can hold 512 bytes
  ///   fingerprint characteristics.
  /// </summary>
  TZfmCharBuffer = (

    /// <summary>
    ///   <c>CharBuffer1</c>
    /// </summary>
    cbOne = 1,

    /// <summary>
    ///   <c>CharBuffer2</c>
    /// </summary>
    cbTwo = 2
  );

  /// <summary>
  ///   Contains the found template index with the corresponding accuracy.
  /// </summary>
  TZfmTemplateSearchResult = record

    /// <summary>
    ///   The found template index. <c>-1</c> if not found.
    /// </summary>
    TemplateIndex: SmallInt;

    /// <summary>
    ///   The corresponding accuracy score of the found template. <c>0</c> if
    ///   not found.
    /// </summary>
    Accuracy: Word;
  end;

  /// <summary>
  ///   Possible ZFM security levels.
  /// </summary>
  TZfmSecurityLevel = (

    /// <summary>
    ///   Highest error tolerance when searching for finger.
    /// </summary>
    slLowest = 1,

    /// <summary>
    ///   High error tolerance when searching for finger.
    /// </summary>
    slLow = 2,

    /// <summary>
    ///   Normal error tolerance when searching for finger.
    /// </summary>
    slNormal = 3,

    /// <summary>
    ///   Low error tolerance when searching for finger.
    /// </summary>
    slHigh = 4,

    /// <summary>
    ///   Lowest error tolerance when searching for finger.
    /// </summary>
    slHighest = 5
  );

  /// <summary>
  ///   Contains internal used system parameters of the sensor.
  /// </summary>
  TZfmSystemParameters = record
    StatusRegister: Word;
    SystemID: Word;
    StorageCapacity: Word;
    SecurityLevel: Word;
    DeviceAddress: UInt32;
    PacketLength: Word;
    BaudRate: Word;
  end;

  /// <summary>
  ///   The characteristics of a finger.
  /// </summary>
  TZfmCharacteristics = array[0..ZFM_CHARACTERISTICS_COUNT-1] of Byte;

  /// <summary>
  ///   Available notepad pages of a ZFM.
  /// </summary>
  TZfmNotepadPage = 0..15;

  /// <summary>
  ///   The ZFM notepad data.
  /// </summary>
  TZfmNotepadData = array[0..ZFM_NOTEPAD_DATA_COUNT-1] of Byte;

const
  /// <summary>
  ///   Header size in bytes of a packet (exclusive payload!).
  /// </summary>
  /// <remarks>
  ///   ZFM packet header = start code (2 bytes) + address (4 bytes) + packet
  ///   type (1 byte) + packet length (2 bytes) + packet checksum (2 bytes)
  /// </remarks>
  ZFM_PACKET_HEADER_SIZE = 11;

type
  /// <summary>
  ///   The ZFM exception class.
  /// </summary>
  EZfmException = class(Exception);

  /// <summary>
  ///   Serial operation progress indication event.
  /// </summary>
  TZfmProgressEvent = procedure(Sender: TObject; const AProgress, ATotal: Cardinal;
    var ACancel: Boolean) of object;

  /// <summary>
  ///   A <c>TZfmSensor</c> manages a ZhianTec ZFM-20 fingerprint sensor.
  /// </summary>
  TZfmSensor = class(TObject)
  private
    FSerial: TSerialConnection;
    FAddress,
    FPassword: UInt32;
    FTimeout,
    FLastError: Byte;
    FOnStart,
    FOnFinish: TNotifyEvent;
    FOnProgress: TZfmProgressEvent;
    procedure DoNotifyOnStart();
    procedure DoNotifyOnFinish();
    function GetLastErrorMessage(): string;
    function GetSerialPort(): string;
    function GetBaudRate(): TBaudRate;
    function GetPacketLength(): TZfmPacketLength;
    function GetSecurityLevel(): TZfmSecurityLevel;
    function GetStorageCapacity(): Word;
    function GetSystemId(): Word;
    procedure SetSecurityLevel(const ASecurityLevel: TZfmSecurityLevel);
    procedure SetAddress(const ANewAddress: UInt32);
    procedure SetPassword(const ANewPassword: UInt32);
    procedure SetBaudRate(const ABaudRate: TBaudRate);
    procedure SetPacketLength(const APacketLength: TZfmPacketLength);
    function UploadData(const AData: PByte; ADataLength: Cardinal;
      APacketLength: Word): Boolean;
  protected
    /// <summary>
    ///   Checks a received response (ack) packet.
    /// </summary>
    /// <param name="AReceivedPacket">
    ///   The received packet by <see cref="ReadPacket"/>.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the request was successfully processed by the sensor or
    ///   <c>False</c> otherwise.
    /// </returns>
    function CheckResponse(const AReceivedPacket: TZfmPacket): Boolean;

    /// <summary>
    ///   Gathers sensor parameters.
    /// </summary>
    /// <returns>
    ///   A <see cref="TZfmSystemParameters"/> record.
    /// </returns>
    function GetSystemParameters(): TZfmSystemParameters;

    /// <summary>
    ///   Receives and parses the response from the sensor.
    /// </summary>
    /// <returns>
    ///   The received packet.
    /// </returns>
    function ReadPacket(): TZfmPacket;

    /// <summary>
    ///   Sets a system parameter.
    /// </summary>
    /// <param name="AParameterNumber">
    ///   The system parameter number.
    /// </param>
    /// <param name="AParameterValue">
    ///   The system parameter value.
    /// </param>
    procedure SetSystemParameter(const AParameterNumber, AParameterValue: Byte);

    /// <summary>
    ///   Sends a request packet to the sensor.
    /// </summary>
    /// <param name="AZfmPacket">
    ///   A valid <see cref="TZfmPacket"/> packet.
    /// </param>
    procedure WritePacket(const AZfmPacket: TZfmPacket);
  public
    /// <summary>
    ///   Constructor for creating a <c>TZfmSensor</c> instance.
    /// </summary>
    /// <param name="AAddress">
    ///   Optional: The sensor address.
    /// </param>
    /// <param name="APassword">
    ///   Optional: The sensor password.
    /// </param>
    constructor Create(AAddress: UInt32 = $FFFFFFFF; APassword: UInt32 = 0);

    /// <summary>
    ///   Destructor for destroying a <c>TZfmSensor</c> instance.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    ///   Clears the complete template database.
    /// </summary>
    procedure ClearDatabase();

    /// <summary>
    ///   Compares the finger characteristics of <c>CharBuffer1</c> with
    ///   <c>CharBuffer2</c> and returns the accuracy score.
    /// </summary>
    /// <returns>
    ///   The accuracy score. If the finger does not match <c>0</c> is returned.
    /// </returns>
    function CompareCharacteristics(): Word;

    /// <summary>
    ///   Tries to establish the connection to the fingerprint sensor. If
    ///   successful the password is verified.
    /// </summary>
    /// <param name="APort">
    ///   The used serial port.
    /// </param>
    /// <param name="ABaudRate">
    ///   Optional: The used baud rate.
    /// </param>
    /// <exception>
    ///   <c>EZfmException</c> when the password is wrong.
    ///   <c>ESerialException</c> when the port was not found.
    /// </exception>
    procedure Connect(const APort: string; ABaudRate: TBaudRate = br57600); overload;

    /// <summary>
    ///   Tries to establish the connection to the fingerprint sensor. If
    ///   successful the password is verified.
    /// </summary>
    /// <param name="APort">
    ///   The used serial port.
    /// </param>
    /// <param name="ABaudRate">
    ///   The used baud rate.
    /// </param>
    /// <exception>
    ///   <c>EZfmException</c> when the password is wrong.
    ///   <c>ESerialException</c> when the port was not found.
    ///   <c>EArgumentException</c> when the baudrate is unsupported.
    /// </exception>
    procedure Connect(const APort: string; ABaudRate: Integer); overload;

    /// <summary>
    ///   Checks if the sensor is connected.
    /// </summary>
    /// <returns>
    ///   <c>True</c> if the connection is opened or <c>False</c> otherwise.
    /// </returns>
    function Connected(): Boolean;

    /// <summary>
    ///   Converts the image in <c>ImageBuffer</c> to finger characteristics and
    ///   stores it in specified <c>CharBuffer</c>.
    /// </summary>
    /// <param name="ADestination">
    ///   The used <c>CharBuffer</c>.
    /// </param>
    procedure ConvertImage(ADestination: TZfmCharBuffer);

    /// <summary>
    ///   Combines the characteristics which are stored in <c>CharBuffer1</c> and
    ///   <c>CharBuffer2</c> to a template. The created template will be stored again
    ///   in <c>CharBuffer1</c> and <c>CharBuffer2</c> as the same.
    /// </summary>
    procedure CreateTemplate();

    /// <summary>
    ///   Deletes one template from the fingerprint database.
    /// </summary>
    /// <param name="AIndex">
    ///   The index of the template that should be deleted.
    /// </param>
    procedure DeleteTemplate(AIndex: Word); overload;

    /// <summary>
    ///   Deletes a range of templates from the fingerprint database.
    /// </summary>
    /// <param name="AStartIndex">
    ///   The index of the template where the deletion should start.
    /// </param>
    /// <param name="ACount">
    ///   The number of templates to be deleted.
    /// </param>
    procedure DeleteTemplate(AStartIndex, ACount: Word); overload;

    /// <summary>
    ///   Downloads the finger characteristics from specified <c>CharBuffer</c>.
    /// </summary>
    /// <param name="ACharBuffer">
    ///   Optional: The used <c>CharBuffer</c>.
    /// </param>
    /// <returns>
    ///   The 512 byte fingerprint characteristics.
    /// </returns>
    function DownloadCharacteristics(ACharBuffer: TZfmCharBuffer = cbOne): TZfmCharacteristics;

    /// <summary>
    ///   Downloads the image of a finger in <c>ImageBuffer</c> to host computer.
    /// </summary>
    /// <param name="ABitmap">
    ///   The bitmap on which the image is drawn.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the download was not canceled or <c>False</c> otherwise.
    /// </returns>
    function DownloadImage(ABitmap: TBitmap): Boolean; overload;

    /// <summary>
    ///   Downloads the image of a finger in <c>ImageBuffer</c> to host computer
    ///   and stores it as bitmap file.
    /// </summary>
    /// <param name="AFileName">
    ///   The filename of the image.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the download was not canceled or <c>False</c> otherwise.
    /// </returns>
    function DownloadImage(const AFileName: TFileName): Boolean; overload;

    /// <summary>
    ///   Gets the number of stored templates.
    /// </summary>
    /// <returns>
    ///   The count.
    /// </returns>
    function GetTemplateCount(): Word;

    /// <summary>
    ///   Generates a random 32-bit decimal number.
    /// </summary>
    /// <returns>
    ///   The number.
    /// </returns>
    function GenerateRandomNumber(): UInt32;

    /// <summary>
    ///   Gets a list of the template positions with usage indicator.
    /// </summary>
    /// <param name="APage">
    ///   The template page.
    /// </param>
    /// <returns>
    ///   A boolean array: If the value at a position is <c>True</c> this position
    ///   is used and contains a template otherwise the position is not used.
    /// </returns>
    function GetTemplateIndex(APage: TZfmTemplatePage): TZfmTemplateIndex;

    /// <summary>
    ///   Loads an existing template specified by position number to specified
    ///   <c>CharBuffer</c>.
    /// </summary>
    /// <param name="AIndex">
    ///   The index of the template that should be loaded.
    /// </param>
    /// <param name="ACharBuffer">
    ///   Optional: The used <c>CharBuffer</c>.
    /// </param>
    procedure LoadTemplate(AIndex: Word; ACharBuffer: TZfmCharBuffer = cbOne);

    /// <summary>
    ///   Raises a <c>EZfmException</c> with the last error message as
    ///   text if the last error differs from the expected error.
    /// </summary>
    /// <param name="AExpectedError">
    ///   Optional: The expected error. NOTE: No exception is raised when this
    ///   error is equal to the last error!
    /// </param>
    procedure RaiseError(AExpectedError: Byte = ZFM_SUCCESS);

    /// <summary>
    ///   Reads the image of a finger and stores it in <c>ImageBuffer</c>.
    /// </summary>
    /// <returns>
    ///   <c>True</c> if a finger was on the sensor and an image was successfully
    ///   stored in <c>ImageBuffer</c> or <c>False</c> if no finger was found.
    /// </returns>
    /// <remarks>
    ///   This is the main method of the sensor. If the read image should be
    ///   stored on the sensor the method <see cref="ConvertImage"/> must be called.
    /// </remarks>
    function ReadImage(): Boolean;

    /// <summary>
    ///   Reads data from a given ZFM notepad page.
    /// </summary>
    /// <returns>
    ///   The ZFM notepad data.
    /// </returns>
    function ReadNotepad(APage: TZfmNotepadPage): TZfmNotepadData;

    /// <summary>
    ///   Searches the finger characteristics from given <c>CharBuffer</c> in
    ///   database.
    /// </summary>
    /// <param name="ACharBuffer">
    ///   The used <c>CharBuffer</c>.
    /// </param>
    /// <returns>
    ///   A <see cref="TZfmTemplateSearchResult"/> which holds the index of the
    ///   found template and the corresponding accuacy score. If the template
    ///   was not found the index is <c>-1</c> and the accuacy score is <c>0</c>.
    /// </returns>
    function SearchTemplate(ACharBuffer: TZfmCharBuffer): TZfmTemplateSearchResult; overload;

    /// <summary>
    ///   Searches the finger characteristics from given <c>CharBuffer</c> in
    ///   database.
    /// </summary>
    /// <param name="ACharBuffer">
    ///   The used <c>CharBuffer</c>.
    /// </param>
    /// <param name="AStartIndex">
    ///   The index to start the search from.
    /// </param>
    /// <param name="ACount">
    ///   The maximum number of templates to search for the characteristics.
    /// </param>
    /// <returns>
    ///   A <see cref="TZfmTemplateSearchResult"/> which holds the index of the
    ///   found template and the corresponding accuacy score. If the template
    ///   was not found the index is <c>-1</c> and the accuacy score is <c>0</c>.
    /// </returns>
    function SearchTemplate(ACharBuffer: TZfmCharBuffer;
      AStartIndex, ACount: Word): TZfmTemplateSearchResult; overload;

    /// <summary>
    ///   Stores a template from the specified <c>CharBuffer</c> at the next
    ///   free index.
    /// </summary>
    /// <param name="ACharBuffer">
    ///   Optional: The used <c>CharBuffer</c>.
    /// </param>
    /// <returns>
    ///   The index the template was stored at.
    /// </returns>
    function StoreTemplate(ACharBuffer: TZfmCharBuffer = cbOne): Word; overload;

    /// <summary>
    ///   Stores a template from the specified <c>CharBuffer</c> at the given
    ///   index.
    /// </summary>
    /// <param name="AIndex">
    ///   The index position to store the template at.
    /// </param>
    /// <param name="ACharBuffer">
    ///   Optional: The used <c>CharBuffer</c>.
    /// </param>
    /// <remarks>
    ///   If a template already exists at the given index it will be overwritten!
    /// </remarks>
    procedure StoreTemplate(AIndex: Word; ACharBuffer: TZfmCharBuffer = cbOne); overload;

    /// <summary>
    ///   Uploads finger characteristics to specified <c>CharBuffer</c>.
    /// </summary>
    /// <param name="ADestination">
    ///   The destination <c>CharBuffer</c>.
    /// </param>
    /// <param name="ACharacteristics">
    ///   The 512 byte fingerprint characteristics.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the upload was not canceled or <c>False</c> otherwise.
    /// </returns>
    function UploadCharacteristics(ADestination: TZfmCharBuffer;
      const ACharacteristics: TZfmCharacteristics): Boolean;

    /// <summary>
    ///   Uploads a fingerprint image to <c>ImageBuffer</c>.
    /// </summary>
    /// <param name="AFingerprintImage">
    ///   The bitmap fingerprint image.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the upload was not canceled or <c>False</c> otherwise.
    /// </returns>
    function UploadImage(const AFingerprintImage: TBitmap): Boolean; overload;

    /// <summary>
    ///   Uploads a fingerprint image to <c>ImageBuffer</c>.
    /// </summary>
    /// <param name="AFileName">
    ///   The filename of the image.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the upload was not canceled or <c>False</c> otherwise.
    /// </returns>
    function UploadImage(const AFileName: TFileName): Boolean; overload;

    /// <summary>
    ///   Writes specified data to a given ZFM notepad page.
    /// </summary>
    /// <param name="APage">
    ///   The ZFM notepad page.
    /// </param>
    /// <param name="AData">
    ///   The specified data.
    /// </param>
    procedure WriteNotepad(APage: TZfmNotepadPage; const AData: TZfmNotepadData);

    /// <summary>
    ///   Verifies password of the fingerprint sensor.
    /// </summary>
    /// <returns>
    ///   <c>True</c> if the sensor password matches or <c>False</c> otherwise.
    /// </returns>
    function VerifyPassword(): Boolean;

    /// <summary>
    ///   Gets or sets the sensor address.
    /// </summary>
    /// <remarks>
    ///   The default is <c>0xFFFFFFFF</c>.
    /// </remarks>
    property Address: UInt32 read FAddress write SetAddress default $FFFFFFFF;

    /// <summary>
    ///   Gets or sets the sensor baud rate.
    /// </summary>
    /// <remarks>
    ///   Only <c>br9600</c>, <c>br19200</c>, <c>br38400</c>, <c>br57600</c> and
    ///   <c>br115200</c> are supported! The default is <c>br57600</c>.
    /// </remarks>
    property BaudRate: TBaudRate read GetBaudRate write SetBaudRate default br57600;

    /// <summary>
    ///   Gets the last occured error code.
    /// </summary>
    property LastError: Byte read FLastError;

    /// <summary>
    ///   Gets the last occured error message.
    /// </summary>
    property LastErrorMessage: string read GetLastErrorMessage;

    /// <summary>
    ///   Event that is called when serial operation has finished.
    /// </summary>
    property OnFinish: TNotifyEvent read FOnFinish write FOnFinish;

    /// <summary>
    ///   Event that is called during long serial operations like downloading or
    ///   uploading.
    /// </summary>
    property OnProgress: TZfmProgressEvent read FOnProgress write FOnProgress;

    /// <summary>
    ///   Event that is called when serial operation has started.
    /// </summary>
    property OnStart: TNotifyEvent read FOnStart write FOnStart;

    /// <summary>
    ///   Gets or sets the sensor maximum packet length.
    /// </summary>
    /// <remarks>
    ///   The default is <c>pl128Byte</c>.
    /// </remarks>
    property PacketLength: TZfmPacketLength read GetPacketLength write SetPacketLength default pl128Byte;

    /// <summary>
    ///   Gets or sets the sensor password.
    /// </summary>
    /// <remarks>
    ///   The default is <c>0x00000000</c>.
    /// </remarks>
    property Password: UInt32 read FPassword write SetPassword default $00000000;

    /// <summary>
    ///   Gets the current used serial port.
    /// </summary>
    property Port: string read GetSerialPort;

    /// <summary>
    ///   Gets or sets the sensor security level.
    /// </summary>
    property SecurityLevel: TZfmSecurityLevel read GetSecurityLevel write SetSecurityLevel default slNormal;

    /// <summary>
    ///   Gets the sensor storage capacity.
    /// </summary>
    property StorageCapacity: Word read GetStorageCapacity;

    /// <summary>
    ///   Gets the sensor system ID.
    /// </summary>
    /// <remarks>
    ///   In v2.0 this a fixed value of <c>0x0000</c>. In v1.4 it was <c>0x0009</c>.
    /// </remarks>
    property SystemId: Word read GetSystemId;

    /// <summary>
    ///   Gets or sets the serial timeout in seconds.
    /// </summary>
    property Timeout: Byte read FTimeout write FTimeout default 3;
  end;

implementation

{ TZfmPacket }

constructor TZfmPacket.Create(ACommand: Byte);
begin
  PacketType := ptCmd;
  SetLength(PacketPayload, 1);
  PacketPayload[0] := ACommand;
end;


{ TZfmPacketLengthHelper }

function TZfmPacketLengthHelper.NumberOfBytes(): Word;
begin
  case Self of
    pl64Byte:  Result := 64;
    pl128Byte: Result := 128;
    pl256Byte: Result := 256;
    else       Result := 32;
  end;  //of case
end;


{ TZfmSensor }

constructor TZfmSensor.Create(AAddress: UInt32 = $FFFFFFFF; APassword: UInt32 = 0);
begin
  inherited Create;
  FAddress := AAddress;
  FPassword := APassword;
  FTimeout := 3;
  FLastError := ZFM_SUCCESS;

  // Setup serial connection
  FSerial := TSerialConnection.Create;

  with FSerial do
  begin
    Timeout := 1000;
    DataBits := dbEight;
    StopBits := sbOne;
  end;  //of with
end;

destructor TZfmSensor.Destroy;
begin
  FreeAndNil(FSerial);
  inherited Destroy;
end;

function TZfmSensor.CheckResponse(const AReceivedPacket: TZfmPacket): Boolean;
begin
  // Unexpected packet type?
  if (AReceivedPacket.PacketType <> ptAck) then
  begin
    FLastError := ZFM_ERROR_BADPACKET;
    RaiseError();
  end  //of begin
  else
    FLastError := AReceivedPacket.PacketPayload[0];

  Result := (FLastError = ZFM_SUCCESS);
end;

procedure TZfmSensor.ClearDatabase();
begin
  WritePacket(TZfmPacket.Create(ZFM_CLEARDATABASE));

  if not CheckResponse(ReadPacket()) then
    RaiseError();
end;

function TZfmSensor.CompareCharacteristics(): Word;
var
  ReceivedPacket: TZfmPacket;

begin
  WritePacket(TZfmPacket.Create(ZFM_COMPARECHARACTERISTICS));
  ReceivedPacket := ReadPacket();

  if not CheckResponse(ReceivedPacket) then
    // Do not raise exception when finger does not match!
    RaiseError(ZFM_ERROR_NOTMATCHING);

  // Finger does not match so accuracy is 0
  // Note: Sensor returns 1
  if (FLastError = ZFM_ERROR_NOTMATCHING) then
    Exit(0);

  // Retrieve the accuracy score
  with ReceivedPacket do
    Result := PacketPayload[1] shl 8 or PacketPayload[2];
end;

procedure TZfmSensor.Connect(const APort: string; ABaudRate: TBaudRate = br57600);
begin
  FSerial.BaudRate := ABaudRate;

  if not FSerial.OpenPort(APort) then
    raise ESerialException.Create('Fingerprint sensor could not be found on "'+ APort +'"!');

  if not VerifyPassword() then
    RaiseError();
end;

procedure TZfmSensor.Connect(const APort: string; ABaudRate: Integer);
begin
  Connect(APort, FSerial.BaudRate.FromBaudRate(ABaudRate));
end;

function TZfmSensor.Connected(): Boolean;
begin
  Result := FSerial.IsOpened();
end;

procedure TZfmSensor.ConvertImage(ADestination: TZfmCharBuffer);
var
  Packet: TZfmPacket;

begin
  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, 2);

  // Set up packet
  with Packet do
  begin
    PacketPayload[0] := ZFM_CONVERTIMAGE;
    PacketPayload[1] := Ord(ADestination);
  end;  //of with

  WritePacket(Packet);

  if not CheckResponse(ReadPacket()) then
    RaiseError();
end;

procedure TZfmSensor.CreateTemplate();
begin
  WritePacket(TZfmPacket.Create(ZFM_CREATETEMPLATE));

  if not CheckResponse(ReadPacket()) then
    RaiseError();
end;

procedure TZfmSensor.DeleteTemplate(AIndex: Word);
begin
  DeleteTemplate(AIndex, 1);
end;

procedure TZfmSensor.DeleteTemplate(AStartIndex, ACount: Word);
var
  Packet: TZfmPacket;

begin
  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, 5);

  // Set up packet
  with Packet do
  begin
    PacketPayload[0] := ZFM_DELETETEMPLATE;
    PacketPayload[1] := Hi(AStartIndex);
    PacketPayload[2] := Lo(AStartIndex);
    PacketPayload[3] := Hi(ACount);
    PacketPayload[4] := Lo(ACount);
  end;  //of with

  WritePacket(Packet);

  if not CheckResponse(ReadPacket()) then
    RaiseError();
end;

procedure TZfmSensor.DoNotifyOnFinish();
begin
  if Assigned(FOnFinish) then
    FOnFinish(Self);
end;

procedure TZfmSensor.DoNotifyOnStart();
begin
  if Assigned(FOnStart) then
    FOnStart(Self);
end;

function TZfmSensor.DownloadCharacteristics(ACharBuffer: TZfmCharBuffer): TZfmCharacteristics;
var
  Packet, ReceivedPacket: TZfmPacket;
  Index: Integer;
  Cancel: Boolean;

begin
  Cancel := False;
  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, 2);

  // Set up packet
  with Packet do
  begin
    PacketPayload[0] := ZFM_DOWNLOADCHARACTERISTICS;
    PacketPayload[1] := Ord(ACharBuffer);
  end;  //of with

  WritePacket(Packet);
  ReceivedPacket := ReadPacket();

  if not CheckResponse(ReceivedPacket) then
    RaiseError();

  DoNotifyOnStart();
  Index := 0;

  // Get follow-up data packets until the end data packet is received
  repeat
    ReceivedPacket := ReadPacket();
    Move(ReceivedPacket.PacketPayload[0], Result[Index], Length(ReceivedPacket.PacketPayload));
    Inc(Index, Length(ReceivedPacket.PacketPayload));

    // Notify progress
    if Assigned(FOnProgress) then
    begin
      FOnProgress(Self, Index, ZFM_CHARACTERISTICS_COUNT, Cancel);

      if Cancel then
      begin
        FSerial.Purge();
        Exit;
      end;  //of begin
    end;  //of begin
  until (ReceivedPacket.PacketType = ptEndData);

  DoNotifyOnFinish();
end;

function TZfmSensor.DownloadImage(ABitmap: TBitmap): Boolean;
var
  x, y: Integer;
  ColorByte, PixelData: Byte;
  ImageBuffer: TMemoryStream;
  ColorBytePtr: PByte;
  ReceivedPacket: TZfmPacket;
  Cancel: Boolean;
  Progress,
  TotalProgress: Cardinal;
  Row: PRGBQuad;

begin
  Assert(Assigned(ABitmap), 'Invalid bitmap!');
  Result := False;
  Cancel := False;
  ImageBuffer := TMemoryStream.Create;

  try
    WritePacket(TZfmPacket.Create(ZFM_DOWNLOADIMAGE));
    ReceivedPacket := ReadPacket();

    if not CheckResponse(ReceivedPacket) then
      RaiseError();

    // Progress indication
    DoNotifyOnStart();
    Progress := 0;
    TotalProgress := (ZFM_FINGERPRINT_IMAGE_HEIGHT * ZFM_FINGERPRINT_IMAGE_WIDTH) div 2;

    // Get follow-up data packets until the end data packet is received
    repeat
      ReceivedPacket := ReadPacket();
      ImageBuffer.Write(ReceivedPacket.PacketPayload[0], Length(ReceivedPacket.PacketPayload));

      // Notify progress
      if Assigned(FOnProgress) then
      begin
        Inc(Progress, Length(ReceivedPacket.PacketPayload));
        FOnProgress(Self, Progress, TotalProgress, Cancel);

        if Cancel then
        begin
          FSerial.Purge();
          Exit;
        end;  //of begin
      end;  //of begin
    until (ReceivedPacket.PacketType = ptEndData);

    ColorByte := 0;
    ColorBytePtr := ImageBuffer.Memory;
    ABitmap.Canvas.Lock();

    // Setup bitmap
    with ABitmap do
    begin
      SetSize(ZFM_FINGERPRINT_IMAGE_WIDTH, ZFM_FINGERPRINT_IMAGE_HEIGHT);
      PixelFormat := pf32bit;
    end;  //of begin

    // Draw fingerprint image
    for y := 0 to ABitmap.Height - 1 do
    begin
      Row := ABitmap.ScanLine[y];

      for x := 0 to ABitmap.Width - 1 do
      begin
        // 1 byte contains 2 pixels
        if not Odd(x) then
        begin
          ColorByte := ColorBytePtr^;
          PixelData := ColorByte and $F0;
        end  //of begin
        else
        begin
          PixelData := (ColorByte and $0F) shl 4;
          Inc(ColorBytePtr);
        end;  //of if

        // Grey-scale bitmap
        Row^.rgbBlue := PixelData;
        Row^.rgbGreen := PixelData;
        Row^.rgbRed := PixelData;
        Row^.rgbReserved := 0;
        Inc(Row);
      end;  //of for
    end;  //of for

    Result := True;

  finally
    ABitmap.Canvas.Unlock();
    ImageBuffer.Free;
    DoNotifyOnFinish();
  end;  //of try
end;

function TZfmSensor.DownloadImage(const AFileName: TFileName): Boolean;
var
  Image: TBitmap;

begin
  Image := TBitmap.Create;

  try
    Result := DownloadImage(Image);

    // Download was not canceled?
    if Result then
      Image.SaveToFile(ChangeFileExt(string(AFileName), string('.bmp')));

  finally
    Image.Free;
  end;  //of try
end;

function TZfmSensor.GenerateRandomNumber(): UInt32;
var
  ReceivedPacket: TZfmPacket;

begin
  Result := 0;
  WritePacket(TZfmPacket.Create(ZFM_GENERATERANDOMNUMBER));
  ReceivedPacket := ReadPacket();

  if not CheckResponse(ReceivedPacket) then
    RaiseError();

  with ReceivedPacket do
  begin
    Result := Result or PacketPayload[1] shl 24;
    Result := Result or PacketPayload[2] shl 16;
    Result := Result or PacketPayload[3] shl 8;
    Result := Result or PacketPayload[4];
  end;  //of with
end;

function TZfmSensor.GetBaudRate(): TBaudRate;
begin
  Result := FSerial.BaudRate;
end;

function TZfmSensor.GetSerialPort(): string;
begin
  Result := FSerial.Port;
end;

function TZfmSensor.GetLastErrorMessage(): string;
begin
  case FLastError of
    ZFM_SUCCESS:                       Result := '';
    ZFM_ERROR_COMMUNICATION:           Result := 'Communication error';
    ZFM_ERROR_WRONGPASSWORD:           Result := 'The password is wrong';
    ZFM_ERROR_INVALIDREGISTER:         Result := 'Invalid register number';
    ZFM_ERROR_NOFINGER:                Result := 'No finger on the sensor';
    ZFM_ERROR_READIMAGE:               Result := 'Error while reading image';
    ZFM_ERROR_MESSYIMAGE:              Result := 'Messy image';
    ZFM_ERROR_FEWFEATUREPOINTS:        Result := 'Failed to generate character file due to lackness of character point or over-smallness of fingerprint image';
    ZFM_ERROR_INVALIDIMAGE:            Result := 'Invalid image';
    ZFM_ERROR_CHARACTERISTICSMISMATCH: Result := 'Characteristics mismatch';
    ZFM_ERROR_INVALIDPOSITION:         Result := 'Invalid position';
    ZFM_ERROR_FLASH:                   Result := 'Error while reading or writing flash';
    ZFM_ERROR_NOTEMPLATEFOUND:         Result := 'No template found';
    ZFM_ERROR_LOADTEMPLATE:            Result := 'Error while loading template';
    ZFM_ERROR_DELETETEMPLATE:          Result := 'Error while deleting template';
    ZFM_ERROR_CLEARDATABASE:           Result := 'Error while clearing template database';
    ZFM_ERROR_NOTMATCHING:             Result := 'Finger does not match';
    ZFM_ERROR_DOWNLOADIMAGE:           Result := 'Error while downlading image';
    ZFM_ERROR_DOWNLOADCHARACTERISTICS: Result := 'Error while downlading characteristics';
    ZFM_ERROR_ADDRCODE:                Result := 'The address is wrong';
    ZFM_ERROR_PASSVERIFY:              Result := 'The password must be verified first';
    ZFM_ERROR_PACKETRESPONSEFAIL:      Result := 'Packet response failed';
    ZFM_ERROR_TIMEOUT:                 Result := 'Timeout limit exceeded';
    ZFM_ERROR_BADPACKET:               Result := 'Bad packet';
    else                               Result := Format('Unknown error %d', [FLastError]);
  end;  //of case
end;

function TZfmSensor.GetPacketLength(): TZfmPacketLength;
begin
  Result := TZfmPacketLength(GetSystemParameters().PacketLength);
end;

function TZfmSensor.GetSecurityLevel(): TZfmSecurityLevel;
begin
  Result := TZfmSecurityLevel(GetSystemParameters().SecurityLevel);
end;

function TZfmSensor.GetSystemId(): Word;
begin
  Result := GetSystemParameters().SystemID;
end;

function TZfmSensor.GetStorageCapacity(): Word;
begin
  Result := GetSystemParameters().StorageCapacity;
end;

function TZfmSensor.GetSystemParameters(): TZfmSystemParameters;
var
  ReceivedPacket: TZfmPacket;

begin
  WritePacket(TZfmPacket.Create(ZFM_GETSYSTEMPARAMETERS));
  ReceivedPacket := ReadPacket();

  if not CheckResponse(ReceivedPacket) then
    RaiseError;

  with ReceivedPacket do
  begin
    Result.StatusRegister := PacketPayload[1] shl 8 or PacketPayload[2];
    Result.SystemID := PacketPayload[3] shl 8 or PacketPayload[4];
    Result.StorageCapacity := PacketPayload[5] shl 8 or PacketPayload[6];
    Result.SecurityLevel := PacketPayload[7] shl 8 or PacketPayload[8];
    Result.DeviceAddress := PacketPayload[9] shl 24 or PacketPayload[10] shl 16 or PacketPayload[11] shl 8 or PacketPayload[12];
    Result.PacketLength := PacketPayload[13] shl 8 or PacketPayload[14];
    Result.BaudRate := PacketPayload[15] shl 8 or PacketPayload[16];
  end;  //of begin
end;

function TZfmSensor.GetTemplateCount(): Word;
var
  ReceivedPacket: TZfmPacket;

begin
  WritePacket(TZfmPacket.Create(ZFM_TEMPLATECOUNT));
  ReceivedPacket := ReadPacket();

  if not CheckResponse(ReceivedPacket) then
    RaiseError;

  with ReceivedPacket do
    Result := PacketPayload[1] shl 8 or PacketPayload[2];
end;

function TZfmSensor.GetTemplateIndex(APage: TZfmTemplatePage): TZfmTemplateIndex;
var
  Packet, ReceivedPacket: TZfmPacket;
  i, b: Byte;
  Index: Word;

begin
  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, 2);

  // Set up packet
  with Packet do
  begin
    PacketPayload[0] := ZFM_TEMPLATEINDEX;
    PacketPayload[1] := Ord(APage);
  end;  //of with

  WritePacket(Packet);
  ReceivedPacket := ReadPacket();

  if not CheckResponse(ReceivedPacket) then
    RaiseError();

  SetLength(Result, High(ReceivedPacket.PacketPayload) * 8);
  Index := 0;

  // Skip the status (first byte)
  for i := 1 to High(ReceivedPacket.PacketPayload) do
    for b := 0 to 7 do
    begin
      Result[Index] := ((ReceivedPacket.PacketPayload[i] and (1 shl b)) > 0);
      Inc(Index);
    end;  //of for
end;

procedure TZfmSensor.LoadTemplate(AIndex: Word; ACharBuffer: TZfmCharBuffer = cbOne);
var
  Packet: TZfmPacket;

begin
  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, 4);

  // Set up packet
  with Packet do
  begin
    PacketPayload[0] := ZFM_LOADTEMPLATE;
    PacketPayload[1] := Ord(ACharBuffer);
    PacketPayload[2] := Hi(AIndex);
    PacketPayload[3] := Lo(AIndex);
  end;  //of with

  WritePacket(Packet);

  if not CheckResponse(ReadPacket()) then
    RaiseError();
end;

procedure TZfmSensor.RaiseError(AExpectedError: Byte = ZFM_SUCCESS);
begin
  if (FLastError <> AExpectedError) then
    raise EZfmException.Create(GetLastErrorMessage()) {$IFNDEF FPC}at ReturnAddress{$ENDIF};
end;

function TZfmSensor.ReadImage(): Boolean;
begin
  WritePacket(TZfmPacket.Create(ZFM_READIMAGE));
  Result := CheckResponse(ReadPacket());
end;

function TZfmSensor.ReadNotepad(APage: TZfmNotepadPage): TZfmNotepadData;
var
  Packet, ReceivedPacket: TZfmPacket;

begin
  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, Length(Result) + 2);

  with Packet do
  begin
    PacketPayload[0] := ZFM_READNOTEPAD;
    PacketPayload[1] := APage;
  end;  //of with

  WritePacket(Packet);
  ReceivedPacket := ReadPacket();

  if not CheckResponse(ReceivedPacket) then
    RaiseError();

  Move(ReceivedPacket.PacketPayload[1], Result[0], Length(Result));
end;

function TZfmSensor.ReadPacket(): TZfmPacket;
var
  ReceivedPacketData: TBytes;
  PacketPayloadLength, PacketChecksum, ReceivedPacketChecksum, i: Word;
  LastPacketIndex: Word;
  PacketType: Byte;

  function ReadPacketData(ABytesToRead: Word): TBytes;
  var
    Timeout: Byte;

  begin
    Timeout := FTimeout;

    // Packet data not completely received?
    while not FSerial.CanRead(FSerial.Timeout, ABytesToRead) do
    begin
      // Timeout exceeded?
      if (Timeout = 0) then
      begin
        FLastError := ZFM_ERROR_TIMEOUT;
        raise EZfmException.Create(GetLastErrorMessage());
      end;  //of begin

      Dec(Timeout);
      Sleep(SERIAL_SLEEP);
    end;  //of while

    Result := FSerial.Read(ABytesToRead);
  end;

begin
  Result.PacketType := ptCmd;

  // Receive packet Header
  ReceivedPacketData := ReadPacketData(ZFM_PACKET_HEADER_SIZE);

  // Invalid header?
  if ((ReceivedPacketData[0] <> Hi(ZFM_STARTCODE)) or
    (ReceivedPacketData[1] <> Lo(ZFM_STARTCODE))) then
  begin
    FLastError := ZFM_ERROR_BADPACKET;
    raise EZfmException.Create('The received packet header is invalid!');
  end;  //of begin

  // Calculate packet payload length (combine the 2 length bytes)
  PacketPayloadLength := ReceivedPacketData[7] shl 8;
  PacketPayloadLength := PacketPayloadLength or ReceivedPacketData[8];
  SetLength(Result.PacketPayload, PacketPayloadLength - SizeOf(PacketChecksum));
  LastPacketIndex := 8 + PacketPayloadLength;

  // Packet type
  PacketType := ReceivedPacketData[6];

  case PacketType of
    ZFM_DATAPACKET:    Result.PacketType := ptData;
    ZFM_ACKPACKET:     Result.PacketType := ptAck;
    ZFM_ENDDATAPACKET: Result.PacketType := ptEndData;
  end;  //of case

  // Receive packet payload
  SetLength(ReceivedPacketData, ZFM_PACKET_HEADER_SIZE + Length(Result.PacketPayload));
  Move(ReadPacketData(Length(Result.PacketPayload))[0], ReceivedPacketData[ZFM_PACKET_HEADER_SIZE], Length(Result.PacketPayload));

  // Start with packet checksum calculation
  PacketChecksum := PacketType + ReceivedPacketData[7] + ReceivedPacketData[8];

  for i := Low(Result.PacketPayload) to High(Result.PacketPayload) do
  begin
    // Collect packet payload
    Result.PacketPayload[i] := ReceivedPacketData[9 + i];

    // Calculate packet checksum
    Inc(PacketChecksum, Result.PacketPayload[i]);
  end;  //of for

  // Received checksum of the packet (last two bytes)
  ReceivedPacketChecksum := ReceivedPacketData[LastPacketIndex - 1] shl 8;
  ReceivedPacketChecksum := ReceivedPacketChecksum or ReceivedPacketData[LastPacketIndex];

  // Checksums do not match?
  if (ReceivedPacketChecksum <> PacketChecksum) then
  begin
    FLastError := ZFM_ERROR_BADPACKET;
    raise EZfmException.Create('The received packet is corrupted (the checksum is wrong)!');
  end;  //of begin
end;

function TZfmSensor.SearchTemplate(
  ACharBuffer: TZfmCharBuffer): TZfmTemplateSearchResult;
begin
  Result := SearchTemplate(ACharBuffer, 0, GetStorageCapacity());
end;

function TZfmSensor.SearchTemplate(ACharBuffer: TZfmCharBuffer;
  AStartIndex, ACount: Word): TZfmTemplateSearchResult;
var
  Packet, ReceivedPacket: TZfmPacket;

begin
  with Result do
  begin
    TemplateIndex := -1;
    Accuracy := 0;
  end;  //of with

  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, 6);

  // Set up packet
  with Packet do
  begin
    PacketPayload[0] := ZFM_SEARCHTEMPLATE;
    PacketPayload[1] := Ord(ACharBuffer);
    PacketPayload[2] := Hi(AStartIndex);
    PacketPayload[3] := Lo(AStartIndex);
    PacketPayload[4] := Hi(ACount);
    PacketPayload[5] := Lo(ACount);
  end;  //of with

  WritePacket(Packet);
  ReceivedPacket := ReadPacket();

  if not CheckResponse(ReceivedPacket) then
  begin
    // Do not raise exception when no template was found
    RaiseError(ZFM_ERROR_NOTEMPLATEFOUND);
    Exit;
  end; // of begin

  // Read the found index with the correspondending accuracy score
  with ReceivedPacket do
  begin
    Result.TemplateIndex := PacketPayload[1] shl 8 or PacketPayload[2];
    Result.Accuracy := PacketPayload[3] shl 8 or PacketPayload[4];
  end;  //of with
end;

procedure TZfmSensor.SetAddress(const ANewAddress: UInt32);
var
  Packet: TZfmPacket;

begin
  if (FAddress = ANewAddress) then
    Exit;

  if not Connected() then
  begin
    FAddress := ANewAddress;
    Exit;
  end;  //of begin

  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, 5);

  // Set up packet
  with Packet do
  begin
    PacketPayload[0] := ZFM_SETADDRESS;
    PacketPayload[1] := ANewAddress shr 24 and $FF;
    PacketPayload[2] := ANewAddress shr 16 and $FF;
    PacketPayload[3] := ANewAddress shr 8 and $FF;
    PacketPayload[4] := ANewAddress and $FF;
  end;  //of with

  WritePacket(Packet);

  if not CheckResponse(ReadPacket()) then
    RaiseError();

  FAddress := ANewAddress;
end;

procedure TZfmSensor.SetBaudRate(const ABaudRate: TBaudRate);
var
  SensorBaudRate: Cardinal;

begin
  if (FSerial.BaudRate <> ABaudRate) then
  begin
    case ABaudRate of
       br9600:   SensorBaudRate := 9600;
       br19200:  SensorBaudRate := 19200;
       br38400:  SensorBaudRate := 38400;
       br57600:  SensorBaudRate := 57600;
       br115200: SensorBaudRate := 115200;
       else      raise EZfmException.Create('Unsupported baudrate!');
    end;  //of case

    SetSystemParameter(4, SensorBaudRate div 9600);
    FSerial.BaudRate := ABaudRate;
  end;  //of begin
end;

procedure TZfmSensor.SetPacketLength(const APacketLength: TZfmPacketLength);
begin
  SetSystemParameter(6, Ord(APacketLength));
end;

procedure TZfmSensor.SetPassword(const ANewPassword: UInt32);
var
  Packet: TZfmPacket;

begin
  if (FPassword = ANewPassword) then
    Exit;

  if not Connected() then
  begin
    FPassword := ANewPassword;
    Exit;
  end;  //of begin

  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, 5);

  // Set up packet
  with Packet do
  begin
    PacketPayload[0] := ZFM_SETPASSWORD;
    PacketPayload[1] := ANewPassword shr 24 and $FF;
    PacketPayload[2] := ANewPassword shr 16 and $FF;
    PacketPayload[3] := ANewPassword shr 8 and $FF;
    PacketPayload[4] := ANewPassword and $FF;
  end;  //of with

  WritePacket(Packet);

  if not CheckResponse(ReadPacket()) then
    RaiseError();

  FPassword := ANewPassword;
end;

procedure TZfmSensor.SetSecurityLevel(const ASecurityLevel: TZfmSecurityLevel);
begin
  SetSystemParameter(5, Ord(ASecurityLevel));
end;

procedure TZfmSensor.SetSystemParameter(const AParameterNumber, AParameterValue: Byte);
var
  Packet: TZfmPacket;

begin
  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, 3);

  // Set up packet
  with Packet do
  begin
    PacketPayload[0] := ZFM_SETSYSTEMPARAMETER;
    PacketPayload[1] := AParameterNumber;
    PacketPayload[2] := AParameterValue;
  end;  //of with

  WritePacket(Packet);

  if not CheckResponse(ReadPacket()) then
    RaiseError();
end;

function TZfmSensor.StoreTemplate(ACharBuffer: TZfmCharBuffer = cbOne): Word;
var
  Page: TZfmTemplatePage;
  Indices: TZfmTemplateIndex;
  i, Index: Integer;

begin
  Index := -1;

  // Search for the next free index
  for Page := Low(TZfmTemplatePage) to High(TZfmTemplatePage) do
  begin
    if (Index <> -1) then
      Break;

    Indices := GetTemplateIndex(Page);

    for i := Low(Indices) to High(Indices) do
      // Index not in use?
      if not Indices[i] then
      begin
        Index := i;
        Break;
      end;  //of begin
  end;  //of for

  // Sensor out of memory?
  if (Index = -1) then
  begin
    FLastError := ZFM_ERROR_INVALIDPOSITION;
    RaiseError();
  end;  //of begin

  StoreTemplate(Index, ACharBuffer);
  Result := Index;
end;

procedure TZfmSensor.StoreTemplate(AIndex: Word; ACharBuffer: TZfmCharBuffer = cbOne);
var
  Packet: TZfmPacket;

begin
  // The ZFM does not validate the index and accepts high index numbers above
  // 1000 WITHOUT an error! Those templates are not really stored on the internal
  // flash: after unplugging the sensor and plugging again they are gone. So
  // validate the index manually.
  if (AIndex >= GetStorageCapacity()) then
  begin
    FLastError := ZFM_ERROR_INVALIDPOSITION;
    RaiseError();
  end;  //of begin

  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, 4);

  // Set up packet
  with Packet do
  begin
    PacketPayload[0] := ZFM_STORETEMPLATE;
    PacketPayload[1] := Ord(ACharBuffer);
    PacketPayload[2] := Hi(AIndex);
    PacketPayload[3] := Lo(AIndex);
  end;  //of with

  WritePacket(Packet);

  if not CheckResponse(ReadPacket()) then
    RaiseError();
end;

function TZfmSensor.UploadCharacteristics(ADestination: TZfmCharBuffer;
  const ACharacteristics: TZfmCharacteristics): Boolean;
var
  PacketLength: Word;
  Packet: TZfmPacket;

begin
  // Get expected packet length
  PacketLength := GetPacketLength().NumberOfBytes();

  // Setup the command packet
  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, 2);

  // Set up packet
  with Packet do
  begin
    PacketPayload[0] := ZFM_UPLOADCHARACTERISTICS;
    PacketPayload[1] := Ord(ADestination);
  end;  //of with

  WritePacket(Packet);

  if not CheckResponse(ReadPacket()) then
    RaiseError();

  DoNotifyOnStart();
  Result := UploadData(@ACharacteristics[0], Length(ACharacteristics), PacketLength);
  DoNotifyOnFinish();
end;

function TZfmSensor.UploadData(const AData: PByte; ADataLength: Cardinal;
  APacketLength: Word): Boolean;
var
  PacketParts, i, Progress: Cardinal;
  Packet: TZfmPacket;
  Part: PByte;
  Cancel: Boolean;

begin
  Result := False;
  Cancel := False;
  Progress := 0;

  // Setup data packet
  Packet.PacketType := ptData;
  SetLength(Packet.PacketPayload, APacketLength);

  // Split up data
  PacketParts := ADataLength div APacketLength;
  Part := AData;

  // Send follow-up data packets
  for i := 1 to PacketParts do
  begin
    Move(Part^, Packet.PacketPayload[0], APacketLength);

    // Last packet
    if (i = PacketParts) then
      Packet.PacketType := ptEndData;

    WritePacket(Packet);
    Inc(Part, APacketLength);

    // Notify progress
    if Assigned(FOnProgress) then
    begin
      Inc(Progress, APacketLength);
      FOnProgress(Self, Progress, ADataLength, Cancel);

      if Cancel then
      begin
        FSerial.Purge();
        Exit;
      end;  //of begin
    end;  //of begin
  end;  //of for

  Result := True;
end;

function TZfmSensor.UploadImage(const AFingerprintImage: TBitmap): Boolean;
var
  PacketLength: Word;
  x, y: Integer;
  ColorByte, PixelData: Byte;
  ImageBuffer: TMemoryStream;
  Index: Integer;
  ImageData: TBytes;
  Row: PRGBQuad;

begin
  Assert(Assigned(AFingerprintImage), 'Invalid bitmap!');

  if ((AFingerprintImage.Width <> ZFM_FINGERPRINT_IMAGE_WIDTH) or
    (AFingerprintImage.Height <> ZFM_FINGERPRINT_IMAGE_HEIGHT)) then
    raise EZfmException.Create('Invalid image dimensions!');

  // Get expected packet length
  PacketLength := GetPacketLength().NumberOfBytes();

  // Setup the command packet
  WritePacket(TZfmPacket.Create(ZFM_UPLOADIMAGE));

  if not CheckResponse(ReadPacket()) then
    RaiseError();

  DoNotifyOnStart();
  SetLength(ImageData, AFingerprintImage.Width div 2);
  ImageBuffer := TMemoryStream.Create;
  ColorByte := 0;
  AFingerprintImage.Canvas.Lock();

  try
    // Serialize fingerprint image
    for y := 0 to AFingerprintImage.Height - 1 do
    begin
      Row := AFingerprintImage.ScanLine[y];
      Index := 0;

      for x := 0 to AFingerprintImage.Width - 1 do
      begin
        // Gray-scale bitmap: all RGB values are the same
        PixelData := Row^.rgbBlue;

        // 1 byte contains 2 pixels
        if Odd(x) then
        begin
          ColorByte := ColorByte or (PixelData shr 4);
          ImageData[Index] := ColorByte;
          Inc(Index);
        end  //of begin
        else
          ColorByte := PixelData and $F0;

        Inc(Row);
      end;  //of for

      ImageBuffer.Write(ImageData[0], Length(ImageData));
    end;  //of for

    Result := UploadData(ImageBuffer.Memory, ImageBuffer.Size, PacketLength);

  finally
    AFingerprintImage.Canvas.Unlock();
    ImageBuffer.Free;
    DoNotifyOnFinish();
  end;  //of try
end;

function TZfmSensor.UploadImage(const AFileName: TFileName): Boolean;
var
  Image: TBitmap;

begin
  Image := TBitmap.Create;

  try
    Image.LoadFromFile(AFileName);
    Result := UploadImage(Image);

  finally
    Image.Free;
  end;  //of try
end;

function TZfmSensor.VerifyPassword(): Boolean;
var
  Packet: TZfmPacket;

begin
  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, SizeOf(FPassword) + 1);

  // Set up packet
  with Packet do
  begin
    PacketPayload[0] := ZFM_VERIFYPASSWORD;
    PacketPayload[1] := FPassword shr 24 and $FF;
    PacketPayload[2] := FPassword shr 16 and $FF;
    PacketPayload[3] := FPassword shr 8 and $FF;
    PacketPayload[4] := FPassword and $FF;
  end;  //of with

  WritePacket(Packet);
  Result := CheckResponse(ReadPacket());

  if not Result then
    // Do not raise exception when password is wrong
    RaiseError(ZFM_ERROR_WRONGPASSWORD);
end;

procedure TZfmSensor.WriteNotepad(APage: TZfmNotepadPage;
  const AData: TZfmNotepadData);
var
  Packet: TZfmPacket;

begin
  Packet.PacketType := ptCmd;
  SetLength(Packet.PacketPayload, Length(AData) + 2);

  with Packet do
  begin
    PacketPayload[0] := ZFM_WRITENOTEPAD;
    PacketPayload[1] := APage;
    Move(AData[0], PacketPayload[2], Length(AData));
  end;  //of with

  WritePacket(Packet);

  if not CheckResponse(ReadPacket()) then
    RaiseError();
end;

procedure TZfmSensor.WritePacket(const AZfmPacket: TZfmPacket);
var
  Packet: TBytes;
  PacketType, i, Index: Byte;
  PacketLength, PacketChecksum: Word;

  procedure AddData(AByte: Byte);
  begin
    Packet[Index] := AByte;
    Inc(Index);
  end;

begin
  if (Length(AZfmPacket.PacketPayload) = 0) then
  begin
    FLastError := ZFM_ERROR_BADPACKET;
    raise EZfmException.Create('Packet payload must at least contain one byte!');
  end;  //of begin

  SetLength(Packet, ZFM_PACKET_HEADER_SIZE + Length(AZfmPacket.PacketPayload));
  Index := 0;

  // Packet header
  AddData(Hi(ZFM_STARTCODE));
  AddData(Lo(ZFM_STARTCODE));

  // Sensor address
  AddData(FAddress shr 24 and $FF);
  AddData(FAddress shr 16 and $FF);
  AddData(FAddress shr 8 and $FF);
  AddData(FAddress and $FF);

  // Packet type
  case AZfmPacket.PacketType of
    ptCmd:     PacketType := ZFM_COMMANDPACKET;
    ptData:    PacketType := ZFM_DATAPACKET;
    ptEndData: PacketType := ZFM_ENDDATAPACKET;
    else
    begin
      FLastError := ZFM_ERROR_BADPACKET;
      raise EZfmException.Create('An ack packet is no valid request packet!');
    end;
  end;  //of case

  AddData(PacketType);

  // The packet length = package payload (n bytes) + checksum (2 bytes)
  PacketLength := Length(AZfmPacket.PacketPayload) + SizeOf(PacketChecksum);
  AddData(Hi(PacketLength));
  AddData(Lo(PacketLength));

  // The packet checksum = packet type (1 byte) + packet length (2 bytes) + payload (n bytes)
  PacketChecksum := PacketType + PacketLength;

  for i := Low(AZfmPacket.PacketPayload) to High(AZfmPacket.PacketPayload) do
  begin
    // Add payload
    AddData(AZfmPacket.PacketPayload[i]);

    // Calculate packet checksum
    Inc(PacketChecksum, AZfmPacket.PacketPayload[i]);
  end;  //of for

  // Add packet checksum (2 bytes)
  AddData(Hi(PacketChecksum));
  AddData(Lo(PacketChecksum));

  // Send packet to sensor
  FSerial.Write(Packet);
end;

end.
