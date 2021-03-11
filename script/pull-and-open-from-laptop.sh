#!/usr/bin/env bash

#alias usa='sh /c/max/sa/script/pull-and-open-from-laptop.sh'

git pull
sed -i 's/D:\/code\/stock-analyse\/out/C:\/max\/sa\/out/g' /C/max/sa/out/_result.html
"C:\Program Files\Google\Chrome\Application\chrome.exe" --incognito "C:/max/sa/out/_result.html"