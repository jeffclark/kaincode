/**
 * \mainpage
 *
 * \version \$Revision: 1130 $
 * \date \$Date: 2007-09-07 18:08:54 -0400 (Fri, 07 Sep 2007) $
 * \author Skyhook Wireless
 *
 * \section main-install Installation
 *
 * For installation instructions please read \ref installation.
 *
 * \section api API Summary
 *
 * \li WPS_location()
 * \li WPS_periodic_location()
 * \li WPS_ip_location()
 *
 * For the full description of the API please read \ref API.
 *
 * \defgroup API API
 *
 * The API works in 2 major modes: \e network centric and \e device centric.
 *
 * \section network_model Network-centric model
 * In the network-centric model the API issues calls to a remote server
 * to determine a location.
 *
 * This is the mode used by the \c WPS_location() call.
 *
 * If a path to a local file has been setup (See \c WPS_set_local_files_path()),
 * the API first tries to determine the location locally,
 * without calling the remote server. This is called the \e mixed-mode model.
 *
 * \section device_model Device-centric model
 * In the device-centric model the API determines location
 * locally.
 *
 * This is the mode used by the \c WPS_periodic_location() call.
 *
 * This mode is activated by setting the path to a local
 * file. See \c WPS_set_local_files_path().
 *
 * \page changelog Change Log
 *
 * \section v2_5 Version 2.5
 *
 * \li Official release.
 *
 * \section v2_4 Version 2.4
 *
 * \li Added \e mixed-mode -- local location determination if possible.
 * \li Added \c WPS_periodic_location()
 * \li Added \c WPS_set_local_files_path()
 * \li Changed returned code from \c WPS_set_proxy()
 *     and \c WPS_set_server_url() to void
 * \li Added \c speed, \c bearing and \c nap
 *     to \c WPS_Location
 * \li Removed \c hpe from \c WPS_IPLocation
 *
 * \section v2_3_1 Version 2.3.1
 *
 * \li Added \c WPS_register_user()
 *
 * \section v2_3 Version 2.3
 *
 * \li Faster scanning
 * \li Caching to allow for better response time
 * \li \c WPSScanner.dll is no longer needed
 *
 * \page installation Installation
 *
 * \section requirements Requirements
 *
 * \if winxp
 *   \li Windows XP Service Pack 2
 * \elseif vista
 *   \li Windows Vista
 * \elseif pocketpc
 *   \li Windows Mobile 2003, Windows CE 5.0, or Windows Mobile 5.0
 * \elseif linux
 *   \li Linux 2.6 with wireless-extension
 *   \li The user must have read-write access to \c /proc/net/wireless.
 *       On most desktop linux write access to \c /proc/net/wireless
 *       is restricted to \c root.
 * \elseif darwin
 *   \li Mac OS X 10.4
 * \elseif symbian
 *   \li Symbian/S60 3rd Edition Feature Pack 1 or Symbian/UIQ 3.1
 * \endif
 * \li Wifi network card for location based on wifi networks.
 *       Without a wifi network card only ip-based location is available.
 * \li Active Internet connection for the network-centric model.
 *
 * \section install Install
 *
 * \if winxp
 *   \li Wi-Fi Service must be installed and running on the client machine.
 *       Run:
 *       \code
 *       bin/svcsetup.exe
 *       \endcode
 *   \li \c wpsapi.dll must be installed on the client's machine.
 * \elseif vista
 *   \li \c wpsapi.dll must be installed on the client's machine.
 * \elseif pocketpc
 *   \li \c wpsapi.dll must be installed on the client's machine.
 * \elseif linux
 *   \li \c libwpsapi.so must be installed on the client's machine.
 * \elseif darwin
 *   \li \c libwpsapi.dylib must be installed on the client's machine.
 * \elseif symbian
 *   \li If you decide to not package OpenC with your application,
 *       OpenC must be installed on the client's phone.
 * \endif
 *
 * \section sdkfiles Files
 *
 * \if winxp
 *   \verbatim
     bin/
         svcsetup.exe           Wi-Fi Service Installer
     documentation/
         html/                  documentation
         sdk.pdf                documentation
     example/
         wpsapitest.cpp         sample application (source code)
         wpsapitest.exe         sample application
         wpsapi.dll             copy of wpsapi.dll
     include/
         wpsapi.h               header file for wpsapi.dll
     lib/
         wpsapi.lib             library for wpsapi.dll
         wpsapi.dll             client library to the WPS server
     \endverbatim
 * \elseif vista
 *   \verbatim
     documentation/
         html/                  documentation
         sdk.pdf                documentation
     example/
         wpsapitest.cpp         sample application (source code)
         wpsapitest.exe         sample application
         wpsapi.dll             copy of wpsapi.dll
     include/
         wpsapi.h               header file for wpsapi.dll
     lib/
         wpsapi.lib             library for wpsapi.dll
         wpsapi.dll             WPS client library
     \endverbatim
 * \elseif pocketpc
 *   \verbatim
     documentation/
         html/                  documentation
         sdk.pdf                documentation
     example/
         wpsapitest.cpp         sample application (source code)
         wpsapitest.exe         sample application
         wpsapi.dll             copy of wpsapi.dll
     include/
         wpsapi.h               header file for wpsapi.dll
     lib/
         wpsapi.lib             library for wpsapi.dll
         wpsapi.dll             WPS client library
         SdkCerts.cab           Certificates for binaries
     \endverbatim
 * \elseif linux
 *   \verbatim
     bin/
         wpsd                   WPS daemon
     include/
         wpsapi.h               header file for libwpsapi.dylib
     lib/
         libwpsapi.2.0.5.so     WPS client library
         libwpsapi.2.so         WPS client library
         libwpsapi.a            library for libwpsapi.dylib
         libwpsapi.so           WPS client library
         libwpsapi.la           library for libwpsapi.dylib
     share/
         libwpsapi/
             log4cpp.properties sample log4cpp.properties
             sdk.pdf            documentation
             html/              documentation
     src/
         libwpsapi/
             wpsapitest         sample application
             wpsapitest.cpp     sample application (source code)
     \endverbatim
 * \elseif darwin
 *   \verbatim
     bin/
         wpsd                   WPS daemon
     include/
         wpsapi.h               header file for libwpsapi.dylib
     lib/
         libwpsapi.2.0.5.dylib  WPS client library
         libwpsapi.2.dylib      WPS client library
         libwpsapi.a            library for libwpsapi.dylib
         libwpsapi.dylib        WPS client library
         libwpsapi.la           library for libwpsapi.dylib
     share/
         libwpsapi/
             log4cpp.properties sample log4cpp.properties
             sdk.pdf            documentation
             html/              documentation
     src/
         libwpsapi/
             wpsapitest         sample application
             wpsapitest.cpp     sample application (source code)
     \endverbatim
 * \elseif symbian
 *   \verbatim
     documentation/
         html/                          documentation
         sdk.pdf                        documentation
     include/
         wpsapi.h                       header file for wpsapi.lib
     lib/
         Epoc32/
             release/
                 armv5/
                     urel/
                         wpsapi.lib     WPS client library
     \endverbatim
 *   \note In order to build an application you must first:
 *         \li Install the <a href="http://forum.nokia.com/info/sw.nokia.com/id/91d89929-fb8c-4d66-bea0-227e42df9053/Open_C_SDK_Plug-In.html">OpenC SDK</a>
 *         \li Install the <a href="http://www.webalice.it/marco.jez/files/STLport-bin-5.1.3-symbian-r1-S60_3rd_FP1.zip">STLport</a> for Symbian OS
 *         \li Copy \c wpsapi.lib to the Symbian SDK folder
 * \endif
 *
 * \page logging Logging
 *
 * \section logginghowto How to turn on logging
 *
 * \if winxp
 *   On Windows XP either drop a file named \c log4cpp.properties
 *   in the directory containing the executable that loads WPS,
 *   or define an environment variable named \c LOG4CPP_CONFIGURATION
 *   that contains the path to the \c log4cpp.properties file.
 * \elseif vista
 *   On Windows Vista either drop a file named \c log4cpp.properties
 *   in the directory containing the executable that loads WPS,
 *   or define an environment variable named \c LOG4CPP_CONFIGURATION
 *   that contains the path to the \c log4cpp.properties file.
 * \elseif pocketpc
 *   On Windows Mobile/CE drop a file named \c log4cpp.properties
 *   in the directory containing the executable that loads WPS.
 *   For the NMEA application this directory is \c \\Windows as
 *   WPS is loaded as a service by \c services.exe.
 * \elseif linux
 *   On Linux define an environment variable named \c LOG4CPP_CONFIGURATION
 *   that contains the path to the \c log4cpp.properties file.
 * \elseif darwin
 *   On Mac OS X define an environment variable named \c LOG4CPP_CONFIGURATION
 *   that contains the path to the \c log4cpp.properties file.
 * \endif
 *
 * \section log4cpp Log4cpp properties file
 *
 * Here's an example of a \c log4cpp.properties file
 * \if winxp
 * \verbatim
log4cpp.rootCategory=DEBUG, file, debug, console
log4cpp.appender.file=Win32FileAppender
log4cpp.appender.file.fileName=\wpslog.txt
log4cpp.appender.file.layout=org.apache.log4j.PatternLayout
log4cpp.appender.file.layout.ConversionPattern=%r %5t %p %c %m%n
log4cpp.appender.console=ConsoleAppender
log4cpp.appender.console.layout=org.apache.log4j.PatternLayout
log4cpp.appender.console.layout.ConversionPattern=%r %5t %p %c %m%n
log4cpp.appender.debug=Win32DebugAppender
log4cpp.appender.debug.layout=org.apache.log4j.PatternLayout
log4cpp.appender.debug.layout.ConversionPattern=%5t %p %c %m%n
   \endverbatim
 * \elseif vista
 * \verbatim
log4cpp.rootCategory=DEBUG, file, debug, console
log4cpp.appender.file=Win32FileAppender
log4cpp.appender.file.fileName=\wpslog.txt
log4cpp.appender.file.layout=org.apache.log4j.PatternLayout
log4cpp.appender.file.layout.ConversionPattern=%r %5t %p %c %m%n
log4cpp.appender.console=ConsoleAppender
log4cpp.appender.console.layout=org.apache.log4j.PatternLayout
log4cpp.appender.console.layout.ConversionPattern=%r %5t %p %c %m%n
log4cpp.appender.debug=Win32DebugAppender
log4cpp.appender.debug.layout=org.apache.log4j.PatternLayout
log4cpp.appender.debug.layout.ConversionPattern=%5t %p %c %m%n
   \endverbatim
 * \elseif pocketpc
 * \verbatim
log4cpp.rootCategory=DEBUG, file
log4cpp.appender.file=Win32FileAppender
log4cpp.appender.file.fileName=\wpslog.txt
log4cpp.appender.file.layout=org.apache.log4j.PatternLayout
log4cpp.appender.file.layout.ConversionPattern=%r %5t %p %c %m%n
   \endverbatim
 * \elseif linux
 * \verbatim
log4cpp.rootCategory=DEBUG, file, console
log4cpp.appender.file=FileAppender
log4cpp.appender.file.fileName=wpslog.txt
log4cpp.appender.file.layout=org.apache.log4j.PatternLayout
log4cpp.appender.file.layout.ConversionPattern=%r %5t %p %c %m%n
log4cpp.appender.console=ConsoleAppender
log4cpp.appender.console.layout=org.apache.log4j.PatternLayout
log4cpp.appender.console.layout.ConversionPattern=%r %5t %p %c %m%n
   \endverbatim
 * \elseif darwin
 * \verbatim
log4cpp.rootCategory=DEBUG, file, console
log4cpp.appender.file=FileAppender
log4cpp.appender.file.fileName=wpslog.txt
log4cpp.appender.file.layout=org.apache.log4j.PatternLayout
log4cpp.appender.file.layout.ConversionPattern=%r %5t %p %c %m%n
log4cpp.appender.console=ConsoleAppender
log4cpp.appender.console.layout=org.apache.log4j.PatternLayout
log4cpp.appender.console.layout.ConversionPattern=%r %5t %p %c %m%n
   \endverbatim
 * \endif
 *
 * For more information visit
 * <a href="http://log4cpp.sourceforge.net/api/classlog4cpp_1_1PropertyConfigurator.html">Log4CPP</a>
 *
 * \if winxp
 *   \internal
 *   \section wpsscannersvcdebug wpsscannersvc
 *   To enable verbose logging from the Wifi Scanner Service
 *   set the following registry key:
 *   \verbatim
[HKEY_LOCAL_MACHINE\SOFTWARE\Skyhook Wireless\Logging\wpsscannersvc.exe]
"LogLevel"=dword:00000003
     \endverbatim
 *   Restart the Wifi Scanner Service. It will now log into
 *   a file named \c wpsscannersvc.log in the same directory
 *   as the \c wpsscannersvc.exe.
 * \endif
 *
 * \page license Limited Use License
 *
 * Copyright 2005-2007 Skyhook Wireless, Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted subject to the following:
 *
 * * Use and redistribution is subject to the Software License and Development
 * Agreement, available at
 * <a href="http://www.skyhookwireless.com">www.skyhookwireless.com</a>
 *
 * * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * <br><hr>
 */
