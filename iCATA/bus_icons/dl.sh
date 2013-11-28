#! /bin/bash

for i in {0..360..3}; do
	wget -O busIcon-$i.png "http://50.203.43.19/InfoPoint/IconFactory.ashx?library=busIcons\mobile&colortype=hex&color=000000&bearing=$i"
done
