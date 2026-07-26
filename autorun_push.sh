#!/bin/bash

# 1. In den Schulordner wechseln
cd ~/Documents/School || exit

# 2. Datum und Uhrzeit für die Commit-Nachricht holen
DATUM=$(date +"%d.%m.%Y - %H:%M Uhr")

# 3. Neue/Geänderte Dateien vormerken
git add .

# 4. Nur committen, wenn es überhaupt Änderungen gibt
if ! git diff-index --quiet HEAD --; then
    git commit -m "Automatisches Backup vom $DATUM"
    git push origin main
fi
