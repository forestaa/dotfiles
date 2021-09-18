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
# zplug "plugins/git", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "~/.zsh",      from:local
zplug 'dracula/zsh', as:theme
zplug "zsh-users/zsh-autosuggestions", defer:2
zplug "git/git", use:"contrib/completion/git-completion.zsh"
# zplug "b4b4r07/enhancd", use:init.sh
# zplug 'wting/autojump', as:plugin, use:"$HOME/.autojump/etc/profile.d/autojump.sh", from:github, hook-build:'./install.py'
# zplug 'chrissicool/zsh-256color'
# zplug mafredri/zsh-async, from:github
# zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme

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

# GIT_PROMPT_EXECUTABLE="haskell"
# export PROMPT=$'%{$fg_bold[green]%}%n@%m %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%} $(git_prompt_info)\n%{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} '
# source $HOME/build/zsh-git-prompt/zshrc.sh
# export PROMPT=$'%{$fg_bold[green]%}%n@%m %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%} $(git_super_status)\n%{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} '
export PROMPT=$'%{$fg_bold[green]%}%n@%m %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%} $DRACULA_GIT_STATUS%f%b\n%{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} '
# export PROMPT=$'%{$fg_bold[green]%}%n@%m %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%}  %F{242}${prompt_pure_vcs_info[branch]}%F{218}${prompt_pure_git_dirty}%f\n%{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} '

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
if command -v keychain 1>/dev/null 2>&1; then
  keychain --nogui --quiet
  source ~/.keychain/$(hostname)-sh
fi

alias nv='nvim'

# xdg base directory
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share

# ocaml
if command -v opam 1>/dev/null 2>&1; then
  test -r /home/foresta/.opam/opam-init/init.zsh && . /home/foresta/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
fi

# go
if command -v go 1>/dev/null 2>&1; then
  go env -w GOPATH=$HOME/.go
  export GOPATH="$HOME/.go"
fi

# haskell stack
export PATH="$HOME/.local/bin:$PATH"

export DISPLAY=localhost:0.0

# vagrant in wsl
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"

# ruby
# export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"
# if [ -f "/usr/share/chruby/chruby.sh" ]; then source /usr/share/chruby/chruby.sh; fi

# ghcup
if [ -f "$HOME/.ghcup/env" ]; then . $HOME/.ghcup/env; fi

# nvm
if [ -f '/usr/share/nvm/init-nvm.sh' ]; then . '/usr/share/nvm/init-nvm.sh'; fi


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/foresta/build/google-cloud-sdk/path.zsh.inc' ]; then . '/home/foresta/build/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/foresta/build/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/foresta/build/google-cloud-sdk/completion.zsh.inc'; fi

# rust
export PATH="$HOME/.cargo/bin:$PATH"

function dry-run-when-push-to-master() {
  if [[ $BUFFER =~ .*git[[:space:]]+push && "$(git branch --show-current)" = "master" ]]; then
    echo ""
    if [[ ! $BUFFER =~ --exec ]]; then
      echo "[dry-run-when-push-to-master]: You are on master branch. Run git push in dry-run mode."
      echo "[dry-run-when-push-to-master]: Put '--exec' if you want to run git push."
      local command="${BUFFER} --dry-run"
    else
      local command="${BUFFER/--exec/}"
    fi
    zle .kill-buffer
    echo "[dry-run-when-push-to-master]: current branch: $(git branch --show-current)"
    echo "[dry-run-when-push-to-master]: command:"
    BUFFER="  ${command}"   # put the spaces before command because BUFFER is not written well without the spaces...
  fi
  zle .accept-line
}
zle -N accept-line dry-run-when-push-to-master

