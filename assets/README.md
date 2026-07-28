# Local build assets

This directory contains the local Aurora installer input and one bundled custom
font used by the image build.

Before a local/custom image build, place your legally obtained installer here:

```text
assets/Aurora Setup.msi
```

The MSI is ignored by Git and included only in your local Docker build context.
The default prebuilt image flow does not require placing an MSI here.

## Bundled custom font

The repository intentionally commits one custom font file:

```text
assets/fonts/SEGUISYM.TTF
```

The image build validates and installs this font automatically for Linux and
Wine. No local font-copy step is required.
