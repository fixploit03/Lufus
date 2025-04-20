#!/bin/bash
#----------------------------------------------
#
#.......: Lufus
#.......: Bootable USB Creator for Linux
#.......: v1.0
#
# ---------------------------------------------
#
# Dibuat oleh: Rofi (Fixploit03)
# Github: https://github.com/fixploit03/Lufus
#
# ---------------------------------------------
#
# Script ini dibuat menggunakan <3 dan kopi.
# Script ini Open Source (Alias gratis)
#
#----------------------------------------------

# Tentang script (OK)
program="Lufus"
deskripsi="Bootable USB Creator for Linux"
versi="v1.0"
pembuat="Rofi (Fixploit03)"
github="https://github.com/fixploit03/Lufus"

# Variabel warna (OK)
m="\e[1;31m"   # Merah
h="\e[1;32m"   # Hijau
b="\e[1;34m"   # Biru
p="\e[1;37m"   # Putih
r="\e[0m"      # Reset
ik=$'\e[1;33m' # Input kuning
ib=$'\e[1;34m' # Input biru
ip=$'\e[1;37m' # Input putih

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
	echo -e "${b}|                                                         |${r}"
	echo -e "${b}|       ${p}${program}                                             ${b}|${r}"
	echo -e "${b}|       ${p}${deskripsi}                    ${b}|${r}"
	echo -e "${b}|       ${p}Versi: ${versi}                                       ${b}|${r}"
	echo -e "${b}|       ${p}Dibuat oleh: ${pembuat}                    ${b}|${r}"
	echo -e "${b}|       ${p}Github: ${github}       ${b}|${r}"
	echo -e "${b}|                                                         |${r}"
	echo -e "${b}+=========================================================+${r}"
	echo
}

# Fungsi untuk mendeteksi perangkat USB yang terpasang (OK)
function deteksi_usb(){
	echo -e "${b}[*] ${p}Mendeteksi perangkat USB yang terpasang...${r}"
	sleep 3
	echo -e "${h}[+] ${p}Perangkat USB yang terpasang:${r}"
	echo ""
	parted -l
	echo -e "${m}+==============================================================+${r}"
	echo -e "${m}|                                                              |${r}"
	echo -e "${m}|       ${p}Perhatikan nama perangkat USB (contoh: /dev/sdb)       ${m}|${r}"
	echo -e "${m}|       ${p}Jangan pilih perangkat USB yang berisi sistem          ${m}|${r}"
	echo -e "${m}|                                                              |${r}"
	echo -e "${m}+==============================================================+${r}"
	echo ""
}

# Fungsi untuk input perangkat USB yang mau dijadikan Bootable (OK)
function input_perangkat_usb(){
	while true; do
		read -p "${ik}[#] ${ip}Masukkan nama perangkat USB (contoh: /dev/sdb): " perangkat_usb
		if [[ -z "${perangkat_usb}" ]]; then
			echo -e "${m}[-] ${p}Nama perangkat USB tidak boleh kosong.${r}"
			continue
		fi
		if [[ ! -e "${perangkat_usb}" ]]; then
			echo -e "${m}[-] ${p}Perangkat USB tidak ditemukan.${r}"
			continue
		fi
		if [[ "${perangkat_usb}" == *"sda"* ]] || [[ "${perangkat_usb}" == *"nvme0n1"* ]]; then
			echo -e "${m}[-] ${p}Perangkat USB mungkin berisi sistem.${r}"
			echo -e "${m}[-] ${p}Sangat berbahaya untuk menimpa perangkat ini.${r}"
			continue
		fi
		echo -e "${h}[+] ${p}Perangkat USB ditemukan.${r}"
		break
	done
}

