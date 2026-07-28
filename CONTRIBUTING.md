# Contributing

Contributions to the container automation and documentation are welcome.

Before opening a pull request:

1. Do not add Aurora installers, Microsoft binaries/fonts, Wine prefixes,
   character data, or credentials.
2. Run `make validate`.
3. Describe the Wine, KasmVNC, and Docker versions used for testing.
4. State whether both independent sessions and PDF generation were tested.

Issues involving Aurora itself should include relevant output from
`/config/logs/session.log` without personal character data.
