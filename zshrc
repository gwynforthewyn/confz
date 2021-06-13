export PATH=$PATH:$HOME/bin
export EDITOR=vi
export VISUAL=${EDITOR}

export DEV="${HOME}/Developer"
export SOURCE="${HOME}/Source"

# gx at the beginning is a lighter blue for directories
# to contrast more with a black background
# see https://geoff.greer.fm/lscolors/ for help
export LSCOLORS=gxfxcxdxbxGxDxabagacad

eval "$(ssh-agent -s)" > /dev/null
ssh-add -K > /dev/null 2>&1

setopt INC_APPEND_HISTORY

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

function cdd() {
  DEST=$1

  cd "${DEV}/${DEST}" || exit
}

def activatepypath() {
  declare -a VALID_VENV_PATHS
  VALID_VENV_PATHS=(
    "./.venv/bin/activate"
    "./venv/bin/activate"
  )

  for PATH in "${VALID_VENV_PATHS[@]}"; do
    if [[ -f "${PATH}" ]]; then
      source "${PATH}" && echo "🐍 "
      return 0
    fi
  done
}

function gbranch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

function promptbranch() {
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1
    then
      gbranch
    else
      echo ""
    fi
}

# In home directory subdirs, strip the path to home dir.
# Otherwise, print the whole path
function getpwdname() {
python -c '
import os
import re

matcher = re.compile("^"+os.path.expanduser("~")+"\S")

if (matcher.match(os.getcwd())):
  current_dir_without_home = os.getcwd().split(os.path.expanduser("~")+"/")[1]
  print(current_dir_without_home + "/")
else:
  print(os.getcwd())
'
}

#http://zsh.sourceforge.net/Doc/Release/Functions.html#Special-Functions
#precmd is a special function
function precmd() {
  PROMPT="$(getpwdname) %F{cyan}$(promptbranch)%f $(activatepypath) $ "
}

function grebase() {
    MAIN_BRANCH=$1

    if [ -z "${MAIN_BRANCH}" ]; then
      MAIN_BRANCH="main"
    fi

    git checkout ${MAIN_BRANCH}
    git fetch upstream --prune
    git rebase --verbose upstream/${MAIN_BRANCH}
    git push origin ${MAIN_BRANCH}
}

function gupdate() {
    MAIN_BRANCH=$1

    if [ -z "${MAIN_BRANCH}" ]; then
      MAIN_BRANCH="main"
    fi

    CURRENT_BRANCH="$(gbranch)"

    grebase ${MAIN_BRANCH}
    git checkout $CURRENT_BRANCH
    git rebase $MAIN_BRANCH
}


alias cds='cd ${SOURCE}'

alias gdc='git diff --cached'
alias gdsc='git diff --sort=committerdate | tail -n 5'
alias gdso='git diff --no-ext-diff'
alias gdsoc='git diff --no-ext-diff --cached'
alias gpo='git push origin'

alias ssh-add='ssh-add -A'

source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
export PATH="$HOME/.rbenv/bin:$PATH"

unalias mv
unalias rm
unalias history

alias history="history 1"

eval "$(rbenv init -)"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
