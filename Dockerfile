FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm-256color

RUN apt-get update -y && \
    apt-get install -y \
    qemu-kvm \
    build-essential \
    libvirt-daemon-system \
    libvirt-dev \
    openssh-server \
    curl \
    net-tools \
    gettext-base \
    kmod \
    rsync \
    samba \
    jq && \
    apt-get autoremove -y && \
    apt-get clean

ARG VAGRANT_VERSION=2.4.1
# ARG VAGRANT_BOX=peru/windows-server-2022-standard-x64-eval
ARG VAGRANT_BOX=peru/windows-10-enterprise-x64-eval

RUN wget https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}-1_amd64.deb && \
    apt install ./vagrant_${VAGRANT_VERSION}-1_amd64.deb && \
    rm -rf ./vagrant_${VAGRANT_VERSION}-1_amd64.deb

RUN vagrant plugin install vagrant-libvirt

RUN vagrant box add --provider libvirt ${VAGRANT_BOX} && \
    vagrant init ${VAGRANT_BOX}

ENV PRIVILEGED=true
ENV INTERACTIVE=true
ENV VAGRANT_BOX=$VAGRANT_BOX

COPY Vagrantfile /Vagrantfile.tmp
COPY startup.sh /
RUN chmod +x startup.sh
RUN rm -rf /Vagrantfile

ENTRYPOINT ["/startup.sh"]
CMD ["/bin/bash"]
