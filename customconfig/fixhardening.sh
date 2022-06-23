#!/bin/bash

# Hardening fix
chown root:root /boot/grub/grub.cfg
chmod 600 /boot/grub/grub.cfg

chmod 600 /var/log/kern.log
chown root:root /var/log/kern.log	
chmod 600 /var/log/syslog
chown root:root /var/log/syslog

cat << EOF >> /etc/audit/rules.d/50-mounts.rules
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts
EOF

cat << EOF >> /etc/audit/rules.d/50-delete.rules
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete
-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete
EOF

cat << EOF >> /etc/audit/rules.d/50-delete.rules
-e 2
EOF

systemctl restart auditd

cp -r /etc/audit/audit.rules /etc/audit/rules.d
