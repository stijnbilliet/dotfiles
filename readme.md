# Cloning this repository
I am using a bare style git repo that stores the git files in a seperate directory from the actual repositories content.
We will be cloning directly in the home directory:
```
cd ~
git clone --bare https://github.com/stijnbilliet/dotfiles.git $HOME/dotfiles.git/
git --git-dir=$HOME/dotfiles.git/ --work-tree=$HOME checkout
```

# Setting up the desktop
Ensure .unbox is executable
```
sudo chmod +x .unbox
```

Then proceed to run it
```
./.unbox
```

The dependencies will be checked and the ansible playbook will be run to ensure the required packages are installed.

# Interacting with the repo
As we are using a bare repo cloned directly into the home directory, using standard git commands in the home directory will not work.
One could continue to use `git --git-dir=$HOME/dotfiles.git/ --work-tree=$HOME` followed by the git command (e.g. status). The setup
script has added a git alias that does this, so to interact with the dotfiles proceed to use the alias as follows:

```
git df status
```
