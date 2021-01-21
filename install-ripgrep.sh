#!/bin/sh
cd
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb
dpkg -i ripgrep_12.1.1_amd64.deb
