# TSU Smart Map — คู่มือติดตั้งและวิธีรัน

แอปแผนที่อัจฉริยะมหาวิทยาลัยทักษิณ วิทยาเขตพัทลุง สร้างด้วย **Flutter**
ข้อมูลทั้งหมดปรับแก้ได้จากไฟล์ config โดยไม่ต้องแก้โค้ด (ดูหัวข้อ "วิธีแก้ข้อมูล" ด้านล่าง)

---

## 1. สิ่งที่ต้องติดตั้ง (Prerequisites)

| รายการ | รุ่นขั้นต่ำ | จำเป็นสำหรับ |
|---|---|---|
| **Flutter SDK** | 3.x (stable) | ทุกแพลตฟอร์ม |
| **Git** | 2.x | ติดตั้ง Flutter แล้วสะดวกต่อการอัปเดต |
| **Google Chrome** | — | รันบน Web |
| **Visual Studio** (Desktop development with C++) | VS 2019+ | รันบน Windows Desktop |
| **Android Studio + Android SDK** | — | รันบน Android (Emulator / เครื่องจริง) |

> หมายเหตุ: โปรเจกต์นี้ไม่ได้ใช้ Google Maps API key — แผนที่ใช้ OpenStreetMap ฟรี
> และการนำทางใช้ URL ของ Google Maps ธรรมดา (ไม่ต้องคีย์)

### 1.1 ติดตั้ง Flutter SDK (Windows)
1. ไปที่ https://docs.flutter.dev/get-started/install/windows
2. ดาวน์โหลด zip ตัว stable แล้วแตก เช่น ไปที่ `D:\flutter_sdk` (ผลลัพธ์: `D:\flutter_sdk\flutter`)
3. เพิ่ม `D:\flutter_sdk\flutter\bin` ลงใน PATH ของระบบ
4. เปิด Command Prompt ตรวจสอบ: `flutter --version`
5. ตรวจความพร้อม: `flutter doctor`

> บนเครื่องที่พัฒนาอยู่แล้ว: Flutter อยู่ที่ `D:\flutter_sdk\flutter`
> ใช้คำสั่ง `$env:Path = "D:\flutter_sdk\flutter\bin;" + $env:Path` ใน PowerShell ก่อนรันคำสั่ง flutter (ถ้ายังไม่ได้ตั้ง PATH)

### 1.2 เปิดใช้งาน Web Platform
```
flutter config --enable-web
```

---

## 2. โครงสร้างโปรเจกต์

```
D:\tsu_smart_map\
├── requitment.txt                # ข้อกำหนดแอป
├── tsu_smart_map\                # โฟลเดอร์โปรเจกต์ Flutter
│   ├── lib\
│   │   ├── main.dart             # จุดเริ่มต้นแอป
│   │   ├── models\app_config.dart   # ตัวแบบข้อมูล (อ่านจาก config JSON)
│   │   ├── services\
│   │   │   ├── config_service.dart     # โหลด config (ภายนอกก่อน แล้วค่อย fallback asset)
│   │   │   └── navigation_service.dart # เปิด Google Maps นำทาง
│   │   ├── pages\
│   │   │   ├── splash_screen.dart      # หน้าเปิด
│   │   │   ├── map_screen.dart         # หน้าแผนที่หลัก (search + drawer + แถบล่าง)
│   │   │   └── market_list_screen.dart # รายชื่อตลาด
│   │   └── widgets\location_marker.dart
│   ├── assets\config\app_config.json   # ★ ไฟล์ข้อมูลกลางที่แก้ได้
│   ├── pubspec.yaml                    # รายการ dependencies และ assets
│   └── build\web\                      # เอาต์พุตเว็บ (หลัง flutter build)
│       └── config\app_config.json      # ★ config ภายนอกสำหรับเว็บ (แก้แล้วเห็นผลทันที)
```

---

## 3. วิธีรันแอป

เข้าไปที่โฟลเดอร์โปรเจกต์ก่อนทุกคำสั่ง:
```
cd D:\tsu_smart_map\tsu_smart_map
```

### 3.1 รันบน Web (แนะนำสำหรับทดสอบเร็ว)

**แบบ Development (Hot Reload):**
```
flutter run -d chrome
```
หรือรันเป็น web-server แล้วเปิดเบราว์เซอร์เอง:
```
flutter run -d web-server --web-port 8080
```

**แบบ Production build + เสิร์ฟเว็บ (เหมือนที่รันอยู่ในตอนนี้):**
```
flutter build web --release
```
จากนั้นรัน static server (ต้องมี Python 3.x):
```
python -m http.server 8080 --bind 127.0.0.1
```
เปิดเบราว์เซอร์ไปที่: http://127.0.0.1:8080/

