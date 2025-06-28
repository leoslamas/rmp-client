# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **rmp_client** - a Flutter application for Remote Media PI torrent management. The app provides a cross-platform interface for searching, downloading, and managing torrents through a remote API.

## Key Architecture

### State Management
- **BLoC Pattern**: Uses `flutter_bloc` library for state management
- **Repository Pattern**: `TorrentRepository` handles all API interactions
- **Dependency Injection**: Uses `RepositoryProvider` and `MultiBlocProvider` for dependency injection

### Core Components
- **TorrentBloc** (`lib/bloc/torrent_bloc.dart`): Manages torrent operations (list, pause, resume, delete)
- **SearchCubit** (`lib/bloc/search_cubit.dart`): Handles torrent search functionality  
- **TorrentRepository** (`lib/repository/torrent_repository.dart`): API client for mock torrent service
- **Models**: `Torrent` and `SearchResult` classes for data representation

### Navigation Architecture
- **HomeScreen** (`lib/screen/home_screen.dart`): Main screen with dual-mode UI
- **ScreenState enum**: Controls switching between `search` and `torrent` modes
- **PopScope**: Uses modern Flutter navigation (replaces deprecated WillPopScope)
- **MultiBlocListener**: Handles state changes and shows SnackBar notifications

### API Integration
- Base URL: `https://private-049ae4-rmp1.apiary-mock.com/torrent`
- Mock API endpoints for search, list, add, resume, pause, and remove operations
- HTTP client using the `http` package
- IP discovery mechanism for local network detection

### Multi-Platform Support
- **Mobile**: Standard Flutter app (Android/iOS)
- **Desktop**: Uses Hover (go-flutter) for desktop deployment
- **Web/Windows/Linux/macOS**: Standard Flutter platform support

## Development Commands

### Setup and Dependencies
```bash
flutter pub get
```

### Running the Application
```bash
# Mobile/Standard platforms
flutter run

# Desktop with Hover (requires Go)
hover init && hover run
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code and check for lint issues
flutter analyze

# Format code according to Dart style guide
dart format lib/ test/
```

### Building
```bash
# Android
flutter build apk

# iOS  
flutter build ios

# Desktop with Hover
hover build

# Web
flutter build web
```

## Code Conventions

### Modern Flutter Practices (Recently Updated)
- Uses `PopScope` instead of deprecated `WillPopScope`
- `const` constructors and widgets where possible
- `super` parameters in constructors (`super.key` instead of `key: key`)
- lowerCamelCase for enum values (`ScreenState.search` not `ScreenState.SEARCH`)
- Proper async context handling with `mounted` checks

### Code Style
- Uses Material 3 design system with deep purple color scheme
- File naming: snake_case (e.g., `torrent.dart` not `Torrent.dart`)
- Model classes use factory constructors for JSON deserialization
- BLoC events and states follow naming convention: `[Action][Entity][Event/State]`
- Repository methods return `Future<T>` and throw `RepositoryException` on errors
- Proper code block formatting (if statements must use braces)

## Project Structure

```
lib/
├── bloc/           # BLoC state management
├── error/          # Custom exceptions
├── model/          # Data models (torrent.dart, search_result.dart)
├── repository/     # API repositories
├── screen/         # UI screens
├── util/           # Utility classes (debouncer)
└── widget/         # Reusable widgets
```

## Dependencies

### Core Dependencies
- `flutter_bloc ^8.0.1`: State management
- `bloc ^8.0.3`: BLoC library  
- `http ^1.2.2`: HTTP client
- `cupertino_icons ^1.0.2`: iOS-style icons

### Development & Testing
- `flutter_test`: Testing framework
- `flutter_lints ^4.0.0`: Dart/Flutter linting rules
- `bloc_test ^9.1.7`: Testing utilities for BLoC
- `mocktail ^1.0.3`: Mocking framework for tests

## Current State & Known Issues

### Recent Improvements
- Replaced deprecated `WillPopScope` with `PopScope`
- Added comprehensive linting with `flutter_lints`
- Fixed file naming conventions (`Torrent.dart` → `torrent.dart`)
- Added testing dependencies for future test implementation

### Pending Improvements
- Comprehensive test coverage (currently minimal)
- Error handling with timeouts and validation
- Configuration extraction for hard-coded URLs
- Input validation and security improvements

### Testing Status
- Current tests are placeholder and don't match app functionality
- Testing infrastructure ready with `bloc_test` and `mocktail`
- Priority: Write tests for BLoCs, Repository, and Models

## Notes

- Desktop support via Hover requires Go installation
- API uses mock endpoints for development/testing
- Portuguese comments in some UI code reflect original development context