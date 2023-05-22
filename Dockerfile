FROM ubuntu:22.04

COPY id_rsa.pub /root/.ssh/authorized_keys
# Update package lists 
RUN apt-get update -y && apt-get upgrade -y

# Set timezone
RUN apt-get install -y tzdata
RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Install utils
RUN apt install fd-find
RUN apt-get install -y --no-install-recommends \
	locales \
	cargo \
	make \
	curl \
	wget \
	libc-dev \
	clang-12 \
	pkg-config \
	gdb zsh unzip gzip tar \
	libreadline-dev \
	valgrind \
	openssh-server \
	git \
	python3-pip \
	pip \
	python3.10-venv \
	iputils-ping \
	ripgrep

# Install custom commands
RUN curl -LO https://github.com/ogham/exa/releases/download/v0.10.0/exa-linux-x86_64-v0.10.0.zip
RUN unzip exa-linux-x86_64-v0.10.0.zip
RUN rm -rf exa-linux-x86_64-v0.10.0.zip
RUN cargo install tre

# Install Norminette
RUN pip3 install norminette

# Generate SSH key pair
RUN ssh-keygen -t rsa -N "" -f /root/.ssh/id_rs
EXPOSE 22

# Install Node.js 16
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs


# give proper names to the compiler's binaries and create the necessary symlinks
RUN mv /usr/bin/clang-12 /usr/bin/clang
RUN mv /usr/bin/clang++-12 /usr/bin/clang++
RUN mv /usr/bin/clang-cpp-12 /usr/bin/clang-cpp
RUN rm /usr/bin/cc
RUN ln -s /usr/bin/clang /usr/bin/cc
RUN ln -s /usr/bin/clang++ /usr/bin/c++
RUN ln -s /usr/bin/clang++ /usr/bin/g++

# Download and extract neovim appimage
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage && \
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
RUN curl -L git.io/antigen > /root/.antigen.zsh

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

# Clean up APT cache to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory to ~/
WORKDIR /root
CMD ["/bin/zsh"]
