#!/bin/bash

USERNAME="$1"
CHEF_VERSION="$2"

if ! command -v ruby >/dev/null 2>&1
then
    echo "Installing Ruby"
    DEBIAN_FRONTEND=noninteractive apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y ruby ruby-dev build-essential
fi

if ! command -v chef-solo >/dev/null 2>&1
then
    echo "Installing Chef"
    gem install --no-rdoc --no-ri chef --version $CHEF_VERSION
fi

rm -rf /home/$USERNAME/stockaid-chef
mv /home/$USERNAME/next-stockaid-chef /home/$USERNAME/stockaid-chef
cd /home/$USERNAME/stockaid-chef
chef-solo -c solo.rb -j solo.json
