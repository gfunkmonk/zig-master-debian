ARG DEBIAN_DIST=trixie
FROM debian:$DEBIAN_DIST

ARG ZIG_VERSION
ARG DEBIAN_DIST
ARG BUILD_VERSION
ARG FULL_VERSION

# Install build dependencies
RUN apt update && apt install -y --no-install-recommends \
    build-essential pandoc python3-html2text wget ca-certificates gzip && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Zig
RUN wget -q "https://ziglang.org/builds/zig-x86_64-linux-$ZIG_VERSION.tar.xz" && \
    tar -xf "zig-x86_64-linux-$ZIG_VERSION.tar.xz" -C /opt && \
    rm "zig-x86_64-linux-$ZIG_VERSION.tar.xz"

# Setup Directory Structure
RUN mkdir -p /output/usr/lib/zig/master \
             /output/DEBIAN \
             /output/usr/share/doc/zig-master/ \
             /output/usr/share/man/man1/

# Copy Binaries and Libs
RUN cp "/opt/zig-x86_64-linux-$ZIG_VERSION/zig" /output/usr/lib/zig/master/ && \
    cp -r "/opt/zig-x86_64-linux-$ZIG_VERSION/lib" /output/usr/lib/zig/master/

# Copy Maintainer Scripts
COPY output/DEBIAN/ /output/DEBIAN/
RUN chmod 755 /output/DEBIAN/postinst /output/DEBIAN/prerm /output/DEBIAN/postrm

# Copy Docs
COPY output/changelog.Debian /output/usr/share/doc/zig-master/changelog.Debian
COPY output/copyright /output/usr/share/doc/zig-master/

# Unified Template Replacement
RUN find /output -type f -exec sed -i \
    -e "s/DIST/$DEBIAN_DIST/g" \
    -e "s/BUILD_VERSION/$BUILD_VERSION/g" \
    -e "s/ZIG_VERSION/$ZIG_VERSION/g" {} +

# Generate Manpage from langref
# Fix: html2text is the binary provided by python3-html2text
RUN html2text "/opt/zig-x86_64-linux-$ZIG_VERSION/doc/langref.html" > /output/usr/share/man/man1/zig-master.md && \
    pandoc -s -t man -o /output/usr/share/man/man1/zig-master.1 /output/usr/share/man/man1/zig-master.md && \
    rm /output/usr/share/man/man1/zig-master.md && \
    gzip -n -9 /output/usr/share/man/man1/zig-master.1

# Clean up source to keep image slim (optional but good practice)
RUN rm -rf "/opt/zig-x86_64-linux-$ZIG_VERSION"

RUN dpkg-deb --build /output /zig-master_${FULL_VERSION}.deb