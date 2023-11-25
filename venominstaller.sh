#!/bin/bash
# Created with passion by @iwantanode

# Creating user/user group
echo "Creating validator user and group..."
VALIDATOR_USER="validator"
VALIDATOR_GROUP="validator"
sudo groupadd $VALIDATOR_GROUP
sudo useradd $VALIDATOR_USER -m -s /bin/bash -g $VALIDATOR_GROUP -G sudo
# Mount 
sudo mkdir -p /var/venom/rnode/
sudo chown $VALIDATOR_USER:$VALIDATOR_GROUP /var/venom/rnode/


# Check if systemd-timesyncd is running
if systemctl is-active --quiet systemd-timesyncd; then
    echo "systemd-timesyncd is running."
else
    echo "systemd-timesyncd is not running."
fi

# Create firewall rules to allow ADNL communications
sudo ufw allow 30000/UDP

# Install dependencies
sudo apt update 
sudo apt install -y git libssl-dev pkg-config build-essential libzstd-dev libclang-dev libgoogle-perftools-dev

# Check if the Rust is installed command is available
if command -v rustc &> /dev/null; then
  echo "Rust is already installed."
  rustc --version
else
  echo "Rust is not installed. Installing Rust..."

  # Download and run the official Rust installation script
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source "$HOME/.cargo/env";

  if [ $? -eq 0 ]; then
    echo "Rust has been successfully installed."
    rustc --version
  else
    echo "Failed to install Rust."
    exit 1
  fi
fi

# Build the validator node
# Switch to validator user and execute the following commands
#su - $VALIDATOR_USER -c "
  #cargo install --locked --git https://github.com/venom-blockchain/stvenom-node-tools;
  #$PWD/.cargo/bin/stvenom init systemd;
  #stvenom init;
 # ~/.cargo/bin/stvenom init systemd;
#"
# ... [previous script content]
source "$HOME/.cargo/env";
# Create home directory for validator if it doesn't exist
if [ ! -d "/home/$VALIDATOR_USER" ]; then
    mkdir /home/$VALIDATOR_USER
    chown $VALIDATOR_USER:$VALIDATOR_USER /home/$VALIDATOR_USER
fi

# Switch to validator user and execute the following commands

# Now run the other commands
cargo install --locked --git https://github.com/broxus/nodekeeper
$HOME/.cargo/bin/nodekeeper init systemd
nodekeeper init
$HOME/.cargo/bin/nodekeeper init systemd

