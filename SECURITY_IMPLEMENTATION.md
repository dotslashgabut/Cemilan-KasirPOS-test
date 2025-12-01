# Implementasi JWT & CORS (Node.js)

Dokumen ini menjelaskan secara rinci penerapan **JSON Web Token (JWT)** untuk autentikasi dan **Cross-Origin Resource Sharing (CORS)** pada backend Node.js.

## 🔐 1. Implementasi JWT (JSON Web Token)

JWT digunakan untuk mengamankan komunikasi antara Frontend (React) dan Backend (Node.js).

### Alur Kerja

1.  **Login**:
    *   User mengirim kredensial ke `/api/login`.
    *   Server memverifikasi dengan `bcrypt.compare`.
    *   Jika valid, server men-generate token menggunakan `jsonwebtoken`.
    *   Payload token berisi `id`, `username`, dan `role`.

2.  **Middleware Autentikasi**:
    *   Setiap route yang dilindungi (misal `/api/transactions`) menggunakan middleware `authenticateToken`.
    *   Middleware ini mengecek header `Authorization: Bearer <token>`.
    *   Jika token valid, `req.user` diisi dengan data user.
    *   Jika tidak, return `401 Unauthorized` atau `403 Forbidden`.

### Kode Implementasi (Ringkasan)

```javascript
// middleware/auth.js
const jwt = require('jsonwebtoken');

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (token == null) return res.sendStatus(401);

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
}
```

## 🌐 2. Implementasi CORS

CORS diatur menggunakan library `cors`.

### Konfigurasi

Di file `server/index.js`:

```javascript
const cors = require('cors');

const corsOptions = {
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://yourdomain.com'] // Production: Whitelist domain
    : '*',                       // Development: Allow all
  credentials: true,             // Izinkan cookies/auth headers
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));
```

## 🚀 3. Skenario Deployment

### Skenario A: Satu Domain (Subfolder/Proxy)
*   Frontend: `https://domain.com`
*   Backend: `https://domain.com/api`
*   **CORS**: Relatif aman, bisa set origin ke `https://domain.com`.

### Skenario B: Beda Domain (Subdomain)
*   Frontend: `https://app.domain.com`
*   Backend: `https://api.domain.com`
*   **CORS**: **Wajib** set origin ke `https://app.domain.com`.

## ⚠️ Troubleshooting

### 1. CORS Error di Browser
*   Pastikan domain frontend ada di whitelist `origin` pada konfigurasi `cors` di backend.
*   Pastikan header `Access-Control-Allow-Origin` dikirim oleh server.

### 2. 401 Unauthorized
*   Pastikan frontend mengirim header `Authorization: Bearer <token>`.
*   Pastikan `JWT_SECRET` di backend sama saat generate dan verify (jangan ganti secret saat server jalan kecuali restart).

### 3. Token Expired
*   Frontend harus menangani error token expired (biasanya 403) dengan me-logout user atau refresh token (jika diimplementasikan).
