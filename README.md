       SSWG ~ SurfShark WireGuard ~ is a terminal script to curl the 'api.surfshark.com' The main fuctions are:
            read_config(), do_login(), get_servers(), gen_keys(), reg_pubkey(), gen_client_confs()	

        The Fuctions explained: 
        read_config()
        looks for the paramaters set forth in two files: sswg.sh and sswg.json 
        On line 68 of the sswg.sh >config_file="/wg.sswg.json" asks for
        user credential and a pre set path to populate further into the processing. Being that line 68 is in itself a pre set path may add
        confusion, yet if one were to set line 68 to a different loction EX. /etc or /etc/config the sswg.json file must be edited to follow.
        These file can be renamed to your liking, HOWEVER line 68 of sswg.sh has to know what you renamed sswg.json
        Once this infomation is proccessd initially the script load the 9 lines of translation and definition of paths.
        
        do_login()
        The login function is being passed info that was processed curling the api with your user/pass data
        This is where it is looking to see if you passed the https challenges and recieved a token currently called "JWT Token"
        all important code swapping, you give creds, you get "JWT Token" simple yet frustrating. SurfShark's guide logging in
        https://support.surfshark.com/hc/en-us/articles/360010864959-How-to-fix-website-app-login-issues-
        
        get_servers()
        Your token grants the further step in server currently using the WireGuard protocal curling in and formating this date with 
        jq functions and echo command to store and pass data along the scripts chain of events. It's worth noting that this script 
        combined two function from a previous script. get_servers() and select_servers()  This refined "get_servers()" function
        checks for existing data on your system and diff it against the jq fetched data looking for any changes in the files.
        Most notable would be "load" changes as most of the other parameters are static ie server name, country, key, etc..
        
        gen_keys()
        Function is checking for existance of your systems keys if not found ~ either because you've never used a script before, or deleted
        file unwittingly; it proceed to rectify this situation by getting a fresh set.
        
        reg_pubkey()
        This is fun section because of all the different varialble that could ruin your day, or give you a victory lap clap echoing the
        expire date for later use in your logger to be viewed via command logread.  If you feel jilted or have problems check
        https://support.surfshark.com/hc/en-us/articles/360010864959-How-to-fix-website-app-login-issues-
        The 911 on this is -get a different ip- ie change vpn servers, go naked via IPS or use your cell data. Or just sleep it off and wait.
        
        gen_client_confs()
        We need these file to plug in the juice to the various places that like individual server peer file, firstly our router; then maybe a 
        wireguard app on your pc, tablet, iot device. 
        
        That about sums up the funtions: Verbosity is king in this script and it wouldn't have happened unless other people knew THIS FACT!
        
             
        This work is a combiation of forked scripts. 
        (Yanzdan ~ Base) 
        (Patrickm ~ Verbosity!! jq | Renewal, json output)
        (RuralRoots ~ Verbosity!!!, since base script landed)
        (Bill ~ Verbosity, DEBUG, 'opkg diffutils requirement, merge, testing, README)
        
        
        opkg update opkg install diffutils curl jq  
        
        ./sswg.sh -g  will produce all connection files w/ pvt keys needed to configure your router,or import in WireGuard's desktop app.
        
        
        
 Why is this script better in my opinion: It combines the swiftness of @Patrickm hacks running without the -g
 ~ The Verbosity Needed to understand the who, what , when, where, why, how from: Verbosity
 And it's debugged ~ forcing error condition to test for insight | and fixing them. 
        

SHELL SCRIPT HAD REDACTED BUT INFORMATIVE README. 

Script default name .json files renamed to NOT conflict with exisiting install.
Also a static path has been added. 
