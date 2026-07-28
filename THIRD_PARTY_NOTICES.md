# Third-party notices

This repository does not redistribute the third-party application payloads
listed below. A local build downloads or consumes them under their respective
licenses.

| Component | Project/source | Notes |
|---|---|---|
| KasmVNC | https://github.com/kasmtech/KasmVNC | GPL-2.0; included in the locally built image |
| Wine | https://www.winehq.org/ | LGPL and other component licenses |
| Winetricks | https://github.com/Winetricks/winetricks | Installs third-party runtime components |
| Ubuntu | https://ubuntu.com/ | Base distribution and packages |
| Aurora Character Builder | https://aurorabuilder.com/ | User-supplied installer; not included |
| Microsoft runtimes | https://www.microsoft.com/ | Downloaded by Winetricks during build; not included in this repository |
| Bundled custom font (`assets/fonts/SEGUISYM.TTF`) | Included in this repository | Installed automatically during image build |

The MIT license in this repository applies only to the original files in this
repository. It does not relicense third-party software or content.
