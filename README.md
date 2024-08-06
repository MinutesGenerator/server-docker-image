# server-docker-image

- With runpod, you can use Docker image `ghcr.io/minutesgenerator/server-docker-image:3` (or latest version instead of 3)
- When the server is first spun up, you need to ssh in and run `/usr/local/bin/setup.sh`
- First boot of the server takes a while to install packages
- Need to update server.ts and the lambda, and the server push script to point to the new prod hostname
