#!/bin/sh

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
gen_keys() {
    if [ -f "$wg_keys" ]; then
        echo "WireGuard keys \"$wg_keys\" already exist"
        wg_pub=$(cat "$wg_keys" | jq -r '.pub')
        wg_prv=$(cat "$wg_keys" | jq -r '.prv')
    else
        echo "Generating WireGuard keys..."
        wg_prv=$(wg genkey)
        wg_pub=$(echo "$wg_prv" | wg pubkey)
        echo "{\"pub\":\"$wg_pub\", \"prv\":\"$wg_prv\"}" > "$wg_keys"
    fi
    echo "  Using public key: $wg_pub"
}
do_login () {
    rc=1
    if [ -f "$token_file" ]; then
        echo "Token file \"$token_file\" exists, skipping login"  ## With the new "000" Failure in reg_pubkey and do_login...
        rc=0                                                      ## we'er calling out the "000" failure in curl...
    else                                                          ## continuing with generation of new/updated "Token.json"!  
        echo "Logging in..."
        tmpfile=$(mktemp /tmp/wg-curl-res.XXXXXX)
        url="$baseurl/v1/auth/login"
        data="{\"username\":\"$username\", \"password\":\"$password\"}"
        http_status=$(curl -o "$tmpfile" -s -w "%{http_code}" -d "$data" -H 'Content-Type: application/json' -X POST $url)
        if [ "$http_status" -eq 200 ]; then
            cp "$tmpfile" "$token_file"
                echo "  HTTP status OK"
            rc=0
        elif [ "$http_status" -eq 429 ]; then
            echo "  HTTP status $http_status (Blocked! Too many requests, Change VPN Server and Retry)"
        elif [ "$http_status" -eq 000 ]; then                     ## Start do_login at shell script again, "000" is various failure code.
            echo "  Overcoming Curl 000 failure... "
            tmpfile=$(mktemp /tmp/wg-curl-res.XXXXXX)
            url="$baseurl/v1/auth/login"
            data="{\"username\":\"$username\", \"password\":\"$password\"}"
            http_status=$(curl -o "$tmpfile" -s -w "%{http_code}" -d "$data" -H 'Content-Type: application/json' -X POST $url)
            if [ "$http_status" -eq 200 ]; then
                cp "$tmpfile" "$token_file"
                    echo "  HTTP status OK"
            rc=0
            fi                                    
        else
            echo "  HTTP status $http_status (Failed! Check username/password in .json file)"
        rm "$tmpfile"
        fi    
    fi
    
    if [ "$rc" -eq 0 ]; then
        token="$(jq -r '.token' "$token_file")"
        renewToken="$(jq -r '.renewToken' "$token_file")"
    fi
    return $rc
}
reg_pubkey() {
    echo "Registering public key..."
    url="$baseurl/v1/account/users/public-keys"
    data="{\"pubKey\": \"$wg_pub\"}"
    retry=$2

    tmpfile="$(mktemp /tmp/wg-curl-res.XXXXXX)"
    http_status="$(curl -o "$tmpfile" -s -w "%{http_code}" -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d "$data" -X POST $url)"
    message="$(jq -r '.message' "$tmpfile" 2>/dev/null)"
    if [ "$http_status" -eq 201 ]; then
	echo "  New Token Created!! "  ### The meaning behind 201 status
        echo "  OK (expires: $(jq -r '.expiresAt' "$tmpfile"), id: $(jq -r '.id' "$tmpfile"))"
    elif [ "$http_status" -eq 401 ] || [ "$http_status" -eq 000 ]; then  ### 401 Testing the generic Curl error for reg pubkey as redundancy.
	echo "  Token file Hot-Fix!..."	### Forged a Token to Prompt This echo 
		 rm "$token_file"
		        if do_login; then
                        reg_pubkey 0
                        return
		        fi
				
        if [ "$message" = "Expired JWT Token" ]; then
            echo "  Deleting $token_file to try again!"	
            rm "$token_file"
            if do_login; then
                reg_pubkey 0
                return
            else
                echo "  Giving up..."   ### Have not seen lines 190~ 199 yet
            fi
        elif [ "$message" = "JWT Token not found" ]; then
            if [ "$retry" -eq 1 ]; then
                 echo "  Have some coffee and try again!"  
                 sleep 5
                 reg_pubkey 0
                 return
            else
                echo "  Giving up..."
            fi
        
         fi
    elif [ "$http_status" -eq 409 ]; then
        echo "  Already registered"
        url="$baseurl/v1/account/users/public-keys/validate"
        http_status="$(curl -o "$tmpfile" -s -w "%{http_code}" -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d "$data" -X POST $url)"
        if [ "$http_status" -eq 200 ]; then
            expire_date="$(jq -r '.expiresAt' "$tmpfile")"
            ed="$(date -u -d "$expire_date" -D "%Y-%m-%dT%T" +"%s")"
            now="$(date -u +"%s")"
            diff=$((ed - now))
            if [ $diff -eq 604800 ] || [ $((604800 - diff)) -lt 10 ]; then
                echo "  Renewed! (expires: $expire_date)"
            	echo "  Hello World Wide WireGuardÂ©"                                           # Your Custom Shout Out 
           	echo "  Thanks Jason A. Donenfeld"                                             # wg was written by One Json we can find
            	logger -t BOSSUSER "RUN DATE:$(date)   KEYS EXPIRE ON: ${expire_date}"         # Log Status Information

            elif [ $diff -gt 0 ]; then
                echo "  Expires on $expire_date)"
            else
                echo "  Warning: key is expired! ($expire_date)"
            fi
        else
            echo " HTTP status $http_status, failed to check key: $(cat "$tmpfile")"
        fi
    else
        echo "  Failed: HTTP $http_status, $(cat "$tmpfile")"
fi
rm "$tmpfile"
}

