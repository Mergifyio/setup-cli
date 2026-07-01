#!/bin/bash

# Generate the README Inputs table from action.yml.
#
# Replaces tj-actions/auto-doc: parses the action's inputs and rewrites the
# GitHub-flavoured Markdown table between the AUTO-DOC-INPUT markers in
# README.md. Pure bash + awk so the repo needs no Python/uv toolchain.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
ACTION="${ROOT}/action.yml"
README="${ROOT}/README.md"
START="<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->"
END="<!-- AUTO-DOC-INPUT:END -->"

if ! grep -qF "${START}" "${README}" || ! grep -qF "${END}" "${README}"; then
  echo "AUTO-DOC-INPUT markers not found in README.md" >&2
  exit 1
fi

# Render the README inputs table from action.yml. awk emits one finished
# Markdown row per input; only the constrained GitHub Action inputs schema is
# handled (2-space input names, 4-space properties, optional `|`/`>`
# block-scalar descriptions).
rows="$(
  awk '
    function trim(s){ sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    # unwrap a scalar: strip matching surrounding quotes (inside which "#" is
    # literal), otherwise strip an inline " # comment" from a plain scalar.
    function scalar(s){
      s = trim(s)
      if (s ~ /^".*"$/ || s ~ /^'"'"'.*'"'"'$/) return substr(s, 2, length(s) - 2)
      sub(/[ \t]+#.*$/, "", s)
      return trim(s)
    }
    # render a (newline-joined) description into a single Markdown table cell:
    # wrapped prose joins with spaces; "* " lines become <br>-separated bullets.
    function render(raw,   nl, i, line, arr, parts, np, out){
      np = 0; nl = split(raw, arr, "\n")
      for (i = 1; i <= nl; i++) {
        line = trim(arr[i])
        if (line == "") continue
        if (substr(line, 1, 2) == "* ") parts[++np] = "<br>\342\200\242 " trim(substr(line, 3))
        else if (np > 0) parts[np] = parts[np] " " line
        else parts[++np] = line
      }
      out = ""
      for (i = 1; i <= np; i++) out = out parts[i]
      return out
    }
    # emit the finished Markdown row; the downstream sort orders rows by the
    # input name that follows the identical "| `" prefix.
    function flush(   defcell){
      if (cur == "") return
      defcell = (def == "") ? "" : "`" def "`"
      printf "| `%s` | string | %s | %s | %s |\n", cur, req, defcell, render(desc)
    }

    BEGIN { in_inputs = 0; collecting = 0; cur = "" }
    {
      line = $0; sub(/\r$/, "", line)
      p = match(line, /[^ ]/); ind = (p ? p - 1 : length(line))
      blank = (line ~ /^[ \t]*$/)

      if (collecting) {
        if (blank) { desc = desc "\n"; next }
        if (ind > blockind) { desc = desc (desc == "" ? "" : "\n") line; next }
        collecting = 0   # dedent: fall through and reprocess this line
      }

      if (blank) next
      if (line ~ /^[ \t]*#/) next                       # full-line comment

      if (ind == 0) {                                   # top-level key
        flush(); cur = ""
        in_inputs = (line ~ /^inputs:[ \t]*$/) ? 1 : 0
        next
      }
      if (!in_inputs) next

      if (ind == 2) {                                   # new input name
        flush()
        key = line; sub(/:.*$/, "", key); cur = trim(key)
        req = "false"; def = ""; desc = ""
        next
      }
      if (ind >= 4 && cur != "") {                      # input property
        prop = trim(line)
        if (prop ~ /^description:/) {
          val = prop; sub(/^description:[ \t]*/, "", val)
          if (val ~ /^[|>]/) { collecting = 1; blockind = ind; desc = "" }
          else desc = scalar(val)
        } else if (prop ~ /^default:/) {
          val = prop; sub(/^default:[ \t]*/, "", val); def = scalar(val)
        } else if (prop ~ /^required:/) {
          val = prop; sub(/^required:[ \t]*/, "", val); val = tolower(scalar(val))
          req = (val == "true" || val == "yes" || val == "on") ? "true" : "false"
        }
        next
      }
    }
    END { flush() }
  ' "${ACTION}" | LC_ALL=C sort
)"

# Assemble the table; the rows already carry their Markdown formatting.
table="| Input | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |"
if [ -n "${rows}" ]; then
  table="${table}
${rows}"
fi

# Splice the rendered block between the markers (inclusive). The block is read
# from a file rather than passed via `awk -v`, which rejects embedded newlines.
tmp="$(mktemp)"
blockfile="$(mktemp)"
trap 'rm -f "${tmp}" "${blockfile}"' EXIT
printf '%s\n\n%s\n\n%s\n' "${START}" "${table}" "${END}" > "${blockfile}"
awk -v start="${START}" -v end="${END}" -v blockfile="${blockfile}" '
  index($0, start) { while ((getline l < blockfile) > 0) print l; close(blockfile); skip = 1; next }
  skip && index($0, end) { skip = 0; next }
  skip { next }
  { print }
' "${README}" > "${tmp}"
mv "${tmp}" "${README}"
# tmp + blockfile are cleaned by the EXIT trap above.
