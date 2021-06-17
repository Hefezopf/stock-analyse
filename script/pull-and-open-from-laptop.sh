#!/usr/bin/env bash

#alias usa='sh /c/max/sa/script/pull-and-open-from-laptop.sh'

cd /c/max/sa/
git pull
sed -i 's/D:\/code\/stock-analyse\/out/file:\/\/\/C:\/max\/sa\/out/g' /C/max/sa/out/_result.html
#"C:\Program Files\Google\Chrome\Application\chrome.exe" --incognito "C:/max/sa/out/_result.html"
start "" "C:\Program Files (x86)\Mozilla Firefox\firefox.exe" -private -url "file:///C:/max/sa/out/_result.html"