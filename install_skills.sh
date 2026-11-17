#!/bin/bash
#
# Install agent skills non-interactively.
# Scope: global (-g) · link mode: symlink (default) · agents: claude-code, github-copilot
# Skills already installed are updated, not reinstalled.
#
set -euo pipefail

# The CLI expects one flag per value; comma-separated lists are rejected.
readonly AGENT_FLAGS=(--agent claude-code --agent github-copilot)

# "<repo-url> <skill> [<skill>...]"
readonly PACKAGES=(
  "https://github.com/mattpocock/skills grill-me grill-with-docs grilling domain-modeling"
  "https://github.com/humanlayer/skills show-me"
  "https://github.com/ayghri/i-have-adhd i-have-adhd"
  "https://github.com/danyuchn/asd-ste100-skill asd-ste100"
)

log() { printf '[install-skills] %s\n' "$*"; }
die() { printf '[install-skills] FAIL: %s\n' "$*" >&2; exit 1; }

# Names of globally installed skills, one per line.
installed_skills() {
  NO_COLOR=1 npx --yes skills list --global | awk '$2 ~ /^~?\// { print $1 }'
}

install_package() {
  local repo="$1"; shift
  local installed="$1"; shift
  local add_skills=() update_skills=() skill

  for skill in "$@"; do
    if grep -qxF -- "$skill" <<<"$installed"; then
      update_skills+=("$skill")
    else
      add_skills+=("$skill")
    fi
  done

  if (( ${#add_skills[@]} )); then
    local skill_flags=()
    for skill in "${add_skills[@]}"; do
      skill_flags+=(--skill "$skill")
    done
    log "installing [${add_skills[*]}] from ${repo} ..."
    npx --yes skills add "$repo" "${skill_flags[@]}" "${AGENT_FLAGS[@]}" --global --yes \
      || die "install ${repo} [${add_skills[*]}]"
    log "OK installed [${add_skills[*]}]"
  fi

  if (( ${#update_skills[@]} )); then
    log "updating [${update_skills[*]}] ..."
    npx --yes skills update "${update_skills[@]}" --global --yes \
      || die "update [${update_skills[*]}]"
    log "OK updated [${update_skills[*]}]"
  fi
}

main() {
  command -v npx >/dev/null 2>&1 || die "npx not found in PATH"

  local installed entry
  installed="$(installed_skills)"
  for entry in "${PACKAGES[@]}"; do
    # Word splitting is intended: "<repo-url> <skill>...".
    # shellcheck disable=SC2086
    install_package ${entry%% *} "$installed" ${entry#* }
  done

  log "all ${#PACKAGES[@]} packages processed (global, symlink, agents: claude-code, github-copilot)"
}

main "$@"
