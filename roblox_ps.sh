#!/data/data/com.termux/files/usr/bin/bash

# Roblox Private Server Launcher Termux
# Bisa simpan link langsung, buka Roblox, tetap di Termux

PS_FILE="ps_links.txt"

# Fungsi list PS
list_ps() {
    if [ ! -f "$PS_FILE" ] || [ ! -s "$PS_FILE" ]; then
        echo "Belum ada link PS tersimpan."
        return 1
    fi
    echo "Daftar Private Server:"
    nl -ba "$PS_FILE"
    return 0
}

# Fungsi add link PS
add_ps() {
    echo -n "Masukkan link Private Server Roblox (https://www.roblox.com/share?code=...): "
    read -r link
    if [[ -n "$link" && "$link" == https://www.roblox.com/share?code=* ]]; then
        echo "$link" >> "$PS_FILE"
        echo "Link berhasil ditambahkan!"
    else
        echo "Link tidak valid."
    fi
}

# Fungsi buka Roblox dari link
open_ps() {
    list_ps || return
    echo -n "Masukkan nomor PS yang ingin dibuka: "
    read -r num
    total=$(wc -l < "$PS_FILE")
    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$total" ]; then
        link=$(sed -n "${num}p" "$PS_FILE")
        echo "Membuka Roblox..."
        termux-open-url "$link"
        echo "Roblox dibuka. Kembali ke Termux untuk pilih server lain kapan saja."
    else
        echo "Nomor tidak valid."
    fi
}

# Fungsi hapus PS
delete_ps() {
    list_ps || return
    echo -n "Masukkan nomor PS yang ingin dihapus: "
    read -r num
    total=$(wc -l < "$PS_FILE")
    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$total" ]]; then
        sed -i "${num}d" "$PS_FILE"
        echo "PS berhasil dihapus!"
    else
        echo "Nomor tidak valid."
    fi
}

# Loop utama
while true; do
    echo "=== Roblox PS Manager ==="
    echo "[1] Add link PS"
    echo "[2] List PS"
    echo "[3] Delete PS"
    echo "[4] Open Roblox PS"
    echo "[5] Exit"
    echo -n "Pilih opsi: "
    read -r choice
    case $choice in
        1) add_ps ;;
        2) list_ps ;;
        3) delete_ps ;;
        4) open_ps ;;
        5) echo "Keluar."; exit 0 ;;
        *) echo "Pilihan tidak valid." ;;
    esac
    echo ""
done
