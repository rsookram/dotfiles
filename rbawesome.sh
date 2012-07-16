#!/bin/bash

sleep 3;
while true; do
	song=$(rhythmbox-client --no-start --print-playing-format="%tt" | sed -e 's/\....$//' | sed -e 's/\.flac$//');
	time=$(rhythmbox-client --no-start --print-playing-format="(%te/%td)");

	echo -e "rbwidget.text = \"$song $time | \"" | awesome-client;
	sleep 1;
done
