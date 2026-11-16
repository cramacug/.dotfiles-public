#!/bin/bash
# Claude Code status line
# Line 1: current directory | git branch
# Line 2: Model - Effort (model :: effort) | Context window (pct :: used/total k)
# Line 3: rate-limit usage (Session / Week), when available

# Epoch -> formatted date, portable across BSD/macOS date and GNU/Linux date
case "$(uname -s)" in
  Darwin) date_from_epoch() { date -r "$1" +"$2"; } ;;
  *) date_from_epoch() { date -d "@$1" +"$2"; } ;;
esac

# jq is required to parse the status payload; say so instead of rendering blanks
if ! command -v jq >/dev/null 2>&1; then
  printf "statusline: jq not installed"
  exit 0
fi

input=$(cat)

# 1. Current directory (abbreviate $HOME as ~), split into dim parent path + bold last segment
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
dir="${cwd/#$HOME/~}"

last="${dir##*/}"
parent="${dir%/*}"
if [ "$dir" = "/" ]; then
  # filesystem root: show "/" itself as the bold segment
  last="/"
  parent=""
elif [ "$parent" = "$dir" ] || [ -z "$last" ]; then
  parent=""
else
  # also covers root-level dirs like /tmp, where parent is "" and becomes "/"
  parent="${parent}/"
fi

# 2. Git branch (skip optional locks so this never blocks concurrent git operations)
branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)

# 3. Model name
model=$(echo "$input" | jq -r '.model.display_name')

# 4. Context usage
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  ctx=$(printf "%.0f%%" "$used")
else
  ctx="--"
fi

# 4b. Reasoning effort (absent on models without reasoning effort)
effort=$(echo "$input" | jq -r '.effort.level // "N/A"')

# 4c. Context window token counts (used/total, in thousands)
context_used_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
tokens_str=""
if [ -n "$context_used_tokens" ] && [ -n "$context_window_size" ]; then
  tokens_str="$((context_used_tokens / 1000))/$((context_window_size / 1000))"
elif [ -n "$context_used_tokens" ]; then
  tokens_str="$((context_used_tokens / 1000))"
elif [ -n "$context_window_size" ]; then
  tokens_str="$((context_window_size / 1000))"
fi

# 5. Rate limits (Pro/Max accounts only; may be absent early in a session)
five_hour_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_day_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Colors (dim-friendly ANSI codes; terminal renders the status line dimmed already)
DIM='\033[2m'
DIM_CYAN='\033[2;36m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'
DARK_ORANGE='\033[38;5;130m'
LIGHT_PURPLE='\033[38;5;141m'
LIGHT_BLUE='\033[38;5;39m'
YELLOW='\033[33m'
BOLD_RED='\033[1;31m'
RED='\033[31m'
MAGENTA='\033[35m'
BLUE='\033[34m'
GREEN='\033[32m'
RESET='\033[0m'
SEP=' | '

dir_field="${DIM_CYAN}${parent}${RESET}${BOLD_CYAN}${last}${RESET}"

line1="${dir_field}"
if [ -n "$branch" ]; then
  if [ "$branch" = "main" ]; then
    branch_color="${BOLD_RED}"
  else
    branch_color="${YELLOW}"
  fi
  line1="${line1}${SEP}${branch_color}${branch}${RESET}"
fi

model_segment="${BOLD_WHITE}Model - Effort${RESET} (${MAGENTA}${model}${RESET}${DIM} :: ${RESET}${LIGHT_PURPLE}${effort}${RESET})"

if [ -n "$tokens_str" ]; then
  ctx_segment="${BOLD_WHITE}Context window${RESET} (${LIGHT_BLUE}${ctx}${RESET}${DIM} :: ${RESET}${BLUE}${tokens_str}${RESET})"
else
  ctx_segment="${BOLD_WHITE}Context window${RESET} (${LIGHT_BLUE}${ctx}${RESET})"
fi

line2="${model_segment}${SEP}${ctx_segment}"

# Line 3: rate-limit usage (skip entirely if rate_limits is absent)
five_segment=""
if [ -n "$five_hour_used" ]; then
  five_rounded=$(printf "%.0f" "$five_hour_used")
  if [ "$five_rounded" -lt 50 ]; then
    five_color="${GREEN}"
  elif [ "$five_rounded" -lt 80 ]; then
    five_color="${YELLOW}"
  else
    five_color="${RED}"
  fi
  five_reset_fmt=""
  if [ -n "$five_hour_reset" ]; then
    five_reset_fmt=$(date_from_epoch "$five_hour_reset" "%H:%M" 2>/dev/null)
  fi
  five_segment="${BOLD_WHITE}Session${RESET} (${five_color}${five_rounded}%${RESET}${DIM} :: ${RESET}${DARK_ORANGE}${five_reset_fmt}${RESET})"
fi

week_segment=""
if [ -n "$seven_day_used" ]; then
  week_rounded=$(printf "%.0f" "$seven_day_used")
  if [ "$week_rounded" -lt 50 ]; then
    week_color="${GREEN}"
  elif [ "$week_rounded" -lt 80 ]; then
    week_color="${YELLOW}"
  else
    week_color="${RED}"
  fi
  week_reset_fmt=""
  if [ -n "$seven_day_reset" ]; then
    week_reset_fmt=$(date_from_epoch "$seven_day_reset" "%Y-%m-%dT%H:%M" 2>/dev/null)
  fi
  week_segment="${BOLD_WHITE}Week${RESET} (${week_color}${week_rounded}%${RESET}${DIM} :: ${RESET}${DARK_ORANGE}${week_reset_fmt}${RESET})"
fi

line3=""
if [ -n "$five_segment" ] && [ -n "$week_segment" ]; then
  line3="${five_segment}${SEP}${week_segment}"
elif [ -n "$five_segment" ]; then
  line3="${five_segment}"
elif [ -n "$week_segment" ]; then
  line3="${week_segment}"
fi

if [ -n "$line3" ]; then
  output="${line1}\n${line2}\n${line3}"
else
  output="${line1}\n${line2}"
fi

printf "%b" "$output"
