# terminal_config

Dotfiles + setup scripts para macOS e Linux.

## Instalar

**macOS:**
```bash
git clone https://github.com/dinizjp/terminal_config.git
cd terminal_config
bash install_mac.sh
```

**Linux** (Ubuntu, Debian, Arch, Fedora, openSUSE):
```bash
git clone https://github.com/dinizjp/terminal_config.git
cd terminal_config
bash install_linux.sh
```

## O que instala

| Ferramenta | Descrição |
|---|---|
| oh-my-zsh | Framework zsh com plugins |
| starship | Prompt customizado |
| eza | `ls` moderno com ícones e cores |
| bat | `cat` com syntax highlight |
| fzf | Fuzzy finder |
| btop | Monitor de sistema |
| fastfetch | System info |
| micro | Editor de terminal |
| ghostty | Terminal GPU-accelerated |
| FiraCode Nerd Font | Fonte com ícones |
| Node.js | Runtime JS |
| Claude Code | CLI da Anthropic |
| Bun | Runtime JS rápido |
| RTK | Proxy CLI para economizar tokens |

## Tema

Catppuccin Mocha em todos os apps (ghostty, btop, eza).

## Chaves de API

Nunca commite segredos. Crie `~/.zshrc.local`:
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-proj-..."
```

## Plugins Claude Code

Após instalar, abra o Claude Code e rode:
```
/plugin install caveman
/plugin install claude-hud
/plugin install context-mode
/reload-plugins
/claude-hud:setup
```
