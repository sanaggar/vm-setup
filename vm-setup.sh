#!/bin/sh
# Personal VM provisioning - fresh Debian 13 (trixie).
# Installs base dev tools, Docker, Chrome, VS Code, and zsh + oh-my-zsh.
# Idempotent: safe to re-run. Usage:  sh vm-setup.sh
# After it finishes: log out and back in (activates the 'docker' group and zsh).
set -e

# --- 1. system update -------------------------------------------------------
sudo apt update
sudo apt upgrade -y

# wireshark asks interactively whether non-root users may capture; pre-answer it
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections

# --- 2. base tools ----------------------------------------------------------
sudo apt install -y \
    wget curl ca-certificates gnupg \
    git vim zsh terminator \
    build-essential \
    htop tree tmux unzip zip \
    net-tools iproute2 \
    wireshark

# --- 3. Docker (official repo) ----------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg \
        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
    sudo usermod -aG docker "$USER"
fi

# --- 4. Google Chrome (.deb from Google) ------------------------------------
if ! command -v google-chrome >/dev/null 2>&1; then
    tmp=$(mktemp -d)
    wget -O "$tmp/chrome.deb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y "$tmp/chrome.deb"
    rm -rf "$tmp"
fi

# --- 5. VS Code (Microsoft repo) --------------------------------------------
if ! command -v code >/dev/null 2>&1; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
        | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
    sudo apt install -y code
fi

# --- 6. oh-my-zsh + 2 plugins (non-interactive) -----------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
# enable the plugins in .zshrc
sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
# make zsh the default shell
sudo chsh -s "$(which zsh)" "$USER"

echo
echo "=== vm-setup.sh done ==="
echo "Log out and back in to activate zsh and the docker group."
echo "Check (run each separately): docker run --rm hello-world   then   echo \$SHELL"
