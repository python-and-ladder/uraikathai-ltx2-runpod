# Use NVIDIA CUDA base image with Ubuntu
FROM nvidia/cuda:13.1.1-cudnn-devel-ubuntu24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV SHELL=/bin/bash

# Set working directory
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    wget \
    curl \
    vim \
    nano \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (for VSCode server)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install PyTorch with CUDA support
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI && \
    cd /workspace/ComfyUI && \
    pip install -r requirements.txt

# Install ComfyUI Manager (optional but recommended)
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# Install LTX Video dependencies
RUN pip install diffusers transformers accelerate sentencepiece protobuf

# Install Jupyter Notebook and extensions
RUN pip install jupyter jupyterlab notebook ipywidgets jupyterlab-vim

# Install code-server (VSCode in browser)
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install Python development tools
RUN pip install \
    numpy \
    pandas \
    matplotlib \
    opencv-python \
    pillow \
    scikit-learn \
    scipy \
    tqdm \
    einops \
    safetensors \
    omegaconf

# Create directories for models and outputs
RUN mkdir -p /workspace/ComfyUI/models/checkpoints \
    /workspace/ComfyUI/models/vae \
    /workspace/ComfyUI/models/loras \
    /workspace/ComfyUI/output \
    /workspace/notebooks \
    /workspace/vscode-data

# Copy startup script
COPY start.sh /workspace/start.sh
RUN chmod +x /workspace/start.sh && sed -i 's/\r$//' /workspace/start.sh

# Expose ports
# 8188 - ComfyUI
# 8888 - Jupyter Notebook
# 8080 - VSCode (code-server)
EXPOSE 8188 8888 8080

# Set the startup command (explicit bash so builtins like wait work in exec form)
CMD ["/bin/bash", "/workspace/start.sh"]