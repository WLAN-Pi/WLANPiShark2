@ECHO OFF
setlocal
REM #################################################################
REM # 
REM # This script runs on a Windows 10 machine and will allow
REM # Wireshark on a Windows machine to decode captured frames,
REM # using a WLANPi as a wireless capture device. The Windows machine
REM # machine must have IP connectivity to your WLANPi via its Ethernet
REM # port. Run this script from a Windows command shell (CMD).
REM # 
REM # Set the variables below to point at your local copy of 
REM # Wireshark and configure the WLANPi credentials & IP address
REM # (Note that the user account on the WLANPi must be an admin 
REM # account to allow the sudo command to be executed - the default
REM # account wlanpi/wlanpi works fine. Please use a plain text
REM # editor to make the updates (e.g. Notepad)
REM # 
REM # You will need the 'plink.exe' executable that is bundled with
REM # Putty to run this batch file. https://www.putty.org/)
REM # 
REM # This batch file needs to be run from a Windows 10 command line
REM # and will stream tcpdump data back to Wireshark on your Windows
REM # machine from a WLANPi, allowing wireless frames decode. This script
REM # was tested with a Comfast CF-912AC adapter plugged in to a WLANPi.
REM # 
REM # If using a version of the WLANPi image prior to version 1.5.0, 
REM # the best way to use this script with your WLANPi is to hook up a
REM # ethernet cable between your laptop/PC and the WLANPi. Make sure you
REM # do this before powering on your WLANPi. Then, when the WLANPi powers
REM # up, you will see a 169.254.x.x address on the display of your WLANPi.
REM # Enter this address in the WLAN_PI_IP address is the variables area
REM # below. This should be a one-time operation, as the WLANPi should use
REM # the same 169.254.x.x address each time. This operation also assumes 
REM # your laptop/PC is set to use DHCP on its ethernet adapter (it will
REM # also uses its own 169.254.x.x address for comms when it gets no
REM # IP address from DHCP).
REM # 
REM # If you are using image version 1.5.0 or later of the WLANPi, (you
REM # can check by browsing to a WLANPi & checkout the top of the page)
REM # then Ethernet over USB functionality is built in to the image. This
REM # means that you can use USB to both power the WLANPi and also provide
REM # an IP connection (no more Ethernet connection required!). Note that the 
REM # WLANPi display will still show the address 169.254.x.x in this mode, but
REM # a new adapter should appear in the adapter list shown on your laptop.
REM # The new adapter will be assigned an address via DHCP in the range 
REM # 192.168.42.0/27, with the WLANPi using an address of 192.168.42.1. If
REM # you have any difficulties with the new Ethernet over USB adapter 
REM # appearing in your adapter list (ipconfig), then try a better quality
REM # microUSB to USB cable, as some thinner cables seem to cause issues.
REM # 
REM # Note that each time you want to change channels or start a new capture,
REM # you will need to close Wireshark and re-run this script. 
REM # 
REM # (Suggestions & feedback: wifinigel@gmail.com)
REM # 
REM #################################################################

REM !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
REM !
REM ! Set your variables here, but make sure no trailing spaces 
REM ! accidentally at end of lines - you WILL have issues!
REM ! 
REM ! Remember, 192.168.42.1 is the default WLANPi address when
REM ! using Ethernet over USB. Also, change IW_VER from 4.9 to 
REM ! 4.14 to activate 80MHz support
REM !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
set WLAN_PI_USER=wlanpi
set WLAN_PI_PWD=wlanpi
set WLAN_PI_IP=192.168.42.1
set WIRESHARK_EXE=C:\Program Files\Wireshark\Wireshark.exe
set PLINK=C:\Program Files (x86)\PuTTY\plink.exe
set WLAN_PI_IFACE=wlan0
set IW_VER=4.9

REM ############### NOTHING TO SET BELOW HERE #######################
:init
    set "__NAME=%~n0"
    set "__VERSION=0.02"
    set "__YEAR=2019"

    set "__BAT_FILE=%~0"
    set "__BAT_PATH=%~dp0"
    set "__BAT_NAME=%~nx0"

    set "CHANNEL_NUMBER=0"
    set "CHANNEL_WIDTH=20"
    set "FILTER=wlan type mgt or wlan type ctl or wlan type data"
    set "SLICE=0"
    set "DEBUG=0"

