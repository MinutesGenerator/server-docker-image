FROM ghcr.io/minutesgenerator/server-docker-image-base:latest

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    clang \
    cmake \
    curl \
    ffmpeg \
    fontconfig \
    fonts-dejavu \
    fonts-liberation \
    git \
    gnupg \
    jq \
    libclang-dev \
    libsndfile1 \
    libreoffice-writer \
    nasm \
    openssh-server \
    pkg-config \
    poppler-utils \
    rsync \
    screen \
    vim \
    wget \
    yasm && \
  mkdir -p --mode=0755 /usr/share/keyrings && \
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null && \
  . /etc/os-release && \
  echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/cloudflared.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends cloudflared && \
  rm -rf /var/lib/apt/lists/*

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
  bash /tmp/miniconda.sh -b -p /opt/miniconda && \
  rm /tmp/miniconda.sh

ENV PATH=/root/.cargo/bin:/opt/miniconda/bin:$PATH
ENV PYO3_PYTHON=/opt/miniconda/envs/mgenv/bin/python

RUN conda init bash && \
  conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
  conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
  conda create -n mgenv python=3.11 -y && \
  conda run -n mgenv pip install --no-cache-dir \
    openai-whisper \
    pyinstrument \
    python-dotenv \
    silero-vad \
    soundfile \
    speechbrain \
    torchaudio && \
  conda clean -afy

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain 1.87.0 && \
  rustup component add clippy rustfmt

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY smoke-test.sh /usr/local/bin/smoke-test.sh

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/smoke-test.sh && \
  mkdir -p /var/run/sshd

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    default-jre-headless \
    libreoffice-java-common && \
  rm -rf /var/lib/apt/lists/* && \
  echo "/usr/lib/libreoffice/program" > /etc/ld.so.conf.d/libreoffice.conf && \
  ldconfig

EXPOSE 22 8888

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
