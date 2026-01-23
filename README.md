# Draggable Overlay Window

A highly customizable, draggable, and resizable overlay window widget for Flutter. Perfect for creating floating panels, tool windows, and multi-window interfaces with full programmatic control.

[![pub package](https://img.shields.io/pub/v/draggable_overlay_window.svg)](https://pub.dev/packages/draggable_overlay_window)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

✨ **Draggable Windows** - Move windows freely across the screen  
🔄 **Resizable** - Resize from all edges and corners (optional)  
📦 **Minimize/Restore** - Built-in minimize and restore functionality  
🎯 **Focus Management** - Automatic z-index management with focus system  
🎨 **Highly Customizable** - Extensive styling and configuration options  
📱 **Responsive** - Works on all platforms (mobile, web, desktop)  
🎮 **Programmatic Control** - Full API for controlling windows via controller  
🔔 **Event Callbacks** - Rich set of callbacks for all window events  
⚡ **Performance Optimized** - Smooth interactions with no lag

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  draggable_overlay_window: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:draggable_overlay_window/draggable_overlay_window.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final DraggableWindowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DraggableWindowController(
      initialPosition: const Offset(100, 100),
      initialSize: const Size(400, 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverlayWindowStack(
        windows: [
          DraggableOverlayWindow(
            key: ValueKey(_controller.windowId),
            controller: _controller,
            title: 'My Window',
            icon: Icons.window,
            content: Center(
              child: Text('Window Content'),
            ),
          ),
        ],
        child: Center(
          child: ElevatedButton(
            onPressed: () => _controller.toggle(),
            child: Text('Toggle Window'),
          ),
        ),
      ),
    );
  }
}
```

## Configuration

### Window Config

Customize your window appearance and behavior:

```dart
DraggableWindowConfig(
  // Size
  initialWidth: 400.0,
  initialHeight: 300.0,
  minWidth: 200.0,
  minHeight: 150.0,
  maxWidth: 800.0,
  maxHeight: 600.0,
  minimizedHeight: 48.0,
  
  // Appearance
  borderRadius: 12.0,
  elevation: 8.0,
  focusedElevation: 16.0,
  borderWidth: 1.0,
  focusedBorderWidth: 2.0,
  showFocusBorder: true,
  
  // Colors
  windowBackgroundColor: Colors.white,
  headerBackgroundColor: Colors.blue.shade50,
  borderColor: Colors.grey.shade300,
  focusedBorderColor: Colors.blue,
  headerIconColor: Colors.blue.shade700,
  headerButtonsColor: Colors.blue,
  dividerColor: Colors.grey.shade300,
  
  // Behavior
  resizable: true,
  enableScrolling: true,
  
  // Divider
  showDivider: true,
  dividerHeight: 1.0,
  
  // Padding
  contentPadding: EdgeInsets.all(16),
  headerPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  
  // Icons
  minimizeIcon: Icons.remove,
  maximizeIcon: Icons.open_in_full,
  closeIcon: Icons.close,
  dragHandleIcon: Icons.drag_handle,
)
```

### Optional Title and Icon

You can create windows without title or icon:

```dart
DraggableOverlayWindow(
  key: ValueKey(_controller.windowId),
  controller: _controller,
  // No title or icon - only drag handle will be shown
  content: MyContent(),
)
```

### Non-Resizable Window

```dart
DraggableOverlayWindow(
  key: ValueKey(_controller.windowId),
  controller: _controller,
  title: 'Fixed Size',
  config: DraggableWindowConfig(
    resizable: false,
    initialWidth: 400,
    initialHeight: 300,
  ),
  content: MyContent(),
)
```

## Controller API

The `DraggableWindowController` provides full programmatic control:

```dart
final controller = DraggableWindowController(
  initialPosition: Offset(100, 100),
  initialSize: Size(400, 300),
);

// Visibility
controller.show();
controller.hide();
controller.toggle();

// Minimize/Restore
controller.minimize();
controller.restore();

// Position & Size
controller.setPosition(Offset(200, 200));
controller.setSize(Size(500, 400));

// State
bool isVisible = controller.isVisible;
bool isMinimized = controller.isMinimized;
Offset position = controller.position;
Size size = controller.size;

// Listen to changes
controller.addListener(() {
  print('Window state changed');
});
```

## Callbacks

Rich set of callbacks for all window events:

```dart
DraggableOverlayWindow(
  key: ValueKey(_controller.windowId),
  controller: _controller,
  title: 'Event Monitor',
  
  // Window events
  onFocus: () => print('Window focused'),
  onClose: () => print('Window closed'),
  onMinimized: () => print('Window minimized'),
  onRestored: () => print('Window restored'),
  
  // Position & size changes
  onPositionChanged: (offset) => print('Position: $offset'),
  onSizeChanged: (size) => print('Size: $size'),
  
  content: MyContent(),
)
```

## Multiple Windows

Manage multiple windows with automatic z-index:

```dart
OverlayWindowStack(
  windows: [
    DraggableOverlayWindow(
      key: ValueKey(_controller1.windowId),
      controller: _controller1,
      title: 'Window 1',
      content: Content1(),
    ),
    DraggableOverlayWindow(
      key: ValueKey(_controller2.windowId),
      controller: _controller2,
      title: 'Window 2',
      content: Content2(),
    ),
    DraggableOverlayWindow(
      key: ValueKey(_controller3.windowId),
      controller: _controller3,
      title: 'Window 3',
      content: Content3(),
    ),
  ],
  child: YourMainContent(),
)
```

## Advanced Features

### Custom Styling

```dart
DraggableWindowConfig(
  headerTextStyle: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
  headerBackgroundColor: Colors.deepPurple,
  windowBackgroundColor: Colors.grey.shade100,
  focusedBorderColor: Colors.deepPurple,
  headerIconColor: Colors.white,
  headerButtonsColor: Colors.white,
)
```

### Dynamic Sizing

Use calculators for responsive sizing:

```dart
DraggableWindowConfig(
  widthCalculator: (context) => MediaQuery.of(context).size.width * 0.5,
  heightCalculator: (context) => MediaQuery.of(context).size.height * 0.6,
)
```

## Platform Support

| Platform | Supported |
|----------|-----------|
| Android  | ✅        |
| iOS      | ✅        |
| Web      | ✅        |
| Windows  | ✅        |
| macOS    | ✅        |
| Linux    | ✅        |

## Example

Check out the [example](example/) directory for a complete working example with multiple windows and all features demonstrated.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created with ❤️ by [JnNetto]

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.
