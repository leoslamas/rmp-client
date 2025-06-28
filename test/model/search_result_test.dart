import 'package:flutter_test/flutter_test.dart';
import 'package:rmp_client/model/search_result.dart';

void main() {
  group('SearchResult', () {
    test('should create a SearchResult instance with all properties', () {
      final searchResult = SearchResult(
        'Test Movie',
        '10',
        '5',
        '1024',
        'http://example.com/movie.torrent'
      );

      expect(searchResult.name, 'Test Movie');
      expect(searchResult.seeders, '10');
      expect(searchResult.leechers, '5');
      expect(searchResult.size, '1024');
      expect(searchResult.url, 'http://example.com/movie.torrent');
    });

    test('should create SearchResult from JSON', () {
      final json = {
        'name': 'Test Series',
        'seeders': '20',
        'leechers': '8',
        'size': '2048',
        'url': 'http://example.com/series.torrent'
      };

      final searchResult = SearchResult.fromJson(json);

      expect(searchResult.name, 'Test Series');
      expect(searchResult.seeders, '20');
      expect(searchResult.leechers, '8');
      expect(searchResult.size, '2048');
      expect(searchResult.url, 'http://example.com/series.torrent');
    });

    test('should handle empty strings in JSON', () {
      final json = {
        'name': '',
        'seeders': '0',
        'leechers': '0',
        'size': '0',
        'url': ''
      };

      final searchResult = SearchResult.fromJson(json);

      expect(searchResult.name, '');
      expect(searchResult.seeders, '0');
      expect(searchResult.leechers, '0');
      expect(searchResult.size, '0');
      expect(searchResult.url, '');
    });
  });
}