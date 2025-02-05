# Bise provisioning

## Installation

```
python3 -m virtualenv --python="$(command -v python3)" .env &&
    source .env/bin/activate &&
    python3 -m pip install -U pip virtualenv &&
    python3 -m pip install -r requirements.txt &&
    ansible-galaxy collection install -r requirements.yml
```

## Usage

A script is provided to generate a sd card image that will boot the latest armbian

```
./make-arch-arm32.sh /dev/<drive>
```

The script should prompt for master password, it currently only fetches my public keys and should be modified if reused.

The user setup script only happens after the first login which by default is `root` with password `1234`.

An ansible playbook can be used to setup the system once the machine went through the user / ssh setup

It's recommended to create a file `export.sh` with all secrets that should be passed to the build script as environment variable.

```
source export.sh
ansible-playbook main.yml -i inventory --ask-become-pass
```
