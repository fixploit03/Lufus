<h1 align="center">
  <img src="https://github.com/fixploit03/Lufus/blob/main/lufus.png" width=100 height=100/><br>
Lufus</h1>

<p align="center">
  <span>Bootable USB Creator for Linux</span>
</p>

<p align="center">
  <a href="https://github.com/fixploit03/Lufus#apa-itu-lufus">Apa itu Lufus?</a>
  &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="https://github.com/fixploit03/Lufus#cara-instal">Cara Instal</a>
  &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="https://github.com/fixploit03/Lufus/blob/main/LICENSE">Lisensi</a>
</p>

## Apa itu Lufus?

[![Platform](https://img.shields.io/badge/Platform-Linux-yellow?logo=linux)](https://www.kernel.org/)
[![Bahasa](https://img.shields.io/badge/Bahasa-Bash-green?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![Lisensi](https://img.shields.io/badge/Lisensi-MIT-lightgreen?logo=open-source-initiative)](https://github.com/fixploit03/Lufus/blob/main/LICENSE)

`Lufus` adalah sebuah script Bash untuk membuat Bootable USB di Linux. Script ini memungkinkan Anda untuk memilih perangkat USB dan file ISO untuk di-flash ke perangkat USB, sehingga Anda dapat membuat USB yang dapat digunakan untuk menginstal atau menjalankan Linux.

## Persyaratan

- Sistem operasi Linux
- Hak akses root / sudo
- Perangkat USB yang akan dijadikan bootable
- File ISO Linux

## Cara Instal

Buka terminal Linux, ketikkan perintah berikut ini:

```
sudo apt-get update -y
sudo apt-get install git -y
cd ~/Desktop
git clone https://github.com/fixploit03/Lufus.git
cd Lufus
chmod +x lufus.sh
sudo ./lufus.sh
```

## Cara Penggunaan

1. Jalankan script dengan perintah `sudo ./lufus.sh`
2. Script akan mendeteksi dan menampilkan semua perangkat penyimpanan yang terpasang
3. Masukkan nama perangkat USB Anda (contoh: `/dev/sdb`)
4. Masukkan path lengkap ke file ISO yang ingin di-flash
5. Konfirmasi pilihan Anda dengan mengetik `iya`
6. Tunggu proses flashing selesai
7. Perangkat USB bootable Anda siap digunakan!

> Peringatan: Semua data pada perangkat USB target akan dihapus selama proses ini. Pastikan untuk mencadangkan data penting sebelum menggunakan Lufus.

## Demonstrasi

[Link YT (Next)]()

## Lisensi

Script ini dilisensikan dibawah [Lisensi MIT](https://github.com/fixploit03/Lufus/blob/main/LICENSE).
