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

# Known Issues

There have been a few reports of users seeing error messages reported by Wirehark relating to the data written to the pipe not being a supported pcap or pcapng format. This is caused by a newer version of Plink.exe than we originally used in our testing. There are no issues with version 0.7.0. Later versions seem to cause an issue (i.e. 0.7.1 and later). Downgrading your version of Plink (by downloading an older version of Putty) to 0.7.0 fixes the issue.

You can check your version of Plink by running "plink.exe -V" from a Windows command prompt.

This issue is under investigation for a more useful fix....watch this space.
