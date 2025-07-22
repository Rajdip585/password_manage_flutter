import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../models/password_entry.dart';

class ExcelExporter {
  static Future<void> exportToExcel(List<PasswordEntry> entries) async {
    // Handle Android storage permissions
    final permissionStatus = await Permission.manageExternalStorage.request();
    if (!permissionStatus.isGranted) {
      throw Exception('Storage permission not granted');
    }

    // Create Excel file
    final excel = Excel.createExcel();
    final sheet = excel['Passwords'];
    sheet.appendRow(['Platform', 'Account', 'Password', 'Note', 'Last Updated']);

    for (var entry in entries) {
      sheet.appendRow([
        entry.platform,
        entry.account,
        entry.password,
        entry.note,
        entry.lastUpdated
      ]);
    }

    // Save to Downloads folder
    final directory = Directory('/storage/emulated/0/Download');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final filePath = "${directory.path}/passwords_export.xlsx";
    final bytes = excel.encode();
    if (bytes == null) throw Exception("Failed to encode Excel data");

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return;
  }
}
