#!/bin/sh
# Lay out a window as the agent sidebar (@pane_role sidebar) down the left at
# @sidebar_width columns, with every other pane in an evenly sized grid of
# ceil(sqrt(N)) columns beside it: 1 pane is 1x1, 4 are 2x2, 9 are 3x3, and
# counts in between leave the last columns one pane short. Without a sidebar
# the grid takes the whole window. Bound to prefix + = in ~/.tmux.conf.
#
# Usage: equalize.sh [window-id]   (defaults to the current window)

w=${1:-$(tmux display -p '#{window_id}')}

sidebar=$(tmux list-panes -t "$w" -F '#{pane_id} #{@pane_role}' |
  awk '$2 == "sidebar" { print $1; exit }')

# select-layout fills the layout's cells in pane order, so the sidebar must
# come first to land in the left column.
if [ -n "$sidebar" ]; then
  first=$(tmux list-panes -t "$w" -F '#{pane_id}' | head -n 1)
  [ "$first" != "$sidebar" ] && tmux swap-pane -d -s "$sidebar" -t "$first"
fi

sw=$(tmux show -gv @sidebar_width 2>/dev/null)
size=$(tmux display -p -t "$w" '#{window_width} #{window_height}')
panes=$(tmux list-panes -t "$w" -F '#{pane_id}' | tr -d % | tr '\n' ' ')

layout=$(echo "$size" | awk -v sidebar="$sidebar" -v sw="${sw:-23}" -v panes="$panes" '
  # Split len cells into n parts with a 1-cell border between each, giving
  # the leftover cells one at a time to the first parts.
  function split_len(len, n, out,    i, avail) {
    avail = len - (n - 1)
    for (i = 1; i <= n; i++)
      out[i] = int(avail / n) + (i <= avail % n)
  }
  # The 16-bit rotate-and-add checksum tmux puts in front of a layout,
  # written without bitwise operators so any awk will do.
  function checksum(s,    i, c) {
    c = 0
    for (i = 1; i <= length(s); i++)
      c = (int(c / 2) + (c % 2) * 32768 + ord[substr(s, i, 1)]) % 65536
    return sprintf("%04x", c)
  }
  {
    W = $1; H = $2
    for (i = 32; i < 127; i++) ord[sprintf("%c", i)] = i
    np = split(panes, id, " ")
    p = 1; x = 0; body = ""
    if (sidebar != "") {
      body = sw "x" H ",0,0," id[p++]
      x = sw + 1
    }
    n = np - p + 1
    if (n < 1) exit 1
    cols = int(sqrt(n)); if (cols * cols < n) cols++
    split_len(W - x, cols, cw)
    for (c = 1; c <= cols; c++) {
      rows = int(n / cols) + (c <= n % cols)
      split_len(H, rows, rh)
      y = 0; cells = ""
      for (r = 1; r <= rows; r++) {
        cells = cells (r > 1 ? "," : "") cw[c] "x" rh[r] "," x "," y "," id[p++]
        y += rh[r] + 1
      }
      col = rows > 1 ? cw[c] "x" H "," x ",0[" cells "]" : cells
      body = body (body != "" ? "," : "") col
      x += cw[c] + 1
    }
    # A lone column with no sidebar is already the whole window.
    root = (sidebar == "" && cols == 1) ? col : W "x" H ",0,0{" body "}"
    print checksum(root) "," root
  }') || exit 0

tmux select-layout -t "$w" "$layout"
