#!/bin/sh
cd
wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
tar xf Python-3.7.3.tar.xz
cd ./Python-3.7.3
./configure
make
make install
update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.7 10
pip3 install pynvim
