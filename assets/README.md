# Local build assets

This directory contains the local Aurora installer input and one bundled custom
font used by the image build.

The installer is expected at:

```text
assets/Aurora Setup.msi
```

The image publish workflow creates this file from the `AURORA_MSI_BASE64`
repository secret before building the image.

## Bundled custom font

The repository intentionally commits one custom font file:

```text
assets/fonts/SEGUISYM.TTF
```

The image build validates and installs this font automatically for Linux and
Wine. No local font-copy step is required.
