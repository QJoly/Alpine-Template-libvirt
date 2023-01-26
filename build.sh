#!/bin/bash

export iso_url="https://dl-cdn.alpinelinux.org/alpine/v3.17/releases/x86_64/alpine-virt-3.17.1-x86_64.iso"
export iso_checksum="sha256:19d22173b53cd169f65db08a966b51f9ef02750a621902d0d784195d7251b83b"
export root_password="HugePassword"


rm http/authorized_keys || true
for f in ssh/*.pub; do
        name_of_key=$(echo $f | cut -d "/" -f2 )
	echo -e "#$name_of_key" >> http/authorized_keys 
	key=$(cat $f)
	echo -e "$key" >> http/authorized_keys
done

packer build alpine-3-amd64-libvirt.json
