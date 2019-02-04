#!/bin/bash

casks=(
  vagrant
  virtualbox
  docker
)

brews=()

function log() {
    m_time=`date "+%F %T"`
    echo -e "${m_time} [windows_2019_docker]: $1"
}

function command_exists() {
  test $(which $1)
}

function wrap {
  cmd=$1
  shift
  for pkg in "$@"; do
    exec="$cmd $pkg"
    log "Executing $exec"
    if ${exec}; then
      log "Installed $pkg"
    else
      log "ERROR: Failed to execute $exec"
      exit 1
    fi
  done
}

function brew_install_or_upgrade() {
  if brew ls --versions "$1" >/dev/null; then
    if (brew outdated | grep "$1" > /dev/null); then 
      log "Upgrading already installed package $1 ..."
      brew upgrade "$1"
    else 
      log "Latest $1 is already installed"
    fi
  else
    brew install "$1"
  fi
}

function brew_cask_install_or_upgrade() {
  if brew cask ls --versions "$1" >/dev/null; then
    if (brew cask outdated | grep "$1" > /dev/null); then 
      log "Upgrading already installed cask $1 ..."
      brew cask upgrade "$1"
    else 
      log "Latest $1 is already installed"
    fi
  else
    brew cask install "$1"
  fi
}

if ! xcode-select -p > /dev/null; then
  log "Installing xcode..."
  xcode-select --install || true
fi

export PATH="/usr/local/sbin:$PATH"
if ! command_exists "brew"; then
  log "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  log "Updating Homebrew..."
  brew update
  brew upgrade
  brew doctor
fi
export HOMEBREW_NO_AUTO_UPDATE=1

log "Installing Homebrew packages..."
brew tap caskroom/versions
wrap 'brew_cask_install_or_upgrade' "${casks[@]}"
wrap 'brew_install_or_upgrade' "${brews[@]}"
brew cleanup

log "Launching vagrant virtualbox for windows_2019_docker..."
vagrant up --provider virtualbox windows_2019_docker --provision

log "Listing docker machines..."
docker-machine ls

log "Swapping to Windows docker-machine..."
log "\t Use command "'eval $(docker-machine env 2019)'
eval $(docker-machine env 2019)

log "Listing Windows docker images..."
docker images -a

log "Listing Windows docker containers..."
docker ps -a

log "Swapping back to Mac docker-machine..."
log "\t Use command "'eval $(docker-machine env -unset)'
eval $(docker-machine env -unset)

export DOCKER_WINDOWS_HOST=$(docker-machine ip 2019)
log "When using windows containers, use the docker windows host ip '${DOCKER_WINDOWS_HOST}'"