:parse
    if "%~1"=="" goto :validate

    rem  - handle single instance command line args (help, version etc.)
    if /i "%~1"=="-h"         call :header & goto :usage
    if /i "%~1"=="--help"     call :header & goto :usage

    if /i "%~1"=="-hh"        call :header & goto :extra_help
    if /i "%~1"=="--xhelp"    call :header & goto :extra_help
    
    if /i "%~1"=="-v"         goto :version
    if /i "%~1"=="--version"  goto :version
    
    if /i "%~1"=="-u"         goto :upgrade
    if /i "%~1"=="--upgrade"  goto :upgrade
    
    if /i "%~1"=="--diag"     goto :diag
      
    rem If you pass the -d option, Wireshark does not start
    if /i "%~1"=="-d"         set "DEBUG=1" & shift & goto :parse
    
    rem - Handle mutliple parameter entries
    
    rem - This var is passed in from the command line (1-14, 36 - 165)
    if /i "%~1"=="--channel"  set "CHANNEL_NUMBER=%~2" & shift & shift & goto :parse
    if /i "%~1"=="-c"         set "CHANNEL_NUMBER=%~2" & shift & shift & goto :parse
    
    if /i "%~1"=="--width"    set "CHANNEL_WIDTH=%~2"  & shift & shift & goto :parse
    if /i "%~1"=="-w"         set "CHANNEL_WIDTH=%~2"  & shift & shift & goto :parse
    
    if /i "%~1"=="--filter"   set "FILTER=%~2"         & shift & shift & goto :parse
    if /i "%~1"=="-f"         set "FILTER=%~2"         & shift & shift & goto :parse
    
    if /i "%~1"=="--slice"    set "SLICE=%~2"          & shift & shift & goto :parse
    if /i "%~1"=="-s"         set "SLICE=%~2"          & shift & shift & goto :parse
    
    if /i "%~1"=="--ip"       set "WLAN_PI_IP=%~2"     & shift & shift & goto :parse
    if /i "%~1"=="-i"         set "WLAN_PI_IP=%~2"     & shift & shift & goto :parse

    shift
    goto :parse

:validate
    rem Check mandatory fields supplied
    rem if not defined CHANNEL_NUMBER call :missing_argument "Channel Number" & goto :end
    if "%CHANNEL_NUMBER%"=="0" call :missing_argument "Channel Number" & goto :end

:width_check
    rem Set channel width to correct value to pass to WLANPi 
    if "%CHANNEL_WIDTH%"=="20"  set "CHANNEL_WIDTH=HT20"  & goto :main
    if "%CHANNEL_WIDTH%"=="40+" set "CHANNEL_WIDTH=HT40+" & goto :main
    if "%CHANNEL_WIDTH%"=="40-" set "CHANNEL_WIDTH=HT40-" & goto :main
    if not "%IW_VER%"=="4.9" (
        if "%CHANNEL_WIDTH%"=="80" set "CHANNEL_WIDTH=80MHz" & goto :main
    )
    call :incorrect_argument "Channel Width" %CHANNEL_WIDTH% & goto :end

:main

rem Check if we need to apply a fix due to Plink version
set PLINK_MOD=

rem Read Plink ver
"%PLINK%" -V > "%TEMP%\plink_ver.txt"
set /P PLINKVER=<"%TEMP%\plink_ver.txt"
del "%TEMP%\plink_ver.txt"

rem For v0.71 onwards, we need to put in the -no-antispoof
If NOT "%PLINKVER%"=="%PLINKVER:0.71=%" set PLINK_MOD=-no-antispoof
If NOT "%PLINKVER%"=="%PLINKVER:0.72=%" set PLINK_MOD=-no-antispoof
If NOT "%PLINKVER%"=="%PLINKVER:0.73=%" set PLINK_MOD=-no-antispoof
If NOT "%PLINKVER%"=="%PLINKVER:0.74=%" set PLINK_MOD=-no-antispoof
If NOT "%PLINKVER%"=="%PLINKVER:0.75=%" set PLINK_MOD=-no-antispoof


if "%DEBUG%"=="1" goto :debug

echo Starting session to device %WLAN_PI_IP% ...

Rem - Start remote commands on WLANPi
"%PLINK%" -ssh %PLINK_MOD% -pw %WLAN_PI_PWD% %WLAN_PI_USER%@%WLAN_PI_IP% "echo %WLAN_PI_PWD% | sudo -S /home/wlanpi/wlanpishark/wlanpishark.py -c %CHANNEL_NUMBER% -w %CHANNEL_WIDTH%" -i %WLAN_PI_IFACE% -s %SLICE% -f %FILTER% | "%WIRESHARK_EXE%" -k -i -

goto :end

:debug

if "%CHANNEL_NUMBER%"=="0" call :missing_argument "Channel Number" & goto :end

echo Starting in debug mode (no Wireshark)

