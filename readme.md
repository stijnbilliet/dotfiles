# Cloning this repository
```
git clone --bare https://github.com/stijnbilliet/dotfiles.git $HOME/dotfiles.git/
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
