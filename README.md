# Aurora Kasm Docker

Run Aurora Character Builder as a browser-accessible application using Wine,
Openbox, and KasmVNC in one Docker image.

The provided Compose configuration starts one Aurora session with a persistent
Wine prefix and shared external character-data directory.

## What this repository does

- Builds a 32-bit Wine prefix on Ubuntu 24.04.
- Installs `.NET Framework 4.5.2`, Visual C++ 2010, and required fonts through
  Winetricks.
- Installs a locally supplied Aurora MSI.
- Runs only Aurora inside a minimal Openbox session.
- Streams the application through KasmVNC over HTTPS.
- Maps `/data/aurora` to both:
  - Wine drive `D:`
  - `C:\Users\aurora\Documents\5e Character Builder`
- Runs a single Aurora session per deployment.

## Important licensing boundary

This project contains original container configuration and automation plus one
bundled custom font (`assets/fonts/SEGUISYM.TTF`). It does **not** include
Aurora, Microsoft runtimes, a Wine prefix, D&D content, or character files.

You must obtain Aurora yourself and ensure that your use complies with its
license. This project is not affiliated with Aurora, Kasm Technologies,
Microsoft, Wine, Wizards of the Coast, or Hasbro.

## Requirements

- Docker Engine with the Compose plugin.
- An x86-64 host.
- At least 12 GB free while building.
- A legally obtained `Aurora Setup.msi`.
- A writable host directory containing your Aurora character data.

The mounted data must be accessible to UID/GID `1000:1000`. The container never
changes ownership of `/data/aurora`.

## Build and run

1. Copy the installer to:

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
   docker compose build
   docker compose up -d
   ```

The first build can take a long time because Wine and the Microsoft runtime
installers must finish without interactive prompts.

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
