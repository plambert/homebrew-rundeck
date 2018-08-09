#!/usr/bin/env bash

# make a bottle for a formula

while [[ $# -gt 0 ]]; do
  opt="$1"; shift
  case "$opt" in
    -- ) formula="$1"; set -- ;;
    --force ) force=1 ;;
    --no-force ) unset force ;;
    * ) 
      [[ -n "$formula" ]] && { echo 1>&2 "$0: ${opt}: unknown option"; exit 1; }
      formula="$(basename -- "$opt" .rb)"
      ;;
  esac
done

# ensure it's not installed

installed_version="$(brew info --json=v1 "$formula" | jq -r '.[0].installed[0].version')" 2>/dev/null

if [[ "$installed_version" != null ]]; then
  if [[ -n "$force" ]]; then
    brew rm "$formula"
  else
    printf 1>&2 '%s: %s: already installed, remove before bottling\n' "$0" "$formula"
    exit 2
  fi
fi

if ! brew install --make-bottle -s "$formula"; then
  rc=$?
  echo 1>&2 "brew install failed: $rc"
  exit "$rc"
fi

brew bottle --merge --write "./${formula}.rb"

