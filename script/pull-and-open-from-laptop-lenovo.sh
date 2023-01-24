#!/usr/bin/env bash

#alias usa='sh /c/code/stock-analyse/script/pull-and-open-from-laptop-lenovo.sh'

cd /c/code/stock-analyse
git pull
sed -i 's/D:\/code\/stock-analyse\/out/C:\/code\/stock-analyse\/out/g' /c/code/stock-analyse/out/_result.html
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --incognito "C:/code/stock-analyse/out/_result.html"