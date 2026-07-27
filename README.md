<div align="center">

  <img src="./img/Turmkreuz.png" alt="Logo" height="80">

  # Evangelische Schule Schloss Gaienhofen
  ### Oberstufe • Digitales Kursheft
  
  ![Last Commit](https://img.shields.io/github/last-commit/B13M4RK/SCHOOL?style=flat-square&color=blue)
  ![License](https://img.shields.io/badge/Abitur-2028-orange?style=flat-square)
  
  **Autor:** Paul Dreißig

</div>

---

## 📚 Kurse & Fächer

Das ist mein zentrales Repository für die Oberstufe. Hier findest du alle Notizen, Materialien und Kapitel zu den einzelnen Kursen:

<details>
<summary><b>🔥 Leistungskurse (LK)</b></summary>
<br>

<details>
<summary><b>⚡ Physik</b></summary>
<br>

Kapitel 1 - Name

* [Zusammenfassung](./Physics/CHA_01_NAME/PHY_SUM_01_NAME.pdf)
* [Aufgaben](./Physics/CHA_01_NAME/PHY_EXE_01.pdf)

Kapitel 2 - Name

* [Zusammenfassung](./Physics/CHA_02_NAME/PHY_SUM_02_NAME.pdf)
* [Aufgaben](./Physics/CHA_02_NAME/PHY_EXE_02.pdf)

🧪 Experimente

* [🧪 01 - Name](./Physics/PHY_EXP_01_NAME.pdf)

<br>

* [📄 Formelsammlung](./Physics/PHY_FOR.pdf)

</details>

<details>
<summary><b>📐 Mathematik</b></summary>

* [Kapitel 01: Name](./Math/CHA_01_NAME.pdf)

</details>

<details>
<summary><b>🇬🇧 Englisch</b></summary>

Kapitel 1 - Name

* [Kapitel 01: Name](./English/CHA_01_NAME.pdf)

Essays

* [01 - Name](./English/ENG_ESS_01_NAME.pdf)

</details>

</details>

<details>
<summary><b>📖 Grundkurse (GK)</b></summary>
<br>

<details>
<summary><b>✍️ Deutsch</b></summary>

* [Kapitel 01: Name](./German/CHA_01_NAME.pdf)
* [Kapitel 02: Name](./German/CHA_02_NAME.pdf)

</details>

<details>
<summary><b>🏛️ Geschichte</b></summary>

* [Kapitel 01: Name](./History/CHA_01_NAME.pdf)

</details>

<details>
<summary><b>⚖️ Gemeinschaftskunde</b></summary>

* [Kapitel 01: Name](./GK/CHA_01_NAME.pdf)

</details>

<details>
<summary><b>⛪ Religion</b></summary>

* [Kapitel 01: Name](./Religion/CHA_01_NAME.pdf)

</details>

<details>
<summary><b>🎨 Kunst</b></summary>

* [Kapitel 01: Name](./Kunst/CHA_01_NAME.pdf)

</details>

<details>
<summary><b>⚽ Sport</b></summary>

* [Kapitel 01: Name](./Sport/CHA_01_NAME.pdf)

</details>

<details>
<summary><b>🔭 Astronomie</b></summary>

* [Kapitel 01: Name](./Astronomie/CHA_01_NAME.pdf)

</details>

</details>

---

## 📊 Notenübersicht

* [📊 Notentabelle öffnen](./grades.pdf)

---

## 📥 Projekt Herunterladen

Git Clone (zum Updaten bis AUG 2028)

```bash
cd Downloads
git clone https://github.com/B13M4RK/SCHOOL.git
```
Download Zip (einmalig)
```bash
cd Downloads
curl -L -O https://github.com/B13M4RK/SCHOOL/archive/refs/heads/main.zip
unzip main.zip
rm main.zip
```

## 📤 Projekt Hochladen

1. Code kopieren und ins Terminal einfügen.
2. GitHub-Seite neu laden.
```bash
#!/bin/bash

# 1. In den Schulordner wechseln
cd ~/Documents/School || exit

# 2. Alte PDFs löschen, damit keine Karteileichen bleiben
find . -type f -name "*.pdf" -delete

# 3. Alle LibreOffice-Dateien suchen und als PDF neu speichern
find . -type f \( -name "*.odt" -o -name "*.ods" -o -name "*.odp" -o -name "*.odg" -o -name "*.odb" -o -name "*.odf" \) | while read -r FILE; do
    DIR=$(dirname "$FILE")
    libreoffice --headless --convert-to pdf "$FILE" --outdir "$DIR" 2>/dev/null
done

# 4. Datum und Uhrzeit holen
DATUM=$(date +"%d.%m.%Y - %H:%M Uhr")

# 5. Alle Dateien (inkl. erzeugter PDFs) vormerken
git add .

# 6. Nur committen und pushen, wenn es Änderungen gab
if ! git diff-index --quiet HEAD --; then
    git commit -m "Automatisches Backup vom $DATUM"
    git push origin main
    notify-send "Git Backup" "Schulordner & PDFs erfolgreich gesichert!" -i document-save
fi

# 7. Aus Ordnern raus
cd
```
---

## ⚖️ Lizenz & Nutzung

Dieses Repository ist freies Lernmaterial! Schülerinnen und Schüler dürfen alle Inhalte gerne **herunterladen, teilen und zum Lernen nutzen**.

* **Eigene Inhalte & Lösungen:** Alle Dokumente mit dem Vermerk `Autor: Paul Dreißig` beinhalten meine eigenen Mitschriften, Erklärungen und Ausarbeitungen. Sie stehen unter der [MIT-Lizenz](LICENSE) und dürfen frei verwendet werden.
* **Integrierte Aufgabenstellungen:** In meinen Dokumenten enthaltene Aufgabenstellungen dienen als Zitat zur Kontextualisierung meiner Lösungen. Die Urheberrechte an den originalen Aufgaben verbleiben bei den jeweiligen Lehrkräften, Schulen oder Verlagen.

> 💡 **Tipp für Mitschüler:** Du kannst das Repo über den grünen **Code**-Button oben als ZIP herunterladen oder per `git clone` auf deinen PC holen.
