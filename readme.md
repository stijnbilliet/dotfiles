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
