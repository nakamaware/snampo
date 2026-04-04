from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess
import sys


def _resolve_bash() -> str:
    if os.name != "nt":
        bash = shutil.which("bash")
        if bash is not None:
            return bash
    else:
        candidates = [
            r"C:\Program Files\Git\bin\bash.exe",
            r"C:\Program Files (x86)\Git\bin\bash.exe",
            shutil.which("bash"),
        ]
        for candidate in candidates:
            if (
                candidate
                and Path(candidate).exists()
                and "system32/bash.exe" not in candidate.lower().replace("\\", "/")
            ):
                return candidate

    raise FileNotFoundError(
        "bash was not found. Install bash and make sure it is available."
    )


def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: run_bash_script.py <script> [args...]", file=sys.stderr)
        return 2

    script_path = Path(sys.argv[1]).resolve()
    if not script_path.exists():
        print(f"Script not found: {script_path}", file=sys.stderr)
        return 2

    bash = _resolve_bash()
    result = subprocess.run([bash, str(script_path), *sys.argv[2:]], check=False)
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
