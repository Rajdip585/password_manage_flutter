import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/password_entry.dart';
import '../db/password_database.dart';

class ViewPasswordScreen extends StatefulWidget {
  final PasswordEntry entry;
  ViewPasswordScreen({required this.entry});

  @override
  _ViewPasswordScreenState createState() => _ViewPasswordScreenState();
}

class _ViewPasswordScreenState extends State<ViewPasswordScreen> {
  bool _isEditing = false;
  bool _obscurePassword = true;
  late FocusNode _passwordFocusNode;
  late TextEditingController _passwordController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(text: widget.entry.password);
    _noteController = TextEditingController(text: widget.entry.note);
    _passwordFocusNode = FocusNode();
  }

  void _deletePassword() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm?"),
        content: Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Delete"),
          ),
        ],
      ),
    );
    if (confirm ?? false) {
      await PasswordDatabase.deletePassword(widget.entry.id!);
      Navigator.pop(context);
    }
  }

  void _saveEdit() async {
    final updated = widget.entry.copyWith(
      password: _passwordController.text,
      note: _noteController.text.trim(),
      lastUpdated: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );
    await PasswordDatabase.updatePassword(updated);
    setState(() {
      _isEditing = false;
    });
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool readOnly = true,
    int maxLines = 1,
    FocusNode? focusNode,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && _obscurePassword,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildStaticField(String label, String value) {
    return _buildLabeledField(
      label: label,
      controller: TextEditingController(text: value),
      readOnly: true,
    );
  }

  Widget _buildPasswordField() {
    return _buildLabeledField(
      label: "Password",
      controller: _passwordController,
      isPassword: true,
      readOnly: !_isEditing,
      focusNode: _passwordFocusNode,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _passwordController.text));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Password copied!")));
            },
          ),
          IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField() {
    return _buildLabeledField(
      label: "Note",
      controller: _noteController,
      readOnly: !_isEditing,
      maxLines: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry.platform),
        actions: [
          IconButton(icon: Icon(Icons.delete), onPressed: _deletePassword),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStaticField("Account", widget.entry.account),
            _buildPasswordField(),
            _buildNoteField(),
            _buildStaticField("Last Updated", widget.entry.lastUpdated),
          ],
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(child: Icon(Icons.save), onPressed: _saveEdit)
          : FloatingActionButton(
              child: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                  _obscurePassword = false;
                });
                _passwordFocusNode.requestFocus();
              },
            ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _noteController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
