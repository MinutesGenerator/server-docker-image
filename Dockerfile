FROM ghcr.io/minutesgenerator/server-docker-image-base:latest

# Install required packages
RUN apt-get update && \
    apt-get install -y wget screen rsync vim openssh-server curl && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/miniconda && \
    rm /tmp/miniconda.sh

ENV PATH=/opt/miniconda/bin:$PATH

# Initialize conda
RUN /opt/miniconda/bin/conda init bash

# Download and extract the pyannote speaker diarization data
RUN wget -O - https://minutesgeneratorpublic.s3.amazonaws.com/data-2023-03-25-02.tar.gz | tar xz -C /

# Copy the environment YAML file
COPY server_env.yml /tmp/server_env.yml

# Copy the setup script into the image
COPY setup.sh /usr/local/bin/setup.sh

# Make the setup script executable and run it
RUN chmod +x /usr/local/bin/setup.sh && \
    /usr/local/bin/setup.sh

# Create directory for keyrings
RUN mkdir -p --mode=0755 /usr/share/keyrings

# Add Cloudflare's GPG key
RUN curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add Cloudflare's apt repository
RUN echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared focal main' | tee /etc/apt/sources.list.d/cloudflared.list

# Update package lists and install cloudflared
RUN apt-get update && \
    apt-get install -y cloudflared && \
    rm -rf /var/lib/apt/lists/*

# Copy the startup script into the image
COPY startup.sh /usr/local/bin/startup.sh

# Make the startup script executable
RUN chmod +x /usr/local/bin/startup.sh

# Set the entrypoint to the startup script
CMD ["/usr/local/bin/startup.sh"]
