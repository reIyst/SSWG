#!/bin/sh
# This work is a combiation of forked scripts. 
# (Yanzdan ~ Base) 
# (Patrickm ~ Verbosity!! jq | Renewal, json output) 
# (RuralRoots ~ Verbosity!!!, since base script landed)
# (Bill ~ Verbosity, DEBUG, 'opkg diffutils requirement, merge, testing, README)  
#
#
# opkg update 
# opkg install diffutils curl jq ntpdate
#    
# ./sswg.sh -g  will produce all connection files w/ pvt keys needed to configure your router,
#  or import in WireGuard's desktop app.
# Usage: in this example a directory was created /wg  
# This is where the sswg.sh and sswg.json files are run from, commonly call 'run directory'.
# 
# This location was arbitrarily chosen.  You may do differently, yet ALWAYS have both files present
# in the location you run from.  AND CHANGE LINE 68 TO FOLLOW YOUR RUN DIRECTORY!!  
# Fill in you sswg.json file w/ the three necessary input rundirectory/user/pass
# Whenever you get a NEW wg.json file, this file holds the Pvt Key necessary to configure uci/luci
##############################  Example of sswg.json  ##############################################
# {
#    "config_folder": "/wg",
#    "username": "user@neverland.com",
#    "password": "admin"
# }
###################################################################################################
#
##########  WORK SHOWN   ##########################################################################
#
# root@Dachshund:/wg# cd //
# root@Dachshund:/# ls
# bin  dev  etc  lib  mnt  overlay  proc  rom  root  sbin  sys  tmp  usr  var  wg  www
# root@Dachshund:/# cd /wg
# root@Dachshund:/wg# ls
# sswg.json  sswg.sh
# root@Dachshund:/wg# ./sswg.sh
# Running at Thu Mar 31 17:36:22 EDT 2022
# Generating WireGuard keys...
#  Using public key: S9tHLNTrijYphXGxxxxxxxxCcnii4mIopRtS8w652Gs=
# Logging in...
#  HTTP status OK
# Registering public key...
#  OK (expires: 2022-04-07T21:36:31+00:00, id: 3fea6527-0ae6-44af-9308-d378c49bfefb)
# Running at Thu Mar 31 17:36:35 EDT 2022
# Enjoy!
# root@Dachshund:/wg# ./sswg.sh -g
# Running at Thu Mar 31 17:36:54 EDT 2022
# WireGuard keys "/wg/wg.json" already exist
#   Using public key: S9tHLNTrijYphXGxxxxxxxxCcnii4mIopRtS8w652Gs=
# Token file "/wg/token.json" exists, skipping login
# Registering public key...
#   Already registered
#   Renewed! (expires: 2022-04-07T21:37:05+00:00)
# Retrieving servers list...
#   HTTP status OK (122 servers downloaded)
#   Selecting suitable servers... (98 servers selected)
# generating config for al-tia.prod.surfshark.com
# generating config for au-syd.prod.surfshark.com
# generating config for au-bne.prod.surfshark.com
# generating config for au-mel.prod.surfshark.com
# ....
###################################################################################################




config_file="/wg/sswg.json"

read_config() {
    conf_json=$(cat "$config_file")
    
    config_folder="$(echo "$conf_json" | jq -r '.config_folder')"
    username="$(echo "$conf_json" | jq -r '.username')"
    password="$(echo "$conf_json" | jq -r '.password')"
    baseurl="https://api.surfshark.com"
    token_file="${config_folder}/token.json"
    servers_file="${config_folder}/surfshark_servers.json"
    wg_keys="${config_folder}/wg.json"
    output_conf_folder="${config_folder}/conf"

 unset conf_json
}

