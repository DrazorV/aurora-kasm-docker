# Contributing

Contributions to the container automation and documentation are welcome.

Before opening a pull request:

1. Do not commit Aurora installers except for the optional
   `assets/Aurora Setup.msi` path used by image builds, additional font payloads
   beyond `assets/fonts/SEGUISYM.TTF`, Wine prefixes, character data, or
   credentials.
2. Run `make validate`.
3. Describe the Wine, KasmVNC, and Docker versions used for testing.
4. State whether the single session and PDF generation were tested.

Issues involving Aurora itself should include relevant output from
`/config/logs/session.log` without personal character data.
