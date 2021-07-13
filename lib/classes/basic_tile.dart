import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class BasicTile {
  final String title;
  final int id;
  final List<BasicTile> devices;

  const BasicTile({
    required this.title,
    required this.id,
    this.devices = const [],
  });
}
