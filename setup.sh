#!/bin/bash

# Create the conda environment the server uses
conda env create -f /tmp/server_env.yml && \
  conda clean -afy

# Install specific versions of torch, torchaudio, and torchvision
conda run -n myenv pip install torch==2.1.0+cu121 torchaudio==2.1.0+cu121 torchvision==0.16.0+cu121 -f https://download.pytorch.org/whl/torch_stable.html
