#!/bin/bash

# Create the conda environment the server uses
conda env create -f /tmp/server_env.yml && \
  conda clean -afy

# Activate the conda environment
source /opt/miniconda/etc/profile.d/conda.sh
conda activate myenv

# Install specific versions of torch, torchaudio, and torchvision
pip install torch==2.1.0+cu121 torchaudio==2.1.0+cu121 torchvision==0.16.0+cu121 -f https://download.pytorch.org/whl/torch_stable.html

# Install nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# Load nvm and install Node.js version 20
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install 20

# Clean up
rm -rf /tmp/*
