# Rename offline Wi-Fi
If your internet connection is down, this script renames ssid to yourssid_OFFLINE. When internet is back, it removes postfix. Supports multiple ssids.

Supports 
* OpenWrt routers (tested on 21.02) 
* DD-WRT Broadcom based (tested on r44715)

# For OpenWRT
* Copy the script to home dirrectory. 
* Go to System/Scheduled tasks (http://192.168.1.1/cgi-bin/luci/admin/system/crontab )
* Set up a cron job to run script every 15 minutes. 
```
*/15 * * * * ~/rename_offline_wifi.sh
```

# For DD-WRT based on Broadcom
**!!1! Currently in order to apply renaming, the script reboots the router.** I'm looking for another way to apply settings
* If you have usb sick, copy the script there. If you don't, you need to enable JFFS storage. All other locations on DD-WRT are eraised each time router reboots. To do so, go to Administration/Management/JFFS2 Support Internal Flash Storage Enable .
* Copy script to the router via scp:

```
scp ~/rename_offline_wifi.sh root@192.168.1.1:/jffs/
```
* Go to Administration/Management http://192.168.1.1/Management.asp , enable Cron and add line 

```
*/15 * * * * /jffs/rename_offline_wifi.sh
```
