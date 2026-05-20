# ─── fastfetch ────────────────────────────────────────────────────────────────
if command -v fastfetch &> /dev/null && [[ $- == *i* ]]; then
    fastfetch
fi

# ─── oh-my-zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git fzf zsh-autosuggestions zsh-syntax-highlighting)

autoload -U compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
compinit

source $ZSH/oh-my-zsh.sh

DEFAULT_USER prompt_context(){}

# ─── editor ───────────────────────────────────────────────────────────────────
export EDITOR="micro"
export VISUAL="micro"
export MICRO_TRUECOLOR=1

# ─── aliases ──────────────────────────────────────────────────────────────────
alias h="history | grep "
alias ezsh="micro ~/.zshrc"
alias cls='clear'
alias ls='eza -lh --group-directories-first --icons --hyperlink'
alias lt='eza --tree --level=3 --long --icons --git'
alias lta='lt -a'
alias ldir="eza -l | grep '^d'"
alias las='eza -Al'
alias sl="eza -l"
alias bat='bat'
alias da='date "+%Y-%m-%d %A %T %Z"'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -v'
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# ─── functions ────────────────────────────────────────────────────────────────
cpd() { cp -r "$1" "$2" && cd "$2"; }
mvd() { mv "$1" "$2" && cd "$2"; }
mcd() { mkdir -p "$1" && cd "$1"; }

up() {
    local d=""
    local limit="${1:-1}"
    for ((i=1; i<=limit; i++)); do d="../$d"; done
    cd "${d:-.}" || return 1
}

ftext() {
    grep -iIHrn --color=always "$1" . | less -r
}

extract() {
    for archive in "$@"; do
        if [ -f "$archive" ]; then
            case $archive in
            *.tar.bz2) tar xvjf "$archive" ;;
            *.tar.gz)  tar xvzf "$archive" ;;
            *.bz2)     bunzip2 "$archive" ;;
            *.rar)     rar x "$archive" ;;
            *.gz)      gunzip "$archive" ;;
            *.tar)     tar xvf "$archive" ;;
            *.tbz2)    tar xvjf "$archive" ;;
            *.tgz)     tar xvzf "$archive" ;;
            *.zip)     unzip "$archive" ;;
            *.Z)       uncompress "$archive" ;;
            *.7z)      7z x "$archive" ;;
            *) echo "don't know how to extract '$archive'" ;;
            esac
        else
            echo "'$archive' is not a valid file"
        fi
    done
}

gclone() {
    if [ "$#" -eq 0 ]; then
        echo "Uso: gclone <nome-do-repositorio>"
        return 1
    fi
    git clone git@github.com:dinizjp/"$1".git
}

n8n_update() {
    local tag="${1:-latest}"
    docker pull docker.n8n.io/n8nio/n8n:"$tag" &&
    docker rm -f n8n 2>/dev/null || true &&
    docker run -d --name n8n --restart unless-stopped \
        -p 5678:5678 \
        -v "$HOME/.n8n:/home/node/.n8n" \
        --env-file "$HOME/n8n.env" \
        docker.n8n.io/n8nio/n8n:"$tag"
}

# ─── fzf ──────────────────────────────────────────────────────────────────────
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
command -v fzf &>/dev/null && source <(fzf --zsh) 2>/dev/null

# ─── conda ────────────────────────────────────────────────────────────────────
# macOS (Homebrew miniconda)
if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
    source "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
fi
# macOS (Homebrew anaconda)
if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
    source "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
fi
# Linux
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
fi
export CONDA_AUTO_ACTIVATE_BASE=false

# ─── bun ──────────────────────────────────────────────────────────────────────
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ─── local bin (rtk, etc) ─────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ─── starship ─────────────────────────────────────────────────────────────────
eval "$(starship init zsh)"

# ─── segredos locais (não commitado) ──────────────────────────────────────────
# Crie ~/.zshrc.local com suas chaves de API:
#   export OPENAI_API_KEY=""
#   export ANTHROPIC_API_KEY=""
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
