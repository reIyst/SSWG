# [OpenWrt ](https://forum.openwrt.org/t/create-surfshark-wireguard-connection-on-openwrt-easily/111866/150) SurfShark WireGurard ~ [SSWG](https://forum.openwrt.org/t/create-surfshark-wireguard-connection-on-openwrt-easily/111866/127)

## A shell script and companion file to curl the 'api.surfshark.com'.
#### Prerequisite: One must have an up-to-date SurfShark VPN account and Luci/uci access to router. Beyond the scope of this README is also having WireGuard installed.  A good place to start is on the [OpenWrt Wiki](https://openwrt.org/docs/guide-user/services/vpn/wireguard/client#preparation) for a baseline install, then unto the [Web Interface](https://openwrt.org/docs/guide-user/services/vpn/wireguard/extras#web_interface).

## Installation Requirements
`opkg update ; opkg install diffutils curl jq ntpdate`
## Usage found within the shell script remarks.
![#c5f015](https://via.placeholder.com/15/c5f015/000000?text=+) Make the shell script executable 
 ``
 chmod +x sswg.sh  
 ``
 
`./sswg.sh -g`  Is the first run application and will produce all connection files w/ pvt keys needed to configure your router, and/or import in WireGuard's desktop app.

`./sswg.sh`  Is the basic run and will contact the base api to register public keys and extend the expiration date of keys found in the wg.json file if already present.





## The main functions are:
###    read_config(), do_login(), get_servers(), gen_keys(), reg_pubkey(), gen_client_confs()

## Functions explained:
##  read_config()
Looks for the parameters set forth in two files: sswg.sh and sswg.json
On line 68 of the sswg.sh >config_file="/wg.sswg.json" asks for user credential and a pre set path to populate
further into the processing. Being that line 68 is in itself a pre set path may add
confusion, yet if one were to set line 68 to a different location
EX. /etc or /etc/config the sswg.json file must be edited to follow.
These file can be renamed to your liking, HOWEVER line 68 of sswg.sh has to know what you renamed sswg.json
Once this information is processed initially the script loads the 9 lines of translation and definition of paths.

##  do_login()
The login function is being passed info that was processed curling the api with your user/pass data
This is where it is looking to see if you passed the https challenges and received a token currently called "JWT Token"
The login does not invoke if a token.json file is found until the script parses over said file and verifies it's
authenticity. The script will verify it, delete it or complain that you're bombing the server
and 429 you for some duration. All important code swapping, you give creds, you get "JWT Token"
simple yet frustrating if you earn yourself a 429 time-out.
Visit SurfShark's guide logging in for more info.  The 411 on this change your ip.
[SurfShark How to Fix](https://support.surfshark.com/hc/en-us/articles/360010864959-How-to-fix-website-app-login-issues-)

##  get_servers()
Your token grants the further step in fetching server currently using the WireGuard protocol,
curling in and formatting this date with jq functions, echo commands. Made tempfiles are then passed
data along the scripts chain of events. It's worth noting the combined two function from a previous script.
get_servers() and select_servers()  This refined "get_servers()" function
checks for existing data on your system and diff it against the jq fetched data looking for any changes in the files.
Most notable would be "load" changes as most of the other parameters are static ie server name, country, key, etc..

##  gen_keys()
Function is checking for existence of your systems keys if not found ~ either because you've never used
a script before, or deleted file unwittingly; it proceed to rectify this situation by getting a fresh set.

##  reg_pubkey()
This is fun section because of all the different variables that could ruin your day,
or give you a victory lap clap.  Echo request are reused to promote the expire date for later use in your
logger to be viewed in you system logs via command logread.  If you feel jilted or have problems check
[SurfShark How to Fix](https://support.surfshark.com/hc/en-us/articles/360010864959-How-to-fix-website-app-login-issues-)
The 411 on this is -get a different ip- ie change vpn servers, go naked via IPS or use your cell data.

##  gen_client_confs()
We need these file to plug in the juice to the various places that like individual server peer file,
firstly our router; then maybe a wireguard app on your pc, tablet, iot device. This was important enough to
me that I combined the best of all current scripts I had been exposed to and had experience with into this.

## A  Few Words About `ntpdate`
`ntpdate` has been added as a requirement to synchronize the date on the router prior to running the main functions within the script. This is introduced to ensure the router has corrected time before it sends your credentials to the api. 

I don't know of any consumer grade routers that have a RTC (real time clock) ~ batteries not included.  Since this is true in my case, and since WireGuard's handshake is time sensitive; two safeguards are implemented. Hence the usage of `ntpdate` within the script, and optionally upon the router's `etc/rc.local` a command `ntpd -d -n -q -N -I xxxx -p 162.159.200.123 -p 203.114.74.17` where `xxxx` is the router's interface wan port. This command will request ntpd time adjustments via ip addressed pools after all other services have loaded.


##  Summation
Verbosity is king in this script and it wouldn't have happened unless other people knew THIS FACT!
This script achievements: it combines the base files of @yanzdan api code with the  swiftness of @trickapm aka patrickm hacks running without the `-g`, the Verbosity of @ruralroots inclusions needed to understand the who, what , when, where, why, how.  It's being actively debugged ~ forcing error condition to test for insight | and fixing them.


## Sources 
This work is a culmination of scripts.
* [yanzdan](https://github.com/yazdan/openwrt-surfshark-wireguard)
* [trickapm](https://gist.github.com/trickapm)
* [ruralroots](https://github.com/ruralroots/openwrt-surfshark-wireguard)


## Etcetera
### Cron Job
Thursday Key Reinstate Sunday conf files download and Key Reinstate

```
15 00 * * 4 /wg/sswg.sh >/wg/wg.log 2 >&1 # standard registration and Redirect standard output to file '>' to log midnight+15min Thurs
15 00 * * 0 /wg/sswg.sh -g >>/wg/wg.log 2 >&1 # servers conf files dwl and Append standard output to file '>>' to log midnight+15min Sunday
```


