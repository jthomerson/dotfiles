# Jeremy Thomerson's Dotfiles and Computer Setup

I need to write more documentation about what this repo contains, but at a high-level it
is my collection of "dot files" that I use on all my machines, as well as a setup guide
for how to install and configure new machines.

Where to start:

   * My "[install everything][install]" playbook
   * My [bash profile](./bash/profile.sh)

## Code Repo Maintenance Script

Also, because I clone so many repos from various sources - GitHub organizations I'm a part
of, my personal repos on GitHub, others on GitLab (self-hosted and their SAAS), etc, I
have a script that will automatically clone all of those repos into the place where I
expect them to appear. Anytime the script is run, it will see if there are new repos and
if so, automatically clone them, as well as running `git fetch --all` in all the existing
repos. This greatly simplifies my life as I can safely run this script at any time and
know that I have everything I need on my machine; this is a huge help if I'm leaving for a
trip and want to make sure I have all my repos on my laptop, and all recent branches
pulled.

That script lives at [./scripts/update-code-folder.sh](./scripts/update-code-folder.sh).
It expects a configuration file at `~/code/.code.json` (because I store all my repos at
`~/code`), but you can also pass it a path to a configuration file as the first argument
to the script, e.g. `./scripts/update-code-folder.sh ~/my-code-config.json`.

### Code Repo Maintenance Requirements

You must have [jq][jq] and [hub][hub] (GitHub's CLI tool) installed for the script to
work. Both of those are installed as part of my [install everything docs][install].

### Code Config File Format

Here's an example of the format the config file needs to take:

```json
{
   "gitlab-work": {
      "dir": "~/code/gitlab",
      "type": "gitlab",
      "baseURL": "https://mycompany.com/gitlab/api/v4",
      "credentials": "~/.creds/gitlab",
      "group": "150",
      "developGroup": "23"
   },
   "github-personal": {
      "dir": "~/code/jthomerson",
      "type": "github",
      "query": "user/repos?affiliation=owner"
   },
   "github-silvermine": {
      "dir": "~/code/silvermine",
      "type": "github",
      "query": "orgs/silvermine/repos"
   }
}
```

Config file notes:

   * **General**:
      * `dir` is the directory you want those repos cloned to
      * `type` is the type of repo source - either `github` or `gitlab` right now
   * **GitHub**:
      * `query` is the query to run to list the repos you want. This is whatever you would
        pass to the [hub api](https://hub.github.com/hub-api.1.html) command to paginate a
        list of projects. Two examples are given above - for your personal repos, and for
        some organization that you are a part of. Note that the organization name will
        currently be deduced from the query so that it can be used as part of the clone
        command, e.g. `hub clone "${ORG_NAME}/${REPO_NAME}"`, so if you're trying to clone
        repos from an organization and don't use the `orgs/{ORG_NAME}/repos` format of
        query, you may need to submit a pull request to update my script to work with that
        format, or accept a separate configuration attribute for the organization name or
        something.
   * **Gitlab**:
      * `baseURL`: The URL to the API for your Gitlab instance.
      * `credentials`: The path to a file that contains your Gitlab API key (also known as
        "Personal Access Tokens"). The file should contain just the text of the key /
        personal access token (with a [trailing newline][newline], but not an empty final
        line).
      * `group`: The (numeric) ID of the group that contains the repos you want to clone.
        Will clone all the repos in that group.
      * `developGroup`: This is a bit special and has to do with the way I use one
        instance of Gitlab that I work with. In this case we use `origin` to point to a
        canonical set of repos, but each of those repos also has a separate fork that
        lives in a separate Gitlab group. Our feature branches are pushed to the fork so
        that we can rewrite history on them as much as we want, but then they're
        eventually merged into the long-lived (i.e. `master`) branch(es) that live on the
        true `origin`. That avoids our ticketing system getting associations to all the
        commits that we initially put into the feature branch before the code review; we
        only want our tickets referencing commits that land in the official branches that
        are hosted on the origin. Basically, if you want a separate origin, you can put
        the (numeric) group ID of the group that has your fork, and the script will look
        for another repo that shares the same name as the official origin repo within the
        "developGroup" group, and if it's found, it will add a `develop` origin for that
        repo in addition to the standard `origin` origin. Confused? Great; just leave this
        paramter blank and forget you read this paragraph.

[jq]: https://stedolan.github.io/jq/
[hub]: https://github.com/github/hub
[install]: ./install-setup/install-everything.md
[newline]: https://github.com/silvermine/silvermine-info/blob/master/coding-standards.md#miscellaneous
