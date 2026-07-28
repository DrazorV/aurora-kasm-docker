# Security policy

## Supported versions

Only the latest commit on the default branch is supported.

## Reporting a vulnerability

Open a private GitHub security advisory rather than a public issue when the
report contains exploitable details.

## Deployment warning

KasmVNC authentication is disabled inside the container. Deploy it only behind
an authenticated reverse proxy and restrict ports 8444/8445 so they are not
reachable directly from untrusted networks.

Never commit MSI installers, fonts, Wine prefixes, character data, credentials,
certificates, cookies, or reverse-proxy secrets.
