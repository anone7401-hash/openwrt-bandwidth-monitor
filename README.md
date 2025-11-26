# OpenWrt Bandwidth Monitor

Aplikasi monitoring bandwidth real-time untuk OpenWrt dashboard yang membantu Anda memantau penggunaan jaringan di semua perangkat yang terhubung.

## Fitur

### 📊 Dashboard Utama

- **Connected Users** - Menampilkan jumlah perangkat yang sedang terhubung ke jaringan Anda
- **Total Download** - Statistik total data yang telah diunduh oleh semua perangkat
- **Total Upload** - Statistik total data yang telah diunggah oleh semua perangkat
- **Total Bandwidth** - Ringkasan penggunaan bandwidth keseluruhan

### 🔍 Monitoring Perangkat Individual

Pantau detail lengkap setiap perangkat yang terhubung:

- **Device Name** - Nama perangkat
- **IP Address** - Alamat IP perangkat di jaringan lokal
- **MAC Address** - Identitas unik perangkat
- **Status** - Status koneksi perangkat (Online/Offline)
- **Signal Strength** - Kekuatan sinyal WiFi (persentase)
- **Connected Time** - Durasi perangkat terhubung

### 📈 Data Usage Tracking

- Download per device - Tracking penggunaan data download individual
- Upload per device - Tracking penggunaan data upload individual
- Total Usage - Total penggunaan data per perangkat

### 🔧 Fitur Tambahan

- **Search** - Cari perangkat berdasarkan nama, IP address, atau MAC address
- **Filter Status** - Filter perangkat berdasarkan status koneksi
- **Sort Options** - Urutkan perangkat berdasarkan total penggunaan bandwidth
- **Auto Refresh** - Update data otomatis setiap 5 detik
- **Dark Mode UI** - Antarmuka modern dengan dark theme

## Instalasi

Gunakan command berikut untuk melakukan instalasi otomatis:

```bash
sh <(curl -s https://raw.githubusercontent.com/anone7401-hash/openwrt-bandwidth-monitor/main/install.sh)
```

Setelah instalasi selesai, akses dashboard melalui OpenWrt Dashboard Anda di `http://192.168.1.1/bandwidth-monitor/)` (atau IP router Anda)/bandwidth-monitor/

## Requirements

- OpenWrt router
- Akses SSH ke router
- curl atau wget
- Koneksi internet untuk menjalankan installer

## Penggunaan

1. Buka OpenWrt Dashboard di browser Anda
1. Cari aplikasi “Bandwidth Monitor”
1. Klik untuk membuka dashboard monitoring
1. Monitor penggunaan bandwidth real-time dari semua perangkat Anda

## Troubleshooting

Jika mengalami masalah instalasi, pastikan:

- Router sudah memiliki akses internet
- Anda memiliki akses root/admin di router
- Port yang diperlukan tidak terblokir oleh firewall

## Kontribusi

Kontribusi sangat diterima! Silakan fork repository dan buat pull request untuk improvement.

## Lisensi

Lihat file LICENSE untuk detail lebih lanjut.

-----

Made with ❤️ for OpenWrt users
