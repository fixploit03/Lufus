#!/bin/bash
#----------------------------------------------
#
#.......: Lufus
#.......: Bootable USB Creator for Linux and Windows
#
# Script ini dibuat menggunakan <3 dan kopi.
# Script ini Open Source (Alias grtatis)
#
#----------------------------------------------

# Tentang script
program="Lufus"
deskripsi="Bootable USB Creator for Linux and Windows"
versi="v1.1"
pembuat="Rofi (Fixploit03)"
github="https://github.com/fixploit03/Lufus"

# Variabel warna
m="\e[1;31m"   # Merah
h="\e[1;32m"   # Hijau
b="\e[1;34m"   # Biru
p="\e[1;37m"   # Putih
r="\e[0m"      # Reset
ik=$'\e[1;33m' # Input kuning
ib=$'\e[1;34m' # Input biru
ip=$'\e[1;37m' # Input putih
ir=$'\e[0,'    # Input reset

# Variabel sistem
waktu_sekarang=$(date +"%Y-%m-%d %H:%M:%S")
os_type=""

# Fungsi untuk cek dependensi
function cek_dependensi() {
    local deps=("parted" "dd" "mkfs.vfat" "wipefs" "eject" "mount" "umount" "rsync" "ntfs-3g")
    local missing=()
    
    echo -e "${b}[*] ${p}Memeriksa dependensi yang diperlukan...${r}"
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null && ! dpkg -l | grep -q "${dep%%-*}"; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${m}[-] ${p}Dependensi yang tidak terpenuhi: ${missing[*]}${r}"
        echo -e "${b}[*] ${p}Mencoba menginstall dependensi yang diperlukan...${r}"
        apt-get update
        apt-get install -y ntfs-3g parted
        
        # Periksa lagi setelah mencoba instalasi
        for dep in "${missing[@]}"; do
            if ! command -v "$dep" &>/dev/null && ! dpkg -l | grep -q "${dep%%-*}"; then
                echo -e "${m}[-] ${p}Gagal menginstall: $dep${r}"
                echo -e "${m}[-] ${p}Silakan install manual dengan perintah: 'sudo apt-get install ntfs-3g parted'${r}"
                exit 1
            fi
        done
        echo -e "${h}[+] ${p}Semua dependensi berhasil diinstall.${r}"
    else
        echo -e "${h}[+] ${p}Semua dependensi terpenuhi.${r}"
    fi
}

# Fungsi untuk cek root (OK)
function cek_root(){
    if [[ "$(id -u)" -ne 0 ]]; then
        echo -e "${m}[-] ${p}Script ini harus dijalankan sebagai root.${r}"
        echo -e "${b}[*] ${p}Ketikkan: 'sudo bash $0'${r}"
        exit 1
    fi
}

# Fungsi untuk menampilkan banner (OK)
function banner(){
    clear
    echo -e "${b}+=========================================================+${r}"
    echo -e "${b}|       ${p}${program}                                             ${b}|${r}"
    echo -e "${b}|       ${p}${deskripsi}              ${b}|${r}"
    echo -e "${b}|       ${p}Versi: ${versi}                                       ${b}|${r}"
    echo -e "${b}|       ${p}Dibuat oleh: ${pembuat}                    ${b}|${r}"
    echo -e "${b}|       ${p}Github: ${github}       ${b}|${r}"
    echo -e "${b}+=========================================================+${r}"
    echo
}

# Fungsi untuk mendeteksi perangkat USB yang terpasang (OK)
function deteksi_usb(){
    echo -e "${b}[*] ${p}Mendeteksi perangkat USB yang terpasang...${r}"
    sleep 2
    echo -e "${h}[+] ${p}Perangkat USB yang terpasang:${r}"
    echo ""
    parted -l
    echo -e "${m}+==============================================================+${r}"
    echo -e "${m}|       ${p}Perhatikan nama perangkat USB (contoh: /dev/sdb)       ${m}|${r}"
    echo -e "${m}|       ${p}Jangan pilih perangkat USB yang berisi sistem          ${m}|${r}"
    echo -e "${m}+==============================================================+${r}"
    echo ""
}

