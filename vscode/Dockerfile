FROM ubuntu:22.04

RUN apt update \
  && apt install -y \
  curl \
  git \
  iproute2 \
  iputils-ping \
  openssh-client \
  openssh-server \
  sudo \
  unzip \
  vim \
  wget \
  && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password ubuntu --uid 1000 \
  && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ubuntu

# Install visual studio code
RUN mkdir -p /home/ubuntu/.local/bin \
  && wget https://github.com/coder/code-server/releases/download/v4.23.1/code-server-4.23.1-linux-amd64.tar.gz -P /tmp \
  && tar -zxf /tmp/code-server-4.23.1-linux-amd64.tar.gz -C /home/ubuntu/.local/bin \
  && mv /home/ubuntu/.local/bin/code-server-4.23.1-linux-amd64 /home/ubuntu/.local/bin/code-server

# Install nvm, nodejs
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
  && export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" \
  && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
  && nvm install 20

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash -s "bun-v1.1.7"

# Install go lang
RUN wget https://go.dev/dl/go1.22.3.linux-amd64.tar.gz -P /tmp \
  && sudo tar -xzf /tmp/go1.22.3.linux-amd64.tar.gz  -C /usr/local

  # Intall java
RUN wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz -P /tmp \
  && sudo tar -xzf /tmp/jdk-21_linux-x64_bin.tar.gz  -C /usr/local \
  && sudo mv /usr/local/jdk-21.0.3 /usr/local/jdk-21

RUN rm -rf /tmp/*

WORKDIR /home/ubuntu/workspace

COPY --chown=ubuntu:ubuntu ./start.sh ./install-extension.sh /opt/

ENV PATH="${PATH}:/home/ubuntu/.local/bin/code-server/bin:/home/ubuntu/.bun/bin:/usr/local/go/bin:/usr/local/jdk-21/bin"
ENV JAVA_HOME="/usr/local/jdk-21"

CMD [ "/opt/start.sh" ]
