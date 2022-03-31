# SSWG
This is a repository that helps you setup surfshark's wireguard on openwrt
# This work is a combiation of forked scripts. 
# (Yanzdan ~ Base) 
# (Patrickm ~ Verbosity!! jq | Renewal, json output) 
# (RuralRoots ~ Verbosity!!!, since base script landed)
# (Bill ~ Verbosity, DEBUG, 'opkg diffutils requirement, merge, testing, README)  
#
#
# opkg update 
# opkg install diffutils curl jq
#    
# ./sswg.sh -g  will produce all connection files w/ pvt keys needed to configure your router,
#  or import in WireGuard's desktop app.


SHELL SCRIPT HAD README IN FURTHER DEPTH. 

Script default name .json files renamed to NOT conflict with exisiting install.
Also a static path has been added. 
