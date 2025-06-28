import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class Torrent extends Equatable {
  final int id;
  final String name;
  final String status;
  final int size;
  final int progress;

  const Torrent(this.id, this.name, this.size, this.status, this.progress);

  Color get statusColor {
    switch (status) {
      case "downloading":
        return Colors.blue;
      case "error":
        return Colors.red[200] ?? Colors.red;
      case "done":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  factory Torrent.fromJson(dynamic json) {
    return Torrent(json['id'] as int, json['name'] as String,
        json['size'] as int, json['status'] as String, json['progress'] as int);
  }
  
  @override
  List<Object> get props => [id, name, status, size, progress];
}
