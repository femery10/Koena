import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_listview_example/classes/basic_tile.dart';
import 'package:expandable_listview_example/classes/device.dart';
import 'package:expandable_listview_example/classes/room.dart';
import 'package:expandable_listview_example/page/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../texts_menu.dart';
import 'add_device_screen.dart';
import 'add_room_screen.dart';
import 'device_info_screen.dart';

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    fetchAllRooms().then((value) {});
    super.initState();
  }

  bool _isSigningOut = false;

  late BasicTile deviceHolderTile;
  late BasicTile roomTile;
  List deviceIdsList = [];
  List<BasicTile> roomTilesList = [];
  late Device deviceObject;

  logout() async {
      setState(() {
        _isSigningOut = true;
      });
      await FirebaseAuth.instance.signOut();
      setState(() {
        _isSigningOut = false;
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => SignInScreen()));
    }

  fetchAllRooms() async {
    FirebaseFirestore.instance
        .collection('rooms')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          deviceIdsList = doc['deviceIds'];

          List<BasicTile> deviceTiles = [];
          for (var idNumber in deviceIdsList) {
            FirebaseFirestore.instance
                .collection('devices')
                .where('deviceId', isEqualTo: idNumber)
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
              title: doc['roomName'], id: 0, devices: deviceTiles);

          roomTilesList.add(roomTile);

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
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.add),
          iconSize: 40,
          onSelected: (value) {
            switch (value) {
              case TextsMenu.addDevice:
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => AddDeviceScreen()));
                break;
              case TextsMenu.addRoom:
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => AddRoomScreen()));
                break;
              case TextsMenu.logout:
                logout();
            }
          },
          itemBuilder: (context) => TextsMenu.items
              .map((item) => PopupMenuItem<String>(
            value: item,
            child: Text(item),
          ))
              .toList(),
        ),
      ],
      title: Text("Kōena App"),
      leading: new Container(),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      child: ExpansionPanelList.radio(
        expansionCallback: (index, isExpanded) {
          final tile = roomTilesList[index];
          setState(() => tile.isExpanded = isExpanded);
        },
        children: roomTilesList
            .map((tile) => ExpansionPanelRadio(
          value: tile.title,
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) => buildTile(tile),
          body: Column(
            children: tile.devices.map(buildTile).toList(),
          ),
        ))
            .toList(),
      ),
    ),
  );

  Widget buildTile(BasicTile tile) => ListTile(
    title: Text(tile.title),
    onTap: tile.devices.isEmpty
        && tile.id != 0 ? () =>  Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => DeviceInfoScreen(tile.id)))
        : null,
  );
}