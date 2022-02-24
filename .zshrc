# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


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
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node

### End of Zinit's installer chunk

zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zdharma-continuum/history-search-multi-word
zinit light b4b4r07/enhancd
zinit depth=1 light-mode for romkatv/powerlevel10k
zinit depth=1 light-mode for jeffreytse/zsh-vi-mode

bindkey -v
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'
export HISTSIZE=1000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY
setopt no_beep

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
  source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
  source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
fi

# openssl
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"

# asdf
if command -v asdf 1>/dev/null 2>&1; then
  source /usr/local/opt/asdf/libexec/asdf.sh
  # source $HOME/.asdf/plugins/java/set-java-home.zsh
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
