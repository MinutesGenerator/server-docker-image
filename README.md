# server-docker-image

Runpod server image for the MinutesGenerator Rust backend.

The image preinstalls the slow, one-time server dependencies that used to be handled by `platform/server/setup.sh`:

- Miniconda at `/opt/miniconda`
- Conda environment `mgenv` with Python 3.11 and the server speech dependencies
- Rust `1.87.0`
- FFmpeg, LibreOffice, Poppler, Cloudflared, SSH, and Rust build dependencies

Use Docker image `ghcr.io/minutesgenerator/server-docker-image:5` in Runpod.

## Build

```bash
docker buildx build --platform linux/amd64 --load -t ghcr.io/minutesgenerator/server-docker-image:5 .
docker run --rm --platform linux/amd64 --entrypoint /usr/local/bin/smoke-test.sh ghcr.io/minutesgenerator/server-docker-image:5
```

## Push

```bash
docker buildx build \
  --platform linux/amd64 \
  -t ghcr.io/minutesgenerator/server-docker-image:5 \
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