# Fungsi untuk input perangkat usb yang mau dijadikan Bootable (OK)
function input_perangkat_usb(){
    while true; do
        read -p "${ik}[#] ${ip}Masukkan nama perangkat USB (contoh: /dev/sdb): " perangkat_usb
        if [[ -z "${perangkat_usb}" ]]; then
            echo -e "${m}[-] ${p}Nama perangkat USB tidak boleh kosong.${r}"
            continue
        fi
        if [[ ! -e "${perangkat_usb}" ]]; then
            echo -e "${m}[-] ${p}Perangkat USB '${perangkat_usb}' tidak ditemukan.${r}"
            continue
        fi
        if [[ "${perangkat_usb}" == *"sda"* ]] || [[ "${perangkat_usb}" == *"nvme0n1"* ]]; then
            echo -e "${m}[-] ${p}Perangkat USB '${perangkat_usb}' mungkin berisi sistem.${r}"
            echo -e "${m}[-] ${p}Sangat berbahaya untuk menimpa perangkat ini.${r}"
            read -p "${ik}[#] ${ip}Apakah Anda yakin ingin melanjutkan? (y/N): " lanjut
            if [[ "${lanjut}" != "y" && "${lanjut}" != "Y" ]]; then
                continue
            fi
        fi
        echo -e "${h}[+] ${p}Perangkat USB '${perangkat_usb}' ditemukan.${r}"
        break
    done
}

# Fungsi untuk input file ISO yang mau di flash (OK)
function input_file_iso(){
    while true; do
        read -p "${ik}[#] ${ip}Masukkan path file ISO (contoh: /home/user/os.iso): " file_iso
        file_iso=$(echo "${file_iso}" | sed -e "s/^[ \t]*//" -e "s/[ \t]*$//" -e "s/^['\"]//" -e "s/['\"]$//")
        if [[ -z "${file_iso}" ]]; then
            echo -e "${m}[-] ${p}Path file ISO tidak boleh kosong.${r}"
            continue
        fi
        if [[ ! -f "${file_iso}" ]]; then
            echo -e "${m}[-] ${p}File ISO '${file_iso}' tidak ditemukan.${r}"
            continue
        fi
        if [[ "${file_iso##*.}" != "iso" ]]; then
            echo -e "${m}[-] ${p}File '${file_iso}' bukan file ISO.${r}"
            continue
        fi
        echo -e "${h}[+] ${p}File ISO '${file_iso}' ditemukan.${r}"
        
        # Deteksi tipe OS dari ISO
        detect_os_type
        break
    done
}

# Fungsi untuk mendeteksi tipe OS (Linux atau Windows)
function detect_os_type() {
    echo -e "${b}[*] ${p}Mendeteksi tipe OS dari ISO...${r}"
    
    # Buat direktori mount sementara
    local temp_mount="/tmp/lufus_temp_mount"
    mkdir -p "$temp_mount"
    
    # Coba mount ISO
    if mount -o loop,ro "$file_iso" "$temp_mount" 2>/dev/null; then
        # Cek indikator Windows
        if [[ -d "$temp_mount/sources" && (-f "$temp_mount/sources/install.wim" || -f "$temp_mount/sources/install.esd") ]]; then
            os_type="Windows"
            echo -e "${h}[+] ${p}File ISO terdeteksi sebagai Windows.${r}"
        # Cek indikator Linux
        elif [[ -d "$temp_mount/casper" || -d "$temp_mount/live" || -f "$temp_mount/isolinux/isolinux.cfg" || -f "$temp_mount/boot/grub/grub.cfg" ]]; then
            os_type="Linux"
            echo -e "${h}[+] ${p}File ISO terdeteksi sebagai Linux.${r}"
        else
            # Tidak bisa mendeteksi secara otomatis
            os_type="Unknown"
            echo -e "${b}[*] ${p}Tidak dapat mendeteksi tipe OS secara otomatis.${r}"
            
            # Tanya pengguna
            while true; do
                read -p "${ik}[#] ${ip}Apakah ini ISO Windows atau Linux? (W/L): " os_choice
                if [[ "${os_choice,,}" == "w" ]]; then
                    os_type="Windows"
                    echo -e "${h}[+] ${p}Tipe OS diatur ke Windows.${r}"
                    break
                elif [[ "${os_choice,,}" == "l" ]]; then
                    os_type="Linux"
                    echo -e "${h}[+] ${p}Tipe OS diatur ke Linux.${r}"
                    break
                else
                    echo -e "${m}[-] ${p}Pilihan tidak valid. Masukkan W untuk Windows atau L untuk Linux.${r}"
                fi
            done
        fi
        
        # Unmount ISO
        umount "$temp_mount"
    else
        # Tidak bisa mount, tanya pengguna
        echo -e "${m}[-] ${p}Tidak dapat memeriksa isi ISO.${r}"
        while true; do
            read -p "${ik}[#] ${ip}Apakah ini ISO Windows atau Linux? (W/L): " os_choice
            if [[ "${os_choice,,}" == "w" ]]; then
                os_type="Windows"
                echo -e "${h}[+] ${p}Tipe OS diatur ke Windows.${r}"
                break
            elif [[ "${os_choice,,}" == "l" ]]; then
                os_type="Linux"
                echo -e "${h}[+] ${p}Tipe OS diatur ke Linux.${r}"
                break
            else
                echo -e "${m}[-] ${p}Pilihan tidak valid. Masukkan W untuk Windows atau L untuk Linux.${r}"
            fi
        done
    fi
    
    # Bersihkan mount point sementara
    rmdir "$temp_mount" 2>/dev/null
}

