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
  List<PasswordEntry> filteredList = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPasswords() async {
    final data = await PasswordDatabase.getAllPasswords();
    setState(() {
      passwordList = data;
      filteredList = data;
    });
  }

  void _filterPasswords(String query) {
    final results = passwordList.where((entry) {
      return entry.platform.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredList = results;
    });
  }

  void _exportPasswords(BuildContext context) async {
    try {
      final entries = await PasswordDatabase.getAllPasswords();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Lock'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'excel') {
                _exportPasswords(context);
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterPasswords,
            ),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? Center(child: Text('No passwords found.'))
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final entry = filteredList[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
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
                                builder: (_) =>
                                    ViewPasswordScreen(entry: entry),
                              ),
                            );
                            _loadPasswords();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
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
