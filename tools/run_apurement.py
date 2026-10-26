#!/usr/bin/env python3
"""Lance l'apurement Stata sans intervention, sans chemin propre au poste.

    python tools/run_apurement.py config     --quarter T1_2026   # parentfile.do seul (racine, trimestre, chemins)
    python tools/run_apurement.py check                          # contrôles statiques Python, sans Stata
    python tools/run_apurement.py apurement  --quarter T1_2026   # parentfile.do puis apurement.do
    python tools/run_apurement.py fusion     --quarter T1_2026   # parentfile.do puis Fusion.do

- Exécutable Stata : variable d'environnement STATA_EXE (jamais écrite dans le code).
- Trimestre : --quarter, sinon ENE_QUARTER (lu par program/parentfile.do).
- ENE_BASE_DIR est fixé à la racine de ce dépôt pour le processus Stata.
- Windows : Stata ignore `shell` en mode batch (/e), or l'initialisation copie
  datain/staging vers datain/brute par `shell` (robocopy). Stata est donc lancé en
  mode interactif (/q, fenêtre réduite) sur un do-file enveloppe qui écrit son
  journal, enregistre le code retour dans datatemp/batch/run_<étape>.rc et ferme
  Stata. Linux/macOS : mode batch (-b), où `shell` fonctionne.
- Le journal de l'enveloppe est écrit dans datatemp/batch/ ; le journal de session
  reste dans logs/ (ouvert par parentfile.do). Le script renvoie 1 si le do-file
  s'est arrêté sur une erreur.
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROGRAM = ROOT / "program"
BATCH_DIR = ROOT / "datatemp" / "batch"

STEPS = {
    "config": ["parentfile.do"],
    "apurement": ["parentfile.do", "apurement.do"],
    "fusion": ["parentfile.do", "Fusion.do"],
}
STATIC_CHECKS = (
    "validate_stata_raw_saves.py",
    "validate_stata_excel_exports.py",
    "validate_codification_inputs.py",
)
ERROR_LINE = re.compile(r"^r\(\d+\);\s*$")


WINDOWS = os.name == "nt"


def stata_command(exe: str, do_file: Path) -> list[str]:
    # Windows : /q (interactif, sans écran d'accueil) ; Linux/macOS : -b (batch).
    return [exe, "/q" if WINDOWS else "-b", "do", str(do_file)]


def wrapper_do(step: str, log_file: Path, rc_file: Path) -> str:
    steps = "".join(f'    do "{(PROGRAM / name).as_posix()}"\n' for name in STEPS[step])
    if not WINDOWS:
        return steps
    # Le journal nommé reste ouvert pendant les do-files, qui ouvrent et ferment
    # leur propre journal sans nom.
    return (
        f'log using "{log_file.as_posix()}", text replace name(run_{step})\n'
        "capture noisily {\n"
        f"{steps}"
        "}\n"
        "local rc = _rc\n"
        "capture log close _all\n"
        f'file open fh using "{rc_file.as_posix()}", write replace\n'
        "file write fh \"`rc'\"\n"
        "file close fh\n"
        "exit, clear STATA\n"
    )


def stata_failed(log_file: Path, rc_file: Path) -> bool:
    if WINDOWS:
        if not rc_file.is_file():
            return True
        return rc_file.read_text(encoding="utf-8").strip() != "0"
    if not log_file.is_file():
        return True
    lines = [line for line in log_file.read_text(encoding="utf-8", errors="replace").splitlines() if line.strip()]
    return any(ERROR_LINE.match(line.strip()) for line in lines[-5:])


def run_stata(step: str, quarter: str | None) -> int:
    exe = os.environ.get("STATA_EXE")
    if not exe:
        print("STATA_EXE n'est pas défini : chemin de l'exécutable Stata (ex. StataMP-64.exe).")
        return 2
    if not Path(exe).is_file():
        print(f"STATA_EXE ne désigne pas un fichier : {exe}")
        return 2

    BATCH_DIR.mkdir(parents=True, exist_ok=True)
    do_file = BATCH_DIR / f"run_{step}.do"
    log_file = do_file.with_suffix(".log")
    rc_file = do_file.with_suffix(".rc")
    log_file.unlink(missing_ok=True)
    rc_file.unlink(missing_ok=True)
    do_file.write_text(wrapper_do(step, log_file, rc_file), encoding="utf-8")

    env = dict(os.environ, ENE_BASE_DIR=str(ROOT))
    if quarter:
        env["ENE_QUARTER"] = quarter
    print(f"Stata {step} (trimestre {env.get('ENE_QUARTER', 'T1_2026 par défaut')}) ...")
    kwargs = {}
    if WINDOWS:
        startup = subprocess.STARTUPINFO()
        startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        startup.wShowWindow = 7  # SW_SHOWMINNOACTIVE : réduite, sans prendre le focus
        kwargs["startupinfo"] = startup
    subprocess.call(stata_command(exe, do_file), cwd=BATCH_DIR, env=env, **kwargs)

    if stata_failed(log_file, rc_file):
        print(f"ÉCHEC : voir {log_file}")
        return 1
    print(f"OK : journal {log_file}")
    return 0


def run_checks() -> int:
    status = 0
    for script in STATIC_CHECKS:
        print(f"--- {script}")
        status |= subprocess.call([sys.executable, str(ROOT / "tools" / script)], cwd=ROOT)
    return 1 if status else 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Lanceur Stata de l'apurement ENE-M")
    parser.add_argument("step", choices=(*STEPS, "check"))
    parser.add_argument("--quarter", default=None, help="TX_YYYY (défaut : ENE_QUARTER)")
    args = parser.parse_args()
    if args.step == "check":
        return run_checks()
    return run_stata(args.step, args.quarter)


if __name__ == "__main__":
    sys.exit(main())
