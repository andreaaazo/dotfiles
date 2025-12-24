# 💎 LIQUID FUTURE LUXURY - ZSH Config
# Mood: Cyber-Brutalist, Neon, Void.

# --- 1. HISTORY & ENVIRONMENT ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS

export TERM=xterm-256color
export EDITOR="nvim"

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# ZSH clean locations
export HISTFILE="$XDG_DATA_HOME/zsh/.zsh_history"
mkdir -p "$XDG_DATA_HOME/zsh"



# --- 2. COMPLETION SYSTEM ---
autoload -Uz compinit
zstyle ":completion:*" menu select
# Applica i colori di LS_COLORS anche al menu di autocompletamento (Tab)
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
compinit

# --- 3. ALIASES ---
# Clear pulisce e mostra il logo
alias clear="clear && fastfetch"

# Ls & Grep con colori
alias ll="ls -lha --color=auto"
alias ls="ls --all --color=auto"
alias grep="grep --color=auto"

# Config Editor
alias vim="nvim"
alias vi="nvim"
alias nano="nvim" # Forziamo l'uso di nvim per abitudine

# God Tier Update Command
# Legge le news di Arch, aggiorna tutto (repo + aur), controlla rebuilds e rimuove orfani se esistono
alias update="sudo informant read && yay -Syu && sudo checkrebuild && (pacman -Qtdq > /dev/null && sudo pacman -Rns \$(pacman -Qtdq) || echo '✨ System clean, no orphans found.')"

# --- 4. PLUGINS ---
# Source dei plugin standard di Arch Linux
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- 5. VISUAL STYLING (Liquid Future Palette) ---

# Configurazione colori Syntax Highlighting (Dopo il source del plugin)
# Primary Glow (#CD6AFF) per comandi validi
# Error Neon (#FF0055) per errori
# Secondary (#5628F3) per opzioni
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#CD6AFF,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#CD6AFF,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#CD6AFF,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#CD6AFF,bold'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF0055,bold'
ZSH_HIGHLIGHT_STYLES[path]='fg=#9D81FE,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#9D81FE'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#FEAC19'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#5628F3'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#5628F3'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#605a66,dim'

# Configurazione LS_COLORS (File System Colors)
# Directory=Viola, Exe=Verde Neon, Link=Ciano, Zip=Arancione
export LS_COLORS="di=1;35:ln=1;36:so=1;32:pi=1;33:ex=1;32:bd=1;34:cd=1;34:su=1;41:sg=1;46:tw=1;42:ow=1;43"

# --- 6. PROMPT & STARTUP ---
# Inizializza Starship
eval "$(starship init zsh)"

# Lancia fastfetch all'avvio della shell
fastfetch
