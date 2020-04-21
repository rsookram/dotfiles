#!/usr/bin/fish

gnome-screenshot -f ~/(expr (date +%s%N) / 1000000).png
