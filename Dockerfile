FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Ubuntu Desktop components & VNC tools
RUN apt-get update && apt-get install -y \
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

# 2. Set environment variables for Ubuntu GNOME UI
ENV XDG_CURRENT_DESKTOP=ubuntu:GNOME
ENV GNOME_SHELL_SESSION_MODE=ubuntu
ENV XDG_DATA_DIRS=/usr/share/ubuntu:/usr/local/share/:/usr/share/

EXPOSE 5901
EXPOSE 6080

# 3. Startup script with D-Bus wrapper for GNOME
CMD bash -c "\
  mkdir -p ~/.vnc && \
  echo '#!/bin/bash\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexport XDG_CURRENT_DESKTOP=ubuntu:GNOME\nexport GNOME_SHELL_SESSION_MODE=ubuntu\nexport XDG_DATA_DIRS=/usr/share/ubuntu:/usr/local/share/:/usr/share/\nexec dbus-run-session gnome-session' > ~/.vnc/xstartup && \
  chmod +x ~/.vnc/xstartup && \
  vncserver -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE :1 && \
  websockify -D --web=/usr/share/novnc/ 6080 localhost:5901 && \
  tail -f /dev/null"
