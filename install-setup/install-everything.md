# Installation for a New Machine

Note that many of these steps were from this great writeup:
https://dev.to/therealdanvega/new-macbook-setup-for-developers-2nma


## Install Some Initial GUI Apps

These apps will help get things going.

   * [Firefox Developer Edition](https://www.mozilla.org/en-US/firefox/developer/)
      * Or, [Firefox](https://www.mozilla.org/en-US/firefox/new/)
      * Make it the default browser.
   * [1Password](https://1password.com/downloads/mac/)
   * [Sublime Text](https://www.sublimetext.com/)
   * [Tailscale](https://tailscale.com/download)


## Prepare for Installations

### Set up Xcode Command Line Tools Package

```
xcode-select --install
```

If you get an error that says "Can't install the software" you can go to
<https://developer.apple.com/downloads/index.action> and download the tools and install
them manually.


### Install Homebrew

**Note that this script must be run with a user that can `sudo`.**

See [brew.sh](https://brew.sh/) for the latest command, which may be:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

At this point you should be set up and able to install packages using Homebrew
as your primary user.


## Install and Configure WezTerm

Now, install [WezTerm][wezterm] using Brew.

```
brew install --cask wezterm
```

[wezterm]: https://wezterm.org/index.html


### Install a Nerd Font

WezTerm (and Starship) need a [Nerd Font](https://www.nerdfonts.com/) for icons and
glyphs to render correctly.

```
brew install --cask font-comic-shanns-mono-nerd-font
```

Then set it as the font in `~/.config/wezterm/wezterm.lua`.


### Grant WezTerm Full Disk Access

Using System Preferences, grant full disk access to WezTerm.


### Configure WezTerm

Link the config from the dotfiles repo:

```
mkdir -p ~/.config/wezterm
ln -sf ~/code/jthomerson/dotfiles/app-settings/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
```


## Install Rectangle

[Rectangle app](https://github.com/rxhanson/Rectangle) is the replacement for
[Spectacle](https://www.spectacleapp.com/). It allows you to easily move windows
around with keyboard shortcuts.

```
brew install rectangle
```

Then open the app and configure your settings. I use Spectacle defaults because
I used Spectacle for so long that I have muscle memory with those settings.

To restore settings from another machine, copy `RectangleConfig.json` from
`~/Downloads` (or wherever you backed it up) into Rectangle's preferences import.


## Configure Terminal Apps

### Configure Zsh

macOS ships with zsh as the default shell. The dotfiles live in `zsh/rc.sh`.

#### Install zsh plugins

```
brew install zsh-syntax-highlighting zsh-autosuggestions starship
```

#### Start Your zsh Profile

Pick a "friendly name" for this machine — it appears in the prompt where your
hostname would normally be.

Create (or replace) `~/.zshrc` with the following, substituting your machine's
friendly name:

```zsh
FRIENDLYHOSTNAME="mym1"
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
[ -f /opt/homebrew/bin/brew ] && BREW="/opt/homebrew/bin/brew" || BREW="/usr/local/bin/brew"
eval "$($BREW shellenv)"
export PATH="$HOME/.local/bin:$PATH"

HISTFILE=~/.zsh_history

source ~/code/jthomerson/dotfiles/zsh/rc.sh
```

`rc.sh` handles everything else: PATH additions, aliases, functions, git, AWS
helpers, Starship prompt, syntax highlighting, and autosuggestions.

#### Configure Starship

Link the Starship config from the dotfiles repo:

```
mkdir -p ~/.config
ln -sf ~/code/jthomerson/dotfiles/app-settings/starship/starship.toml ~/.config/starship.toml
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
rsync -a --progress OTHER_MACHINE:~/.config/gh ~/.config/
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
git config --global core.excludesfile ~/code/jthomerson/dotfiles/app-settings/git/.gitignore-global
```



### Install This Repo

This repo has all the necessary dotfiles in it.

```
mkdir -p ~/code/jthomerson
pushd ~/code/jthomerson
git clone git@github.com:jthomerson/dotfiles.git
```


## Install Other Apps and Tools


### Install Miscellaneous Tools

Install some miscellaneous tools that you might like:

```
brew install \
   rustup \
   1password-cli \
   parallel \
   wget \
   awscli \
   telnet \
   ag \
   jq \
   colordiff \
   duckdb \
   db-browser-for-sqlite \
   dbeaver-community \
   helix \
   tree \
   corkscrew \
   ccrypt \
   hugo \
   imagemagick \
   ohcount \
   tmux \
   thrift \
   yt-dlp \
   asciinema \
   graphviz \
   reattach-to-user-namespace \
   pandoc \
   vlc \
   postman

brew tap common-fate/granted
brew install granted

brew tap hashicorp/tap
brew install hashicorp/tap/vault
```

Some tools require modifications to your `PATH` environment variable. Each of the tools I
recommend installing in the next code block requires such a change. However, you will not
need to manually make any changes to your `PATH` environment variable because the
recommended changes are already made in [../zsh/path.sh](../zsh/path.sh). Every attempt
has been made to make those changes safe even if you don't install these tools.

```
brew install \
   coreutils \
   gnu-sed \
   grep \
   openssl@1.1 \
   python \
   ffmpeg
```

When I was setting this up in 2025-11, I switched from `pip install yq` to
`brew install yq`. We'll see if this was a good idea or not.

```
brew install yq
```


### Install `uv` for Python / MCP Servers

Get current command from [Astral](https://docs.astral.sh/uv/getting-started/).
Will look like this probably:

```
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Then you can install Python (e.g. `uv python install 3.10`) and other tools.


### Install Claude Code

Get the current install command from [claude.ai/code](https://claude.ai/code).
Will look like this probably:

```
curl -fsSL https://claude.ai/install.sh | bash
```

This installs to `~/.local/bin/claude`, which is already on `PATH` via `~/.zshrc`.


### Install More GUI Apps

   * [Remember the Milk](https://www.rememberthemilk.com/services/)
   * [Keyboard Maestro](https://www.keyboardmaestro.com/main/) ([old versions](https://files.stairways.com/))
   * [Notion](https://www.notion.com/desktop)
   * [Google Chrome](https://www.google.com/chrome/)
   * [Visual Studio Code](https://code.visualstudio.com/)
   * [Docker Desktop](https://www.docker.com/products/docker-desktop/)
   * [Balsamiq Wireframes](https://balsamiq.com/wireframes/balsamiq.com/wireframes/desktop/)
   * [Google Drive](https://workspace.google.com/products/drive/#download)


### Configure Pushover.net Push Notifications

I use the awesome <https://pushover.net/> to send push notifications to my mobile devices
from shell scripts. For example, if you have a long-running script and need to know that
it's done, you can use:

```
./some-long-running-script.sh; pushover "Script done with exit code $?"
```

Or, if you have a script that monitors some resource for changes, you could have it send
you a push notification each time it finds a change.

To configure it:

   1. Sign up for an account at <https://pushover.net/>
   2. Install the app on a mobile device and login
   3. At the bottom of [this page](https://pushover.net/) create an app called "Shell" (or
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
   5. Then you can send messages like this: `pushover "This is a test"`


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
<https://github.com/nvm-sh/nvm#installation-and-update>


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

```
dotfiles
./install-setup/install-pdftk.sh
```


### Install GitHub CLI

#### Install the Old GitHub Tool (`hub`)

The [GitHub CLI tool](https://hub.github.com/) is handy to automate some tasks, and
especially for calling the GitHub APIs from the CLI. It's used by my code-repo
automation scripts, but eventually needs to be updated to use the newer tool
(`gh`, below).

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

#### Install the New GitHub Tool (`gh`)

```bash
brew install gh
gh auth login
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


## Mac App Store Apps

I also install these, which I've purchased on the App Store:

   * [Pixelmator Pro](https://apps.apple.com/us/app/pixelmator-pro/id1289583905?mt=12)
   * Final Cut Pro, et al - go to the purchases section of the App Store app and download

And these free apps:

   * [OneDrive](https://apps.apple.com/us/app/onedrive/id823766827?mt=12)
   * [Microsoft OneNote](https://apps.apple.com/us/app/microsoft-onenote/id784801555?mt=12) (free)
   * [WhatsApp](https://apps.apple.com/us/app/whatsapp-messenger/id310633997)
   * Microsoft Office apps
   * [Skitch](https://apps.apple.com/us/app/skitch-snap-mark-up-share/id425955336?mt=12)
   * [Slack](https://apps.apple.com/us/app/slack-for-desktop/id803453959?mt=12)
