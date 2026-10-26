# Installation for a New Machine

Note that many of these steps were initially from this great writeup:
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


### Install a Nerd Font

WezTerm (and Starship) need a [Nerd Font](https://www.nerdfonts.com/) for icons and
glyphs to render correctly.

```
brew install --cask font-sauce-code-pro-nerd-font
```


### Install This Repo

This repo has all the necessary dotfiles in it.

```
mkdir -p ~/code/jthomerson
pushd ~/code/jthomerson
git clone git@github.com:jthomerson/dotfiles.git
```


## Install and Configure WezTerm

Now, install [WezTerm][wezterm] using Brew.

```
brew install --cask wezterm
ln -s ~/code/jthomerson/dotfiles/app-settings/wezterm ~/.config/wezterm
```

[wezterm]: https://wezterm.org/index.html


### Grant WezTerm Full Disk Access

Using System Preferences, grant full disk access to WezTerm.


### Configure WezTerm

Link the config from the dotfiles repo:

```
mkdir -p ~/.config/wezterm
ln -sf ~/code/jthomerson/dotfiles/app-settings/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
```


### Optional: Per-Machine WezTerm Overrides

`wezterm.lua` loads a per-machine `local.lua` for settings that shouldn't be shared
across computers — typically `ssh_domains` (to connect to a remote WezTerm mux) and
`unix_domains` (to host one). `local.lua` is gitignored in this repo, so each machine
gets its own copy.

Only create this file if you need one of the scenarios below. If the file is absent,
the shared config falls back to empty defaults.

The file lives at `~/.config/wezterm/local.lua` (which resolves into the gitignored
`app-settings/wezterm/local.lua` via the symlink above).

#### Connect to a Remote WezTerm Mux

Use this on a machine that should attach to a multiplexer running on another host.
Requires SSH access to that host (see "Configure SSH" below).

```lua
-- ~/.config/wezterm/local.lua
return {
   ssh_domains = {
      {
         name = 'remote-main',
         remote_address = '100.125.108.72',
         username = 'jthomerson',
         multiplexing = 'WezTerm',
         remote_wezterm_path = '/opt/homebrew/bin/wezterm',
      },
   },
}
```

Then connect with: `wezterm connect remote-main`.

`remote_wezterm_path` is important: WezTerm's SSH client runs commands via a
non-interactive shell on the remote, which does not source `~/.zshrc`, so
Homebrew's `bin` directory is not on `PATH` and `wezterm` will not be found.
Setting an absolute path sidesteps the PATH issue entirely. Adjust the path if
the remote installs WezTerm somewhere other than `/opt/homebrew/bin` (Intel
Macs use `/usr/local/bin`; Linux may use `/usr/bin`).

#### Host a WezTerm Mux

Use this on a machine that should serve a multiplexer for other machines to attach to.

```lua
-- ~/.config/wezterm/local.lua
return {
   unix_domains = { { name = 'main' } },
}
```

Then start the mux server (it runs headless and survives SSH disconnects):

```bash
wezterm-mux-server --daemonize
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
ln -s ~/code/jthomerson/dotfiles/app-settings/starship ~/.config/starship
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
   yq \
   colordiff \
   duckdb \
   db-browser-for-sqlite \
   dbeaver-community \
   helix \
   tree \
   ccrypt \
   hugo \
   imagemagick \
   chafa \
   ghostscript \
   ohcount \
   tmux \
   thrift \
   yt-dlp \
   asciinema \
   graphviz \
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
   python \
   ffmpeg
```


### Configure Helix

Link the Helix config from the dotfiles repo:

```
ln -sfn ~/code/jthomerson/dotfiles/app-settings/helix ~/.config/helix
```

Install Language Servers so Helix can provide IDE features. We install these
via Homebrew rather than `npm install -g` so they live outside any Node
version's global package space — otherwise they would disappear every time
`nvm use` switched to a project with a different `.nvmrc`.

```
brew install \
   typescript-language-server \
   rust-analyzer \
   marksman \
   yaml-language-server \
   bash-language-server
```

`vscode-json-language-server` and `vscode-eslint-language-server` (see lint
diagnostics below) both ship with VS Code's language services package:

```
npm install -g vscode-langservers-extracted
```

> Note: this one is installed via `npm -g` because Homebrew does not package
> it. It is tied to whichever Node version was active when you ran the
> command, so if you switch Node versions you may need to re-install it (or
> add `vscode-langservers-extracted` to `~/.nvm/default-packages`).

Verify Helix sees each LSP:

```
hx --health typescript
hx --health rust
```

If any show "Not found" for their language server, confirm the binary is
on your `PATH` in the same shell where you launch Helix.

#### Lint diagnostics (eslint, markdownlint)

In Helix, inline diagnostics come from language servers, not formatters. Type
errors already arrive via `typescript-language-server`. `languages.toml` adds
two more diagnostic sources:

   * **eslint** on JS/TS/Vue via `vscode-eslint-language-server` (from the
     `vscode-langservers-extracted` package installed above). It runs each
     project's own eslint, so it honors that repo's config and rules; a repo
     with no eslint config simply shows nothing.
   * **markdownlint** on Markdown via `efm-langserver`, a generic bridge that
     wraps external linters as an LSP. It runs the `markdownlint-file` wrapper
     (in the Helix config dir), which prefers each project's own
     `markdownlint-cli2` and config so diagnostics match that repo's
     `npm run markdownlint`. The `markdownlint-cli2` installed below is only a
     fallback for projects that do not vendor their own; note a global version
     may differ from a project's and report different results.

```
brew install efm-langserver markdownlint-cli2
```

> Note: if eslint diagnostics do not appear in a project, confirm the project
> uses a config style the server recognizes (flat `eslint.config.js` is
> auto-detected by recent server versions; very old `.eslintrc`-only setups
> may need `experimental.useFlatConfig` set in the `eslint` language-server
> config).

#### Markdown formatting (dprint)

`languages.toml` uses `dprint` to format Markdown (`:format` / space-mode
format). This is formatting only and is separate from the markdownlint
diagnostics above.

```
brew install dprint
```

#### Smart reflow (`par`)

The `A-r` / `A-w` keybindings in `config.toml` pipe the selection through
`par` to re-wrap long lines. Unlike Helix's built-in `:reflow`, `par` keeps
the indentation and the comment/quote prefix (`//`, `#`, `*`, `>`) on every
wrapped line, even when reflowing a single line.

```
brew install par
```

#### Vue support (`.vue` files)

Vue Language Tools has no Homebrew formula, and installing it via `npm -g` would
tie it to one Node version's global space (and break on `nvm use`). Instead we
install it into a fixed, nvm-independent prefix that `languages.toml` references
by absolute path. `/opt/homebrew` is a constant on Apple Silicon, so the same
paths work on every machine.

```sh
mkdir -p /opt/homebrew/lib/hx-lsp
cat > /opt/homebrew/lib/hx-lsp/package.json <<'JSON'
{
   "name": "hx-lsp-tools",
   "private": true,
   "dependencies": {
      "@vue/language-server": "3.2.9",
      "@vue/typescript-plugin": "3.2.9",
      "typescript": "5.9.3"
   },
   "overrides": {
      "@vue/shared": "3.5.35"
   }
}
JSON
npm install --prefix /opt/homebrew/lib/hx-lsp --save-exact
```

> The `@vue/shared` override pins around a yanked `3.5.36` that `@vue/language-core`
> requests; drop it if a future `@vue/*` release resolves cleanly.

Helix runs these in "hybrid mode": `vue-language-server` handles Vue-specific
features while `typescript-language-server` loads `@vue/typescript-plugin` to
supply goto-definition, hover, and `@/*` tsconfig path aliases for `.vue` files.
Because the prefix is fixed, no symlink or per-Node reinstall is needed; rebuild
it only to change a pinned version.

Verify Vue is wired up (both servers should show a checkmark):

```sh
hx --health vue
```

The first goto-definition in a freshly opened project is slow (tens of seconds)
while `tsserver` loads the whole project; subsequent jumps are instant.


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

#### Grilling skills

Matt Pocock's `grill-me` skill has Claude interview me in rounds of numbered questions,
each with a recommended answer, until a plan has no unstated assumptions. `grill-me` only
triggers his `grilling` skill, so link both. They come from his skills repo, which is also
a plugin, but the plugin brings dozens of other skills that overlap the ones I use:

```bash
git clone https://github.com/mattpocock/skills.git ~/code/random/mattpocock-skills
ln -sfn ~/code/random/mattpocock-skills/skills/productivity/grilling ~/.claude/skills/grilling
ln -sfn ~/code/random/mattpocock-skills/skills/productivity/grill-me ~/.claude/skills/grill-me
```

Update them with `git -C ~/code/random/mattpocock-skills pull`.

#### Status line

`bin/claude-statusline` shows the account, the model, how much of the context is used, and
how much of the 5-hour and 7-day usage limits is gone, with when each resets. The account
is the config dir's name without `.claude-`, or "Default account" for `~/.claude`. The
`statusLine` setting in my `settings.json` (in agentic-ai-workflows) runs it.


### Install and Configure Herdr

[Herdr][herdr] is the terminal workspace manager the Claude sessions run in: a workspace
per repo, with a tab per worktree or review. It runs inside WezTerm.

```bash
brew install herdr terminal-notifier
mkdir -p ~/.config/herdr
ln -sfn ~/code/jthomerson/dotfiles/app-settings/herdr/config.toml ~/.config/herdr/config.toml
herdr integration install claude
```

The Claude integration installs a hook script in `~/.claude/hooks` and registers it as a
`SessionStart` hook in `~/.claude/settings.json`, so Herdr can show each Claude session's
state. Check it with `herdr integration status`.

Notifications go through macOS (`delivery = "system"` in `config.toml`), so they work in
any terminal. Herdr sends them with `terminal-notifier`, which needs permission: allow it
in System Settings → Notifications. Herdr notifies when an agent in another tab finishes
or needs me, and `ctrl+b` then `o` jumps to that agent.

Key bindings:

   * Cmd+Arrow moves between panes. WezTerm would otherwise take the keystroke, so
     `wezterm.lua` sends Herdr's pane-focus keys (its `ctrl+b` prefix, then h/j/k/l)
     whenever the focused WezTerm pane is running Herdr. Those are Herdr's defaults; if
     you rebind them in `config.toml`, update `wezterm.lua` to match.
   * Cmd+Shift+Return zooms the Herdr pane, the same way: `wezterm.lua` sends `ctrl+b`
     then `z`.
   * Cmd+] and Cmd+[ go to the next and previous Herdr tab, the same way: `wezterm.lua`
     sends `ctrl+b` then `n` or `p`.
   * Everything else is Herdr's default. Press `ctrl+b` then `?` for the list, or run
     `herdr --default-config` to see every binding.

`review-watch` (in this repo's `bin`) runs code reviews for merge requests assigned to me
in Herdr tabs. Start it in a pane of the Reviews workspace; `review-watch --help` has the
details.

[herdr]: https://herdr.dev


### Install More GUI Apps

   * [Remember the Milk](https://www.rememberthemilk.com/services/)
   * [Keyboard Maestro](https://www.keyboardmaestro.com/main/) ([old versions](https://files.stairways.com/))
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


### Install GitHub CLI (`gh`)


```bash
brew install gh
gh auth login
```


### Install GitLab CLI (`glab`)

```bash
brew install glab
```

Authenticate with a personal access token rather than the interactive browser flow.
On a self-hosted instance the browser flow asks for an OAuth `client_id`, which works
only if a matching OAuth application is registered on the GitLab server itself.
Without one the login cannot complete. A token sidesteps that entirely.

Create a token under Preferences > Access Tokens with the `api` scope, save it to a
file, then authenticate against that host. Repeat for each instance you use:

```bash
cat ~/.creds/gitlab | glab auth login --hostname gitlab.example.com \
   --stdin --git-protocol ssh --api-protocol https
```

Piping the token via `--stdin` keeps it out of your shell history and the process
list. A few things that are easy to lose track of later:

   * The token is stored in the macOS keyring, not on disk. The config file records
     only the username and protocol settings, so it looks empty even when login
     succeeded.
   * On macOS the config lives at `~/Library/Application Support/glab-cli/config.yml`,
     not the `~/.config/glab-cli/` path that `glab auth login --help` describes.
   * Re-run the same login command whenever the token expires.
   * An abandoned login attempt leaves an empty host stanza behind, and that alone
     makes `glab auth status` report failure even when every host you actually use
     is authenticated. Delete the unused stanza.

Verify with `glab auth status`. Each authenticated host should report `Logged in`.


### Install tuicr

[tuicr][tuicr] is a terminal code review UI with vim keybindings. It reviews local
commits, GitHub pull requests, and GitLab merge requests.

```bash
brew install tuicr
ln -sfn ~/code/jthomerson/dotfiles/app-settings/tuicr ~/.config/tuicr
```

tuicr stores no credentials of its own. It shells out to `gh` for GitHub and `glab`
for GitLab, so both must be authenticated first for review submission to work, and
comments post as whichever account those CLIs are logged in as. A self-hosted GitLab
remote is only recognized as GitLab once its host is authenticated in `glab`;
otherwise tuicr falls back to treating the remote as GitHub.

Usage:

```bash
tuicr                      # review the working tree / pick commits
tuicr pr 125               # review a GitHub pull request
tuicr mr 125               # review a GitLab merge request
tuicr --stdout             # export the review as Markdown instead of copying it
```

Press `?` inside the app for keybindings. The leader key is `;`.

#### tuicr's Claude Code skill

tuicr ships a Claude Code skill that opens a review pane beside the agent (in Herdr, among
other multiplexers) and reads your comments back. Homebrew doesn't install it, so clone
the repo, check out the tag matching the installed version, and link the skill:

```bash
git clone https://github.com/agavra/tuicr.git ~/code/random/tuicr
git -C ~/code/random/tuicr checkout "v$(tuicr --version | awk '{print $2}')"
ln -sfn ~/code/random/tuicr/skills/tuicr ~/.claude/skills/tuicr
```

After `brew upgrade tuicr`, move the clone to the new version's tag the same way:

```bash
git -C ~/code/random/tuicr fetch --tags
git -C ~/code/random/tuicr checkout "v$(tuicr --version | awk '{print $2}')"
```

[tuicr]: https://github.com/agavra/tuicr


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
