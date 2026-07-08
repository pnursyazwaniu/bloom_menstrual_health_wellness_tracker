# Fix Firestore Permission Error

Error "Missing or insufficient permissions" berarti Firestore Security Rules tidak membenarkan user untuk mengupdate profil mereka.

## Solusi: Update Firestore Security Rules

### Langkah-langkah:

1. **Buka Firebase Console**
   - Pergi ke https://console.firebase.google.com/
   - Pilih project anda

2. **Pergi ke Firestore Database**
   - Click "Firestore Database" di menu sebelah kiri
   - Klik tab "Rules"

3. **Ganti Rules dengan yang berikut:**

```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to manage their own documents
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
      allow delete: if request.auth.uid == userId;
    }

    // Allow any authenticated user to read other data
    match /{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

4. **Klik "Publish"**
   - Rules akan aktif dalam beberapa saat

### Penjelasan Rules:

- **`match /users/{userId}`**: Hanya data dalam koleksi "users" dengan ID yang match dengan UID user yang authenticated
- **`allow read: if request.auth.uid == userId`**: User hanya boleh baca data mereka sendiri
- **`allow write: if request.auth.uid == userId`**: User hanya boleh tulis/update data mereka sendiri

### Testing:

1. Buka aplikasi
2. Login dengan akun anda
3. Klik "Edit Profile"
4. Masukkan nama dan tarikh lahir
5. Klik tombol "Save"

Sekarang seharusnya profil anda boleh disimpan dengan sukses! ✓

## Jika masih error:

Kemungkinan penyebab lain:
1. User tidak authenticated dengan benar - pastikan sudah login
2. Email belum diverify - verify email dulu sebelum update profil
3. Firestore collection name salah - pastikan collection name adalah `users`

Untuk debugging, buka Firebase Console > Firestore Database > Logs untuk melihat error lebih detail.
