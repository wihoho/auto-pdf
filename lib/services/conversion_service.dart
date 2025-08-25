import 'dart:io';
import 'package:logging/logging.dart';
import 'conversion_service_interface.dart';
import 'conversion_service_factory.dart';

/// Main conversion service that delegates to platform-specific implementations
class ConversionService {
  final Logger _logger = Logger('ConversionService');
  late final ConversionServiceInterface _platformService;
  
  ConversionService() {
    try {
      _platformService = ConversionServiceFactory.create();
      _logger.info('Initialized conversion service for ${ConversionServiceFactory.currentPlatform}');
      _logger.info('Platform requirements: ${_platformService.platformRequirements}');
    } catch (e) {
      _logger.severe('Failed to initialize conversion service: $e');
      rethrow;
    }
  }
  
  /// Converts a PowerPoint file to PDF using platform-specific automation
  Future<bool> convertPptToPdf(String pptFilePath) async {
    _logger.info('=== CONVERSION START (${ConversionServiceFactory.currentPlatform}) ===');
    _logger.info('Target file: $pptFilePath');
    _logger.info('Using: ${_platformService.powerPointAppName}');
    
    try {
      return await _platformService.convertPptToPdf(pptFilePath);
    } catch (e, stackTrace) {
      _logger.severe('Platform conversion service failed: $e');
      _logger.severe('Stack trace: $stackTrace');
      return false;
    }
  }
  
  /// Checks if PowerPoint is installed and accessible
  Future<bool> isPowerPointInstalled() async {
    try {
      return await _platformService.isPowerPointInstalled();
    } catch (e) {
      _logger.severe('Error checking PowerPoint installation: $e');
      return false;
    }
  }
  
  /// Gets the platform-specific PowerPoint application name
  String get powerPointAppName => _platformService.powerPointAppName;
  
  /// Gets platform-specific requirements
  String get platformRequirements => _platformService.platformRequirements;
  
  /// Gets the current platform name
  String get currentPlatform => ConversionServiceFactory.currentPlatform;
  
  /// Checks if the current platform is supported
  bool get isCurrentPlatformSupported => ConversionServiceFactory.isCurrentPlatformSupported;
}
