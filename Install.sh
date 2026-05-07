#!/bin/bash

if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python -m venv venv
fi

source venv/bin/activate

python -m pip install -U pip

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
git clone --depth 1 https://github.com/jhj0517/jhj0517-whisper.git /tmp/jhj0517-whisper
python3 "$SCRIPT_DIR/scripts/patch_whisper_dep.py" /tmp/jhj0517-whisper
pip install /tmp/jhj0517-whisper

grep -v 'jhj0517-whisper' requirements.txt > /tmp/req.txt
pip install -r /tmp/req.txt && echo "Requirements installed successfully." || {
    echo ""
    echo "Requirements installation failed. Please remove the venv folder and run the script again."
    deactivate
    exit 1
}

deactivate
