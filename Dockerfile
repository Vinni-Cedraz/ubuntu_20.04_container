FROM ubuntu:22.04

# Update package lists 
RUN apt-get update -y && apt-get upgrade -y

# Set timezone
RUN apt-get install -y tzdata
RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Install utils
RUN apt install fd-find
RUN apt-get install -y --no-install-recommends \
	clang \
	locales \
	cargo \
	make \
	curl \
	wget \
	libc-dev \
	pkg-config \
	gdb zsh unzip gzip tar \
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

# Install Node.js 16
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs

# Set the working directory
WORKDIR /root
# Download and extract neovim appimage
RUN wget https://github.com/neovim/neovim/releases/download/v0.8.3/nvim-linux64.tar.gz && \
	tar -xvf nvim-linux64.tar.gz && \
	rm nvim-linux64.tar.gz && \
	mv nvim-linux64 /root/.local/nvim && \
	echo 'PATH=$PATH:/root/.local/nvim/' >> /root/.zshrc

# Install Powerlevel10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.powerlevel10k
RUN echo 'source /root/.powerlevel10k/powerlevel10k.zsh-theme' > /root/.zshrc

# Install zsh plugin manager 
RUN curl -L git.io/antigen-nightly > /root/.antigen.zsh

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
