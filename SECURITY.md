# Security policy

## Supported versions

Only the latest commit on the default branch is supported.

## Reporting a vulnerability

Open a private GitHub security advisory rather than a public issue when the
report contains exploitable details.

## Deployment warning

KasmVNC authentication is disabled inside the container. Deploy it only behind
an authenticated reverse proxy and restrict port 8444 so it is not
reachable directly from untrusted networks.

Never commit MSI installers, unapproved font payloads beyond
`assets/fonts/SEGUISYM.TTF`, Wine prefixes, character data, credentials,
certificates, cookies, or reverse-proxy secrets.
