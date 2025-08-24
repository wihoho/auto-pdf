import 'dart:io';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:logging/logging.dart';

class SystemTrayService {
  static final SystemTrayService _instance = SystemTrayService._internal();
  static SystemTrayService get instance => _instance;
  
  SystemTrayService._internal();
  
  final Logger _logger = Logger('SystemTrayService');
  final SystemTray _systemTray = SystemTray();
  bool _isInitialized = false;
  
  // Callbacks
  Function()? onShowWindow;
  Function()? onHideWindow;
  Function()? onExit;
  
  bool get isInitialized => _isInitialized;
  
  Future<bool> initialize() async {
    try {
      // Initialize system tray
      await _systemTray.initSystemTray(
        title: "Auto PDF Converter",
        iconPath: _getIconPath(),
      );
      
      // Set up context menu
      await _setupContextMenu();
      
      // Set up event handlers
      _setupEventHandlers();
      
      _isInitialized = true;
      _logger.info('System tray initialized successfully');
      return true;
      
    } catch (e) {
      _logger.severe('Failed to initialize system tray: $e');
      return false;
    }
  }
  
  Future<void> _setupContextMenu() async {
    final Menu menu = Menu();
    
    await menu.buildFrom([
      MenuItemLabel(
        label: 'Show Window',
        onClicked: (menuItem) => _showWindow(),
      ),
      MenuItemLabel(
        label: 'Hide Window',
        onClicked: (menuItem) => _hideWindow(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Exit',
        onClicked: (menuItem) => _exitApplication(),
      ),
    ]);
    
    await _systemTray.setContextMenu(menu);
  }
  
  void _setupEventHandlers() {
    // Handle system tray click
    _systemTray.registerSystemTrayEventHandler((eventName) {
      _logger.fine('System tray event: $eventName');
      
      if (eventName == kSystemTrayEventClick) {
        _toggleWindow();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }
  
  Future<void> _showWindow() async {
    try {
      await windowManager.show();
      await windowManager.focus();
      onShowWindow?.call();
      _logger.info('Window shown from system tray');
    } catch (e) {
      _logger.warning('Failed to show window: $e');
    }
  }
  
  Future<void> _hideWindow() async {
    try {
      await windowManager.hide();
      onHideWindow?.call();
      _logger.info('Window hidden to system tray');
    } catch (e) {
      _logger.warning('Failed to hide window: $e');
    }
  }
  
  Future<void> _toggleWindow() async {
    try {
      final isVisible = await windowManager.isVisible();
      if (isVisible) {
        await _hideWindow();
      } else {
        await _showWindow();
      }
    } catch (e) {
      _logger.warning('Failed to toggle window: $e');
    }
  }
  
  void _exitApplication() {
    _logger.info('Exit requested from system tray');
    onExit?.call();
  }
  
  Future<void> updateTooltip(String tooltip) async {
    try {
      await _systemTray.setToolTip(tooltip);
    } catch (e) {
      _logger.warning('Failed to update tooltip: $e');
    }
  }
  
  Future<void> showNotification({
    required String title,
    required String message,
    String? iconPath,
  }) async {
    try {
      // Note: system_tray package may not support notifications directly
      // This is a placeholder for future implementation
      _logger.info('Notification: $title - $message');
    } catch (e) {
      _logger.warning('Failed to show notification: $e');
    }
  }
  
  String _getIconPath() {
    // Try to find an appropriate icon
    const possiblePaths = [
      'assets/icons/app_icon.ico',
      'assets/icons/app_icon.png',
      'windows/runner/resources/app_icon.ico',
    ];
    
    for (final path in possiblePaths) {
      final file = File(path);
      if (file.existsSync()) {
        return path;
      }
    }
    
    // Return empty string if no icon found - system tray will use default
    _logger.warning('No system tray icon found, using default');
    return '';
  }
  
  Future<void> dispose() async {
    try {
      if (_isInitialized) {
        await _systemTray.destroy();
        _isInitialized = false;
        _logger.info('System tray disposed');
      }
    } catch (e) {
      _logger.warning('Error disposing system tray: $e');
    }
  }
}