# Fungsi untuk konfirmasi apakah mau melanjutkan atau tidak (OK)
function mengonfirmasi(){
    echo ""
    echo -e "${m}+====================================================================+${r}"
    echo -e "${m}|                                                                    |${r}"
    echo -e "${m}|       ${p}Semua data pada perangkat USB '${perangkat_usb}' akan dihapus.       ${m}|${r}"
    echo -e "${m}|                                                                    |${r}"
    echo -e "${m}+====================================================================+${r}"
    echo 
    echo -e "${p}Informasi pembuatan Bootable USB:${r}"
    echo ""
    echo -e "${h}[+] ${p}Perangkat USB: ${perangkat_usb}${r}"
    echo -e "${h}[+] ${p}File ISO: ${file_iso}${r}"
    echo -e "${h}[+] ${p}Tipe OS: ${os_type}${r}"
    echo ""

    while true; do
        read -p "${ik}[#] ${ip}Apakah Anda ingin melanjutkannya (iya/tidak): " konfirmasi
        if [[ "${konfirmasi}" == "iya" ]]; then
            break
        elif [[ "${konfirmasi}" == "tidak" ]]; then
            echo -e "${m}[-] ${p}Proses membuat Bootable USB dibatalkan.${r}"
            exit 0
        else
            echo -e "${m}[-] ${p}Masukkan tidak valid. Harap masukkan 'iya/tidak'.${r}"
            continue
        fi
    done
}

# Fungsi untuk membuat bootable USB untuk Linux
function buat_bootable_linux(){
    echo -e "${b}[*] ${p}Memformat perangkat USB '${perangkat_usb}'...${r}"
    sleep 2
    
    # Hapus semua signature dari disk
    wipefs -a "${perangkat_usb}"
    
    # Format sebagai FAT32
    mkfs.vfat -F 32 "${perangkat_usb}" -n "LINUX_USB"
    if [[ $? -eq 0 ]]; then
        echo -e "${h}[+] ${p}Perangkat USB '${perangkat_usb}' berhasil diformat.${r}"
    else
        echo -e "${m}[-] ${p}Gagal memformat perangkat USB '${perangkat_usb}'.${r}"
        exit 1
    fi
    
    echo -e "${b}[*] ${p}Memulai proses flashing ISO '${file_iso}' ke perangkat USB '${perangkat_usb}'...${r}"
    sleep 2
    
    # Menggunakan dd untuk memindahkan data ISO ke USB
    dd if="${file_iso}" of="${perangkat_usb}" bs=4M status=progress oflag=sync
    
    if [[ $? -eq 0 ]]; then
        echo -e "${h}[+] ${p}Proses flashing selesai.${r}"
        return 0
    else
        echo -e "${m}[-] ${p}Gagal melakukan flashing ISO '${file_iso}' ke perangkat USB '${perangkat_usb}'.${r}"
        return 1
    fi
}

