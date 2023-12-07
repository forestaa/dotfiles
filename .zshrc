# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

bindkey -v
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000
setopt extendedglob notify nobeep
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'


### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})â¦%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-rust \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-bin-gem-node

### End of Zinit's installer chunk

zinit light-mode for zsh-users/zsh-autosuggestions
zinit light-mode for zdharma-continuum/fast-syntax-highlighting
zinit light-mode wait for zdharma-continuum/history-search-multi-word
zinit light-mode depth=1 for romkatv/powerlevel10k
zinit light-mode for jeffreytse/zsh-vi-mode
zinit light-mode rustup cargo='zoxide' atload='eval "$(zoxide init zsh)"; export _ZO_FZF_OPTS="--height 40% --layout=reverse"' for zdharma-continuum/null
zinit snippet 'https://github.com/halcyon/asdf-java/blob/master/set-java-home.zsh'

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

# nvim
alias nv='nvim'

# zsh-vi-mode
function zvm_vi_yank() {
	zvm_yank
	printf ${CUTBUFFER} | pbcopy
	zvm_exit_visual_mode
}

# Prevent unintentioal git push to master
function dry-run-when-git-push-to-master() {
  if [[ $BUFFER =~ .*git[[:space:]]+push && "$(git branch --show-current)" = "master" ]]; then
    echo ""
    if [[ ! $BUFFER =~ --exec ]]; then
      echo "[dry-run-when-git-push-to-master]: You are on master branch. Run git push in dry-run mode."
      echo "[dry-run-when-git-push-to-master]: Put '--exec' if you really want to run git push."
      local command="${BUFFER} --dry-run"
    else
      local command="${BUFFER/--exec/}"
    fi
    zle .kill-buffer
    echo "[dry-run-when-git-push-to-master]: current branch: $(git branch --show-current)"
    echo "[dry-run-when-git-push-to-master]: command"
    BUFFER="  ${command}"
  fi
  zle .accept-line
}
zle -N accept-line dry-run-when-git-push-to-master

# go
if command -v go 1>/dev/null 2>&1; then
  export GOPATH="$HOME/.go"
  export PATH="$GOPATH/bin:$PATH"
fi

 # gcloud
if command -v gcloud 1>/dev/null 2>&1; then
  source $(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
  source $(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
fi

if command -v aws 1>/dev/null 2>&1; then
  complete -C $(brew --prefix awscli)/bin/aws_completer aws
fi

# openssl
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"

# asdf
if command -v asdf 1>/dev/null 2>&1; then
  source $(brew --prefix asdf)/libexec/asdf.sh
  source $HOME/.asdf/plugins/java/set-java-home.zsh
fi

# krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# fzf
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse"

# code with fzf
alias ghcode='code $(ghq list -p | fzf)'
alias ghidea='idea $(ghq list -p | fzf)'

# ghcup
[ -f "/Users/daichi.morita/.ghcup/env" ] && source "/Users/daichi.morita/.ghcup/env" # ghcup-env

# Added by Docker Desktop
[ -f "/Users/daichi.morita/.docker/init-zsh.sh" ] && source /Users/daichi.morita/.docker/init-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


