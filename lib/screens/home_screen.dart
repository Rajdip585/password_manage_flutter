import 'package:flutter/material.dart';
import '../models/password_entry.dart';
import '../db/password_database.dart';
import 'add_password_screen.dart';
import 'view_password_screen.dart';
import '../utils/export_to_excel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PasswordEntry> passwordList = [];

  void _loadPasswords() async {
    final data = await PasswordDatabase.getAllPasswords();
    setState(() => passwordList = data);
  }

  void _exportPasswords(BuildContext context) async {
    try {
      final List<PasswordEntry> entries =
          await PasswordDatabase.getAllPasswords();
      await ExcelExporter.exportToExcel(entries);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exported to Excel successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Export failed: ${e.toString()}")));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Lock'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'excel') {
                _exportPasswords(context); // Your export function
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Export to Excel'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: passwordList.isEmpty
          ? Center(child: Text('No passwords added yet.'))
          : ListView.builder(
              itemCount: passwordList.length,
              itemBuilder: (context, index) {
                final entry = passwordList[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      entry.platform,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(entry.account),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewPasswordScreen(entry: entry),
                        ),
                      );
                      _loadPasswords();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPasswordScreen()),
          );
          _loadPasswords();
        },
        child: Icon(Icons.add),
        tooltip: 'Add Password',
      ),
    );
  }
}
