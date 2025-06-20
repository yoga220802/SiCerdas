<div align="center">
  <img src="https://github.com/yoga220802/SiCerdas/blob/main/assets/images/app_logo.png?raw=true" alt="Logo SiCerdas" width="120" style="border-radius: 15%;">
  <h1><b>SiCerdas</b></h1>
  <p>
    Aplikasi berita cerdas berbasis Flutter yang membawa informasi terkini ke ujung jari Anda, dilengkapi dengan asisten AI untuk pengalaman membaca yang lebih mendalam.
  </p>
  <p>
    <a href="#"><img src="https://img.shields.io/badge/platform-multiplatform-blue?style=for-the-badge&logo=flutter"></a>
    <a href="#"><img src="https://img.shields.io/badge/build-passing-brightgreen?style=for-the-badge&logo=githubactions"></a>
    <a href="#"><img src="https://img.shields.io/github/license/yoga220802/sicerdas?style=for-the-badge&logo=apache"></a>
  </p>
</div>

---

## 🌟 Tentang Proyek

**SiCerdas** bukan sekadar aplikasi berita biasa. Dibangun dengan *passion* menggunakan Flutter, aplikasi ini dirancang untuk memberikan pengalaman membaca berita yang modern, interaktif, dan personal. Pengguna tidak hanya dapat membaca berita dari berbagai kategori, tetapi juga dapat berkontribusi dengan menulis berita mereka sendiri. Fitur unggulan kami, **Asisten AI**, memungkinkan pengguna untuk bertanya dan mendapatkan ringkasan dari berita yang sedang dibaca, membuat pemahaman informasi menjadi lebih cepat dan mudah.

## ✨ Fitur Utama

* 🔐 **Autentikasi Pengguna**: Sistem login dan registrasi yang aman menggunakan Firebase Authentication.
* 📰 **Berita Terkini & Kategori**: Jelajahi berita dari berbagai kategori seperti Teknologi, Olahraga, Hiburan, dan lainnya.
* ✍️ **Kontribusi Pengguna (CRUD)**: Pengguna dapat membuat, membaca, memperbarui, dan menghapus artikel berita mereka sendiri.
* 🖼️ **Upload Gambar**: Integrasi dengan Cloudinary untuk mengunggah gambar berita dengan mudah.
* 🔍 **Pencarian Cerdas**: Temukan berita yang relevan dengan cepat melalui fitur pencarian yang responsif.
* 🤖 **Asisten AI (Gemini)**: Dapatkan ringkasan atau ajukan pertanyaan tentang konten berita kepada asisten AI kami yang didukung oleh Google Generative AI.
* 👤 **Manajemen Profil**: Personalisasi akun Anda dengan memperbarui nama dan foto profil.
* 📱 **UI/UX Modern**: Antarmuka yang bersih, modern, dan intuitif dirancang untuk kenyamanan membaca di berbagai perangkat.
* 🌐 **Multi-platform**: Dijalankan dengan lancar di Android, iOS, dan Web dari satu basis kode.

## 🚀 Teknologi yang Digunakan

| **Komponen**           | **Teknologi/Layanan**                                                                                                                            |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Framework**          | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge\&logo=flutter\&logoColor=white)                                       |
| **Bahasa**             | ![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge\&logo=dart\&logoColor=white)                                                |
| **Backend & Database** | ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge\&logo=firebase\&logoColor=black) (Auth, Realtime Database, Storage) |
| **AI & ML**            | ![Google AI](https://img.shields.io/badge/Google_AI-4285F4?style=for-the-badge\&logo=google\&logoColor=white) (Gemini API)                       |
| **Media Storage**      | ![Cloudinary](https://img.shields.io/badge/Cloudinary-3448C5?style=for-the-badge\&logo=cloudinary\&logoColor=white)                              |
| **Manajemen State**    | `Provider`                                                                                                                                       |
| **Lainnya**            | `http`, `google_fonts`, `image_picker`                                                                                                           |

## 🎨 UI/UX Desain

Desain antarmuka dibuat dengan mempertimbangkan kenyamanan dan pengalaman pengguna secara keseluruhan. Anda dapat melihat prototype desain kami melalui tautan berikut:

👉 [Figma Desain UI/UX SiCerdas](https://www.figma.com/design/ckug88jnL2Gzyy5f4Dnm3Z/UI-Artikel-Berita?node-id=0-1&t=afvbXlZm1tfIYzZH-1)

## 📂 Struktur Proyek

```
lib/
├── app/                # Konfigurasi global, tema, dan widget umum
│   ├── theme/          # Pengaturan tema aplikasi
│   └── widgets/        # Widget yang dapat digunakan kembali
├── data/               # Model data dan layanan (API, Database)
│   ├── models/         # Kelas-kelas model data
│   └── services/       # Interaksi dengan API dan Firebase
├── features/           # Direktori untuk setiap fitur aplikasi
│   ├── auth/           # Autentikasi (Login, Register)
│   ├── home/           # Halaman utama dan detail berita
│   ├── my_news/        # Fitur CRUD berita pengguna
│   ├── profile/        # Profil pengguna
│   ├── chat/           # Fitur chat dengan AI (Gemini)
│   └── ...             # Fitur tambahan lainnya
└── main.dart           # Titik masuk utama aplikasi
```

## 🛠️ Panduan Instalasi & Setup

**Prasyarat:**

* Flutter SDK (versi 3.16.8 atau lebih tinggi)
* Koneksi internet
* Emulator atau perangkat fisik

**Langkah-langkah:**

1. Clone repositori:

```sh
git clone https://github.com/yoga220802/sicerdas.git
cd sicerdas
```

2. Konfigurasi Firebase:

* Buat project baru di [Firebase Console](https://console.firebase.google.com/)
* Tambahkan Android/iOS app ke Firebase project
* Unduh `google-services.json` dan tempatkan di `android/app/`
* Unduh `GoogleService-Info.plist` dan tempatkan di `ios/Runner/`

3. Install dependencies:

```sh
flutter pub get
```

4. Jalankan aplikasi:

```sh
flutter run
```

## 👥 Tim Kami

| **Foto**        | **Nama** | **Peran**         | **Kontribusi**                                                      |
| --------------- | -------- | ----------------- | ------------------------------------------------------------------- |
| \[Gambar Dhika] | Dhika    | UI/UX Designer    | Merancang antarmuka pengguna yang modern dan ramah pengguna         |
| \[Gambar Yoga]  | Yoga     | Flutter Developer | Mengembangkan seluruh fitur aplikasi dan integrasi backend serta AI |

---

<div align="center">
  <p>Dibuat dengan 🔥 menggunakan Flutter</p>
</div>
