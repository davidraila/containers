
FROM fedora

RUN dnf -y update
RUN dnf -y install sudo git wget kde-runtime adobe-source-code-pro-fonts liberation-fonts dejavu\*font\* gcc procps

#
# wget and install vscode-insiders
#

RUN echo 'wget -cqO- https://go.microsoft.com/fwlink/?LinkID=760866 -O /tmp/vscode.rpm  &&\
  	dnf -y install /tmp/vscode.rpm && rm -f /tmp/vscode.rpm' > /usr/local/bin/update-code && chmod 755 /usr/local/bin/update-code && /usr/local/bin/update-code &&\
	dnf -y clean all

copy start.sh /usr/local/bin
CMD start.sh