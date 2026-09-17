#!/bin/bash
#
# Install agent skills non-interactively.
# Scope: global (-g) · link mode: symlink (default) · agents: claude-code, github-copilot
#
set -euo pipefail

# The CLI expects one flag per value; comma-separated lists are rejected.
readonly AGENT_FLAGS=(--agent claude-code --agent github-copilot)

# "<repo-url> <skill> [<skill>...]"
readonly PACKAGES=(
  "https://github.com/mattpocock/skills code-review grill-me grill-with-docs"
  "https://github.com/duolahypercho/andrej-karpathy-skills andrej-karpathy-skill"
  "https://github.com/juliusbrussee/caveman caveman-commit caveman"
  "https://github.com/humanlayer/skills show-me"
  "https://github.com/ayghri/i-have-adhd i-have-adhd"
  "https://github.com/brianlovin/agent-config simplify"
)

log() { printf '[install-skills] %s\n' "$*"; }
die() { printf '[install-skills] FAIL: %s\n' "$*" >&2; exit 1; }

install_package() {
  local repo="$1"; shift
  local skill_flags=() skill

  for skill in "$@"; do
    skill_flags+=(--skill "$skill")
  done

  log "installing [$*] from ${repo} ..."
  if ! npx --yes skills add "$repo" "${skill_flags[@]}" "${AGENT_FLAGS[@]}" --global --yes; then
    die "${repo} [$*]"
  fi
  log "OK [$*]"
}

main() {
  command -v npx >/dev/null 2>&1 || die "npx not found in PATH"

  local entry
  for entry in "${PACKAGES[@]}"; do
    install_package ${entry}
  done

  log "all ${#PACKAGES[@]} packages installed (global, symlink, agents: claude-code, github-copilot)"
}

main "$@"
