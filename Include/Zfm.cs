// *********************************************************************** //
//                                                                         //
// ZhianTec Fingerprint Module (ZFM) SDK definitions                       //
//                                                                         //
// Copyright (c) 2011-2016 Philipp Meisberger (PM Code Works)              //
//                                                                         //
// *********************************************************************** //

using System;
using System.Runtime.InteropServices;

namespace ZfmSdk
{
    /// <summary>
    ///   Possible ZFM CharBuffers
    /// </summary>
    public enum ZfmCharBuffer
    {
        /// <summary>
        ///   CharBuffer 1
        /// </summary>
        CharBuffer1 = 1,

        /// <summary>
        ///   CharBuffer 2
        /// </summary>
        CharBuffer2 = 2
    };

    public class Zfm
    {
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
        [DllImport("Zfm.dll", EntryPoint = "ZfmInitialize", CallingConvention = CallingConvention.Cdecl)]
        public static extern void Initialize(uint address = 0xFFFFFFFF, uint password = 0);

        /// <summary>
        ///   Unitializes the ZFM and frees up used resources.
        /// </summary>
        [DllImport("Zfm.dll", EntryPoint = "ZfmUnInitialize", CallingConvention = CallingConvention.Cdecl)]
        public static extern void UnInitialize();

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
        [DllImport("Zfm.dll", EntryPoint = "ZfmConnect", CallingConvention = CallingConvention.Cdecl)]
        public static extern void Connect([MarshalAs(UnmanagedType.LPWStr)]string port, uint baudrate = 57600);

        /// <summary>
        ///   Clears the complete template database.
        /// </summary>
        [DllImport("Zfm.dll", EntryPoint = "ZfmEmpty", CallingConvention = CallingConvention.Cdecl)]
        public static extern void Empty();

        /// <summary>
        ///   Compares the finger characteristics of <c>CharBuffer1</c> with
        ///   <c>CharBuffer2</c> and returns the accuracy score.
        /// </summary>
        /// <returns>
        ///   The accuracy score. If the finger does not match <c>0</c> is returned.
        /// </returns>
        [DllImport("Zfm.dll", EntryPoint = "ZfmMatch", CallingConvention = CallingConvention.Cdecl)]
        public static extern ushort Match();

        /// <summary>
        ///   Converts the image in <c>ImageBuffer</c> to finger characteristics and
        ///   stores it in specified <c>CharBuffer</c>.
        /// </summary>
        /// <param name="charBuffer">
        ///   The used <c>CharBuffer</c>.
        /// </param>
        [DllImport("Zfm.dll", EntryPoint = "ZfmImage2Tz", CallingConvention = CallingConvention.Cdecl)]
        public static extern void Image2Tz(ZfmCharBuffer charBuffer);

        /// <summary>
        ///   Combines the characteristics which are stored in <c>CharBuffer1</c> and
        ///   <c>CharBuffer2</c> to a template. The created template will be stored again
        ///   in <c>CharBuffer1</c> and <c>CharBuffer2</c> as the same.
        /// </summary>
        [DllImport("Zfm.dll", EntryPoint = "ZfmRegModel", CallingConvention = CallingConvention.Cdecl)]
        public static extern void RegModel();

        /// <summary>
        ///   Deletes a range of templates from the fingerprint database.
        /// </summary>
        /// <param name="startIndex">
        ///   The index of the template where the deletion should start.
        /// </param>
        /// <param name="count">
        ///   The number of templates to be deleted.
        /// </param>
        [DllImport("Zfm.dll", EntryPoint = "ZfmDeletChar", CallingConvention = CallingConvention.Cdecl)]
        public static extern void DeletChar(ushort startIndex, ushort count = 1);

        /// <summary>
        ///   Gets the number of stored templates.
        /// </summary>
        /// <returns>
        ///   The count.
        /// </returns>
        [DllImport("Zfm.dll", EntryPoint = "ZfmTemplateNum", CallingConvention = CallingConvention.Cdecl)]
        public static extern ushort TemplateNum();

