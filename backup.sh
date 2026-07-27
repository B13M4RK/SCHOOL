#!/bin/bash 

# 1. In den Schulordner wechseln 
cd ~/Documents/School || exit 

# 2. Alte PDFs löschen, damit keine alten Stände oder gelöschte Dateien als Waise bleiben 
find . -type f -name "*.pdf" -delete 

# 3. Alle LibreOffice-Dateien (.odt, .ods, .odp, .odg, .odb, .odf) suchen 
# und direkt im jeweiligen Zielordner als PDF speichern 
find . -type f \( -name "*.odt" -o -name "*.ods" -o -name "*.odp" -o -name "*.odg" -o -name "*.odb" -o -name "*.odf" \) | while read -r FILE; do 
    DIR=$(dirname "$FILE") 
    libreoffice --headless --convert-to pdf "$FILE" --outdir "$DIR" 2>/dev/null 
done 

# 3b. Leere Ordner finden und mit einer .gitkeep versehen, damit Git sie erkennt
find . -type d -empty -exec touch {}/.gitkeep \;

# 4. Datum und Uhrzeit holen 
DATUM=$(date +"%d.%m.%Y - %H:%M Uhr") 

# 5. Alle Dateien (inkl. der erzeugten PDFs und .gitkeep-Dateien) vormerken 
git add . 

# 6. Nur committen und pushen, wenn es Änderungen gab (auch ungetrackte Dateien prüfen)
if ! git diff-index --quiet HEAD -- || [ -n "$(git status --porcelain)" ]; then 
    git commit -m "Automatisches Backup vom $DATUM" 
    git push origin main 
    notify-send "Git Backup" "Schulordner & PDFs erfolgreich gesichert!" -i document-save 
fi 

# 7. Zurück ins Home-Verzeichnis
cd
