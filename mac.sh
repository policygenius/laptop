#!/bin/sh
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

##### Functions and Helpers #####

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

append_to_zshrc() {
  local text="$1" zshrc
  local skip_new_line="${2:-0}"

  if [ -w "$HOME/.zshrc.local" ]; then
    zshrc="$HOME/.zshrc.local"
  else
    zshrc="$HOME/.zshrc"
  fi

  if ! grep -Fqs "$text" "$zshrc"; then
    if [ "$skip_new_line" -eq 1 ]; then
      printf "%s\n" "$text" >> "$zshrc"
    else
      printf "\n%s\n" "$text" >> "$zshrc"
    fi
  fi
}

cask_install_or_upgrade() {
  if ! cask_is_installed "$1"; then
    fancy_echo "Installing %s ..." "$1"
    brew install --cask --appdir="/Applications" "$@" || true
  fi
}

cask_is_installed() {
  local name="$(cask_expand_alias "$1")"

  brew list --cask -1 | grep -Fqx "$name"
}

cask_expand_alias() {
  brew info --cask "$1" 2>/dev/null | head -1 | awk '{gsub(/:/, ""); print $1}'
}

brew_install_or_upgrade() {
  if brew_is_installed "$1"; then
    if brew_is_upgradable "$1"; then
      fancy_echo "Upgrading %s ..." "$1"
      brew upgrade "$@"
    else
      fancy_echo "Already using the latest version of %s. Skipping ..." "$1"
    fi
  else
    fancy_echo "Installing %s ..." "$1"
    brew install "$@"
  fi
}

brew_is_installed() {
  local name="$(brew_expand_alias "$1")"

  brew list --formula -1 | grep -Fqx "$name"
}

brew_is_upgradable() {
  local name="$(brew_expand_alias "$1")"

  ! brew outdated --quiet "$name" >/dev/null
}

brew_tap() {
  fancy_echo "Tapping %s..." "$1"
  brew tap "$1" 2> /dev/null
}

brew_expand_alias() {
  brew info "$1" 2>/dev/null | head -1 | awk '{gsub(/:/, ""); print $1}'
}

brew_launchctl_restart() {
  local name="$(brew_expand_alias "$1")"
  local domain="homebrew.mxcl.$name"
  local plist="$domain.plist"

  fancy_echo "Restarting %s ..." "$1"
  mkdir -p "$HOME/Library/LaunchAgents"
  ln -sfv "/usr/local/opt/$name/$plist" "$HOME/Library/LaunchAgents"

  if launchctl list | grep -Fq "$domain"; then
    launchctl unload "$HOME/Library/LaunchAgents/$plist" >/dev/null
  fi
  launchctl load "$HOME/Library/LaunchAgents/$plist" >/dev/null
}

gem_install_or_update() {
  if gem list "$1" --installed > /dev/null; then
    fancy_echo "Updating %s ..." "$1"
    gem update "$@"
  else
    fancy_echo "Installing %s ..." "$1"
    gem install "$@"
    rbenv rehash
  fi
}

install_or_update_homebrew() {
  if ! command -v brew >/dev/null; then
    fancy_echo "Installing Homebrew ..."
    /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    append_to_zshrc '# recommended by brew doctor'

    append_to_zshrc 'export PATH="/usr/local/bin:$PATH"' 1

    export PATH="/usr/local/bin:$PATH"
  else
    fancy_echo "Homebrew already installed."
  fi
  fancy_echo "Updating Homebrew formulas ..."
  brew update
}

install_ruby() {
  append_to_zshrc 'eval "$(rbenv init - --no-rehash zsh)"' 1
  ruby_version="2.7.6"
  eval "$(rbenv init - zsh)"

  if ! rbenv versions | grep -Fq "$ruby_version"; then
    rbenv install -s "$ruby_version"
  fi

  rbenv global "$ruby_version"
  rbenv shell "$ruby_version"

  gem update --system 3.4.22
}

install_bundler_1_17_3() {
  gem install bundler --version 1.17.3
  rbenv rehash

  fancy_echo "Configuring Bundler ..."
  number_of_cores=$(sysctl -n hw.ncpu)
  bundle config --global jobs $((number_of_cores - 1))
}

 # PostgreSQL 9.6 hit EoL and is no longer supported by brew. This step now downloads the PG App - https://postgresapp.com/ - to install 9.6
 # You will need to manually start the Database however. See the StartingPostgresApp.md guide in this repo.
 install_postgresql() {
  # brew_install_or_upgrade 'postgresql@9.6'
  # brew link postgresql@9.6 --force
  # brew_launchctl_restart 'postgresql'
  # if [ `psql -U postgres -c "select 1" &> /dev/null` ]; then
  #   /usr/local/bin/createuser -U `whoami` --superuser postgres
  # fi

  if [ -z `psql --version`]; then
    fancy_echo 'Installing psql via PostgresApp...'
    # Download the postgresapp DMG via curl
    # --location to follow redirects
    # --output to write the output to a file
    curl https://github.com/PostgresApp/PostgresApp/releases/download/v2.5.2/Postgres-2.5.2-9.6-10-11-12-13-14.dmg --location --output ~/Downloads/postgres-2.5.2.dmg
    MOUNT_POINT=$(hdiutil attach ~/Downloads/postgres-2.5.2.dmg -nobrowse | grep "Postgres-2.5.2" | awk '{print $3}')
    sudo cp -R $MOUNT_POINT/Postgres.app /Applications
    hdiutil unmount $MOUNT_POINT
    sudo mkdir -p /etc/paths.d && echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp
    fancy_echo 'Installed psql via PostgresApp BUT needs to be started manually'
  else
    fancy_echo 'Already installed Psql. Skipping'
  fi
}

##### Start Installation #####

if [ ! -d "$HOME/.bin/" ]; then
  mkdir "$HOME/.bin"
fi

if [ ! -f "$HOME/.zshrc" ]; then
  touch "$HOME/.zshrc"
fi

append_to_zshrc 'export PATH="$HOME/.bin:$PATH"'

# Install packages
install_or_update_homebrew
brew_install_or_upgrade 'git'
install_postgresql
brew_install_or_upgrade 'redis'
brew_launchctl_restart 'redis'
brew_install_or_upgrade 'sops'
brew_install_or_upgrade 'n'
sudo n stable
brew_install_or_upgrade 'yarn'
brew_install_or_upgrade 'rbenv'
brew_install_or_upgrade 'ruby-build'
brew_install_or_upgrade 'openssl'
brew_install_or_upgrade 'elasticsearch@6'
brew_install_or_upgrade 'txn2/tap/kubefwd'
brew services start elasticsearch@6

brew unlink openssl && brew link openssl --force

brew_tap 'homebrew/cask'
cask_install_or_upgrade 'chromedriver'

# Install applications
cask_install_or_upgrade 'google-chrome'
install_ruby
install_bundler_1_17_3

# Setup Google Cloud Platform/Kubernetes Tooling
cask_install_or_upgrade 'google-cloud-sdk'
gcloud components install kubectl docker-credential-gcr pubsub-emulator
brew_install_or_upgrade 'helm'
append_to_zshrc 'source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
