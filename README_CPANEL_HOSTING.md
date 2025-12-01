# Panduan Hosting ke cPanel (Frontend React + Backend Node.js)

Panduan ini menjelaskan cara meng-hosting aplikasi Cemilan KasirPOS menggunakan **Backend Node.js** ke shared hosting cPanel yang mendukung fitur **Setup Node.js App**.

## 📋 Prasyarat

1.  Hosting cPanel dengan fitur **Setup Node.js App** (CloudLinux).
2.  Domain atau subdomain aktif.
3.  Akses ke File Manager dan Database Wizard.

## 🏗️ Langkah 1: Persiapan Database

1.  Login ke cPanel.
2.  Buka **MySQL Database Wizard**.
3.  Buat database baru (contoh: `u12345_cemilan`).
4.  Buat user database baru (contoh: `u12345_admin`) dan passwordnya.
5.  **PENTING**: Berikan hak akses **ALL PRIVILEGES**.

## ⚙️ Langkah 2: Setup Backend (Node.js)

1.  **Upload File**:
    *   Buka File Manager.
    *   Buat folder di root (di luar `public_html`), misal `cemilan-backend`.
    *   Upload isi folder `server` dari komputer Anda ke folder tersebut (kecuali `node_modules`).
2.  **Setup Node.js App**:
    *   Buka menu **Setup Node.js App**.
    *   Klik **Create Application**.
    *   **Node.js Version**: 18.x (atau terbaru).
    *   **Application Mode**: Production.
    *   **Application Root**: `cemilan-backend`.
    *   **Application URL**: `api.tokocemilan.com` (Subdomain disarankan).
    *   **Startup File**: `index.js`.
    *   Klik **Create**.
3.  **Install Dependencies**:
    *   Klik **Run NPM Install**.
4.  **Environment Variables**:
    *   Tambahkan variabel database (`DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS`, `JWT_SECRET`) di menu Environment Variables aplikasi tersebut.
    *   Restart aplikasi.

## 🖥️ Langkah 3: Build & Upload Frontend (React)

1.  **Edit Environment Variable Frontend**:
    *   Edit `.env.production` di komputer lokal.
    *   Set `VITE_API_URL` ke URL aplikasi Node.js Anda (misal: `https://api.tokocemilan.com/api`).
2.  **Build Project**:
    *   Jalankan `npm run build`.
3.  **Upload ke cPanel**:
    *   Upload isi folder `dist` ke `public_html` (atau folder domain frontend).
4.  **Setup .htaccess**:
    *   Pastikan ada file `.htaccess` untuk menangani routing React (lihat `CPANEL_DEPLOYMENT.md` untuk kodenya).

## ✅ Langkah 4: Testing

Buka website frontend Anda dan coba login. Jika berhasil, berarti Frontend dan Backend Node.js sudah terhubung.

---

## 🛡️ Troubleshooting

1.  **503 Service Unavailable (Backend)**:
    *   Cek log error di cPanel.
    *   Pastikan `index.js` berjalan dengan benar.
2.  **Database Error**:
    *   Cek kredensial database di Environment Variables.
