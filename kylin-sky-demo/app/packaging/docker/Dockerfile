FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG UBUNTU_PORTS_MIRROR=http://ports.ubuntu.com/ubuntu-ports

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    sed -i "s|http://ports.ubuntu.com/ubuntu-ports|${UBUNTU_PORTS_MIRROR}|g" /etc/apt/sources.list \
    && apt-get -o Acquire::Retries=5 -o Acquire::Queue-Mode=access update \
    && apt-get -o Acquire::Retries=5 -o Acquire::Queue-Mode=access install --no-install-recommends --yes \
        build-essential \
        ca-certificates \
        cmake \
        ninja-build \
        libqt5svg5-dev \
        qml-module-qtquick2 \
        qml-module-qtquick-controls2 \
        qml-module-qtquick-window2 \
        qml-module-qtwebengine \
        qtbase5-dev \
        qtdeclarative5-dev \
        qtquickcontrols2-5-dev \
        qtwebengine5-dev

WORKDIR /workspace
