# dotfiles

My collection of scripts and configs for a range of different uses over a range of different machines

## Usage

These are all designed for my usage, but if you wish sit in my seat follow these commands:

```bash
cd /path/to/repo

# To see the options, just run the file
./dot-manage.sh

# Installs vundle, the vim package manager
./dot-manage.sh 6
# Installs oh-my-zsh, a super customized zsh interface of sorts
./dot-manage.sh 7
# Installs nvm, used to manage node versions
./dot-manage.sh 8

# Does everything mentioned above in one command
./dot-manage.sh 9

# Now depending on your OS, use either ./dot-files 1-5
# For example, for Ubuntu use:
./dot-manage.sh 3
# Or for MacOS use:
./dot-manage.sh 5
```
