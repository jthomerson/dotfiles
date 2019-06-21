# Installation for a New Machine

Note that many of these steps were from this great writeup:
https://dev.to/therealdanvega/new-macbook-setup-for-developers-2nma


## Prepare for Installations


### Set up Xcode Command Line Tools Package

```
xcode-select --install
```


### Install Homebrew

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```


### Upgrade bash

First, install the latest version of bash.

```
# See what version you have
echo "Current bash version: ${BASH_VERSION}" && bash --version

# Then install the latest
brew install bash
```

Now make it available as a shell:

```
sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
```

And then make it your shell:

```
chsh -s /usr/local/bin/bash
```


### Bash profile

Set up the bash profile to source the shared one from this repo:

```
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "source '${SCRIPT_DIR}/profile.sh'" >> ~/.bash_profile
```


### Install git

Install git and its bash completion. See also:

 * https://salsa.debian.org/debian/bash-completion
 * https://github.com/bobthecow/git-flow-completion/wiki/Install-Bash-git-completion


```
brew install git bash-completion
```

### Miscellaneous Tools

Install some miscellaneous tools that you might like:

```
brew install ag colordiff tree
brew cask install google-chrome
brew cask install firefox
brew cask install visual-studio-code
brew cask install docker
```


### Install Node Version Manager (nvm)

Note: you should check what the latest version is by visiting
https://github.com/nvm-sh/nvm#installation-and-update

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
```
