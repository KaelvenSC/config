#!/data/data/com.termux/files/usr/bin/bash

# Script Roblox Private Server Manager untuk Termux
# Bisa pakai link web PS dan buka Roblox langsung (com.roblox.clientb)

PS_FILE="ps_links.txt"

# Fungsi menu
show_menu() {
    echo "=== Roblox Private Server Manager ==="
    echo "[1] Add link PS"
    echo "[2] List PS"
    echo "[3] Delete PS"
    echo "[4] Open Roblox app (com.roblox.clientb)"
    echo "[5] Show PS link (copy-paste untuk join)"
    echo "[6] Exit"
    echo -n "Pilih opsi: "
}

# Add link PS
add_ps() {
    echo -n "Masukkan link Private Server Roblox (https://www.roblox.com/share?code=...): "
    read -r link
    if [[ -n "$link" && "$link" == https://www.roblox.com/share?code=* ]]; then
        echo "$link" >> "$PS_FILE"
        echo "Link berhasil ditambahkan!"
    else
        echo "Link tidak valid. Pastikan format https://www.roblox.com/share?code=..."
    fi
}

# List PS
list_ps() {
    if [ ! -f "$PS_FILE" ] || [ ! -s "$PS_FILE" ]; then
        echo "Tidak ada link PS yang tersimpan."
        return 1
    fi
    echo "Daftar Private Server:"
    nl -ba "$PS_FILE"
    return 0
}

# Delete PS
delete_ps() {
    list_ps || return
    echo -n "Masukkan nomor PS yang ingin dihapus: "
    read -r num
    total=$(wc -l < "$PS_FILE")
    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$total" ]; then
        sed -i "${num}d" "$PS_FILE"
        echo "PS berhasil dihapus!"
    else
        echo "Nomor tidak valid."
    fi
}

# Open Roblox app
open_roblox() {
    echo "Membuka Roblox app..."
    am start -n com.roblox.clientb/com.roblox.client.LaunchActivity
    echo "Roblox dibuka. Join server manual melalui link."
}

# Show link PS
show_link() {
    list_ps || return
    echo -n "Masukkan nomor PS yang ingin ditampilkan link: "
    read -r num
    total=$(wc -l < "$PS_FILE")
    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$total" ]]; then
        link=$(sed -n "${num}p" "$PS_FILE")
        echo "Link PS: $link"
        echo "Copy-paste link ini di browser untuk join server."
    else
        echo "Nomor tidak valid."
    fi
}

# Loop utama
while true; do
    show_menu
    read -r choice
    case $choice in
        1) add_ps ;;
        2) list_ps ;;
        3) delete_ps ;;
        4) open_roblox ;;
        5) show_link ;;
        6) echo "Keluar."; exit 0 ;;
        *) echo "Pilihan tidak valid. Coba lagi." ;;
    esac
    echo ""
done
