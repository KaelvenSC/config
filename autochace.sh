#!/data/data/com.termux/files/usr/bin/bash

# ==================== AUTO CLEAR CACHE (5 MENIT, NO LOG) ====================
echo "========================================="
echo "   AUTO CLEAR CACHE SETIAP 5 MENIT"
echo "   (NO LOG FILE - AMAN UNTUK STORAGE)"
echo "========================================="
echo "Press Ctrl+C to stop"
echo "========================================="

while true; do
    DATE=$(date '+%H:%M:%S')
    echo "[$DATE] 🔄 Membersihkan cache..."
    
    # Clear commands - semua output dibuang
    apt-get clean -y > /dev/null 2>&1
    apt-get autoclean -y > /dev/null 2>&1
    pip cache purge > /dev/null 2>&1
    rm -rf ~/.cache/pip > /dev/null 2>&1
    rm -rf /data/data/com.termux/files/usr/tmp/* > /dev/null 2>&1
    rm -rf ~/.tmp > /dev/null 2>&1
    rm -rf ~/.termux/logs/* > /dev/null 2>&1
    rm -rf ~/.cache/termux/logs/* > /dev/null 2>&1
    
    if command -v npm &> /dev/null; then
        npm cache clean --force > /dev/null 2>&1
    fi
    
    echo "[$DATE] ✅ Selesai! Next: $(date -d "+5 minutes" '+%H:%M:%S')"
    echo "----------------------------------------"
    
    sleep 300
done
