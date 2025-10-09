#!/usr/bin/env bash

# Build the Docker image
docker build -t nixos-vm-builder .

# Run the container and extract the built VM
docker run --rm -v $(pwd)/output:/output nixos-vm-builder

# The VM is now in ./output/
echo "VM built! Run with: ./output/bin/run-nixos-vm"