do_login () {
    rc=1
    if [ -f "$token_file" ]; then
        echo "Token file \"$token_file\" exists, skipping login"
        rc=0
    else
        echo "Logging in..."
        tmpfile=$(mktemp /tmp/wg-curl-res.XXXXXX)
        url="$baseurl/v1/auth/login"
        data="{\"username\":\"$username\", \"password\":\"$password\"}"
        http_status=$(curl -o $tmpfile -s -w "%{http_code}" -d "$data" -H 'Content-Type: application/json' -X POST $url)
        if [ $http_status -eq 200 ]; then
            cp $tmpfile $token_file
                echo "  HTTP status OK"
            rc=0
        elif [ $http_status -eq 429 ]; then
            echo "  HTTP status $http_status (Blocked! Too many requests, Change VPN Server and Retry)"
        else
            echo "  HTTP status $http_status (Failed! Check username/password in .json file)"
        rm $tmpfile  ###  rm: can't remove '/tmp/wg-curl-res.bolbGP': No such file or directory ### Moved this rm command up to reslove. ###
        fi    
    fi
    
    if [ "$rc" -eq 0 ]; then
        token="$(jq -r '.token' "$token_file")"
        renewToken="$(jq -r '.renewToken' "$token_file")"
    fi
    return $rc
}

get_servers() {
    echo "Retrieving servers list..."
    tmpfile=$(mktemp /tmp/surfshark-wg-servers.XXXXXX)
    url="$baseurl/v4/server/clusters/generic?countryCode="
    http_status=$(curl -o $tmpfile -s -w "%{http_code}" -H 'Authorization: Bearer $token' -H 'Content-Type: application/json' $url)
    rc=1
    if [ $http_status -eq 200 ]; then
        echo "  HTTP status OK ($(jq '. | length' "$tmpfile") servers downloaded)"
        echo -n "  Selecting suitable servers..."
        tmpfile2=$(mktemp /tmp/surfshark-wg-servers.XXXXXX)
        jq '.[] | select(.tags as $t | ["p2p", "virtual", physical"] | index($t))' "$tmpfile" | jq -s '.' > "$tmpfile2"
        echo " ($(jq '. | length' "$tmpfile2") servers selected)"
        if [ -f "$servers_file" ]; then
            echo "  Servers list \"$servers_file\" already exists"
            changes=$(diff "$servers_file" $tmpfile2)
            if [ -z "$changes" ]; then
                echo "  No changes"
                rm $tmpfile2
            else
                echo "  Servers changed! Updating servers file" 
                mv $tmpfile2 "$servers_file"
                rc=0
            fi
        else
            mv $tmpfile2 "$servers_file"
            rc=0
        fi
    else
            echo "  HTTP status $http_status (Failed)"
    fi
    rm $tmpfile
    return $rc
}

gen_keys() {
    if [ -f "$wg_keys" ]; then
        echo "WireGuard keys \"$wg_keys\" already exist"
        wg_pub=$(cat $wg_keys | jq -r '.pub')
        wg_prv=$(cat $wg_keys | jq -r '.prv')
    else
        echo "Generating WireGuard keys..."
        wg_prv=$(wg genkey)
        wg_pub=$(echo $wg_prv | wg pubkey)
        echo "{\"pub\":\"$wg_pub\", \"prv\":\"$wg_prv\"}" > $wg_keys
    fi
    echo "  Using public key: $wg_pub"
}

