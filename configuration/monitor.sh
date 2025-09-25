#!/usr/bin/env bash

# Build URL
declare -A group=(
  [21]="ces"
  [22]="lhes"
  [23]="rmes"
  [24]="woes"
  [25]="ses"
  [26]="ybes"
  [27]="wes"
  [28]="bles"
  [31]="aewms"
  [32]="lcms"
  [33]="acsms"
  [51]="ahs"
  [52]="chs"
  [81]="lvdo"
)
site_code=$(ip -4 addr | awk '/inet 10./ {print $2}' | cut -d '.' -f 2)
count=12

while [ -z "${group[$site_code]}" ]
do
  sleep 1
done

url="https://cam-monitor.lvusd.org/cam-monitor/index-beelink.html?group=${group[$site_code]}&count=$count"

# Launch Chrome in fullscreen
chromium $url --hide-crash-restore-bubble --hide-scrollbars --start-fullscreen --password-store=basic --restart