echo Channel number : %CHANNEL_NUMBER%
echo Channel width: %CHANNEL_WIDTH%
echo Interface: %WLAN_PI_IFACE%
echo Slice: %SLICE%
echo Filter: %FILTER%
"%PLINK%" -ssh %PLINK_MOD% -pw %WLAN_PI_PWD% %WLAN_PI_USER%@%WLAN_PI_IP% "echo %WLAN_PI_PWD% | sudo -S /home/wlanpi/wlanpishark/wlanpishark.py -c %CHANNEL_NUMBER% -w %CHANNEL_WIDTH%" -i %WLAN_PI_IFACE% -s %SLICE% -d -f %FILTER%

goto :end

:header
    echo.
    echo  %__NAME% v%__VERSION% - A Windows batch file to stream tcpdump
    echo  running on a WLANPi to Wireshark on a Windows machine
    echo.
    goto :eof

:usage
    echo  USAGE:
    echo.
    IF not "%IW_VER%"=="4.9" (
        echo   %__BAT_NAME% [--channel nn] { --width 20 ^| 40+ ^| 40- ^| 80 } { --filter "capture filter"} { --slice nnn } { --ip nnn.nnn.nnn.nnn }
        echo.
        echo   %__BAT_NAME% [-c nn] { -w 20 ^| 40+ ^| 40- ^| 80 } { -f "capture filter"} { -s nnn } { -i nnn.nnn.nnn.nnn}
        
    ) ELSE (
        echo   %__BAT_NAME% [--channel nn] { --width 20 ^| 40+ ^| 40- } { --filter "capture filter"} { --slice nnn } { --ip nnn.nnn.nnn.nnn }
        echo.
        echo   %__BAT_NAME% [-c nn] { -w 20 ^| 40+ ^| 40- } { -f "capture filter"} { -s nnn } { -i nnn.nnn.nnn.nnn}
    )
    echo.
    echo.  %__BAT_NAME% -h, --help          shows basic help
    echo.  %__BAT_NAME% -hh, --xhelp        shows extra help
    echo.  %__BAT_NAME% -v, --version       shows the version
    echo.  %__BAT_NAME% --diag              shows diagnostic info
    IF "%IW_VER%"=="4.9" (
        echo.  %__BAT_NAME% -u, --upgrade       shows how to enable 80MHz capture
    )
    goto :end    

:extra_help
    echo  HELP:
    echo.
    if not "%IW_VER%"=="4.9" (
        echo   %__BAT_NAME% [--channel nn] { --width 20 ^| 40+ ^| 40- ^| 80 } { --filter "capture filter"} { --slice nnn } { --ip nnn.nnn.nnn.nnn }
        echo.
        echo   %__BAT_NAME% [-c nn] { -w 20 ^| 40+ ^| 40- ^| 80 } { -f "capture filter"} { -s nnn } { -i nnn.nnn.nnn.nnn}
        
    ) ELSE (
        echo   %__BAT_NAME% [--channel nn] { --width 20 ^| 40+ ^| 40- } { --filter "capture filter"} { --slice nnn } { --ip nnn.nnn.nnn.nnn }
        echo.
        echo   %__BAT_NAME% [-c nn] { -w 20 ^| 40+ ^| 40- } { -f "capture filter"} { -s nnn } { -i nnn.nnn.nnn.nnn}
    )
    echo.
    echo.  %__BAT_NAME% -h, --help          shows basic help
    echo.  %__BAT_NAME% -hh, --xhelp        shows extra help
    echo.  %__BAT_NAME% -v, --version       shows the version
    echo.  %__BAT_NAME% --diag              shows diagnostic info
    IF "%IW_VER%"=="4.9" (
        echo.  %__BAT_NAME% -u, --upgrade       shows how to enable 80MHz capture
    )
    echo.
    echo   Command Line Capture Options:
    echo.
    echo    --channel or -c : (Mandatory) Channel number to capture (1-13, 36-165)
    echo.
    echo    --width or -w   : (Optional) Channel width to be used for capture 
    if not "%IW_VER%"=="4.9" (
    echo                       Available values: 20, 40+, 40-, 80 ^(default: 20Mhz^)
    ) else (
    echo                       Available values: 20, 40+, 40- ^(default: 20Mhz^)
    )
    echo.
    echo    --filter or -f  : (Optional) tcpdump capture filter (must be enclosed in quotes)
    echo                       Examples: 
    echo                                "wlan type mgt" - capture only management frames
    echo                                "wlan type ctl" - capture only control frames
    echo                                "wlan type mgt subtype beacon" - capture only beacon frames
    echo.
    echo     See more details at: http://wifinigel.blogspot.com/2018/04/wireshark-capture-filters-for-80211.html
    echo.
    echo    --slice or -s   : (Optional) Slice captured frames to capture only headers and reduce size of capture
    echo                                 file. Provide value for number of bytes to be captured per frame.
    echo.
    echo    --ip or -i      : (Optional) IP address of WLANPi. Note that if this is ommitted, the hard coded version in the 
    echo                                 batch file itself will be used
    echo.
    echo   Example:
    echo.
    echo    1. Capture all frames on channel 36:
    echo.
    echo        WLANPiShark.bat -c 36
    echo.
    echo    2. Capture the first 200 bytes of beacon frames on 20MHz channel 48:
    echo.
    echo        WLANPiShark.bat -c 48 -w 20 -s 200 -f "wlan type mgt subtype beacon"
    echo.
    if not "%IW_VER%"=="4.9" (
        echo    3. Capture on 80MHz channel with base channel of 36 ^(i.e. 36,40,44,48^)
        echo.
        echo        WLANPiShark.bat -c 36 -w 80
        echo.
    )
    echo    Bugs:
    echo        Please report to wifinigel@gmail.com (please supply "WLANPiShark.bat --diag" output)
    echo.
    echo    More Information:
    echo        Visit: https://github.com/WLAN-Pi/WLANPiShark2
    echo.
    goto :end

