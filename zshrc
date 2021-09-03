setopt prompt_subst

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

  if [[ ${VIRTUAL_ENV} ]]; then
    # VIRTUAL_ENV for a project in /foo/bar contains /foo/bar/venv
    VIRTUAL_ENV_DIR=$(dirname ${VIRTUAL_ENV})

    if [[ "${PWD}" != ${VIRTUAL_ENV_DIR}*  ]]; then
      deactivate
    fi
  fi

  PRESENT_SEARCH=${PWD}

  while [[ ${PRESENT_SEARCH} != "/" ]]
  do
    VALID_VENV_PATHS=(
      "${PRESENT_SEARCH}/.venv/bin/activate"
      "${PRESENT_SEARCH}/venv/bin/activate"
      "${PRESENT_SEARCH}/virtualenv/bin/activate"
    )

    for POTENTIAL_PATH in "${VALID_VENV_PATHS[@]}"; do
      if [[ -f "${POTENTIAL_PATH}" ]]; then
        source "${POTENTIAL_PATH}"
        return 0
      fi
    done

    PRESENT_SEARCH=$(dirname ${PRESENT_SEARCH})
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
  case $PWD in
  ($HOME/*)
      echo ${PWD#$HOME/}
      ;;
  (*)
      echo ${PWD}
      ;;
  esac

}

function grebase() {
  MAIN_BRANCH="main"

  testForBranch=$(git branch | grep -E "\s${mainBranch}$")

  if [ -z "${testForBranch}" ]; then
    mainBranch="master"
  fi

  git checkout ${mainBranch}
  git fetch upstream --prune
  git rebase --verbose upstream/${mainBranch}
  git push origin ${mainBranch}
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

export PATH="$HOME/.rbenv/bin:$PATH"


alias history="history 1"

eval "$(rbenv init -)"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# #http://zsh.sourceforge.net/Doc/Release/Functions.html#Special-Functions
# #chpwd is a special function
chpwd_functions+=(activatepypath)

function giveYouAPython() {
    [[ -n "$VIRTUAL_ENV" ]] && echo  " 🐍"
}

PROMPT="\$(activatepypath)\$(getpwdname) %F{cyan}\$(promptbranch)%f\$(giveYouAPython) $ "
export VIRTUAL_ENV_DISABLE_PROMPT=1
