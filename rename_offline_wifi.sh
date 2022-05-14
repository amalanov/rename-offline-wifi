#!/bin/sh

###########################
#
# This script checks connection to 8.8.8.8. If none, it renames all ssids by adding __OFFLINE to ssids 
# This script doesn't have any parameters. Just run it.
# It works both on OpenWRT (tested on 21.02) and DD-WRT (tested on v3.0-r44715 std (11/03/20))
# Homepage is https://github.com/amalanov/rename-offline-wifi
#
###########################


fn_get_full_config ()                         
{                                             
        if command -v uci >/dev/null; then    
                uci show                                                   
        elif command -v nvram >/dev/null; then                             
                nvram show                                                 
        else                                                               
                echo "Neither uci nor nvram derected. Unknown system. Exit"
                exit 404
        fi            
}                                         
                                          
fn_get_config_value ()                        
{                                             
        if command -v uci >/dev/null; then    
                echo "$(uci get $1)"                                       
        elif command -v nvram >/dev/null; then                             
                echo "$(nvram get $1)"                                     
        else                                                               
                echo "Neither uci nor nvram derected. Unknown system. Exit"
                exit 404
        fi            
}                                         
                                          
fn_set_config_value ()                        
{                                             
       if command -v uci >/dev/null; then                   
               eval "uci set $1=$2"                                       
       elif command -v nvram >/dev/null; then                             
               eval "nvram set $1=$2"                                     
       else                                                               
               echo "Neither uci nor nvram derected. Unknown system. Exit"
               exit 404
       fi        
}                                         
                                          
fn_commit ()                              
{                                             
        if command -v uci >/dev/null; then    
               uci commit wireless           
               wifi reload                   
        elif command -v nvram >/dev/null; then                             
                nvram commit                        

                # I dont know a working way to apply wireless settings except reboot. 
                # Waiting for reply on https://forum.dd-wrt.com/phpBB2/posting_sec.php?mode=reply&t=259376                       
                wl radio off    
                wl radio                                           
                wl radio on        
                stopservice wan
                startservice wan
                reboot

        else                                                               
                echo "Neither uci nor nvram derected. Unknown system. Exit"
        fi              
}  

sfx="__OFFLINE"          
                                                                  
ping -c 3 8.8.8.8                                                                   
has_connection=$?                                                                   
                                                                                    
# get all config lines which contain *ssid=* and iterate over them                  
fn_get_full_config | grep "ssid[ ]*=" | 
{ 
THERE_WERE_ANY_CHANGES=0
# | - is pipeline. It starts a new process, therefore it creates a new scope for variables
# If I define THERE_WERE_ANY_CHANGES outside {}, I wont be able to set a value to this variable

while read -r line; do                      
        # split config line which looks like devicename=wifiname and get device name
        device="$(echo $line | cut -d"=" -f1)"
        ssid=$(fn_get_config_value ${device})      

        has_sfx=$(echo $ssid | grep -c $sfx)                                                                   
        if [ $has_connection -eq 0 ]                               
        then                                                       
                echo "You have connection to google"               
                if [ $has_sfx -gt 0 ] ; then                       
                        echo "Gonna fix '$device' and SSID '$ssid'"
                        echo "SSID contains $sfx in name"          
                        newssid=${ssid/$sfx/}                      
                        fn_set_config_value $device $newssid       
                        THERE_WERE_ANY_CHANGES=1                    
                fi                                                  
        else                                                        
                echo "No internet"                                  
                if [ $has_sfx -eq 0 -a "$ssid" != "" ]; then  # On DD-WRT there are some "" ssids. Don't deal with them                       
                        echo "Gonna fix ' $device' and SSID '$ssid'"
                        newssid="$ssid$sfx"                                         
                        echo "New ssid is $newssid"                                 
                        fn_set_config_value $device $newssid                        
                        THERE_WERE_ANY_CHANGES=1                                    
                fi                                                  
        fi                                                          
done                                                                
                                                                    
echo "Where there any changes? Is there anything to commit? $THERE_WERE_ANY_CHANGES"
if [ $THERE_WERE_ANY_CHANGES -eq 1 ]; then                                          
        echo "Commit changes"                                                       
        fn_commit                                                                   
fi   
}
