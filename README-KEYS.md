## Welcome to Keys.sh 
* ###### :warning: Tested on OpenWrt 22.03.0-rc6 : MikroTik RouterBOARD 951Ui-2nD (hAP) : YMMV :warning:
* :on: Use custom DNS servers on `if wg0` has DNSSEC and DNSSEC check unsigned :heavy_check_mark: : `dnsmasq-full - 2.86-13` package :on:

###### New Setup: Interface "wg0" in the `WAN` zone firewall and Toronto peer activated!
###### Use LuCi Interface Settings to drag-n-drop new conf.

Import configuration
`Load configuration…`
Imports settings from an existing WireGuard configuration file.
___
## Your Options

```
 "	 ####		Switch -'option'		####	"
 " ____________________________________________________________"
 ""
 " '-n'  : eg : ./keys.sh -n :New Setup Establish "
 " '-d'  : eg : ./keys.sh -d :Delete 'wg0' and trace settings "
 " '-g'  : eg : ./keys.sh -g :Generate Server conf "
 " '  '  : eg : ./keys.sh    :Extend Key Duration "
 " ____________________________________________________________"
```
___


## Usage Inline (existing `/wg` install)
___
* If your are considering using this with a current install:  Save your `wg.json` file before running `keys.sh -d` .
* The `keys.sh -d` will only remove from `/etc/config/network` and `/etc/config/firewall` what the `keys.sh -n` command implanted. 
*  However, it will wipe the /wg/ directory of `token.json` , `wg.json` , `surfshark_servers.json` , and the `/wg/conf/*` directory. 
###### Backup if unsure!
___

Safe usage of `keys.sh` inline with a current install would be to run with option: 
* `./keys.sh -g` "Generate Server conf" or 
* `./keys.sh` "Extend Key Duration".
Those commands are considered standard option is `sswg.sh`. 
___
## Usage Fresh Run (I just flashed my router..)
``opkg update opkg install diffutils curl jq ntpdate``
`mkdir -p /wg/` Edit your `sswg.json` with your up-to-date SurfShark VPN account creds:
```
##############################  Example of sswg.json  ##############################################
# {
#    "config_folder": "/wg",
#    "username": "user@neverland.com",
#    "password": "admin"
# }
###################################################################################################
```
Transfer `sswg.json` and `keys.sh` to `/wg/` dir. 
`chmod +x keys.sh` allows script to be executable. 


```opkg update opkg install luci-app-wireguard; luci-proto-wireguard; wireguard-tools; kmod-wireguard```

* Reboot your system so the above packages can manifest in Luci.
___
![Image](https://github.com/reIyst/SSWG/blob/main/2022-08-05_192401.jpg)
___
___
![Image](https://github.com/reIyst/SSWG/blob/main/2022-08-05_192416.jpg)
___
___
![Image](https://github.com/reIyst/SSWG/blob/main/2022-08-05_192418.jpg)
___
___
![Image](https://github.com/reIyst/SSWG/blob/main/2022-08-05_192540.jpg)
___
___
![Image](https://github.com/reIyst/SSWG/blob/main/2022-08-05_192554.jpg)
___







***
____
### Copyright and Attribution of developed software, tool, logo, names are the right of the following entities respectively.  
![Image](https://openwrt.org/_media/logo.png "OpenWrt Logo") CC Attribution-Share Alike 4.0 International


![Image](https://surfshark.com/wp-content/themes/surfshark/assets/img/logos/logo.svg)  © 2022 Copyright Surfshark. All rights reserved.

![Image](https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Logo_of_WireGuard.svg/330px-Logo_of_WireGuard.svg.png)  © Copyright 2015-2022 Jason A. Donenfeld. All Rights Reserved. "WireGuard" and the "WireGuard" logo are registered trademarks of Jason A. Donenfeld.
***
____










##### Tested on MikroTik RouterBOARD 951Ui-2nD (hAP) : OpenWrt 22.03.0-rc6
