
# Jellyfin

## Transcoding

```bash
# You can find the device you are going to use for transcoding under:
/dev/dri

# Query the id of the render group on the host system and use it in the Docker CLI or docker-compose file:
getent group render | cut -d: -f3
```

Befor you enable transcoding in your jellyfin instance, you can check wether the graphics card is mounted correctly into the container. Use these two commands:

```bash
# Check the QSV and VA-API codecs:
docker exec -it jellyfin /usr/lib/jellyfin-ffmpeg/vainfo

# Check the OpenCL runtime status:
docker exec -it jellyfin /usr/lib/jellyfin-ffmpeg/ffmpeg -v verbose -init_hw_device vaapi=va -init_hw_device opencl@va

```

Next login into Jellyfin and enable transcoding:

1. Open the Hamburger Menu on the top left.
2. Click on `Dashboard`.
3. Go to `Playback / Transcoding`.
4. Select `Intel QuickSync (QSV)`.
5. Enable hardware decoding for the supported codecs.

## Cache images with nginx

Create a cache folder under `/var/cache/nginx` and change the the owner to nginx user:

```bash
mkdir /var/cache/nginx/jellyfin

chown -R www-data: /var/cache/nginx 
```

Add the following lines to your `/etc/nginx/site-enabled/jellyfin.conf`. The first part outside the server block, the second inside the server block.

```
# Add this outside of your server block (i.e. http block)
proxy_cache_path /var/cache/nginx/jellyfin levels=1:2 keys_zone=jellyfin:100m max_size=15g inactive=30d use_temp_path=off;

# Cache images (inside server block)
location ~ /Items/(.*)/Images {
  proxy_pass http://$jellyfin:8096;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_set_header X-Forwarded-Protocol $scheme;
  proxy_set_header X-Forwarded-Host $http_host;

  proxy_cache jellyfin;
  proxy_cache_revalidate on;
  proxy_cache_lock on;
  # add_header X-Cache-Status $upstream_cache_status; # This is only to check if cache is working
}
```

## Plugins

A list of plugins I use:

- AniDB
- Fanart
- InfuseSync
- IntroSkipper
- Playback Reporting
- Reports
- Session Cleaner
- TMDb
- TheTVDB
- Webhook

### Webhook

Configure the webhook to send notifications to your ntfy instance. Go to Dashboard -&gt; My Plugins -&gt; Webhook:

1. Server URL: URL of your jellyfin instance (e.g. https://jellyfin.domain.tld)
2. Add Generic Destination
3. Webhook name: ntfy
4. Webhook URL: ntfy.domain.tld
5. Status: ✅ Enable
6. Notification Type: 
    1. ✅ Item Added
7. Item Type: 
    1. Movies
    2. Episodes
    3. Season
    4. Series
    5. Albums
    6. Songs
    7. Videos
8. Templates: Be inspired by the [Ntfy.handlebars](https://github.com/jellyfin/jellyfin-plugin-webhook/blob/master/Jellyfin.Plugin.Webhook/Templates/Ntfy.handlebars) template
9. Add Request Header: 
    1. Key: Authorization
    2. Value: Basic BASE64\_ENCODED\_TOKEN ('echo "Basic $(echo -n ':NTFY\_TOKEN' | base64)')
10. Add Request Header: 
    1. Key: X-Markdown
    2. Value: true
11. Save
12. If it doesn't work -&gt; [Debug](https://github.com/jellyfin/jellyfin-plugin-webhook?tab=readme-ov-file#debugging)
    1. logging.conf = volumes/jellyfin/config/config/logging.default.json
