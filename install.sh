#!/usr/bin/env bash
# Install the Jupyter Python Tutor: an AI chat panel inside JupyterLab,
# configured to teach rather than to do the work for you.
#
#   ./install.sh [notebook-folder]      (defaults to the current directory)
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$PWD}"

bold=$'\033[1m'; red=$'\033[31m'; green=$'\033[32m'; yellow=$'\033[33m'; off=$'\033[0m'
ok()   { echo "  ${green}✓${off} $*"; }
warn() { echo "  ${yellow}!${off} $*"; }
die()  { echo "  ${red}✗${off} $*"; echo; exit 1; }

echo
echo "${bold}Jupyter Python Tutor${off}"
echo

# ---------------------------------------------------------------- prerequisites
echo "${bold}Checking what you already have${off}"

command -v jupyter >/dev/null || die "No Jupyter found.
    Install Anaconda (https://www.anaconda.com/download) or run:
      pip install jupyterlab"
ok "Jupyter — $(jupyter --version 2>/dev/null | awk '/jupyterlab/{print "JupyterLab "$3}' | head -1)"

# Install into the same Python that owns `jupyter`, not whatever `python3`
# happens to point at — otherwise the extension lands in the wrong environment
# and JupyterLab never sees it.
PY="$(dirname "$(command -v jupyter)")/python"
[ -x "$PY" ] || PY="$(command -v python3)"
[ -x "$PY" ] || die "Could not find the Python that runs your Jupyter."
ok "Python — $("$PY" --version 2>&1) at $PY"

command -v node >/dev/null || die "No Node.js found. Install it from https://nodejs.org
    (needed for the adapter that connects Claude to JupyterLab)"
ok "Node — $(node -v)"

command -v claude >/dev/null || die "Claude Code is not installed.
    Install it: https://claude.com/claude-code
    A Claude subscription is required — this is the part no script can do for you."
ok "Claude Code — $(claude --version 2>/dev/null | head -1)"

[ -d "$TARGET" ] || die "Folder does not exist: $TARGET"
ok "Notebook folder — $TARGET"

# -------------------------------------------------------------------- installing
echo
echo "${bold}Installing${off}"

echo "  · Jupyter AI (the chat panel)…"
# Anaconda and standard venvs have pip; uv-created venvs do not ship it. Fall
# back to `uv pip` rather than failing on an environment that is perfectly fine.
if "$PY" -m pip --version >/dev/null 2>&1; then
  INSTALL_CMD=("$PY" -m pip install --quiet --upgrade "jupyter-ai")
elif command -v uv >/dev/null; then
  warn "no pip in that environment — using uv instead"
  INSTALL_CMD=(uv pip install --quiet --python "$PY" "jupyter-ai")
else
  die "That Python has no pip, and uv is not installed either.
    Install pip:  $PY -m ensurepip --upgrade
    or install uv: https://docs.astral.sh/uv/"
fi

"${INSTALL_CMD[@]}" \
  || die "Installing jupyter-ai failed. Run this yourself to see why:
      ${INSTALL_CMD[*]}"
ok "Jupyter AI $("$PY" -c 'import importlib.metadata as m; print(m.version("jupyter-ai"))' 2>/dev/null)"

echo "  · Claude ACP adapter (lets JupyterLab drive Claude)…"
npm install -g @agentclientprotocol/claude-agent-acp >/dev/null 2>&1 \
  || die "npm install failed. If it is a permissions error, try:
      sudo npm install -g @agentclientprotocol/claude-agent-acp"
command -v claude-agent-acp >/dev/null \
  || die "Adapter installed but 'claude-agent-acp' is not on your PATH.
    Check where npm puts global binaries:  npm prefix -g"
ok "ACP adapter — $(command -v claude-agent-acp)"

# --------------------------------------------------------------- tutor behaviour
echo "  · Tutor instructions…"
DEST="$TARGET/CLAUDE.md"
if [ -f "$DEST" ]; then
  BACKUP="$DEST.backup.$(date +%Y%m%d-%H%M%S)"
  cp "$DEST" "$BACKUP"
  warn "You already had a CLAUDE.md — saved a copy as $(basename "$BACKUP")"
fi
cp "$HERE/tutor/CLAUDE.md" "$DEST"
ok "Tutor rules — $DEST"

# ---------------------------------------------------------------------- finished
cat <<EOF

${bold}Done.${off} Two things left, both on you:

  1. Make sure you are logged in to Claude:   ${bold}claude /login${off}

  2. Start JupyterLab from this folder:       ${bold}cd "$TARGET" && jupyter lab${off}

     It must be ${bold}jupyter lab${off}, not ${bold}jupyter notebook${off} — the chat panel only
     appears in the full JupyterLab interface. If you already have a server
     running, you do not need to restart it: just change ${bold}/tree${off} to ${bold}/lab${off} in
     the browser address bar.

Then look for the ${bold}chat icon in the left sidebar${off}, click ${bold}+${off} to start a chat, and
pick ${bold}Claude${off}. Ask it to explain something in your notebook.

EOF
