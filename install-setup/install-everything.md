# Installation for a New Machine

Note that many of these steps were from this great writeup:
https://dev.to/therealdanvega/new-macbook-setup-for-developers-2nma


## Prepare for Installations


### Set up Xcode Command Line Tools Package

```
xcode-select --install
```

If you get an error that says "Can't install the software" you can go to
https://developer.apple.com/downloads/index.action and download the tools and
install them manually.


### Install Homebrew

Note that this script must be run with a user that can `sudo`.

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

If the user you ran the previous command as is not your primary user (i.e. it
was a user who could `sudo`, but your day-to-day primary user can not `sudo`),
but you want your primary user to be able to install packages with Homebrew,
you need to also follow these steps:

```
# As admin user:
sudo chown -R YOURUSERNAMEHERE /usr/local/*

# Then, switch back to your primary user, perhaps by running `exit`. Then:
/usr/local/bin/brew update --force
```

At this point you should be set up and able to install packages using Homebrew
as your primary user.


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

If your user account does not have `sudo` permissions, you can also `Cmd+,` in
Terminal and change the setting from "Shells open with: Default login shell" to
"Command" and enter `/usr/local/bin/bash`.


### Install git

Install git and its bash completion. See also:

 * https://salsa.debian.org/debian/bash-completion
 * https://github.com/bobthecow/git-flow-completion/wiki/Install-Bash-git-completion


```
brew install git bash-completion
```


### Install this repo

This repo has all the necessary dotfiles in it.

```
mkdir -p ~/code/jthomerson
pushd ~/code/jthomerson
git clone git@github.com:jthomerson/dotfiles.git
```


### Configure bash profile

Set up the bash profile.

If one does not exist yet, you may want to do this. This will reset the `PATH` variable to
its default so that each time you reset your shell, you don't end up appending your old
PATH to your new one. Of course, if your bash profile already has other things in it, you
may not want to do this, or you may want to put this at the very top of the file.

```
echo 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"' >> ~/.bash_profile
```

Then we want to definitely set up the profile to source this script:

```
echo "source '~/code/jthomerson/dotfiles/bash/profile.sh'" >> ~/.bash_profile
```


### Install miscellaneous tools

Install some miscellaneous tools that you might like:

```
brew install \
   ag \
   colordiff \
   tree \
   corkscrew \
   ccrypt \
   hugo \
   imagemagick \
   ohcount \
   tmux \
   thrift \
   youtube-dl \
   remind101/formulae/assume-role
```

These tools require additional entries in your profile to update your `PATH`
environment (see [../bash/path.sh](../bash/path.sh)).

```
brew install coreutils
brew install grep
brew install openssl
brew install python
brew install ffmpeg
```

And now some GUI-based tools:

```
brew cask install sublime-text
brew cask install google-chrome
brew cask install firefox
brew cask install visual-studio-code
brew cask install docker
brew cask install db-browser-for-sqlite
```


### Install Node Version Manager (nvm)

Note: you should check what the latest version is by visiting
https://github.com/nvm-sh/nvm#installation-and-update

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
```