# Fungsi untuk input file ISO yang mau di-flash (OK)
function input_file_iso(){
	while true; do
		read -p "${ik}[#] ${ip}Masukkan path file ISO Linux: " file_iso
		file_iso=$(echo "${file_iso}" | sed -e "s/^[ \t]*//" -e "s/[ \t]*$//" -e "s/^['\"]//" -e "s/['\"]$//")
		if [[ -z "${file_iso}" ]]; then
			echo -e "${m}[-] ${p}Path file ISO tidak boleh kosong.${r}"
			continue
		fi
		if [[ ! -f "${file_iso}" ]]; then
			echo -e "${m}[-] ${p}File ISO tidak ditemukan.${r}"
			continue
		fi
		if [[ "${file_iso##*.}" != "iso" ]]; then
			echo -e "${m}[-] ${p}File bukan file ISO.${r}"
			continue
		fi
		echo -e "${h}[+] ${p}File ISO ditemukan.${r}"
		break
	done

}

# Fungsi untuk konfirmasi apakah mau melanjutkan atau tidak (OK)
function mengonfirmasi(){
	echo ""
	echo -e "${m}+========================================================+${r}"
	echo -e "${m}|                                                        |${r}"
	echo -e "${m}|       ${p}Semua data pada perangkat USB akan dihapus       ${m}|${r}"
	echo -e "${m}|                                                        |${r}"
	echo -e "${m}+========================================================+${r}"
	echo ""
	echo -e "${p}Informasi pembuatan Bootable USB:${r}"
	echo ""
	echo -e "${h}[+] ${p}Perangkat USB: ${perangkat_usb}${r}"
	echo -e "${h}[+] ${p}File ISO: ${file_iso}${r}"
	echo ""

	while true; do
		read -p "${ik}[#] ${ip}Apakah Anda ingin melanjutkannya (iya/tidak): " konfirmasi
		if [[ "${konfirmasi}" == "iya" ]]; then
			:
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

# Fungsi untuk membuat Bootable USB (OK)
function buat_bootable(){
	# Meng-unmount jika ada partisi yang ter-mount (terpasang)
	if findmnt | grep -q "${perangkat_usb}"; then
            	umount "${perangkat_usb}"* &>/dev/null
	fi
	# Menghapus semua signature filesystem dan partition table
	wipefs -a "${perangkat_usb}" &>/dev/null
	echo -e "${b}[*] ${p}Memformat perangkat USB...${r}"
	sleep 3
	mkfs.ext4 -L BOOTABLE "${perangkat_usb}"
	if [[ $? -eq 0 ]]; then
		echo -e "${h}[+] ${p}Perangkat USB berhasil diformat.${r}"
	else
		echo -e "${m}[-] ${p}Gagal memformat perangkat USB.${r}"
		exit 1
	fi
	echo -e "${b}[*] ${p}Memulai proses flashing ISO ke perangkat USB...${r}"
	sleep 3
	pv "${file_iso}" | dd of="${perangkat_usb}" bs=4M oflag=sync
	if [[ $? -eq 0 ]]; then
		echo -e "${h}[+] ${p}Proses flashing ISO ke perangkat USB selesai.${r}"
		echo -e "${b}[*] ${p}Meng-eject perangkat USB...${r}"
		sleep 3
		eject "${perangkat_usb}"
		if [[ $? -eq 0 ]]; then
    			echo -e "${h}[+] ${p}Perangkat USB berhasil di-eject.${r}"
		else
    			echo -e "${m}[-] ${p}Gagal meng-eject perangkat USB.${r}"
    			exit 1
		fi
		echo -e "${h}[+] ${p}Bootable USB berhasil dibuat dan siap digunakan.${r}"
		echo ""
		echo -e "${b}[*] ${p}Terima kasih telah menggunakan ${program} :)${r}"
		exit 0
	else
		echo -e "${m}[-] ${p}Gagal melakukan flashing ISO ke perangkat USB.${r}"
	        exit 1
	fi

}

# Manggil semua fungsi
cek_root
banner
deteksi_usb
input_perangkat_usb
input_file_iso
mengonfirmasi
buat_bootable
