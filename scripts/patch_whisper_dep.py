#!/usr/bin/env python3
"""Patch jhj0517-whisper setup.py to remove pkg_resources dependency.

setup.py imports pkg_resources to parse install_requires, but pkg_resources
is not available in modern pip build environments. This patches it to use
a simple line-reader instead.
"""
import re
import sys
from pathlib import Path

target = Path(sys.argv[1]) / "setup.py"
text = target.read_text()
text = text.replace("import pkg_resources\n", "")
text = re.sub(
    r"install_requires=\[.*?pkg_resources\.parse_requirements.*?\]",
    (
        'install_requires=[\n'
        '        l.strip()\n'
        '        for l in Path(__file__).with_name("requirements.txt").read_text().splitlines()\n'
        '        if l.strip() and not l.startswith("#") and not l.startswith("-")\n'
        '    ]'
    ),
    text,
    flags=re.DOTALL,
)
target.write_text(text)
print(f"Patched {target}")
