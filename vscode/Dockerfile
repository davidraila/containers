FROM fedora

RUN dnf -y update 
RUN dnf -y install yum-plugin-fastestmirror
RUN dnf -y install sudo docker wget less which git autogen autoconf automake cmake cmake-gui \
  clang clang-tools-extra clang-analyzer \
  libtool-ltdl-devel python27 libtool autogen-libopts-devel openssl-devel glibc-utils \
   libtirpc-devel libtool-ltdl \
   xorg-x11-fonts-Type1  dejavu\*mono\*fonts \*oxygen\*fonts \
   breeze\*
   #google-\*fonts dejavu\*fonts liberation\*fonts oxygen\*fonts 
   
RUN wget -cqO- https://go.microsoft.com/fwlink/?LinkID=760866 -O /tmp/vscode.rpm  &&\
  dnf -y install /tmp/vscode.rpm && rm -f /tmp/vscode.rpm && ln -s `which code-insiders` /usr/local/bin/code
COPY NVIDIA-Linux-x86_64-384.98.run /tmp
RUN sh /tmp/NVIDIA-Linux-x86_64-384.98.run --silent -a --install-libglvnd --no-x-check --no-nvidia-modprobe --no-kernel-module
RUN ln -s /hpss_src/hpss-7.4.3.3-0.el6/ /opt/hpss
RUN dnf -y clean all