        /// <summary>
        ///   Generates a random 32-bit decimal number.
        /// </summary>
        /// <returns>
        ///   The number.
        /// </returns>
        [DllImport("Zfm.dll", EntryPoint = "ZfmGetRandomCode", CallingConvention = CallingConvention.Cdecl)]
        public static extern uint GetRandomCode();

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
        [DllImport("Zfm.dll", EntryPoint = "ZfmReadConList", CallingConvention = CallingConvention.Cdecl)]
        public static extern bool ReadConList(byte page, byte[] list, ref uint listLength);

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
        [DllImport("Zfm.dll", EntryPoint = "ZfmLoadChar", CallingConvention = CallingConvention.Cdecl)]
        public static extern void LoadChar(ushort index, ZfmCharBuffer charBuffer);

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
        [DllImport("Zfm.dll", EntryPoint = "ZfmGenImg", CallingConvention = CallingConvention.Cdecl)]
        public static extern bool GenImg();

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
        [DllImport("Zfm.dll", EntryPoint = "ZfmSearch", CallingConvention = CallingConvention.Cdecl)]
        public static extern void Search(ZfmCharBuffer charBuffer, out short templateIndex, out ushort accuracy);

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
        [DllImport("Zfm.dll", EntryPoint = "ZfmStore", CallingConvention = CallingConvention.Cdecl)]
        public static extern void Store(ushort index, ZfmCharBuffer charBuffer);

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
        [DllImport("Zfm.dll", EntryPoint = "ZfmDownChar", CallingConvention = CallingConvention.Cdecl)]
        public static extern bool DownChar(byte destination, byte[] characteristics, uint characteristicsLength);

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
        [DllImport("Zfm.dll", EntryPoint = "ZfmUpChar", CallingConvention = CallingConvention.Cdecl)]
        public static extern bool UpChar(ZfmCharBuffer charBuffer, byte[] characteristics, ref uint characteristicsLength);

        /// <summary>
        ///   Uploads a fingerprint image to <c>ImageBuffer</c>.
        /// </summary>
        /// <param name="fileName">
        ///   The filename of the image.
        /// </param>
        /// <returns>
        ///   <c>True</c> if the upload was not canceled or <c>False</c> otherwise.
        /// </returns>
        [DllImport("Zfm.dll", EntryPoint = "ZfmDownImage", CallingConvention = CallingConvention.Cdecl)]
        public static extern bool DownImage([MarshalAs(UnmanagedType.LPWStr)]string fileName);

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
        [DllImport("Zfm.dll", EntryPoint = "ZfmUpImage", CallingConvention = CallingConvention.Cdecl)]
        public static extern bool UpImage([MarshalAs(UnmanagedType.LPWStr)]string fileName);

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
        [DllImport("Zfm.dll", EntryPoint = "ZfmReadNotepad", CallingConvention = CallingConvention.Cdecl)]
        public static extern bool ReadNotepad(byte page, byte[] data, ref byte dataLength);

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
        [DllImport("Zfm.dll", EntryPoint = "ZfmWriteNotepad", CallingConvention = CallingConvention.Cdecl)]
        public static extern bool WriteNotepad(byte page, byte[] data, byte dataLength);

        /// <summary>
        ///   Verifies password of the fingerprint sensor.
        /// </summary>
        /// <returns>
        ///   <c>True</c> if the sensor password matches or <c>False</c> otherwise.
        /// </returns>
        [DllImport("Zfm.dll", EntryPoint = "ZfmVfyPwd", CallingConvention = CallingConvention.Cdecl)]
        public static extern bool VfyPwd();

        /// <summary>
        ///   Sets the sensor password.
        /// </summary>
        [DllImport("Zfm.dll", EntryPoint = "ZfmSetAddr", CallingConvention = CallingConvention.Cdecl)]
        public static extern void SetAddr(uint newAddress);

        /// <summary>
        ///   Sets the sensor address.
        /// </summary>
        [DllImport("Zfm.dll", EntryPoint = "ZfmSetPwd", CallingConvention = CallingConvention.Cdecl)]
        public static extern void SetPwd(uint newPassword);

        /// <summary>
        ///   Gets the last error code.
        /// </summary>
        /// <returns>
        ///   The last error.
        /// </returns>
        [DllImport("Zfm.dll", EntryPoint = "ZfmGetLastError", CallingConvention = CallingConvention.Cdecl)]
        public static extern byte GetLastError();
    }
}
