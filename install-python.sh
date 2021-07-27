#!/bin/sh
cd
wget https://www.python.org/ftp/python/3.9.1/Python-3.9.1.tar.xz
tar xf Python-3.9.1.tar.xz
cd ./Python-3.9.1
./configure
make
make install
update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.9 10
pip3 install pynvim
