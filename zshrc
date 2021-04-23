export PATH=$PATH:$HOME/bin
export EDITOR=vi
export VISUAL=${EDITOR}

# gx at the beginning is a lighter blue for directories
# to contrast more with a black background
# see https://geoff.greer.fm/lscolors/ for help
export LSCOLORS=gxfxcxdxbxGxDxabagacad

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
  PROMPT="$(getpwdname) %F{cyan}$(promptbranch)%f $ "
}


function grebase() {
    mainBranch=$1

    if [ -z "${mainBranch}" ]; then
      mainBranch="main"
    fi

    git checkout ${mainBranch}
    git fetch upstream --prune
    git rebase --verbose upstream/${mainBranch}
    git push origin ${mainBranch}
}

alias cds='cd /Users/jams/Source'
alias cdp='cd /Users/jams/Developer'

alias gdsc='git diff --sort=committerdate | tail -n 5'
alias gdso='git diff --no-ext-diff'
source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"

