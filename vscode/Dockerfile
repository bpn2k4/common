FROM ubuntu:22.04

RUN apt update \
  && apt install -y curl git iproute2 iputils-ping openssh-client openssh-server sudo wget \
  && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password ubuntu --uid 1000 \
  && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ubuntu

RUN mkdir -p /home/ubuntu/.local/bin \
  && wget https://github.com/coder/code-server/releases/download/v4.23.1/code-server-4.23.1-linux-amd64.tar.gz -P /tmp \
  && tar -zxf /tmp/code-server-4.23.1-linux-amd64.tar.gz -C /home/ubuntu/.local/bin \
  && mv /home/ubuntu/.local/bin/code-server-4.23.1-linux-amd64 /home/ubuntu/.local/bin/code-server

WORKDIR /home/ubuntu/workspace

COPY --chown=ubuntu:ubuntu ./start.sh ./install-extension.sh /opt/

EXPOSE 1-65535

ENV PATH="${PATH}:/home/ubuntu/.local/bin/code-server/bin"

CMD [ "/opt/start.sh" ]
