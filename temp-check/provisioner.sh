#!/bin/bash

# install packages
apt-get update
apt-get install apt-transport-https ca-certificates curl gnupg lsb-release

# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io

# install docker-compose
dc_latest_version=$(curl -s https://github.com/docker/compose/tags | grep '<a href="/docker/compose/releases/tag/' | sed -E 's|^.+?/tag/(.+?)">$|\1|' | head -n 1)
curl -L "https://github.com/docker/compose/releases/download/${dc_latest_version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# create prometheus DB dir
mkdir /PROMETHEUS
chmod a+rwx /PROMETHEUS

docker-compose up
