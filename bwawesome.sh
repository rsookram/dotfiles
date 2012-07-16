#!/bin/bash

sleep 3;
while true; do
	totalbw=$(vnstat --oneline | sed -e "s/\ //g" | sed -e "s/;/\ /g" | awk '{print $6}');

	echo -e "bwwidget.text = \"TOT $totalbw |\"" | awesome-client;
	sleep 5m;
done
