#!/bin/bash

# ========================================
# Log- und Dump-Verzeichnis
DUMPDIR="/var/log/sendmail-wrapper"
LOGFILE="$DUMPDIR/wrapper.log"
DEBUG=0  # auf 1 setzen für Debug-Modus: keine .eml-Löschung

# Hinweis: Rechte setzen
# mkdir -p /var/log/sendmail-wrapper
# chmod 1777 /var/log/sendmail-wrapper
# touch /var/log/sendmail-wrapper/wrapper.log
# chmod 666 /var/log/sendmail-wrapper/wrapper.log
# chown vmail:vmail /var/log/sendmail-wrapper/wrapper.log
# ========================================

# Sicherstellen, dass Verzeichnis existiert
mkdir -p "$DUMPDIR"
chmod 1777 "$DUMPDIR"

# EML-Datei speichern
TS=$(date +%s%N)
EMLFILE="$DUMPDIR/mail-$TS.eml"
cat > "$EMLFILE"

# Header analysieren
TO=$(grep -i "^To: " "$EMLFILE" | head -n1 | sed 's/^To: //I' | tr -d '\r\n')
FROM=$(grep -i "^From: " "$EMLFILE" | head -n1 | sed 's/^From: //I' | tr -d '\r\n')
ARGS="$*"

# Fallback-From setzen
[[ -z "$FROM" ]] && FROM="no-reply@yourdomain.tld"

# Logging: alles in einer Zeile
echo "[$(date '+%Y-%m-%d %H:%M:%S')] FROM=$FROM TO=$TO FILE=$EMLFILE ARGS=\"$ARGS\"" >> "$LOGFILE"

# Abbruch bei fehlendem Empfänger
if [[ -z "$TO" ]]; then
  echo "Fehler: Kein To:-Header gefunden, Abbruch." >> "$LOGFILE"
  [[ $DEBUG -eq 0 ]] && rm -f "$EMLFILE"
  exit 1
fi

# Mail versenden
/usr/sbin/sendmail -f "$FROM" "$TO" < "$EMLFILE"
SENDMAIL_EXIT=$?

# Nur löschen, wenn kein Debug aktiv
if [[ $DEBUG -eq 0 ]]; then
  rm -f "$EMLFILE"
fi

exit $SENDMAIL_EXIT
