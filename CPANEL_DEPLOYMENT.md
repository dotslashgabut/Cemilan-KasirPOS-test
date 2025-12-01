# 🌐 Deploy ke cPanel Shared Hosting - React + Node.js

## 📋 Struktur Folder di cPanel

```
/home/username/
├── cemilan-backend/        # ← Folder Backend Node.js (Di luar public_html)
│   ├── index.js
│   ├── package.json
│   ├── .env
│   └── ...
│
public_html/                # ← Root domain (https://yourdomain.com)
├── index.html             # ← Frontend React (Build result)
├── assets/                # ← React build assets
└── .htaccess              # ← Frontend routing
```

**URLs:**
- Frontend: `https://yourdomain.com/`
- Backend API: `https://api.yourdomain.com/` (Subdomain) atau `https://yourdomain.com/api/` (Subfolder/Proxy)

---

## 🚀 Langkah 1: Persiapan Database

### 1.1 Buat Database di cPanel

1. Login ke **cPanel**
2. Buka **MySQL Database Wizard** atau **MySQL Databases**
3. **Buat Database:**
   - Database Name: `cemilan_pos` 
   - cPanel akan otomatis prefix: `username_cemilan_pos`

4. **Buat User:**
   - Username: `cemilan_admin`
   - Password: `[strong_password]`
   - cPanel akan otomatis prefix: `username_cemilan_admin`

5. **Set Privileges:**
   - Pilih: **ALL PRIVILEGES**
   - Klik: **Make Changes**

---

## 📦 Langkah 2: Setup Backend Node.js

### 2.1 Upload Files Backend

1. Buka **File Manager** di cPanel.
2. Navigate ke root directory (`/home/username/`).
3. Buat folder baru: `cemilan-backend`.
4. Upload semua file dari folder `server` project Anda ke dalam folder `cemilan-backend` tersebut.
   - **JANGAN** upload folder `node_modules`.
   - Pastikan `package.json`, `index.js` (atau app.js), dan folder source code lainnya terupload.

### 2.2 Setup Node.js App di cPanel

1. Di dashboard cPanel, cari menu **"Setup Node.js App"** (di bagian Software).
2. Klik **Create Application**.
3. Isi form konfigurasi:
   - **Node.js Version**: Pilih versi 18.x atau 20.x (sesuai development).
   - **Application Mode**: `Production`.
   - **Application Root**: `cemilan-backend` (nama folder yang tadi dibuat).
   - **Application URL**: Pilih domain/subdomain (misal `api.yourdomain.com`).
   - **Application Startup File**: `index.js` (atau entry point backend Anda).
4. Klik **Create**.

### 2.3 Install Dependencies

1. Setelah app dibuat, scroll ke bawah di halaman detail app tersebut.
2. Klik tombol **Run NPM Install**.
   - cPanel akan otomatis membaca `package.json` dan menginstall dependencies.
   - Jika tombol tidak muncul atau gagal, Anda bisa masuk via Terminal (SSH) dan jalankan `npm install` di folder `cemilan-backend`.

### 2.4 Konfigurasi Environment Variables

1. Masih di halaman detail Node.js App.
2. Klik **Environment Variables** (atau edit file `.env` manual di File Manager).
3. Tambahkan variabel:
   - `PORT`: (Biarkan kosong atau sesuai default cPanel, biasanya otomatis)
   - `DB_HOST`: `localhost`
   - `DB_NAME`: `username_cemilan_pos`
   - `DB_USER`: `username_cemilan_admin`
   - `DB_PASS`: `password_database_anda`
   - `JWT_SECRET`: `string_rahasia_anda`
   - `NODE_ENV`: `production`
4. Klik **Save** dan **Restart** aplikasi.

---

## 🎨 Langkah 3: Build & Upload Frontend

### 3.1 Update Frontend .env

Di **project development** Anda, edit file `.env.production`:

```env
VITE_API_URL=https://api.yourdomain.com/api
```
*(Sesuaikan dengan URL aplikasi Node.js Anda)*

### 3.2 Build Frontend

Di terminal project development:

```bash
npm run build
```

Output: Folder `dist/` berisi file production.

### 3.3 Upload Frontend ke cPanel

1. Buka **File Manager**.
2. Navigate ke `public_html/` (atau folder domain frontend Anda).
3. Upload **ISI** dari folder `dist/`:
   - `index.html`
   - `assets/` folder
   - Dan file lainnya.

### 3.4 Setup .htaccess Frontend

Buat/edit file `.htaccess` di `public_html/` agar React Router berjalan lancar:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    
    # Don't rewrite existing files/directories
    RewriteCond %{REQUEST_FILENAME} -f [OR]
    RewriteCond %{REQUEST_FILENAME} -d
    RewriteRule ^ - [L]
    
    # Rewrite everything else to index.html (React Router)
    RewriteRule ^ index.html [L]
</IfModule>
```

---

## ✅ Langkah 4: Testing

1. **Test Backend**: Buka `https://api.yourdomain.com/api/health` (jika ada) atau endpoint lain.
2. **Test Frontend**: Buka `https://yourdomain.com`.
3. **Login**: Coba login dengan user default (`superadmin` / `password`).

---

## 🔧 Troubleshooting

### ❌ Backend 503 Service Unavailable
- Cek log Node.js di cPanel (biasanya `stderr.log`).
- Pastikan port tidak hardcoded (gunakan `process.env.PORT`).
- Pastikan script startup benar (`index.js`).

### ❌ Database Connection Error
- Pastikan user database memiliki privileges.
- Cek password dan nama database di environment variables.

### ❌ Frontend 404 on Refresh
- Pastikan `.htaccess` sudah benar.

---

## 🆘 Support

Jika fitur "Setup Node.js App" tidak ada di cPanel Anda, hubungi provider hosting Anda. Fitur ini memerlukan CloudLinux dan LVE Manager yang biasanya tersedia di paket hosting modern.
