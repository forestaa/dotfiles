# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt autocd extendedglob nomatch notify nobeep auto_pushd auto_menu

bindkey -e
# bindkey -v
# bindkey -M viins '^?'  backward-delete-char
# bindkey -M viins '^A'  beginning-of-line
# bindkey -M viins '^B'  backward-char
# bindkey -M viins '^D'  delete-char-or-list
# bindkey -M viins '^E'  end-of-line
# bindkey -M viins '^F'  forward-char

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/foresta/.zshrc'

autoload -Uz compinit && compinit
# End of lines added by compinstall

source ~/.zplug/init.zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "plugins/git", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "~/.zsh",      from:local
zplug 'dracula/zsh', as:theme
zplug "zsh-users/zsh-autosuggestions", defer:2  
zplug "b4b4r07/enhancd", use:init.sh
# zplug 'wting/autojump', as:plugin, use:"$HOME/.autojump/etc/profile.d/autojump.sh", from:github, hook-build:'./install.py'
# zplug 'chrissicool/zsh-256color'

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load
# zplug load --verbose


# ignore case when typing lowercase, but respect case when typing uppercase
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'

export PROMPT=$'%{$fg_bold[green]%}%n@%m %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%} $(git_prompt_info)\n%{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} '

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# keychain
keychain --nogui --quiet
source ~/.keychain/$(hostname)-sh

alias nv='nvim'

# ocaml
if command -v opam 1>/dev/null 2>&1; then
  # eval "$(opam config env)"
  test -r /home/foresta/.opam/opam-init/init.zsh && . /home/foresta/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
fi

# go
export GOPATH="$HOME/go"

# haskell stack
export PATH="$HOME/.local/bin:$PATH"

export DISPLAY=localhost:0.0

# vagrant in wsl
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"

# ruby
export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"
