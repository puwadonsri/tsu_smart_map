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
│   ├── pages/                   # Splash / แผนที่ / ตลาด+รายละเอียด / ฉุกเฉิน / รายการจุด
│   ├── widgets/                 # หมุดบนแผนที่
│   └── utils/app_icons.dart     # ตารางแปลงชื่อไอคอนใน config -> IconData
├── assets/config/app_config.json  # ★ ไฟล์ข้อมูลกลางที่แก้ได้
├── test/config_test.dart          # เทสต์ config + ไอคอน + ค่า default
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

ไฟล์กลาง: `tsu_smart_map/assets/config/app_config.json` — ทั้งแอป Flutter และหน้าเว็บอ่านสคีมาเดียวกัน

```jsonc
{
  "app": {
    "emergencyNumber": "0928733748",
    "emergencyLabel": "สำหรับรถเสีย / อุบัติเหตุ ภายใน ม.ทักษิณ พัทลุง",
    "emergencyTitle": "เบอร์ฉุกเฉิน",
    "tagline": "เดินทางสะดวก ปลอดภัย ใกล้คุณ"   // แสดงบนหน้า Splash
  },
  "map": {
    "center": { "lat": 7.80822, "lng": 99.93869 },
    "zoom": 16,
    "travel": { "walkKmh": 4.5, "driveKmh": 30 }  // ใช้ประมาณเวลาเดินทางจาก distanceKm
  },
  "layers": [
    {
      "id": "tram",
      "name": "จุดรถราง",
      "icon": "directions_bus",              // ชื่อไอคอน Material (ดูรายชื่อที่รองรับด้านล่าง)
      "description": "ศาลาที่จอดรถราง",       // คำอธิบายใต้ชื่อในแถบด้านข้าง
      "listTitle": "จุดจอดรถรางทั้งหมด",      // หัวข้อหน้ารายการจุดทั้งหมด
      "group": "ประเภทสถานที่",                // หัวข้อกลุ่มในแถบด้านข้าง
      "color": "#1E88E5",
      "enabled": true,
      "locations": [
        { "name": "ศาลารถราง หน้าประตู", "lat": 7.80755, "lng": 99.93895, "detail": "..." }
      ]
    }
  ],
  "markets": [
    { "name": "ตลาดป่าพะยอม", "lat": 7.83410, "lng": 99.94310,
      "detail": "...", "distanceKm": 4.0, "icon": "storefront" }
  ],
  "shortcuts": [
    { "id": "markets", "label": "ตลาดใกล้ฉัน", "icon": "storefront", "color": "#43A047", "action": "markets" }
  ]
}
```

**สิ่งที่ปรับได้โดยไม่ต้องแก้โค้ด**

- เพิ่ม/แก้จุดใน `layers[].locations` และ `markets[]`
- เพิ่มชั้นข้อมูลใหม่ทั้งประเภท — ใส่ `icon` / `description` / `listTitle` / `group` ให้ครบ
  แล้วแถบด้านข้าง ปุ่มลัด และหน้ารายการจุดจะสร้างให้อัตโนมัติ
- ตั้งหัวข้อกลุ่มใหม่ในแถบด้านข้างด้วยฟิลด์ `group` (ชั้นข้อมูลที่ `group` เดียวกันจะอยู่กลุ่มเดียวกัน)
- `shortcuts[].action` รองรับ `markets` · `emergency` · `toggleLayer` · `layerList`

**ชื่อไอคอนที่รองรับ** — `storefront` `phone_in_talk` `call` `directions_bus` `local_gas_station`
`electric_scooter` `warning` `place` `location_on` `school` `restaurant` `hotel` `park`
`local_hospital` `local_parking` `directions_walk` `directions_car` `map`

> ฝั่ง Flutter ต้องเป็นชื่อที่ลงทะเบียนไว้ใน [`lib/utils/app_icons.dart`](tsu_smart_map/lib/utils/app_icons.dart)
> เพราะ Flutter ตัดฟอนต์ไอคอนที่ไม่ถูกอ้างถึงตอน build — มีเทสต์คุมไว้ใน `test/config_test.dart`

**โหมด Web**: แก้ `build/web/config/app_config.json` แล้วกดรีเฟรช (Ctrl+F5) เห็นผลทันทีไม่ต้อง compile

## 🌐 หน้าเว็บสาธิต (index.html)

`index.html` ที่ราก repo เป็นเวอร์ชันเดโมด้วย Leaflet.js ล้วน เปิดไฟล์ในเบราว์เซอร์ได้เลย
ไม่ต้องลง Flutter — ใช้สคีมา config เดียวกัน โดยลำดับการโหลดคือ
`config/app_config.json` → `tsu_smart_map/assets/config/app_config.json` → config ที่ฝังในไฟล์

## 📄 ข้อกำหนดแอป

ดูรายละเอียด Requirements ทั้งหมดได้ที่ [`requitment.txt`](requitment.txt)

## 📝 หมายเหตุ

- ระยะทางและตำแหน่งจุด/ตลาดเป็นค่าประมาณ — ปรับแก้ได้ใน config
- ถ้าต้องการแผนที่ Google Maps แทน OpenStreetMap แนะนำใช้ package `google_maps_flutter` + API key