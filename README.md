    SSWG ~ SurfShark WireGuard ~ is a terminal script to curl the 'api.surfshark.com' The main fuctions are:
        read_config(), do_login(), get_servers(), gen_keys(), reg_pubkey(), gen_client_confs()

    The Fuctions explained:
    read_config()
    looks for the paramaters set forth in two files: sswg.sh and sswg.json
    On line 68 of the sswg.sh >config_file="/wg.sswg.json" asks for user credential and a pre set path to populate
    further into the processing. Being that line 68 is in itself a pre set path may add
    confusion, yet if one were to set line 68 to a different loction
    EX. /etc or /etc/config the sswg.json file must be edited to follow.
    These file can be renamed to your liking, HOWEVER line 68 of sswg.sh has to know what you renamed sswg.json
    Once this infomation is proccessd initially the script loads the 9 lines of translation and definition of paths.

    do_login()
    The login function is being passed info that was processed curling the api with your user/pass data
    This is where it is looking to see if you passed the https challenges and recieved a token currently called "JWT Token"
    The login does not invoke if a token.json file is found until the script parses over said file and verifies it's
    authenticity. The script will verify it, delete it or complain that you're bombing the server
    and 429 you for some duration. All important code swapping, you give creds, you get "JWT Token"
    simple yet frustrating if you earn yourself a 429 time-out.
    Visit SurfShark's guide logging in for more info.  The 411 on this change your ip.
    https://support.surfshark.com/hc/en-us/articles/360010864959-How-to-fix-website-app-login-issues-

    get_servers()
    Your token grants the further step in fetching server currently using the WireGuard protocol,
    curling in and formating this date with jq functions, echo commands. Made tempfiles are then passed
    data along the scripts chain of events. It's worth noting the combined two function from a previous script.
    get_servers() and select_servers()  This refined "get_servers()" function
    checks for existing data on your system and diff it against the jq fetched data looking for any changes in the files.
    Most notable would be "load" changes as most of the other parameters are static ie server name, country, key, etc..

    gen_keys()
    Function is checking for existance of your systems keys if not found ~ either because you've never used
    a script before, or deleted file unwittingly; it proceed to rectify this situation by getting a fresh set.

    reg_pubkey()
    This is fun section because of all the different varialble that could ruin your day,
    or give you a victory lap clap.  Echo request are reused to promote the expire date for later use in your
    logger to be viewed in you system logs via command logread.  If you feel jilted or have problems check
    https://support.surfshark.com/hc/en-us/articles/360010864959-How-to-fix-website-app-login-issues-
    The 411 on this is -get a different ip- ie change vpn servers, go naked via IPS or use your cell data.

    gen_client_confs()
    We need these file to plug in the juice to the various places that like individual server peer file,
    firstly our router; then maybe a wireguard app on your pc, tablet, iot device. This was important enough to
    me that I combined the best of all current scripts I had been exposed to and had experience with into this.

    That about sums up the funtions: Verbosity is king in this script and it wouldn't have happened unless other people knew THIS FACT!
    
     Why is this script better in my opinion: It combines the swiftness of @Patrickm hacks running without the -g
     ~ The Verbosity Needed to understand the who, what , when, where, why, how from: Verbosity
     And it's debugged ~ forcing error condition to test for insight | and fixing them.


    This work is a combiation of forked scripts.
    (Yanzdan ~ Base)
    (Patrickm ~ Verbosity!! jq | Renewal, json output)
    (RuralRoots ~ Verbosity!!!, since base script landed)
    (Bill ~ Verbosity, DEBUG, 'opkg diffutils requirement, merge, testing, README)


    opkg update opkg install diffutils curl jq

    ./sswg.sh -g  will produce all connection files w/ pvt keys needed to configure your router,or import in WireGuard's desktop app.
