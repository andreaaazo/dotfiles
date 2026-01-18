# --- HISTORY & ENVIRONMENT ---
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

[[ -d "$XDG_DATA_HOME/zsh" ]] || mkdir -p "$XDG_DATA_HOME/zsh"
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"

# ZSH clean locations
export HISTFILE="$XDG_DATA_HOME/zsh/.zsh_history"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/compdump"
mkdir -p "$XDG_DATA_HOME/zsh"


alias clear="clear && fastfetch"

alias ls="ls --all --color=auto"
alias grep="grep --color=auto"


alias update="sudo informant read && yay -Syu && sudo checkrebuild && (pacman -Qtdq > /dev/null && sudo pacman -Rns \$(pacman -Qtdq) || echo '✨ System clean, no orphans found.')"

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- 6. PROMPT & STARTUP ---
# Inizializza Starship
eval "$(starship init zsh)"

# Lancia fastfetch all'avvio della shell
fastfetch


export PATH=$PATH:/home/Andrea/.spicetify
