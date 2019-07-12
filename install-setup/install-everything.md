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

Now configure it:

```
git config --global user.email "jeremy@thomersonfamily.com"
git config --global user.name "Jeremy Thomerson"
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
echo 'source ~/code/jthomerson/dotfiles/bash/profile.sh' >> ~/.bash_profile
```


### Install miscellaneous tools

Install some miscellaneous tools that you might like:

```
brew install \
   telnet \
   ag \
   jq \
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

Note: if you are running brew as a *non-admin* user (someone who can not `sudo`), then you
will need to install these applications to your user's `~/Applications` directory. To
configure brew to always do this for all cask installs, do this:

```
echo 'export HOMEBREW_CASK_OPTS="--appdir=~/Applications"' >> ~/.bash_profile
```

```
brew cask install iterm2
brew cask install spectacle
brew cask install sublime-text
brew cask install google-chrome
brew cask install firefox
brew cask install visual-studio-code
brew cask install docker
brew cask install db-browser-for-sqlite
brew cask install dropbox
brew cask install remember-the-milk
# If you have an older license for Keyboard Maestro, you'll have to install it
# manually instead of this cask. See https://www.stairways.com/main/download
brew cask install keyboard-maestro
brew cask install skitch
brew cask install slack
brew cask install 1password-cli
brew tap homebrew/cask-versions && brew cask install 1password-beta
```


### Upgrade Vim and configure it

Vim installs Ruby, which requires additional entries in your profile to update
your `PATH` environment if you want to use the Homebrew-installed Ruby (see
[../bash/path.sh](../bash/path.sh)).

```
brew install vim
```


### Configure VNC

To enable VNC access to the machine, go to System Preferences > Sharing >
Remote Management. Make sure it is enabled, and your user whitelisted if "only these
users" option is selected.


### Configure SSH

To enable SSH access to the machine, go to System Preferences > Sharing >
Remote Login. Make sure it is enabled, and your user whitelisted if "only these
users" option is selected.

#### Alternate Port

If you need to run SSH on an alternate port for any reason, you should see
https://apple.stackexchange.com/a/335329 to see the list of ways that it's possible to do
this. I typically use method two (making a new launch daemon) so that I can run SSH on the
standard port and an alternate port.

Here's the contents of my `/Library/LaunchDaemons/ssh2.plist`:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Disabled</key>
	<true/>
	<key>Label</key>
	<string>com.openssh.sshd2</string>
	<key>Program</key>
	<string>/usr/libexec/sshd-keygen-wrapper</string>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/sbin/sshd</string>
		<string>-i</string>
	</array>
	<key>Sockets</key>
	<dict>
		<key>Listeners</key>
		<dict>
			<key>SockServiceName</key>
			<string>2222</string>
		</dict>
	</dict>
	<key>inetdCompatibility</key>
	<dict>
		<key>Wait</key>
		<false/>
		<key>Instances</key>
		<integer>42</integer>
	</dict>
	<key>StandardErrorPath</key>
	<string>/dev/null</string>
	<key>SHAuthorizationRight</key>
	<string>system.preferences</string>
	<key>POSIXSpawnType</key>
	<string>Interactive</string>
</dict>
</plist>
```

In case the tutorial / Stack Overflow answer disappears later, the method is to
(as root):

   * Create the file described above
   * `launchctl load -w /Library/LaunchDaemons/ssh2.plist`

If you want to unload / stop it,
`launchctl unload /Library/LaunchDaemons/ssh2.plist`


### Install Node Version Manager (nvm)

Note: you should check what the latest version is by visiting
https://github.com/nvm-sh/nvm#installation-and-update

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
```

Then you'll want to at least set up your default node and NPM versions, e.g.:

```
nvm install 8.10
npm install --global npm@6.4.1
```


### Install Antivirus

If you have a need (e.g. corporate policy for your work VPN, etc) to install an
antivirus software, you can use [Avira for
free](https://www.avira.com/en/free-antivirus-mac). If, like me, you want to
install everything possible via CLI, just do this:

```
brew cask install avira-antivirus
```

Then follow the on-screen instructions.

Note: There is no brew installer for JunOS Pulse, if that's what your company
uses. You'll need to download that from your company and manually install it.


### Install GitHub CLI

The [GitHub CLI tool](https://hub.github.com/) is handy to automate some tasks, and
especially for calling the GitHub APIs from the CLI.

```
brew install hub
hub api
# Follow the prompts to log in
```

Now you can do things like:

```
hub api --paginate 'user/repos?affiliation=owner
```
