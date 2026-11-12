if command -v fastfetch &> /dev/null; then
    # Only run fastfetch if we're in an interactive shell
    if [[ $- == *i* ]]; then
        fastfetch
    fi
fi

#SHORTCUTS
alias h="history | grep "
alias ezsh="nano ~/.zshrc"
alias cls='clear'
alias ls='eza -lh --group-directories-first --icons --hyperlink'
alias lt='eza --tree --level=3 --long --icons --git'
alias lta='lt -a'

#gitclone
gclone() {
  if [ "$#" -eq 0 ]; then
    echo "Uso: gclone <nome-do-repositorio>"
    return 1
  fi
  git clone git@github-443:dinizjp/"$1".git
}

n8n_update() {
  local tag="${1:-1.106.3}"   # passe outra tag quando quiser
  docker pull docker.n8n.io/n8nio/n8n:"$tag" &&
  docker rm -f n8n 2>/dev/null || true &&
  docker run -d --name n8n --restart unless-stopped \
    -p 5678:5678 \
    -v "$HOME/.n8n:/home/node/.n8n" \
    --env-file "$HOME/n8n.env" \
    docker.n8n.io/n8nio/n8n:"$tag"
}



# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"


# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"
# Texto escuro nos blocos do prompt (o "preto" do tema Cursed VHS é claro e sumia no azul)
CURRENT_FG="#1c082c"


COMPLETION_WAITING_DOTS="true"


plugins=(git fzf zsh-autosuggestions zsh-syntax-highlighting macos)

# 🟢 Ativar Autocompletar Inteligente no Zsh
autoload -U compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
compinit


source $ZSH/oh-my-zsh.sh



export LS_COLORS="/Users/dinizjp/.config/eza"



[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source <(fzf --zsh)


#CONDA
export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
source /opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh
export CONDA_AUTO_ACTIVATE_BASE=false


# Inicializar o Conda para o Zsh, se o script existir
if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
    . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
fi
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

export EDITOR="micro"
export VISUAL="micro"
export "MICRO_TRUECOLOR=1"
# Chaves de API ficam fora do git, em ~/.zshrc.local
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

DEFAULT_USER prompt_context(){}

# Added by Antigravity
export PATH="/Users/dinizjp/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
alias claude-tivita="CLAUDE_CONFIG_DIR=~/.claude-tivita command claude"
alias claude-pessoal="CLAUDE_CONFIG_DIR=~/.claude-pessoal command claude"

# bun completions
[ -s "/Users/dinizjp/.bun/_bun" ] && source "/Users/dinizjp/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# >>> tokless path >>>
# Adds tokless tool bin dirs to PATH (rtk, bun, cargo).
for d in "$HOME/.local/bin" "$HOME/.bun/bin" "$HOME/.cargo/bin"; do
  [ -d "$d" ] && case ":$PATH:" in *":$d:"*) ;; *) PATH="$d:$PATH" ;; esac
done
export PATH
# <<< tokless path <<<
