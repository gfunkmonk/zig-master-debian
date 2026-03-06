ARG DEBIAN_DIST=trixie
FROM debian:$DEBIAN_DIST

ARG ZIG_VERSION
ARG DEBIAN_DIST
ARG BUILD_VERSION
ARG FULL_VERSION

RUN apt update && apt install -y build-essential pandoc python3-html2text wget 
RUN wget -q "https://ziglang.org/builds/zig-x86_64-linux-$ZIG_VERSION.tar.xz" && tar -xf "zig-x86_64-linux-$ZIG_VERSION.tar.xz" -C /opt && rm "zig-x86_64-linux-$ZIG_VERSION.tar.xz"
RUN mkdir -p /output/usr/lib/zig/master
RUN cp "/opt/zig-x86_64-linux-$ZIG_VERSION/zig" /output/usr/lib/zig/master/
RUN cp -r "/opt/zig-x86_64-linux-$ZIG_VERSION/lib" /output/usr/lib/zig/master/

RUN mkdir -p /output/DEBIAN
RUN mkdir -p /output/usr/share/doc/zig-master/
RUN mkdir -p /output/usr/share/man/man1/

COPY output/DEBIAN/control /output/DEBIAN/
COPY output/DEBIAN/postinst /output/DEBIAN/
COPY output/DEBIAN/prerm /output/DEBIAN/
COPY output/DEBIAN/postrm /output/DEBIAN/
RUN chmod 755 /output/DEBIAN/postinst
RUN chmod 755 /output/DEBIAN/prerm
RUN chmod 755 /output/DEBIAN/postrm

COPY output/changelog.Debian /output/usr/share/doc/zig-master/changelog.Debian
COPY output/copyright /output/usr/share/doc/zig-master/

RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/usr/share/doc/zig-master/changelog.Debian
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/usr/share/doc/zig-master/changelog.Debian
RUN sed -i "s/ZIG_VERSION/$ZIG_VERSION/" /output/usr/share/doc/zig-master/changelog.Debian

RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/DEBIAN/control
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/control
RUN sed -i "s/ZIG_VERSION/$ZIG_VERSION/" /output/DEBIAN/control

RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/DEBIAN/postinst
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/postinst
RUN sed -i "s/ZIG_VERSION/$ZIG_VERSION/" /output/DEBIAN/postinst

RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/DEBIAN/prerm
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/prerm
RUN sed -i "s/ZIG_VERSION/$ZIG_VERSION/" /output/DEBIAN/prerm

RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/DEBIAN/postrm
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/postrm
RUN sed -i "s/ZIG_VERSION/$ZIG_VERSION/" /output/DEBIAN/postrm

RUN html2markdown "/opt/zig-x86_64-linux-$ZIG_VERSION/doc/langref.html" > /output/usr/share/man/man1/zig-master.md
RUN pandoc -s -t man -o /output/usr/share/man/man1/zig-master.1 /output/usr/share/man/man1/zig-master.md
RUN rm /output/usr/share/man/man1/zig-master.md
RUN gzip -n -9 /output/usr/share/man/man1/zig-master.1


RUN dpkg-deb --build /output /zig-master_${FULL_VERSION}.deb


