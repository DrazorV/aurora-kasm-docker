# Aurora Kasm Docker

Run Aurora Character Builder as a browser-accessible application using Wine,
Openbox, and KasmVNC in one Docker image.

The provided Compose configuration starts one Aurora session with a persistent
Wine prefix and shared external character-data directory.

## What this repository does

- Publishes a ready-to-use Aurora image to GHCR.
- Builds a 32-bit Wine prefix on Ubuntu 24.04.
- Installs `.NET Framework 4.5.2`, Visual C++ 2010, and required fonts through
  Winetricks.
- Installs Aurora during image build.
- Runs only Aurora inside a minimal Openbox session.
- Streams the application through KasmVNC over HTTPS.
- Maps `/data/aurora` to both:
  - Wine drive `D:`
  - `C:\Users\aurora\Documents\5e Character Builder`
- Runs a single Aurora session per deployment.

## Important licensing boundary

This repository contains original container configuration and automation plus
one bundled custom font (`assets/fonts/SEGUISYM.TTF`). The repository source
still does **not** commit Aurora binaries by default, Microsoft runtimes, a
Wine prefix, D&D content, or character files; `assets/Aurora Setup.msi` is the
only optional installer path supported by the build/publish workflows.

Published images may include Aurora if built from a legally obtained installer.
You are responsible for ensuring your use complies with Aurora's license. This
project is not affiliated with Aurora, Kasm Technologies, Microsoft, Wine,
Wizards of the Coast, or Hasbro.

## Requirements

- Docker Engine with the Compose plugin.
- An x86-64 host.
- A writable host directory containing your Aurora character data.

The mounted data must be accessible to UID/GID `1000:1000`. The container never
changes ownership of `/data/aurora`.

## Run prebuilt image (recommended)

1. Create the environment file:

   ```bash
   cp .env.example .env
   ```

2. Set `AURORA_DATA_PATH` in `.env` to the host directory that contains the
   `5e Character Builder` data.

3. Optionally override `AURORA_IMAGE` if you publish a different tag/owner.

4. Start the session:

   ```bash
   docker compose up -d
   ```

## Build locally (optional)

1. The installer is expected at:

   ```text
   assets/Aurora Setup.msi
   ```

2. The bundled custom font at `assets/fonts/SEGUISYM.TTF` is installed
   automatically during image build.

3. Create the environment file:

   ```bash
   cp .env.example .env
   ```

4. Set `AURORA_DATA_PATH` in `.env` to the host directory that contains the
   `5e Character Builder` data.

5. Build and start the session:

   ```bash
   docker compose -f compose.yaml -f compose.build.yaml build
   docker compose up -d
   ```

The first build can take a long time because Wine and the Microsoft runtime
installers must finish without interactive prompts.

## Publish the public image

1. Add a repository secret named `AURORA_MSI_BASE64` containing a base64-encoded
   Aurora installer:

   ```bash
   base64 -w 0 "Aurora Setup.msi"
   ```

2. Publishing is automatic on:
   - pushes to `main` (publishes `latest` and `sha-<shortsha>`)
   - pushed tags matching `v*` (publishes the tag plus `sha-<shortsha>`)

3. Optionally run `Publish Image` manually (`workflow_dispatch`) to publish an
   extra custom tag via `image_tag` (for example `latest` or `stable`).

4. The workflow publishes:
   - `ghcr.io/<owner>/aurora-kasm:latest` (on `main`)
   - `ghcr.io/<owner>/aurora-kasm:<image_tag>` (manual dispatch)
   - `ghcr.io/<owner>/aurora-kasm:sha-<shortsha>`
   - `ghcr.io/<owner>/aurora-kasm:<git-tag>` (on `v*` tags)

## URLs

With the example environment, Aurora is available at:

- `https://HOST:8444`

The KasmVNC certificate is locally generated, so direct browser access produces
a certificate warning. A reverse proxy should provide the public certificate.

## Persistent layout

| Container path | Purpose |
|---|---|
| `/config/wineprefix` | Per-user Wine installation and preferences |
| `/config/logs/xvnc.log` | KasmVNC log |
| `/config/logs/session.log` | Openbox, Wine, and Aurora output |
| `/data/aurora` | Shared character data supplied by the host |

Do not share `/config` between users. Sharing `/data/aurora` is supported, but
do not edit the same character file concurrently.

## Reverse proxy

KasmVNC authentication is deliberately disabled in the container. Protect the
service with Authelia or another authentication gateway and restrict direct
network access to the KasmVNC ports.

See [`docs/reverse-proxy.md`](docs/reverse-proxy.md) for Nginx notes.

## Logs

```bash
docker compose logs -f aurora
docker exec aurora tail -f /config/logs/session.log
docker exec aurora tail -f /config/logs/xvnc.log
```

## Updating

Back up the named `/config` volume before rebuilding. Rebuilding the image does
not modify existing prefixes automatically. To initialize a new prefix from an
updated image, start it with a new empty `/config` volume.

## Known limitation

Aurora is a Windows WPF application running through Wine. Small font-metric or
control-alignment differences may remain compared with native Windows even
when the correct fonts and 96-DPI configuration are used.
