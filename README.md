# Dotfiles

This repository contains a collection of [dotfiles](https://dotfiles.github.io/) and scripts used to configure and customize my OS X environment. This is an adaptation of [@hideoo's work](https://github.com/hideoo/dotfiles) from my own recipes without the fancy Dotbot implementation and with some more bash tooling around it.

## Main Features

[icasp's Prezto](https://github.com/icasp/prezto), a fork of [Prezto](https://github.com/sorin-ionescu/prezto), the configuration framework for Zsh, is used and will be automatically installed if not detected.

Using the main script `deploy.sh`, three main actions are available:

### "init"

This script will install Prezto if necessary, automatically sync all dotfiles included in this repository to their assumed location and install some useful scripts to your system.
Also backs up any existing dotfiles before deploying new version.

Included main dotfiles (can be configured in *candidates.conf*):

  * All [Prezto](https://github.com/sorin-ionescu/prezto) configuration
  * [.streamlinkrc](https://streamlink.github.io/cli.html#cli-streamlinkrc)
  * [.wgetrc](https://www.gnu.org/software/wget/manual/html_node/Wgetrc-Commands.html)
  * .curlrc
  * [.vimrc](http://www.vim.org/docs.php) (and .vim folder)
  * screenrc.d
  * editorconfig

Additional (alternative) dotfiles (can be configured in *.altcandidates.conf*):
These will only try to deploy if user matches variable "ME" in *deploy.sh*
  * [.gitconfig](https://git-scm.com/docs/git-config)
  * .aws
  * .livestreamerrc (token included in repo is bogus)
  * .streamlinkrc (token included in repo is bogus)

Included scripts:

  * `imgcat`: Script showing inline images in iTerm2 v3.

A call to "install.sh" will automatically install all your applications from Chrome to Node and configure your environment settings. This action is meant to be used after a fresh install of macOS.

### "update"

Same as init without the macOS applications and settings deployment.

### "audit"

Will perform a scan of dotfiles mentioned in configuration files and check for existence and differences.

## Secondary Features

**MAC RESET** : available in subdirectory *mac_reset* with its own README, allows to fully backup macOS data and applications preferences on an external media and restore.
Sort of a "one time" time machine for a clean reinstallation with backup really limited to personal data and key components.
See [mac_reset dedicated README](https://github.com/icasp/dotfiles/blob/master/mac_reset/README.md)

## Usage

*Note: To properly customize the scripts, you should fork this repository and modify it to fit your needs and include your own configuration. You can also copy whatever portion of script / configuration that you find useful.*

To install, just clone the repository and set the correct permissions:

```
$ git clone https://github.com/icasp/dotfiles
$ cd dotfiles
$ chmod +x deploy.sh
```

```
$ ./deploy.sh <init|update|audit>
```

## Configuration

Edit the following for dotfiles deployment :
  * `candidates.conf` (gets its contents from dotfiles root folder)
  * `.altcandidates.conf` (gets its contents from ".alt" directory in dotfiles root folder)

Look into the `setup` folder for configuration of macOS apps and settings to install :
- `xcode.sh`: Install the XCode Command Line Tools.
- `homebrew.sh`: Install [Homebrew](https://brew.sh/).
- `formulas.sh`: Install various Homebrew Formulas. This is the file to edit to define all the Formulas you want to install.
- `casks.sh`: Install [Homebrew-Cask](https://caskroom.github.io/) and various Casks. This is the file to edit to define all the Casks you want to install.
- `node.sh`: Install the latest stable version of [Node.js](https://nodejs.org) and install various global packages. This is the file to edit to define all the global packages you want to install.
- `settings.sh`: Configure all your environment settings. This is the file to edit to enable / disable some customizations and define your own.

## Resources

* [hideoo/dotfiles](https://github.com/hideoo/dotfiles)


## License

Code released under the [MIT license](https://github.com/icasp/dotfiles/blob/master/LICENSE.md).
