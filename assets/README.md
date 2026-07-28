# Local build assets

This directory intentionally contains no redistributable application payloads.

Before building, place your legally obtained installer here:

```text
assets/Aurora Setup.msi
```

The MSI is ignored by Git and included only in your local Docker build context.

## Optional Microsoft fonts

If you are licensed to use them, place the following files under
`assets/fonts/`:

```text
segoeui.ttf
segoeuib.ttf
segoeuil.ttf
seguisb.ttf
segoeuisl.ttf
seguisym.ttf
```

The build validates and installs supplied `.ttf` files. Font files are ignored
by Git and must not be committed to this repository.
