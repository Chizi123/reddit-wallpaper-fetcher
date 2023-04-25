# TITLE:Reddit wallpaper fetcher (Redwall)<br/>

# What is this?<br/>
This is a simple shell script to pull the images from a set of subreddits, intended for use as a dynamic wallpaper.
It is written in bash and uses curl, jq and imagemagick for its processing.
Currently it downloads the images, names them and places them in a folder which should set the wallpaper.
It can optionally add the title of the image to the image.
It uses a simple, bash readable configuration file.

# How to use<br/>
Copy the default configuration file to ~/.config/reddit-wallpaper-fetcher.conf and alter the variables as need be.
The list of subreddits is a bash list, so every entry needs to be in quotes and seperated by a space or newline.

# TODOs<br/>
Add support for all DE/WMs<br/>
Add support for multiple mmonitors

