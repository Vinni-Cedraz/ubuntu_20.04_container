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
	clangd \
	sudo \
	libc-dev \
	clang-12 \
	pkg-config \
	openssh-client \
	dbus-x11 \
	gdb zsh unzip gzip tar \
	libreadline-dev \
	valgrind \
	git \
	python3-pip \
	build-essential \
	python3-dev \
	python3-venv \
	pip \
	iputils-ping \
	xclip \
	ripgrep \
	netcat

#configure locale:
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install custom commands
RUN wget https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip
RUN unzip exa-*.zip
RUN rm -rf exa-linux-x86_64-v0.10.1.zip
RUN wget https://github.com/peteretelej/tree/releases/download/0.1.4/tree_0.1.4_x86_64-unknown-linux-musl.tar.gz
RUN tar -xvf tree_0.1.4_x86_64-unknown-linux-musl.tar.gz
RUN rm -f tree_0.1.4_x86_64-unknown-linux-musl.tar.gz
RUN mv tree /usr/bin                     

RUN pip3 install norminette==3.3.51
RUN pip3 install compiledb
RUN pip3 install cmake

# GDB-dashboard
RUN wget -P ~ https://git.io/.gdbinit
RUN pip install pygments

# This ensures you are compiling your C code with the same compiler we have in 42's workspaces (clang-12) and that you will be using it when you compile with "cc"
RUN mv /usr/bin/clang-12 /usr/bin/clang
RUN mv /usr/bin/clang++-12 /usr/bin/clang++
RUN mv /usr/bin/clang-cpp-12 /usr/bin/clang-cpp
RUN rm -f /usr/bin/cc
RUN rm -f /usr/bin/c++
RUN rm -f /usr/bin/g++
RUN ln -s /usr/bin/clang /usr/bin/cc
RUN ln -s /usr/bin/clang++ /usr/bin/c++
RUN ln -s /usr/bin/clang++ /usr/bin/g++

# Download and extract neovim appimage
RUN wget https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.appimage && \
    chmod u+x nvim-linux-x86_64.appimage && \
    ./nvim-linux-x86_64.appimage --appimage-extract && \
    mv squashfs-root /neovim && \
	ln -s /neovim/usr/bin/nvim /usr/bin/nvim

# Add environment variables needed for GUI apps 
ARG DISPLAY
ENV DISPLAY=$DISPLAY
ARG XDG_RUNTIME_DIR
ENV XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR
ARG _USER
ARG _USER_HOME

# and create non-root user if needed
RUN if [ "$_USER" == "myuser"]; then \
        useradd -m -G sudo -s /bin/zsh myuser && \
        echo "myuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
    fi

USER $_USER
WORKDIR $_USER_HOME

# Install ft_neovim
RUN mkdir -p .config/
RUN git clone https://github.com/Vinni-Cedraz/ft_neovim .config/nvim
RUN nvim --headless -c "lua require("init.lua")" -c "qall!"
RUN nvim --headless -c "lua require("plugins.treesitter")" -c "qall!"
RUN nvim --headless -c "lua require("plugins.copilot")" -c "qall!"

# Install Powerlevel10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git .powerlevel10k
RUN echo "source ~/.powerlevel10k/powerlevel10k.zsh-theme" > .zshrc

# Install zsh plugin manager 
RUN wget git.io/antigen -O .antigen.zsh

# INSTALL MY ZSH SETTINGS
RUN git clone --branch my_ubuntu_container https://github.com/Vinni-Cedraz/.dotfiles
RUN chmod +x .dotfiles/install.sh
RUN bash .dotfiles/install.sh
RUN echo ulimit -n 65535 >> ~/.zshrc;

# Set the terminal to load 256 colors
ENV TERM xterm-256color

# Install NVM and Node.js 18
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
# Set Zsh as the default shell
SHELL ["/bin/zsh", "-c"]
RUN source $HOME/.nvm/nvm.sh && nvm install 18 && nvm use 18 # Activate NVM by sourcing the script

RUN if [ "$_USER" = "myuser" ]; then \
        su root; \
		apt-get clean && rm -rf /var/lib/apt/lists/*; \
	else \
		apt-get clean && rm -rf /var/lib/apt/lists/*; \
    fi

CMD ["/bin/zsh"]
