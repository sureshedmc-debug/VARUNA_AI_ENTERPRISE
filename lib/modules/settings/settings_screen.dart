import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.memory),
            title: Text('Raspberry Pi'),
            subtitle: Text('Not Connected'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.flight),
            title: Text('Pixhawk'),
            subtitle: Text('Not Connected'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.psychology),
            title: Text('TensorFlow Model'),
            subtitle: Text('Not Loaded'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Theme'),
            subtitle: Text('System Default'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('VARUNA AI Enterprise'),
            subtitle: Text('Version 1.0'),
          ),
        ],
      ),
    );
  }
}

