### Build build environment

FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git-core 
RUN apt-get install -y --no-install-recommends build-essential devscripts equivs

RUN mkdir -p /build
WORKDIR /build
RUN git clone -b debian https://github.com/knxd/knxd.git
WORKDIR /build/knxd
RUN mk-build-deps --install --tool='apt-get --no-install-recommends --yes --allow-unauthenticated' debian/control
RUN rm -f knxd-build-deps_*.deb
RUN dpkg-buildpackage -b -uc

### Build final container

FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends libev4 libusb-1.0-0 gosu
RUN mkdir -p /pkg
WORKDIR /pkg
COPY --from=0 /build/knxd_*.deb .
COPY --from=0 /build/knxd-tools_*.deb .
RUN dpkg -i knxd_*.deb knxd-tools_*.deb
RUN apt-get clean -y && apt-get autoclean -y && apt-get autoremove
WORKDIR /usr/local/bin
RUN rm -rf /pkg
COPY knxd.ini /etc/knxd.ini
COPY entrypoint.sh .
RUN chmod u+x entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh", "knxd"]
CMD ["/etc/knxd.ini"]
