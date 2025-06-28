import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rmp_client/model/torrent.dart';

void main() {
  group('Torrent', () {
    test('should create a Torrent instance with all properties', () {
      const torrent = Torrent(1, 'Test Torrent', 1000000, 'downloading', 50);

      expect(torrent.id, 1);
      expect(torrent.name, 'Test Torrent');
      expect(torrent.size, 1000000);
      expect(torrent.status, 'downloading');
      expect(torrent.progress, 50);
    });

    test('should return correct status color for downloading', () {
      const torrent = Torrent(1, 'Test', 1000, 'downloading', 50);
      expect(torrent.statusColor, Colors.blue);
    });

    test('should return correct status color for error', () {
      const torrent = Torrent(1, 'Test', 1000, 'error', 0);
      expect(torrent.statusColor, Colors.red[200] ?? Colors.red);
    });

    test('should return correct status color for done', () {
      const torrent = Torrent(1, 'Test', 1000, 'done', 100);
      expect(torrent.statusColor, Colors.green);
    });

    test('should return grey color for unknown status', () {
      const torrent = Torrent(1, 'Test', 1000, 'unknown', 0);
      expect(torrent.statusColor, Colors.grey);
    });

    test('should create Torrent from JSON', () {
      final json = {
        'id': 1,
        'name': 'Test Torrent',
        'size': 1000000,
        'status': 'downloading',
        'progress': 75
      };

      final torrent = Torrent.fromJson(json);

      expect(torrent.id, 1);
      expect(torrent.name, 'Test Torrent');
      expect(torrent.size, 1000000);
      expect(torrent.status, 'downloading');
      expect(torrent.progress, 75);
    });

    test('should handle missing fields in JSON gracefully', () {
      final json = {
        'id': 2,
        'name': 'Partial Torrent',
        'size': 500000,
        'status': 'paused',
        'progress': 25
      };

      expect(() => Torrent.fromJson(json), returnsNormally);
    });
  });
}