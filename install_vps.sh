#!/usr/bin/env bash
# install_vps.sh — JP's terminal setup for VPS/servers (SSH, headless)
# Sem GUI, sem fontes, sem terminal emulator — só CLI + Claude
# Suporte: Ubuntu/Debian, Arch, Fedora, openSUSE
# Usage: bash install_vps.sh

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

safe_copy() {
    local src="$1" dst="$2"
    if [ -f "$dst" ] || [ -d "$dst" ]; then
        mv "$dst" "${dst}.bak.$(date +%Y%m%d%H%M%S)"
    fi
    cp -r "$src" "$dst"
}

echo ""
echo "=== JP Terminal Setup — VPS/Server ==="
echo ""

# ─── Detectar distro ──────────────────────────────────────────────────────────
detect_distro() {
    [ -f /etc/os-release ] && { . /etc/os-release; echo "$ID"; } || echo "unknown"
}
DISTRO=$(detect_distro)

install_pkg() {
    case "$DISTRO" in
        ubuntu|debian|linuxmint|pop)  sudo apt-get install -y "$@" ;;
        arch|manjaro|endeavouros)     sudo pacman -S --noconfirm "$@" ;;
        fedora|rhel|centos|rocky)     sudo dnf install -y "$@" ;;
        opensuse*)                    sudo zypper install -y "$@" ;;
        *) warn "Distro '$DISTRO' não reconhecida. Instale manualmente: $*"; return 1 ;;
    esac
}

# ─── Update ───────────────────────────────────────────────────────────────────
case "$DISTRO" in
    ubuntu|debian|linuxmint|pop) sudo apt-get update -qq ;;
    arch|manjaro|endeavouros)    sudo pacman -Sy --noconfirm ;;
    fedora|rhel|centos|rocky)    sudo dnf check-update -q || true ;;
    opensuse*)                   sudo zypper refresh ;;
esac

# ─── Pacotes base ─────────────────────────────────────────────────────────────
case "$DISTRO" in
    ubuntu|debian|linuxmint|pop)
        sudo apt-get install -y zsh git curl wget unzip micro bat fzf btop fd-find ripgrep fastfetch 2>/dev/null || \
        sudo apt-get install -y zsh git curl wget unzip bat fzf ripgrep ;;
    arch|manjaro|endeavouros)
        sudo pacman -S --noconfirm zsh git curl wget unzip micro bat fzf btop fd ripgrep fastfetch ;;
    fedora|rhel|centos|rocky)
        sudo dnf install -y zsh git curl wget unzip bat fzf btop ripgrep ;;
    opensuse*)
        sudo zypper install -y zsh git curl wget unzip bat fzf btop ripgrep ;;
esac
ok "Pacotes base"

# ─── eza ──────────────────────────────────────────────────────────────────────
if ! command -v eza &>/dev/null; then
    case "$DISTRO" in
        arch|manjaro|endeavouros)
            sudo pacman -S --noconfirm eza ;;
        ubuntu|debian|linuxmint|pop)
            sudo apt-get install -y gpg
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
                | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
                | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo apt-get update -qq && sudo apt-get install -y eza ;;
        *)
            command -v cargo &>/dev/null && cargo install eza || \
            warn "eza: instale manualmente de https://github.com/eza-community/eza/releases" ;;
    esac
fi
ok "eza"

# ─── Starship ─────────────────────────────────────────────────────────────────
command -v starship &>/dev/null || curl -fsSL https://starship.rs/install.sh | sh -s -- -y
ok "Starship"

# ─── Node.js ──────────────────────────────────────────────────────────────────
if ! command -v node &>/dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - 2>/dev/null || true
    install_pkg nodejs 2>/dev/null || warn "Instale Node.js: https://nodejs.org"
fi
ok "Node.js"

# ─── oh-my-zsh ────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
ok "oh-my-zsh + plugins"

# ─── Bun ──────────────────────────────────────────────────────────────────────
if ! command -v bun &>/dev/null && [ ! -f "$HOME/.bun/bin/bun" ]; then
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi
ok "Bun"

# ─── Claude Code ──────────────────────────────────────────────────────────────
command -v claude &>/dev/null || npm install -g @anthropic-ai/claude-code
ok "Claude Code"

# ─── RTK ──────────────────────────────────────────────────────────────────────
if ! command -v rtk &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
fi
command -v rtk &>/dev/null && rtk init -g
ok "RTK"

# ─── Dotfiles ─────────────────────────────────────────────────────────────────
safe_copy "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

mkdir -p "$HOME/.config/btop/themes"
safe_copy "$DOTFILES_DIR/.config/btop/btop.conf"                     "$HOME/.config/btop/btop.conf"
safe_copy "$DOTFILES_DIR/.config/btop/themes/catppuccin_mocha.theme" "$HOME/.config/btop/themes/catppuccin_mocha.theme"

mkdir -p "$HOME/.config/eza"
safe_copy "$DOTFILES_DIR/.config/eza/config.yaml" "$HOME/.config/eza/config.yaml"

mkdir -p "$HOME/.config/micro"
[ -f "$DOTFILES_DIR/.config/micro/settings.json" ] && \
    safe_copy "$DOTFILES_DIR/.config/micro/settings.json" "$HOME/.config/micro/settings.json"

safe_copy "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

ok "Dotfiles copiados (backup criado se existia)"

# ─── Shell padrão ─────────────────────────────────────────────────────────────
ZSH_PATH="$(which zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
    grep -q "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
    chsh -s "$ZSH_PATH"
fi

# ─── Claude Code plugins ──────────────────────────────────────────────────────
CLAUDE_PLUGINS_DIR="$HOME/.claude/plugins"
mkdir -p "$CLAUDE_PLUGINS_DIR"
cat > "$CLAUDE_PLUGINS_DIR/known_marketplaces.json" << 'JSON'
{
  "claude-plugins-official": {"source": {"source": "github", "repo": "anthropics/claude-plugins-official"}, "installLocation": ""},
  "caveman":      {"source": {"source": "github", "repo": "JuliusBrussee/caveman"},    "installLocation": ""},
  "claude-hud":   {"source": {"source": "github", "repo": "jarrodwatts/claude-hud"},   "installLocation": ""},
  "context-mode": {"source": {"source": "github", "repo": "mksglu/context-mode"},      "installLocation": ""}
}
JSON
ok "Claude Code marketplaces configurados"

# ─── Concluído ────────────────────────────────────────────────────────────────
echo ""
echo "=== Setup concluído! ==="
echo ""
echo "Execute: exec zsh"
echo ""
echo "Depois dentro do Claude Code rode:"
echo ""
echo "  /plugin install caveman"
echo "  /plugin install context-mode"
echo "  /reload-plugins"
echo ""
echo "Crie ~/.zshrc.local com suas chaves de API:"
echo "  export ANTHROPIC_API_KEY=\"sk-ant-...\""
echo ""