# Fungsi untuk membuat bootable USB untuk Windows
function buat_bootable_windows(){
    echo -e "${b}[*] ${p}Menyiapkan perangkat USB untuk Windows bootable...${r}"
    sleep 2
    
    # Membuat mount point sementara
    local mount_iso="/tmp/lufus_iso_mount"
    local mount_usb="/tmp/lufus_usb_mount"
    mkdir -p "$mount_iso" "$mount_usb"
    
    # Hapus semua signature dari disk
    echo -e "${b}[*] ${p}Menghapus signature dari perangkat USB...${r}"
    wipefs -a "${perangkat_usb}"
    
    # Membuat partisi baru
    echo -e "${b}[*] ${p}Membuat partisi pada perangkat USB...${r}"
    (
        echo o # Buat tabel partisi baru
        echo n # Buat partisi baru
        echo p # Partisi primer
        echo 1 # Partisi nomor 1
        echo   # Default first sector
        echo   # Default last sector
        echo t # Ubah tipe partisi
        echo 7 # NTFS/exFAT
        echo a # Set bootable flag
        echo w # Tulis perubahan
    ) | fdisk "${perangkat_usb}" > /dev/null 2>&1
    
    sleep 2
    
    # Format partisi sebagai NTFS
    echo -e "${b}[*] ${p}Memformat partisi sebagai NTFS...${r}"
    mkfs.ntfs -f -L "WINDOWS_USB" "${perangkat_usb}1"
    
    if [[ $? -ne 0 ]]; then
        echo -e "${m}[-] ${p}Gagal memformat partisi NTFS.${r}"
        rmdir "$mount_iso" "$mount_usb"
        exit 1
    fi
    
    # Mount ISO dan partisi USB
    echo -e "${b}[*] ${p}Memasang ISO dan perangkat USB...${r}"
    mount -o loop,ro "$file_iso" "$mount_iso"
    mount "${perangkat_usb}1" "$mount_usb"
    
    if [[ $? -ne 0 ]]; then
        echo -e "${m}[-] ${p}Gagal memasang perangkat USB.${r}"
        umount "$mount_iso" 2>/dev/null
        rmdir "$mount_iso" "$mount_usb"
        exit 1
    fi
    
    # Salin file dari ISO ke USB
    echo -e "${b}[*] ${p}Menyalin file dari ISO ke perangkat USB (ini mungkin memerlukan waktu beberapa menit)...${r}"
    rsync -ah --info=progress2 "$mount_iso/" "$mount_usb/"
    
    if [[ $? -ne 0 ]]; then
        echo -e "${m}[-] ${p}Gagal menyalin file dari ISO ke perangkat USB.${r}"
        umount "$mount_iso" "$mount_usb" 2>/dev/null
        rmdir "$mount_iso" "$mount_usb"
        exit 1
    fi
    
    # Unmount ISO dan USB
    echo -e "${b}[*] ${p}Menyelesaikan dan mem-flush cache...${r}"
    sync
    umount "$mount_iso" "$mount_usb"
    
    # Bersihkan mount point
    rmdir "$mount_iso" "$mount_usb"
    
    echo -e "${h}[+] ${p}Windows bootable USB berhasil dibuat.${r}"
    return 0
}

# Fungsi untuk membuat Bootable USB sesuai tipe OS
function buat_bootable(){
    # Unmount semua partisi dari perangkat yang dipilih
    echo -e "${b}[*] ${p}Meng-unmount perangkat USB '${perangkat_usb}'...${r}"
    for part in ${perangkat_usb}*; do
        if [[ "$part" != "$perangkat_usb" ]]; then
            umount "$part" 2>/dev/null
        fi
    done
    sleep 1
    
    # Buat bootable berdasarkan tipe OS
    if [[ "$os_type" == "Linux" ]]; then
        buat_bootable_linux
    elif [[ "$os_type" == "Windows" ]]; then
        buat_bootable_windows
    else
        echo -e "${m}[-] ${p}Tipe OS tidak dikenali. Membatalkan operasi.${r}"
        exit 1
    fi
    
    if [[ $? -eq 0 ]]; then
        echo -e "${b}[*] ${p}Meng-eject perangkat USB '${perangkat_usb}'...${r}"
        sleep 2
        eject "${perangkat_usb}"
        if [[ $? -eq 0 ]]; then
            echo -e "${h}[+] ${p}Perangkat USB '${perangkat_usb}' berhasil di-eject.${r}"
        else
            echo -e "${m}[-] ${p}Gagal meng-eject perangkat USB '${perangkat_usb}'.${r}"
        fi
        echo -e "${h}[+] ${p}Bootable USB berhasil dibuat dan siap digunakan.${r}"
        echo ""
        echo -e "${b}[*] ${p}Terima kasih telah menggunakan ${program} ${versi} :)${r}"
        exit 0
    else
        echo -e "${m}[-] ${p}Gagal membuat bootable USB.${r}"
        exit 1
    fi
}

# Fungsi untuk menampilkan menu bantuan
function tampilkan_bantuan() {
    echo -e "${p}Penggunaan: sudo bash $0 [OPSI]${r}"
    echo -e "${p}Opsi:${r}"
    echo -e "  ${h}-h, --help${p}      Menampilkan bantuan ini${r}"
    echo -e "  ${h}-v, --version${p}   Menampilkan versi program${r}"
    echo -e ""
    echo -e "${p}Contoh:${r}"
    echo -e "  ${b}sudo bash $0${r}"
    echo -e "  ${b}sudo bash $0 --help${r}"
    exit 0
}

# Proses argumen command line
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    tampilkan_bantuan
elif [[ "$1" == "-v" || "$1" == "--version" ]]; then
    echo -e "${program} ${versi}"
    exit 0
fi

# Manggil semua fungsi
cek_root
banner
cek_dependensi
deteksi_usb
input_perangkat_usb
input_file_iso
mengonfirmasi
buat_bootable
