#!/bin/bash

path=""
# select site
site=1;
for infosite in $(cat ${path}/scripts/custompkg/site); do
    echo ${site}. $(echo ${infosite}|awk -F, '{print $1}');
    (( site++ ));
done

read -p "What is location site? : " site
while [[ $site -lt 1 || $site -gt 5 ]]; do
    read -p "What is site for install ? : " site
done

# Set hostname on this server
i=1;
for infoline in $(cat ${path}/scripts/custompkg/hostname.${site}); do
    echo ${i}. $(echo ${infoline}|awk -F, '{print $1}');
    (( i++ ));
done

read -p "What is hostname on this server ? : " index

totalline=$(cat ${path}/scripts/custompkg/hostname.${site} |wc -l);
while [[ $index -lt 1 || $index -gt $totalline ]]; do
    read -p "What is hostname on this server ? : " index
done

infoos=$(sed -n "${index} p" ${path}/scripts/custompkg/hostname.${site});
# Setup network interface
## set oob with netplan
echo "=============configure OOB interface================"
cat << EOF > /etc/netplan/02-oobstat.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eno1:
      dhcp4: no
      addresses:
        - $(echo ${infoos} | awk -F, '{print $2}')/24
      gateway4: $(echo ${infoos} | awk -F, '{print $3}')
      routes:
      - to: 10.235.4.0/24
        via: $(echo ${infoos} | awk -F, '{print $3}')
      - to: 10.235.6.0/24
        via: $(echo ${infoos} | awk -F, '{print $3}')
EOF

echo "==============Summary configure OOB with netplan==================="
cat /etc/netplan/02-oobstat.yaml
echo "==============Apply configure OOB==================="
netplan apply
echo "==============Display Configure OOB==================="
ip addr
echo "==============END configure OOB==================="