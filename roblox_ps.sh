#!/data/data/com.termux/files/usr/bin/bash

# Script untuk mengelola dan membuka Private Server Roblox di Termux
# Simpan link PS dalam file ps_links.txt

PS_FILE="ps_links.txt"

# Fungsi untuk menampilkan menu
show_menu() {
    echo "=== Roblox Private Server Manager ==="
    echo "[1] Add link PS"
    echo "[2] List PS yang tersimpan"
    echo "[3] Delete PS"
    echo "[4] Run selected PS (buka Roblox otomatis)"
    echo "[5] Exit"
    echo -n "Pilih opsi: "
}

# Fungsi untuk add link
add_ps() {
    echo -n "Masukkan link private server Roblox (roblox://placeId=123456&linkCode=abc): "
    read -r link
    if [[ -n "$link" && "$link" == roblox://* ]]; then
        echo "$link" >> "$PS_FILE"
        echo "Link berhasil ditambahkan!"
    else
        echo "Link tidak valid. Pastikan format roblox://..."
    fi
}

# Fungsi untuk list PS
list_ps() {
    if [ ! -f "$PS_FILE" ] || [ ! -s "$PS_FILE" ]; then
        echo "Tidak ada link PS yang tersimpan."
        return 1
    fi
    echo "Daftar Private Server:"
    nl -ba "$PS_FILE"
    return 0
}

# Fungsi untuk delete PS
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

# Fungsi untuk run selected PS
run_ps() {
    list_ps || return
    echo -n "Masukkan nomor PS yang ingin dijalankan: "
    read -r num
    total=$(wc -l < "$PS_FILE")
    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$total" ]; then
        link=$(sed -n "${num}p" "$PS_FILE")
        echo "Membuka Roblox dengan link: $link"
        # Gunakan termux-open-url agar compatible Android terbaru
        termux-open-url "$link"
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
