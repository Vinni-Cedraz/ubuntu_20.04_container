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
	cargo \
	make \
	curl \
	wget \
	libc-dev \
	clang-12 \
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

# create /usr/bin/cc as a symlink to clang-12
RUN rm /usr/bin/cc
RUN ln -s /usr/bin/clang-12 /usr/bin/cc

# create fix 
RUN touch /root/run_me_after_nvim.sh
RUN echo '#!/bin/bash\n\n# Define the file \
path\nfile_path=~/.local/share/nvim/lazy/nvim-cmp/lua/cmp/view/ghost_text_view.lua\n\n# \
Check if the text "c.hl_group" is present in line 40 of the file\nif grep -q \
"c.hl_group" $file_path; then\n  # Delete the 40th line of the file\n  sed -i \
"40d" $file_path\n\n  # Output confirmation message\n  echo "The 40th line of \
$file_path containing '\''c.hl_group'\'' has been deleted."\nelse\n  # Output \
message if the text is not found\n  echo "The text '\''c.hl_group'\'' was not \
found in line 40 of $file_path."\nfi\n' > /root/run_me_after_nvim.sh
RUN chmod +x /root/run_me_after_nvim.sh

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
