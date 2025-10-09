# ---------------------------------------------
#  Vela Builder
# ---------------------------------------------
FROM registry.cn-hangzhou.aliyuncs.com/dockerhub_mirror/ubuntu:22.04

LABEL maintainer="xinbingnan <xinbingnan@xiaomi.com>" \
      description="Vela Builder"

# 1. Source and Basic env
RUN sed -i'.bak' 's,/[a-z]*.ubuntu.com,/mirrors.tuna.tsinghua.edu.cn,' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        software-properties-common \
        tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" >/etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

# 2. Requirement Tools & Python runtimes
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl wget sudo vim xxd jq bc ftp openssh-server \
        git pkgconf ninja-build cmake cmake-format \
        python3 python3-pip python-is-python3 \
        nodejs npm unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Toolchains
## x64
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        gcc-9 g++-9 g++-9-multilib \
        autoconf automake bison flex gperf genromfs dfu-util \
        nasm yasm \
        zlib1g-dev kconfig-frontends \ 
        libjpeg-turbo8 libncurses5 libx11-dev libxext-dev \
        libpulse-dev libasound2-dev libasound2-plugins \
        libusb-1.0-0-dev \
        libv4l-dev libuv1-dev \
        libmp3lame-dev \
        libpng-dev libjpeg-dev libfreetype-dev libsdl2-dev \
        libwayland-dev libxkbcommon-dev \
        libavformat-dev libavcodec-dev libswscale-dev libavutil-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

## i386
RUN dpkg --add-architecture i386 && apt-get update && \
    apt-get install -y --no-install-recommends \
        libc6-dev-i386 \
        lib32ncurses5-dev \
        libx11-dev:i386 libxext-dev:i386 \
        libpulse-dev:i386 libasound2-dev:i386 libasound2-plugins:i386 \
        libusb-1.0-0-dev:i386 libmad0-dev:i386 \
        libv4l-dev:i386 libuv1-dev \
        libmp3lame-dev:i386 \
        libpng-dev:i386 libjpeg-dev:i386 libfreetype-dev:i386 libsdl2-dev:i386 \
        libwayland-dev:i386 libxkbcommon-dev:i386 \
        libavformat-dev:i386 libavcodec-dev:i386 libswscale-dev:i386 libavutil-dev:i386 \
        libunwind-dev:i386 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 4. Python QA / Dev and tuna source
RUN pip3 install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple -U \
        Pillow pytest==6.2.4 pytest-repeat==0.9.1 pytest-json==0.4.0 \
        pexpect matplotlib numpy asyncio pyserial html-table esptool \
        jinja2 galaxy-fds-sdk \
        pypng lz4 kconfiglib

# 5. repo
RUN curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo -o /usr/bin/repo && \
    sed -i 's|https://gerrit.googlesource.com/git-repo|https://mirrors.ustc.edu.cn/aosp/git-repo|g' /usr/bin/repo && \
    chmod +x /usr/bin/repo

# 6. git
RUN git config --global core.compression -1 && \
    git config --global color.ui auto

# 7. protobuf
RUN cd /tmp && \
    wget -q https://github.com/protocolbuffers/protobuf/releases/download/v3.14.0/protobuf-all-3.14.0.zip && \
    unzip -q protobuf-all-3.14.0.zip && cd protobuf-3.14.0 && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && make install && ldconfig && \
    cd / && rm -rf /tmp/protobuf-*

# 8. JDK && gcc-13
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-11-jdk && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc-13 g++-13 g++-13-multilib cmake && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 12. Utils
RUN apt-get update && apt-get install -y --no-install-recommends \
        qemu-system-arm qemu-efi-aarch64 qemu-utils \
        unionfs-fuse net-tools \
        mtools protobuf-c-compiler protobuf-compiler \
        libprotobuf-dev libdivsufsort-dev \
        libc++-dev libc++abi-dev \
        ruby-full gcovr \
        libinput-dev libxkbcommon-dev libdrm-dev \
        wayland-protocols libwayland-dev libwayland-bin && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# fix libunwind-dev installation problem
RUN apt-get update && apt-get install -y --no-install-recommends \
        libunwind-dev libunwind-dev:i386 && \
    apt-get clean && rm -rf /var/lib/lists/*

# 13. env
ENV REPO_URL="https://mirrors.tuna.tsinghua.edu.cn/git/git-repo"
