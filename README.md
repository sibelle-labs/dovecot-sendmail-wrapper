# dovecot-sendmail-wrapper

Ein robuster `/usr/sbin/sendmail`-Wrapper für Dovecot + Sieve (Vacation), der Probleme mit `sendmail -t` in Postfix behebt.

## Problem

Dovecot erzeugt Vacation-Mails über Sieve, die zwar RFC-konform sind, aber nicht immer einen `To:`-Header in den ersten Headerzeilen enthalten. Der `sendmail -t` Befehl von Postfix erkennt so keine Empfänger und versendet die Mail fehlerhaft oder gar nicht.
Das Problem ist nicht neu, aber doch für mich unter Oracle Linux 9.x mit Dovecot 2.3.16 und Postfix 3.5.25 !

## Lösung

Dieses Wrapper-Skript:
- speichert die `.eml`-Mail temporär,
- extrahiert `To:` und `From:`,
- übergibt sie explizit an `/usr/sbin/sendmail`,
- funktioniert unabhängig von Header-Reihenfolge,
- speichert optional Logs und Mailkopien.

## Verwendung

1. Skript installieren:
```bash
cp sendmail-wrapper.sh /usr/local/bin/sendmail-wrapper.sh
chmod +x /usr/local/bin/sendmail-wrapper.sh

2. im local.conf

protocol lmtp {
  mail_plugins = sieve
  sendmail_path = /usr/local/bin/sendmail-wrapper.sh
}
# oder
protocol lda {
  mail_plugins = sieve
  sendmail_path = /usr/local/bin/sendmail-wrapper.sh
}

3. Logverzeichnis anlegen:
mkdir -p /var/log/sendmail-wrapper
chmod 1777 /var/log/sendmail-wrapper
