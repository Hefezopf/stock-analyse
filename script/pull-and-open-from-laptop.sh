#!/usr/bin/env bash

#alias usa='sh /c/code/stock-analyse/script/pull-and-open-from-laptop.sh'

cd /c/code/stock-analyse/
git pull
sed -i 's/D:\/code\/stock-analyse\/out/file:\/\/\/C:\/code\/stock-analyse\/out/g' /C/code/stock-analyse/out/_result.html
#"C:\Program Files\Google\Chrome\Application\chrome.exe" --incognito "C:/code/stock-analyse/out/_result.html"
start "" "C:\Program Files (x86)\Mozilla Firefox\firefox.exe" -private -url "file:///C:/code/stock-analyse/out/_result.html"