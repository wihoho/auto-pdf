# Auto PDF Converter

A Windows desktop application built with Flutter that automatically converts PowerPoint files (.ppt and .pptx) to PDF format when they are added to a monitored folder.

## Features

- **Automatic Monitoring**: Watches a selected folder for new PowerPoint files
- **Instant Conversion**: Automatically converts PPT/PPTX files to PDF using Microsoft PowerPoint
- **User-Friendly Interface**: Simple and intuitive GUI with real-time status updates
- **Activity Logging**: Comprehensive logging of all conversion activities and errors
- **Background Operation**: Runs quietly in the background without interrupting your workflow
- **Error Handling**: Robust error handling with detailed error messages

## Requirements

- **Windows Operating System**: Windows 10 or later
- **Microsoft PowerPoint**: Must be installed on the system for conversion functionality
- **Flutter SDK**: Required for development (not needed for end users)

## Installation

### For End Users

1. Download the latest release from the releases page
2. Extract the ZIP file to your desired location
3. Run `auto_pdf_converter.exe`

### For Developers

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/auto-pdf-converter.git
   cd auto-pdf-converter
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run -d windows
   ```

4. Build for release:
   ```bash
   flutter build windows --release
   ```

## Usage

1. **Launch the Application**: Run the Auto PDF Converter executable

2. **Select a Folder**: Click "Browse for Folder" to choose the directory you want to monitor

3. **Start Monitoring**: Click "Start Monitoring" to begin watching for new PowerPoint files

4. **Add PowerPoint Files**: Copy or save PowerPoint files (.ppt or .pptx) to the monitored folder

5. **Automatic Conversion**: The application will automatically detect new files and convert them to PDF

6. **Monitor Progress**: View real-time logs and status updates in the application window

7. **Stop Monitoring**: Click "Stop Monitoring" when you're done

## How It Works

The application uses the following technologies and approaches:

- **File System Watcher**: Monitors the selected directory for file system changes
- **PowerShell Automation**: Uses PowerShell scripts to automate Microsoft PowerPoint for conversion
- **COM Automation**: Leverages PowerPoint's COM interface for reliable PDF generation
- **Flutter Desktop**: Provides a modern, responsive user interface

## Conversion Process

When a new PowerPoint file is detected:

1. The file watcher triggers a conversion event
2. A PowerShell script is generated with the file paths
3. PowerPoint is launched in the background (invisible mode)
4. The presentation is opened and exported as PDF
5. PowerPoint is properly closed and COM objects are released
6. The PDF file is saved in the same directory as the original

## Troubleshooting

### Common Issues

**"Microsoft PowerPoint may not be installed"**
- Ensure Microsoft PowerPoint is installed and properly licensed
- Try opening PowerPoint manually to verify it works

**"Failed to convert" errors**
- Check that the PowerPoint file is not corrupted
- Ensure the file is not currently open in another application
- Verify you have write permissions to the target directory

**"Directory does not exist" error**
- Make sure the selected folder still exists
- Check that you have read permissions for the folder

### Logs

The application maintains detailed logs that can help diagnose issues:
- View logs in the "Activity Log" section of the application
- Copy logs to clipboard using the copy button
- Clear logs using the clear button when needed

## Development

### Project Structure

```
lib/
├── main.dart                 # Application entry point
├── providers/
│   └── app_state_provider.dart    # State management
├── services/
│   ├── conversion_service.dart    # PowerPoint to PDF conversion
│   ├── file_watcher_service.dart  # File system monitoring
│   └── logging_service.dart       # Logging functionality
├── screens/
│   └── main_screen.dart           # Main application screen
└── widgets/
    ├── folder_selection_widget.dart    # Folder selection UI
    ├── monitoring_control_widget.dart  # Start/stop controls
    ├── status_display_widget.dart      # Status information
    └── log_display_widget.dart         # Activity log display
```

### Key Dependencies

- `file_picker`: For folder selection dialog
- `watcher`: For file system monitoring
- `provider`: For state management
- `window_manager`: For window management
- `system_tray`: For system tray integration (future feature)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Flutter](https://flutter.dev/) for cross-platform desktop development
- Uses Microsoft PowerPoint COM automation for reliable PDF conversion
- Inspired by the need to automate repetitive document conversion tasks
