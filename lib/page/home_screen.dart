import 'package:expandable_listview_example/classes/basic_tile.dart';
import 'package:expandable_listview_example/classes/device.dart';
import 'package:expandable_listview_example/page/add_device_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../classes/room.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    fetchAllRooms().then((value) {});
    print(roomTilesList.toString());
    super.initState();
  }

  List<BasicTile> deviceTiles = [];
  late BasicTile deviceHolderTile;
  late BasicTile roomTile;
  List deviceIdsList = [];
  List<BasicTile> roomTilesList = [];
  late Device deviceObject;

  fetchAllRooms() async {
    FirebaseFirestore.instance
        .collection('rooms')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          deviceIdsList = doc['deviceIds'];

          for (var i = 0; i < deviceIdsList.length; i++) {
            FirebaseFirestore.instance
                .collection('devices')
                .where('deviceId', isEqualTo: deviceIdsList[i])
                .get()
                .then((QuerySnapshot querySnapshot) {
              querySnapshot.docs.forEach((doc) {
                setState(() {
                  deviceHolderTile = BasicTile(
                      title: doc['deviceName'],
                      id: doc['deviceId'],
                      devices: []);
                  deviceTiles.add(deviceHolderTile);
                });
              });
            });
          }

          roomTile = BasicTile(
              title: doc['roomName'], id: doc['roomId'], devices: deviceTiles);

          roomTilesList.add(roomTile);

          // roomTilesList = [
          //   BasicTile(title: 'Living Room', id: 1, devices: [
          //     BasicTile(title: 'TV', id: 1),
          //     BasicTile(title: "Lighting", id: 2)
          //   ]),
          //   BasicTile(title: 'Master Bedroom', id: 2, devices: [
          //     BasicTile(title: "bOB", id: 3),
          //   ]),
          // ];

        });
      });
    });
  }


  final roomRef =
      FirebaseFirestore.instance.collection('rooms').withConverter<Room>(
            fromFirestore: (snapshot, _) => Room.fromJson(snapshot.data()!),
            toFirestore: (room, _) => room.toJson(),
          );

  List<int> deviceIds = [1, 2, 4];

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
          roomId: idNumCounter,
          roomName: "please work",
          deviceIds: deviceIds,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Kōena App"),
          centerTitle: true,
        ),
        body: Column(
          children:
              roomTilesList.map((tile) => BasicTileWidget(tile: tile)).toList(),
        ),
        floatingActionButton: ElevatedButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddDeviceScreen())),
          child: Text("Add Device"),
        ),
      );
}

class BasicTileWidget extends StatelessWidget {
  final BasicTile tile;

  BasicTileWidget({required this.tile});

  // const BasicTileWidget({
  //   required Key key,
  //   required this.tile,
  // }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = tile.title;
    final tiles = tile.devices;

    if (tiles.isEmpty) {
      return ListTile(
        title: Text(title),
      );
    } else {
      return Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
        child: ExpansionTile(
          key: PageStorageKey(title),
          //title of the room
          title: Text(title),
          children: tiles
              .map((tile) => BasicTileWidget(
                    tile: tile,
                  ))
              .toList(),
        ),
      );
    }
  }
}
