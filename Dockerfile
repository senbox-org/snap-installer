FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USER=snap
ARG USER_HOME_DIR="/home/snap"
ARG DOCKER_GID=999

COPY target/esa-snap_all_unix_10_0_0-SNAPSHOT.sh ${USER_HOME_DIR}
COPY target/esa-snap_all_macos_10_0_0-SNAPSHOT ${USER_HOME_DIR}
COPY target/esa-snap_all_windows-x64_10_0_0-SNAPSHOT ${USER_HOME_DIR}

RUN echo "Installers have been copied"

RUN sh /usr/local/bin/mvn-entrypoint.sh

# Default target platform is 'unix'
# ARG TARGET_PLATFORM=unix

# # 'unix' stage
# FROM ubuntu:22.04 as unix
# ARG DEBIAN_FRONTEND=noninteractive
# ARG USER=snap
# ARG USER_HOME_DIR="/home/snap"
# COPY --from=base /build/snap-installer/target/esa-snap_all_unix.sh USER_HOME_DIR/
# CMD [ "/home/snap/esa-snap_all_unix.sh" ]

# # 'darwin' stage
# FROM sickcodes/docker-osx:ventura as darwin
# ARG USER=snap
# ARG USER_HOME_DIR="/home/snap"
# COPY --from=base /build/snap-installer/target/esa-snap_all_macos.dmg USER_HOME_DIR/
# CMD [ "/home/snap/esa-snap_all_macos.dmg" ]

# # 'windows' stage
# FROM mcr.microsoft.com/windows/servercore:ltsc2022 as windows
# ARG USER=snap
# ARG USER_HOME_DIR="C:\Users\snap\Documents"
# COPY --from=base /build/snap-installer/target/esa-snap_all_windows-x64.exe USER_HOME_DIR/
# CMD [ "C:\Users\snap\Documents\esa-snap_all_windows-x64.exe" ]

# FROM package-${TARGET_PLATFORM} AS executable