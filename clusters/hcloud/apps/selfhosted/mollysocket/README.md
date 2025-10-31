# Molly Pushnachrichten durch ntfy <!-- omit in toc -->

[UnifiedPush Dokumentation](https://unifiedpush.org/users/distributors/ntfy/)<span style="white-space: pre-wrap;"></span>

- [Voraussetzung](#voraussetzung)
  - [ntfy Einstellungen](#ntfy-einstellungen)
  - [mollysocket Webseite](#mollysocket-webseite)
- [Molly-FOSS Einstellungen](#molly-foss-einstellungen)


## Voraussetzung

<span style="white-space: pre-wrap;">Installiere auf deinem Handy Molly-FOSS über den Accrescent AppStore. Zudem benötigst du auf deinem Server zu der mollysocket Instanz auch eine ntfy Instanz. Siehe hierfür </span>[https://wiki.smail.koeln/books/docker/chapter/ntfy](https://wiki.smail.koeln/books/docker/chapter/ntfy).

### ntfy Einstellungen

Solltest du vorab die Nutzbarkeit von ntfy durch Login eingeschränkt haben, müssen folgende Befehle unter /opt/docker/ntfy ausgeführt werden:

```bash
# Erlaube dem User, Topics die mit up starten lesend zu abonieren
docker exec -it ntfy ntfy access username 'up*' read-only

# Damit Pushnachrichten an Topics gesendet werden können, die mit up starten, müssen diese für alle schreibbar gemacht werden
docker exec -it ntfy ntfy access '*' 'up*' write-only
```

### mollysocket Webseite

Die Webseite molly.domain.tld sollte erreichbar und ein QR-Code zu sehen sein.

## Molly-FOSS Einstellungen

- <span style="white-space: pre-wrap;">Settings / Push notifications / </span>
    - Delivery service -&gt; UnifiedPush
    - <span style="white-space: pre-wrap;">UnifiedPush -&gt; QR-Code auf der Webseite </span>[https://molly.domain.tld](https://molly.domain.tld)<span style="white-space: pre-wrap;"> scannen</span>
    - <span style="white-space: pre-wrap;">UnifiedPush -&gt; Account ID kopieren </span>
        - In der compose.yml von mollysocket eintragen und container neu starten -&gt; MOLLY\_ALLOWED\_UUIDS=\["asdjiwi353i5-dsakd32-wdasd"\]
    - UnifiedPush -&gt; Test configuration
- Es sollte ein neues Topic in der ntfy App aufgetaucht sein
    - ntfy.domain.tld/up1neu32dsida
    - im.molly.app (UnifiedPush)