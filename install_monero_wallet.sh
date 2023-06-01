#!/bin/bash

sudo apt-get update

# Install bzip2 if needed
if ! command -v bzip2 &>/dev/null; then
	echo "bzip2 is not installed. Installing..."
	sudo apt-get install bzip2 -y
else
	echo "bzip2 is already installed, continuing..."
fi

# Start process of downloading monero wallet
MONERO_HASHES_DL=https://www.getmonero.org/downloads/hashes.txt
MONERO_WALLET_DL=https://downloads.getmonero.org/gui/linux64

#Verify PGP of monero_hashes.txt
wget https://www.getmonero.org/downloads/hashes.txt -O monero_hashes.txt

gpg --import binaryfate.asc >/dev/null 2>&1
gpg --verify monero_hashes.txt >/dev/null 2>&1

# Determine if the exit code of gpg is a success
if [[ $? -eq 0 ]]; then
	echo "SUCCESS: Vaid PGP for monero wallet hashes. Continuing..."
else
	echo "ERROR: Invalid PGP for monero wallet hashes. Exiting."
	exit 1
fi

# Extract desired wallet hash from monero_hashes.txt file
MONERO_WALLET_HASH=$(grep "monero-gui-linux-x64-" "monero_hashes.txt" | cut -d' ' -f1)

# Download monero wallet
wget https://downloads.getmonero.org/gui/linux64 -O monero-gui-linux64.tar.bz2

# Verify file hash of the monero wallet
computed_hash=$(sha256sum monero-gui-linux64.tar.bz2 | awk '{print $1}')

echo "Monero wallet computed hash: $computed_hash"

if [ "$computed_hash" = "$MONERO_WALLET_HASH" ]; then
	echo "Monero wallet hash verification successful. The file is intact and has not been tampered with."
else
	echo "Monero wallet hash verification failed. The file may be corrupted or tampered with."
	exit 1
fi

# Extract the monero wallet file
echo "Extracting monero wallet..."
mkdir monero-gui-wallet
tar -xjf monero-gui-linux64.tar.bz2 -C ./monero-gui-wallet