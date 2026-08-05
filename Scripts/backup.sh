#!/bin/bash  

# 1. In den Schulordner wechseln  
cd ~/Documents/School || exit  

# 2. Zentralen PDF-Ordner vorbereiten und alte PDFs dort komplett bereinigen
mkdir -p PDFs
find PDFs -type f -name "*.pdf" -delete  

# 3. Alle LibreOffice-Dateien (.odt, .ods, .odp, .odg, .odb, .odf, .ott) suchen  
# und als PDF in die entsprechende Spiegelstruktur im 'PDFs/' Ordner exportieren  
find Subjects Templates Overview -type f \( -name "*.odt" -o -name "*.ods" -o -name "*.odp" -o -name "*.odg" -o -name "*.odb" -o -name "*.odf" -o -name "*.ott" \) 2>/dev/null | while read -r FILE; do  
    # Relativen Pfad ermitteln (z.B. Subjects/Physics/CHA_01_ELECTROMAGNETISM/file.odt)
    REL_PATH=$(dirname "$FILE")
    
    # Zielverzeichnis im PDFs-Ordner erstellen
    TARGET_DIR="PDFs/$REL_PATH"
    mkdir -p "$TARGET_DIR"
    
    # Als PDF direkt in den neuen Zielordner exportieren
    libreoffice --headless --convert-to pdf "$FILE" --outdir "$TARGET_DIR" 2>/dev/null  
done  

# 3b. Leere Ordner finden und mit einer .gitkeep versehen, damit Git sie erkennt
find . -type d -empty -exec touch {}/.gitkeep \;

# 4. Datum und Uhrzeit holen  
DATUM=$(date +"%d.%m.%Y - %H:%M Uhr")  

# --- Statistik & Noten-Markdown aktualisieren ---
if [ -f "stats.sh" ]; then
    bash stats.sh
fi

# 5. Alle Dateien (inkl. der zentralisierten PDFs und .gitkeep-Dateien) vormerken  
git add .  

# 6. Nur committen und pushen, wenn es Änderungen gab (auch ungetrackte Dateien prüfen)
if ! git diff-index --quiet HEAD -- || [ -n "$(git status --porcelain)" ]; then  
    git commit -m "Automatisches Backup & Zentralisierung PDFs vom $DATUM"  
    git push origin main  
    notify-send "Git Backup" "Schulordner & PDFs erfolgreich gesichert!" -i document-save  
fi  

# 7. Zurück ins Home-Verzeichnis
cd
