import 'package:flutter/material.dart';

/// แปลงชื่อไอคอนที่เขียนไว้ใน config เป็น [IconData]
///
/// ต้องเป็นตารางค่าคงที่ เพราะ Flutter ตัดฟอนต์ไอคอนที่ไม่ถูกอ้างถึงตอน build
/// (icon tree shaking) — การใช้ `IconData(codePoint)` แบบไดนามิกจะได้ช่องว่าง
const Map<String, IconData> kConfigIcons = {
  'storefront': Icons.storefront,
  'phone_in_talk': Icons.phone_in_talk,
  'call': Icons.call,
  'directions_bus': Icons.directions_bus,
  'local_gas_station': Icons.local_gas_station,
  'electric_scooter': Icons.electric_scooter,
  'warning': Icons.warning_amber_rounded,
  'warning_amber': Icons.warning_amber_rounded,
  'place': Icons.place,
  'location_on': Icons.location_on,
  'school': Icons.school,
  'restaurant': Icons.restaurant,
  'hotel': Icons.hotel,
  'park': Icons.park,
  'local_hospital': Icons.local_hospital,
  'local_parking': Icons.local_parking,
  'directions_walk': Icons.directions_walk,
  'directions_car': Icons.directions_car,
  'map': Icons.map,
};

IconData iconFromConfig(String name) => kConfigIcons[name] ?? Icons.place;
