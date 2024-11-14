FROM ubuntu:22.04

# Set environment variables
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm-256color

# Set timezone and locale in one layer
RUN apt-get update && apt-get install -y tzdata locales \
    && ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && locale-gen en_US.UTF-8

# Install all packages in a single layer
RUN apt-get install -y --no-install-recommends \
    fd-find \
    make \
    wget \
    curl \
    clangd \
    sudo \
    libc-dev \
    clang-12 \
    pkg-config \
    openssh-client \
    dbus-x11 \
    gdb \
    zsh \
    unzip \
    gzip \
    tar \
    libreadline-dev \
    libxext-dev \
    libx11-dev \
    valgrind \
    git \
    python3-pip \
    pip \
	build-essential \
	python3-dev
    python3-venv \
    iputils-ping \
    libcriterion-dev \
    xclip \
    xz-utils \
    ripgrep \
    libglfw3 \
    libglfw3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install custom binaries in one layer
RUN wget https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip \
    && unzip exa-*.zip \
    && rm -rf exa-linux-x86_64-v0.10.1.zip \
    && wget https://github.com/peteretelej/tree/releases/download/0.1.4/tree_0.1.4_x86_64-unknown-linux-musl.tar.gz \
    && tar -xvf tree_0.1.4_x86_64-unknown-linux-musl.tar.gz \
    && rm -f tree_0.1.4_x86_64-unknown-linux-musl.tar.gz \
    && mv tree /usr/bin

# Install Python packages in one layer
RUN pip3 install norminette compiledb cmake pygments

# Configure clang and GDB in one layer
RUN wget -P ~ https://git.io/.gdbinit \
    && mv /usr/bin/clang-12 /usr/bin/clang \
    && mv /usr/bin/clang++-12 /usr/bin/clang++ \
    && mv /usr/bin/clang-cpp-12 /usr/bin/clang-cpp \
    && rm -f /usr/bin/cc \
    && ln -s /usr/bin/clang /usr/bin/cc \
    && ln -s /usr/bin/clang /usr/bin/gcc \
    && ln -s /usr/bin/clang++ /usr/bin/c++ \
    && ln -s /usr/bin/clang++ /usr/bin/g++

# Install Neovim in one layer
RUN wget https://github.com/neovim/neovim/releases/latest/download/nvim.appimage \
    && chmod u+x nvim.appimage \
    && ./nvim.appimage --appimage-extract \
    && mv squashfs-root /neovim \
    && ln -s /neovim/usr/bin/nvim /usr/bin/nvim

# Set display variables
ARG DISPLAY
ENV DISPLAY=$DISPLAY
ARG XDG_RUNTIME_DIR
ENV XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR
ARG _USER
ARG _USER_HOME

# Create non-root user
RUN if [ "$_USER" = "myuser" ]; then \
    useradd -m -G sudo -s /bin/zsh myuser \
    && echo "myuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
    fi

USER $_USER
WORKDIR $_USER_HOME

# Install configurations and tools in one layer
RUN mkdir -p .config/ \
    && git clone https://github.com/Vinni-Cedraz/ft_neovim .config/nvim \
    && nvim --headless -c "lua require(\"init.lua\")" -c "qall!" \
    && nvim --headless -c "lua require(\"plugins.treesitter\")" -c "qall!" \
    && nvim --headless -c "lua require(\"plugins.copilot\")" -c "qall!" \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git .powerlevel10k \
    && echo "source ~/.powerlevel10k/powerlevel10k.zsh-theme" > .zshrc \
    && wget git.io/antigen -O .antigen.zsh

# Install dotfiles and NVM in one layer
RUN git clone --branch my_ubuntu_container https://github.com/Vinni-Cedraz/.dotfiles \
    && chmod +x .dotfiles/install.sh \
    && bash .dotfiles/install.sh \
    && echo "ulimit -n 65535" >> ~/.zshrc \
    && wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Set shell and install Node.js
SHELL ["/bin/zsh", "-c"]
RUN source $HOME/.nvm/nvm.sh && nvm install 18 && nvm use 18

# Final cleanup
RUN if [ "$_USER" = "myuser" ]; then \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*; \
    else \
    apt-get clean && rm -rf /var/lib/apt/lists/*; \
    fi

CMD ["/bin/zsh"]
