
# Container devel of dsi/gct/globus/etc.

## Requirements
- docker enabled linux system with outbound access to NCSA gitlab, github, docker hub

## Setup
1. Pull the docker image
    ```
    [server]# docker pull davidraila/globus-devel:centos-6
    ```
1. Populate ~/src on the server with the sources you with to work on.  Use a local git master on NCSA gitlab, adding the upstream remote referene to merge upstream changes and/or contribute a pull request upstream.
    ```
    [server]# mkdir ~/src
    [server]# git clone git@git.ncsa.illinois.edu:draila/ncsa-hpss-dsi.git ~/src/hpss_dsi_ncsa
    [server]# cd ~/src/hpss_dsi_ncsa 
    [server]# git remote add upstream https://github.com/JasonAlt/GridFTP-DSI-for-HPSS.git

    ```
1. Additional setup for HPSS development if desired:
    1. Download appropriate hpss rpms into /tmp/rpms
    1. Create a version-named docker volume to hold the hpss installation files and populate with a forced hpss install:
    ```
    [server]# docker volume create opt_hpss_753u8_el6
    [server]# docker run --rm -it -v /tmp/rpms:/tmp/rpms -v opt_hpss_753u8_el6:/hpss_src/hpss-7.5.3.0-20191022.u8.el6

    [container ]# cd /rpms 
    [container]# rpm -i --nodeps --noscripts *.rpm
    [container]# exit

    [server]# rm -rf /tmp/rpms
    ```
4. Build a named development container.  Repeat this processes for each different platform/version and hpss release to support each version/platform in a different container if desired:
    ```
    [server]# docker run -it --name HPSS_DEV_C6 --hostname HPSS_DEV_C6 -v /etc/localtime:/etc/localtime -v opt_hpss_753u8_el6:/opt/hpss -v /root/src:/root/src

    ... or for GCT, without an hpss volume:

    [server]# docker run -it --name GCT_DEV_C7 --hostname GCT_DEV_C7 -v /etc/localtime:/etc/localtime -v /root/src:/root/src

    ```

## HPSS DSI Build and package:
1. instructions at https://github.com/JasonAlt/GridFTP-DSI-for-HPSS/blob/master/bootstrap
bootstrap and configure only need to be done once normally
    ```
    [container]# cd src/hpss_dsi_ncsa
    [container]# ./bootstrap
    [container]# ./configure
    [container]# make
    [container]# make install
    [container]# (cd /usr/local/lib && tar cf ~/src/hpss_dsi_ncsa/dsi-bin.tar libglobus*)
    ```
    This packages the dsi in dsi-bin.tar under the host src path specified, where it can be copied and installed on a DSI system under /usr/local/gridftp/hpss_dsi

## Gridcf GCT Build:
- instructions at https://github.com/gridcf/gct/blob/master/INSTALL.txt
    ```
    [container]# cd src/gcfgct
    [container]# autoreconf -i
    [container]# ./configure
    [container]# make
    [container]# make install
    ```
GCT files are deployed by default under