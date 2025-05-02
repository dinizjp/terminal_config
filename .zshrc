# Verifica se o fastfetch está disponível e roda apenas em shells interativos
if command -v fastfetch &> /dev/null; then
    if [[ $- == *i* ]]; then
        fastfetch
    fi
fi

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi


#######################################################
# GENERAL ALIASES
#######################################################
# SHORTCUTS
alias h="history | grep "
alias ezsh="micro ~/.zshrc"
alias cls='clear'
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias ldir="ls -l | egrep '^d'"   # directories only
alias las='ls -Al'                 # Hidden Files
alias bat='batcat'
alias sl="ls -l"
alias da='date "+%Y-%m-%d %A %T %Z"'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -v'
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# Remove a directory and all files
alias rmd='/bin/rm  --recursive --force --verbose '

# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

#######################################################
# SPECIAL FUNCTIONS - FROM CHRIS TITUS
#######################################################
extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.bz2) tar xvjf $archive ;;
			*.tar.gz) tar xvzf $archive ;;
			*.bz2) bunzip2 $archive ;;
			*.rar) rar x $archive ;;
			*.gz) gunzip $archive ;;
			*.tar) tar xvf $archive ;;
			*.tbz2) tar xvjf $archive ;;
			*.tgz) tar xvzf $archive ;;
			*.zip) unzip $archive ;;
			*.Z) uncompress $archive ;;
			*.7z) 7z x $archive ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}
# Copy and go to the directory
cpg() {
	if [ -d "$2" ]; then
		cp "$1" "$2" && cd "$2"
	else
		cp "$1" "$2"
	fi
}

# Move and go to the directory
mvg() {
	if [ -d "$2" ]; then
		mv "$1" "$2" && cd "$2"
	else
		mv "$1" "$2"
	fi
}

# Create and go to the directory
mkdirg() {
	mkdir -p "$1"
	cd "$1"
}

#Remove safety 
if command -v trash &> /dev/null; then
    alias rm='trash -v'
else
    alias rm='rm -i'  # fallback to interactive remove
fi

# Goes up a specified number of directories  (i.e. up 4)
up() {
	local d=""
	limit=$1
	for ((i = 1; i <= limit; i++)); do
		d=$d/..
	done
	d=$(echo $d | sed 's/^\///')
	if [ -z "$d" ]; then
		d=..
	fi
	cd $d
}

# Automatically do an ls after each cd, z, or zoxide
cd ()
{
	if [ -n "$1" ]; then
		builtin cd "$@" && ls
	else
		builtin cd ~ && ls
	fi
}

# Searches for text in all files in the current folder
ftext() {
	# -i case-insensitive
	# -I ignore binary files
	# -H causes filename to be printed
	# -r recursive search
	# -n causes line number to be printed
	# optional: -F treat search term as a literal, not a regular expression
	# optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
	grep -iIHrn --color=always "$1" . | less -r
}




###########################################################
# PATHS FZF CONDA PLUGINS 
##########################################################
# Caminho para o Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Tema do Zsh
#ZSH_THEME="agnoster"

# Plugins do Oh My Zsh
plugins=(git fzf zsh-autosuggestions zsh-syntax-highlighting)

# Ativar autocompletar inteligente no Zsh
autoload -U compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
compinit

# Carregar o Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Configurações do usuário

# Definir cores para o ls no Linux
export LS_COLORS="$(vivid generate snazzy)"

# Carregar o fzf, se disponível
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Configuração do Miniconda no Linux
export PATH="$HOME/miniconda3/bin:$PATH"
source "$HOME/miniconda3/etc/profile.d/conda.sh"
export CONDA_AUTO_ACTIVATE_BASE=false


# Inicializar o Conda para o Zsh, se o script existir
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
fi


# Definir editor padrão
export EDITOR="micro"
export VISUAL="micro"
export "MICRO_TRUECOLOR=1"
export OPENAI_API_KEY="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"

eval "$(starship init zsh)"


# DEFAULT_USER prompt_context(){}

