### Build build environment

FROM ubuntu:22.04
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

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends libev4 libusb-1.0-0 gosu libfmt8 && \
    mkdir -p /pkg
COPY --from=0 /build/knxd_*.deb /pkg
COPY --from=0 /build/knxd-tools_*.deb /pkg
RUN dpkg -i /pkg/knxd_*.deb /pkg/knxd-tools_*.deb && \
    apt-get clean -y && \
    apt-get autoclean -y && \
    apt-get autoremove && \
    rm -rf /pkg
WORKDIR /usr/local/bin
COPY knxd.ini /etc/knxd.ini
COPY entrypoint.sh .
RUN chmod u+x entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh", "knxd"]
CMD ["/etc/knxd.ini"]
