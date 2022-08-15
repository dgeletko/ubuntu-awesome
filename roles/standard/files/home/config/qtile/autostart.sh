#!/bin/bash

compton --config ~/.config/compton/compton.conf &
lxpolkit &
light-locker &
xrdb ~/.Xresources
nitrogen --restore

nm-applet &
pasystray &
blueman-applet &

