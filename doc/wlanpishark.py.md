# wlanpyshark.py

TBA - development in progress

# Usage

```

 Usage:

    wlanpishark.py -i <interface name> -c <channel> -w <channel width> -s <slice value> -f <filter definition>
    wlanpishark.py -h

 Command line options:

    -c       Sets channel to capture on (valid values 1-13, 36-165)
    -i       Sets name of wireless interface on WLANPi (usually wlan0 with one adapter attached)
    -w       Set channel width to capture (valid values: 20, 40+, 40-, 80MHz
    -s       Frame capture slice size (0 = no slice, any other numeric value specifies slice size in bytes)
    -f       Filter definition to specify frames captured (uses tcpdump filter syntax - e.g. "wlan type mgt subtype beacon")
    -h       Help page

```



