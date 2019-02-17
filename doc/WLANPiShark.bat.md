# WLANPiShark

This is a windows bat file to be used in conjunction with a WLANPi device. It is run from a Windows command prompt and will start a remote streamed capture from a WLANPi device to Wireshark on a Windows machine running this bat file. This allows a Windows machine to run an over the air wireless capture, using the WLANPi as a remote sensor.

The file requires some minor configuration using a simple text editor such as notepad to configure it for your Windows machine. The WLANPi requires no configuration - this batch files has been created specifically to ensure that no changes need to be made by the user on the WLANPi device. You can build a WLANPi as per the instructions at [http://WLANPi.com] and use this batch file with WLANPi the out of the box config.

Here is a blog post that describes how to use this script with a WLANPi in more detail: [https://wifinigel.blogspot.com/2019/01/wlanpishark-wireless-capture-with.html]

Here are the README details from the batch file (which you can view by opening the batch file itself with a text editor) and it is strongly recommended that you review this prior to using this script:

```
 #################################################################
 
 This script runs on a Windows 10 machine and will allow
 Wireshark on a Windows machine to decode captured frames,
 using a WLANPi as a wireless capture device. The Windows machine
 machine must have IP connectivity to your WLANPi via its Ethernet
 port. Run this script from a Windows command shell (CMD).
 
 Set the variables below to point at your local copy of 
 Wireshark and configure the WLANPi credentials & IP address
 (Note that the user account on the WLANPi must be an admin 
 account to allow the sudo command to be executed - the default
 account wlanpi/wlanpi works fine. Please use a plain text
 editor to make the updates (e.g. Notepad)
 
 You will need the 'plink.exe' executable that is bundled with
 Putty to run this batch file. https://www.putty.org/)
 
 This batch file needs to be run from a Windows 10 command line
 and will stream tcpdump data back to Wireshark on your Windows
 machine from a WLANPi, allowing wireless frames decode. This script
 was tested with a Comfast CF-912AC adapter plugged in to a WLANPi.
 
 If using a version of the WLANPi image prior to version 1.5.0, 
 the best way to use this script with your WLANPi is to hook up a
 ethernet cable between your laptop/PC and the WLANPi. Make sure you
 do this before powering on your WLANPi. Then, when the WLANPi powers
 up, you will see a 169.254.x.x address on the display of your WLANPi.
 Enter this address in the WLAN_PI_IP address is the variables area
 below. This should be a one-time operation, as the WLANPi should use
 the same 169.254.x.x address each time. This operation also assumes 
 your laptop/PC is set to use DHCP on its ethernet adapter (it will
 also uses its own 169.254.x.x address for comms when it gets no
 IP address from DHCP).
 
 If you are using image version 1.5.0 or later of the WLANPi, (you
 can check by browsing to a WLANPi & check out the top of the page)
 then Ethernet over USB functionality is built in to the image. This
 means that you can use USB to both power the WLANPi and also provide
 an IP connection (no more Ethernet connection required!). Note that the 
 WLANPi display will still show the address 169.254.x.x in this mode, but
 a new adapter should appear in the adapter list shown on your laptop.
 The new adapter will be assigned an address via DHCP in the range 
 192.168.42.0/27, with the WLANPi using an address of 192.168.42.1. If
 you have any difficulties with the new Ethernet over USB adapter 
 appearing in your adapter list (ipconfig), then try a better quality
 microUSB to USB cable, as some thinner cables seem to cause issues.
 
 Note that each time you want to change channels or start a new capture,
 you will need to close Wireshark and re-run this script. 
 
 (Suggestions & feedback: wifinigel@gmail.com)
 
 #################################################################
```

## Configuration

There are a few variable you will need to set before running the batch file on your Windows machine - do this by editing the batch file with a simple text editor such as Notepad:

```
set WLAN_PI_USER=wlanpi
set WLAN_PI_PWD=wlanpi
set WLAN_PI_IP=192.168.42.1
set WIRESHARK_EXE=C:\Program Files\Wireshark\Wireshark.exe
set PLINK=C:\Program Files (x86)\PuTTY\plink.exe
set WLAN_PI_IFACE=wlan0
set IW_VER=4.9
```
## Usage

```
WLANPiShark v0.01 - A Windows batch file to stream tcpdump
 running on a WLANPi to Wireshark on a Windows machine

 USAGE:

  WLANPiShark.bat [--channel nn] { --width 20 | 40+ | 40- } { --filter "capture filter"} { --slice nnn } { --ip nnn.nnn.nnn.nnn }

  WLANPiShark.bat [-c nn] { -w 20 | 40+ | 40- } { -f "capture filter"} { -s nnn } { -i nnn.nnn.nnn.nnn}

  WLANPiShark.bat -h, --help          shows basic help
  WLANPiShark.bat -hh, --xhelp        shows extra help
  WLANPiShark.bat -v, --version       shows the version
  WLANPiShark.bat -u, --upgrade       shows how to enable 80MHz capture
```
## Additional Help

```
WLANPiShark v0.01 - A Windows batch file to stream tcpdump
 running on a WLANPi to Wireshark on a Windows machine

 HELP:

  WLANPiShark.bat [--channel nn] { --width 20 | 40+ | 40- } { --filter "capture filter"} { --slice nnn } { --ip nnn.nnn.nnn.nnn }

  WLANPiShark.bat [-c nn] { -w 20 | 40+ | 40- } { -f "capture filter"} { -s nnn } { -i nnn.nnn.nnn.nnn}

  WLANPiShark.bat -h, --help          shows basic help
  WLANPiShark.bat -hh, --xhelp        shows extra help
  WLANPiShark.bat -v, --version       shows the version
  WLANPiShark.bat -u, --upgrade       shows how to enable 80MHz capture

  Command Line Capture Options:

   --channel or -c : (Mandatory) Channel number to capture (1-13, 36-165)

   --width or -w   : (Optional) Channel width to be used for capture
                      Available values: 20, 40+, 40- (default: 20Mhz)

   --filter or -f  : (Optional) tcpdump capture filter (must be enclosed in quotes)
                      Examples:
                               "wlan type mgt" - capture only management frames
                               "wlan type ctl" - capture only control frames
                               "wlan type mgt subtype beacon" - capture only beacon frames

    See more details at: http://wifinigel.blogspot.com/2018/04/wireshark-capture-filters-for-80211.html

   --slice or -s   : (Optional) Slice captured frames to capture only headers and reduce size of capture
                                file. Provide value for number of bytes to be captured per frame.

   --ip or -i      : (Optional) IP address of WLANPi. Note that if this is ommitted, the hard coded version in the
                                batch file itself will be used

  Example:

   1. Capture all frames on channel 36:

       WLANPiShark.bat -c 36

   2. Capture the first 200 bytes of beacon frames on 20MHz channel 48:

       WLANPiShark.bat -c 48 -w 20 -s 200 -f "wlan type mgt subtype beacon"

   Bugs:
       Please report to wifinigel@gmail.com

   More Information:
       Visit: https://github.com/WLAN-Pi/WLANPiShark2
```
## Examples

1. Capture on channel 52 (default 20Mhz width):

```
WLANPiShark.bat -c 52
```

2. Capture on channel 44 with a channel width of 40MHz (channels 44 + 48):

```
WLANPiShark.bat -c 44 -w 40+
```

3. Capture on channel 132 using 40MHz channels capturing only the first 200 bytes of each frame:

```
WLANPiShark.bat -c 132 -w 40+ -s 200
```

4. Capture on channel 52 using a channel width on 80MHz (assuming 80MHz support enabled - see notes at the top of this page). Note this will capture the 80MHz channel 52 - 64:

```
WLANPiShark.bat -c 52 -w 80
```

5. Capture only beacon frames on channel 100:

```
WLANPiShark.bat -c 100 -f "wlan type mgt subtype beacon"
```

## Filtering
For more information about capture filters, please see my blog article at: [http://wifinigel.blogspot.com/2018/04/wireshark-capture-filters-for-80211.html]. The syntax shown for Wireshark capture filters in that article is the same as is required for the filter syntax used with this script.

## Screenshots

![Screenshot1](https://github.com/wifinigel/WLANPiShark/blob/master/screenshot1.png)

![Screenshot2](https://github.com/wifinigel/WLANPiShark/blob/master/screenshot2.png)

## Caveats
- Note that this is work in progress and I cannot guarantee its reliability, despite my very best efforts - use at your own risk.


