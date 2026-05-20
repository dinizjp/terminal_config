#!/usr/bin/env bash
# install_linux.sh — JP's terminal setup for Linux
# Suporte: Ubuntu/Debian, Arch, Fedora/RHEL, openSUSE
# Usage: bash install_linux.sh

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "=== JP Terminal Setup — Linux ==="
echo ""

# ─── Detectar distro ──────────────────────────────────────────────────────────
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

DISTRO=$(detect_distro)

install_pkg() {
    case "$DISTRO" in
        ubuntu|debian|linuxmint|pop)
            sudo apt-get install -y "$@" ;;
        arch|manjaro|endeavouros|garuda)
            sudo pacman -S --noconfirm "$@" ;;
        fedora|rhel|centos|rocky|almalinux)
            sudo dnf install -y "$@" ;;
        opensuse*|sles)
            sudo zypper install -y "$@" ;;
        *)
            warn "Distro '$DISTRO' não reconhecida. Instale manualmente: $*"
            return 1 ;;
    esac
}

# ─── Update ───────────────────────────────────────────────────────────────────
case "$DISTRO" in
    ubuntu|debian|linuxmint|pop)
        sudo apt-get update -qq ;;
    arch|manjaro|endeavouros|garuda)
        sudo pacman -Sy --noconfirm ;;
    fedora|rhel|centos|rocky|almalinux)
        sudo dnf check-update -q || true ;;
    opensuse*|sles)
        sudo zypper refresh ;;
esac

# ─── Pacotes base ─────────────────────────────────────────────────────────────
BASE_PKGS_APT=(zsh git curl wget unzip micro bat fzf btop fd-find ripgrep fastfetch)
BASE_PKGS_ARCH=(zsh git curl wget unzip micro bat fzf btop fd ripgrep fastfetch)
BASE_PKGS_DNF=(zsh git curl wget unzip micro bat fzf btop fd-find ripgrep fastfetch)
BASE_PKGS_ZYPPER=(zsh git curl wget unzip micro bat fzf btop fd ripgrep)

case "$DISTRO" in
    ubuntu|debian|linuxmint|pop)
        sudo apt-get install -y "${BASE_PKGS_APT[@]}" 2>/dev/null || \
        sudo apt-get install -y zsh git curl wget unzip bat fzf btop fd-find ripgrep ;;
    arch|manjaro|endeavouros|garuda)
        sudo pacman -S --noconfirm "${BASE_PKGS_ARCH[@]}" ;;
    fedora|rhel|centos|rocky|almalinux)
        sudo dnf install -y "${BASE_PKGS_DNF[@]}" 2>/dev/null || \
        sudo dnf install -y zsh git curl wget unzip bat fzf btop ripgrep ;;
    opensuse*|sles)
        sudo zypper install -y "${BASE_PKGS_ZYPPER[@]}" ;;
esac
ok "Pacotes base"

# ─── eza (via cargo ou binário) ───────────────────────────────────────────────
if ! command -v eza &>/dev/null; then
    case "$DISTRO" in
        arch|manjaro|endeavouros|garuda)
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
            if command -v cargo &>/dev/null; then
                cargo install eza
            else
                warn "eza: instale manualmente de https://github.com/eza-community/eza/releases"
            fi ;;
    esac
fi
ok "eza"

# ─── Starship ─────────────────────────────────────────────────────────────────
if ! command -v starship &>/dev/null; then
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi
ok "Starship"

# ─── Node.js ──────────────────────────────────────────────────────────────────
if ! command -v node &>/dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - 2>/dev/null || true
    install_pkg nodejs 2>/dev/null || warn "Instale Node.js manualmente: https://nodejs.org"
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

# ─── Ghostty ─────────────────────────────────────────────────────────────────
if ! command -v ghostty &>/dev/null; then
    case "$DISTRO" in
        arch|manjaro|endeavouros|garuda)
            sudo pacman -S --noconfirm ghostty 2>/dev/null || \
            (command -v yay &>/dev/null && yay -S --noconfirm ghostty) || \
            warn "Instale Ghostty manualmente: https://ghostty.org/download" ;;
        *)
            if command -v flatpak &>/dev/null; then
                flatpak install -y flathub com.mitchellh.ghostty 2>/dev/null || true
            else
                warn "Instale Ghostty manualmente: https://ghostty.org/download"
            fi ;;
    esac
fi
ok "Ghostty"

# ─── FiraCode Nerd Font ───────────────────────────────────────────────────────
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if ! fc-list | grep -qi "FiraCode Nerd"; then
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
    TMP_FONT=$(mktemp -d)
    curl -fsSL "$FONT_URL" -o "$TMP_FONT/FiraCode.zip"
    unzip -q "$TMP_FONT/FiraCode.zip" -d "$FONT_DIR"
    rm -rf "$TMP_FONT"
    fc-cache -f
fi
ok "FiraCode Nerd Font"

# ─── Dotfiles ─────────────────────────────────────────────────────────────────
cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

mkdir -p "$HOME/.config/ghostty"
cp "$DOTFILES_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"

mkdir -p "$HOME/.config/btop/themes"
cp "$DOTFILES_DIR/.config/btop/btop.conf"                       "$HOME/.config/btop/btop.conf"
cp "$DOTFILES_DIR/.config/btop/themes/catppuccin_mocha.theme"   "$HOME/.config/btop/themes/catppuccin_mocha.theme"

mkdir -p "$HOME/.config/eza"
cp "$DOTFILES_DIR/.config/eza/config.yaml" "$HOME/.config/eza/config.yaml"

mkdir -p "$HOME/.config/micro"
cp "$DOTFILES_DIR/.config/micro/settings.json" "$HOME/.config/micro/settings.json" 2>/dev/null || true

cp "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

ok "Dotfiles copiados"

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
echo "Reinicie o terminal e então dentro do Claude Code rode:"
echo ""
echo "  /plugin install caveman"
echo "  /plugin install claude-hud"
echo "  /plugin install context-mode"
echo "  /reload-plugins"
echo "  /claude-hud:setup"
echo ""
echo "Crie ~/.zshrc.local com suas chaves de API (não commitado):"
echo "  export ANTHROPIC_API_KEY=\"sk-...\""
echo ""
