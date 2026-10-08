import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import 'display_screen.dart';
import 'form_screen.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController();
    return StreamBuilder<UserModel?>(
      stream: auth.userStream(user.uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting || snap.data == null) {
          return Scaffold(
            appBar: AppBar(actions: [
              IconButton(icon: const Icon(Icons.logout), onPressed: auth.signOut)
            ]),
            body: Center(
              child: snap.connectionState == ConnectionState.waiting
                  ? const CircularProgressIndicator()
                  : const Text('ไม่พบข้อมูลสิทธิ์ผู้ใช้ใน collection users'),
            ),
          );
        }
        final me = snap.data!;
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('PredictIQ'),
              actions: [
                Center(
                  child: Chip(
                    label: Text('${me.role}: ${me.email}',
                        style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                IconButton(
                  tooltip: 'Sign Out',
                  icon: const Icon(Icons.logout),
                  onPressed: auth.signOut,
                ),
              ],
              bottom: const TabBar(tabs: [
                Tab(icon: Icon(Icons.edit_note), text: 'บันทึกผลวินิจฉัย'),
                Tab(icon: Icon(Icons.warning_amber), text: 'รายการเฝ้าระวัง'),
              ]),
            ),
            body: TabBarView(
              children: [
                const FormScreen(),
                DisplayScreen(isAdmin: me.isAdmin),
              ],
            ),
          ),
        );
      },
    );
  }
}
