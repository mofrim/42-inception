FROM nixos/nix:latest

# Enable flakes
RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf;

# Install qemu for the VM build
RUN nix-env -iA nixpkgs.qemu;

WORKDIR /build

# Copy the flake files
COPY ./flake/* .

# Build the VM
RUN git init . && git add . && git config --global user.email "kalle@hoinz" && git config --global user.name "kalle" &&  git commit -m "init";
RUN nix build .#nixosConfigurations.vm.config.system.build.vm;

COPY ./copy_files.sh /

CMD [ "/copy_files.sh" ]
# CMD ["tail", "-f"]
