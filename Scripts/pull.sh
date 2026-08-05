#!/bin/bash

cd
cd Documents/School
git pull
cd

# Zeigt eine Desktop-Benachrichtigung an
notify-send "Git Pull" "Documents/School wurde erfolgreich aktualisiert!"
cd
