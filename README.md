# Rename offline Wi-Fi
If your internet connection is down, this script renames ssid to *_OFFLINE. When internet is back, it removes postfix. Supports multiple ssids.

Supports 
* OpenWrt routers (tested on 21.02) 
* DD-WRT Broadcom based (tested on r44715)

You can set up a cron job to run script every 15 minutes. 
```
*/15 * * * * ~/rename_offline_wifi.sh
```
