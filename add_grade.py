#!/usr/bin/env python3
import os
import sys
import datetime
import zipfile
import xml.etree.ElementTree as ET

SCHOOL_DIR = os.path.expanduser("~/Documents/School")
ODS_FILE = os.path.join(SCHOOL_DIR, "grades.ods")
CSV_FILE = os.path.join(SCHOOL_DIR, "grades.csv")

SUBJECTS = [
    "Physik",
    "Mathematik",
    "Englisch",
    "Deutsch",
    "Geschichte",
    "Gemeinschaftskunde",
    "Religion",
    "Kunst",
    "Sport",
    "Astronomie"
]

def get_subject():
    print("\n=== 1. FACH AUSWÄHLEN ===")
    for idx, sub in enumerate(SUBJECTS, 1):
        print(f"  [{idx}] {sub}")
    print(f"  [{len(SUBJECTS)+1}] Anderes Fach eingeben")
    
    while True:
        try:
            choice = input("\nWähle eine Nummer (1-11): ").strip()
            if not choice:
                continue
            num = int(choice)
            if 1 <= num <= len(SUBJECTS):
                return SUBJECTS[num - 1]
            elif num == len(SUBJECTS) + 1:
                custom = input("Name des Fachs eingeben: ").strip()
                if custom:
                    return custom
            print("Ungültige Auswahl, bitte erneut versuchen.")
        except ValueError:
            print("Bitte eine Zahl eingeben.")

def get_type():
    print("\n=== 2. ART DER LEISTUNG ===")
    print("  [1] Schriftlich (Klausur / Test)")
    print("  [2] Mündlich (Mitarbeit / Referat)")
    
    while True:
        choice = input("\nWähle 1 oder 2: ").strip()
        if choice == "1":
            return "Schriftlich"
        elif choice == "2":
            return "Mündlich"
        print("Bitte '1' oder '2' eingeben.")

def get_points():
    print("\n=== 3. NOTENPUNKTE (0 - 15) ===")
    while True:
        try:
            pts_str = input("Punkte eingeben (0-15): ").strip()
            pts = int(pts_str)
            if 0 <= pts <= 15:
                return pts
            print("Punkte müssen zwischen 0 und 15 liegen!")
        except ValueError:
            print("Bitte eine Zahl von 0 bis 15 eingeben.")

def get_description():
    desc = input("\n=== 4. BEZEICHNUNG / NOTIZ (optional, z.B. 'Klausur 1') ===\n> ").strip()
    return desc if desc else "-"

def write_to_csv(date_str, subject, grade_type, points, desc):
    file_exists = os.path.exists(CSV_FILE)
    with open(CSV_FILE, "a", encoding="utf-8") as f:
        if not file_exists:
            f.write("Datum;Fach;Art;Punkte;Bezeichnung\n")
        f.write(f"{date_str};{subject};{grade_type};{points};{desc}\n")

def create_default_ods(date_str, subject, grade_type, points, desc):
    mimetype = b"application/vnd.oasis.opendocument.spreadsheet"
    
    manifest_xml = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0">
 <manifest:file-entry manifest:media-type="application/vnd.oasis.opendocument.spreadsheet" manifest:full-path="/"/>
 <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="content.xml"/>
</manifest:manifest>'''

    content_xml = f'''<?xml version="1.0" encoding="UTF-8"?>
<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" 
                         xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" 
                         xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0">
 <office:body>
  <office:spreadsheet>
   <table:table table:name="Noten">
    <table:table-row>
     <table:table-cell office:value-type="string"><text:p>Datum</text:p></table:table-cell>
     <table:table-cell office:value-type="string"><text:p>Fach</text:p></table:table-cell>
     <table:table-cell office:value-type="string"><text:p>Art</text:p></table:table-cell>
     <table:table-cell office:value-type="string"><text:p>Punkte</text:p></table:table-cell>
     <table:table-cell office:value-type="string"><text:p>Bezeichnung</text:p></table:table-cell>
    </table:table-row>
    <table:table-row>
     <table:table-cell office:value-type="string"><text:p>{date_str}</text:p></table:table-cell>
     <table:table-cell office:value-type="string"><text:p>{subject}</text:p></table:table-cell>
     <table:table-cell office:value-type="string"><text:p>{grade_type}</text:p></table:table-cell>
     <table:table-cell office:value-type="float" office:value="{points}"><text:p>{points}</text:p></table:table-cell>
     <table:table-cell office:value-type="string"><text:p>{desc}</text:p></table:table-cell>
    </table:table-row>
   </table:table>
  </office:spreadsheet>
 </office:body>
</office:document-content>'''

    with zipfile.ZipFile(ODS_FILE, 'w', zipfile.ZIP_DEFLATED) as zf:
        zf.writestr('mimetype', mimetype)
        zf.writestr('META-INF/manifest.xml', manifest_xml)
        zf.writestr('content.xml', content_xml)

def append_to_ods(date_str, subject, grade_type, points, desc):
    if not os.path.exists(ODS_FILE):
        create_default_ods(date_str, subject, grade_type, points, desc)
        return

    temp_zip = ODS_FILE + ".tmp"
    with zipfile.ZipFile(ODS_FILE, 'r') as z_in, zipfile.ZipFile(temp_zip, 'w') as z_out:
        for item in z_in.infolist():
            data = z_in.read(item.filename)
            if item.filename == 'content.xml':
                root = ET.fromstring(data)
                tables = root.findall('.//{urn:oasis:names:tc:opendocument:xmlns:table:1.0}table')
                if tables:
                    table = tables[0]
                    row = ET.Element('{urn:oasis:names:tc:opendocument:xmlns:table:1.0}table-row')
                    
                    vals = [
                        ('string', str(date_str)),
                        ('string', str(subject)),
                        ('string', str(grade_type)),
                        ('float', str(points)),
                        ('string', str(desc))
                    ]
                    
                    for v_type, val in vals:
                        cell = ET.Element('{urn:oasis:names:tc:opendocument:xmlns:table:1.0}table-cell')
                        cell.set('{urn:oasis:names:tc:opendocument:xmlns:office:1.0}value-type', v_type)
                        if v_type == 'float':
                            cell.set('{urn:oasis:names:tc:opendocument:xmlns:office:1.0}value', val)
                        p = ET.Element('{urn:oasis:names:tc:opendocument:xmlns:text:1.0}p')
                        p.text = val
                        cell.append(p)
                        row.append(cell)
                    
                    table.append(row)
                data = ET.tostring(root, encoding='utf-8', xml_declaration=True)
            z_out.writestr(item, data)
            
    os.replace(temp_zip, ODS_FILE)

def main():
    os.makedirs(SCHOOL_DIR, exist_ok=True)
    
    print("==========================================")
    print("   📊 NOTENEINTRAG - OBERSTUFE")
    print("==========================================")
    
    subject = get_subject()
    grade_type = get_type()
    points = get_points()
    desc = get_description()
    
    today = datetime.date.today().strftime("%d.%m.%Y")
    
    try:
        append_to_ods(today, subject, grade_type, points, desc)
        write_to_csv(today, subject, grade_type, points, desc)
        
        print("\n==========================================")
        print("✅ Note erfolgreich eingetragen!")
        print(f"📌 Datum:       {today}")
        print(f"📚 Fach:        {subject}")
        print(f"📝 Art:         {grade_type}")
        print(f"💯 Punkte:      {points} NP")
        print(f"🏷️  Notiz:       {desc}")
        print("==========================================")
    except Exception as e:
        print(f"\n❌ Fehler beim Speichern: {e}")

if __name__ == "__main__":
    main()
