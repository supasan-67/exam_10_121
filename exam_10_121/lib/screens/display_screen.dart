import 'package:flutter/material.dart';

import '../controllers/machine_controller.dart';
import '../models/machine_model.dart';
import 'form_screen.dart';

class DisplayScreen extends StatelessWidget {
  final bool isAdmin; // Admin = CRUD, Operator = Read + Create เท่านั้น
  const DisplayScreen({super.key, required this.isAdmin});

  Color _level(double v) {
    if (v < 2.8) return Colors.green;
    if (v < 7.1) return Colors.orange;
    return Colors.red;
  }

  Future<void> _confirmDelete(BuildContext context, MachineModel m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ลบ ${m.assetCode} ออกจากรายการเฝ้าระวังหลังซ่อมเสร็จ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ลบ')),
        ],
      ),
    );
    if (ok == true) await MachineController().delete(m.id);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MachineController().stream(),
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('เกิดข้อผิดพลาด: ${snap.error}'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('ยังไม่มีรายการเฝ้าระวัง'));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final m = MachineModel.fromDoc(docs[i]);
            final over = m.alarmThreshold != null && m.vibration >= m.alarmThreshold!;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: _level(m.vibration),
                  foregroundColor: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m.vibration.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('mm/s', style: TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
                title: Text(m.assetCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${m.lineLocation} • ${m.motorModel}\n'
                  'อุณหภูมิ: ${m.temperature.toStringAsFixed(1)} °C'
                  '${m.alarmThreshold != null ? '\nเกณฑ์เตือน: ${m.alarmThreshold} mm/s${over ? ' ⚠ เกินเกณฑ์' : ''}' : ''}'
                  '${m.maintenanceNote.isNotEmpty ? '\nบันทึก: ${m.maintenanceNote}' : ''}',
                ),
                isThreeLine: true,
                // Operator: ซ่อนปุ่ม Edit / Delete ทั้งหมด
                trailing: isAdmin
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FormScreen(machine: m)),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, m),
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
