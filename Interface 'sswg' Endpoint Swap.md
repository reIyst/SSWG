![image](https://avatars.githubusercontent.com/u/102527325?s=48&v=4) _This README is dedicated to making a cli uci install of the Wireguard services and sswg script to enable one to swap endpoint easily and quickly.  The front end work is lengthy, mostly reading; yet the outcome is well worth the time, especially since most of the work of configuration is `uci set`. Enjoy!_
# OpenWrt SurfShark WireGurard ~ SSWG 
### Have the requirements to run the script
___
``opkg update`` 
``opkg install diffutils; curl; jq; ntpdate``

:eight_spoked_asterisk:_You can install and run the script to obtain the keys within the `wg.json` file prior to doing Multi Peer section._


From the [reIyst SSWG](https://github.com/reIyst/SSWG/releases/tag/OpenWrt_Wireguard_Surfshark) download the ['sswg.sh'](https://github.com/reIyst/SSWG/releases/download/OpenWrt_Wireguard_Surfshark/sswg.sh) and ['sswg.json'](https://github.com/reIyst/SSWG/releases/download/OpenWrt_Wireguard_Surfshark/sswg.json) files.[^1] If you have WinSCP your day is made easy. SSH into your router via WinSCP/Putty and create the folder structure. Copy the two files into the 'wg' directory and make the sswg.sh file executable. `./sswg.sh -g`  Is the first run application and will produce all connection files w/ pvt keys needed to configure your router, and/or import in WireGuard's© desktop app.
  
``mkdir -p /wg/``

``chmod +x sswg.sh``

``./sswg.sh -g``
____
# Multi (Peer) for interface named 'sswg'
### Have the requirements to use Luci/uci WireGuard©
``opkg update``
``opkg install luci-app-wireguard;  luci-proto-wireguard;  wireguard-tools; kmod-wireguard``
* Reboot your system so the above packages can manifest in Luci.

### Installing w/out Peer(1) and with Multi Peer for uci cli Swapping.
**Follow the Templet** Use all or at least two, or configure your own within the file templet. Double check the `wan.metric='10'` to ensure metric 10 is not already in use ``ip route show default`` ; modify accordingly.  ***All public key are dummy. Until changed with legitimate pub key from your downloaded client conf files; you will be without :surfer: Internet access.[^2]***

```
cd /
uci set network.wan.metric='10'

uci set network.sswg=interface
uci set network.sswg.proto='wireguard'
uci set network.sswg.listen_port='51820'
uci set network.sswg.addresses='10.14.0.2/8'
uci set network.sswg.private_key=$(eval echo $(jq '.prv' ./wg/wg.json))	
uci commit network


uci set network.peerchiu='wireguard_sswg'
uci set network.peerchiu.description=peerchiu
uci set network.peerchiu.public_key=placeholderVHmt3AX4dqLqcyE0dpPqYBjDlWMaUTAG=
uci add_list network.peerchiu.allowed_ips='0.0.0.0/0'
uci add_list network.peerchiu.allowed_ips='::/0'
uci set network.peerchiu.route_allowed_ips='1'
uci set network.peerchiu.endpoint_host=us-chi.prod.surfshark.com
uci set network.peerchiu.endpoint_port='51820'
uci set network.peerchiu.persistent_keepalive='25'
uci commit network

uci set network.peerdalu='wireguard_sswg'
uci set network.peerdalu.description=peerdalu
uci set network.peerdalu.public_key=placeholderg38ogv4g4XMLJa51YqWY/yKWR9UEUTAG=
uci add_list network.peerdalu.allowed_ips='0.0.0.0/0'
uci add_list network.peerdalu.allowed_ips='::/0'
uci set network.peerdalu.route_allowed_ips='1'
uci set network.peerdalu.endpoint_host=us-dal.prod.surfshark.com
uci set network.peerdalu.endpoint_port='51820'
uci set network.peerdalu.persistent_keepalive='25'
uci commit network

uci set network.peernycu='wireguard_sswg'
uci set network.peernycu.description=peernycu
uci set network.peernycu.public_key=placeholder0zW3J0YXZK4aN3It7DD26TXlACuWTAG=
uci add_list network.peernycu.allowed_ips='0.0.0.0/0'
uci add_list network.peernycu.allowed_ips='::/0'
uci set network.peernycu.route_allowed_ips='1'
uci set network.peernycu.endpoint_host=us-nyc.prod.surfshark.com
uci set network.peernycu.endpoint_port='51820'
uci set network.peernycu.persistent_keepalive='25'
uci commit network

uci set network.peerwarp='wireguard_sswg'
uci set network.peerwarp.description=peerwarp
uci set network.peerwarp.public_key=placeholdertG64rHRLm085VMS2cAX2paeAaphB/TAG=
uci add_list network.peerwarp.allowed_ips='0.0.0.0/0'
uci add_list network.peerwarp.allowed_ips='::/0'
uci set network.peerwarp.route_allowed_ips='1'
uci set network.peerwarp.endpoint_host=pl-waw.prod.surfshark.com
uci set network.peerwarp.endpoint_port='51820'
uci set network.peerwarp.persistent_keepalive='25'
uci commit network

uci set network.peertorc='wireguard_sswg'
uci set network.peertorc.description=peertorc
uci set network.peertorc.public_key=placeholder64vDpB4pbrz8QafNn3y5P9Yc/kQvyTAG=
uci add_list network.allowed_ips='0.0.0.0/0'
uci add_list network.allowed_ips='::/0'
uci set network.peertorc.route_allowed_ips='1'
uci set network.peertorc.endpoint_host=ca-tor.prod.surfshark.com
uci set network.peertorc.endpoint_port='51820'
uci set network.peertorc.persistent_keepalive='25'
uci commit network
/etc/init.d/network restart
```
[^1]: Remember the `sswg.json` file needs your personal [attention](https://github.com/reIyst/SSWG/blob/d92faa50f6f9f8a390c755cc932cf4958ec4fddf/sswg.sh#L19).
[^2]: Remember to use the PubKey from your downloaded server configs `/wg/conf/`.
 
***
____

##  To minimize Firewall setup; Consider VPN network as public. Assign VPN interface to WAN zone.

```
uci add_list firewall.wan.network="sswg"
uci commit firewall
/etc/init.d/firewall restart
```


***
____
# Swapping 
## Uci CLI Peer Swapping
### The peer swapping is achieved by placing the desired peer config in the last/bottom order of the `/etc/config/network` file. The high arbitrary number '99' should suffice to place desired network peer at bottom. My personal config has only 15. The resulting command will also be represented in the Wireguard Status, Interface Peer Pages of Luci.  Simple command, long description. 
From the above install, Toronto Canada is the last peer installed and will be the default route the sswg vpn tunnels through.  By running the below command the Warsaw Poland endpoint takes the bottom position and becomes sswg vpn tunnel. **This is achieved from the `network.peerwarp` NETWORK not the description=peerwarp!** A look at your `/etc/config/network` file will enlighten your understanding later.

###### Warsaw :surfer:
```
uci reorder network.peerwarp=99;uci commit network;/etc/init.d/network restart
```
###### Chicago :surfer:
```
uci reorder network.peerchiu=99;uci commit network;/etc/init.d/network restart
```
###### Dallas :surfer:
```
uci reorder network.peerdalu=99;uci commit network;/etc/init.d/network restart
```
###### New York :surfer:
```
uci reorder network.peernycu=99;uci commit network;/etc/init.d/network restart
```
###### Toronto :surfer:
```
uci reorder network.peertorc=99;uci commit network;/etc/init.d/network restart
```

## Common uci commands for introspective users.

```ip rule```
```wg.show```
```ip route show default```
```ubus call system board; uci export dhcp; uci export network; uci export firewall```


***
____
### Copyright and Attribution of developed software, tool, logo, names are the right of the following entities respectively.  
![Image](https://openwrt.org/_media/logo.png "OpenWrt Logo") CC Attribution-Share Alike 4.0 International


![Image](https://surfshark.com/wp-content/themes/surfshark/assets/img/logos/logo.svg)  © 2023 Copyright Surfshark. All rights reserved.

![Image](https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Logo_of_WireGuard.svg/330px-Logo_of_WireGuard.svg.png)  © Copyright 2015-2023 Jason A. Donenfeld. All Rights Reserved. "WireGuard" and the "WireGuard" logo are registered trademarks of Jason A. Donenfeld.
***
____
