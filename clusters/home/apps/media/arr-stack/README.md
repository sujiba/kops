# media stack

## Gluetun

### Quad9 
To check if dns is working as exptected, you can query for dns info with the following commands inside the containers:

```bash
dig +short txt proto.on.quad9.net.

# response
dot

# Replace [session] with a random hash (40 chars long) and [random] with random chars every request.
curl https://[session]-[random].ipleak.net/dnsdetection/
```

The curl output is a list of quad9 ip addresses. With whois you can search for the owner of the ip address. It should be one of those [network providers](https://docs.quad9.net/FAQs/#network-providers-dns-leak-tests).

## SABnzbd

Siehe [https://wiki.smail.koeln/books/docker/page/sabnzbd](https://wiki.smail.koeln/books/docker/page/sabnzbd)

# NFS-Share

- Control Panel -> Shared Folder -> media -> Press Edit 
    - Permissions: Read / Write for "guest"
    - NFS Permissions: 
        - Hostname / IP: IPADDRESS
        - Privileges: Read / Write
        - Squash: Map all users to guest -> assigns access privileges to all users of NFS client equivalent to the guest access privileges on your system
        - security: sys
        - Enable asynchronous: ✅

# SABnzbd

[SABnzbd](https://sabnzbd.org/) ist ein mutli-plattform Downloader für binäre Newsgroup-Dateien. Das Programm arbeiten im Hintergrund und vereinfacht das Herunterladen, Verifizieren und Entpacken von Dateien aus dem Usenet. SABnzbd nutzt NZB-Dateien, anstelle das Usenet direkt zu durchsuchen. Die NZBs erhält man durch verschiedene Usenet Indexer oder Foren. Das Userinterface von SABnzbd ist eine Web-App.


## Ersteinrichtung  


1. Sprache: Deutsch
2. Assistenten starten
3. Adresse: news.eweka.nl
4. Benutzer:
5. Passwort:
6. SSL: ✅  
    
7. Eweitert
8. Port: 563 oder 443
9. Verbindungen: 10 (max. 50)
10. Zertifikat überprüfen: Strikt
11. Server überprüfen
12. Weiter
13. SABnzbd anzeigen

Jetzt kann das Downloaden beginnen.

## Weitere Einstellungen

### Categories  


Die Kategorien werden für Radarr, Sonarr und Lidarr benötigt damit die einzelnen Anwendungen sich nicht gegenseitig stören.

<table border="1" id="bkmrk-category-priority-pr" style="border-collapse: collapse; width: 100%; height: 242.2px;"><colgroup><col style="width: 16.6865%;"></col><col style="width: 16.6865%;"></col><col style="width: 16.6865%;"></col><col style="width: 16.6865%;"></col><col style="width: 16.6865%;"></col><col style="width: 16.6865%;"></col><col style="width: 0%;"></col></colgroup><thead><tr style="height: 63.4px;"><th style="height: 63.4px;">Category</th><th style="height: 63.4px;">Priority</th><th style="height: 63.4px;">Processing</th><th style="height: 63.4px;">Script</th><th style="height: 63.4px;">Folder/Path</th><th colspan="2" style="height: 63.4px;">Indexer Categories / Groups</th></tr></thead><tbody><tr style="height: 29.8px;"><td style="height: 29.8px;">animes</td><td style="height: 29.8px;">default</td><td style="height: 29.8px;">default</td><td style="height: 29.8px;">-</td><td style="height: 29.8px;">animes</td><td style="height: 29.8px;">  
</td><td style="height: 29.8px;">  
</td></tr><tr style="height: 29.8px;"><td style="height: 29.8px;">documentaries</td><td style="height: 29.8px;">default</td><td style="height: 29.8px;">default</td><td style="height: 29.8px;">-</td><td style="height: 29.8px;">documentaries</td><td style="height: 29.8px;">  
</td><td style="height: 29.8px;">  
</td></tr><tr style="height: 29.8px;"><td style="height: 29.8px;">movies</td><td style="height: 29.8px;">default</td><td style="height: 29.8px;">default</td><td style="height: 29.8px;">-</td><td style="height: 29.8px;">movies</td><td style="height: 29.8px;">  
</td><td style="height: 29.8px;">  
</td></tr><tr style="height: 29.8px;"><td style="height: 29.8px;">music</td><td style="height: 29.8px;">default</td><td style="height: 29.8px;">default</td><td style="height: 29.8px;">-</td><td style="height: 29.8px;">music</td><td style="height: 29.8px;">  
</td><td style="height: 29.8px;">  
</td></tr><tr style="height: 29.8px;"><td style="height: 29.8px;">tv</td><td style="height: 29.8px;">default</td><td style="height: 29.8px;">default</td><td style="height: 29.8px;">-</td><td style="height: 29.8px;">tv</td><td style="height: 29.8px;">  
</td><td style="height: 29.8px;">  
</td></tr><tr style="height: 29.8px;"><td style="height: 29.8px;">prowlarr</td><td style="height: 29.8px;">default</td><td style="height: 29.8px;">default</td><td style="height: 29.8px;">-</td><td style="height: 29.8px;">prowlarr</td><td style="height: 29.8px;">  
</td><td style="height: 29.8px;">  
</td></tr></tbody></table>

[https://trash-guides.info/Downloaders/SABnzbd/Paths-and-Categories/](https://trash-guides.info/Downloaders/SABnzbd/Paths-and-Categories/)

### Ungewollte Dateiendungen  


Damit ungewollte Dateiendungen nicht geladen oder nach einem Download gelöscht werden, können folgende Einstellungen vorgenommen werden:

1. In den `Einstellungen` zum Unterpunkt `Schalter` wechseln
2. In der Kategorie `Warteschlange`: 
    1. `Erkennung identischer Downloads`: `Anhalten`
    2. `Ungewollte Dateiendungen` auf `Erlaubtliste` stellen und Dateiendungen eintragen: `mkv, mp4, aac, flac, mp3, ogg, wav, cbr, cbz, epub`
    3. Änderung speichern
3. In der Kategorie `Nachbearbeitung`: 
    1. `Downloads während der Nachbearbeitung anhalten`: ✅
    2. `Beispieldateien ignorieren`: ✅
    3. In `Unerwünschte Dateien` die Dateiendungen eintragen: `exe, bat, cmd, dll, html, idx, jar, nfo, py, ps1, sh, srr, srt, txt, sub, url, vbs`
    4. Änderung speichern

### URL Base

Sollte SABnzbd nur unter einem Pfad erreichbar sein (z.B. [https://domain.tld/sabnzb](https://domain.tld/sabnzb)), kann dies wie folgt eingestellt werden:

1. In den `Einstellungen` zum Unterpunkt `Spezial` wechseln 
    1. In der Kategorie `Werte`: `url_base` -> /sabnzbd

# Prowlarr

## Login

- Authentication: Forms (Login Page)
- Authentication Required: Enabled
- Username
- Password

## Configuration

### General

Settings -> General -> Analytics

1. Send Anonymous Usage Data: 

### UI

Settings -> UI -> Dates

1. Short Date Format: 25 Mar 2014
2. Long Date Format: Tuesday, 25 March, 2014
3. Time Format: 17:00/17:30

### Apps

Example for Radarr (add all the \*arr apps you're using):

Settings -> Apps -> Applications -> + -> Add Application -> Radarr

1. Name: Radarr
2. Sync Level: Full Sync
3. Prowlarr Server: http://localhost:9696
4. Radarr Server: http://localhost:7878
5. API Key: RADARR\_API\_KEY
6. Sync Categories: Movies (advanced settings)

### Donwload Clients

Settings -> Download Clients -> + -> SABnzbd

1. Name: SABznbd
2. Enable: ✅
3. Host: localhost
4. Port: 8080
5. API Key: SABNZBD\_FULL\_API\_KEY
6. Default Category: prowlarr
7. Mapped Categories: + (see also SABnzbd Categories)
8. 1. Example for movies (add all categories from SABnzbd)
        1. Download Client Category: movies
        2. Mapped Categories: movies

### Indexers

Indexers -> + Add Indexer -> Search for "Generic Newznab"

1. Name: Indexer name
2. Enable: ✅
3. Sync Profile: Standard
4. URL: Indexer url
5. API Key: Indexer API Key
6. VIP Expiration: yyyy-mm-dd
7. Query Limit: 10000 (advanced settings)
8. Grab Limit: 400 (advanced settings)
9. Limits Unit: Day (advanced settings)
10. Download Client: SABnzbd (advanced settings)

# Sonarr

<p class="callout info">It is recommended to use two sonarr instances. One for anime and one for tv shows.</p>

<p class="callout info">Disable Analytics under Settings -> General -> Analytics.</p>

[https://wiki.servarr.com/en/sonarr](https://wiki.servarr.com/en/sonarr)

## Login

- Authentication: Forms (Login Page)
- Authentication Required: Enabled
- Username
- Password

## Configuration

### Media Management

Settings -> Media Management -> [https://trash-guides.info/Sonarr/Sonarr-recommended-naming-scheme/](https://trash-guides.info/Sonarr/Sonarr-recommended-naming-scheme/)

### Profiles

Settings -> Profiles ->

1. [https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles/](https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles/)
2. [https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles-anime/](https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles-anime/)
3. [https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles-german-en/](https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles-german-en/)
4. [https://github.com/PCJones/radarr-sonarr-german-dual-language](https://github.com/PCJones/radarr-sonarr-german-dual-language)

### Quality

Settings -> Quality -> [https://trash-guides.info/Sonarr/Sonarr-Quality-Settings-File-Size/](https://trash-guides.info/Sonarr/Sonarr-Quality-Settings-File-Size/)

### Custom Formats

Settings -> Custom Formats -> [https://trash-guides.info/Sonarr/sonarr-collection-of-custom-formats/](https://trash-guides.info/Sonarr/sonarr-collection-of-custom-formats/)

### Indexers

Settings -> Indexers -> + -> Select Newznab

1. Name: Indexer name
2. Enable RSS: ✅
3. Enable Automatic Search: ✅
4. Enable Interactive Search: ✅
5. URL: Indexer url
6. API Key: Indexer API Key
7. Categories: 
8. Anime Categories: TV -> Anime, TV-De -> Anime
9. Anime Standard Format Search: 

### Download Clients

Settings -> Download Clients -> + Select SABnzbd

1. Name: SABnzbd
2. Enable: ✅
3. Host: localhost
4. Port: 8080
5. API Key: SABnzbd -> Settings -> Security -> API Key
6. Category: animes or tv

# Radarr
