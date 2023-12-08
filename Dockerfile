FROM ubuntu:22.04
ENV PATH="${PATH}:/root/.local/bin"
RUN apt-get update -y; \ 
    apt-get -y install curl; \
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null; \
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install -y gcc python3; \
    apt-get install -y python3-pip; \
    apt-get install -y openssh-server; \
    apt-get install -y nano; \
    apt-get install -y git; \
    apt-get install -y zip; \
    apt-get install -y unzip; \
    mkdir -p /dev/net; \
    mknod /dev/net/tun c 10 200; \
    chmod 600 /dev/net/tun; \
    apt-get install -y tailscale; \
    apt-get remove -y curl; \
    apt-get clean all -y; \
    python3 -m pip install --user ansible --no-warn-script-location; \
    mkdir /etc/ansible/; \
    ansible-config init --disabled -t all > /etc/ansible/ansible.cfg
COPY hosts /etc/ansible/
EXPOSE 1055
CMD tailscaled --tun=userspace-networking --socks5-server=localhost:1055 & tailscale up && /bin/bash
