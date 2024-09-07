#!/bin/bash
set -ex

rm -rf /opt/_internal/cpython-3*

export OPENSSL_VERSION=1.1.1w
export PYTHON_VERSION=3.10.14

# Download, build, and install OpenSSL
cd /usr/local/src
curl -sL https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz | tar -xz
cd openssl-$OPENSSL_VERSION
./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib
make -j$(nproc)
make install

# Update the shared libries to use the new OpenSSL version
echo "/usr/local/openssl/lib" > /etc/ld.so.conf.d/openssl-$OPENSSL_VERSION.conf
ldconfig

# Add the new OpenSSL to the path
export PATH=/usr/local/openssl/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/openssl/lib:$LD_LIBRARY_PATH

# Verify the new OpenSSL version
openssl version

# Rebuild python to use the new OpenSSL
cd /usr/local/src
curl -sL https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz | tar -xz
cd Python-$PYTHON_VERSION
./configure --prefix=/usr/local --enable-shared --with-openssl=/usr/local/openssl
make
make install

# Verify the new Python version
python3 --version

# Rebuild pip to use the new Python
curl -sL https://bootstrap.pypa.io/get-pip.py | python3

# Verify the new pip version
pip3 --version

# Install requests, pyinstaller, upgrade pip
pip3 install --upgrade pip
pip3 install requests pyinstaller

# Force the system to use /usr/local/bin/python3
ln -sf /usr/local/bin/python3 /usr/bin/python3
ln -sf /usr/local/bin/pip3 /usr/bin/pip3
ln -sf /usr/local/bin/python3 /usr/bin/python
ln -sf /usr/local/bin/pip3 /usr/bin/pip

# Verify the system is using the new Python
python --version