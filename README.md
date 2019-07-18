# WLANPiShark2
Scripts to enable Wireshark to be run on various laptop types using the WLANPi as a remote packet sniffer  

**(Seeing "Data written to the pipe is neither a supported pcap format nor pcapng format" messages? See the "Known Issues" section at the bottom of this page)**

This project is a spin-off of the original [WLANPiShark project](https://github.com/wifinigel/WLANPiShark). The aim of that project was to allow Windows users to be able to use a WLANPi as a Wi-Fi capture device, thus providing an easy way for Windows users to perform packet captures in to Wireshark. However the project relied on a clunky batch file that took quite a a while to start up, making it slow to use.

This project aims to perform the same task, but far more efficiently, and across several platforms (beyond just Windows). It does this by leveraging a Python script that is pre-installed on to the WLANPi that does much of the device setup heavy lifting, and removes the complexity required in the previous project batch file. 

To initiate the capture, a second script/batch file is executed on the device (e.g. laptop) that wishes to execute the Wirehsark capture, using the WLANPi as a remote probe. 

In this release, there are only 2 scripts:

- WLANPiShark.bat : the Windows batch file to be run on a Windows machine
- wlanpishark.py : the Python script that is installed on the WLANPi and iscalled from the batch to execute all WLANPi setup commands and initiate a tcpdump stream

The architecture of the solution is shown in the diagram below:

![WLANPiShark Overview](https://github.com/WLAN-Pi/WLANPiShark2/blob/master/images/WLANPiShark_Overview.png)

It is hoped this more flexible approach will enable easier development for other platforms to utlise the WLANPi as a remote probe capture device. Additional scripts will be added to this project over time to provide remote probe capture capability for other operating systems and software packages. 

The scripts/batch files that are used by this project are listed below. Each has its own dedicated page detailing its installation and operation:


- [WLANPiShark.bat](https://github.com/WLAN-Pi/WLANPiShark2/blob/master/doc/WLANPiShark.bat.md) : the Windows batch file to be run on a Windows machine
- [wlanpishark.py](https://github.com/WLAN-Pi/WLANPiShark2/blob/master/doc/wlanpishark.py.md) : Python script that is installed on the WLAPNPi and iscalled from the batch to execute all WLANPi setup commands and initiate a tcpdump stream

# Quick Setup

## wlanpishark.py

(Note: if you are running WLANPi image v1.6.1 or later, this script is already installed on the WLANPi)

1. SSH to your WLANPi (login with the 'wlanpi' user account)
2. Create a directory called /home/wlanpi/wlanpishark : mkdir ~/wlanpishark
3. Change in to the newly created directory: cd ./wlanpishark
4. Copy the wlanpishark.py to the newly created directory on the WLANPi (e.g. use SFTP utlity)
5. Make the wlanpishark.py script executable : chmod a+x ./wlanpishark.py

## WLANPiShark.bat

1. Copy the WLANPiShark.bat on to a Windows machine
2. Edit the file variables to suit the local machine environment (e.g. using Notepad)
3. Execute the batch file in a Windows command console

(See the dedicated batch file page for full details: [WLANPiShark.bat](https://github.com/WLAN-Pi/WLANPiShark2/blob/master/doc/WLANPiShark.bat.md))

### Examples

Capture on channel 36 using a 40MHz channel width:

```
 WLANPiShark.bat -c 36 -w 40+
```

Check config settings:

```
 WLANPiShark.bat --diag
```

Use in interactive mode:

```
 WLANPiShark.bat --int
```

# Current Version

The current version is v0.03. Check your version with the CLI command:

```
 WLANPiShark.bat -v
```

# Known Issues

There have been a few reports of users seeing error messages reported by Wirehark relating to "data written to the pipe not being a supported pcap or pcapng format" being reported by Wireshark. 

This is caused by a newer version of Plink.exe than we originally used in our testing. There are no issues with version 0.7.0. Later versions (i.e. 0.7.1 and later) cause an issue due to a new security checking option ("-no-antispoof"). 

Downgrading your version of Plink (by downloading an older version of Putty) to 0.7.0 fixes the issue. 

A better option is to upgrade your WLANPiShark.bat file to version 0.02 (or later) as it detects your Plink version and works around the Plink issue automatically. There is no need to change anything on the WLANPi, just download the current [WLANPiShark.bat](https://github.com/WLAN-Pi/WLANPiShark2/blob/master/WLANPiShark.bat) file, configure it as per your previous copy on your Windows machine, and run it as before.

You can check your version of Plink by running "plink.exe -V" from a Windows command prompt.

# Release Notes
```
#################################################################
# 
# Version history;
# 
# v0.01 - N.Bowden 17th Feb 2019
#
#        Initial release of spin-off from original WLANPIShark
#        project. Now relies on having wlanpishark.py file on
#        the remote WLANPi to speed up and simplify operations.
# 
# v0.02 - N.Bowden 17th July 2019
#
#        1. Several reports of issues which turned out to be
#           an issue with a new "-no-antispoof" introduced in
#           Plink 0.71. issue did no affect Plink 0.70
#           Added version detection and a fix if version 0.71 to 
#           0.75 is detected (bit of future proofing in there...)
# 
#        2. Added new "--diag" CLI option to do some basic 
#           checks and dump out config data for bug/issue
#           reports
# 
# v0.03 - N.Bowden 18th July 2019
#
#        1. Added interactive mode to optionally allow entry of
#           channel number & width if INTERACTIVE var set to
#           non zero value (set to 1 for instance), or CLI option
#           "--int". Props to Paul Manders for the code & idea. Also
#           added diagnostics mode via CLI "--diag" option to show
#           if config vars configured correctly
#
#################################################################
```
