FROM ubuntu:19.10
# Install Deps
RUN apt update && apt upgrade -y
RUN apt install -y git meson  build-essential \
        pkg-config cmake glib2.0-dev gir1.2-gusb-1.0 libgusb-dev \
        libcairo2-dev  libnss3-dev udev libgudev-1.0-dev gdb-mingw-w64-target \
        libgirepository1.0-dev valgrind debhelper gtk-doc-tools libxv-dev libglib2.0-doc checkinstall \
		python3-pip python3-cairo umockdev libgusb-doc wget libpolkit-gobject-1-dev libdbus-glib-1-dev \
		libsystemd-dev libpam0g-dev systemd python3-cairo python3-dbusmock policykit-1 \
		&& pip3 install meson
# Build libfprint 1.90.1
RUN wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/libfprint/1:1.90.1-1/libfprint_1.90.1.orig.tar.xz 
RUN tar xJf /libfprint_1.90.1.orig.tar.xz \
	&& cd libfprint-1.90.1/ \
	&& wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/libfprint/1:1.90.1-1/libfprint_1.90.1-1.debian.tar.xz \
	&& tar xJf  libfprint_1.90.1-1.debian.tar.xz\
	&& dpkg-buildpackage -rfakeroot -b
RUN   	dpkg -i libfprint-2-2_1.90.1-1_amd64.deb \
	&&  dpkg -i gir1.2-fprint-2.0_1.90.1-1_amd64.deb \
	&&  dpkg -i libfprint-2-dev_1.90.1-1_amd64.deb 
# Build pam-wrapper 1.0.7  Fixed
RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/p/pam-wrapper/pam-wrapper_1.0.7.orig.tar.gz \
	&& tar xzf pam-wrapper_1.0.7.orig.tar.gz \
	&& cd pam_wrapper-1.0.7/ \
	&&  wget http://archive.ubuntu.com/ubuntu/pool/universe/p/pam-wrapper/pam-wrapper_1.0.7-4build1.debian.tar.xz \
	&& tar xJf pam-wrapper_1.0.7-4build1.debian.tar.xz \
	&& dpkg-buildpackage -rfakeroot -b
RUN    dpkg -i libpamtest0_1.0.7-4build1_amd64.deb \
	&& dpkg -i python3-pypamtest_1.0.7-4build1_amd64.deb \
	&& dpkg -i libpam-wrapper_1.0.7-4build1_amd64.deb
# Build fprintd 1.90.1
RUN git clone https://gitlab.freedesktop.org/libfprint/fprintd.git \
	&& cd fprintd/ \
	&& git checkout 1.90.1 \
	&& meson build \
	&& cd build/ \
	&& ninja \
	&& checkinstall -y --default --pkgname fprintd-1.90.1   ninja install \
	&& cp /fprintd/build/fprintd*  /
RUN ls -l /*.deb

FROM alpine
COPY --from=0 /*.deb /
