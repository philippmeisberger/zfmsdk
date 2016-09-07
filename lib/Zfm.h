// *********************************************************************** //
//                                                                         //
// ZhianTec Fingerprint Module (ZFM) SDK definitions                       //
//                                                                         //
// Copyright (c) 2011-2016 Philipp Meisberger (PM Code Works)              //
//                                                                         //
// *********************************************************************** //

/// <summary>
///   Possible ZFM CharBuffers
/// </summary>
typedef enum
{
    /// <summary>
    ///   CharBuffer 1
    /// </summary>
    CharBuffer1 = 1,

    /// <summary>
    ///   CharBuffer 2
    /// </summary>
    CharBuffer2 = 2
} ZfmCharBuffer;

/// <summary>
///   Initializes the ZFM.
/// </summary>
/// <param name="address">
///   Optional: The sensor address.
/// </param>
/// <param name="password">
///   Optional: The sensor password.
/// </param>
/// <remarks>
///   Only call ONCE!
/// </remarks>
void ZfmInitialize(unsigned long address = 0xFFFFFFFF, unsigned long password = 0);

/// <summary>
///   Unitializes the ZFM and frees up used resources.
/// </summary>
void ZfmUnInitialize();

/// <summary>
///   Tries to establish the connection to the fingerprint sensor. If
///   successful the password is verified.
/// </summary>
/// <param name="port">
///   The used serial port.
/// </param>
/// <param name="baudRate">
///   Optional: The used baud rate.
/// </param>
/// <exception>
///   <c>EZfmException</c> when the password is wrong.
///   <c>ESerialException</c> when the port was not found.
/// </exception>
void ZfmConnect(const wchar_t *port, unsigned long baudrate = 57600);

/// <summary>
///   Clears the complete template database.
/// </summary>
void ZfmEmpty();

/// <summary>
///   Compares the finger characteristics of <c>CharBuffer1</c> with
///   <c>CharBuffer2</c> and returns the accuracy score.
/// </summary>
/// <returns>
///   The accuracy score. If the finger does not match <c>0</c> is returned.
/// </returns>
unsigned short ZfmMatch();

/// <summary>
///   Converts the image in <c>ImageBuffer</c> to finger characteristics and
///   stores it in specified <c>CharBuffer</c>.
/// </summary>
/// <param name="charBuffer">
///   The used <c>CharBuffer</c>.
/// </param>
void ZfmImage2Tz(ZfmCharBuffer charBuffer);

/// <summary>
///   Combines the characteristics which are stored in <c>CharBuffer1</c> and
///   <c>CharBuffer2</c> to a template. The created template will be stored again
///   in <c>CharBuffer1</c> and <c>CharBuffer2</c> as the same.
/// </summary>
void ZfmRegModel();

/// <summary>
///   Deletes a range of templates from the fingerprint database.
/// </summary>
/// <param name="startIndex">
///   The index of the template where the deletion should start.
/// </param>
/// <param name="count">
///   The number of templates to be deleted.
/// </param>
void ZfmDeletChar(unsigned short startIndex, unsigned short count = 1);

/// <summary>
///   Gets the number of stored templates.
/// </summary>
/// <returns>
///   The count.
/// </returns>
unsigned short ZfmTemplateNum();

/// <summary>
///   Generates a random 32-bit decimal number.
/// </summary>
/// <returns>
///   The number.
/// </returns>
unsigned long ZfmGetRandomCode();

/// <summary>
///   Gets a list of the template positions with usage indicator.
/// </summary>
/// <param name="page">
///   The template page.
/// </param>
/// <param name="list">
///   A boolean array: If the value at a position is <c>True</c> this position
///   is used and contains a template otherwise the position is not used.
///   NOTE: Can be <c>NULL</c> to determine the required size in bytes.
///   The return value of the function will be <c>False</c> and <c>listLength</c>
///   will contain the required size for the buffer.
/// </param>
/// <returns>
///   <c>True</c> if the list was successfully downloaded or <c>False</c> otherwise.
/// </returns>
bool ZfmReadConList(unsigned char page, unsigned char *list, _InOut_ unsigned long listLength);

/// <summary>
///   Loads an existing template specified by position number to specified
///   <c>CharBuffer</c>.
/// </summary>
/// <param name="index">
///   The index of the template that should be loaded.
/// </param>
/// <param name="charBuffer">
///   The used <c>CharBuffer</c>.
/// </param>
void ZfmLoadChar(unsigned short index, ZfmCharBuffer charBuffer);

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
bool ZfmGenImg();

/// <summary>
///   Searches the finger characteristics from given <c>CharBuffer</c> in
///   database.
/// </summary>
/// <param name="charBuffer">
///   The used <c>CharBuffer</c>.
/// </param>
/// <param name="templateIndex">
///   Contains the found template index. <c>-1</c> if not found.
/// </param>
/// <param name="accuracy">
///   Contains the corresponding accuracy score of the found template. <c>0</c>
///   if not found.
/// </param>
void ZfmSearch(ZfmCharBuffer charBuffer, _Out_ short templateIndex,
  _Out_ unsigned short accuracy);

