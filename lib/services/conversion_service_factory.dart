import 'dart:io';
import 'conversion_service_interface.dart';
import 'conversion_service_windows.dart';
import 'conversion_service_macos.dart';

/// Factory class to create the appropriate conversion service based on the platform
class ConversionServiceFactory {
  /// Creates the appropriate conversion service for the current platform
  static ConversionServiceInterface create() {
    if (Platform.isWindows) {
      return ConversionServiceWindows();
    } else if (Platform.isMacOS) {
      return ConversionServiceMacOS();
    } else {
      throw UnsupportedError(
        'Platform ${Platform.operatingSystem} is not supported. '
        'Only Windows and macOS are currently supported.'
      );
    }
  }
  
  /// Gets the current platform name
  static String get currentPlatform {
    if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else {
      return Platform.operatingSystem;
    }
  }
  
  /// Checks if the current platform is supported
  static bool get isCurrentPlatformSupported {
    return Platform.isWindows || Platform.isMacOS;
  }
  
  /// Gets platform-specific requirements message
  static String get platformRequirements {
    if (Platform.isWindows) {
      return 'Requires Microsoft PowerPoint to be installed on Windows';
    } else if (Platform.isMacOS) {
      return 'Requires Microsoft PowerPoint for Mac to be installed';
    } else {
      return 'Platform ${Platform.operatingSystem} is not supported';
    }
  }
}
