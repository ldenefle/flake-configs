# Bise provisioning

## Usage

```
python3 -m virtualenv --python="$(command -v python3)" .env &&
    source .env/bin/activate &&
    python3 -m pip install -U pip virtualenv &&
    python3 -m pip install -r requirements.txt &&
    ansible-galaxy collection install -r requirements.yml
```

Before running Ansible, dependencies needs to be installed on target `bise`

```
sudo su
pacman-key --init
pacman-key --populate
pacman -Sy
pacman -S sudo python base-devel glibc libffi openssl
groupadd sudoers
useradd -G sudoers,wheel -m lucas
echo 'lucas ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-lucas
su lucas
mkdir -m 700 ~/.ssh; curl https://github.com/ldenefle.keys >> ~/.ssh/authorized_keys
exit
reboot
```


