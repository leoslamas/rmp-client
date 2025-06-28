import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'test/model/torrent_test.dart' as torrent_test;
import 'test/model/search_result_test.dart' as search_result_test;
import 'test/bloc/torrent_bloc_test.dart' as torrent_bloc_test;
import 'test/bloc/search_cubit_test.dart' as search_cubit_test;
import 'test/util/debug_logger_test.dart' as debug_logger_test;

void main() {
  group('All Tests', () {
    group('Model Tests', () {
      torrent_test.main();
      search_result_test.main();
    });
    
    group('BLoC Tests', () {
      torrent_bloc_test.main();
      search_cubit_test.main();
    });
    
    group('Utility Tests', () {
      debug_logger_test.main();
    });
  });
}