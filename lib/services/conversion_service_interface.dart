/// Abstract interface for PowerPoint to PDF conversion services
abstract class ConversionServiceInterface {
  /// Converts a PowerPoint file to PDF
  /// Returns true if conversion was successful, false otherwise
  Future<bool> convertPptToPdf(String pptFilePath);
  
  /// Checks if the required PowerPoint application is installed and accessible
  Future<bool> isPowerPointInstalled();
  
  /// Gets the platform-specific name of the PowerPoint application
  String get powerPointAppName;
  
  /// Gets platform-specific requirements or notes
  String get platformRequirements;
}
