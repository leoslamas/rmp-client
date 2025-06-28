import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:rmp_client/error/exception.dart';
import 'package:rmp_client/model/search_result.dart';
import 'package:rmp_client/model/torrent.dart';
import 'package:rmp_client/util/debug_logger.dart';

class TorrentRepository {
  static String baseUrl = "https://private-049ae4-rmp1.apiary-mock.com/torrent";

  String _searchTorrentsUrl(String terms) => "$baseUrl/search?terms=$terms";
  String _listTorrentsUrl() => "$baseUrl/list";
  String _downloadTorrentUrl() => "$baseUrl/add";
  String _resumeTorrentUrl(int id) => "$baseUrl/resume/$id";
  String _pauseTorrentUrl(int id) => "$baseUrl/pause/$id";
  String _deleteTorrentUrl(int id) => "$baseUrl/remove/$id";

  Future<List<SearchResult>> searchTorrents(String terms) async {
    Uri url = Uri.parse(_searchTorrentsUrl(terms));
    Response resp = await get(url);

    if (resp.statusCode == HttpStatus.ok) {
      var json = jsonDecode(resp.body) as List;
      return json.map((sr) => SearchResult.fromJson(sr)).toList();
    } else {
      throw RepositoryException(resp.body);
    }
  }

  Future<List<Torrent>> listTorrents() async {
    Uri url = Uri.parse(_listTorrentsUrl());
    Response resp = await get(url);

    if (resp.statusCode == HttpStatus.ok) {
      var json = jsonDecode(resp.body) as List;
      return json.map((torrent) => Torrent.fromJson(torrent)).toList();
    } else {
      throw RepositoryException(resp.body);
    }
  }

  Future<String> downloadTorrent(String magnetUrl) async {
    Uri url = Uri.parse(_downloadTorrentUrl());
    Response resp = await post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"url": magnetUrl}));

    if (resp.statusCode == HttpStatus.ok) {
      return resp.body;
    } else {
      throw RepositoryException(resp.body);
    }
  }

  Future<String> resumeTorrent(int id) async {
    Uri url = Uri.parse(_resumeTorrentUrl(id));
    Response resp = await post(url);

    if (resp.statusCode == HttpStatus.ok) {
      return resp.body;
    } else {
      throw RepositoryException(resp.body);
    }
  }

  Future<String> pauseTorrent(int id) async {
    Uri url = Uri.parse(_pauseTorrentUrl(id));
    Response resp = await post(url);

    if (resp.statusCode == HttpStatus.ok) {
      return resp.body;
    } else {
      throw RepositoryException(resp.body);
    }
  }

  Future<String> deleteTorrent(int id) async {
    Uri url = Uri.parse(_deleteTorrentUrl(id));
    Response resp = await delete(url);

    if (resp.statusCode == HttpStatus.ok) {
      return resp.body;
    } else {
      throw RepositoryException(resp.body);
    }
  }

  Future<String> ipDiscovery() async {
    Completer<String> c = Completer();
    DebugLogger.log("Discovering...");
    RawDatagramSocket? udpSocket;
    
    try {
      //TODO: find broadcast IP dynamically
      var destinationAddress = InternetAddress("192.168.1.255");
      udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 9000);
      udpSocket.broadcastEnabled = true;
      
      udpSocket.listen((e) {
        if (e == RawSocketEvent.read) {
          Datagram? dg = udpSocket?.receive();
          if (dg != null && !c.isCompleted) {
            DebugLogger.log("Host: ${dg.address.host}");
            baseUrl = "http://${dg.address.host}:9090/torrent";
            DebugLogger.log("Updated baseUrl to: $baseUrl");
            c.complete(dg.address.host);
            udpSocket?.close();
          }
        }
      });

      udpSocket.send([1], destinationAddress, 9191);
      
      // Add timeout to prevent hanging
      Timer(const Duration(seconds: 5), () {
        if (!c.isCompleted) {
          udpSocket?.close();
          c.complete("localhost"); // Fallback to localhost
        }
      });
      
    } catch (e) {
      DebugLogger.log("Error: $e");
      udpSocket?.close();
      if (!c.isCompleted) {
        c.complete("localhost"); // Fallback to localhost instead of error
      }
    }
    return c.future;
  }
}
