# media stack

## gluetun env file

<span style="white-space: pre-wrap;">Create the </span>`<span class="editor-theme-code">gluetun.env</span>`<span style="white-space: pre-wrap;"> under </span>`<span class="editor-theme-code">/opt/docker/arr_stack</span>`:

```yaml
# See https://github.com/qdm12/gluetun-wiki/tree/main/setup#setup
VPN_SERVICE_PROVIDER=mullvad
VPN_TYPE=wireguard

# Create a new wireguard device: https://github.com/qdm12/gluetun/discussions/805#discussioncomment-2026642
# Device name on Mullvad Website: bingo bongo
WIREGUARD_PRIVATE_KEY=
WIREGUARD_ADDRESSES=IPADDRESS/32

# If the VPN server is owned by Mullvad
OWNED_ONLY=yes

# Comma separated list of countries
SERVER_COUNTRIES=Switzerland

# Comma separated list of cities
# - SERVER_CITIES=Zurich
# https://github.com/qdm12/gluetun-wiki/blob/main/setup/servers.md#update-the-vpn-servers-list
UPDATER_PERIOD=24h

# Turn DNS over TLS off to use default mullvad DNS servers
DOT=off
```

## compose.yml

<p class="callout info">This is a multi-stage setup. It is recommended to use two sonarr containers. One for tv series and one for animes. The Problem is that gluetun cannot differentiate between containers that use the same port. So you have to change the port for sonarr\_anime.</p>

<span style="white-space: pre-wrap;">Create the </span>`<span class="editor-theme-code">compose.yml</span>`<span style="white-space: pre-wrap;"> next to your </span>`<span class="editor-theme-code">gluetun.env</span>`:

```yaml
---
services:
  ### VPN - Mullvad
  gluetun:
    image: qmcgaw/gluetun
    container_name: gluetun-test
    env_file:
      - gluetun.env
    environment:
      - TZ=Europe/Berlin
      - PUID=1010
      - PGID=1010
    volumes:
      - ./volumes/gluetun:/gleutun
    ports:
      - 1080:1080     # socks5 proxy
      - 127.0.0.1:8080:8080/tcp # SABnzbd
      - 127.0.0.1:8686:8686/tcp # lidarr
      - 127.0.0.1:7878:7878/tcp # radarr
      - 127.0.0.1:8989:8989/tcp # sonarr
      - 127.0.0.1:8990:8990/tcp # sonarr_anime -> start container first and change port in config.xml
      - 127.0.0.1:9696:9696/tcp # prowlarr
    devices:
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - NET_ADMIN
    restart: unless-stopped

  ### Socks5 Proxy for Mullvad Browser
  socks5:
    image: serjs/go-socks5-proxy
    container_name: socks5
    network_mode: "service:gluetun"
    depends_on:
      gluetun:
        condition: service_healthy
    restart: unless-stopped

  ### Downloader - Usenet
  sabnzbd:
    image: linuxserver/sabnzbd:latest
    container_name: sabnzbd
    environment:
      - TZ=Europe/Berlin
      - PUID=1010
      - PGID=1010
      - UMASK=002
    volumes:
      - ./volumes/sabnzbd:/config
      - ./volumes/downloads/complete:/downloads
      - ./volumes/downloads/incomplete:/incomplete-downloads
    network_mode: "service:gluetun"
    depends_on:
      gluetun:
        condition: service_healthy
    restart: unless-stopped

  ### Library Manager - Music
  lidarr:
    image: lscr.io/linuxserver/lidarr:latest
    container_name: lidarr
    environment:
      - TZ=Europe/Berlin
      - PUID=1010
      - PGID=1010
      - UMASK=002
    volumes:
      - ./volumes/lidarr/config:/config
      - ./volumes/downloads/complete:/downloads
      - media:/media
    network_mode: "service:gluetun"
    depends_on:
      gluetun:
        condition: service_healthy
    restart: unless-stopped

  ### Library Manager - Movies
  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      - TZ=Europe/Berlin
      - PUID=1010
      - PGID=1010
      - UMASK=002
    volumes:
      - ./volumes/radarr/config:/config
      - ./volumes/downloads/complete:/downloads
      - media:/media
    network_mode: "service:gluetun"
    depends_on:
      gluetun:
        condition: service_healthy
    restart: unless-stopped

  ### Libarary Manager - TV Shows
  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      - TZ=Europe/Berlin
      - PUID=1010
      - PGID=1010
      - UMASK=002
    volumes:
      - ./volumes/sonarr/config:/config
      - ./volumes/downloads/complete:/downloads
      - media:/media
    network_mode: "service:gluetun"
    depends_on:
      gluetun:
        condition: service_healthy
    restart: unless-stopped

  ### Libarary Manager - Animes
  sonarr_anime:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr_anime
    environment:
      - TZ=Europe/Berlin
      - PUID=1010
      - PGID=1010
      - UMASK=002
    volumes:
      - ./volumes/sonarr_anime/config:/config
      - ./volumes/downloads/complete:/downloads
      - media:/media
    network_mode: "service:gluetun"
    depends_on:
      gluetun:
        condition: service_healthy
    restart: unless-stopped

  ### Index and Search Management
  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    environment:
      - TZ=Europe/Berlin
      - PUID=1010
      - PGID=1010
      - UMASK=002
    volumes:
      - ./volumes/prowlarr/config:/config
    network_mode: "service:gluetun"
    depends_on:
      gluetun:
        condition: service_healthy
    restart: unless-stopped

  ### Media Server - Jellyfin
  jellyfin:
    image: jellyfin/jellyfin
    container_name: jellyfin
    user: 1010:1010
    environment:
      - TZ=Europe/Berlin
      - JELLYFIN_PublishedServerUrl=https://jelly.intern.buschhaus.koeln
    volumes:
      - ./volumes/jellyfin/config:/config
      - ./volumes/jellyfin/cache:/cache
      - media:/media
    ports:
      - 127.0.0.1:8096:8096
    group_add:
      - "105"
    devices:
      - /dev/dri/renderD128:/dev/dri/renderD128
    restart: unless-stopped

  ### Media Requests - Jellyseerr
  jellyseerr:
    image: ghcr.io/fallenbagel/jellyseerr:latest
    container_name: jellyseerr
    environment:
      - TZ=Europe/Berlin
    ports:
      - 127.0.0.1:5055:5055
    volumes:
      - ./volumes/jellyseerr:/app/config
    restart: unless-stopped

# nfs prerequisite on your synology nas: https://wiki.smail.koeln/books/docker/page/nfs-share
volumes:
  media:
    driver_opts:
      type: "nfs"
      o: "addr=IPADDRESS,nfsvers=4.1,nolock,rw,soft"
      device: ":/volume2/media"
```

