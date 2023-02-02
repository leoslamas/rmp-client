import 'package:flutter/material.dart';

class Torrent {
  int id;
  String name;
  String status;
  int size;
  int progress;

  Torrent(this.id, this.name, this.size, this.status, this.progress);

  Color get statusColor {
    switch (this.status) {
      case "downloading":
        return Colors.blue;
        break;
      case "error":
        return Colors.red[200];
        break;
      case "done":
        return Colors.green;
        break;
      default:
        return Colors.grey;
    }
  }

  factory Torrent.fromJson(dynamic json) {
    return Torrent(json['id'] as int, json['name'] as String,
        json['size'] as int, json['status'] as String, json['progress'] as int);
  }
}
