#!/bin/bash  

# 1. In den Schulordner wechseln  
cd ~/Documents/School || exit  

# 2. Zentralen PDF-Ordner vorbereiten und alte PDFs bereinigen
mkdir -p PDFs
find PDFs -type f -name "*.pdf" -delete  

# 3. Alle LibreOffice-Dateien suchen und als PDF direkt flach in den 'PDFs/' Ordner exportieren  
find Subjects Templates Overview -type f \( -name "*.odt" -o -name "*.ods" -o -name "*.odp" -o -name "*.odg" -o -name "*.odb" -o -name "*.odf" -o -name "*.ott" \) 2>/dev/null | while read -r FILE; do  
    # Als PDF direkt in den flachen PDFs/-Ordner exportieren  
    libreoffice --headless --convert-to pdf "$FILE" --outdir "PDFs" 2>/dev/null  
done  

# 3b. Leere Ordner finden und mit einer .gitkeep versehen, damit Git sie erkennt
find . -type d -empty -exec touch {}/.gitkeep \;

# 4. Datum und Uhrzeit holen  
DATUM=$(date +"%d.%m.%Y - %H:%M Uhr")  

# --- Statistik & Noten-Markdown aktualisieren ---
if [ -f "stats.sh" ]; then
    bash stats.sh
fi

# 5. Alle Dateien vormerken  
git add .  

# 6. Nur committen und pushen, wenn es Änderungen gab
if ! git diff-index --quiet HEAD -- || [ -n "$(git status --porcelain)" ]; then  
    git commit -m "Automatisches Backup & flache PDFs vom $DATUM"  
    git push origin main  
    notify-send "Git Backup" "Schulordner & flache PDFs erfolgreich gesichert!" -i document-save  
fi  

# 7. Zurück ins Home-Verzeichnis
cd