/** @{ */

#ifndef _WPSAPI_H_
#define _WPSAPI_H_

#ifdef __cplusplus
extern "C" {
#endif

/**
 * WPS return codes
 */
typedef enum
{
    /**
     * The call was successful.
     */
    WPS_OK = 0,

    /**
     * The \c WPSScanner.dll was not found.
     *
     * \deprecated This error code is no longer relevant.
     */
    WPS_ERROR_SCANNER_NOT_FOUND,

    /**
     * No Wifi adapter was detected.
     */
    WPS_ERROR_WIFI_NOT_AVAILABLE,

    /**
     * No Wifi reference points in range.
     */
    WPS_ERROR_NO_WIFI_IN_RANGE,

    /**
     * User authentication failed.
     */
    WPS_ERROR_UNAUTHORIZED,

    /**
     * The server is unavailable.
     */
    WPS_ERROR_SERVER_UNAVAILABLE,

    /**
     * A location couldn't be determined.
     */
    WPS_ERROR_LOCATION_CANNOT_BE_DETERMINED,

    /**
     * Proxy authentication failed.
     */
    WPS_ERROR_PROXY_UNAUTHORIZED,

    /**
     * A file IO error occurred while reading the local file.
     *
     * \since 2.4
     */
    WPS_ERROR_FILE_IO,

    /**
     * The local file has an invalid format.
     *
     * \since 2.4
     */
    WPS_ERROR_INVALID_FILE_FORMAT,

    /**
     * Some generic error occurred.
     */
    WPS_ERROR = 99
} WPS_ReturnCode;


/**
 * WPS_SimpleAuthentication is used to identify
 * the user with the server.
 */
typedef struct
{
    /**
     * the user's name, or unique identifier.
     */
    const char* username;

    /**
     * the authentication realm
     */
    const char* realm;
} WPS_SimpleAuthentication;

/**
 * street address lookup.
 *
 * \note the server returns as much information as requested,
 *       but is not required to fill in all the requested fields.
 *       \n
 *       Only the fields the server could reverse geocode are returned.
 */
typedef enum
{
    /**
     * no street address lookup is performed
     */
    WPS_NO_STREET_ADDRESS_LOOKUP,

    /**
     * a limited address lookup is performed
     * to return, at most, city information.
     */
    WPS_LIMITED_STREET_ADDRESS_LOOKUP,

    /**
     * a full street address lookup is performed
     * returning the most specific street address
     */
    WPS_FULL_STREET_ADDRESS_LOOKUP
} WPS_StreetAddressLookup;

typedef struct
{
    char* name;
    char code[3];
} WPS_NameCode;

/**
 * Street Address
 */
typedef struct
{
    /**
     * street number
     */
    char* street_number;

    /**
     * A \c NULL terminated array of address line
     */
    char** address_line;

    /**
     * city
     */
    char* city;

    /**
     * postal code.
     */
    char* postal_code;

    /**
     * county
     */
    char* county;

    /**
     * province
     */
    char* province;

    /**
     * state, includes state name and 2-letter code.
     */
    WPS_NameCode state;

    /**
     * region
     */
    char* region;

    /**
     * country, includes country name and 2-letter code.
     */
    WPS_NameCode country;
} WPS_StreetAddress;

/**
 * Geographic location based on observed access points.
 */
typedef struct
{
    //@{
    /**
     * the calculated physical geographic location
     */
    double latitude;
    double longitude;
    //@}

    /**
     * <em>horizontal positioning error</em> --
     * A calculated error estimate of the location result in meters
     */
    double hpe;

    /**
     * The number of access-point used to calculate this location.
     *
     * \since 2.4
     */
    unsigned short nap;

    /**
     * A calculated estimate of speed in km/hr.
     *
     * A negative speed is used to indicate an unknown speed.
     *
     * \since 2.4
     */
    double speed;

    /**
     * A calculated estimate of bearing as degree from north
     * counterclockwise (+90 is West).
     *
     * \since 2.4
     */
    double bearing;

    /**
     * physical street address,
     * only returned in the network-centric model
     * when the \c street_address_lookup parameter
     * is set to \c limited or \c full.
     */
    WPS_StreetAddress* street_address;
} WPS_Location;

/**
 * Geographic location based on
 * the IP address of the client making the request.
 *
 * \note This information is likely not accurate,
 *       but may give some indication as to the general location
 *       of the request and may provide some hints for the client
 *       software to act and react appropriately.
 */
typedef struct
{
    /**
     * the IP address of the client as received by the server
     */
    char* ip;

    //@{
    /**
     * the estimated physical geographic location
     */
    double latitude;
    double longitude;
    //@}

    /**
     * physical street address,
     * only returned when the \c street_address_lookup parameter
     * is set to \c limited or \c full
     */
    WPS_StreetAddress* street_address;
} WPS_IPLocation;

/**
 * Requests geographic location based on observed wifi access points.
 *
 * \param authentication the user's authentication information.
 * \param street_address_lookup request street address lookup
 *                              in addition to latitude/longitude lookup
 * \param location pointer to return a \c WPS_Location struct.
 *                 \n
 *                 This pointer should be freed by calling WPS_free_location().
 *
 * \return a \c WPS_ReturnCode
 */
extern WPS_ReturnCode
WPS_location(const WPS_SimpleAuthentication* authentication,
             WPS_StreetAddressLookup street_address_lookup,
             WPS_Location** location);


/**
 * Callback routine for \c WPS_periodic_location().
 *
 * \param arg the \c arg passed to \c WPS_periodic_location().
 * \param code the \c WPS_ReturnCode of the last request
 * \param location If \c code is \c WPS_OK points to a \c WPS_Location
 *                 \n
 *                 This pointer does \e not need to be freed.
 *
 * \return \e true if \c WPS_periodic_location() is to continue,
 *         \e false if \c WPS_periodic_location() should stop.
 *
 * \since 2.4
 */
typedef int (*WPS_LocationCallback)(void* arg,
                                    WPS_ReturnCode code,
                                    const WPS_Location* location);

/**
 * Requests periodic geographic location based on observed wifi access points.
 *
 * \param authentication the user's authentication information.
 * \param street_address_lookup request street address lookup
 *                              in addition to latitude/longitude lookup
 *                              \n
 *                              Note that street address lookup is only
 *                              performed when the location is determined
 *                              by the remote server (network-centric model),
 *                              not when the location is determined locally.
 * \param period time in milliseconds between location reports
 *               \n
 *               Note this time is \e approximatif, particularly when the location
 *               is calculated remotely.
 * \param iterations number of time a location is to be reported.
 *                   \n
 *                   A value of zero indicates an unlimited number of
 *                   iterations.
 * \param callback the callback routine to report locations to.
 * \param arg an opaque parameter passed to the callback routine.
 *
 * \pre \c period must be strictly greater than 0.
 *
 * \since 2.4
 */
extern WPS_ReturnCode
WPS_periodic_location(const WPS_SimpleAuthentication* authentication,
                      WPS_StreetAddressLookup street_address_lookup,
                      unsigned long period,
                      unsigned iterations,
                      WPS_LocationCallback callback,
                      void* arg);

/**
 * Request geographic location information based on
 * the IP address of the client making the request.
 *
 * \note  This information is likely not accurate,
 *        but may give some indication as to the general location
 *        of the request and may provide some hints for the client
 *        software to act and react appropriately.
 *
 * \note  WPS_ip_location() only works in the network-centric model.
 *
 * \param authentication the user's authentication information.
 * \param street_address_lookup request street address lookup
 *                              in addition to lat/long lookup
 * \param location pointer to return a \c WPS_IPLocation struct.
 *                 \n
 *                 This pointer should be freed by calling WPS_free_ip_location()
 *
 * \return a \c WPS_ReturnCode
 */
extern WPS_ReturnCode
WPS_ip_location(const WPS_SimpleAuthentication* authentication,
                WPS_StreetAddressLookup street_address_lookup,
                WPS_IPLocation** location);

/**
 * Free a WPS_Location struct returned by WPS_location()
 */
extern void
WPS_free_location(WPS_Location*);

/**
 * Free a WPS_Location struct returned by WPS_ip_location()
 */
extern void
WPS_free_ip_location(WPS_IPLocation*);

/**
 * Setup a proxy server
 *
 * \param address the IP address of the proxy server
 * \param port the TCP port number to connect to
 * \param user the username to authenticate with the proxy server
 * \param password the password to authentication with the proxy server
 *
 * \return a \c WPS_ReturnCode
 */
extern void
WPS_set_proxy(const char* address,
              int port,
              const char* user,
              const char* password);

/**
 * Overwrite the WPS server's url from its default value.
 *
 * \param url the url to the server.
 *            \n
 *            A value of \c NULL turns off remote determination of location.
 */
extern void
WPS_set_server_url(const char* url);

/**
 * Set the path to local files so location determination can be performed
 * locally.
 *
 * \param paths an array (terminated by \c NULL) of complete path to local files.
 *              \n
 *              Each local file supercedes any previous file.
 *              \n
 *              A value of \c NULL turns off local determination of location.
 *
 * \return a \c WPS_ReturnCode
 *
 * \since 2.4
 */
extern WPS_ReturnCode
WPS_set_local_files_path(const char** paths);

/**
 * Register a new user
 *
 * \param authentication an existing user's authentication information.
 * \param new_authentication the new user's authentication information.
 *
 * \return a \c WPS_ReturnCode
 *
 * \since 2.3.1
 */
extern WPS_ReturnCode
WPS_register_user(const WPS_SimpleAuthentication* authentication,
                  const WPS_SimpleAuthentication* new_authentication);

#ifdef __cplusplus
}
#endif

/** @} */

/**
 * \example wpsapitest.cpp
 *
 * This sample application, located in the \c example directory, is a
 * simple console based application.
 *
 * When run, it first issues an
 * ip location (\c WPS_ip_location()) request to locate itself
 * based on the ip address of the machine.
 * It prints the latitude and longitude returned
 * from the server.
 *
 * Second it requests a wifi location (\c WPS_location()), with street
 * address reverse lookup, based on wifi networks around the
 * machine. It prints the latitude, longitude and address returned
 * from the server.
 *
 * Finally it requests a series of wifi location (\c WPS_periodic_location()).
 *
 * Here's a sample output:
 * \verbatim
     66.228.70.195: 42.342500, -71.067700

     42.350950, -71.049709
     328 Congress St
     Boston, MA 02210
   \endverbatim
 *
 * \note  The sample application needs a direct connection to the internet
 *        to function properly.
 *
 * \if pocketpc
 *   \note  In order to build the sample application you must have
 *          enabled "Smart Device Programmability" option when installing
 *          Visual Studio 2005.
 * \endif
 * <hr>
 */

#endif // _WPSAPI_H_
