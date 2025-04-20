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
  <a href="https://github.com/fixploit03/Lufus#cara-penggunaan">Cara Penggunaan</a>
  &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="https://github.com/fixploit03/Lufus/blob/main/LICENSE">Lisensi</a>
</p>

## Apa itu Lufus?

[![Platform](https://img.shields.io/badge/Platform-Linux-yellow?logo=linux)](https://www.kernel.org/)
[![Bahasa](https://img.shields.io/badge/Bahasa-Bash-green?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![Lisensi](https://img.shields.io/badge/Lisensi-MIT-lightgreen?logo=open-source-initiative)](https://github.com/fixploit03/Lufus/blob/main/LICENSE)

![](https://github.com/fixploit03/Lufus/blob/main/Screenshot.png)

`Lufus` adalah sebuah script Bash untuk membuat Bootable USB di Linux. Script ini memungkinkan Anda untuk memilih perangkat USB dan file ISO untuk di-flash ke perangkat USB, sehingga Anda dapat membuat USB yang dapat digunakan untuk menginstal atau menjalankan Linux.

> Lufus tidak mendukung pembuatan USB bootable untuk sistem operasi Windows.

## Persyaratan

- Sistem operasi Linux
- Hak akses root / sudo
- Perangkat USB yang akan dijadikan bootable
- File ISO Linux

## Cara Instal

Buka terminal Linux, ketikkan perintah berikut ini:

```
# Update repositori Linux
$ sudo apt-get update -y

# Instal dependensi yang diperlukan
$ sudo apt install bash parted util-linux e2fsprogs coreutils eject pv git -y

# Pindah ke direktori Desktop
$ cd ~/Desktop

# Kloning repositori Lufus dari Github
$ git clone https://github.com/fixploit03/Lufus.git

# Pindah ke direktori Lufus
$ cd Lufus

# Berikan izin eksekusi terhadap script
$ chmod +x lufus.sh
```

## Cara Penggunaan

Buka terminal Linux, ketikkan perintah berikut ini:

```
$ sudo ./lufus.sh
```

Ikuti langkah-langkah atau instruksi yang diberikan.

> #### Peringatan
>
> Semua data pada perangkat USB akan dihapus! Pastikan Anda telah melakukan backup sebelum melanjutkan.

## Lisensi

Script ini dilisensikan dibawah [Lisensi MIT](https://github.com/fixploit03/Lufus/blob/main/LICENSE).