reg_pubkey() {
    echo "Registering public key..."
    url="$baseurl/v1/account/users/public-keys"
    data="{\"pubKey\": \"$wg_pub\"}"
    retry=$1

    tmpfile="$(mktemp /tmp/wg-curl-res.XXXXXX)"
    http_status="$(curl -o "$tmpfile" -s -w "%{http_code}" -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d "$data" -X POST $url)"
    message="$(jq -r '.message' $tmpfile 2>/dev/null)"
    if [ $http_status -eq 201 ]; then
	echo "  New Token and wg.json Created!! Your uci/luci Pvt. Key will be outdated. Enter new Pvt.Key in uci/luci. To Repopulate matching Conf folder; Run again w/ -g" ### The meaning behind 201 status
        echo "  OK (expires: $(jq -r '.expiresAt' $tmpfile), id: $(jq -r '.id' $tmpfile))"
    elif [ $http_status -eq 401 ]; then
        echo "  Access denied: $message"
	echo "  Token file corrupted! Deleting if available, and attempting to Login..."	### Forged a Token to Prompt This echo 
		 rm "$token_file"	### Added these 5 line to del/do_login and get new token
		        if do_login; then
                        reg_pubkey 0
                        return
		        fi		
        if [ "$message" = "Expired JWT Token" ]; then
            echo "  Deleting $token_file to try again!"	### Grammar like I know any Ha!
            rm "$token_file"
            if do_login; then
                reg_pubkey 0
                return
            else
                echo "  Giving up..."   ### Have not seen lines 190~ 199 yet
            fi
        elif [ "$message" = "JWT Token not found" ]; then
            if [ $retry -eq 1 ]; then
                 echo "  Have some coffee and try again!"  
                 sleep 5
                 reg_pubkey 0
                 return
            else
                echo "  Giving up..."
            fi
        fi
    elif [ $http_status -eq 409 ]; then
        echo "  Already registered"
        url="$baseurl/v1/account/users/public-keys/validate"
        http_status="$(curl -o "$tmpfile" -s -w "%{http_code}" -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d "$data" -X POST $url)"
        if [ $http_status -eq 200 ]; then
            expire_date="$(jq -r '.expiresAt' $tmpfile)"
            ed="$(date -u -d "$expire_date" -D "%Y-%m-%dT%T" +"%s")"
            now="$(date -u +"%s")"
            diff=$(($ed - $now))
            if [ $diff -eq 604800 -o $((604800 - $diff)) -lt 10 ]; then
                echo "  Renewed! (expires: $expire_date)"
            	echo "  Hello World Wide WireGuard©"                                           # Your Custom Shout Out 
           	echo "  Thanks Jason A. Donenfeld"                                             # wg was written by One Json we can find
            	logger -t BOSSUSER "RUN DATE:$(date)   KEYS EXPIRE ON: ${expire_date}"         # Log Status Information

            elif [ $diff > 0 ]; then
                echo "  Expires on $expire_date)"
            else
                echo "  Warning: key is expired! ($expire_date)"
            fi
        else
            echo " HTTP status $http_status, failed to check key: $(cat $tmpfile)"
        fi
    else
        echo "  Failed: HTTP $http_status, $(cat $tmpfile)"
    fi
    rm $tmpfile
}

gen_client_confs() {
    postf=".surfshark.com"
    mkdir -p $output_conf_folder
    server_hosts="$(cat "$servers_file" | jq -c '.[] | [.connectionName, .pubKey]')"
    for row in $server_hosts; do
        srv_host="$(echo $row | jq '.[0]')"
        srv_host=$(eval echo $srv_host)
        srv_pub="$(echo $row | jq '.[1]')"
        srv_pub=$(eval echo $srv_pub)
        echo "generating config for $srv_host"
        srv_conf_file="${output_conf_folder}/${srv_host%$postf}.conf"
        srv_conf="[Interface]\nPrivateKey=$wg_prv\nAddress=10.14.0.2/8\nMTU=1350\n\n[Peer]\nPublicKey=o07k/2dsaQkLLSR0dCI/FUd3FLik/F/HBBcOGUkNQGo=\nAllowedIPs=172.16.0.36/32\nEndpoint=wgs.prod.surfshark.com:51820\nPersistentKeepalive=25\n\n[Peer]\nPublicKey=$srv_pub\nAllowedIPs=0.0.0.0/0\nEndpoint=$srv_host:51820\nPersistentKeepalive=25\n"
        uci_conf=""
        if [ "`echo -e`" = "-e" ]; then
            echo "$srv_conf" > $srv_conf_file
        else
            echo -e "$srv_conf" > $srv_conf_file
        fi
    done
}

echo "Just a Sec 'ntpdate' sycning clock"
ntpdate -s pool.ntp.org  ## testing 04052022	## Remark this line if you have not installed ntpdate
echo "Running at $(date)"
read_config
gen_keys

if do_login; then
    reg_pubkey 1
else
    echo "Not registering public key!"
fi

if [ "$1" == "-g" ]; then
    if get_servers; then
        gen_client_confs
    else
        echo "Not generating client configurations!"
    fi
fi
if [ $http_status -eq 429 ]; then  ### Added these three line to remind user to change IP; log to system log
	logger -t BOSSUSER "RUN DATE:$(date)   Run script again on different IP and run with -g to get conf's"
	echo "Switching VPN Servers Recommended to Login ~ Renew Check ~ run w/ -g once IP is changed"
fi
echo "Done at $(date)"	### Changed to Done
echo "Enjoy!"	### Condidering  
