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
```

Spawn by `docker run` command:
```bash
docker run -d --name nvim-dev --restart unless-stopped \
  -v $(pwd):/home/dev/.config/nvim \
  -v <some-path>:/workspace \
  nvim-dev
```

Build and run by `docker compose` command (remember to modify the value in `env` file)
```bash
cp env .env
docker compose up -d --build
```

Add this line into your `.bashrc` or `.zshrc`:
```bash
alias nvim="docker exec -it nvim-dev /bin/bash"
```
