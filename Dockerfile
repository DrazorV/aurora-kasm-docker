# syntax=docker/dockerfile:1.7
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG KASMVNC_VERSION=1.4.0
ARG WINETRICKS_VERSION=20260125
ARG TARGETARCH

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    WINEARCH=win32 \
    WINEDEBUG=-all \
    WINEPREFIX=/opt/aurora/wine-template

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Package versions follow the supported Ubuntu 24.04 repositories at build time.
# hadolint ignore=DL3008
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        cabextract \
        curl \
        dbus-x11 \
        fontconfig \
        fonts-dejavu-core \
        gosu \
        libasound2t64 \
        openbox \
        p7zip-full \
        procps \
        ssl-cert \
        tini \
        tzdata \
        unzip \
        wine \
        wine32:i386 \
        wine64 \
        winbind \
        wmctrl \
        x11-utils \
        x11-xserver-utils \
        xfonts-base \
        xvfb \
    && case "${TARGETARCH:-amd64}" in \
         amd64) KASM_ARCH=amd64 ;; \
         *) echo "Unsupported architecture: ${TARGETARCH}. Aurora is x86-only." >&2; exit 1 ;; \
       esac \
    && curl -fsSL \
        -o /tmp/kasmvnc.deb \
        "https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/kasmvncserver_noble_${KASMVNC_VERSION}_${KASM_ARCH}.deb" \
    # KasmVNC dependencies are resolved by APT from the same Ubuntu repositories.
    # hadolint ignore=DL3008
    && apt-get install -y --no-install-recommends /tmp/kasmvnc.deb \
    && curl -fsSL \
        -o /usr/local/bin/winetricks \
        "https://raw.githubusercontent.com/Winetricks/winetricks/${WINETRICKS_VERSION}/src/winetricks" \
    && chmod 0755 /usr/local/bin/winetricks \
    && rm -f /tmp/kasmvnc.deb \
    && rm -rf /var/lib/apt/lists/*

RUN if getent group aurora >/dev/null; then \
        :; \
    elif getent group 1000 >/dev/null; then \
        groupmod --new-name aurora "$(getent group 1000 | cut -d: -f1)"; \
    else \
        groupadd --gid 1000 aurora; \
    fi \
    && if id -u aurora >/dev/null 2>&1; then \
        :; \
    elif getent passwd 1000 >/dev/null; then \
        usermod \
            --gid aurora \
            --home /home/aurora \
            --login aurora \
            --move-home \
            --shell /bin/bash \
            "$(getent passwd 1000 | cut -d: -f1)"; \
    else \
        useradd \
            --uid 1000 \
            --gid aurora \
            --create-home \
            --shell /bin/bash \
            aurora; \
    fi \
    && usermod --append --groups ssl-cert aurora \
    && install -d -m 0755 -o aurora -g aurora \
        /config \
        /data/aurora \
        /opt/aurora \
        /opt/aurora/openbox

COPY assets/ /tmp/aurora-assets/
COPY docker/openbox/rc.xml /opt/aurora/openbox/rc.xml
COPY docker/install-aurora.sh /usr/local/lib/aurora/install-aurora.sh
COPY docker/install-fonts.sh /usr/local/lib/aurora/install-fonts.sh
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY docker/start-session.sh /usr/local/bin/start-session.sh
COPY docker/start-aurora.sh /usr/local/bin/start-aurora.sh
COPY docker/healthcheck.sh /usr/local/bin/healthcheck.sh

RUN chmod 0755 \
        /usr/local/bin/entrypoint.sh \
        /usr/local/bin/start-session.sh \
        /usr/local/bin/start-aurora.sh \
        /usr/local/bin/healthcheck.sh \
        /usr/local/lib/aurora/install-aurora.sh \
        /usr/local/lib/aurora/install-fonts.sh \
    && /usr/local/lib/aurora/install-aurora.sh \
    && /usr/local/lib/aurora/install-fonts.sh \
    && rm -rf /tmp/aurora-assets \
    && chown -R aurora:aurora /opt/aurora

EXPOSE 8444

VOLUME ["/config", "/data/aurora"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
