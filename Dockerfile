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
    python3 python3-venv \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LC_CTYPE=en_US.UTF-8 \
    USERNAME=dev USER_UID=1000 USER_GID=1000

# Install nvim
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    rm -rf /opt/nvim-linux-x86_64 && \
    mkdir -p /opt/nvim-linux-x86_64 && \
    chmod a+rX /opt/nvim-linux-x86_64 && \
    tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
    ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/ && \
    rm -rf nvim-linux-x86_64.tar.gz

# Install node.js for Pyright usage
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m venv /opt/venv

# Create non-root user
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}

# Java development
RUN curl -fsSL https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list && \
    apt-get update && apt-get install -y java-1.8.0-amazon-corretto-jdk && rm -rf /var/lib/apt/lists/*

RUN curl -L https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/1.50.0/jdt-language-server-1.50.0-202509041425.tar.gz -o jdt-language-server-1.50.0.tar.gz && \
    mkdir -p /opt/jdtls && tar -xvf jdt-language-server-1.50.0.tar.gz -C /opt/jdtls && \
    chown -R ${USER_UID}:${USER_GID} /opt/jdtls/config_linux && \
    rm -rf jdt-language-server-1.50.0.tar.gz

# Set working directory
USER ${USERNAME}
WORKDIR /home/${USERNAME}
# ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="/usr/local/bin:/opt/venv/bin:$PATH"
RUN mkdir -p /home/${USERNAME}/.config/nvim

CMD ["sleep", "infinity"]
