#!/bin/bash
# Bersihkan semua di VPS - Gunakan dengan hati-hati!
# Diuji pada Ubuntu/Debian

echo "🚨 Peringatan: Script ini akan membersihkan sistem Anda!"
read -p "Lanjutkan? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
  echo "❌ Dibatalkan."
  exit 1
fi

echo "🧹 Update & Bersihkan Package..."
apt update && apt autoremove --purge -y && apt clean

echo "🧼 Hapus package umum (bisa disesuaikan)..."
apt remove --purge -y nginx apache2 mysql-server php nodejs docker docker-compose snapd ufw

echo "👥 Hapus user tidak penting (selain root)..."
for user in $(awk -F: '$3 >= 1000 {print $1}' /etc/passwd); do
    if [[ "$user" != "root" ]]; then
        echo "🔸 Menghapus user: $user"
        userdel -r $user 2>/dev/null
    fi
done

echo "📅 Hapus semua cron jobs..."
rm -f /etc/cron.d/* 2>/dev/null
rm -f /var/spool/cron/crontabs/* 2>/dev/null
crontab -r 2>/dev/null

echo "🔥 Hapus semua rules firewall (iptables)..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

echo "🗑️ Hapus file sampah..."
rm -rf /var/log/* /tmp/* /var/tmp/* ~/.bash_history 2>/dev/null
history -c 2>/dev/null

echo "✅ Pembersihan selesai. Sebaiknya reboot."
read -p "Reboot sekarang? (y/n): " reboot_now
if [[ "$reboot_now" == "y" ]]; then
  if command -v reboot >/dev/null; then
    reboot
  else
    echo "❌ Perintah 'reboot' tidak ditemukan. Silakan reboot manual dengan: sudo reboot"
  fi
fi
