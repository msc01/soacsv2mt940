# soacsv2mt940
## Übersicht
Convert Statement Of Account .CSV to MT940 (swift) format -- Konvertierung Bankauszüge im .CSV-Format ins MT940-Format (SWIFT)

## Aufruf
Aufruf: soacsv2mt940 csvFilename [mt940Filename] [nbr] [openingBalance]

Beispiel: soacsvmt940 bank.csv bank.txt 0 -1523,89

Parameter:

- csvFilename: Name der Eingabe-Datei im .csv-Format, welche ins mt940-Format konvertiert werden soll.
- mt940Filename: optionaler Name der Ausgabe-Datei; falls der Parameter nicht angegeben wird, wird der Name der Eingabe-Datei genommen und statt der Endung .csv wird die Endung .mt940 angefügt.
- nbr: optionale Kontoauszugs-Nr., welche im Kopf-Bereich der mt940-Datei (Satzart :28c:) vermerkt wird. Wird der Parameter nicht angegeben, wird 0 genommen.
- openingBalance: optionaler Eröffungs-Saldo des Kontoauszugs. Wird dieser nicht mit übergeben, so wird 0 gneommen.

## Hintergrund
Einsatz-Szenario: Konto bei der Commerzbank, Buchhaltung mittels Collmex; automatische Übernahme der Auszüge der Commerzbank in die Collmex-Buchhaltung.

Die Commerzbank liefert Bankauszüge aktuell in zwei Formaten aus: als .CSV-Datei oder per HBCI mit Chipkarte (!). In Collmex können sie allerdings entweder als MT940-Datei importiert oder per HBCI mit PIN (!) eingelesen werden, so dass keine direkte Möglichkeit besteht, die Auszüge von der Commerzbank in Collmex zu importieren.

Eine Option ist, die Kontoauszüge  zunächst per HBCI mit Chipkarte in das Programm Bank X zu importieren und dann von dort ins MT940-Format zu exportieren, um sie so wiederum nach Collmex zu bekommen.

Da Bank X aber ausschließlich zu diesem Zweck im Einsatz wäre, kostenpflichtig ist und der für HBCI mit Chipkarte notwendige Chipkartenleser unterwegs nur schwerlich einsetzbar ist, wird ein Konvertierungsprogramm benötigt, welches die [.CSV-Kontoauszugsdatei] [1] der Commerzbank entsprechend ins [MT940-Format] [2] ([Details] [3])/ eine [MT940-Datei] [4] für den Import nach Collmex umwandelt.

## Umsetzung
Das Programm soll später nicht nur lokal sondern ggf. auch als Dienst / Webservice laufen, weshalb es in Ruby umgesetzt ist.

### Eingabe
Die Eingabe des Namens der zu verarbeitenden .CSV-Kontoauszugsdatei erfolgt zunächst per Kommandozeile beim Aufruf des Programms durch Übergabe des Dateinamens. Später soll die Datei per Datei-Browser ausgewählt werden können.

Prüfungen beim Einlesen der Eingabedatei:

* Datei nicht vorhanden?
* Datei leer?
* Datei nicht im Format .csv?

### Verarbeitung
Parsen .CSV - ermitteln der Felder mit mindestens folgenden Prüfungen:

* Überschriftszeile vorhanden / entspricht Vorgabe?
* Trennzeichen ist ";"?
* Nicht alle Felder?
* Felder enthalten gültige Werte?

Umwandeln ins Format mt940 in den Schritten (gemäß [mt940-Dateiaufbau] [3]):

* Kopf
* Rumpf
* Fuss

### Ausgabe
Die Ausgabe erfolgt im gleichen Verzeichnis und unter gleichem Namen wie die Eingabe-Datei, nur mit der Endung .mt940, mit mindestens folgenden Prüfungen:

* Ausgabedatei schon vorhanden?
 * Postfix Inkrement 1 an Dateinamen hängen, erneut versuchen (Schleife bis Erfolg)
* Ausgabedatei kann aus sonstigen Gründen nicht geschrieben werden?
 * Abbruch

### ToDo
Folgende Punkte sind noch umzusetzen:

v1.0:

- Credit/Debit-Ermittlung und "Positivierung" des entsprechenden Betrags in eigener Methode
- Prüfen der Überschriftenzeile auf die notwendigen Felder / Struktur
- Kommandozeilenparameter mit options: -n für nbr, damit nicht alle anderen mit angegeben werden müssen, falls eine Nummer übergeben werden soll
- Umstellung auf csv-Verarbeitung aus std-lib
- Namensgebung Klassen, Methoden, Variablen optimieren
- strftime auf .year, etc. umstellen?
- GVC anhand :umsatzart setzen
- Logging
- Auf GEM umstellen

v2.0:

- Datei per Dialog auswählen
- Server-Version


---

[1]:data/test.csv
[2]:http://de.wikipedia.org/wiki/MT940
[3]:doc/datenstruktur-mt940-swift.pdf
[4]:data/soamt940_test_template.mt940