# Fix: Masalah HPP Minus di Laba Rugi

## 🐛 Masalah
Ketika transaksi penjualan dihapus, di tab 'Laba Rugi' muncul nilai **minus** karena perhitungan HPP yang tidak tepat.

## 🔍 Root Cause Analysis

### Skenario Masalah:
1. **Transaksi Penjualan Normal** dicatat:
   - Jual 10 barang @ Rp 100.000 (HPP @ Rp 60.000)
   - Revenue: Rp 1.000.000
   - COGS: Rp 600.000

2. **Transaksi RETURN** dibuat:
   - Retur 5 barang
   - `totalAmount`: -Rp 500.000
   - HPP items: 5 x Rp 60.000 = Rp 300.000

3. **Transaksi Penjualan Asli DIHAPUS** (problem!):
   - Transaksi RETURN masih ada (orphan data)
   - Transaksi penjualan sudah tidak ada

4. **Hasil Perhitungan Laba Rugi:**
   - Revenue = 0 + (-500.000) = **-Rp 500.000** ❌
   - COGS = 0 - 300.000 = **-Rp 300.000** ❌
   - Gross Profit = -500.000 - (-300.000) = **-Rp 200.000** ❌

### Penyebab Utama:
**Data Integrity Issue** - Ada transaksi RETURN yang merujuk ke transaksi yang sudah tidak ada (orphan record).

## ✅ Solusi yang Diterapkan

### 1. **Cascade Delete (Penghapusan Berjenjang)**
Mengimplementasikan logika penghapusan otomatis di `services/api.ts` (`deleteTransaction`). Ketika transaksi penjualan dihapus, sistem akan secara otomatis mencari dan menghapus semua data terkait.

**Lokasi:** `services/api.ts` (function `deleteTransaction`)

**Logika Cascade Delete:**
1. **Cek Transaksi RETURN Terkait:**
   - Sistem mencari semua transaksi tipe `RETURN` yang memiliki `originalTransactionId` sama dengan transaksi yang akan dihapus.
2. **Hapus Transaksi RETURN:**
   - Untuk setiap transaksi RETURN yang ditemukan:
     - **Revert Stock:** Stok barang dikurangi kembali (karena retur sebelumnya menambah stok).
     - **Hapus Cashflow:** Menghapus data arus kas terkait retur.
     - **Hapus Transaksi:** Menghapus record transaksi retur dari database.
3. **Revert Stock Transaksi Utama:**
   - Stok barang dikembalikan (ditambah) sesuai jumlah yang terjual di transaksi asli.
4. **Hapus Cashflow Transaksi Utama:**
   - Menghapus data arus kas terkait transaksi penjualan.
5. **Hapus Transaksi Utama:**
   - Menghapus record transaksi penjualan dari database.

**Benefit:**
- ✅ **User Experience Lebih Baik:** User tidak perlu menghapus retur satu per satu secara manual.
- ✅ **Data Integrity Terjamin:** Tidak ada lagi data orphan (retur tanpa induk).
- ✅ **Laporan Akurat:** Mencegah HPP minus di laporan laba rugi.

### 2. **Restore Debt Logic (Saat Menghapus Retur)**
Jika yang dihapus adalah transaksi RETURN (bukan penjualan), sistem akan:
1. Mencari transaksi penjualan asli.
2. Menghapus entri "Potong Utang" di riwayat pembayaran transaksi asli.
3. Menghitung ulang `amountPaid` dan `paymentStatus` transaksi asli.
4. Mengupdate status `isReturned` jika tidak ada retur lain yang tersisa.

## 📋 Workflow Baru
Pengguna dapat langsung menghapus transaksi penjualan, dan sistem akan otomatis membersihkan semua data terkait (retur, stok, cashflow).

## 🧪 Testing Checklist

- [ ] **Skenario 1: Hapus Penjualan dengan Retur**
    - [ ] Buat transaksi penjualan normal
    - [ ] Buat transaksi retur untuk transaksi tersebut
    - [ ] Hapus transaksi penjualan asli
    - [ ] **Verifikasi:** Transaksi retur ikut terhapus
    - [ ] **Verifikasi:** Stok barang kembali normal (seolah tidak ada jual beli)
    - [ ] **Verifikasi:** Cashflow terkait penjualan dan retur terhapus

- [ ] **Skenario 2: Hapus Retur Saja**
    - [ ] Buat transaksi penjualan (Kredit/Tempo)
    - [ ] Buat transaksi retur (Potong Utang)
    - [ ] Hapus transaksi retur
    - [ ] **Verifikasi:** Hutang di transaksi penjualan kembali bertambah
    - [ ] **Verifikasi:** Status pembayaran terupdate (misal dari LUNAS kembali ke SEBAGIAN)
    - [ ] **Verifikasi:** Stok barang berkurang (karena batal retur)

## 🔗 Related Files

- `services/api.ts` - Core logic for `deleteTransaction` (Cascade Delete & Debt Restore)
- `pages/Finance.tsx` - UI for triggering deletion
- `types.ts` - Transaction types definition

---

**Fixed by:** AI Assistant
**Date:** 2025-11-24
**Issue:** HPP minus di laba rugi & Data Integrity