get_servers() {
    echo "Retrieving servers list..."
    tmpfile=$(mktemp /tmp/surfshark-wg-servers.XXXXXX)
    url="$baseurl/v4/server/clusters/generic?countryCode="
    http_status=$(curl -o "$tmpfile" -s -w "%{http_code}" -H "Authorization: Bearer $token" -H 'Content-Type: application/json' "$url")
    rc=1
    if [ "$http_status" -eq 200 ]; then
        echo "  HTTP status OK ($(jq '. | length' "$tmpfile") servers downloaded)"
        echo -n "  Selecting suitable servers..."
        tmpfile2=$(mktemp /tmp/surfshark-wg-servers.XXXXXX)
        jq '.[] | select(.tags as $t | ["p2p", "virtual", "physical"] | index($t))' "$tmpfile" | jq -s '.' > "$tmpfile2"
        echo " ($(jq '. | length' "$tmpfile2") servers selected)"
        if [ -f "$servers_file" ]; then
            echo "  Servers list \"$servers_file\" already exists"
            changes=$(diff "$servers_file" "$tmpfile2")
            if [ -z "$changes" ]; then
                echo "  No changes"
                rm "$tmpfile2"
            else
                echo "  Servers changed! Updating servers file" 
                mv "$tmpfile2" "$servers_file"
                rc=0
            fi
        else
            mv "$tmpfile2" "$servers_file"
            rc=0
        fi
    else
            echo "  HTTP status $http_status (Failed)"
    fi
    rm "$tmpfile"
    return $rc
}
gen_client_confs() {
    postf=".surfshark.com"
    mkdir -p "$output_conf_folder"
    server_hosts="$(cat "$servers_file" | jq -c '.[] | [.connectionName, .pubKey]')"
    for row in $server_hosts; do
        srv_host="$(echo "$row" | jq '.[0]')"
        srv_host=$(eval echo "$srv_host")
        srv_pub="$(echo "$row" | jq '.[1]')"
        srv_pub=$(eval echo "$srv_pub")
        echo "generating config for $srv_host"
        srv_conf_file="${output_conf_folder}/${srv_host%"$postf"}.conf"
        srv_conf="[Interface]\nPrivateKey=$wg_prv\nAddress=10.14.0.2/8\nMTU=1350\n\n[Peer]\nPublicKey=o07k/2dsaQkLLSR0dCI/FUd3FLik/F/HBBcOGUkNQGo=\nAllowedIPs=172.16.0.36/32\nEndpoint=wgs.prod.surfshark.com:51820\nPersistentKeepalive=25\n\n[Peer]\nPublicKey=$srv_pub\nAllowedIPs=0.0.0.0/0\nEndpoint=$srv_host:51820\nPersistentKeepalive=25\n"
        uci_conf=""
        if [ "$(echo -e)" = "-e" ]; then
            echo "$srv_conf" > "$srv_conf_file"
        else
            echo -e "$srv_conf" > "$srv_conf_file"
        fi
    done
}

echo "Just a Sec 'ntpdate' sycning clock"
ntpdate -s 137.184.81.69  ## testing 04052022	## Remark this line if you have not installed ntpdate
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
if [ "$http_status" -eq 429 ] || [ "$http_status" -eq 000 ]; then  ### Added these three line to remind user to change IP; log to system log
	logger -t BOSSUSER "RUN DATE:$(date)   Key Update Failure: if "429" run on different IP and run with -g to get conf's"
	echo "Switching VPN Servers Recommended: (Failed 000 just run again.)  (Failed 429 use different VPN, run again.)"
fi
echo "Done at $(date)"	### Changed to Done
echo "Enjoy!"	### Condidering  
