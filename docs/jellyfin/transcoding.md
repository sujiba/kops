# Jellyfin Transcoding – Intel Core Ultra 5 225H (QSV) <!-- omit in toc -->

Hardware transcoding configuration for Jellyfin on an Intel Core Ultra 5 225H (Arrow Lake-H) with integrated Intel graphics. Jellyfin runs on Kubernetes using the official image, which already ships `jellyfin-ffmpeg`, all Intel drivers and the OpenCL runtime.

The media engine can decode **and** encode H.264, HEVC (8/10-bit), VP9 and AV1 in hardware. Multiple simultaneous 4K HDR transcodes are no problem.

Reference: [Jellyfin Docs – Intel GPU](https://jellyfin.org/docs/general/post-install/transcoding/hardware-acceleration/intel) · [Jellyfin Docs – Stereo Downmix](https://jellyfin.org/docs/general/post-install/transcoding/downmix)


## Overview <!-- omit in toc -->
- [Prerequisites](#prerequisites)
  - [Check drivers (VA-API / QSV)](#check-drivers-va-api--qsv)
  - [Check OpenCL (for tone mapping)](#check-opencl-for-tone-mapping)
- [Settings](#settings)
  - [Hardware Acceleration](#hardware-acceleration)
  - [Hardware Decoding](#hardware-decoding)
  - [Hardware Encoding](#hardware-encoding)
  - [Encoding Formats](#encoding-formats)
  - [VPP Tone Mapping](#vpp-tone-mapping)
  - [Tone Mapping (OpenCL)](#tone-mapping-opencl)
  - [General \& Paths](#general--paths)
  - [Audio](#audio)
  - [Software Encoding \& Deinterlacing](#software-encoding--deinterlacing)
  - [Subtitles \& Segments](#subtitles--segments)
- [Verification](#verification)

---

## Prerequisites

The pod needs access to the iGPU's render device. `/dev/dri/renderD128` is mounted as a `hostPath`, and the GID of the host's `render` group is set via `supplementalGroups` (`getent group render | cut -d: -f3`). The container must run as `privileged`.

Note: The `I have no name!` shell prompt inside the pod is expected, because the UID from `runAsUser` has no entry in the container's `/etc/passwd`. It doesn't affect GPU access.

### Check drivers (VA-API / QSV)

```bash
/usr/lib/jellyfin-ffmpeg/vainfo --display drm --device /dev/dri/renderD128
```

Expected output includes `Intel iHD driver` (tested with iHD 26.2.4, libva 2.24.1). The listed profiles determine which codecs are enabled below. `VAEntrypointVLD` means decoding, `VAEntrypointEncSlice` means encoding.

### Check OpenCL (for tone mapping)

```bash
/usr/lib/jellyfin-ffmpeg/ffmpeg -v verbose -init_hw_device vaapi=va:/dev/dri/renderD128 -init_hw_device opencl@va
```

Successful if the OpenCL device is detected (`Intel(R) OpenCL Graphics`) and all three `... function found` lines appear. The final `Exiting with exit code 1` is expected, since the command is run without input or output files.

---

## Settings

Found under **Dashboard → Playback → Transcoding**. The order matches the UI.

### Hardware Acceleration

```config
Hardware acceleration: Intel Quicksync (QSV)
QSV Device:            /dev/dri/renderD128
```

- **Intel Quicksync (QSV):** The preferred method on Linux for current Intel GPUs. VA-API is only needed for very old hardware.
- **QSV Device:** The iGPU's render node, mounted into the pod.

### Hardware Decoding

```config
Enable hardware decoding for:
[x] H264
[x] HEVC
[x] MPEG2
[ ] VC1
[x] VP8
[x] VP9
[x] AV1
[x] HEVC 10bit
[x] VP9 10bit
[x] HEVC RExt 8/10bit
[x] HEVC RExt 12bit

[x] Prefer OS native DXVA or VA-API hardware decoders
```

- Everything reported by `vainfo` with `VAEntrypointVLD` is enabled. The iGPU even decodes HEVC 4:2:2 and 4:4:4 up to 12-bit (RExt).
- **VC1** is disabled because the hardware doesn't support it (it doesn't appear in `vainfo`). Such files, usually old Blu-ray rips, are decoded by the CPU.
- **Prefer OS native … decoders:** Uses the VA-API decoders instead of the QSV decoders. Required for Dolby Vision support.

### Hardware Encoding

```config
[x] Enable hardware encoding
[x] Enable Intel Low-Power H.264 hardware encoder
[x] Enable Intel Low-Power HEVC hardware encoder
```

- **Enable hardware encoding:** Encoding runs on the iGPU instead of the CPU.
- **Low-Power encoders:** Must stay enabled on Arrow Lake, since Meteor Lake / Arrow Lake and newer only support the Low-Power encoding mode. The required HuC firmware is loaded automatically from Gen 12 (Alder Lake) onwards, no kernel parameters needed. This can be verified on the node with `sudo dmesg | grep -i huc`.

### Encoding Formats

```config
[x] Allow encoding in HEVC format
[x] Allow encoding in AV1 format
```

- H.264 is always enabled. HEVC and AV1 are additionally allowed because the iGPU can encode both in hardware.
- Jellyfin only uses these formats if the client supports them. They save significant bandwidth at the same quality, which mainly helps with remote streaming.

### VPP Tone Mapping

```config
[ ] Enable VPP Tone mapping
VPP Tone mapping brightness gain: 16
VPP Tone mapping contrast gain:   1
```

- Disabled. VPP tone mapping is slightly more power-efficient, but offers very few tuning options and doesn't support Dolby Vision. If enabled, it would take priority over OpenCL.
- The gain values are defaults and have no effect while VPP is disabled.

### Tone Mapping (OpenCL)

```config
[x] Enable Tone mapping
Tone mapping algorithm: BT.2390
Tone mapping mode:      Auto
Tone mapping range:     Auto
Tone mapping desat:     0
Tone mapping peak:      100
Tone mapping param:     (empty)
```

- **Enable Tone mapping:** Converts HDR10, HLG and Dolby Vision to SDR when the client can't display HDR. Without tone mapping, HDR content looks washed out and grey on SDR devices. Runs via OpenCL on the iGPU.
- **Algorithm BT.2390:** The recommended default.
- **Mode Auto:** Switch to `RGB` if highlights look blown out.
- **Range Auto:** The output color range matches the source.
- **Desat 0, Peak 100, Param empty:** Defaults. Leave them unchanged as long as the picture looks good.

### General & Paths

```config
Transcoding thread count:  Auto
FFmpeg path:               /usr/lib/jellyfin-ffmpeg/ffmpeg
Transcode path:            /transcode
Fallback font folder path: (empty)
[ ] Enable fallback fonts
```

- **Thread count Auto:** Mainly affects software transcoding. CPU load is low anyway with hardware transcoding.
- **FFmpeg path:** The bundled `jellyfin-ffmpeg` from the official image.
- **Transcode path `/transcode`:** Dedicated volume for transcode segments. Ideally a fast local volume (e.g. `emptyDir` on SSD), since files are constantly written and deleted here.
- **Fallback fonts:** Only needed if subtitles with missing fonts render incorrectly.

### Audio

```config
[ ] Enable VBR audio encoding
Audio boost when downmixing: 1.5
Stereo Downmix Algorithm:    AC-4
Audio seek strategy:         TrimCopiedAudio
Max muxing queue size:       2048
```

- **VBR audio encoding:** Disabled, since variable bitrate can occasionally cause buffering or compatibility issues.
- **Stereo Downmix Algorithm AC-4:** An industry standard that preserves both volume level and spatial impression well. The most balanced algorithm for movies.
- **Audio boost 1.5:** The default of 2 is tuned for ffmpeg's built-in downmix (`None`). With AC-4, 1.5 is a good middle ground. If loud scenes sound distorted, lower it to 1.2–1.3. If everything is too quiet, raise it towards 2.
- **Seek strategy and muxing queue:** Defaults. Only increase the queue if `Too many packets buffered for output stream` appears in the FFmpeg log.

> **When does the downmix apply?** Only when the **server** transcodes the audio to stereo, i.e. when the client reports that it only supports stereo (typically browsers and some TV apps). With Direct Play or Direct Stream of multichannel audio, the playback device downmixes on its own and this setting has no effect. The playback info shows whether the server is downmixing: the audio stream is then listed as "Transcoding" with 2 channels.
>
> Changes only apply to newly started playback sessions.

### Software Encoding & Deinterlacing

```config
Encoding preset:      Auto
H.265 encoding CRF:   28
H.264 encoding CRF:   23
Deinterlacing method: Yet Another DeInterlacing Filter (YADIF)
[ ] Double the frame rate when deinterlacing
```

- **Preset, CRF and YADIF** only apply to software encoding (x264/x265) and software deinterlacing. With hardware acceleration enabled they are practically unused. Defaults are kept.
- **Double the frame rate:** Only relevant for interlaced content (Live TV, old DVDs). When enabled, it produces smoother motion. With QSV, deinterlacing happens in hardware anyway.

### Subtitles & Segments

```config
[x] Allow subtitle extraction on the fly
[ ] Throttle Transcodes
[x] Delete segments
Throttle after:         180
Time to keep segments:  720
```

- **Subtitle extraction on the fly:** Embedded subtitles are delivered to the client as text instead of being burned into the video, avoiding unnecessary transcoding.
- **Throttle Transcodes:** Disabled. Pausing the transcoder saves little on this hardware. It can be enabled if desired and turned off again if seeking causes problems.
- **Delete segments:** Segments that have already been watched are deleted after 720 s. This prevents the entire transcoded movie from piling up in `/transcode`, which can quickly reach several GB for 4K content.
- **Throttle after:** Default value. Has no effect while throttling is disabled.

---

## Verification

1. Play an HDR file (ideally 4K HEVC 10-bit) in the browser and select a lower quality to force a transcode.
2. The picture should show normal, vivid colors (tone mapping works).
3. The playback info or **Dashboard → Activity** should show "Transcoding". The playback's FFmpeg log contains `hevc_qsv` / `h264_qsv` and `tonemap_opencl`.
4. Optionally check GPU utilization **on the Kubernetes node** (not inside the pod):

   ```bash
   sudo intel_gpu_top
   ```

   `Video` shows decoding and encoding load, `Render/3D` shows the OpenCL tone mapping load. The pod's CPU usage should stay low.
