# Use a small base image with package manager
FROM debian:stable-slim

# Build arguments
ARG USER_UID
ARG USER_GID
ARG ENABLE_JAVA=false

# Fallbacks in case USER_UID or USER_GID are not passed
ENV USER_UID=${USER_UID:-1000}
ENV USER_GID=${USER_GID:-1000}

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    make \
    gcc build-essential libc6-dev\
    ripgrep \
    fd-find \
    unzip \
    tar \
    git \
    wget ca-certificates \
    tini \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd --gid ${USER_GID} dev \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m dev \
    && mkdir -p /home/dev/.config/nvim

# Install nvim
RUN wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    && rm -rf /opt/nvim-linux-x86_64 \
    && mkdir -p /opt/nvim-linux-x86_64 \
    && chmod a+rX /opt/nvim-linux-x86_64 \
    && tar -C /opt -xzf nvim-linux-x86_64.tar.gz \
    && ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/ \
    && rm -rf nvim-linux-x86_64.tar.gz

# Conditionally install Python and Java support
RUN wget -qO- https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && if [ "$ENABLE_JAVA" = "true" ]; then \
        wget -qO- https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg \
        && echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list \
        && apt-get update && apt-get install -y --no-install-recommends openjdk-21-jdk java-1.8.0-amazon-corretto-jdk \
        && wget https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/1.50.0/jdt-language-server-1.50.0-202509041425.tar.gz -O jdt-language-server.tar.gz \
        && mkdir -p /opt/jdtls && tar -xvf jdt-language-server.tar.gz -C /opt/jdtls \
        && chown -R ${USER_UID}:${USER_GID} /opt/jdtls/config_linux \
        && rm -rf jdt-language-server.tar.gz; \
    fi && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
USER dev
WORKDIR /home/dev

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["sleep", "infinity"]
