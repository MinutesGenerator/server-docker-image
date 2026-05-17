# server-docker-image

Runpod server image for the MinutesGenerator Rust backend.

The image preinstalls the slow, one-time server dependencies that used to be handled by `platform/server/setup.sh`:

- Miniconda at `/opt/miniconda`
- Conda environment `mgenv` with Python 3.11 and the server speech dependencies
- PyTorch/Torchaudio `2.11.0+cu126` for Runpod drivers that support CUDA 12.6/12.7 but not CUDA 13
- Rust `1.87.0`
- FFmpeg, LibreOffice, Poppler, Cloudflared, SSH, and Rust build dependencies
- `/usr/local/bin` links for Rust and Conda tools so non-interactive SSH deploy commands can find them

Use Docker image `ghcr.io/minutesgenerator/server-docker-image:6` in Runpod.

## Build

```bash
docker buildx build --platform linux/amd64 --load -t ghcr.io/minutesgenerator/server-docker-image:6 .
docker run --rm --platform linux/amd64 --entrypoint /usr/local/bin/smoke-test.sh ghcr.io/minutesgenerator/server-docker-image:6
```

## Push

```bash
docker buildx build \
  --platform linux/amd64 \
  -t ghcr.io/minutesgenerator/server-docker-image:6 \
  -t ghcr.io/minutesgenerator/server-docker-image:latest \
  --push .
```

## Provisioning

Create a Runpod instance using the image and set `PUBLIC_KEY` so the container entrypoint can populate `/root/.ssh/authorized_keys` and start sshd.

Then deploy from the `minutes-generator` repo:

```bash
npm run deploy:server -- --pod <pod-id> --restart
```

You should not need to SSH in and run `platform/server/setup.sh` for a fresh pod built from this image.
