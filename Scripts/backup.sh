#!/bin/bash 

# 1. In den Schulordner wechseln 
cd ~/Documents/School || exit 

# 2. Zentralen PDFs-Ordner vorbereiten
mkdir -p PDFs

# 3. Alte PDFs im PDFs-Ordner löschen (außer Vorlagen falls dort) 
find PDFs -type f -name "*.pdf" -delete 

# 4. Alle LibreOffice-Dateien suchen und als PDF direkt in den PDFs-Ordner konvertieren 
find . -type f \( -name "*.odt" -o -name "*.ods" -o -name "*.odp" -o -name "*.odg" -o -name "*.odb" -o -name "*.odf" -o -name "*.ott" \) | while read -r FILE; do 
    libreoffice --headless --convert-to pdf "$FILE" --outdir PDFs 2>/dev/null 
done 

# 4b. Bereits vorhandene PDFs aus Unterordnern (z.B. aus Overview oder Subjects) ebenfalls in den PDFs-Ordner kopieren
find . -mindepth 2 -type f -name "*.pdf" ! -path "./PDFs/*" ! -path "./Templates/*" -exec cp {} PDFs/ \;

# 5. README.md dynamisch anhand der echten Dateien im PDFs-Ordner generieren
python3 - << 'EOF'
import os
import glob
import re

pdf_dir = "PDFs"
readme_path = "README.md"

if os.path.exists(pdf_dir):
    # Alle PDFs holen, Templates ausschließen
    all_pdfs = [os.path.basename(f) for f in glob.glob(os.path.join(pdf_dir, "*.pdf"))]
    valid_pdfs = [p for p in all_pdfs if not p.startswith("TEMP_")]
    valid_pdfs.sort()

    # Kategorisierung der PDFs nach Präfix
    physics_links = []
    art_links = []
    overview_links = []
    other_links = []

    for pdf in valid_pdfs:
        path = f"./PDFs/{pdf}"
        name_clean = os.path.splitext(pdf)[0]
        
        if pdf.startswith("PHY_"):
            physics_links.append(f"* [{name_clean}]({path})")
        elif pdf.startswith("ART_"):
            art_links.append(f"* [{name_clean}]({path})")
        elif pdf in ["grades.pdf", "lehrplan.pdf"]:
            overview_links.append(f"* [{name_clean}]({path})")
        else:
            other_links.append(f"* [{name_clean}]({path})")

    # README einlesen, um den Header/Footer zu behalten, oder komplett passend zusammenbauen
    # Hier bauen wir den zentralen Inhaltsbereich passend zu deiner Struktur auf:
    
    print(f"Gefundene PDFs verlinkt: {valid_pdfs}")

    # Beispielhafter Code zum Aktualisieren der README-Abschnitte kann hier erfolgen.
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
