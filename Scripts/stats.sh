#!/bin/bash
cd ~/Documents/School || exit

STATS_FILE="Overview/STATS.md"
mkdir -p Overview

# 1. Überschrift und Datum schreiben
echo "# 📊 Schul-Statistiken & Noten" > "$STATS_FILE"
echo "**Letztes Update:** $(date +'%d.%m.%Y %H:%M')" >> "$STATS_FILE"
echo "" >> "$STATS_FILE"

# 2. Dokumenten-Statistik sammeln
ODT_COUNT=$(find . -type f -name "*.odt" | wc -l)
PDF_COUNT=$(find . -type f -name "*.pdf" | wc -l)
CHAPTER_COUNT=$(find . -type d -name "CHA_*" | wc -l)

echo "## 📁 Dokumente" >> "$STATS_FILE"
echo "- **Erstellte Kapitel:** $CHAPTER_COUNT" >> "$STATS_FILE"
echo "- **LibreOffice-Dateien (.odt):** $ODT_COUNT" >> "$STATS_FILE"
echo "- **Generierte PDFs:** $PDF_COUNT" >> "$STATS_FILE"
echo "" >> "$STATS_FILE"

# 3. ODS Noten-Scanner
ODS_FILE="Overview/grades.ods"

if [ -f "$ODS_FILE" ]; then
    echo "## 📈 Aktueller Notenstand" >> "$STATS_FILE"
    
    # LibreOffice konvertiert die ODS unsichtbar in eine CSV-Datei im /tmp/ Ordner
    libreoffice --headless --convert-to csv "$ODS_FILE" --outdir /tmp >/dev/null 2>&1
    CSV_FILE="/tmp/grades.csv"

    if [ -f "$CSV_FILE" ]; then
        echo "| Fach | Note |" >> "$STATS_FILE"
        echo "|------|------|" >> "$STATS_FILE"
        
        # Wir lesen die CSV-Datei aus (Trennzeichen kann Komma oder Semikolon sein)
        while IFS=";," read -r fach note rest; do
            # Entferne mögliche Anführungszeichen, die LibreOffice beim CSV-Export hinzufügt
            fach=$(echo "$fach" | tr -d '"')
            note=$(echo "$note" | tr -d '"')
            
            # Zeilen überspringen, die leer sind oder den Header "Fach" enthalten
            if [[ -n "$fach" && -n "$note" && "$fach" != "Fach" && "$fach" != "Subject" ]]; then
                echo "| $fach | **$note** |" >> "$STATS_FILE"
            fi
        done < "$CSV_FILE"
        
        rm "$CSV_FILE"
    else
        echo "*Fehler: Konnte Noten nicht auslesen.*" >> "$STATS_FILE"
    fi
fi
