FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Set environment variables for the Ubuntu GNOME desktop session
ENV XDG_CURRENT_DESKTOP=ubuntu:GNOME
ENV GNOME_SHELL_SESSION_MODE=ubuntu
ENV XDG_DATA_DIRS=/usr/share/ubuntu:/usr/local/share/:/usr/share/
ENV XDG_SESSION_TYPE=x11

# 2. Install Ubuntu Desktop Minimal, GNOME Session, TigerVNC, and noVNC
RUN apt-get update && apt-get install -y --no-install-recommends \
    ubuntu-desktop-minimal \
    gnome-terminal \
    dbus-x11 \
    x11-xserver-utils \
    tigervnc-standalone-server \
    novnc \
    websockify \
    sudo \
    curl \
    wget \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# 3. Create the .vnc/xstartup script to launch GNOME via D-Bus
RUN mkdir -p /root/.vnc && \
    echo '#!/bin/bash\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
export XDG_CURRENT_DESKTOP=ubuntu:GNOME\n\
export GNOME_SHELL_SESSION_MODE=ubuntu\n\
export XDG_DATA_DIRS=/usr/share/ubuntu:/usr/local/share/:/usr/share/\n\
export XDG_SESSION_TYPE=x11\n\
exec dbus-run-session -- gnome-session --session=ubuntu' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# 4. Expose VNC port (5901) and noVNC Web UI port (6080)
EXPOSE 5901
EXPOSE 6080

# 5. Start TigerVNC server and the websockify proxy on boot
CMD ["bash", "-c", "vncserver -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE :1 && websockify -D --web=/usr/share/novnc/ 6080 localhost:5901 && tail -f /dev/null"]
