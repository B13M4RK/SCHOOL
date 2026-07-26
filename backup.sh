#!/bin/bash

# 1. In den Schulordner wechseln
cd ~/Documents/School || exit

# 2. Alle .odt und .ods Dateien automatisch im Hintergrund als PDF speichern
# (libreoffice wandelt sie um und legt die PDF im selben Ordner ab)
find . -type f \( -name "*.odt" -o -name "*.ods" \) -exec libreoffice --headless --convert-to pdf "{}" --outdir "$(dirname "{}")" \; 2>/dev/null

# 3. Datum und Uhrzeit holen
DATUM=$(date +"%d.%m.%Y - %H:%M Uhr")

# 4. Alle Dateien (inklusive der neu erzeugten PDFs) vormerken
git add .

# 5. Nur committen und pushen, wenn es Änderungen gab
if ! git diff-index --quiet HEAD --; then
    git commit -m "Automatisches Backup vom $DATUM"
    git push origin main
    notify-send "Git Backup" "Schulordner & PDFs erfolgreich auf GitHub gesichert!" -i document-save
fi
