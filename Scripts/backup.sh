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

# --- 3c. README.md Automatisch für die Fächer aktualisieren ---
README="README.md"

if [ -f "$README" ]; then
    # Temporäre Datei für den neuen README-Inhalt
    TMP_README=$(mktemp)

    # Wir lesen die README zeilenweise durch und generieren den Fächer-Teil dynamisch neu
    while IFS= read -r line; do
        # Wir suchen im Block zwischen den Kurs-Überschriften und der Notenübersicht
        if [[ "$line" == "## 📚 Kurse & Fächer" ]]; then
            echo "$line" >> "$TMP_README"
            # Überspringe bis zum Block-Anfang einlesen
            read -r line; echo "$line" >> "$TMP_README"
            read -r line; echo "$line" >> "$TMP_README"
            read -r line; echo "$line" >> "$TMP_README"
            
            # --- LEISTUNGSKURSE (LK) ---
            echo '<details>' >> "$TMP_README"
            echo '<summary><b>🔥 Leistungskurse (LK)</b></summary>' >> "$TMP_README"
            echo '<br>' >> "$TMP_README"
            echo '' >> "$TMP_README"

            # Funktion zum Generieren der Fach-Abschnitte (LK)
            gen_lk_subject() {
                local subj_folder="$1"
                local subj_title="$2"
                local subj_display="$3"
                
                echo '<details>' >> "$TMP_README"
                echo "<summary><b>$subj_display</b></summary>" >> "$TMP_README"
                echo '<br>' >> "$TMP_README"
                echo '' >> "$TMP_README"

                local path="Subjects/$subj_folder"
                if [ -d "$path" ]; then
                    # Nach Kapiteln suchen (CHA_*)
                    for chap in "$path"/CHA_*; do
                        if [ -d "$chap" ]; then
                            local chap_name=$(basename "$chap")
                            # Schöner Name für die Anzeige (z.B. Kapitel 1 - Name)
                            local c_num=$(echo "$chap_name" | cut -d'_' -f2)
                            local c_txt=$(echo "$chap_name" | cut -d'_' -f3-)
                            echo "Kapitel $c_num - $c_txt" >> "$TMP_README"
                            echo '' >> "$TMP_README"

                            # PDFs in diesem Kapitel auflisten
                            for pdf in "$chap"/*.pdf; do
                                if [ -f "$pdf" ]; then
                                    local p_name=$(basename "$pdf" .pdf)
                                    echo "* [$p_name](./$pdf)" >> "$TMP_README"
                                fi
                            done
                            echo '' >> "$TMP_README"
                        fi
                    done

                    # Experimente direkt im Fach-Ordner (falls vorhanden)
                    local has_exp=false
                    for pdf in "$path"/*_EXP_*.pdf; do
                        [ -f "$pdf" ] && has_exp=true && break
                    done
                    
                    if [ "$has_exp" = true ]; then
                        echo "🧪 Experimente" >> "$TMP_README"
                        echo '' >> "$TMP_README"
                        for pdf in "$path"/*_EXP_*.pdf; do
                            if [ -f "$pdf" ]; then
                                local p_name=$(basename "$pdf" .pdf)
                                echo "* [🧪 $p_name](./$pdf)" >> "$TMP_README"
                            fi
                        done
                        echo '' >> "$TMP_README"
                    fi

                    # Formelsammlung (FOR)
                    for pdf in "$path"/*_FOR*.pdf; do
                        if [ -f "$pdf" ]; then
                            echo '<br>' >> "$TMP_README"
                            echo '' >> "$TMP_README"
                            echo "* [📄 Formelsammlung](./$pdf)" >> "$TMP_README"
                            echo '' >> "$TMP_README"
                        fi
                    done
                fi
                echo '</details>' >> "$TMP_README"
                echo '' >> "$TMP_README"
            }

            # Physik (Beispiel LK)
            gen_lk_subject "Physics" "Physics" "⚡ Physik"
            # Mathe LK (Beispiel)
            gen_lk_subject "Math" "Math" "📐 Mathematik"
            # Englisch (Beispiel)
            gen_lk_subject "English" "English" "🇬🇧 Englisch"

            echo '</details>' >> "$TMP_README"
            echo '' >> "$TMP_README"

            # --- GRUNDKURSE (GK) ---
            echo '<details>' >> "$TMP_README"
            echo '<summary><b>📖 Grundkurse (GK)</b></summary>' >> "$TMP_README"
            echo '<br>' >> "$TMP_README"
            echo '' >> "$TMP_README"

            gen_gk_subject() {
                local subj_folder="$1"
                local subj_display="$2"
                echo '<details>' >> "$TMP_README"
                echo "<summary><b>$subj_display</b></summary>" >> "$TMP_README"
                echo '' >> "$TMP_README"
                local path="Subjects/$subj_folder"
                if [ -d "$path" ]; then
                    for chap in "$path"/CHA_*; do
                        if [ -d "$chap" ]; then
                            local c_num=$(basename "$chap" | cut -d'_' -f2)
                            local c_txt=$(basename "$chap" | cut -d'_' -f3-)
                            echo "* [Kapitel $c_num: $c_txt](./$chap)" >> "$TMP_README"
                        fi
                    done
                fi
                echo '</details>' >> "$TMP_README"
                echo '' >> "$TMP_README"
            }

            gen_gk_subject "German" "✍️ Deutsch"
            gen_gk_subject "History" "🏛️ Geschichte"
            gen_gk_subject "Civics" "⚖️ Gemeinschaftskunde"
            gen_gk_subject"Religion" "⛪ Religion"
            gen_gk_subject "Art" "🎨 Kunst"
            gen_gk_subject "PE" "⚽ Sport"
            gen_gk_subject "Astronomy" "🔭 Astronomie"

            echo '</details>' >> "$TMP_README"

            # Überspringe den alten statischen Fächerblock in der originalen README bis zur Notenübersicht
            while IFS= read -r skip_line; do
                [[ "$skip_line" == "## 📊 Notenübersicht" ]] && { echo "$skip_line" >> "$TMP_README"; break; }
            done
        else
            echo "$line" >> "$TMP_README"
        fi
    done < "$README"

    # README überschreiben
    mv "$TMP_README" "$README"
fi

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
    git commit -m "Automatisches Backup, flache PDFs & README Update vom $DATUM"  
    git push origin main  
    notify-send "Git Backup" "Schulordner, PDFs & README erfolgreich aktualisiert!" -i document-save  
fi  

# 7. Zurück ins Home-Verzeichnis
cd
