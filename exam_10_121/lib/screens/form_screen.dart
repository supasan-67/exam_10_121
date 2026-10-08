import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../controllers/machine_controller.dart';
import '../models/machine_model.dart';

/// ใช้ทั้งหน้า "บันทึกใหม่" (machine == null) และ "แก้ไข" (ส่ง machine เข้ามา)
class FormScreen extends StatefulWidget {
  final MachineModel? machine;
  const FormScreen({super.key, this.machine});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = MachineController();

  late final _code = TextEditingController(text: widget.machine?.assetCode);
  late final _motor = TextEditingController(text: widget.machine?.motorModel);
  late final _line = TextEditingController(text: widget.machine?.lineLocation);
  late final _email = TextEditingController(text: widget.machine?.engineerEmail);
  late final _vib = TextEditingController(text: widget.machine?.vibration.toString());
  late final _temp = TextEditingController(text: widget.machine?.temperature.toString());
  late final _note = TextEditingController(text: widget.machine?.maintenanceNote);
  late final _alarm =
      TextEditingController(text: widget.machine?.alarmThreshold?.toString());
  bool _saving = false;

  bool get _editing => widget.machine != null;

  final _numberValidator = MultiValidator([
    RequiredValidator(errorText: 'ห้ามเว้นว่าง'),
    PatternValidator(r'^\d+(\.\d+)?$', errorText: 'กรอกเป็นตัวเลขเท่านั้น'),
  ]);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final m = MachineModel(
      assetCode: _code.text.trim(),
      motorModel: _motor.text.trim(),
      lineLocation: _line.text.trim(),
      engineerEmail: _email.text.trim(),
      vibration: double.parse(_vib.text),
      temperature: double.parse(_temp.text),
      maintenanceNote: _note.text.trim(),
      alarmThreshold: double.tryParse(_alarm.text),
    );
    try {
      if (_editing) {
        await _controller.update(widget.machine!.id, m);
      } else {
        await _controller.add(m);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editing ? 'อัปเดตข้อมูลแล้ว' : 'บันทึกข้อมูลแล้ว')));
      if (_editing) {
        Navigator.pop(context);
      } else {
        _formKey.currentState!.reset();
        for (final c in [_code, _motor, _line, _email, _vib, _temp]) {
          c.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
      labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder());

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _code,
            decoration: _dec('หมายเลขเครื่องจักร (เช่น PUMP-HEAVY-01)', Icons.precision_manufacturing),
            validator: RequiredValidator(errorText: 'กรุณากรอกหมายเลขเครื่องจักร').call,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _motor,
            decoration: _dec('รุ่นมอเตอร์', Icons.settings),
            validator: RequiredValidator(errorText: 'กรุณากรอกรุ่นมอเตอร์').call,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _line,
            decoration: _dec('ตำแหน่งไลน์ผลิต', Icons.location_on),
            validator: RequiredValidator(errorText: 'กรุณากรอกตำแหน่งไลน์ผลิต').call,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: _dec('อีเมลวิศวกรซ่อมบำรุง', Icons.email),
            validator: MultiValidator([
              RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
              EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
            ]).call,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _vib,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('ค่าความสั่นสะเทือน (mm/s RMS)', Icons.vibration),
            validator: _numberValidator.call,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _temp,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('อุณหภูมิผิวตลับลูกปืน (°C)', Icons.thermostat),
            validator: _numberValidator.call,
          ),
          if (_editing) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _note,
              maxLines: 2,
              decoration: _dec('บันทึกการอัดจารบี / งานซ่อมบำรุง', Icons.oil_barrel),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _alarm,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _dec('เกณฑ์เตือนภัย (mm/s)', Icons.notification_important),
              validator: (v) => (v == null || v.isEmpty)
                  ? null
                  : PatternValidator(r'^\d+(\.\d+)?$', errorText: 'กรอกเป็นตัวเลขเท่านั้น')
                      .call(v),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save),
            label: Text(_editing ? 'อัปเดตข้อมูล' : 'บันทึกผลวินิจฉัย'),
          ),
        ],
      ),
    );

    if (_editing) {
      return Scaffold(appBar: AppBar(title: const Text('แก้ไขรายการ')), body: form);
    }
    return form;
  }
}
