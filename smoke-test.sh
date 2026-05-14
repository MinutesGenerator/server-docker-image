#!/usr/bin/env bash
set -euo pipefail

ffmpeg -version | head -1
soffice --version
cloudflared --version
rustc --version
cargo --version

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

is_qemu_emulated() {
  ps -p 1 -o args= | grep -q "qemu-"
}

cat > "${tmp_dir}/smoke.html" <<'EOF'
<!doctype html>
<html>
<head><meta charset="utf-8"></head>
<body><h1>LibreOffice smoke test</h1><p>PDF export is available.</p></body>
</html>
EOF

if is_qemu_emulated; then
  echo "Skipping LibreOffice conversion smoke test under QEMU emulation."
else
  mkdir -p "${tmp_dir}/out" "${tmp_dir}/profile"
  soffice \
    --headless \
    --nologo \
    --nofirststartwizard \
    --nolockcheck \
    --nodefault \
    --norestore \
    "-env:UserInstallation=file://${tmp_dir}/profile" \
    --convert-to pdf \
    --outdir "${tmp_dir}/out" \
    "${tmp_dir}/smoke.html" >/dev/null 2>&1

  test -s "${tmp_dir}/out/smoke.pdf"
fi

conda run -n mgenv python -c '
import dotenv
import pyinstrument
import silero_vad
import soundfile
import speechbrain
import torch
import torchaudio
import whisper

print("python deps ok")
print(f"torch={torch.__version__}")
print(f"cuda_available={torch.cuda.is_available()}")
'