สำคัญ: หลัง build ใหม่ ต้องคัดลอก config ไปไว้ข้างตัว build ด้วยเพื่อให้แก้ข้อมูลแล้วเห็นผลทันที:
```
copy assets\config\app_config.json build\web\config\app_config.json
```

### 3.2 รันบน Windows Desktop (ต้องมี Visual Studio C++ toolchain)
```
flutter run -d windows
```
หรือ build ไฟล์ .exe:
```
flutter build windows --release
```
ไฟล์ผลลัพธ์: `build\windows\x64\runner\Release\tsu_smart_map.exe`

### 3.3 รันบน Android (ต้องมี Android Studio / SDK)
```
flutter run -d android                    # รันบนเครื่องที่เสียบสายหรือ Emulator
flutter build apk --release               # สร้างไฟล์ APK
```
ไฟล์ผลลัพธ์: `build\app\outputs\flutter-apk\app-release.apk`

---

## 4. วิธีแก้ข้อมูล (โดยไม่ต้องแก้โค้ด)

ไฟล์หลัก: `tsu_smart_map\assets\config\app_config.json`

ตัวอย่างฟอร์แมต:
```jsonc
{
  "app": {
    "name": "TSU Smart Map",
    "campusName": "มหาวิทยาลัยทักษิณ วิทยาเขตพัทลุง",
    "emergencyNumber": "0928733748",        // ← เบอร์ฉุกเฉิน
    "emergencyLabel": "สำหรับรถเสีย / อุบัติเหตุ"
  },
  "map": {
    "center": { "lat": 7.80822, "lng": 99.93869 },  // ← จุดกลางแผนที่
    "zoom": 16
  },
  "layers": [
    {
      "id": "tram",
      "name": "จุดรถราง",                   // ← ชื่อประเภท
      "emoji": "🚎",
      "enabled": true,
      "color": "#1E88E5",
      "locations": [
        { "name": "ศาลารถราง หน้าประตู", "lat": 7.80755, "lng": 99.93895, "detail": "..." }  // ← เพิ่มจุดใหม่ได้
      ]
    }
  ],
  "markets": [
    { "name": "ตลาดป่าพะยอม", "lat": 7.83410, "lng": 99.94310, "detail": "...", "distanceKm": 4.0, "emoji": "🛒" }
  ],
  "shortcuts": [
    { "id": "markets", "label": "ตลาดใกล้ฉัน", "icon": "storefront", "color": "#43A047", "action": "markets" }
  ]
}
```

การเพิ่ม/แก้จุดแต่ละจุดใช้ฟิลด์: `name`, `lat`, `lng`, `detail`
- ฟิลด์ใหม่ที่ไม่มีให้ใส่ `null` ได้ ยกเว้น `name/lat/lng` ที่ต้องมี
- icon ที่ใช้ได้ใน shortcuts: `storefront`, `phone_in_talk`, `directions_bus`, `local_gas_station`, `electric_scooter`, `warning`

### 4.1 เห็นผลการแก้ทันที (เฉพาะเว็บ)
- แก้ไฟล์ `build\web\config\app_config.json` แล้วกด **รีเฟรชเบราว์เซอร์ (Ctrl+F5)**
- ระบบจะโหลดจากไฟล์ภายนอกก่อน (ถ้ามี) จึงไม่ต้อง compile ใหม่

### 4.2 เห็นผลหลัง build ใหม่ (ทุกแพลตฟอร์ม)
- แก้ `assets\config\app_config.json` แล้วรัน `flutter build` / `flutter run` ใหม่

---

## 5. คำสั่งตรวจสอบคุณภาพโค้ด
```
flutter analyze        # ตรวจ syntax / lint
flutter test           # รันเทสต์ (ทดสอบการโหลด config)
```

---

## 6. หมายเหตุ / ข้อจำกัด
- ตำแหน่งและระยะทางตลาดเป็นค่าประมาณ — ปรับแก้ได้ใน config
- ระยะตลอด "นำทางไป Google Maps" เปิดแอป/เบราว์เซอร์ภายนอก
- บนมือถือจริง การกด "กดโทรออก" จะโทรหาหมายเลขฉุกเฉินจริง
- ถ้าต้องการแผนที่ Google Maps แทน OpenStreetMap ให้ใช้ package `google_maps_flutter`
  และเพิ่ม API key ของ Google Maps Platform (ดูใน `requitment.txt` หัวข้อ หมายเหตุ)