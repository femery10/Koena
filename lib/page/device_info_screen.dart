import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_listview_example/classes/device.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class DeviceInfoScreen extends StatefulWidget {
  final int deviceID;

  DeviceInfoScreen(this.deviceID);

  @override
  _DeviceInfoScreenState createState() => _DeviceInfoScreenState(deviceID);
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  @override
  void initState() {
    fetchThisDevice(deviceIdforWidget);
  }

  int deviceId = 1000;
  int automaticTurnOffCondition = 0;
  String deviceName = "";

  Device theDevice = Device(
      deviceName: "deviceName", deviceId: 1000, automaticTurnOffCondition: 0);

  fetchThisDevice(int theDeviceId) async {
    FirebaseFirestore.instance
        .collection('devices')
        .where('deviceId', isEqualTo: theDeviceId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          deviceId = doc["deviceId"];
          deviceName = doc["deviceName"];
          automaticTurnOffCondition = doc['automaticTurnOffCondition'];

          theDevice = Device(
              deviceName: deviceName,
              deviceId: deviceId,
              automaticTurnOffCondition: automaticTurnOffCondition);
        });
      });
    });
  }

  final int deviceIdforWidget;
  final TextEditingController _automaticTurnOffCondition =
      TextEditingController();

  updateCondition() async {
    {
      FirebaseFirestore.instance
          .collection('devices')
          .where('deviceId', isEqualTo: theDevice.deviceId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'automaticTurnOffCondition': int.parse(_automaticTurnOffCondition.text)});
        });
      });
    }
  }

  _DeviceInfoScreenState(this.deviceIdforWidget);
  User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Text("Device Name: " + theDevice.deviceName,
                    style: TextStyle(color: Colors.black, fontSize: 20)),
              ),
              SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Text("Device Id: " + theDevice.deviceId.toString(),
                    style: TextStyle(color: Colors.black, fontSize: 20)),
              ),
              Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Column(
                    children: [
                      Text("Current condition time: " + theDevice.automaticTurnOffCondition.toString(),
                          style: TextStyle(color: Colors.black, fontSize: 20)),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _automaticTurnOffCondition,
                        decoration: const InputDecoration(
                            labelText: 'turn off time (mins)', hintText: 'enter new time here'),
                        //must make the hint automatically set to the current value of the condition
                      ),
                      Text(" minutes",
                          style: TextStyle(color: Colors.black, fontSize: 20)),
                    ],
                  )),
              SizedBox(height: 10,),
              Container(
                child: ElevatedButton(
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
                    updateCondition();
                  },
                  child: Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                ),
              )
            ]));
  }
}
