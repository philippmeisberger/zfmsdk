{ *********************************************************************** }
{                                                                         }
{ ZhianTec Fingerprint Module (ZFM) SDK definitions                       }
{                                                                         }
{ Copyright (c) 2011-2016 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit Zfm;

{$IFDEF FPC}{$mode delphiunicode}{$ENDIF}

interface

type
  /// <summary>
  ///   Possible ZFM CharBuffers
  /// </summary>
  TZfmCharBuffer = (
    /// <summary>
    ///   CharBuffer 1
    /// </summary>
    CharBuffer1 = 1,

    /// <summary>
    ///   CharBuffer 2
    /// </summary>
    CharBuffer2 = 2
  );

/// <summary>
///   Initializes the ZFM.
/// </summary>
/// <param name="AAddress">
///   Optional: The sensor address.
/// </param>
/// <param name="APassword">
///   Optional: The sensor password.
/// </param>
/// <remarks>
///   Only call ONCE!
/// </remarks>
procedure ZfmInitialize(AAddress: UInt32 = $FFFFFFFF; APassword: UInt32 = 0); cdecl;

/// <summary>
///   Unitializes the ZFM and frees up used resources.
/// </summary>
procedure ZfmUnInitialize(); cdecl;

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
procedure ZfmConnect(APort: PChar; ABaudrate: UInt32 = 57600); cdecl;

/// <summary>
///   Clears the complete template database.
/// </summary>
procedure ZfmEmpty(); cdecl;

/// <summary>
///   Compares the finger characteristics of <c>CharBuffer1</c> with
///   <c>CharBuffer2</c> and returns the accuracy score.
/// </summary>
/// <returns>
///   The accuracy score. If the finger does not match <c>0</c> is returned.
/// </returns>
function ZfmMatch(): Word; cdecl;

/// <summary>
///   Converts the image in <c>ImageBuffer</c> to finger characteristics and
///   stores it in specified <c>CharBuffer</c>.
/// </summary>
/// <param name="ACharBuffer">
///   The used <c>CharBuffer</c>. Can be <c>ZFM_CHARBUFFER1</c> or <c>ZFM_CHARBUFFER2</c>.
/// </param>
procedure ZfmImage2Tz(ACharBuffer: TZfmCharBuffer); cdecl;

/// <summary>
///   Combines the characteristics which are stored in <c>CharBuffer1</c> and
///   <c>CharBuffer2</c> to a template. The created template will be stored again
///   in <c>CharBuffer1</c> and <c>CharBuffer2</c> as the same.
/// </summary>
procedure ZfmRegModel(); cdecl;

/// <summary>
///   Deletes a range of templates from the fingerprint database.
/// </summary>
/// <param name="AStartIndex">
///   The index of the template where the deletion should start.
/// </param>
/// <param name="ACount">
///   The number of templates to be deleted.
/// </param>
procedure ZfmDeletChar(AStartIndex: Word; ACount: Word = 1); cdecl;

/// <summary>
///   Gets the number of stored templates.
/// </summary>
/// <returns>
///   The count.
/// </returns>
function ZfmTemplateNum(): Word; cdecl;

/// <summary>
///   Generates a random 32-bit decimal number.
/// </summary>
/// <returns>
///   The number.
/// </returns>
function ZfmGetRandomCode(): UInt32; cdecl;

/// <summary>
///   Gets a list of the template positions with usage indicator.
/// </summary>
/// <param name="APage">
///   The template page.
/// </param>
/// <param name="AList">
///   A boolean array: If the value at a position is <c>True</c> this position
///   is used and contains a template otherwise the position is not used.
///   NOTE: Can be <c>NULL</c> to determine the required size in bytes.
///   The return value of the function will be <c>False</c> and <c>AListLength</c>
///   will contain the required size for the buffer.
/// </param>
/// <returns>
///   <c>True</c> if the list was successfully downloaded or <c>False</c> otherwise.
/// </returns>
function ZfmReadConList(APage: Byte; AList: PByte; var AListLength: UInt32): Boolean; cdecl;

/// <summary>
///   Loads an existing template specified by position number to specified
///   <c>CharBuffer</c>.
/// </summary>
/// <param name="AIndex">
///   The index of the template that should be loaded.
/// </param>
/// <param name="ACharBuffer">
///   The used <c>CharBuffer</c>.
/// </param>
procedure ZfmLoadChar(AIndex: Word; ACharBuffer: TZfmCharBuffer); cdecl;

/// <summary>
///   Reads the image of a finger and stores it in <c>ImageBuffer</c>.
/// </summary>
/// <returns>
///   <c>True</c> if a finger was on the sensor and an image was successfully
///   stored in <c>ImageBuffer</c> or <c>False</c> if no finger was found.
/// </returns>
/// <remarks>
///   This is the main method of the sensor. If the read image should be
///   stored on the sensor the method <see cref="ZfmRegModel"/> must be called.
/// </remarks>
function ZfmGenImg(): Boolean; cdecl;

/// <summary>
///   Searches the finger characteristics from given <c>CharBuffer</c> in
///   database.
/// </summary>
/// <param name="ACharBuffer">
///   The used <c>CharBuffer</c>.
/// </param>
/// <param name="ATemplateIndex">
///   Contains the found template index. <c>-1</c> if not found.
/// </param>
/// <param name="AAccuracy">
///   Contains the corresponding accuracy score of the found template. <c>0</c>
///   if not found.
/// </param>
procedure ZfmSearch(ACharBuffer: TZfmCharBuffer; out ATemplateIndex: SmallInt;
  out AAccuracy: Word); cdecl;

/// <summary>
///   Stores a template from the specified <c>CharBuffer</c> at the given
///   index.
/// </summary>
/// <param name="AIndex">
///   The index position to store the template at.
/// </param>
/// <param name="ACharBuffer">
///   The used <c>CharBuffer</c>.
/// </param>
/// <remarks>
///   If a template already exists at the given index it will be overwritten!
/// </remarks>
procedure ZfmStore(AIndex: Word; ACharBuffer: TZfmCharBuffer); cdecl;

/// <summary>
///   Uploads finger characteristics to specified <c>CharBuffer</c>.
/// </summary>
/// <param name="ADestination">
///   The destination <c>CharBuffer</c>.
/// </param>
/// <param name="ACharacteristics">
///   The fingerprint characteristics.
/// </param>
/// <param name="ACharacteristicsLength">
///   The length of the characteristics in bytes.
/// </param>
/// <returns>
///   <c>True</c> if the upload was successful or <c>False</c> otherwise.
/// </returns>
function ZfmDownChar(ADestination: Byte; ACharacteristics: PByte;
  ACharacteristicsLength: UInt32): Boolean; cdecl;

/// <summary>
///   Downloads the finger characteristics from specified <c>CharBuffer</c>.
/// </summary>
/// <param name="ACharBuffer">
///   The used <c>CharBuffer</c>.
/// </param>
/// <param name="ACharacteristics">
///   Contains the fingerprint characteristics.
///   NOTE: Can be <c>NULL</c> to determine the required size in bytes.
///   The return value of the function will be <c>False</c> and
///   <c>ACharacteristicsLength</c> will contain the required size for the buffer.
/// </param>
/// <param name="ACharacteristicsLength">
///   The length of the characteristics in bytes.
/// </param>
/// <returns>
///   <c>True</c> if the download was successful or <c>False</c> otherwise.
/// </returns>
function ZfmUpChar(ACharBuffer: TZfmCharBuffer; ACharacteristics: PByte;
  var ACharacteristicsLength: UInt32): Boolean; cdecl;

/// <summary>
///   Uploads a fingerprint image to <c>ImageBuffer</c>.
/// </summary>
/// <param name="AFileName">
///   The filename of the image.
/// </param>
/// <returns>
///   <c>True</c> if the upload was not canceled or <c>False</c> otherwise.
/// </returns>
function ZfmDownImage(AFileName: PChar): Boolean; cdecl;

/// <summary>
///   Downloads the image of a finger in <c>ImageBuffer</c> to host computer
///   and stores it as bitmap file.
/// </summary>
/// <param name="AFileName">
///   The filename of the image.
/// </param>
/// <returns>
///   <c>True</c> if the download was successful or <c>False</c> otherwise.
/// </returns>
function ZfmUpImage(AFileName: PChar): Boolean; cdecl;

/// <summary>
///   Reads data from a given ZFM notepad page.
/// </summary>
/// <param name="APage">
///   The ZFM notepad page. Must be value between 0 and 15 otherwise the
///   function fails.
/// </param>
/// <param name="AData">
///   Contains the 32 byte ZFM notepad data.
///   NOTE: Can be <c>NULL</c> to determine the required size in bytes.
///   The return value of the function will be <c>False</c> and
///   <c>ADataLength</c> will contain the required size for the buffer.
/// </param>
/// <param name="ADataLength">
///   The length of the data in bytes.
/// </param>
/// <returns>
///   <c>True</c> if the notepad was successful read or <c>False</c> otherwise.
/// </returns>
function ZfmReadNotepad(APage: Byte; AData: PByte; var ADataLength: Byte): Boolean; cdecl;

/// <summary>
///   Writes specified data to a given ZFM notepad page.
/// </summary>
/// <param name="APage">
///   The ZFM notepad page. Must be value between 0 and 15 otherwise the
///   function fails.
/// </param>
/// <param name="AData">
///   The specified data.
/// </param>
/// <param name="ADataLength">
///   The length of the specified data in bytes.
/// </param>
/// <returns>
///   <c>True</c> if the notepad was successful written or <c>False</c> otherwise.
/// </returns>
function ZfmWriteNotepad(APage: Byte; AData: PByte; ADataLength: Byte): Boolean; cdecl;

/// <summary>
///   Verifies password of the fingerprint sensor.
/// </summary>
/// <returns>
///   <c>True</c> if the sensor password matches or <c>False</c> otherwise.
/// </returns>
function ZfmVfyPwd(): Boolean; cdecl;

/// <summary>
///   Sets the sensor password.
/// </summary>
procedure ZfmSetAddr(const ANewAddress: UInt32); cdecl;

/// <summary>
///   Sets the sensor address.
/// </summary>
procedure ZfmSetPwd(const ANewPassword: UInt32); cdecl;

/// <summary>
///   Gets the last error code.
/// </summary>
/// <returns>
///   The last error.
/// </returns>
function ZfmGetLastError(): Byte; cdecl;

implementation

const
  ZfmLib = {$IFDEF MSWINDOWS}'Zfm.dll'{$ELSE}'libzfm.so'{$ENDIF};

procedure ZfmInitialize; external ZfmLib name 'ZfmInitialize';
procedure ZfmUnInitialize; external ZfmLib name 'ZfmUnInitialize';
procedure ZfmConnect; external ZfmLib name 'ZfmConnect';
procedure ZfmEmpty; external ZfmLib name 'ZfmEmpty';
function ZfmMatch; external ZfmLib name 'ZfmMatch';
procedure ZfmImage2Tz; external ZfmLib name 'ZfmImage2Tz';
procedure ZfmRegModel; external ZfmLib name 'ZfmRegModel';
procedure ZfmDeletChar; external ZfmLib name 'ZfmDeletChar';
function ZfmTemplateNum; external ZfmLib name 'ZfmTemplateNum';
function ZfmGetRandomCode; external ZfmLib name 'ZfmGetRandomCode';
function ZfmReadConList; external ZfmLib name 'ZfmReadConList';
procedure ZfmLoadChar; external ZfmLib name 'ZfmLoadChar';
function ZfmGenImg; external ZfmLib name 'ZfmGenImg';
procedure ZfmSearch; external ZfmLib name 'ZfmSearch';
procedure ZfmStore; external ZfmLib name 'ZfmStore';
function ZfmDownChar; external ZfmLib name 'ZfmDownChar';
function ZfmUpChar; external ZfmLib name 'ZfmUpChar';
function ZfmDownImage; external ZfmLib name 'ZfmDownImage';
function ZfmUpImage; external ZfmLib name 'ZfmUpImage';
function ZfmReadNotepad; external ZfmLib name 'ZfmReadNotepad';
function ZfmWriteNotepad; external ZfmLib name 'ZfmWriteNotepad';
function ZfmVfyPwd; external ZfmLib name 'ZfmVfyPwd';
procedure ZfmSetAddr; external ZfmLib name 'ZfmSetAddr';
procedure ZfmSetPwd; external ZfmLib name 'ZfmSetPwd';
function ZfmGetLastError; external ZfmLib name 'ZfmGetLastError';

end.