/// <summary>
///   Stores a template from the specified <c>CharBuffer</c> at the given
///   index.
/// </summary>
/// <param name="index">
///   The index position to store the template at.
/// </param>
/// <param name="charBuffer">
///   The used <c>CharBuffer</c>.
/// </param>
/// <remarks>
///   If a template already exists at the given index it will be overwritten!
/// </remarks>
void ZfmStore(unsigned short index, ZfmCharBuffer charBuffer);

/// <summary>
///   Uploads finger characteristics to specified <c>CharBuffer</c>.
/// </summary>
/// <param name="destination">
///   The destination <c>CharBuffer</c>.
/// </param>
/// <param name="characteristics">
///   The fingerprint characteristics.
/// </param>
/// <param name="characteristicsLength">
///   The length of the characteristics in bytes.
/// </param>
/// <returns>
///   <c>True</c> if the upload was successful or <c>False</c> otherwise.
/// </returns>
bool ZfmDownChar(unsigned char destination, unsigned char *characteristics,
  unsigned long characteristicsLength);

/// <summary>
///   Downloads the finger characteristics from specified <c>CharBuffer</c>.
/// </summary>
/// <param name="charBuffer">
///   The used <c>CharBuffer</c>.
/// </param>
/// <param name="characteristics">
///   Contains the fingerprint characteristics.
///   NOTE: Can be <c>NULL</c> to determine the required size in bytes.
///   The return value of the function will be <c>False</c> and
///   <c>characteristicsLength</c> will contain the required size for the buffer.
/// </param>
/// <param name="characteristicsLength">
///   The length of the characteristics in bytes.
/// </param>
/// <returns>
///   <c>True</c> if the download was successful or <c>False</c> otherwise.
/// </returns>
bool ZfmUpChar(ZfmCharBuffer charBuffer, unsigned char *characteristics,
  _Out_ unsigned long characteristicsLength);

/// <summary>
///   Uploads a fingerprint image to <c>ImageBuffer</c>.
/// </summary>
/// <param name="fileName">
///   The filename of the image.
/// </param>
/// <returns>
///   <c>True</c> if the upload was not canceled or <c>False</c> otherwise.
/// </returns>
bool ZfmDownImage(const wchar_t *fileName);

/// <summary>
///   Downloads the image of a finger in <c>ImageBuffer</c> to host computer
///   and stores it as bitmap file.
/// </summary>
/// <param name="fileName">
///   The filename of the image.
/// </param>
/// <returns>
///   <c>True</c> if the download was successful or <c>False</c> otherwise.
/// </returns>
bool ZfmUpImage(const wchar_t *fileName);

/// <summary>
///   Reads data from a given ZFM notepad page.
/// </summary>
/// <param name="page">
///   The ZFM notepad page. Must be value between 0 and 15 otherwise the
///   function fails.
/// </param>
/// <param name="data">
///   Contains the 32 byte ZFM notepad data.
///   NOTE: Can be <c>NULL</c> to determine the required size in bytes.
///   The return value of the function will be <c>False</c> and
///   <c>dataLength</c> will contain the required size for the buffer.
/// </param>
/// <param name="dataLength">
///   The length of the data in bytes.
/// </param>
/// <returns>
///   <c>True</c> if the notepad was successful read or <c>False</c> otherwise.
/// </returns>
bool ZfmReadNotepad(unsigned char page, unsigned char *data, _InOut_ unsigned char dataLength);

/// <summary>
///   Writes specified data to a given ZFM notepad page.
/// </summary>
/// <param name="page">
///   The ZFM notepad page. Must be value between 0 and 15 otherwise the
///   function fails.
/// </param>
/// <param name="data">
///   The specified data.
/// </param>
/// <param name="dataLength">
///   The length of the specified data in bytes.
/// </param>
/// <returns>
///   <c>True</c> if the notepad was successful written or <c>False</c> otherwise.
/// </returns>
bool ZfmWriteNotepad(unsigned char page, unsigned char *data, unsigned char dataLength);

/// <summary>
///   Verifies password of the fingerprint sensor.
/// </summary>
/// <returns>
///   <c>True</c> if the sensor password matches or <c>False</c> otherwise.
/// </returns>
bool ZfmVfyPwd();

/// <summary>
///   Sets the sensor password.
/// </summary>
void ZfmSetAddr(unsigned long newAddress);

/// <summary>
///   Sets the sensor address.
/// </summary>
void ZfmSetPwd(unsigned long newPassword);

/// <summary>
///   Gets the last error code.
/// </summary>
/// <returns>
///   The last error.
/// </returns>
unsigned char ZfmGetLastError();
