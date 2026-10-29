#!/bin/sh
# Build the site: wrap every page in the shared layout and write it to public/.
set -e

rm -rf public
mkdir -p public
cp style.css public/

for f in pages/*.html pages/essays/*.html; do
  [ -e "$f" ] || continue              # skip if a folder is empty

  rel=${f#pages/}                      # e.g. essays/example.html
  out="public/$rel"
  mkdir -p "$(dirname "$out")"

  # Which nav link is the current page?
  case "$rel" in
    writing/*) name=index ;;
    *)        name=$(basename "$rel" .html) ;;
  esac

  # A page's first line is its title, written as <!-- Title -->
  title=$(head -n 1 "$f" | sed 's/<!-- \(.*\) -->/\1/')

  # Top of the layout, with the title filled in and the current link marked.
  sed -e "s|{{title}}|$title|" \
      -e "/<li>/s|href=\"/$name.html\"|& aria-current=\"page\"|" \
      layout/top.html > "$out"

  # The page itself (minus its title line), then the bottom of the layout.
  tail -n +2 "$f" >> "$out"
  cat layout/bottom.html >> "$out"
done

echo "Built $(find public -name '*.html' | wc -l) pages into public/"
