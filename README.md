<div align="center">

# TSU Smart Map 🗺️

**แอปแผนที่อัจฉริยะ มหาวิทยาลัยทักษิณ วิทยาเขตพัทลุง**

แอปพลิเคชันแผนที่ภายในมหาวิทยาลัย แสดงจุดสำคัญต่าง ๆ เช่น จุดรถราง ปั๊มน้ำมัน จุดสกู๊ตเตอร์ไฟฟ้า และจุดควรระมัดระวัง พร้อมปุ่มโทรฉุกเฉินและรายชื่อตลาดใกล้มหาวิทยาลัย — ข้อมูลทั้งหมดปรับแก้ได้จากไฟล์ config โดยไม่ต้องแก้โค้ด

Flutter · OpenStreetMap · No Database

</div>

---

## ✨ คุณสมบัติ (Features)

- 🗺️ **แผนที่อัจฉริยะ** — แสดงแผนที่ภายใน ม.ทักษิณ พัทลุง (OpenStreetMap ไม่ต้องใช้ API key)
- 📂 **Filter Layers** — เปิด/ปิดการแสดงผล 4 ประเภท: 🚎 จุดรถราง · ⛽ จุดเติมน้ำมัน · 🛴 จุดสกู๊ตเตอร์ · ⚠️ จุดควรระมัดระวัง
- 📞 **Emergency Call** — ปุ่มโทรออกฉุกเฉิน 092-873-3748 (สำหรับรถเสีย/อุบัติเหตุ)
- 🏪 **Nearby Markets** — รายชื่อตลาดรอบมหาวิทยาลัย พร้อมระยะทางโดยประมาณ
- 🧭 **นำทางไป Google Maps** — แตะที่จุด/ตลาดใดก็ได้เพื่อเปิดเส้นทาง
- 🔎 **ช่องค้นหา** — ค้นหาชื่อสถานที่แล้วเลื่อนแผนที่ไปยังจุดนั้น
- ⚙️ **Config-driven** — แก้ข้อมูลได้จากไฟล์ JSON โดยไม่ต้องแก้โค้ด (Web รองรับการแก้แล้วเห็นผลทันที)

## 🛠️ เทคโนโลยี (Tech Stack)

| เครื่องมือ | ใช้ทำอะไร |
|---|---|
| **Flutter** (Dart) | Cross-platform app (Web / Windows / Android) |
| **flutter_map + OpenStreetMap** | แผนที่ (ฟรี ไม่ต้องใช้ Google Maps API key) |
| **url_launcher** | โทรฉุกเฉิน (tel:) และเปิด Google Maps นำทาง |
| **http** | โหลด config จากไฟล์ภายนอก (โหมด Web) |

## 📁 โครงสร้างโปรเจกต์

```
tsu_smart_map/                  ← โฟลเดอร์โปรเจกต์หลัก
├── lib/
│   ├── main.dart                # จุดเริ่มต้นแอป
│   ├── models/app_config.dart   # ตัวแบบข้อมูล (อ่านจาก config JSON)
│   ├── services/                # โหลด config + เปิด Google Maps
│   ├── pages/                   # Splash / แผนที่หลัก / ตลาด
│   └── widgets/                 # Marker บนแผนที่
├── assets/config/app_config.json  # ★ ไฟล์ข้อมูลกลางที่แก้ได้
├── test/widget_test.dart          # เทสต์การโหลด config
└── README.md                      # คู่มือติดตั้ง/รันโดยละเอียด
```

## 🚀 เริ่มต้นใช้งาน (Quick Start)

```bash
# 0. ลง Flutter SDK แล้วเปิด web platform
flutter config --enable-web

# 1. เข้าไปที่โปรเจกต์
cd tsu_smart_map

# 2. รันบน Web (dev, hot reload)
flutter run -d chrome

# หรือ build เป็น release
flutter build web --release
```

รายละเอียดการติดตั้ง + วิธีรันทุกแพลตฟอร์ม (Windows, Android) และการตั้งค่าเพิ่มเติมอ่านได้ที่ **[tsu_smart_map/README.md](tsu_smart_map/README.md)**

## ⚙️ การแก้ข้อมูล (Config)

ไฟล์กลาง: `assets/config/app_config.json`

```jsonc
{
  "app": { "emergencyNumber": "0928733748" },
  "map": { "center": { "lat": 7.80822, "lng": 99.93869 }, "zoom": 16 },
  "layers": [
    {
      "id": "tram",
      "name": "จุดรถราง",
      "emoji": "🚎",
      "locations": [
        { "name": "ศาลารถราง หน้าประตู", "lat": 7.80755, "lng": 99.93895, "detail": "..." }
      ]
    }
  ],
  "markets": [ { "name": "ตลาดป่าพะยอม", "lat": 7.83410, "lng": 99.94310, "distanceKm": 4.0 } ],
  "shortcuts": [ { "label": "ตลาดใกล้ฉัน", "icon": "storefront", "action": "markets" } ]
}
```

- เพิ่ม/แก้จุดได้ที่ `layers[].locations` และ `markets[]`
- **โหมด Web**: แก้ `build/web/config/app_config.json` แล้วกดรีเฟรช (Ctrl+F5) — เห็นผลทันทีไม่ต้อง compile

## 📄 ข้อกำหนดแอป

ดูรายละเอียด Requirements ทั้งหมดได้ที่ [`requitment.txt`](requitment.txt)

## 📝 หมายเหตุ

- ระยะทางและตำแหน่งจุด/ตลาดเป็นค่าประมาณ — ปรับแก้ได้ใน config
- ถ้าต้องการแผนที่ Google Maps แทน OpenStreetMap แนะนำใช้ package `google_maps_flutter` + API key