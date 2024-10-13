# zmodload zsh/zprof

HOMEBREW_NO_INSTALL_FROM_API=1

source ${HOME/.zshrc_env_vars}
bindkey \^U backward-kill-line #modify ctrl-u to delete from the cursor backwards

setopt prompt_subst

export PATH=/usr/local/bin:$PATH:$HOME/bin
export EDITOR=nvim
export VISUAL=${EDITOR}

export GROOVY_HOME=/usr/local/opt/groovy/libexec

export DEV="${HOME}/Developer"
# Not sure about commenting out gopath...
export GOPATH="${HOME}/go"
export PATH=${HOME}/go/bin:${PATH}
export SOURCE="${HOME}/Source"

#Share history across multiple terminals.
setopt share_history
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=100000000
SAVEHIST=100000000
set +o inc_append_history # Apparently this should be off if share_history is turned on

set -o emacs

export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"

# Dangerous stuff from homebrew for ruby
export PATH="/usr/local/opt/ruby/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/ruby/lib"
export CPPFLAGS="-I/usr/local/opt/ruby/include"
export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"

# From https://docs.docker.com/engine/reference/commandline/cli/
# this hides the old style "docker stop" commands and forces me to
# use e.g. "docker container stop" and not be a legacy doofus
export DOCKER_HIDE_LEGACY_COMMANDS=1

# gx at the beginning is a lighter blue for directories
# to contrast more with a black background
# see https://geoff.greer.fm/lscolors/ for help
export LSCOLORS=gxfxcxdxbxGxDxabagacad

eval "$(ssh-agent -s)" > /dev/null
if [[ $(uname -a | grep Darwin) ]]; then
  export APPLE_SSH_ADD_BEHAVIOR=macos
  ssh-add --apple-load-keychain > /dev/null 2>&1
else
  # Assume we're on linux
  ssh-add -K > /dev/null 2>&1
fi

autoload -Uz compinit 
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;

# Allows autocomplete stuff to succeed
# https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Use-of-compinit
if type brew &>/dev/null; then
  # FPATH=/usr/local/share/zsh-completions:$FPATH
  FPATH=/usr/local/share/zsh/site-functions:$FPATH
fi

# This sources kubectl completion, which requires compinit
source <(command kubectl completion zsh)

function bashdebug() {
  echo "trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND")' DEBUG"
}


# Custom completion function for cdd
_cdd_complete() {
  # Use _files to generate a list of directories in $DEV
  _files -W "${DEV}" -/
}

# Register the custom completion function for cdd
compdef _cdd_complete cdd

function cdd() {
  DEST=$1

  cd "${DEV}/${DEST}/"
}

function cds() {
  DEST=$1

  cd "${SOURCE}/${DEST}"
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

function dockerlogs() {
  tail -f ~/Library/Containers/com.docker.docker/Data/log/vm/dockerd.log
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

function clion() {
  DIR=${1:-"."} 
  open -na "/Applications/CLion.app/" --args "${DIR}"
}

function goland() {
  DIR=${1:-"."} 
  open -na "/Applications/GoLand.app/" --args "${DIR}"
}

function idea() {
  DIR=${1:-"."}

  open -na "/Applications/Intellij Idea.app/"  --args "${DIR}"
}

function pycharm() {
  DIR=${1:-"."}

  open -na "/Applications/PyCharm.app/"  --args "${DIR}"
}

function rubymine() {
  DIR=${1:-"."}

  open -na "/Applications/RubyMine.app/"  --args "${DIR}"
}

function webstorm() {
  DIR=${1:-"."}

  open -na "/Applications/WebStorm.app/"  --args "${DIR}"
}

function wireshark() {
  FILE=${1}

  if [[ -z "$FILE" ]]; then
    echo "usage: wireshark path/to/file.pcap"
    exit 1
  fi

  FILE="$(pwd)/${FILE}"

  open -na "/Applications/Wireshark.app/" --args "${FILE}"
}

function particle() {
  TITLE=${1}
  DIRECTORY=${2}

  if [[ -z "${TITLE}" || -z "${DIRECTORY}" ]]; then
    echo "You missed providing a TITLE or DIRECTORY to this function" >&2
    echo "Usage: particle TITLE OUTPUTDIRECTORY" >&2
    return 1
  fi

  if [[ ! -d "${DIRECTORY}" ]]; then
    echo "Your directory <${DIRECTORY}> does not exist." >&2
    echo "Usage: particle TITLE OUTPUTDIRECTORY" >&2
    return 1
  fi

  OUTPUTFILE=$(echo "${TITLE}" | tr " " "-" | tr "[:upper:]" "[:lower:]").html
  TARGET="${DIRECTORY}/${OUTPUTFILE}"
  if [[ -f "${TARGET}" ]]; then
    echo "File <${TARGET}> already exists. Refusing to overwrite" >&2
    return 1
  fi

  templ webpages/article | templ TITLE="${TITLE}" DATE="$(date +"%Y-%m-%d %H:%M:%S")" > "${TARGET}"
}

alias cds='cd ${SOURCE}'
alias dec='pbpaste | base64 -d'
alias docdate="date +%Y-%m-%d"
alias subl="subl -n"
alias gdc='git diff --cached'
alias gdsc='git diff --sort=committerdate | tail -n 5'
alias gdso='git diff --no-ext-diff'
alias gdsoc='git diff --no-ext-diff --cached'
alias gpo='git push origin'
alias gpu='git push upstream'

alias vi="nvim"

alias k="kubectl"

alias python="python3"

alias zish="subl -n ${HOME}/.zshrc"

alias history="history 1"


function giveYouAPython() {
    [[ -n "$VIRTUAL_ENV" ]] && echo  " 🐍"
}


function doYouARPrompt() {
    echo "%F{cyan}$(getpwdname)%f$(giveYouAPython) %F{red}$(git rev-parse --abbrev-ref HEAD 2> /dev/null)%f"
}

function ssh() {
      TERM=xterm /usr/bin/ssh $@
}

# #http://zsh.sourceforge.net/Doc/Release/Functions.html#Special-Functions
# #chpwd is a special function
chpwd_functions+=(activatepypath
                  )

PROMPT=" \$(doYouARPrompt)%F{5f00d7} ; %f"


export VIRTUAL_ENV_DISABLE_PROMPT=1

# # For building python3 with ssl support
# The correct openssl path is discoverable by this homebrew command
# OPENSSL_PATH=$(brew --prefix openssl)
OPENSSL_PATH="/usr/local/opt/openssl@3"
export LDFLAGS="-L${OPENSSL_PATH}/lib"
export CPPFLAGS="-I${OPENSSL_PATH}/include/openssl"
export CFLAGS="-I${OPENSSL_PATH}/include/openssl"
export PATH="${OPENSSL_PATH}/bin:$PATH"

# zprof
export PATH="/usr/local/sbin:$PATH"

[ -f "/Users/gwyn/.ghcup/env" ] && source "/Users/gwyn/.ghcup/env" # ghcup-env
