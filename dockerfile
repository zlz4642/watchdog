FROM mcr.microsoft.com/azure-cli

RUN curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
RUN curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

WORKDIR /root
COPY . .
RUN chmod 777 -R *

RUN apk add openrc
COPY watchdog.sh /etc/init.d/watchdog
RUN chmod 777 /etc/init.d/watchdog
RUN rc-update add watchdog default

ENTRYPOINT ["/root/watchdog.sh"]