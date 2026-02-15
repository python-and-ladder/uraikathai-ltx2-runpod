#!/bin/bash

# Start ComfyUI in the background
echo "Starting ComfyUI..."
cd /workspace/ComfyUI
python3 main.py --listen 0.0.0.0 --port 8188 &

# Start Jupyter Notebook in the background
echo "Starting Jupyter Notebook..."
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root \
  --NotebookApp.token='' --NotebookApp.password='' \
  --notebook-dir=/workspace/notebooks &

# Start code-server (VSCode)
echo "Starting VSCode (code-server)..."
code-server --bind-addr 0.0.0.0:8080 \
  --user-data-dir /workspace/vscode-data \
  --auth none \
  /workspace &

# Keep container alive until all background services exit
wait