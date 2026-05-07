FROM debian:bookworm-slim AS builder

RUN apt-get update && \
    apt-get install -y curl git python3 python3-pip python3-venv && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* && \
    mkdir -p /Whisper-WebUI

WORKDIR /Whisper-WebUI

COPY requirements.txt .
COPY scripts/patch_whisper_dep.py /tmp/

RUN python3 -m venv venv && \
    . venv/bin/activate && \
    git clone --depth 1 https://github.com/jhj0517/jhj0517-whisper.git /tmp/jhj0517-whisper && \
    python3 /tmp/patch_whisper_dep.py /tmp/jhj0517-whisper && \
    pip install /tmp/jhj0517-whisper && \
    grep -v 'jhj0517-whisper' requirements.txt > /tmp/req.txt && \
    pip install -U -r /tmp/req.txt


FROM debian:bookworm-slim AS runtime

RUN apt-get update && \
    apt-get install -y curl ffmpeg python3 && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR /Whisper-WebUI

COPY . .
COPY --from=builder /Whisper-WebUI/venv /Whisper-WebUI/venv

VOLUME [ "/Whisper-WebUI/models" ]
VOLUME [ "/Whisper-WebUI/outputs" ]

ENV PATH="/Whisper-WebUI/venv/bin:$PATH"
ENV LD_LIBRARY_PATH=/Whisper-WebUI/venv/lib64/python3.11/site-packages/nvidia/cublas/lib:/Whisper-WebUI/venv/lib64/python3.11/site-packages/nvidia/cudnn/lib

ENTRYPOINT [ "python", "app.py" ]
