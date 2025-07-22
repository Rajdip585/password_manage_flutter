import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/password_database.dart';
import '../models/password_entry.dart';

class AddPasswordScreen extends StatefulWidget {
  @override
  _AddPasswordScreenState createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final platformController = TextEditingController();
  final accountController = TextEditingController();
  final passwordController = TextEditingController();
  final noteController = TextEditingController();
  bool _obscurePassword = true;

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        alignLabelWithHint: true, // Align label at top-left
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  void _savePassword() async {
    if (_formKey.currentState!.validate()) {
      final entry = PasswordEntry(
        platform: platformController.text.toUpperCase().trim(),
        account: accountController.text,
        password: passwordController.text,
        note: noteController.text,
        lastUpdated: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      );
      await PasswordDatabase.insertPassword(entry);
      Navigator.pop(context);
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Add New Password'),
      centerTitle: true,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: platformController,
                decoration: _inputDecoration('Platform'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: accountController,
                decoration: _inputDecoration('Account'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration('Password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: noteController,
                decoration: _inputDecoration('Note'),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePassword,
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
