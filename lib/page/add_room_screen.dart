import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_listview_example/classes/room.dart';
import 'package:expandable_listview_example/page/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddRoomScreen extends StatefulWidget {
  @override
  _AddRoomScreenState createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final roomRef =
  FirebaseFirestore.instance.collection('rooms').withConverter<Room>(
    fromFirestore: (snapshot, _) => Room.fromJson(snapshot.data()!),
    toFirestore: (room, _) => room.toJson(),
  );

  deleteRoomWithId(int roomId) {
    FirebaseFirestore.instance
        .collection('rooms')
        .where('roomId', isEqualTo: roomId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
  }

  int idNumCounter = 0;

  addRoom() async {
    FirebaseFirestore.instance
        .collection('rooms')
        .orderBy('roomId', descending: false)
        .limitToLast(1)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          idNumCounter = doc["roomId"] + 1;
        });
      });
      await roomRef.add(
        Room(
          roomName: _roomName.text,
          roomId: idNumCounter,
          deviceIds: []
        ),
      );
    });
  }

  final TextEditingController _roomName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(leading: new Container()),
        backgroundColor: Colors.white,
        floatingActionButton: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => HomeScreen()));
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
                  child: TextFormField(
                    controller: _roomName,
                    decoration: const InputDecoration(
                        labelText: 'room name',
                        hintText: "input room name"),
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
                  addRoom();
                },
                child: Text(
                  "Add Room",
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
              ),
            ]));
  }
}
