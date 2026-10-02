autoload -Uz add-zsh-hook

_project_venv_find() {
  [[ -n ${PROJECT_ROOT:-} ]] || return
  local root="${PROJECT_ROOT:A}" dir="${PWD:A}" explicit
  [[ "$dir" == "$root" || "$dir" == "$root"/* ]] || return
  if [[ -n ${PROJECT_VENV_COMPONENT:-} ]]; then
    explicit="$root/$PROJECT_VENV_COMPONENT/.venv"
    [[ -f "$explicit/bin/activate" ]] && print -r -- "$explicit" && return
  fi
  while [[ "$dir" == "$root" || "$dir" == "$root"/* ]]; do
    [[ -f "$dir/.venv/bin/activate" ]] && print -r -- "$dir/.venv" && return
    [[ "$dir" == "$root" ]] && break
    dir="${dir:h}"
  done
}

_project_venv_sync() {
  local target="${(@f)$(_project_venv_find)}"
  if [[ -n ${_PROJECT_VENV_ACTIVE:-} && "${VIRTUAL_ENV:-}" != "$target" ]]; then
    deactivate 2>/dev/null || true
    unset _PROJECT_VENV_ACTIVE
  fi
  if [[ -n "$target" && "${VIRTUAL_ENV:-}" != "$target" ]]; then
    source "$target/bin/activate"
    export _PROJECT_VENV_ACTIVE="$target"
  fi
}

add-zsh-hook chpwd _project_venv_sync
add-zsh-hook precmd _project_venv_sync
_project_venv_sync
