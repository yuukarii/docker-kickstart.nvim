# Use a small base image with package manager
FROM debian:trixie-20250908-slim

ARG NEOVIM_URL="https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz"
ARG NODE_URL="https://deb.nodesource.com/setup_22.x"
ARG JDTLS_URL="https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/1.50.0/jdt-language-server-1.50.0-202509041425.tar.gz"

# Build arguments
ARG USER_UID
ARG USER_GID
ARG ENABLE_JAVA=true

# Fallbacks in case USER_UID or USER_GID are not passed
ENV USER_UID=${USER_UID:-1000}
ENV USER_GID=${USER_GID:-1000}

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    make \
    gcc build-essential libc6-dev\
    ripgrep \
    fd-find \
    tree-sitter-cli \
    unzip \
    tar \
    git \
    wget ca-certificates \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd --gid ${USER_GID} dev \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m dev \
    && mkdir /workspace

# Install nvim
RUN wget ${NEOVIM_URL} \
    && rm -rf /opt/nvim-linux-x86_64 \
    && mkdir -p /opt/nvim-linux-x86_64 \
    && chmod a+rX /opt/nvim-linux-x86_64 \
    && tar -C /opt -xzf nvim-linux-x86_64.tar.gz \
    && ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/ \
    && rm -rf nvim-linux-x86_64.tar.gz

# Install python and node.js for pyright
RUN wget -qO- ${NODE_URL} | bash - \
    && apt-get install -y --no-install-recommends python3-venv python3-pip nodejs

# Install Java if enable
RUN if [ "$ENABLE_JAVA" = "true" ]; then \
        wget -qO- https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg \
        && echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list \
        && apt-get update && apt-get install -y --no-install-recommends openjdk-21-jdk java-1.8.0-amazon-corretto-jdk maven \
        && wget ${JDTLS_URL} -O jdt-language-server.tar.gz \
        && mkdir -p /opt/jdtls && tar -xvf jdt-language-server.tar.gz -C /opt/jdtls \
        && chown -R ${USER_UID}:${USER_GID} /opt/jdtls/config_linux \
        && rm -rf jdt-language-server.tar.gz \
        && rm -rf /var/lib/apt/lists/* ; \
    fi

# Copy some dirs
# RUN mkdir -p /afs/xx/xx/xx/8.0.462
# COPY 8.0.462 /afs/xx/xx/xx/8.0.462

# Set working directory
USER dev
WORKDIR /workspace

ARG MASON_PACKAGES="lua-language-server stylua bash-language-server pyright"

RUN mkdir -p /home/dev/.config/nvim \
    && git clone https://github.com/yuukarii/docker-kickstart.nvim.git /home/dev/.config/nvim \
    && HOME=/home/dev XDG_CONFIG_HOME=/home/dev/.config nvim --headless "+Lazy! sync" +qa \
    && HOME=/home/dev XDG_CONFIG_HOME=/home/dev/.config nvim --headless -c "MasonInstall ${MASON_PACKAGES}" -c "qall"

CMD ["/bin/bash"]
