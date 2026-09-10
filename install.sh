#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

VERSION="2.0.0"
APP="T-Termux"
BASE="$HOME/.t-termux"
CONFIG="$BASE/config"
BACKUP_DIR="$BASE/backups"
ZSHRC="$HOME/.zshrc"

C_RESET='\033[0m'; C_CYAN='\033[1;36m'; C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'; C_RED='\033[1;31m'; C_BLUE='\033[1;34m'

log(){ printf "${C_CYAN}[•]${C_RESET} %s\n" "$*"; }
ok(){ printf "${C_GREEN}[✓]${C_RESET} %s\n" "$*"; }
warn(){ printf "${C_YELLOW}[!]${C_RESET} %s\n" "$*"; }
die(){ printf "${C_RED}[✗]${C_RESET} %s\n" "$*" >&2; exit 1; }

[[ -d "$PREFIX" && -n "${TERMUX_VERSION:-}" ]] || die "این اسکریپت فقط داخل Termux اجرا می‌شود."
command -v pkg >/dev/null 2>&1 || die "دستور pkg پیدا نشد."

backup_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  mkdir -p "$BACKUP_DIR"
  cp -f "$f" "$BACKUP_DIR/$(basename "$f").$(date +%Y%m%d-%H%M%S).bak"
}

ensure_pkg() {
  local missing=()
  for p in "$@"; do
    dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p")
  done
  if ((${#missing[@]})); then
    log "نصب وابستگی‌ها: ${missing[*]}"
    pkg update -y >/dev/null
    pkg install -y "${missing[@]}"
  fi
}

install_plugin() {
  local url="$1" dest="$2"
  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" pull --ff-only >/dev/null 2>&1 || true
  else
    rm -rf "$dest"
    git clone --depth 1 "$url" "$dest" >/dev/null
  fi
}

write_zshrc() {
  backup_file "$ZSHRC"
  cat > "$ZSHRC" <<'EOF'
# T-Termux v2 managed block
export TTERMUX_HOME="$HOME/.t-termux"
export PATH="$TTERMUX_HOME/bin:$PATH"

# Plugins
if [[ -f "$TTERMUX_HOME/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$TTERMUX_HOME/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [[ -f "$TTERMUX_HOME/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$TTERMUX_HOME/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=5000
setopt append_history hist_ignore_dups share_history autocd interactive_comments

# Safer, useful aliases
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls --color=auto'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'

# T-Termux prompt
autoload -U colors && colors
setopt prompt_subst
PROMPT='%F{cyan}┌─[%f%F{green}%n%f@%F{blue}termux%f]─[%F{yellow}%~%f] %F{magenta}$(git_prompt)%f
%F{cyan}└─╼%f %F{green}❯%f '
RPROMPT='%F{240}%D{%H:%M:%S}%f'

git_prompt() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return
  if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
    print -r -- " $branch ✗"
  else
    print -r -- " $branch ✓"
  fi
}

# Banner once per interactive shell
if [[ -o interactive && -z "${TTERMUX_BANNER_SHOWN:-}" ]]; then
  export TTERMUX_BANNER_SHOWN=1
  "$TTERMUX_HOME/bin/ttermux-banner" 2>/dev/null || true
fi
# End T-Termux v2 managed block
EOF
}

setup_files() {
  mkdir -p "$BASE/bin" "$BASE/plugins" "$CONFIG" "$BACKUP_DIR"
  cp "$(dirname "$0")/lib/ttermux-banner" "$BASE/bin/ttermux-banner"
  cp "$(dirname "$0")/lib/ttermux" "$BASE/bin/ttermux"
  chmod +x "$BASE/bin/"*
}

main() {
  log "$APP v$VERSION"
  ensure_pkg git zsh figlet
  setup_files

  log "دریافت پلاگین‌ها..."
  install_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$BASE/plugins/zsh-autosuggestions"
  install_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$BASE/plugins/zsh-syntax-highlighting"

  write_zshrc
  "$BASE/bin/ttermux" doctor >/dev/null 2>&1 || true

  if command -v chsh >/dev/null 2>&1; then
    chsh -s "$(command -v zsh)" 2>/dev/null || warn "تغییر shell پیش‌فرض انجام نشد؛ دستی zsh را اجرا کن."
  fi

  ok "T-Termux v2 نصب شد."
  printf '\n%s\n' "برای ورود به پنل: ttermux"
  printf '%s\n' "برای فعال‌سازی فوری: exec zsh"
}
main "$@"
