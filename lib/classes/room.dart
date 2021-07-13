import 'dart:core';


class Room {

  final int roomId;
  final String roomName;
  final List<int> deviceIds;


  Room({required this.roomId, required this.roomName, required this.deviceIds,
  });

  Room.fromJson(Map<String, Object?> json)
      : this(
    roomId: json['roomId']! as int,
    roomName: json['roomName']! as String,
    deviceIds: json['deviceIds']! as List<int>,
  );

  Map<String, Object?> toJson() {
    return {
      'roomId': roomId,
      'roomName': roomName,
      'deviceIds': deviceIds,
    };
  }
}
