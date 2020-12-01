#!/bin/bash

IMAGE_REGEX='"url": "https:\/\/i\.redd\.it\/[a-z0-9]*\.\w{3,4}\", "subreddit_subscribers": '
TITLE_REGEX='"clicked": (true|false), "title": "[a-zA-Z0-9.\[\]\(\) ]*", "link_flair_richtext": \['
TIME_REGEX='"subreddit_subscribers": \d*, "created_utc": [\d.]*, "num_crossposts": '
PERMALINK_REGEX=', "permalink": "\/r\/[A-Za-z0-9\/_]*", "parent_whitelist_status": '

SUBREDDITS=("EarthPorn")
SORT=new
USER=$(whoami)

source $HOME/.config/reddit-wallpaper-fetcher.conf &>/dev/null

LATEST_TIME=0
if [ -f $HOME/.wallpaper/json ]; then
    LATEST=$(cat ~/.wallpaper/json)
    LATEST_TIME=$(echo $LATEST | grep -oP "$TIME_REGEX" | tail -n1 | grep -oP '"created_utc": [\d.]*' | grep -oP '[\d.]*')
fi

for i in "${SUBREDDITS[@]}"; do
    temp=$(curl -s --user-agent $USER "https://www.reddit.com/r/$i.json?sort=$SORT&limit=1")
    time=$(echo $temp | grep -oP "$TIME_REGEX" | tail -n1 | grep -oP '"created_utc": [\d.]*' | grep -oP '[\d.]*')
    if [ $(awk -v n1="$time" -v n2="$LATEST_TIME" 'BEGIN {printf (n1>n2?"1":"")}') ]; then
	LATEST=$temp
	LATEST_TIME=$time
    fi
done

url=$(echo $LATEST | grep -oP "$IMAGE_REGEX" | tail -n1 | grep -oP '"https:\/\/.*",' | grep -oP '".*"' | sed 's/"//g')
curl -s -o "$HOME/.wallpaper/temp.$(echo $url | rev | cut -d'.' -f1 | rev)" "$url"
