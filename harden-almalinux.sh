#!/bin/bash

# Update the system
echo "Updating the system..."
dnf update -y

# Enable SELinux
echo "Enabling SELinux..."
setenforce 1
sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config


# Install and configure fail2ban
echo "Installing and configuring Fail2ban..."
dnf install fail2ban -y
systemctl enable fail2ban
systemctl start fail2ban

cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Set up automatic updates
echo "Setting up automatic updates..."
dnf install dnf-automatic -y
systemctl enable --now dnf-automatic.timer

# Install and run security tools
echo "Installing security tools..."
dnf install chkrootkit rkhunter -y
chkrootkit
rkhunter --update
rkhunter --propupd

# Configure AIDE
echo "Configuring AIDE..."
dnf install aide -y
aide --init
cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
(crontab -l ; echo "0 2 * * * /usr/sbin/aide --check") | crontab -

# Enable logging and monitoring
echo "Enabling logging and monitoring..."
systemctl enable rsyslog
systemctl start rsyslog

dnf install audit -y
systemctl enable auditd
systemctl start auditd

# Disable unnecessary services
echo "Disabling unnecessary services..."
# Add services you want to disable below
UNNECESSARY_SERVICES=(
  "avahi-daemon"
  "cups"
  "bluetooth"
)
for service in "${UNNECESSARY_SERVICES[@]}"; do
  systemctl disable "$service"
done

# Secure shared memory
echo "Securing shared memory..."
echo "tmpfs /dev/shm tmpfs defaults,noexec,nosuid 0 0" >> /etc/fstab
mount -o remount /dev/shm

# Disable IPv6 if not needed
echo "Disabling IPv6..."
cat <<EOL >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOL
sysctl -p

# Network security: Limit network exposure
echo "Limiting network exposure..."
# Example: binding SSH to localhost (if remote access is not needed)
# sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 127.0.0.1/' /etc/ssh/sshd_config
# systemctl restart sshd

# Remind the user to set up regular backups
echo "Please ensure you set up regular, automated backups and store them securely."

echo "System hardening completed!"
