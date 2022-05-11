THERE_WERE_ANY_CHANGES=0                                                                   
sfx="__OFFLINE"                                                                            
                                                                                           
ping -c 3 8.8.8.8                                                                          
has_connection=$?                                                                          
                                                                                           
# get all config lines which contain *ssid=* and iterate over them                         
uci show | grep "ssid[ ]*=" | while read -r line; do                                       
        # split config line which looks like devicename=wifiname and get device name       
        device="$(echo $line | cut -d"=" -f1)"                                             
        ssid=$(uci get ${device})                                                          
        has_sfx=$(echo $ssid | grep -c $sfx)                                               
                                                                                           
        if [ $has_connection -eq 0 ]                                                       
        then                                                                               
                echo "You have connection to google"                                       
                if [ $has_sfx -gt 0 ] ; then                                               
                        echo "Gonna fix ' $device' and SSID '$ssid'"                       
                        echo "SSID contains $sfx in name"                                  
                        newssid=${ssid/$sfx/}                                              
                        uci set ${device}=$newssid                                         
                        THERE_WERE_ANY_CHANGES=1                                           
                        echo "New ssid is $newssid"                                        
                fi                                                                         
        else                                                                               
                echo "No internet"                                                         
                if [ $has_sfx -eq 0 ]; then                                                
                        echo "Gonna fix ' $device' and SSID '$ssid'"                       
                        newssid="$ssid$sfx"                                                
                        echo "New ssid is $newssid"                                        
                        uci set ${device}=$newssid                                         
                        THERE_WERE_ANY_CHANGES=1                                           
                fi                                                                         
        fi                                                                                 
done                                                                                       
                                                                                           
echo "Where there any changes? Is there anything to commit? $THERE_WERE_ANY_CHANGES"       
if [ $THERE_WERE_ANY_CHANGES -eq 1 ]; then                                                 
        echo "Commit changes"                                                              
        uci commit wireless                                                                
        wifi reload                                                                        
fi                                             
