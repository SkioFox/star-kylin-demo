FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        build-essential \
        ca-certificates \
        cmake \
        dpkg-dev \
        file \
        ninja-build \
        libqt5svg5-dev \
        qml-module-qtquick2 \
        qml-module-qtquick-controls2 \
        qml-module-qtquick-window2 \
        qml-module-qtwebengine \
        qtbase5-dev \
        qtdeclarative5-dev \
        qtquickcontrols2-5-dev \
        qtwebengine5-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
