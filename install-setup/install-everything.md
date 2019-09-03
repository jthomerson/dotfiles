# Installation for a New Machine

Note that many of these steps were from this great writeup:
https://dev.to/therealdanvega/new-macbook-setup-for-developers-2nma


## Prepare for Installations

### Get Critical Files From Another Machine

If you already have another Mac set up somewhere and you have critical secure
files (e.g. `~/.ssh` with your keys, or `~/.aws` with credentials and/or role
configurations), you should probably rsync them from that machine to this one.

For example:

```
rsync -a --progress OTHER_MACHINE:~/.ssh ~/
rsync -a --progress OTHER_MACHINE:~/.aws ~/
```


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


## Install Essentials

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
# Note that you need to run this as a user who can sudo
sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
```

And then make it your shell. You should run this as your primary user, as well as any
other user that you want to use this updated version of bash as their shell (for example,
if you have a second user that can sudo, you may want to run it as that user as well).

```
chsh -s /usr/local/bin/bash
```

If your user account does not have `sudo` permissions, you can also `Cmd+,` in
Terminal and change the setting from "Shells open with: Default login shell" to
"Command" and enter `/usr/local/bin/bash`.


### Install git

```
brew install git
```

Now configure it:

```
git config --global user.email "jeremy@thomersonfamily.com"
git config --global user.name "Jeremy Thomerson"
```


### Install bash completion

See also:

 * https://salsa.debian.org/debian/bash-completion
 * https://github.com/bobthecow/git-flow-completion/wiki/Install-Bash-git-completion


```
brew install bash-completion
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

**Now start a new terminal session to inherit those changes.**


## Install Other Apps and Tools

### Install miscellaneous tools

Install some miscellaneous tools that you might like:

```
brew install \
   wget \
   awscli \
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
   remind101/formulae/assume-role \
   reattach-to-user-namespace
```

Some tools require modifications to your `PATH` environment variable. Each of the tools I
recommend installing in the next code block requires such a change. However, you will not
need to manually make any changes to your `PATH` environment variable because the
recommended changes are already made in [../bash/path.sh](../bash/path.sh). Every attempt
has been made to make those changes safe even if you don't install these tools.

```
brew install coreutils
brew install grep
brew install openssl
brew install python
brew install ffmpeg
```

### Install cask-based (many GUI) tools

Many GUI apps (i.e. Google Chrome, Firefox, Sublime, etc) can be installed by
`brew` from _casks_. According to [brew](https://brew.sh), a cask is for:

> "To install, drag this icon..." no more. `brew cask` installs macOS apps,
> fonts and plugins and other non-open source software.

Note, though, that many casks install into your `/Applications` directory. That
will require administrator access. So, if you are running brew as a *non-admin*
user (someone who can not `sudo`), then you have two options:

   * **Option 1:** Install these applications to your user's `~/Applications`
     directory. To configure brew to always do this for all cask installs, do
     this:

        ```
        echo 'export HOMEBREW_CASK_OPTS="--appdir=~/Applications"' >> ~/.bash_profile
        ```

      * If you do add the `HOMEBREW_CASK_OPTS` to your Bash profile, you need
        to start a new terminal session to inherit those changes before
        proceeding.
      * Note that some applications don't seem to work well with this method:
	 * 1Password X (Beta) has issues staying connected to your browser, and
	   [incessantly complains][1pwx] about not being installed in
           `/Applications`.
	 * `maxtex` will *not* (cask) install unless you're an admin because it
	   asks you to authenticate for a `sudo` command part way through its
           installation.
   * **Option 2:** Temporarily make your user an admin (so that your user can
     `sudo`), or run cask installations from a second user that can `sudo`.
      * Note: when you make the user an admin, System Preferences will tell you that you
	have to restart to make it go into effect. You actually don't. However, you will
	need to later log out, log in as another user so that you can remove admin
        privileges from your primary user.

**At this time, I recommend option two if you have the ability to do it.** When I was
using option one, most applications behaved okay, but I had a lot of problems with
1Password and Google Chrome interactions. I suspect this was primarily on the part of
1Password (I was / am on X Beta), but I couldn't put up with those issues and decided to
install the apps where they expected to live - in the `/Applications` directory, which
required using a user that could sudo.

[1pwx]: https://twitter.com/jthomerson/status/1158830446437982208


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
brew cask install sketchup
brew cask install google-cloud-sdk
brew cask install mactex
brew cask install vlc
brew tap homebrew/cask-versions && brew cask install 1password-beta
```

#### Python-Based (Non-Brew) Tools:

```
pip install yq
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
	<key>RunAtLoad</key>
	<true/>
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


### Install Global NPM Modules

```
npm install --global grunt-cli \
   serverless \
   jwt-cli
```


### Install PDF Toolkit (pdftk)

Run `./install-pdftk.sh`


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
hub api --paginate 'user/repos?affiliation=owner'
```


### Configure iMessage

   * Sign in with your iCloud account on iMessage for Mac.
   * Go to Settings > Messages on your iPhone and tap on Text Messages Forwarding.
   * Enable forwarding to the computer(s) you want regular (non-iMessage) text messages
     forwarded to.


### Sync Google Contacts With OSX

   * Open the Contacts app
   * Select Contacts > Add Account from the menu
   * Click the Google option, and follow the prompts to connect


### Configure iTerm2

Once you install [iTerm2](https://www.iterm2.com/), you will probably want to configure it
to allow for jumping / deleting back a word (`Opt+Arrows`, `Opt+Delete`), or a line
(`Cmd+Arrows`, `Cmd+Delete`). There's a great [Stack Overflow
answer](https://stackoverflow.com/a/22312856) on how to do this. But, since I've already
done that and saved my iTerm configuration into this repo, here's the steps to use the
committed config:

   * Open iTerm settings
   * Check the "Load preferences from a custom folder or URL" option (under "General > Preferences")
   * Browse to / enter the path (e.g. "~/code/jthomerson/dotfiles/app-settings/iterm2")


### Install JDK Version and Eclipse

To install the latest versions of Java (OpenJDK) and Eclipse:

```
brew cask install java
brew cask install eclipse-jee
brew install maven
```

Note that this installs the latest version of Java. Presumably you can use the
compatibility flags to determine which version you're targeting (rather than installing
additional older versions).

## Mac App Store Apps

I also install these, which I've purchased on the App Store:

   * [Pixelmator](https://apps.apple.com/us/app/pixelmator/id407963104?mt=12)
