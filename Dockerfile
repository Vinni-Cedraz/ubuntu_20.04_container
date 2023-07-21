FROM node:16-alpine

# Update package lists 
RUN apk update

# Set timezone
RUN apk add alpine-conf
RUN setup-timezone -z America/Sao_Paulo

# Install utils
RUN apk add --no-cache \
	make \
	wget \
	libc-dev \
	clang \
	pkgconf \
	openssh-client \
	dbus-x11 \
	gdb \
	zsh \
	unzip \
	gzip \
	tar \
	readline-dev \
	valgrind \
	git \
	ca-certificates \
	openssl \
	curl \
	python3 \
	py3-pip \
	iputils \
	ripgrep \
	neovim

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
# This ensures you are compiling your C code with the same compiler we have in
# 42's workspaces (clang-12) and that you will be using it when you compile with "cc"

# Set the working directory
WORKDIR /root

# Install Powerlevel10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.powerlevel10k
RUN echo 'source /root/.powerlevel10k/powerlevel10k.zsh-theme' > /root/.zshrc

# Install zsh plugin manager 
RUN wget git.io/antigen -O ~/.antigen.zsh

# Install my dotfiles
RUN git clone --branch my_ubuntu_container https://github.com/Vinni-Cedraz/.dotfiles
RUN chmod +x /root/.dotfiles/install.sh
RUN zsh /root/.dotfiles/install.sh

#configure locale:
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set the terminal to load 256 colors
ENV TERM xterm-256color

# Install ft_neovim
RUN mkdir -p /root/.config/
RUN git clone https://github.com/Vinni-Cedraz/ft_neovim /root/.config/nvim

# Clean up APT cache to reduce image size
RUN apk cache clean

# Set working directory to ~/
WORKDIR /root
CMD ["/bin/zsh"]
