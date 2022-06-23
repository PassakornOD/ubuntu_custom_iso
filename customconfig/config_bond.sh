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
cat << EOF > /etc/netplan/01-bondlacp.yaml
network:
  ethernets:
    ens1f0: {}
    ens1f1: {}
    ens5f0: {}
    ens5f1: {}
  bonds:
    bond0:
      interfaces:
      - ens1f0
      - ens1f1
      - ens5f0
      - ens5f1
      mtu: 1500
      parameters:
        down-delay: 0
        lacp-rate: fast
        mii-monitor-interval: 100
        mode: 802.3ad
        transmit-hash-policy: layer3+4
        up-delay: 0
  vlans:
    bond0.$(echo ${infoos} | awk -F, '{print $4}'):
      id: $(echo ${infoos} | awk -F, '{print $4}')
      link: bond0
      addresses:
        - $(echo ${infoos} | awk -F, '{print $5}')/27
        - $(echo ${infoos} | awk -F, '{print $7}')/123
      gateway4: $(echo ${infoos} | awk -F, '{print $6}')
      gateway6: $(echo ${infoos} | awk -F, '{print $8}')

    bond0.$(echo ${infoos} | awk -F, '{print $9}'):
      id: $(echo ${infoos} | awk -F, '{print $9}')
      link: bond0
      addresses:
        - $(echo ${infoos} | awk -F, '{print $10}')/27
        - $(echo ${infoos} | awk -F, '{print $12}')/121
      gateway4: $(echo ${infoos} | awk -F, '{print $11}')
      gateway6: $(echo ${infoos} | awk -F, '{print $13}')

    bond0.$(echo ${infoos} | awk -F, '{print $14}'):
      id: $(echo ${infoos} | awk -F, '{print $14}')
      link: bond0
      addresses:
        - $(echo ${infoos} | awk -F, '{print $15}')/24
      gateway4: $(echo ${infoos} | awk -F, '{print $16}')

    bond0.$(echo ${infoos} | awk -F, '{print $17}'):
      id: $(echo ${infoos} | awk -F, '{print $17}')
      link: bond0
      addresses:
        - $(echo ${infoos} | awk -F, '{print $18}')/24
      gateway4: $(echo ${infoos} | awk -F, '{print $19}')
EOF

echo "==============Summary configure OOB with netplan==================="
cat /etc/netplan/01-bondlacp.yaml
# echo "==============Apply configure OOB==================="
# netplan apply
# echo "==============Display Configure OOB==================="
# ip addr
# echo "==============END configure OOB==================="