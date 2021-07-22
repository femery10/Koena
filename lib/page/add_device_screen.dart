import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_listview_example/classes/device.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class AddDeviceScreen extends StatefulWidget {
  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  @override
  void initState() {
    fetchListOfRooms().then((value) {});
    super.initState();
  }

  final deviceRef =
      FirebaseFirestore.instance.collection('devices').withConverter<Device>(
            fromFirestore: (snapshot, _) => Device.fromJson(snapshot.data()!),
            toFirestore: (device, _) => device.toJson(),
          );

  String roomNameHolder = "";
  List<String> listOfRooms = [];
  String location = "";

  fetchListOfRooms() async {
    FirebaseFirestore.instance
        .collection('rooms')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          roomNameHolder = doc['roomName'];
          location = doc['roomName'];
          listOfRooms.add(roomNameHolder);
        });
      });
    });
  }

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
  List deviceIdsTempList = [];

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
      FirebaseFirestore.instance
          .collection('rooms')
          .where('roomName', isEqualTo: location)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        querySnapshot.docs.forEach((doc) {
          setState(() {
            deviceIdsTempList = doc['deviceIds'];
            deviceIdsTempList.add(idNumCounter);
            doc.reference.update({'deviceIds': deviceIdsTempList});
          });
          });
        });
      await deviceRef.add(
        Device(
          deviceName: _deviceName.text,
          deviceId: idNumCounter,
          automaticTurnOffCondition: int.parse(_automaticTurnOffCondition.text),
        ),
      );
    });
  }

  final TextEditingController _deviceName = TextEditingController();
  final TextEditingController _automaticTurnOffCondition = TextEditingController();
  User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(leading: new Container()),
        backgroundColor: Colors.white,
        floatingActionButton: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()));
          },
          icon: Icon(Icons.home_filled),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 250,
                  child: DropdownButton<String>(
                    menuMaxHeight: 480,
                    value: location,
                    dropdownColor: Colors.white,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black, fontSize: 24),
                    onChanged: (String? newValue) {
                      setState(() {
                        location = newValue!;
                      });
                    },
                    items: listOfRooms
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
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
              Center(child: Container(
                width: 250,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _automaticTurnOffCondition,
                  decoration: const InputDecoration(
                      labelText: 'turn off time (mins)',
                      hintText: "turn off after"),
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
                  "Add Device",
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
              ),
            ]));
  }
}
