#!/bin/bash
# Update all @github pins in a box repo to the latest tags of each repo.
# Usage: update-pins.sh <repo-dir>
set -u
DIR="$1"
cd "$DIR" || exit 1

# Extract unique repos
REPOS=$(grep -rhoE '@github.com/opencharly/[a-z0-9-]+' --include='charly.yml' . 2>/dev/null | sort -u)

UPDATED=0
for repo in $REPOS; do
  short="${repo#@github.com/}"
  # Get the latest tag (non-annotated refs only)
  latest=$(git ls-remote --tags "https://github.com/$short" 2>/dev/null | grep -v '\^{}' | awk '{print $2}' | sed 's|refs/tags/||' | sort -V | tail -1)
  if [ -z "$latest" ]; then
    echo "SKIP $short (no tags)"
    continue
  fi
  # Replace all pins of this repo with the latest tag
  count=$(grep -rl "@github.com/$short:v" --include='charly.yml' . 2>/dev/null | wc -l)
  if [ "$count" -gt 0 ]; then
    grep -rl "@github.com/$short:v" --include='charly.yml' . 2>/dev/null | while read -r f; do
      sed -i "s|@github.com/$short:v[0-9.]*|@github.com/$short:$latest|g" "$f"
    done
    echo "UPDATED $short -> $latest ($count files)"
    UPDATED=$((UPDATED+1))
  fi
done
echo "=== done: $UPDATED repos updated ==="
