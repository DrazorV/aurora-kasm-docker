# Aurora Kasm Docker

Run Aurora Character Builder in a browser with Wine, Openbox, and KasmVNC.
The published image already contains Aurora and its required Wine runtime, so
running it only requires Docker and a folder for your Aurora content.

## Quick start

Create a `compose.yaml` file with the following contents. The `./content`
directory is the only host folder you need to provide; Docker creates it if it
does not already exist.

````yaml
services:
  aurora:
    image: ghcr.io/drazorv/aurora-kasm:latest
    container_name: aurora
    restart: unless-stopped
    ports:
      - "8444:8444"
    volumes:
      - ./content:/data/aurora
      - aurora-config:/config

volumes:
  aurora-config:
````

Start Aurora:

```bash
docker compose up -d
```

Open `https://HOST:8444` in a browser. The KasmVNC certificate is generated
locally, so the first direct connection will show a certificate warning.

Place your `5e Character Builder` content in `./content`. Inside the container,
that folder is available both as Wine drive `D:` and at
`C:\Users\aurora\Documents\5e Character Builder`.

## Customize the deployment (optional)

The minimal Compose file is enough for the default image and port. Customize it
only when needed:

- Use a different image tag or registry by changing `image`.
- Change the public port by replacing the left side of `8444:8444`.
- Bind the port only to localhost for use behind a reverse proxy:

  ```yaml
  ports:
    - "127.0.0.1:8444:8444"
  ```

- Replace `./content` with an absolute path when your content lives elsewhere.
- Set `TZ` under `environment` if you need a specific timezone.

The repository's `.env.example` and `compose.yaml` provide the same kinds of
settings for deployments that prefer environment-based configuration.

## Requirements

- Docker Engine with the Compose plugin.
- An x86-64 host.
- A writable content directory accessible to UID/GID `1000:1000`.

On first startup, the container attempts to `chown` only `/data/aurora` itself
to `1000:1000` when needed. If your host filesystem or mount options block that
change, set host-side ownership manually.

## Persistent data

| Path | Purpose |
|---|---|
| `./content` | Your Aurora character data on the host |
| `aurora-config` | Wine prefix, Aurora preferences, and container logs |
| `/config/logs/xvnc.log` | KasmVNC log inside the container |
| `/config/logs/session.log` | Openbox, Wine, and Aurora output inside the container |

Keep `aurora-config` separate for each user. Sharing the content directory is
supported, but avoid editing the same character file concurrently.

## Logs

```bash
docker compose logs -f aurora
docker exec aurora tail -f /config/logs/session.log
docker exec aurora tail -f /config/logs/xvnc.log
```

## Updating

Pull and restart to use the latest published image:

```bash
docker compose pull
docker compose up -d
```

Back up the `aurora-config` volume before recreating the deployment. To start
with a new Wine prefix after an image update, remove or replace that volume.

## Reverse proxy and security

KasmVNC authentication is disabled in the container. Put the service behind
Authelia or another authentication gateway, and do not expose the KasmVNC port
directly to untrusted networks. See [`docs/reverse-proxy.md`](docs/reverse-proxy.md)
for Nginx notes.

## Building the image locally

Local builds are optional and are only needed when you want to build Aurora
from your own legally obtained installer. Place it at:

```text
assets/Aurora Setup.msi
```

Then build with:

```bash
docker compose -f compose.yaml -f compose.build.yaml build
```

The first build can take a long time while Wine and the Microsoft runtime
installers complete.

## Licensing

This repository contains original container configuration and automation, one
bundled custom font (`assets/fonts/SEGUISYM.TTF`), and may include an Aurora
installer at `assets/Aurora Setup.msi` for image builds. It does not commit an
installed Aurora runtime, Microsoft runtimes, a Wine prefix, D&D content, or
character files.

Published images may include Aurora when built from a legally obtained
installer. You are responsible for ensuring your use complies with Aurora's
license. This project is not affiliated with Aurora, Kasm Technologies,
Microsoft, Wine, Wizards of the Coast, or Hasbro.

## Known limitation

Aurora is a Windows WPF application running through Wine. Small font-metric or
control-alignment differences may remain compared with native Windows, even
with the correct fonts and 96-DPI configuration.
