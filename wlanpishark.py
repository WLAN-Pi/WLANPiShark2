#!/usr/bin/python
'''
    wlanpishark.py - Script to stream TCP dump to stdout on a WLANPi
    
    This script needs to called via an SSH session from a remote machine
    (e.g. running Windows, Mac or Linux) that starts an SSH session, calls 
    this script and pipes the output in to Wireshark. 
    
    For more info, please see https://github.com/WLAN-Pi/WLANPiShark2
    
'''

import sys
import os
import getopt
import subprocess

__author__ = 'Nigel Bowden'
__version__ = '0.01'
__email__ = 'wifinigel@gmail.com'
__status__ = 'beta'

# we must be root to run this script - exit with msg if not
if not os.geteuid()==0:
    print("\n#####################################################################################")
    print("You must be root to run this script (use 'sudo wlanpishark.py') - exiting" )
    print("#####################################################################################\n")
    sys.exit()

# Initialize variables in case we do not get any parameters passed to us
WLAN_PI_IFACE = 'wlan0'
CHANNEL_WIDTH = 'HT20'
CHANNEL_NUMBER = '36'
SLICE = '0'
FILTER = ' '
DEBUG = False

def usage():

    print("\n Usage:\n")
    print("    wlanpishark.py -i <interface name> -c <channel> -w <channel width> -s <slice value> -f <filter definition>")
    print("    wlanpishark.py -h")
    print(" ")
    sys.exit()

# proces sthe CLI parameters passed to this script 

try:
    opts, args = getopt.getopt(sys.argv[1:],'i:w:c:s:f:hdv')
except getopt.GetoptError:
    print("\nOops...syntaxt error, please re-check: \n")
    usage()

if DEBUG:
    print("Received args: ")
    print(sys.argv[1:])
    
for opt, arg in opts:
    if opt == '-h':
        usage()
    elif opt == ("-d"):
        DEBUG = True
    elif opt == ("-v"):
        print("\nwlanpishark.py version: {}\n".format(__version__))
        sys.exit()
    elif opt == ("-i"):
        WLAN_PI_IFACE = arg
    elif opt in ("-w"):
        CHANNEL_WIDTH = arg
    elif opt in ("-c"):
        CHANNEL_NUMBER = arg
    elif opt in ("-i"):
        WLAN_PI_IFACE = str(arg)
    elif opt in ("-s"):
        SLICE = arg
    elif opt in ("-f"):
        # horrible kludge to get rest of cli params due to useage of shell
        filter_args = [arg] + args
        filter_str = " ".join(filter_args)
        FILTER = '"{}"'.format(filter_str)

# These are the commands to get the WLANPi ready to stream the tcpdump data
commands_list = [
    [ 'Killing old tcpdump processes...', '/usr/bin/pkill -f tcpdump > /dev/null 2>&1'],
    [ 'Killing processes that may interfere with airmon-ng...', 'airmon-ng check kill > /dev/null 2>&1' ],
    [ 'Bringing WLAN card up...', 'ifconfig {} up'.format(WLAN_PI_IFACE) ],
    [ 'Setting wireless adapter to monitor mode', 'iw {} set monitor none'.format(WLAN_PI_IFACE) ],
    [ 'Setting wireless adapter to channel {} (channel width {})'.format(CHANNEL_NUMBER, CHANNEL_WIDTH), 'iw {} set channel {} {}'.format(WLAN_PI_IFACE, CHANNEL_NUMBER, CHANNEL_WIDTH) ],
    
]

# execute each command in turn
for command in commands_list:

    if DEBUG:
        print(command[0])
        print("Command : " + str(command[1]))

    try:
        cmd_output = subprocess.call(command[1], shell=True)
        if DEBUG:
            print("Command output: " + str(cmd_output))
    except Exception as ex:
        if DEBUG:
            print("Error executing command: {} (Error msg: {})".format(command[1], ex))

# Launch tcpdump using passed parameters (unless we're running in debug)
if DEBUG == False:
    msg = 'Lauching tcpdump...'
    subprocess.call('tcpdump -n -i {} -U -s {} -w - {}'.format(WLAN_PI_IFACE, SLICE, FILTER), shell=True)
