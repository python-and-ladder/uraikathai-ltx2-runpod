# Instructions

## Building and Using the Image

### Automatic Build with GitHub Actions

The image builds automatically when you:

- Push to main branch → creates `latest` tag
- Create a tag like `v1.0.0` → creates version tags
- Open a PR → creates test build

### Manual Local Build

```bash
# Build the image
docker build -t ltx2-comfyui:latest .

# Tag for GHCR
docker tag ltx2-comfyui:latest ghcr.io/your-username/your-repo:latest

# Login to GHCR (one time)
echo $GITHUB_TOKEN | docker login ghcr.io -u your-username --password-stdin

# Push to GHCR
docker push ghcr.io/your-username/your-repo:latest
```

### Running on RunPod

**Using RunPod Template:**

1. In RunPod:
    - Go to Templates
    - Create new template
    - Use your GHCR image: [`ghcr.io/your-username/your-repo:latest`](http://ghcr.io/your-username/your-repo:latest)
    - Set exposed ports: 8188, 8888, 8080
    - Deploy

**Local Testing:**

```bash
docker run -it --gpus all \
  -p 8188:8188 \
  -p 8888:8888 \
  -p 8080:8080 \
  -v $(pwd)/models:/workspace/ComfyUI/models \
  -v $(pwd)/output:/workspace/ComfyUI/output \
  -v $(pwd)/notebooks:/workspace/notebooks \
  ghcr.io/your-username/your-repo:latest
```

## Accessing Services

Once running in RunPod:

- **ComfyUI**: [`https://your-pod-id-8188.proxy.runpod.net`](https://your-pod-id-8188.proxy.runpod.net)
- **Jupyter Notebook**: [`https://your-pod-id-8888.proxy.runpod.net`](https://your-pod-id-8888.proxy.runpod.net)
- **VSCode**: [`https://your-pod-id-8080.proxy.runpod.net`](https://your-pod-id-8080.proxy.runpod.net)

## Installing LTX 2 Models

After the container starts, download the LTX Video model:

```bash
# Inside the container or via Jupyter notebook
cd /workspace/ComfyUI/models/checkpoints
wget https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltx-video-2b-v0.9.safetensors
```

Or use the ComfyUI Manager to install LTX Video custom nodes.

## Sample Jupyter Notebook Cell

```python
# Test LTX 2 pipeline in Jupyter
import torch
from diffusers import LTXPipeline

pipe = LTXPipeline.from_pretrained(
    "Lightricks/LTX-Video",
    torch_dtype=torch.bfloat16
)
pipe.to("cuda")

prompt = "A cat walking on a beach at sunset"
video = pipe(prompt, num_frames=121, num_inference_steps=50).frames[0]

print(f"Generated video with {len(video)} frames")
```

## Advantages of GitHub Container Registry + Actions

- **Free for public repositories**: No rate limits or storage costs
- **Automated builds**: CI/CD pipeline builds on every commit
- **Version control**: Automatic tagging based on git tags
- **Security scanning**: GitHub automatically scans for vulnerabilities
- **Tight integration**: Works seamlessly with GitHub repositories
- **Build cache**: GitHub Actions cache speeds up subsequent builds
- **No separate account**: Uses your existing GitHub account

## Workflow Triggers

The GitHub Action triggers on:

- **Push to main**: Creates `latest` tag
- **Git tags**: Creates version tags (e.g., `v1.0.0` → `1.0.0`, `1.0`, `1`)
- **Pull requests**: Test builds without publishing
- **Manual**: Trigger via "Actions" tab → "Run workflow"

## Notes

- The container runs all three services simultaneously
- All services are accessible without authentication (suitable for RunPod's secure environment)
- Models and outputs are stored in `/workspace` for persistence
- GPU access is required for LTX 2 inference
- Consider using RunPod's network volumes to persist models between pod restarts
- GHCR images are pulled faster than Docker Hub in many regions
- GitHub Actions provides 2,000 free minutes per month for private repos (unlimited for public repos)