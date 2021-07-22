import 'dart:core';


class Device {

  // change riderId and driverId back to int later
  final int deviceId;
  final String deviceName;
  final int automaticTurnOffCondition;

  Device({required this.deviceId, required this.deviceName, required this.automaticTurnOffCondition});

  Device.fromJson(Map<String, Object?> json)
      : this(
    deviceId: json['deviceId']! as int,
    deviceName: json['deviceName']! as String,
    automaticTurnOffCondition: json['automaticTurnOffCondition']! as int,
  );

  Map<String, Object?> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'automaticTurnOffCondition': automaticTurnOffCondition,
    };
  }
}