<span style="white-space: pre-wrap;">Now start the gluetun and sonarr\_anime container with </span>`<span class="editor-theme-code">docker compose up -d gluetun sonarr_anime</span>`<span style="white-space: pre-wrap;">. Edit </span>`<span class="editor-theme-code">/opt/docker/arr_stack/volumes/sonarr_anime/config/conifg.xml</span>`<span style="white-space: pre-wrap;"> and change the ports to 8990 and 9899. Save the changes and stop the containers with </span>`<span class="editor-theme-code">docker compose down</span>`.

<span style="white-space: pre-wrap;">Create the folder structure under </span>`<span class="editor-theme-code">/opt/docker/arr_stack/volumes/donwloads</span>`:

```bash
mkdir -p /opt/docker/arr_stack/volumes/donwloads/{animes,movies,music,tv}
```

<span style="white-space: pre-wrap;">Start all containers with </span>`<span class="editor-theme-code">docker compose up -d</span>`<span style="white-space: pre-wrap;">. </span>

## SABnzbd

<span style="white-space: pre-wrap;">Siehe </span>[https://wiki.smail.koeln/books/docker/page/sabnzbd](https://wiki.smail.koeln/books/docker/page/sabnzbd)

# NFS-Share

- <span style="white-space: pre-wrap;">Control Panel -&gt; Shared Folder -&gt; media -&gt; Press Edit </span>
    - Permissions: Read / Write for "guest"
    - <span style="white-space: pre-wrap;">NFS Permissions: </span>
        - Hostname / IP: IPADDRESS
        - Privileges: Read / Write
        - Squash: Map all users to guest -&gt; assigns access privileges to all users of NFS client equivalent to the guest access privileges on your system
        - security: sys
        - Enable asynchronous: ✅

# SABnzbd

[SABnzbd](https://sabnzbd.org/) ist ein mutli-plattform Downloader für binäre Newsgroup-Dateien. Das Programm arbeiten im Hintergrund und vereinfacht das Herunterladen, Verifizieren und Entpacken von Dateien aus dem Usenet. SABnzbd nutzt NZB-Dateien, anstelle das Usenet direkt zu durchsuchen. Die NZBs erhält man durch verschiedene Usenet Indexer oder Foren. Das Userinterface von SABnzbd ist eine Web-App.


## Ersteinrichtung  


1. <div class="li">Sprache: Deutsch</div>
2. <div class="li">Assistenten starten</div>
3. <div class="li">Adresse: news.eweka.nl</div>
4. <div class="li">Benutzer:</div>
5. <div class="li">Passwort:</div>
6. <div class="li">SSL: ✅  
    </div>
7. <div class="li">Eweitert</div>
8. <div class="li">Port: 563 oder 443</div>
9. <div class="li">Verbindungen: 10 (max. 50)</div>
10. <div class="li">Zertifikat überprüfen: Strikt</div>
11. <div class="li">Server überprüfen</div>
12. <div class="li">Weiter</div>
13. <div class="li">SABnzbd anzeigen</div>

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
    1. In der Kategorie `Werte`: `url_base` -&gt; /sabnzbd

# Prowlarr

## Login

- Authentication: Forms (Login Page)
- Authentication Required: Enabled
- Username
- Password

## Configuration

### General

Settings -&gt; General -&gt; Analytics

1. <span style="white-space: pre-wrap;">Send Anonymous Usage Data: </span>

### UI

Settings -&gt; UI -&gt; Dates

1. Short Date Format: 25 Mar 2014
2. Long Date Format: Tuesday, 25 March, 2014
3. Time Format: 17:00/17:30

### Apps

Example for Radarr (add all the \*arr apps you're using):

Settings -&gt; Apps -&gt; Applications -&gt; + -&gt; Add Application -&gt; Radarr

1. Name: Radarr
2. Sync Level: Full Sync
3. Prowlarr Server: http://localhost:9696
4. Radarr Server: http://localhost:7878
5. API Key: RADARR\_API\_KEY
6. Sync Categories: Movies (advanced settings)

### Donwload Clients

Settings -&gt; Download Clients -&gt; + -&gt; SABnzbd

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

Indexers -&gt; + Add Indexer -&gt; Search for "Generic Newznab"

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

<p class="callout info">Disable Analytics under Settings -&gt; General -&gt; Analytics.</p>

[https://wiki.servarr.com/en/sonarr](https://wiki.servarr.com/en/sonarr)

## Login

- Authentication: Forms (Login Page)
- Authentication Required: Enabled
- Username
- Password

## Configuration

### Media Management

<span style="white-space: pre-wrap;">Settings -&gt; Media Management -&gt; </span>[https://trash-guides.info/Sonarr/Sonarr-recommended-naming-scheme/](https://trash-guides.info/Sonarr/Sonarr-recommended-naming-scheme/)

### Profiles

Settings -&gt; Profiles -&gt;

1. [https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles/](https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles/)
2. [https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles-anime/](https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles-anime/)
3. [https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles-german-en/](https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles-german-en/)
4. [https://github.com/PCJones/radarr-sonarr-german-dual-language](https://github.com/PCJones/radarr-sonarr-german-dual-language)

### Quality

<span style="white-space: pre-wrap;">Settings -&gt; Quality -&gt; </span>[https://trash-guides.info/Sonarr/Sonarr-Quality-Settings-File-Size/](https://trash-guides.info/Sonarr/Sonarr-Quality-Settings-File-Size/)

### Custom Formats

<span style="white-space: pre-wrap;">Settings -&gt; Custom Formats -&gt; </span>[https://trash-guides.info/Sonarr/sonarr-collection-of-custom-formats/](https://trash-guides.info/Sonarr/sonarr-collection-of-custom-formats/)

### Indexers

Settings -&gt; Indexers -&gt; + -&gt; Select Newznab

1. Name: Indexer name
2. Enable RSS: ✅
3. Enable Automatic Search: ✅
4. Enable Interactive Search: ✅
5. URL: Indexer url
6. API Key: Indexer API Key
7. <span style="white-space: pre-wrap;">Categories: </span>
8. Anime Categories: TV -&gt; Anime, TV-De -&gt; Anime
9. <span style="white-space: pre-wrap;">Anime Standard Format Search: </span>

### Download Clients

Settings -&gt; Download Clients -&gt; + Select SABnzbd

1. Name: SABnzbd
2. Enable: ✅
3. Host: localhost
4. Port: 8080
5. API Key: SABnzbd -&gt; Settings -&gt; Security -&gt; API Key
6. Category: animes or tv

# Radarr
