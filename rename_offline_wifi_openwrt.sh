THERE_WERE_ANY_CHAGES=0 # should I commit changes and restart wifi?
sfx="__OFFLINE" # postfix for ssid

ping -c 3 8.8.8.8
has_connection=$?

for wifinum in 0 1 2 3 4 5 6 7 8 9
do
        ssid=$(uci get wireless.wifinet${wifinum}.ssid)
        has_sfx=$(echo $ssid | grep -c $sfx)

        if [ $has_connection -eq 0 ]
        then
                echo "You have connection to google"
                if [ $has_sfx -gt 0 ] ; then
                        echo "SSID contains $sfx in name"
                        newssid=${ssid/$sfx/}
                        uci set wireless.wifinet${wifinum}.ssid=$newssid
                        THERE_WERE_ANY_CHANGES=1
                        echo "New ssid is $newssid"
                fi
        else
                echo "No internet"
                if [ $has_sfx -eq 0 ]; then
                        newssid="$ssid$sfx"
                        echo "New ssid is $newssid"
                        uci set wireless.wifinet${wifinum}.ssid=$newssid
                        THERE_WERE_ANY_CHANGES=1
                fi
        fi
done

if [ $THERE_WERE_ANY_CHANGES -eq 1 ]; then
        uci commit wireless
        wifi reload
fi