:upgrade
    echo.
    echo. To upgrade this script to support 80MHz captures, edit this file
    echo  to change the IW_VER variable from:
    echo.
    echo     set IW_VER=4.9
    echo.
    echo  to:
    echo.
    echo     set IW_VER=4.14
    echo.
    echo  Ensure you are running at least version 4.14 of 'iw' first!
    echo  (SSH to WLANPi and run : sudo iw --version)
    echo. 
    goto :end    

:diag

rem Check Plink file
echo ==========================
echo  Plink checks
echo ==========================
echo Plink file path: %PLINK%
if exist "%PLINK%" (
    echo File check: Plink file detected OK
) else (
    echo File check: Plink file not detected - please check path configured
)

"%PLINK%" -V > %TEMP%\plink_ver.txt
set /P PLINKVER=<%TEMP%\plink_ver.txt
del %TEMP%\plink_ver.txt
echo Version check: %PLINKVER%

rem Check Wireshark file
echo ==========================
echo  Wireshark checks
echo ==========================
echo Wireshark file path: %WIRESHARK_EXE%
if exist "%WIRESHARK_EXE%" (
    echo File check: Wireshark file detected OK
) else (
    echo File check: Wireshark file not detected - please check path configured
)

"%WIRESHARK_EXE%" -v > %TEMP%\ws_ver.txt
set /P WSVER=<%TEMP%\ws_ver.txt
del %TEMP%\ws_ver.txt
echo Version check: %WSVER%

rem Dump vars
echo ==========================
echo  Configured variables
echo ==========================
echo WLANPi username: %WLAN_PI_USER%
echo WLANPi user account pwd: %WLAN_PI_PWD%
echo WLANPi IP address: %WLAN_PI_IP%
echo WLANPi wireless LAN interface name: %WLAN_PI_IFACE%
echo IW version: %IW_VER%

goto :end

:version
    echo.
    echo.  %__BAT_NAME% 
    echo   Version: %__VERSION%
    echo.
    goto :eof

:missing_argument
    echo.
    echo  **** Error: Missing required argument: %~1  ****
    echo.
    call :usage & goto :eof

:incorrect_argument
    echo.
    echo  **** Error: Incorrect argument supplied for %~1 : %~2  ****
    echo.
    call :usage & goto :eof

:end
    exit /B
    
REM #################################################################
REM # 
REM # Version history;
REM # 
REM # v0.01 - N.Bowden 17th Feb 2019
REM #
REM #        Initial release of spin-off from original WLANPIShark
REM #        project. Now relies on having wlanpishark.py file on
REM #        the remote WLANPi to speed up and simplify operations.
REM # 
REM # v0.02 - N.Bowden 17th July 2019
REM #
REM #        1. Several reports of issues which turned out to be
REM #           an issue with a new "-no-antispoof" introduced in
REM #           Plink 0.71. issue did no affect Plink 0.70
REM #           Added version detection and a fix if version 0.71 to 
REM #           0.75 is detected (bit of future proofing in there...)
REM # 
REM #        2. Added new "--diag" CLI option to do some basic 
REM #           checks and dump out config data for bug/issue
REM #           reports
REM # 
REM #################################################################

