FROM library/ubuntu:xenial AS build

ENV LANG=C.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y \
        python-software-properties \
        software-properties-common \
        apt-utils
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y \
        fdupes

RUN mkdir /build /rootfs
WORKDIR /build
RUN apt-get download \
        libgdbm3 \
        perl-base \
        perl-modules-5.22 \
        libperl5.22 \
        perl
RUN find *.deb | xargs -I % dpkg-deb -x % /rootfs

WORKDIR /rootfs
RUN rm -rf \
        etc \
        usr/share/doc \
        usr/share/man \
        usr/share/lintian \
        usr/lib/x86_64-linux-gnu/perl/debian-config-data-* \
        usr/lib/x86_64-linux-gnu/perl/cross-config-* \
 && ln -sf perl5.22-x86_64-linux-gnu usr/bin/perl \
 && ln -sf perl5.22-x86_64-linux-gnu usr/bin/perl5.22.1 \
 && ln -sf cpan5.22-x86_64-linux-gnu usr/bin/cpan \
 && fdupes -rnq1 \
        usr/lib/x86_64-linux-gnu/perl \
        usr/lib/x86_64-linux-gnu/perl-base \
        usr/share/perl \
    | xargs -I % sh -c "ln -sf /%"

WORKDIR /


FROM clover/common

ENV LANG=C.UTF-8

COPY --from=build /rootfs /
