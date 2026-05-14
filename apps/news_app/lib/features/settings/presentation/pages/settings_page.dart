import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: const <Widget>[
          ListTile(
            title: Text('启动自动刷新'),
            subtitle: Text('默认开启，后续将接入持久化开关'),
            trailing: Switch(value: true, onChanged: null),
          ),
          Divider(height: 1),
          ListTile(
            title: Text('仅 Wi-Fi 刷新'),
            subtitle: Text('后续接入平台网络能力'),
            trailing: Switch(value: false, onChanged: null),
          ),
          Divider(height: 1),
          ListTile(
            title: Text('清理缓存'),
            subtitle: Text('后续接入本地缓存管理'),
            trailing: Icon(Icons.cleaning_services_outlined),
          ),
        ],
      ),
    );
  }
}
