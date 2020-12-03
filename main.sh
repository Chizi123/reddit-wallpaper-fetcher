#!/bin/bash

TESTING=1

#Default variables
SUBREDDITS=("EarthPorn")
SORT=new
USER=$(whoami)
SIZE=1920x1080
WRITE_TITLE=1
TITLE_COLOR="white"
TITLE_POSITION="Southeast"
TITLE_SIZE=30

#Set directories for testing
if [ $TESTING != 1 ]; then
    CONFDIR="$HOME/.config"
    WALLDIR="$HOME/.wallpaper"
else
    CONFDIR="$(dirname $(realpath $0))"
    WALLDIR="$(dirname $(realpath $0))"
fi

source $CONFDIR/reddit-wallpaper-fetcher.conf &>/dev/null

#Initialise time from last fetch
LATEST_TIME=0
if [ -f $WALLDIR/json ]; then
    LATEST=$(cat $WALLDIR/json)
    LATEST_TIME=$(echo $LATEST | jq ".data.children[-1].data.created_utc")
fi

#Try subreddits for new images
for i in "${SUBREDDITS[@]}"; do
    temp=$(curl -s --user-agent $USER "https://www.reddit.com/r/$i.json?sort=$SORT&limit=1")
    time=$(echo $temp | jq ".data.children[-1].data.created_utc")
    if [ $(awk -v n1="$time" -v n2="$LATEST_TIME" 'BEGIN {printf (n1>n2?"1":"")}') ]; then
	LATEST=$temp
	LATEST_TIME=$time
    fi
done

#No Update to do
#if [ -f $WALLDIR/json ] && [ "$(cat $WALLDIR/json)" == "$LATEST" ]; then
#    exit
#fi

#Download image
url=$(echo $LATEST | jq ".data.children[-1].data.url" | sed 's/"//g')
ext="$(echo $url | rev | cut -d'.' -f1 | rev)"
curl -s -o "$WALLDIR/temp.$ext" "$url"

#Save image information
echo $LATEST > $WALLDIR/json
title=$(echo $LATEST | jq ".data.children[-1].data.title")
echo "$title" > $WALLDIR/data.txt
echo $url >> $WALLDIR/data.txt
echo https://reddit.com$(echo $LATEST | jq ".data.children[-1].data.permalink" | sed 's/"//g') >> $WALLDIR/data.txt

#Add image title
if [ $WRITE_TITLE == 1 ]; then
    convert "temp.$ext" -fill "$TITLE_COLOR" -gravity "$TITLE_POSITION" -pointsize "$TITLE_SIZE" -annotate 0 "$title" -resize $SIZE "wallpaper.jpg"
else
    convert "temp.$ext" -resize $SIZE "wallpaper.jpg"
fi
rm temp.$ext
