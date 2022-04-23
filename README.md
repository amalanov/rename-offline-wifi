# Rename offline Wi-Fi
If your internet connection is down, this script renames ssid to *_OFFLINE. When internet is back, it removes postfix. For OpenWRT. Supports multiple ssids.

You can set up a cron job to run script every 15 minutes. Go to luci/admin/system/crontab.
```
*/15 * * * * ~/rename_offline_wifi_openwrt.sh
```
