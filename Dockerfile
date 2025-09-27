# Use a small base image with package manager
FROM debian:stable-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    make \
    gcc \
    ripgrep \
    fd-find \
    unzip \
    tar \
    git \
    curl \
    sudo \
    locales \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LC_CTYPE=en_US.UTF-8 \
    USERNAME=dev USER_UID=1000 USER_GID=1000

# Now we install nvim
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    rm -rf /opt/nvim-linux-x86_64 && \
    mkdir -p /opt/nvim-linux-x86_64 && \
    chmod a+rX /opt/nvim-linux-x86_64 && \
    tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
    ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/

# Create non-root user
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}

# Set working directory
USER ${USERNAME}
WORKDIR /home/${USERNAME}
ENV PATH=/usr/local/bin:$PATH

RUN mkdir -p /home/${USERNAME}/.config/nvim

# Default command when container runs
CMD ["/bin/bash"]
