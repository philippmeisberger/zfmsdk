ZFM SDK
=======

ZFM SDK is a Delphi written library for using various ZhianTec Fingerprint Modules (ZFM) under Windows and Linux operating systems. It was developed and tested for ZFM-20 and ZFM-60 models.

Integration
-----------

ZFM SDK can be used out of native Delphi applications created by Rad Studio and Lazarus as a regular Delphi unit. For other compiled languages like the C family ZFM SDK can also be used as shared library (see "lib" folder). The library has to be compiled using Lazarus IDE. Just open the Zfm.lpi from the "lib" folder out of Lazarus and compile it. The library file is created in the "bin" folder. The required header files are located inside the "include" folder.

Samples
-------

There are three samples attached that should explain the usage of the project:
- The "sample" folder contains two equivalent non-graphical console applications for Lazarus and Visual Studio (C#) which use the shared library
- The "gui" folder contains a full featured graphical Lazarus application which uses the native Delphi unit

Linux setup
-----------

Add group "dialout" for each user which should be able to use the ZFM

    ~# usermod -a -G dialout <username>
    ~# reboot

Troubleshooting
---------------

When you get messages like `Fingerprint sensor could not be found` or `The recieved packet header is invalid!` there are multiple reasons for these issues:

- The sensor was not found at given port
- The USB-TTL converter is not working properly
- The data wires (TX, RX) between the sensor and the USB-TTL converter are not connected correctly
- The sensor is not compatible with the library (not a ZhianTec model?)

Of course you can try the following solution for each possibility:

- Ensure you are using the correct port (e.g. Linux uses */dev/ttyUSB0* and Windows uses *COM3*)
- Try another USB-TTL converter (the chipset CP2102 is working well)
- Exchange the data wires and use other cables
- Maybe you bought the wrong model? Try another sensor

Questions and suggestions
-------------------------

If you have any questions to this project just ask me via email:

<team@pm-codeworks.de>
