# Home Assistant

## configuration.yaml

```yaml
# Loads default set of integrations. Do not remove.
default_config:

# Allow nginx reverse proxy
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1

# Load frontend themes from the themes folder
frontend:
  themes: !include_dir_merge_named themes

# Load additional configs under packages
homeassistant:
  packages: !include_dir_named packages

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml

```

## Wake-on-Lan

Unter `/opt/docker/home_stack/volumes/homeassistant/config/packages` die Datei `wake-on-lan.yaml` erstellen:

```yaml
switch:
  - platform: wake_on_lan
    mac: B4:2E:99:38:20:A2
    host: IP_ADDRESS
    name: "example"
  - platform: wake_on_lan
    mac: 38:20:A2:B4:2E:99
    host: IP_ADDRESS
    name: "example-02"
```

oder direkt in configuration.yaml.

# HACS

<p class="callout info">Für die Nutzung von HACS ist ein GitHub Account zwingend notwendig.</p>

Der Home Assistant Community Store gibt dir die Möglichkeit auf einem einfachen Weg Erweiterungen in Home Assistant zu installieren. HACS kann wie folgt installiert werden:

```bash
docker-compose exec -it homeassistant bash
wget -O - https://get.hacs.xyz | bash -
docker-compose restart homeassistant
```

# Zigbee2Mqtt  as iFrame in Home Assistant  

1. Go to settings
2. Select dashboards
3. `+ create dashboard`
4. Select Website and enter the url e.g. [https://home.domain.tld/z2m/](https://home.domain.tld/z2m/)
5. Enter title and select a symbol: `mdi:zigbee`

See also [Webpage Card](https://www.home-assistant.io/dashboards/iframe/).