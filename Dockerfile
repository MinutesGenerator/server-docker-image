FROM ghcr.io/minutesgenerator/server-docker-image:latest

# Install required packages
RUN apt-get update && \
  apt-get install -y wget screen rsync vim && \
  rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
  bash /tmp/miniconda.sh -b -p /opt/miniconda && \
  rm /tmp/miniconda.sh

ENV PATH=/opt/miniconda/bin:$PATH

# Download and extract the pyannote speaker diarization data
RUN wget -O - https://minutesgeneratorpublic.s3.amazonaws.com/data-2023-03-25-02.tar.gz | tar xz -C /


COPY server_env.yml /tmp/server_env.yml

# Create the conda environment the server uses
RUN conda env create -f /tmp/server_env.yml && \
  conda clean -afy
