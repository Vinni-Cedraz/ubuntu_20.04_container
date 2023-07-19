FROM ubuntu:22.04

# Update package lists 
RUN apt-get update -y && apt-get upgrade -y

# Set timezone
RUN apt-get install -y tzdata
RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Install utils
RUN apt install fd-find
RUN apt-get install -y --no-install-recommends \
	locales \
	make \
	wget \
	curl \
	libc-dev \
	clang-12 \
	pkg-config \
	gdb zsh unzip gzip tar \
	libreadline-dev \
	valgrind \
	openssh-server \
	xz-utils \
	git \
	python3-pip \
	pip \
	python3.10-venv \
	iputils-ping \
	ripgrep \
	graphviz \
	kcachegrind \
	dbus-x11

# Add environment variables needed for GUI apps 
ARG DISPLAY
ENV DISPLAY=$DISPLAY

ARG XDG_RUNTIME_DIR
ENV XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR

# Install custom commands
RUN wget https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip
RUN unzip exa-*.zip
RUN rm -rf exa-linux-x86_64-v0.10.1.zip
RUN wget https://github.com/peteretelej/tree/releases/download/0.1.4/tree_0.1.4_x86_64-unknown-linux-musl.tar.gz
RUN tar -xvf tree_0.1.4_x86_64-unknown-linux-musl.tar.gz
RUN rm -f tree_0.1.4_x86_64-unknown-linux-musl.tar.gz
RUN mv tree /usr/bin                     
RUN pip3 install norminette
RUN pip3 install compiledb

# Generate SSH key pair
RUN ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
EXPOSE 22
COPY id_rsa.pub /root/.ssh/authorized_keys

# This ensures you are compiling your C code with the same compiler we have in
# 42's workspaces (clang-12) and that you will be using it when you compile with "cc"
RUN mv /usr/bin/clang-12 /usr/bin/clang
RUN mv /usr/bin/clang++-12 /usr/bin/clang++
RUN mv /usr/bin/clang-cpp-12 /usr/bin/clang-cpp
RUN rm -f /usr/bin/cc
RUN ln -s /usr/bin/clang /usr/bin/cc
RUN ln -s /usr/bin/clang++ /usr/bin/c++
RUN ln -s /usr/bin/clang++ /usr/bin/g++

# Download and extract neovim appimage
RUN wget https://github.com/neovim/neovim/releases/latest/download/nvim.appimage && \
    chmod u+x nvim.appimage && \
    ./nvim.appimage --appimage-extract && \
    mv squashfs-root /neovim && \
    ln -s /neovim/usr/bin/nvim /usr/bin/nvim

# Set the working directory
WORKDIR /root

# Install Powerlevel10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.powerlevel10k
RUN echo 'source /root/.powerlevel10k/powerlevel10k.zsh-theme' > /root/.zshrc

# Install zsh plugin manager 
RUN wget  git.io/antigen > /root/.antigen.zsh

# Install my dotfiles
RUN git clone --branch my_ubuntu_container https://github.com/Vinni-Cedraz/.dotfiles
WORKDIR /root/.dotfiles
RUN chmod +x install.sh
RUN ./install.sh
RUN echo ulimit -n 65535 >> ~/.zshrc

#configure locale:
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set the terminal to load 256 colors
ENV TERM xterm-256color

# Install ft_neovim
RUN mkdir -p /root/.config/
RUN git clone https://github.com/Vinni-Cedraz/ft_neovim /root/.config/nvim

# Install NVM and Node.js 16 
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
# Set Zsh as the default shell
SHELL ["/bin/zsh", "-c"]
RUN source ~/.nvm/nvm.sh && nvm install 16 && nvm use 16 # Activate NVM by sourcing the script

# Clean up APT cache to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory to ~/
WORKDIR /root
CMD ["/bin/zsh"]
