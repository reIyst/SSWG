## Welcome to Keys.sh 
* ###### :warning: Tested on OpenWrt 22.03.3 : Netgear WAX202, MikroTik RouterBOARD 951Ui-2nD (hAP) :warning:
* Use custom DNS servers on `if wg0` has DNSSEC and DNSSEC check unsigned :heavy_check_mark: : `dnsmasq-full - 2.86-13` package.
* If deciding to run with DNSSEC you'll need `dnsmasq` to be uninstalled and `dnsmasq-full` installed. [Link](https://github.com/openwrt/packages/tree/master/net/stubby/files#:~:text=Both%20options%20are%20detailed%20below%2C%20and%20both%20require%20that%20the%20dnsmasq%20package%20on%20the%20OpenWRT%20device%20is%20replaced%20with%20the%20dnsmasq%2Dfull%20package.%20That%20can%20be%20achieved%20by%20running%20the%20following%20command%3A)  : Right Click/Open New Tab to go to highlighted section. 
* `opkg update`
* `opkg install dnsmasq-full --download-only && opkg remove dnsmasq && opkg install dnsmasq-full --cache . && rm *.ipk`

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
## Usage Fresh Run
___
###### I just flashed my router.  Bare-bones till online via `keys.sh -n` ~ 17 minutes :3rd_place_medal:    You Can Be Better! :1st_place_medal:

* `opkg update`   `opkg install diffutils curl jq ntpdate`
* `mkdir -p /wg/` Edit your `sswg.json` with your up-to-date SurfShark VPN account creds:
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


`opkg update`   `opkg install luci-app-wireguard`

* Reboot your system so the above packages can manifest in Luci.
###### ssh into your router's ip and issue the command from the /wg dir `./keys.sh -n`
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
___

## [The Main Functions Explained Here](https://github.com/reIyst/SSWG/blob/main/README_SSWG.md#functions-explained)
___
### New Functions:

### wg0_new()
The function is calling all other MAIN funtions to do their job and pull in all the SurfShark goodness.  Addionally; one peer, with all the setting needed to get online WireGuard/SurfShark style fast is configured therein.  A custom `if` name `config wireguard_wg0 'peertorc'` that allows for the use of [peer swapping](https://github.com/reIyst/SSWG/blob/main/Interface%20'wg0'%20Endpoint%20Swap.md#installing-wout-peer1-and-with-multi-peer-for-uci-cli-swapping) via cli.  Your script can be modified in this section to suit your needs.  Learn the `uci` paramaters. This can be studied via the LuCi save view in the upper right hand corner before you hit `Save and Apply`.  This is true no matter if you are adding or deleting item from your web session in LuCi.  Just look at what is being held in the pre-commit stage ~ copy/paste into an editor of choice and learn your way thru it. 

### reset_keys()
Quick/Quiet removal of the `/wg/conf/` folder, `wg.json` , `token.json` , `surfshark_servers.json` . Leaving `keys.sh` , `sswg.json` , and all user placed item not mentiond here. 




***
____
### Copyright and Attribution of developed software, tool, logo, names are the right of the following entities respectively.  
![Image](https://openwrt.org/_media/logo.png "OpenWrt Logo") CC Attribution-Share Alike 4.0 International


![Image](https://surfshark.com/wp-content/themes/surfshark/assets/img/logos/logo.svg)  © 2023 Copyright Surfshark. All rights reserved.

![Image](https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Logo_of_WireGuard.svg/330px-Logo_of_WireGuard.svg.png)  © Copyright 2015-2022~3 Jason A. Donenfeld. All Rights Reserved. "WireGuard" and the "WireGuard" logo are registered trademarks of Jason A. Donenfeld.
***
____










##### Tested on Netgear WAX202, MikroTik RouterBOARD 951Ui-2nD (hAP) : OpenWrt 22.03.3

###### ....ohh EOF or Easter Egg?    Quick Run...Have needed web pages open for cheet sheets, make a current `backup-OpenWrt-2022-now-now.tar.gz`:stopwatch: Flash your system (only if part of plan)..:play_or_pause_button:..SSH via Putty into 192.168.1.1 `opkg update` :arrow_forward: ``opkg install dnsmasq-full --download-only && opkg remove dnsmasq && opkg install dnsmasq-full --cache . && rm *.ipk`` :twisted_rightwards_arrows: during the opkg sessions make use of time by copying item from your backup to your new install: IE `rc.local crontab/root etc/config/system...`  :arrow_forward: ` opkg install diffutils curl jq ntpdate` :twisted_rightwards_arrows:  `opkg install luci-app-wireguard`:twisted_rightwards_arrows: WinSCP into 192.168.1.1 and create `/wg/` directory and move your `keys.sh` and `sswg.json` files, right click on script and set executable or cli `chmod +x keys.sh`. Check opkg and if done, run `./keys.sh -n` till done;issue command `wg show` and :stopwatch: !!  Navigate via WinSCP to `/etc/config/network` set the subnet you desire/save and `REBOOT` via Putty or the WinSCP Command windowlet. Release any device IP that got a dhcp addy from OpenWrt's install and kill your Putty/WinSCP session that were on the 192.168.1.0/24 subnet. 
###### You will be better!

