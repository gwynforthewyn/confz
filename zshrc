export PATH=$PATH:$HOME/bin
export EDITOR=vi
export VISUAL=${EDITOR}

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
  print(os.getcwd().split(os.path.expanduser("~")+"/")[1]) 
else:
  print(os.getcwd())
'
}

#http://zsh.sourceforge.net/Doc/Release/Functions.html#Special-Functions
#precmd is a special function
function precmd() {
  PROMPT="$(getpwdname) $(promptbranch) $ "
}

alias cds='cd /Users/jams/Source'
alias cdp='cd /Users/jams/Developer'

source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"

