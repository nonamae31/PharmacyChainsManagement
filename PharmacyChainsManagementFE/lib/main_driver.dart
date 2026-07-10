import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:pharmacy_chains_management_fe/main.dart' as app;

void main() async {
  // Bật Flutter Driver Extension để MCP có thể điều khiển ngầm
  enableFlutterDriverExtension();
  
  // Khởi chạy app bình thường
  app.main();
}
