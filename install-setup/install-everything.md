# Installation for a New Machine

Note that many of these steps were from this great writeup:
https://dev.to/therealdanvega/new-macbook-setup-for-developers-2nma


## Prepare for Installations

### Change Your Shell to Bash

Starting with Catalina, macOS switched to using `zsh` as the default shell.
Since I prefer `bash`, I switch it back before progressing.

**Note: This may not be necessary, as in more recent versions of macOS, the terminal gives
you a heads-up that `zsh` is their new preference, but makes you switch to it yourself.**

```
chsh -s /bin/bash
```

**Now restart Terminal**


### Set up Xcode Command Line Tools Package

```
xcode-select --install
```

If you get an error that says "Can't install the software" you can go to
https://developer.apple.com/downloads/index.action and download the tools and
install them manually.


### Install Homebrew

**Note that this script must be run with a user that can `sudo`.**

See [brew.sh](https://brew.sh/) for the latest command, which may be:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Alternate Installation as Non-Admin

If the user you ran the previous command as is not your primary user (i.e. it
was a user who could `sudo`, but your day-to-day primary user can not `sudo`),
but you want your primary user to be able to install packages with Homebrew,
you need to also follow these steps:

```
# As admin user:
sudo chown -R YOURUSERNAMEHERE /usr/local/*

# Then, switch back to your primary user, perhaps by running `exit`. Then:
[ -f /opt/homebrew/bin/brew ] && BREW="/opt/homebrew/bin/brew" || BREW="/usr/local/bin/brew"
"${BREW}" update --force
```

At this point you should be set up and able to install packages using Homebrew
as your primary user.


## Configure Bash

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
sudo bash -c 'echo /opt/homebrew/bin/bash >> /etc/shells'
```

And then make it your shell. You should run this as your primary user, as well as any
other user that you want to use this updated version of bash as their shell (for example,
if you have a second user that can sudo, you may want to run it as that user as well).

```
chsh -s /opt/homebrew/bin/bash
```

If your user account does not have `sudo` permissions, you can also `Cmd+,` in
Terminal and change the setting from "Shells open with: Default login shell" to
"Command" and enter `/opt/homebrew/bin/bash`.


### Start Your Bash Profile

Let's get your Bash profile started. First, pick a "friendly name" for this
machine. This will appear in the terminal where your hostname would normally
appear. We will put the friendly name as the first name of your bash profile.
We'll also make a backup of any existing bash profile in case you have one.

```
cat ~/.bash_profile > ~/.bash_profile.$(date +%s).bak
echo 'FRIENDLYHOSTNAME="mym1"' > ~/.bash_profile
```

Now we want to reset the PATH variable each time your profile is reset. We do
this so that you start from a clean slate instead of just appending (or
prepending) new paths to your already-modified PATH variable. This line will
reset it to the Mac default before proceeding.

```
echo 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"' >> ~/.bash_profile
```

Now we want to allow Homebrew to add its variables to the profile each time our
profile is reset. This is especially needed because on ARM (M1) machines,
Homebrew installs to `/opt/homebrew` whereas on x86 installs to `/usr/local`. In
order to make our dotfiles work with both installations, we need the
`HOMEBREW_PREFIX` environment variable, which this script will configure.

```
[ -f /opt/homebrew/bin/brew ] && BREW="/opt/homebrew/bin/brew" || BREW="/usr/local/bin/brew"
echo 'eval "$('${BREW}' shellenv)"' >> ~/.bash_profile
```

Finally, we want to use the profile from our dotfiles to configure our
environment, so we add this line to our local profile.

```
echo 'source ~/code/jthomerson/dotfiles/bash/profile.sh' >> ~/.bash_profile
```

**Now start a new terminal session to inherit those changes.**


## Get Critical Files From Another Machine

If you already have another Mac set up somewhere and you have critical secure
files (e.g. `~/.ssh` with your keys, or `~/.aws` with credentials and/or role
configurations), you should probably rsync them from that machine to this one.

For example:

```
rsync -a --progress OTHER_MACHINE:~/.ssh ~/
rsync -a --progress OTHER_MACHINE:~/.creds ~/
rsync -a --progress OTHER_MACHINE:~/.aws ~/
rsync -a --progress OTHER_MACHINE:~/.granted ~/
rsync -a --progress OTHER_MACHINE:~/.config/hub ~/.config/
```


## Install Essentials


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


### Install This Repo

This repo has all the necessary dotfiles in it.

```
mkdir -p ~/code/jthomerson
pushd ~/code/jthomerson
git clone git@github.com:jthomerson/dotfiles.git
```


## Install Other Apps and Tools

### Install and Configure iTerm2

First, install [iTerm2](https://www.iterm2.com/).

```
brew install iterm2
```

Once you install [iTerm2](https://www.iterm2.com/), you will probably want to configure it
to allow for jumping / deleting back a word (`Opt+Arrows`, `Opt+Delete`), or a line
(`Cmd+Arrows`, `Cmd+Delete`). There's a great [Stack Overflow
answer](https://stackoverflow.com/a/22312856) on how to do this. But, since I've already
done that and saved my iTerm configuration into this repo, here's the steps to use the
committed config:

   * Open iTerm settings
   * Check the "Load preferences from a custom folder or URL" option (under "General > Preferences")
   * Browse to / enter the path (e.g. "~/code/jthomerson/dotfiles/app-settings/iterm2")

**Now kill Terminal and from here on out, use iTerm2.**


### Install Rectangle

[Rectangle app](https://github.com/rxhanson/Rectangle) is the replacement for
[Spectacle](https://www.spectacleapp.com/). It allows you to easily move windows
around with keyboard shortcuts.

```
brew install rectangle
```

Then open the app and configure your settings. I use Spectacle defaults because
I used Spectacle for so long that I have muscle memory with those settings.


### Install Miscellaneous Tools

Install some miscellaneous tools that you might like:

```
brew install \
   parallel \
   wget \
   awscli \
   telnet \
   ag \
   jq \
   colordiff \
   duckdb \
   dbeaver-community \
   tree \
   corkscrew \
   ccrypt \
   hugo \
   imagemagick \
   ohcount \
   tmux \
   thrift \
   youtube-dl \
   asciinema \
   graphviz \
   reattach-to-user-namespace \
   pandoc

brew tap common-fate/granted
brew install granted
```

Some tools require modifications to your `PATH` environment variable. Each of the tools I
recommend installing in the next code block requires such a change. However, you will not
need to manually make any changes to your `PATH` environment variable because the
recommended changes are already made in [../bash/path.sh](../bash/path.sh). Every attempt
has been made to make those changes safe even if you don't install these tools.

```
brew install coreutils
brew install gnu-sed
brew install grep
brew install openssl@1.1
brew install python
brew install ffmpeg
```

### Install GUI (Previously Cask) Tools

In earlier versions of this document, I suggested installing GUI apps (i.e.
Google Chrome, Firefox, Sublime, etc) using Brew. My reason for wanting to do
so was that it optimized multi-machine consistency - everything was installed
the same way. But over time, I found that the Brew-based installations often
caused problems. Perhaps that was because the Brew install ended up configuring
something slightly different than a normal "download DMG and install" ([for
example, 1Password][1pwx]). Or, those problems might have been caused by
corporate policies since I was trying to keep my personal and corporate
machines similar. In any event, I've decided to just download the following
apps from the downloaded install packages on their websites, or from the App
Store:

[1pwx]: https://twitter.com/jthomerson/status/1158830446437982208

   * [1Password](https://1password.com/downloads/mac/)
   * [Sublime Text](https://www.sublimetext.com/)
   * [Google Chrome](https://www.google.com/chrome/)
   * [Firefox](https://www.mozilla.org/en-US/firefox/new/)
      * Or, [Firefox Developer Edition](https://www.mozilla.org/en-US/firefox/developer/)
   * [Visual Studio Code](https://code.visualstudio.com/)
   * [Docker Desktop](https://www.docker.com/products/docker-desktop/)
   * [Skitch](https://evernote.com/products/skitch)
   * [Slack](https://slack.com/downloads/mac)
   * [VLC](https://www.videolan.org/vlc/download-macosx.html)
   * [Balsamiq Wireframes](https://balsamiq.com/wireframes/desktop/)
   * [SQLite DB Browser](https://sqlitebrowser.org/)


[GraphiQL desktop](https://github.com/skevy/graphiql-app) should still be
installed via Brew:

```
brew install graphiql
```


### Install Python-Based (Non-Brew) Tools:

```
pip install yq
pip install awsume
pip install awsume-console-plugin
```

### Upgrade and Configure Vim

Vim installs Ruby, which requires additional entries in your profile to update
your `PATH` environment if you want to use the Homebrew-installed Ruby (see
[../bash/path.sh](../bash/path.sh)).

```
brew install vim
```

### Configure Pushover.net Push Notifications

I use the awesome <https://pushover.net/> to send push notifications to my mobile devices
from Bash scripts. For example, if you have a long-running script and need to know that
it's done, you can use:

```
./some-long-running-script.sh; pushover "Script done with exit code $?"
```

Or, if you have a script that monitors some resource for changes, you could have it send
you a push notification each time it finds a change.

To configure it:

   1. Sign up for an account at <https://pushover.net/>
   2. Install the app on a mobile device and login
   3. At the bottom of [this page](https://pushover.net/) create an app called "Bash" (or
      whatever) to get an API key
   4. Download and configure this script: https://github.com/akusei/pushover-bash

      ```
      cd ~/whereveryoustoreyourcode/
      git clone git@github.com:akusei/pushover-bash.git
      cd pushover-bash
      mkdir ~/.pushover
      cp pushover-config ~/.pushover/
      ```

      Edit `~/.pushover/pushover-config` to add the API key and user key (that's all you
      need - the rest is just defaults).

      Then I make a symlink in /usr/local/bin so I can just use "pushover" anywhere from
      any directory:

      ```
      sudo ln -s ~/whereveryoustoreyourcode/pushover-bash/pushover.sh /usr/local/bin/pushover
      ```
   5. Then you acn send messages like this: `pushover "This is a test"`


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
# If you are running this on an M1 Mac and you need to use versions of Node prior to 15.3
# (which is the first version that supported the arm64 architecture), you will need to
# first start a terminal session using the `arch` tool to run the terminal in i386. Do
# that by following this step first:
arch -x86_64 zsh

# That will start a zsh shell in i386 (bash isn't universal, so can't be started the same
# way). Then when you run the normal installation (next command), everything will run
# fine.

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
```

Then you'll want to at least set up your default node and NPM versions, e.g.:

```
nvm install 12
```

Installing a version of Node that did not support ARM will result in a long installation
process, as NVM will need to compile Node.

When that's done, if you want to confirm that your older version of Node is running as an
Intel architecture (using Rosetta, which it will need to do), you can run this command:

```
nvm use 12
node -p process.arch
```

If it prints `arm64`, then Node is running on the ARM architecture, which it doesn't
support. See the [NVM homepage](https://github.com/nvm-sh/nvm#macos-troubleshooting)
troubleshooting section for more information.


### Install Global NPM Modules

```
npm install --global grunt-cli \
   serverless \
   jwt-cli \
   @vue/cli \
   http-server \
   yo
```


### Install PDF Toolkit (pdftk)

Run `./install-pdftk.sh`



### Install Antivirus

**NOTE: This section is out-of-date. I don't necessarily recommend Avira at
this time, and don't recommend installing GUI apps via Brew (see above).**

If you have a need (e.g. corporate policy for your work VPN, etc) to install an
antivirus software, you can use [Avira for
free](https://www.avira.com/en/free-antivirus-mac). If, like me, you want to
install everything possible via CLI, just do this:

```
brew install avira-antivirus
```

Then follow the on-screen instructions.

Note: There is no brew installer for JunOS Pulse, if that's what your company
uses. You'll need to download that from your company and manually install it.


### Install GitHub CLI

The [GitHub CLI tool](https://hub.github.com/) is handy to automate some tasks, and
especially for calling the GitHub APIs from the CLI.

Before logging in, you'll need to create a [personal access token][hub-pat]. Give it
repo and workflow access. When prompted for your password, enter the token instead.

[hub-pat]: https://github.com/settings/tokens

```
# make sure that ~/.config/hub was copied from another computer or generated
# with a valid personal access token
brew install hub
hub api --paginate 'user/repos?affiliation=owner'
```

**NOTE:** This is the **old** `hub` tool. The newer tool is `gh`. See:

   * New: https://cli.github.com/
   * Old: https://github.com/github/hub
   * Comparison: https://github.com/cli/cli#comparison-with-hub
   * More detailed why: https://github.com/cli/cli/blob/trunk/docs/gh-vs-hub.md


### Configure iMessage

   * Sign in with your iCloud account on iMessage for Mac.
   * Go to Settings > Messages on your iPhone and tap on Text Messages Forwarding.
   * Enable forwarding to the computer(s) you want regular (non-iMessage) text messages
     forwarded to.


### Sync Google Contacts With OSX

   * Open the Contacts app
   * Select Contacts > Add Account from the menu
   * Click the Google option, and follow the prompts to connect



### Install JDK Version and Eclipse

**NOTE: This section about Java is out-of-date. Need to update it the next time
I install Java on a new machine.**

To install the latest versions of Java (OpenJDK) and Eclipse:

```
brew cask install java
brew cask install eclipse-jee
brew install maven
```

Note that this installs the latest version of Java. Presumably you can use the
compatibility flags to determine which version you're targeting (rather than installing
additional older versions).

#### Alternative Java Installation

I need to figure out which of these two methods (above or this one) is better, but for now
I'm just documenting both.

```
brew install openjdk
```


## Manual Installs

These apps you will want to download and install from their websites. I've previously
tried using the casks for some of these, but at some point had problems with them and
decided it was better to just use the official installers.

   * [Remember the Milk](https://www.rememberthemilk.com/services/)
      * On computers with restrictive IT policies, it may be best to install this in
        `~/Applications` so that it has permissions to update itself. Otherwise, I was
        constantly nagged with permissions prompts to install updates.
   * [1Password X](https://1password.com/downloads/mac/)
      * And the [Chrome plugin][1pass-chrome]
      * And the [Firefox plugin][1pass-firefox]
   * [Keyboard Maestro](https://www.keyboardmaestro.com/main/)
      * If you're on a computer where you cannot sync your macros through a
        file sync service, you can download a local copy of them and save them
        in the `~/.config` directory. Of course, you'll have to manually "sync"
        them when there's changes.

      ```
      mkdir ~/.config/keyboard-maestro
      mv ~/Downloads/Keyboard\ Maestro\ Macros.kmsync ~/.config/keyboard-maestro/
      ```

[1pass-chrome]: https://chrome.google.com/webstore/detail/1password-%E2%80%93-password-mana/aeblfdkhhhdcdjpifhhbdiojplfjncoa
[1pass-firefox]: https://addons.mozilla.org/en-US/firefox/addon/1password-x-password-manager/?src=search



## Mac App Store Apps

I also install these, which I've purchased on the App Store:

   * [Pixelmator Pro](https://apps.apple.com/us/app/pixelmator-pro/id1289583905?mt=12)
   * [Microsoft OneNote](https://apps.apple.com/us/app/microsoft-onenote/id784801555?mt=12) (free)
   * Final Cut Pro, et al
   * Microsoft Office apps
