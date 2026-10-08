import 'package:cloud_firestore/cloud_firestore.dart';

class MachineModel {
  final String id;
  final String assetCode;
  final String motorModel;
  final String lineLocation;
  final String engineerEmail;
  final double vibration; // mm/s RMS
  final double temperature; // °C
  final String maintenanceNote; // บันทึกอัดจารบี
  final double? alarmThreshold; // เกณฑ์เตือนภัย mm/s

  MachineModel({
    this.id = '',
    required this.assetCode,
    required this.motorModel,
    required this.lineLocation,
    required this.engineerEmail,
    required this.vibration,
    required this.temperature,
    this.maintenanceNote = '',
    this.alarmThreshold,
  });

  factory MachineModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return MachineModel(
      id: d.id,
      assetCode: m['assetCode'] ?? '',
      motorModel: m['motorModel'] ?? '',
      lineLocation: m['lineLocation'] ?? '',
      engineerEmail: m['engineerEmail'] ?? '',
      vibration: (m['vibration'] ?? 0).toDouble(),
      temperature: (m['temperature'] ?? 0).toDouble(),
      maintenanceNote: m['maintenanceNote'] ?? '',
      alarmThreshold: (m['alarmThreshold'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'assetCode': assetCode,
        'motorModel': motorModel,
        'lineLocation': lineLocation,
        'engineerEmail': engineerEmail,
        'vibration': vibration,
        'temperature': temperature,
        'maintenanceNote': maintenanceNote,
        'alarmThreshold': alarmThreshold,
      };
}
