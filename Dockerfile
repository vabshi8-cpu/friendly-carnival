FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Ubuntu Desktop components, VNC server, and web streaming utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    ubuntu-desktop-minimal \
    gnome-session \
    gnome-terminal \
    tigervnc-standalone-server \
    novnc \
    websockify \
    dbus-x11 \
    x11-xserver-utils \
    sudo \
    curl \
    wget \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# 2. Expose VNC (5901) and noVNC Web UI (6080)
EXPOSE 5901
EXPOSE 6080

# 3. Create startup script for VNC and noVNC proxy
CMD bash -c "\
  mkdir -p ~/.vnc && \
  echo '#!/bin/sh\nexport XKL_XMODMAP_DISABLE=1\nexec gnome-session' > ~/.vnc/xstartup && \
  chmod +x ~/.vnc/xstartup && \
  vncserver -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE :1 && \
  websockify -D --web=/usr/share/novnc/ 6080 localhost:5901 && \
  tail -f /dev/null"
