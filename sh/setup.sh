### S-OS Setup Script for Arch Linux.

### (Rn this is a pretty direct port of my former Debian script, and has not been throughly tested!)

# DISCLAIMER !
# ------------
# This script is intended for setting up S-OS. It is not meant for general use... (yet?)
# Use this script at your own risk. The author takes no responsibility for any data loss 
# or system issues that may arise from its use.
# Proceed with caution!

# NOTE: If the Quicklisp or related setup fails, ensure to clean up by running:
# rm -rf ~/.lisp ~/quicklisp

# Ensure basic dependencies
sudo pacman -Syu --noconfirm sudo curl

# Install Charmbracelet tools for a more visually appealing experience
sudo pacman -S --noconfirm gum glow

# Welcome message
clear
glow <<EOM
# Welcome to the S-OS Setup Script! 🚀
This script will guide you through setting up your environment step-by-step.

Press ENTER to continue...
EOM
read

# Double confirmation with warning
glow <<EOM
**!!! WARNING: This setup might override existing configurations.**
Press ENTER again to confirm and proceed, or Ctrl+C to abort.
EOM
read

# Install and enable OpenSSH
if gum confirm --default=Yes "Install and enable OpenSSH?"; then
  sudo pacman -S --noconfirm openssh
  sudo systemctl enable sshd
  sudo systemctl start sshd
  gum format --theme=pink "green" "✅ OpenSSH installed and enabled successfully!"
fi

# Install and enable Tailscale
if gum confirm --default=Yes "Install and enable Tailscale?"; then
  sudo pacman -S --noconfirm tailscale
  sudo systemctl enable --now tailscaled
  sudo tailscale up
  gum format --theme=pink "cyan" "🔷 Tailscale installed and enabled successfully!"
fi

# Confirm and install Podman x Distrobox
if gum confirm --default=Yes "Install Podman x Distrobox?"; then
  sudo pacman -S --noconfirm podman distrobox
  gum format --theme=pink "green" "📦 Podman and Distrobox installed successfully!"
fi

# Setup essential directories
if gum confirm --default=Yes "Set up local directories?"; then
  for dir in ~/.cache ~/.config ~/.trash ~/.state ~/.mount; do
    if [ -L "$dir" ]; then
      gum format --theme=pink "red" "⚠️  $dir is already a symbolic link. Aborting setup."
      exit 1
    elif [ -d "$dir" ]; then
      timestamp=$(date +%Y-%m-%d-%H-%M-%S)
      mv "$dir" "$dir-old-$timestamp"
      gum format --theme=pink "yellow" "🔄 Moved $dir to $dir-old-$timestamp"
    fi
  done
  mkdir -p ~/.local/cache ~/.local/config ~/.local/share/Trash ~/.local/mount ~/.local/state
  ln -s ~/.local/cache ~/.cache
  ln -s ~/.local/config ~/.config
  ln -s ~/.local/share/Trash ~/.trash
  ln -s ~/.local/state ~/.state
  ln -s ~/.local/mount ~/.mount
  ln -s /mnt ~/.local/mount/set
  ln -s /media ~/.local/mount/auto
fi

# Install Zsh
if gum confirm --default=Yes "Install Zsh?"; then
  sudo pacman -S --noconfirm zsh
  mkdir ~/.zsh_custom ~/.zsh_contrib
  gum spin --spinner line --title "Installing Oh My Zsh..." -- sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  mv ~/.oh-my-zsh ~/.ohmy
  sed -i "s|export ZSH=\"$HOME/.oh-my-zsh\"|export ZSH=\"$HOME/.ohmy\"|" ~/.zshrc
  sed -i "s|ZSH_THEME=\"robbyrussell\"|ZSH_THEME=\"candy\"|" ~/.zshrc
  gum format --theme=pink "green" "🎉 Oh My Zsh installed and configured!"
fi

# Install Xorg and LightDM
if gum confirm --default=Yes "Install Xorg, xdg-utils, and slick-greeter?"; then
  sudo pacman -S --noconfirm xorg xdg-utils lightdm lightdm-slick-greeter
  sudo systemctl enable lightdm
  gum format --theme=pink "blue" "💡 Xorg and LightDM installed!"
fi

# Install and compile StumpWM
if gum confirm --default=Yes "Install and compile StumpWM?"; then
  mkdir -p ~/.lisp/misc
  git clone https://github.com/stumpwm/stumpwm-contrib ~/.lisp/misc/stumpwm-contrib
  git clone https://github.com/stumpwm/stumpwm ~/.lisp/misc/stumpwm
  cd ~/.lisp/misc/stumpwm
  ./autogen.sh && ./configure && make
  sudo make install
  gum format --theme=pink "blue" "🔵 StumpWM installed successfully!"
fi

# Final message
glow <<EOM
# 🎉 S-OS Setup Complete!
Your system is now set up and ready to go.

Enjoy your new environment!
EOM