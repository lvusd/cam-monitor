# README

## Requirements

- [Nix](nix.dev/install-nix)

## Usage

1. Build the ISO image via `nix build`
2. `dd` the ISO image over a USB stick
3. Boot to the USB on the machine
4. Wait for install to complete and system shuts off (~5 minutes)
5. Power on the machine
6. Connect to wifi **before** deployment

## Hardware

- Disable suspend / sleep in BIOS
- Enable auto-power on in BIOS (AMD CBS > FCH)
