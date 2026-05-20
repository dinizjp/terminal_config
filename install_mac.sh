#!/usr/bin/env bash
# install_mac.sh — JP's terminal setup for macOS (Apple Silicon + Intel)
# Usage: bash install_mac.sh

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "=== JP Terminal Setup — macOS ==="
echo ""

# ─── Homebrew ─────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
fi
ok "Homebrew"

# ─── Pacotes CLI ──────────────────────────────────────────────────────────────
BREW_PACKAGES=(
    zsh
    git
    micro
    eza
    bat
    fzf
    btop
    fastfetch
    fd
    ripgrep
    starship
    node
    zsh-autosuggestions
    zsh-syntax-highlighting
)

for pkg in "${BREW_PACKAGES[@]}"; do
    brew list "$pkg" &>/dev/null || brew install "$pkg"
done
ok "CLI packages"

# ─── Apps (cask) ──────────────────────────────────────────────────────────────
brew list --cask ghostty &>/dev/null || brew install --cask ghostty
ok "Ghostty"

# FiraCode Nerd Font
brew list --cask font-fira-code-nerd-font &>/dev/null || {
    brew tap homebrew/cask-fonts 2>/dev/null || true
    brew install --cask font-fira-code-nerd-font
}
ok "FiraCode Nerd Font"

# ─── oh-my-zsh ────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
# plugins
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

# ─── fzf keybindings ──────────────────────────────────────────────────────────
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc 2>/dev/null || true

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
