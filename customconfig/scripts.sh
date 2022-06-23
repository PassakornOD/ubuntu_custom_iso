#!/bin/bash


path=""

# select site
site=1;
for infosite in $(cat ${path}/scripts/custompkg/site); do
    echo ${site}. $(echo ${infosite}|awk -F, '{print $1}');
    (( site++ ));
done
(( site-- ))
read -p "What is location site? : " site_id
while [[ $site_id -lt 1 || $site_id -gt $site ]]; do
    read -p "Please select id location site range 1 to ${site} ? : " site_id
done
infosite=$(sed -n "${site_id} p" ${path}/scripts/custompkg/site);
echo $infosite;
# Set hostname on this server
i=1;
for infoline in $(cat ${path}/scripts/custompkg/hostname.${infosite}); do
    echo ${i}. $(echo ${infoline}|awk -F, '{print $1}');
    (( i++ ));
done

read -p "What is hostname on this server ? : " index
totalline=$(cat ${path}/scripts/custompkg/hostname.${infosite} |wc -l);
while [[ $index -lt 1 || $index -gt $totalline ]]; do
    read -p "What is hostname on this server ? : " index
done

infoos=$(sed -n "${index} p" ${path}/scripts/custompkg/hostname.${infosite});
hname=$(echo ${infoos} | awk -F, '{print $1}')
hostnamectl set-hostname ${hname};
echo "==============configure hostname==================="
hostnamectl
sleep 5


# Setup network interface
## set oob with netplan
cat << EOF > /etc/netplan/02-oobstat.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
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

echo "==============y configure OOB with netplan==================="
cat /etc/netplan/02-oobstat.yaml
sleep 5
echo "==============Apply configure OOB==================="
netplan apply
echo "==============Display Configure OOB==================="
ip addr
echo "==============END configure OOB==================="


#install auditd and chronyd
echo "==============Install auditd and chronyd==================="
dpkg -i ${path}/scripts/packages/auditd/*.deb
echo "==============Install auditd and chronyd==================="
apt install ${path}/scripts/packages/chronyd/*.deb -y
sleep 5
# enable auditd service 
echo "==============enable and start auditd service==================="
systemctl enable auditd
systemctl start auditd

# Set NTP protocol with chrony service
if [ -f "/etc/chrony/chrony.conf" ]
then
sed -i 's/^server/#server/g' /etc/chrony/chrony.conf
echo "server 10.235.155.5 iburst prefer" >> /etc/chrony/chrony.conf
echo "server 10.232.95.5 iburst" >> /etc/chrony/chrony.conf
echo "==============configure NTP chronyd==================="b  
cat /etc/chrony/chrony.conf
echo "==============Enable and start chronyd service==================="
systemctl enable chronyd
systemctl start chronyd
else
echo "File is not found"
fi



# Remove all scripts
# echo "==============Remove script==================="
# rm -f ${path}/scripts/custompkg/hostname.1
# rm -f ${path}/scripts/custompkg/hostname.2
# rm -f ${path}/scripts/custompkg/hostname.3
# rm -f ${path}/scripts/custompkg/hostname.4
# rm -f ${path}/scripts/custompkg/hostname.5
# rm -f ${path}/scripts/custompkg/scripts.sh
