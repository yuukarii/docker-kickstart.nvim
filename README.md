# docker-kickstart.nvim

## Introduction

This repo is forked from [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) repo.

I modified it for developing with my Python and Java8 projects. Also, I packaged it into Docker container for easier to maintain the development environment.

Firstly, install Nerd Font into your system:
```bash
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Iosevka.zip
unzip Iosevka.zip -d Iosevka

mkdir -p ~/.local/share/fonts
cp Iosevka/*.ttf ~/.local/share/fonts/
cp Iosevka/*.otf ~/.local/share/fonts/
```

Configure your terminal to use this font.

Build the container image:
```bash
docker build -t nvim-dev .

# or

docker build --build-arg ENABLE_JAVA=false \
  --build-arg USER_UID=1000 --build-arg USER_GID=1000 \
  -t nvim-dev .
```

Open `nvim` by `docker run` command:
```bash
docker run -it --rm -v $(pwd):/workspace nvim-dev

# or if you want it to be persistent

docker run -d --name nvim-workspace --restart unless-stopped \
  -v $(pwd):/workspace nvim-dev
```

Add this alias into your `.bashrc` or `.zshrc`:
```bash
alias nvim="docker run -it --rm -v $(pwd):/workspace nvim-dev"
alias nvim-workspace="docker run -d --name nvim-workspace --restart unless-stopped -v $(pwd):/workspace nvim-dev"
```
