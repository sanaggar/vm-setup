# vm-setup

A personal provisioning script for a fresh **Debian 13 (Trixie)** virtual
machine. It installs the base development tools I use on every VM, so I don't
have to reinstall everything by hand each time.

## What it installs

- **System**: full `apt update && upgrade`
- **CLI tools**: wget, curl, git, vim, tmux, htop, tree, zip/unzip, net-tools
- **Build toolchain**: build-essential (gcc, make…)
- **Network**: wireshark
- **Docker** (official repository) + current user added to the `docker` group
- **Google Chrome** (official .deb)
- **Visual Studio Code** (Microsoft repository)
- **zsh + oh-my-zsh**, set as the default shell, with the `git`,
  `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins

The script is **idempotent**: re-running it is safe and skips what is already
installed.

## Usage

On a fresh Debian 13 machine, one command:

    wget -qO- https://raw.githubusercontent.com/sanaggar/vm-setup/main/vm-setup.sh | sh

Or, to read it before running it (recommended for any remote script):

    wget https://raw.githubusercontent.com/sanaggar/vm-setup/main/vm-setup.sh
    less vm-setup.sh
    sh vm-setup.sh

After it finishes, **log out and back in** (to activate zsh and the `docker`
group), then check:

    docker run --rm hello-world
    echo $SHELL        # /usr/bin/zsh

## Notes

- Tested on Debian 13 GNOME.
- Requires `sudo` rights (the installing user must be in the `sudoers` group).
- No secrets are stored in this script; it only runs public installers.
