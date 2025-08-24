import 'package:flutter_test/flutter_test.dart';
import 'package:auto_pdf_converter/services/conversion_service_factory.dart';
import 'package:auto_pdf_converter/services/conversion_service.dart';

void main() {
  group('ConversionService Tests', () {
    test('should create appropriate platform service', () {
      expect(ConversionServiceFactory.isCurrentPlatformSupported, isTrue);
      expect(ConversionServiceFactory.currentPlatform, isNotEmpty);
      
      final service = ConversionServiceFactory.create();
      expect(service, isNotNull);
      expect(service.powerPointAppName, isNotEmpty);
      expect(service.platformRequirements, isNotEmpty);
    });

    test('should initialize conversion service without errors', () {
      expect(() => ConversionService(), returnsNormally);
      
      final service = ConversionService();
      expect(service.currentPlatform, isNotEmpty);
      expect(service.powerPointAppName, isNotEmpty);
      expect(service.platformRequirements, isNotEmpty);
      expect(service.isCurrentPlatformSupported, isTrue);
    });

    test('should handle PowerPoint installation check gracefully', () async {
      final service = ConversionService();
      
      // This should not throw an exception, even if PowerPoint is not installed
      expect(() async => await service.isPowerPointInstalled(), returnsNormally);
      
      final isInstalled = await service.isPowerPointInstalled();
      expect(isInstalled, isA<bool>());
    });
  });
}
