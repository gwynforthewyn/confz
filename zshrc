# zmodload zsh/zprof

setopt prompt_subst

export PATH=$PATH:$HOME/bin
export PATH=$HOME/.python/Python-3.9.6/usr/local/bin:$PATH
export EDITOR=vi
export VISUAL=${EDITOR}

export DEV="${HOME}/Developer"
export SOURCE="${HOME}/Source"

#Share history across multiple terminals.
setopt share_history
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=1000
set +o inc_append_history # Apparently this should be off if share_history is turned on

# From https://docs.docker.com/engine/reference/commandline/cli/
# this hides the old style "docker stop" commands and forces me to
# use e.g. "docker container stop" and not be a legacy doofus
export DOCKER_HIDE_LEGACY_COMMANDS=1

# gx at the beginning is a lighter blue for directories
# to contrast more with a black background
# see https://geoff.greer.fm/lscolors/ for help
export LSCOLORS=gxfxcxdxbxGxDxabagacad

eval "$(ssh-agent -s)" > /dev/null
ssh-add -K > /dev/null 2>&1

if type brew &>/dev/null; then
  FPATH=/usr/local/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

function bashdebug() {
  echo "trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND")' DEBUG"
}

function cdd() {
  DEST=$1

  cd "${DEV}/${DEST}"
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


function clion() {
  DIR=${1:-"."}

  open -na "/Applications/CLion.app/"  --args "${DIR}"
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

function idea() {
  DIR=${1:-"."}

  open -na "/Applications/Intellij Idea CE.app/"  --args "${DIR}"
}

function pycharm() {
  DIR=${1:-"."}

  open -na "/Applications/PyCharm CE.app/"  --args "${DIR}"
}


alias cds='cd ${SOURCE}'
alias subl="subl -n"
alias gdc='git diff --cached'
alias gdsc='git diff --sort=committerdate | tail -n 5'
alias gdso='git diff --no-ext-diff'
alias gdsoc='git diff --no-ext-diff --cached'
alias gpo='git push origin'

alias python="python3"
alias ssh-add='ssh-add -A'

alias zish="subl -n ${HOME}/.zshrc"

alias history="history 1"

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"


function giveYouAPython() {
    [[ -n "$VIRTUAL_ENV" ]] && echo  " 🐍 "
}


export DO_YOU_A_RPROMPT_STATEFILE="${HOME}/.former_working_dir-${$}"
function doYouARPrompt() {
  if [[ ! -f "${DO_YOU_A_RPROMPT_STATEFILE}" ]]; then
    echo "%F{cyan}$(getpwdname)%f$(activatepypath)$(giveYouAPython)"
  else
    if [[ "$(cat ${DO_YOU_A_RPROMPT_STATEFILE})" != "${PWD}" ]]; then
      echo "%F{cyan}$(getpwdname)%f$(activatepypath)$(giveYouAPython)"
    else
      echo ' '
    fi
  fi

  echo -e "${PWD}" > "${DO_YOU_A_RPROMPT_STATEFILE}"
}

function cleanDoYouARPromptStatefile() {
  rm $DO_YOU_A_RPROMPT_STATEFILE
}

# #http://zsh.sourceforge.net/Doc/Release/Functions.html#Special-Functions
# #chpwd is a special function
chpwd_functions+=(activatepypath
                  )

# Ensure that the rprompt statefile  is removed at the end of each shell session.
zshexit_functions+=(cleanDoYouARPromptStatefile)

RPROMPT="\$(doYouARPrompt)"
PROMPT="; "


export VIRTUAL_ENV_DISABLE_PROMPT=1

# # For building python3 with ssl support
# The correct openssl path is discoverable by this homebrew command
# OPENSSL_PATH=$(brew --prefix openssl)
OPENSSL_PATH="/usr/local/opt/openssl@1.1"
export LDFLAGS="-L${OPENSSL_PATH}/lib"
export CPPFLAGS="-I${OPENSSL_PATH}/include/openssl"
export CFLAGS="-I${OPENSSL_PATH}/include/openssl"
export PATH="${OPENSSL_PATH}/bin:$PATH"

export PATH="$PATH:/Users/jams/Library/Python/3.9/bin"

# zprof
