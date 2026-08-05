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

# --- 3c. README.md dynamisch für alle Fächer generieren ---
README="README.md"

if [ -f "$README" ]; then
    TMP_README=$(mktemp)

    while IFS= read -r line; do
        if [[ "$line" == "## 📚 Kurse & Fächer" ]]; then
            echo "$line" >> "$TMP_README"
            read -r line; echo "$line" >> "$TMP_README"
            read -r line; echo "$line" >> "$TMP_README"
            read -r line; echo "$line" >> "$TMP_README"

            # --- Leistungskurse (LK) ---
            echo '<details>' >> "$TMP_README"
            echo '<summary><b>🔥 Leistungskurse (LK)</b></summary>' >> "$TMP_README"
            echo '<br>' >> "$TMP_README"
            echo '' >> "$TMP_README"

            generate_lk_fach() {
                local fach_folder="$1"
                local fach_title="$2"
                local fach_short="$3"
                local fach_icon="$4"

                echo '<details>' >> "$TMP_README"
                echo "<summary><b>$fach_icon $fach_title</b></summary>" >> "$TMP_README"
                echo '<br>' >> "$TMP_README"
                echo '' >> "$TMP_README"

                local path="Subjects/$fach_folder"
                if [ -d "$path" ]; then
                    # Kapitel durchgehen
                    for chap in "$path"/CHA_*; do
                        if [ -d "$chap" ]; then
                            local chap_name=$(basename "$chap")
                            local c_num=$(echo "$chap_name" | cut -d'_' -f2)
                            local c_txt=$(echo "$chap_name" | cut -d'_' -f3-)
                            
                            echo "Kapitel $c_num - $c_txt" >> "$TMP_README"
                            echo '' >> "$TMP_README"

                            # Suche nach Zusammenfassungen / Aufgaben etc. im flachen PDFs/-Ordner
                            for pdf in "PDFs/${fach_short}_"*.pdf; do
                                if [ -f "$pdf" ]; then
                                    local p_base=$(basename "$pdf" .pdf)
                                    # Prüfen ob das PDF zum aktuellen Kapitel gehört (anhand der Nummer)
                                    if [[ "$p_base" == *_${c_num}_* ]] || [[ "$p_base" == *_${c_num} ]]; then
                                        # Typ erkennen
                                        if [[ "$p_base" == *_SUM_* ]]; then
                                            echo "* [Zusammenfassung](./$pdf)" >> "$TMP_README"
                                        elif [[ "$p_base" == *_EXE_* ]]; then
                                            echo "* [Aufgaben](./$pdf)" >> "$TMP_README"
                                        elif [[ "$p_base" == *_ESS_* ]]; then
                                            echo "* [Essay](./$pdf)" >> "$TMP_README"
                                        fi
                                    fi
                                fi
                            done
                            echo '' >> "$TMP_README"
                        fi
                    done

                    # Experimente (EXP) global im Fach
                    local has_exp=false
                    for pdf in "PDFs/${fach_short}_EXP_"*.pdf; do
                        [ -f "$pdf" ] && has_exp=true && break
                    done

                    if [ "$has_exp" = true ]; then
                        echo "🧪 Experimente" >> "$TMP_README"
                        echo '' >> "$TMP_README"
                        for pdf in "PDFs/${fach_short}_EXP_"*.pdf; do
                            if [ -f "$pdf" ]; then
                                local p_name=$(basename "$pdf" .pdf)
                                echo "* [🧪 $p_name](./$pdf)" >> "$TMP_README"
                            fi
                        done
                        echo '' >> "$TMP_README"
                    fi

                    # Formelsammlung (FOR)
                    for pdf in "PDFs/${fach_short}_FOR"*.pdf; do
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

            generate_lk_fach "Physics" "Physik" "PHY" "⚡"
            generate_lk_fach "Math" "Mathematik" "MAT" "📐"
            generate_lk_fach "English" "Englisch" "ENG" "🇬🇧"

            echo '</details>' >> "$TMP_README"
            echo '' >> "$TMP_README"

            # --- Grundkurse (GK) ---
            echo '<details>' >> "$TMP_README"
            echo '<summary><b>📖 Grundkurse (GK)</b></summary>' >> "$TMP_README"
            echo '<br>' >> "$TMP_README"
            echo '' >> "$TMP_README"

            generate_gk_fach() {
                local fach_folder="$1"
                local fach_title="$2"
                local fach_short="$3"
                local fach_icon="$4"

                echo '<details>' >> "$TMP_README"
                echo "<summary><b>$fach_icon $fach_title</b></summary>" >> "$TMP_README"
                echo '<br>' >> "$TMP_README"
                echo '' >> "$TMP_README"

                local path="Subjects/$fach_folder"
                if [ -d "$path" ]; then
                    for chap in "$path"/CHA_*; do
                        if [ -d "$chap" ]; then
                            local chap_name=$(basename "$chap")
                            local c_num=$(echo "$chap_name" | cut -d'_' -f2)
                            local c_txt=$(echo "$chap_name" | cut -d'_' -f3-)

                            echo "Kapitel $c_num - $c_txt" >> "$TMP_README"
                            echo '' >> "$TMP_README"

                            for pdf in "PDFs/${fach_short}_"*.pdf; do
                                if [ -f "$pdf" ]; then
                                    local p_base=$(basename "$pdf" .pdf)
                                    if [[ "$p_base" == *_${c_num}_* ]] || [[ "$p_base" == *_${c_num} ]]; then
                                        if [[ "$p_base" == *_SUM_* ]]; then
                                            echo "* [Zusammenfassung](./$pdf)" >> "$TMP_README"
                                        elif [[ "$p_base" == *_EXE_* ]]; then
                                            echo "* [Aufgaben](./$pdf)" >> "$TMP_README"
                                        elif [[ "$p_base" == *_ESS_* ]]; then
                                            echo "* [Essay](./$pdf)" >> "$TMP_README"
                                        fi
                                    fi
                                fi
                            done
                            echo '' >> "$TMP_README"
                        fi
                    done
                fi
                echo '</details>' >> "$TMP_README"
                echo '' >> "$TMP_README"
            }

            generate_gk_fach "German" "Deutsch" "GER" "✍️"
            generate_gk_fach "History" "Geschichte" "HIS" "🏛️"
            generate_gk_fach "Civics" "Gemeinschaftskunde" "CIV" "⚖️"
            generate_gk_fach "Religion" "Religion" "REL" "⛪"
            generate_gk_fach "Art" "Kunst" "ART" "🎨"
            generate_gk_fach "PE" "Sport" "PE" "⚽"
            generate_gk_fach "Astronomy" "Astronomie" "AST" "🔭"

            echo '</details>' >> "$TMP_README"

            # Bis zur Notenübersicht überspringen im alten Template
            while IFS= read -r skip_line; do
                [[ "$skip_line" == "## 📊 Notenübersicht" ]] && { echo "$skip_line" >> "$TMP_README"; break; }
            done
        else
            echo "$line" >> "$TMP_README"
        fi
    done < "$README"

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
    git commit -m "Automatisches Backup & README PDF-Verlinkung vom $DATUM"  
    git push origin main  
    notify-send "Git Backup" "Schulordner & README erfolgreich aktualisiert!" -i document-save  
fi  

# 7. Zurück ins Home-Verzeichnis
cd
