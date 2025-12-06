# Zigbee2MQTT

## MQTT kommunikation absichern

```bash
docker exec -it mqtt sh
cd /mosquitto/conf
mosquitto_passwd -c passwd z2m
exit
```

Die Datei `/opt/docker/home_stack/volumes/mosquitto/conf/mosquitto.conf` bearbeiten und folgendes ergänzen, wenn notwendig:

```bash
allow_anonymous false
password_file /mosquitto/conf/passwd
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
```

Als nächstes hinterlegen wir die Logindaten für MQTT in der Zigbee2MQTT Konfiguration. Dafür die Datei `/opt/docker/home/volumes/zigbee2mqtt/data/configuration.yaml` bearbeiten und folgendes ergänzen:

```yaml
homeassistant: true
permit_join: false
mqtt:
  base_topic: zigbee2mqtt
  server: mqtt://mqtt
  user: z2m
  password: MQTT_PASSWORD
serial:
  port: /dev/ttyACM0
  adapter: deconz
frontend: true
```
