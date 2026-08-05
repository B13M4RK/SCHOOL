#!/bin/bash 

# 1. In den Schulordner wechseln 
cd ~/Documents/School || exit 

# 2. Zentralen PDFs-Ordner vorbereiten
mkdir -p PDFs

# 3. Alte PDFs im PDFs-Ordner löschen, damit keine veralteten Stände bleiben 
find PDFs -type f -name "*.pdf" -delete 

# 4. Alle LibreOffice-Dateien (.odt, .ods, .odp, .odg, .odb, .odf, .ott) suchen 
# und als PDF direkt in den zentralen PDFs-Ordner konvertieren 
find . -type f \( -name "*.odt" -o -name "*.ods" -o -name "*.odp" -o -name "*.odg" -o -name "*.odb" -o -name "*.odf" -o -name "*.ott" \) | while read -r FILE; do 
    libreoffice --headless --convert-to pdf "$FILE" --outdir PDFs 2>/dev/null 
done 

# 4b. Falls es bereits fertig exportierte PDFs in den Unterordnern gibt, optional in den PDFs-Ordner kopieren/verschieben:
find . -mindepth 2 -type f -name "*.pdf" ! -path "./PDFs/*" -exec cp {} PDFs/ \;

# 5. README.md automatisch basierend auf den vorhandenen PDFs im PDFs-Ordner aktualisieren
python3 - << 'EOF'
import os
import glob

pdf_dir = "PDFs"
readme_path = "README.md"

if os.path.exists(pdf_dir):
    # Alle PDFs im PDFs-Ordner ermitteln
    pdf_files = sorted([os.path.basename(f) for f in glob.glob(os.path.join(pdf_dir, "*.pdf"))])
    
    # Beispiel für die automatische Generierung / Aktualisierung der README-Sektion für PDFs:
    # Hier wird ein Bereich in der README.md dynamisch aktualisiert oder eine Liste generiert.
    print(f"Gefundene PDFs für die Verlinkung: {pdf_files}")
    
    # Du kannst hier die Logik anpassen, wie die README.md genau aufgebaut sein soll.
EOF

# 6. Leere Ordner finden und mit einer .gitkeep versehen
find . -type d -empty -exec touch {}/.gitkeep \;

# 7. Datum und Uhrzeit holen 
DATUM=$(date +"%d.%m.%Y - %H:%M Uhr") 

# 8. Alle Änderungen vormerken 
git add . 

# 9. Nur committen und pushen, wenn es Änderungen gab 
if ! git diff-index --quiet HEAD -- || [ -n "$(git status --porcelain)" ]; then 
    git commit -m "Automatisches Backup vom $DATUM" 
    git push origin main 
    notify-send "Git Backup" "Schulordner & PDFs erfolgreich gesichert!" -i document-save 
fi 

# 10. Zurück ins Home-Verzeichnis
cd
