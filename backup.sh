#!/bin/bash

# Ordner-Pfade definieren
SCHUL_DIR="$HOME/Documents/School"
LEHRE_DIR="$HOME/Documents/Lehre"

# Funktion zum Konvertieren, Committen und Pushen
process_repo() {
    local TARGET_DIR="$1"
    local NAME="$2"

    # Prüfen, ob der Ordner überhaupt existiert
    if [ ! -d "$TARGET_DIR" ]; then
        echo "Ordner $TARGET_DIR nicht gefunden. Überspringe..."
        return
    fi

    echo "Verarbeite $NAME ($TARGET_DIR)..."
    cd "$TARGET_DIR" || return

    # 1. Alte PDFs löschen
    find . -type f -name "*.pdf" -delete

    # 2. LibreOffice-Dateien in PDFs umwandeln
    find . -type f \( -name "*.odt" -o -name "*.ods" -o -name "*.odp" -o -name "*.odg" -o -name "*.odb" -o -name "*.odf" \) | while read -r FILE; do
        DIR=$(dirname "$FILE")
        libreoffice --headless --convert-to pdf "$FILE" --outdir "$DIR" 2>/dev/null
    done

    # 3. Datum und Uhrzeit
    DATUM=$(date +"%d.%m.%Y - %H:%M Uhr")

    # 4. Änderungen vormerken
    git add .

    # 5. Commit & Push, falls Änderungen vorliegen
    if ! git diff-index --quiet HEAD --; then
        git commit -m "Automatisches Backup vom $DATUM"
        git push origin main
        notify-send "Git Backup" "$NAME & PDFs erfolgreich gesichert!" -i document-save
    else
        echo "Keine Änderungen in $NAME."
    fi
}

# Skript ausführen für beide Ordner
process_repo "$SCHUL_DIR" "Schulordner"
process_repo "$LEHRE_DIR" "Lehre-Ordner"

# Zurück ins Home-Verzeichnis
cd "$HOME"
