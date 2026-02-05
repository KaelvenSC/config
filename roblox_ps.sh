#!/data/data/com.termux/files/usr/bin/bash

# Script untuk mengelola dan membuka Private Server Roblox di Termux
# Pastikan Termux memiliki akses root atau izin yang diperlukan untuk menjalankan perintah Android.
# Simpan link PS dalam file ps_links.txt

PS_FILE="ps_links.txt"

# Fungsi untuk menampilkan menu
show_menu() {
    echo "=== Roblox Private Server Manager ==="
    echo "[1] Add link PS"
    echo "[2] List PS yang mau dimasukkan"
    echo "[3] Delete PS yang mau dihapus"
    echo "[4] Run selected PS (buka Roblox otomatis)"
    echo "[5] Exit"
    echo "Pilih opsi:"
}

# Fungsi untuk add link
add_ps() {
    echo "Masukkan link private server Roblox (contoh: roblox://placeId=123456&linkCode=abc):"
    read -r link
    if [ -n "$link" ]; then
        echo "$link" >> "$PS_FILE"
        echo "Link berhasil ditambahkan!"
    else
        echo "Link tidak boleh kosong."
    fi
}

# Fungsi untuk list PS
list_ps() {
    if [ ! -f "$PS_FILE" ] || [ ! -s "$PS_FILE" ]; then
        echo "Tidak ada link PS yang tersimpan."
        return
    fi
    echo "Daftar Private Server:"
    nl -ba "$PS_FILE"
}

# Fungsi untuk delete PS
delete_ps() {
    list_ps
    if [ ! -f "$PS_FILE" ] || [ ! -s "$PS_FILE" ]; then
        return
    fi
    echo "Masukkan nomor PS yang ingin dihapus:"
    read -r num
    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le $(wc -l < "$PS_FILE") ]; then
        sed -i "${num}d" "$PS_FILE"
        echo "PS berhasil dihapus!"
    else
        echo "Nomor tidak valid."
    fi
}

# Fungsi untuk run selected PS
run_ps() {
    list_ps
    if [ ! -f "$PS_FILE" ] || [ ! -s "$PS_FILE" ]; then
        return
    fi
    echo "Masukkan nomor PS yang ingin dijalankan:"
    read -r num
    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le $(wc -l < "$PS_FILE") ]; then
        link=$(sed -n "${num}p" "$PS_FILE")
        echo "Membuka Roblox dengan link: $link"
        # Buka Roblox dengan link (pastikan package com.roblox.client terinstall)
        am start -a android.intent.action.VIEW -d "$link" com.roblox.client
        echo "Roblox dibuka otomatis. Masuk ke private server."
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
        4) run_ps ;;
        5) echo "Keluar."; exit 0 ;;
        *) echo "Pilihan tidak valid. Coba lagi." ;;
    esac
    echo ""
done
