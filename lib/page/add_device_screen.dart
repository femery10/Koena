import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_listview_example/classes/device.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddDeviceScreen extends StatefulWidget {
  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final deviceRef =
      FirebaseFirestore.instance.collection('devices').withConverter<Device>(
            fromFirestore: (snapshot, _) => Device.fromJson(snapshot.data()!),
            toFirestore: (device, _) => device.toJson(),
          );

  deleteDeviceWithId(int deviceId) {
    FirebaseFirestore.instance
        .collection('devices')
        .where('deviceId', isEqualTo: deviceId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
  }

  int idNumCounter = 0;

  addDevice() async {
    FirebaseFirestore.instance
        .collection('devices')
        .orderBy('deviceId', descending: false)
        .limitToLast(1)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          idNumCounter = doc["deviceId"] + 1;
        });
      });
      await deviceRef.add(
        Device(
            deviceName: _deviceName.text,
            deviceId: idNumCounter,
            parentRoomId: 1),
      );
    });
  }

  final TextEditingController _deviceName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 250,
                  child: TextFormField(
                    controller: _deviceName,
                    decoration: const InputDecoration(
                        labelText: 'device name',
                        hintText: "input device name"),
                  ),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.blue,
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: () {
                  addDevice();
                },
                child: Text(
                  "Upload Ride Request",
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
              ),
            ]));
  }
}
