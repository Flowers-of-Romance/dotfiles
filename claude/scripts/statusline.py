#!/usr/bin/env python3
"""Pattern 3: Ring meter - pie-like circle segments"""
import json, os, subprocess, sys
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

data = json.load(sys.stdin)

R = '\033[0m'
DIM = '\033[2m'
BOLD = '\033[1m'
CYAN = '\033[38;2;100;200;230m'
PURPLE = '\033[38;2;200;130;230m'

RINGS = ['○', '◔', '◑', '◕', '●']

def gradient(pct):
    if pct < 50:
        r = int(pct * 5.1)
        return f'\033[38;2;{r};200;80m'
    else:
        g = int(200 - (pct - 50) * 4)
        return f'\033[38;2;255;{max(g, 0)};60m'

def ring(pct):
    idx = min(int(pct / 25), 4)
    return RINGS[idx]

def fmt(label, pct, label_style=BOLD):
    p = round(pct)
    return f'{label_style}{label}{R} {gradient(pct)}{ring(pct)} {p}%{R}'

model = data.get('model', {}).get('display_name', 'Claude')
parts = [f'{BOLD}{model}{R}']

ctx = data.get('context_window', {}).get('used_percentage')
if ctx is not None:
    parts.append(fmt('ctx', ctx))

five = data.get('rate_limits', {}).get('five_hour', {}).get('used_percentage')
if five is not None:
    parts.append(fmt('5h', five))

week = data.get('rate_limits', {}).get('seven_day', {}).get('used_percentage')
if week is not None:
    parts.append(fmt('7d', week))

cwd = (data.get('workspace', {}).get('current_dir')
       or data.get('cwd')
       or os.getcwd())
home = os.path.expanduser('~')
if cwd.startswith(home):
    cwd_display = '~' + cwd[len(home):]
else:
    cwd_display = cwd
parts.append(f'{CYAN}📁 {cwd_display}{R}')

try:
    branch = subprocess.run(
        ['git', '-C', cwd, 'branch', '--show-current'],
        capture_output=True, text=True, timeout=1
    ).stdout.strip()
    if branch:
        parts.append(f'{PURPLE}🌿 {branch}{R}')
except Exception:
    pass

print('  '.join(parts), end='')
