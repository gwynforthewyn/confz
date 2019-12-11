
function python() {
  docker run -it python python "$@"
}

function promptbranch() {
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1
    then
      gbranch
    else
      echo ""
    fi
}

#http://zsh.sourceforge.net/Doc/Release/Functions.html#Special-Functions
#precmd is a special function
function precmd() {
  PROMPT="$(basename ${PWD}) $(promptbranch) $ "
}
