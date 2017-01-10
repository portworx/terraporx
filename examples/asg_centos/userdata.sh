#!/bin/bash -v
mkdir -p /etc/yum.repos.d
tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
yum update -y >> /tmp/boot.out 2>&1
yum install -y docker-engine >> /tmp/boot.out 2>&1
systemctl enable docker.service >> /tmp/boot.out 2>&1
systemctl start docker >> /tmp/boot.out 2>&1
