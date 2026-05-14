import 'package:flutter/material.dart';

export 'src/window_manager_scope.dart';

/// # DraggableOverlayWindow v2.3
///
/// A draggable, resizable, and minimizable floating window widget for Flutter.
/// Can be used as an overlay window in any Flutter application.
///
/// ## Features:
/// - ✅ Draggable (drag & drop)
/// - ✅ Resizable (resize handles on corners and edges) - can be disabled
/// - ✅ Minimizable with onMinimized/onRestored callbacks
/// - ✅ Closable
/// - ✅ Focus system (z-index) - click to bring to front
/// - ✅ Responsive (adapts to different screen sizes)
/// - ✅ Customizable (optional title and icon, colors, sizes)
/// - ✅ Maintains state when minimized
/// - ✅ Mandatory Key for better widget control

// ============================================================================
// ENUMS & LOCALIZATION
// ============================================================================

/// Supported languages for window tooltips
enum WindowLanguage {
  en,
  it,
  pt,
  es,
  fr,
  de,
}

/// Localization helper for DraggableOverlayWindow tooltips
class _WindowLocalizations {
  static const Map<WindowLanguage, Map<String, String>> _data = {
    WindowLanguage.en: {
      'minimize': 'Minimize',
      'maximize': 'Restore',
      'close': 'Close',
    },
    WindowLanguage.it: {
      'minimize': 'Minimizza',
      'maximize': 'Ripristina',
      'close': 'Chiudi',
    },
    WindowLanguage.pt: {
      'minimize': 'Minimizar',
      'maximize': 'Restaurar',
      'close': 'Fechar',
    },
    WindowLanguage.es: {
      'minimize': 'Minimizar',
      'maximize': 'Restaurar',
      'close': 'Cerrar',
    },
    WindowLanguage.fr: {
      'minimize': 'Réduire',
      'maximize': 'Restaurer',
      'close': 'Fermer',
    },
    WindowLanguage.de: {
      'minimize': 'Minimieren',
      'maximize': 'Wiederherstellen',
      'close': 'Schließen',
    },
  };

  static String get(String key, WindowLanguage language) {
    return _data[language]![key] ?? _data[WindowLanguage.en]![key]!;
  }
}

// ============================================================================
// WINDOW MANAGER (for z-index/focus control)
// ============================================================================

/// Global window manager to control z-index and focus
class WindowManager extends ChangeNotifier {
  static final WindowManager _instance = WindowManager._internal();
  factory WindowManager() => _instance;
  WindowManager._internal();

  final List<String> _windowStack = [];
  int _nextId = 0;

  /// Generates a unique ID for a new window
  String generateId() {
    return 'window_${_nextId++}';
  }

  final Map<String, String> _taggedWindows = {};

  /// Registers a window with an optional tag (to ensure uniqueness)
  void registerWindow(String windowId, {String? tag}) {
    if (tag != null) {
      if (_taggedWindows.containsKey(tag)) {
        // If the tag already exists and points to another ID, update
        // But ideally, the UI should check before
      }
      _taggedWindows[tag] = windowId;
    }

    if (!_windowStack.contains(windowId)) {
      _windowStack.add(windowId);
      notifyListeners();
    }
  }

  /// Removes a window from the manager
  void unregisterWindow(String windowId) {
    _windowStack.remove(windowId);
    _taggedWindows.removeWhere((key, value) => value == windowId);
    notifyListeners();
  }

  /// Checks if a window with the given tag exists
  String? getWindowIdByTag(String tag) {
    return _taggedWindows[tag];
  }

  /// Brings a window to the front (focus)
  void bringToFront(String windowId) {
    if (_windowStack.contains(windowId)) {
      _windowStack.remove(windowId);
      _windowStack.add(windowId);
      notifyListeners();
    }
  }

  /// Returns the z-index of a window (higher = more on top)
  int getZIndex(String windowId) {
    return _windowStack.indexOf(windowId);
  }

  /// Returns whether the window is on top
  bool isOnTop(String windowId) {
    return _windowStack.isNotEmpty && _windowStack.last == windowId;
  }

  /// List of all windows ordered by z-index
  List<String> get windowStack => List.unmodifiable(_windowStack);
}

// ============================================================================
// CONFIGURATIONS
// ============================================================================

/// Customizable configurations for DraggableOverlayWindow
class DraggableWindowConfig {
  /// Height of the window when minimized (header only)
  final double minimizedHeight;

  /// Radius of the rounded corners
  final double borderRadius;

  /// Elevation (shadow) of the window
  final double elevation;

  /// Elevation when the window is in focus
  final double focusedElevation;

  /// Header background color
  final Color? headerBackgroundColor;

  /// Window background color
  final Color? windowBackgroundColor;

  /// Border color
  final Color? borderColor;

  /// Border color when in focus
  final Color? focusedBorderColor;

  /// Whether to enable automatic scrolling in the content
  final bool enableScrolling;

  /// Content padding
  final EdgeInsets contentPadding;

  /// Whether the window can be resized
  final bool resizable;

  /// Size of the drag handle area for resizing
  final double resizeHandleSize;

  /// Minimum width of the window
  final double minWidth;

  /// Minimum height of the window
  final double minHeight;

  /// Maximum width of the window (null = no limit)
  final double? maxWidth;

  /// Maximum height of the window (null = no limit)
  final double? maxHeight;

  /// Initial width of the window
  final double initialWidth;

  /// Initial height of the window
  final double initialHeight;

  /// Function to calculate width based on screen width (overrides initialWidth)
  final double Function(double screenWidth)? widthCalculator;

  /// Function to calculate height based on screen height (overrides initialHeight)
  final double Function(double screenHeight)? heightCalculator;

  /// Minimize icon
  final IconData minimizeIcon;

  /// Maximize/restore icon
  final IconData maximizeIcon;

  /// Close icon
  final IconData closeIcon;

  /// Drag handle icon
  final IconData dragHandleIcon;

  /// Whether to show the minimize button
  final bool showMinimizeButton;

  /// Whether to show the drag handle
  final bool showDragHandle;

  /// Language for tooltips
  final WindowLanguage language;

  /// Whether to center the window on initial opening
  final bool centerInitialPosition;

  /// Whether to show the header
  final bool showHeader;

  const DraggableWindowConfig({
    this.minimizedHeight = 48.0,
    this.borderRadius = 12.0,
    this.elevation = 8.0,
    this.focusedElevation = 16.0,
    this.headerBackgroundColor,
    this.windowBackgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.enableScrolling = true,
    this.contentPadding = const EdgeInsets.only(bottom: 8),
    this.resizable = true,
    this.resizeHandleSize = 8.0,
    this.minWidth = 200.0,
    this.minHeight = 150.0,
    this.maxWidth,
    this.maxHeight,
    this.initialWidth = 400.0,
    this.initialHeight = 350.0,
    this.widthCalculator,
    this.heightCalculator,
    this.minimizeIcon = Icons.remove,
    this.maximizeIcon = Icons.open_in_full,
    this.closeIcon = Icons.close,
    this.dragHandleIcon = Icons.drag_handle,
    this.borderWidth = 1.0,
    this.focusedBorderWidth,
    this.showFocusBorder = true,
    this.dividerHeight = 1.0,
    this.showDivider = true,
    this.dividerColor,
    this.headerPadding,
    this.headerIconColor,
    this.headerButtonsColor,
    this.headerTextStyle,
    this.showMinimizeButton = true,
    this.showDragHandle = true,
    this.language = WindowLanguage.en,
    this.centerInitialPosition = true,
    this.showHeader = true,
  });

  /// Border width
  final double borderWidth;

  /// Border width when in focus
  final double? focusedBorderWidth;

  /// Whether to show the focus border
  final bool showFocusBorder;

  /// Divider height (thickness)
  final double dividerHeight;

  /// Whether to show the divider
  final bool showDivider;

  /// Divider color
  final Color? dividerColor;

  /// Header content padding
  final EdgeInsets? headerPadding;

  /// Header icons color
  final Color? headerIconColor;

  /// Header buttons color
  final Color? headerButtonsColor;

  /// Header text style
  final TextStyle? headerTextStyle;

  /// Default configuration
  static const DraggableWindowConfig defaultConfig = DraggableWindowConfig();

  /// Compact configuration for smaller screens
  static const DraggableWindowConfig compactConfig = DraggableWindowConfig(
    minimizedHeight: 40.0,
    borderRadius: 8.0,
    elevation: 6.0,
    focusedElevation: 12.0,
    contentPadding: EdgeInsets.only(bottom: 4),
    minWidth: 150.0,
    minHeight: 100.0,
    initialWidth: 300.0,
    initialHeight: 250.0,
  );

  /// Creates a copy with modified values
  DraggableWindowConfig copyWith({
    double? minimizedHeight,
    double? borderRadius,
    double? elevation,
    double? focusedElevation,
    Color? headerBackgroundColor,
    Color? windowBackgroundColor,
    Color? borderColor,
    Color? focusedBorderColor,
    bool? enableScrolling,
    EdgeInsets? contentPadding,
    bool? resizable,
    double? resizeHandleSize,
    double? minWidth,
    double? minHeight,
    double? maxWidth,
    double? maxHeight,
    double? initialWidth,
    double? initialHeight,
    double Function(double screenWidth)? widthCalculator,
    double Function(double screenHeight)? heightCalculator,
    IconData? minimizeIcon,
    IconData? maximizeIcon,
    IconData? closeIcon,
    IconData? dragHandleIcon,
    double? borderWidth,
    double? focusedBorderWidth,
    bool? showFocusBorder,
    double? dividerHeight,
    bool? showDivider,
    Color? dividerColor,
    EdgeInsets? headerPadding,
    Color? headerIconColor,
    Color? headerButtonsColor,
    TextStyle? headerTextStyle,
    bool? showMinimizeButton,
    bool? showDragHandle,
    WindowLanguage? language,
    bool? centerInitialPosition,
    bool? showHeader,
  }) {
    return DraggableWindowConfig(
      minimizedHeight: minimizedHeight ?? this.minimizedHeight,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      focusedElevation: focusedElevation ?? this.focusedElevation,
      headerBackgroundColor:
          headerBackgroundColor ?? this.headerBackgroundColor,
      windowBackgroundColor:
          windowBackgroundColor ?? this.windowBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      enableScrolling: enableScrolling ?? this.enableScrolling,
      contentPadding: contentPadding ?? this.contentPadding,
      resizable: resizable ?? this.resizable,
      resizeHandleSize: resizeHandleSize ?? this.resizeHandleSize,
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      initialWidth: initialWidth ?? this.initialWidth,
      initialHeight: initialHeight ?? this.initialHeight,
      widthCalculator: widthCalculator ?? this.widthCalculator,
      heightCalculator: heightCalculator ?? this.heightCalculator,
      minimizeIcon: minimizeIcon ?? this.minimizeIcon,
      maximizeIcon: maximizeIcon ?? this.maximizeIcon,
      closeIcon: closeIcon ?? this.closeIcon,
      dragHandleIcon: dragHandleIcon ?? this.dragHandleIcon,
      borderWidth: borderWidth ?? this.borderWidth,
      focusedBorderWidth: focusedBorderWidth ?? this.focusedBorderWidth,
      showFocusBorder: showFocusBorder ?? this.showFocusBorder,
      dividerHeight: dividerHeight ?? this.dividerHeight,
      showDivider: showDivider ?? this.showDivider,
      dividerColor: dividerColor ?? this.dividerColor,
      headerPadding: headerPadding ?? this.headerPadding,
      headerIconColor: headerIconColor ?? this.headerIconColor,
      headerButtonsColor: headerButtonsColor ?? this.headerButtonsColor,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      showMinimizeButton: showMinimizeButton ?? this.showMinimizeButton,
      showDragHandle: showDragHandle ?? this.showDragHandle,
      language: language ?? this.language,
      centerInitialPosition:
          centerInitialPosition ?? this.centerInitialPosition,
      showHeader: showHeader ?? this.showHeader,
    );
  }
}

// ============================================================================
// CONTROLLER
// ============================================================================
/// Controller for programmatic control of a [DraggableOverlayWindow].
class DraggableWindowController extends ChangeNotifier {
  static final Map<String, DraggableWindowController> _instances = {};

  bool _isVisible = false;
  bool _isMinimized = false;
  Offset _position = const Offset(-9999, -9999);
  Size _size;
  final String _windowId;
  final String? _tag;

  /// Factory constructor
  /// If [tag] is provided and an instance already exists, it returns the existing one.
  factory DraggableWindowController({
    Size initialSize = const Size(400, 350),
    Offset initialPosition = const Offset(-9999, -9999),
    String? tag,
  }) {
    if (tag != null && _instances.containsKey(tag)) {
      return _instances[tag]!;
    }

    final controller = DraggableWindowController._internal(
      initialSize: initialSize,
      initialPosition: initialPosition,
      tag: tag,
    );

    if (tag != null) {
      _instances[tag] = controller;
    }

    return controller;
  }

  DraggableWindowController._internal({
    Size initialSize = const Size(400, 350),
    Offset initialPosition = const Offset(-9999, -9999),
    String? tag,
  })  : _size = initialSize,
        _position = initialPosition,
        _windowId = WindowManager().generateId(),
        _tag = tag;

  /// Unique window ID
  String get windowId => _windowId;

  /// Whether the window is visible
  bool get isVisible => _isVisible;

  /// Whether the window is minimized
  bool get isMinimized => _isMinimized;

  /// Current position of the window
  Offset get position => _position;

  /// Current size of the window
  Size get size => _size;

  /// Whether the window is focused (on top)
  bool get isFocused => WindowManager().isOnTop(_windowId);

  /// Shows the window
  void show() {
    if (!_isVisible) {
      _isVisible = true;
      _isMinimized = false;
      WindowManager().registerWindow(_windowId, tag: _tag);
      WindowManager().bringToFront(_windowId);
      notifyListeners();
    }
  }

  /// Hides the window
  void hide() {
    if (_isVisible) {
      _isVisible = false;
      WindowManager().unregisterWindow(_windowId);
      notifyListeners();
    }
  }

  /// Toggles visibility
  void toggle() {
    if (_isVisible) {
      hide();
    } else {
      show();
    }
  }

  /// Minimizes the window
  void minimize() {
    if (_isVisible && !_isMinimized) {
      _isMinimized = true;
      notifyListeners();
    }
  }

  /// Restores the window (maximizes)
  void restore() {
    if (_isVisible && _isMinimized) {
      _isMinimized = false;
      notifyListeners();
    }
  }

  /// Toggles minimized state
  void toggleMinimize() {
    if (_isVisible) {
      _isMinimized = !_isMinimized;
      notifyListeners();
    }
  }

  /// Brings the window to the front (focus)
  void bringToFront() {
    WindowManager().bringToFront(_windowId);
  }

  /// Sets the window position
  void setPosition(Offset newPosition) {
    if (_position != newPosition) {
      _position = newPosition;
      notifyListeners();
    }
  }

  /// Sets the window size
  void setSize(Size newSize) {
    if (_size != newSize) {
      _size = newSize;
      notifyListeners();
    }
  }

  /// Sets initial position and size without notifying (used in initialization)
  void setInitialState({Offset? position, Size? size}) {
    if (position != null) _position = position;
    if (size != null) _size = size;
  }

  @override
  void dispose() {
    WindowManager().unregisterWindow(_windowId);
    if (_tag != null) {
      _instances.remove(_tag);
    }
    super.dispose();
  }
}

// ============================================================================
// ENUMS
// ============================================================================

/// Resize direction
enum _ResizeDirection {
  topLeft,
  top,
  topRight,
  left,
  right,
  bottomLeft,
  bottom,
  bottomRight,
}

// ============================================================================
// MAIN WIDGET
// ============================================================================

/// Draggable and resizable floating window widget
class DraggableOverlayWindow extends StatefulWidget {
  /// Controller for programmatic control
  final DraggableWindowController controller;

  /// Title displayed in the header (optional)
  final String? title;

  /// Custom title widget (overrides [title] if provided)
  final Widget? titleWidget;

  /// Widget positioned at the start of the header
  final Widget? headerLeading;

  /// Widget(s) positioned before system buttons
  final Widget? headerActions;

  /// Icon displayed in the header (optional)
  final IconData? icon;

  /// Window content
  final Widget content;

  /// Custom configurations
  final DraggableWindowConfig config;

  /// Callback when the window gains focus
  final VoidCallback? onFocus;

  /// Callback when the window is closed
  final VoidCallback? onClose;

  /// Callback when the window is minimized
  final VoidCallback? onMinimized;

  /// Callback when the window is restored (maximized)
  final VoidCallback? onRestored;

  /// Callback when the position changes
  final ValueChanged<Offset>? onPositionChanged;

  /// Callback when the size changes
  final ValueChanged<Size>? onSizeChanged;

  const DraggableOverlayWindow({
    required Key key,
    required this.controller,
    required this.content,
    this.title,
    this.titleWidget,
    this.headerLeading,
    this.headerActions,
    this.icon,
    this.config = const DraggableWindowConfig(),
    this.onFocus,
    this.onClose,
    this.onMinimized,
    this.onRestored,
    this.onPositionChanged,
    this.onSizeChanged,
  }) : super(key: key);

  @override
  State<DraggableOverlayWindow> createState() => _DraggableOverlayWindowState();
}

class _DraggableOverlayWindowState extends State<DraggableOverlayWindow> {
  late Offset _currentPosition;
  late Size _currentSize;
  bool _isPositionInitialized = false;
  final WindowManager _windowManager = WindowManager();

  DraggableWindowController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _initializeSize();
    _currentPosition = _controller.position;
    // If the position is the sentinel, it means it hasn't been explicitly set
    if (_currentPosition != const Offset(-9999, -9999)) {
      _isPositionInitialized = true;
    } else {
      // Temporary fallback until build() can calculate center or use default
      _currentPosition = const Offset(50, 50);
      _isPositionInitialized = false;
    }
    _controller.addListener(_onControllerChanged);
    _windowManager.addListener(_onWindowManagerChanged);

    // Registers the window if visible
    if (_controller.isVisible) {
      _windowManager.registerWindow(_controller.windowId,
          tag: _controller._tag);
    }
  }

  void _initializeSize() {
    // Uses the controller size if defined, otherwise uses config
    Size initialSize;
    if (_controller.size.width > 0 && _controller.size.height > 0) {
      initialSize = _controller.size;
    } else {
      initialSize = Size(
        widget.config.initialWidth,
        widget.config.initialHeight,
      );
    }

    // Apply constraints
    _currentSize = Size(
      initialSize.width.clamp(
        widget.config.minWidth,
        widget.config.maxWidth ?? double.infinity,
      ),
      initialSize.height.clamp(
        widget.config.minHeight,
        widget.config.maxHeight ?? double.infinity,
      ),
    );

    _controller.setInitialState(size: _currentSize);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _windowManager.removeListener(_onWindowManagerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    // Prevents update conflicts with the controller
    if (mounted) {
      setState(() {
        _currentPosition = _controller.position;
        // Clamp size from controller
        _currentSize = Size(
          _controller.size.width.clamp(
            widget.config.minWidth,
            widget.config.maxWidth ?? double.infinity,
          ),
          _controller.size.height.clamp(
            widget.config.minHeight,
            widget.config.maxHeight ?? double.infinity,
          ),
        );
      });
    }
  }

  void _onWindowManagerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  double _calculateWidth(BuildContext context) {
    if (widget.config.widthCalculator != null) {
      final screenWidth = MediaQuery.of(context).size.width;
      return widget.config.widthCalculator!(screenWidth);
    }
    return _currentSize.width;
  }

  double _calculateHeight(BuildContext context) {
    if (widget.config.heightCalculator != null) {
      final screenHeight = MediaQuery.of(context).size.height;
      return widget.config.heightCalculator!(screenHeight);
    }
    return _currentSize.height;
  }

  void _handleTap() {
    _controller.bringToFront();
    widget.onFocus?.call();
  }

  void _handleDragStart(DragStartDetails details) {
    _controller.bringToFront();
    widget.onFocus?.call();
  }

  void _handleDrag(DragUpdateDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final width = _calculateWidth(context);
    // Usar minimizedHeight quando minimizado
    final height = _controller.isMinimized
        ? widget.config.minimizedHeight
        : _calculateHeight(context);

    final newPosition = Offset(
      (_currentPosition.dx + details.delta.dx).clamp(
        0.0,
        screenSize.width - width,
      ),
      (_currentPosition.dy + details.delta.dy).clamp(
        0.0,
        screenSize.height - height,
      ),
    );

    setState(() {
      _currentPosition = newPosition;
    });

    _controller.setPosition(newPosition);
    widget.onPositionChanged?.call(newPosition);
  }

  void _handleResize(_ResizeDirection direction, DragUpdateDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final config = widget.config;
    final dx = details.delta.dx;
    final dy = details.delta.dy;

    // Current position and size
    double left = _currentPosition.dx;
    double top = _currentPosition.dy;
    double width = _currentSize.width;
    double height = _currentSize.height;

    // Apply deltas according to direction
    switch (direction) {
      case _ResizeDirection.left:
      case _ResizeDirection.topLeft:
      case _ResizeDirection.bottomLeft:
        // When resizing from the left, move the left edge
        left += dx;
        width -=
            dx; // Decrease width when moving right, increase when moving left
        break;
      case _ResizeDirection.right:
      case _ResizeDirection.topRight:
      case _ResizeDirection.bottomRight:
        // When resizing from the right, only increase width
        width += dx;
        break;
      default:
        break;
    }

    switch (direction) {
      case _ResizeDirection.top:
      case _ResizeDirection.topLeft:
      case _ResizeDirection.topRight:
        // When resizing from the top, move the top edge
        top += dy;
        height -=
            dy; // Decrease height when moving down, increase when moving up
        break;
      case _ResizeDirection.bottom:
      case _ResizeDirection.bottomLeft:
      case _ResizeDirection.bottomRight:
        // When resizing from the bottom, only increase height
        height += dy;
        break;
      default:
        break;
    }

    // Apply minimum size limits
    if (width < config.minWidth) {
      if (direction == _ResizeDirection.left ||
          direction == _ResizeDirection.topLeft ||
          direction == _ResizeDirection.bottomLeft) {
        // If resizing from the left and minimum is reached,
        // adjust left position to maintain minimum size
        left = _currentPosition.dx + (_currentSize.width - config.minWidth);
      }
      width = config.minWidth;
    }

    if (height < config.minHeight) {
      if (direction == _ResizeDirection.top ||
          direction == _ResizeDirection.topLeft ||
          direction == _ResizeDirection.topRight) {
        // If resizing from the top and minimum is reached,
        // adjust top position to maintain minimum size
        top = _currentPosition.dy + (_currentSize.height - config.minHeight);
      }
      height = config.minHeight;
    }

    // Apply maximum size limits
    final maxW = config.maxWidth ?? screenSize.width;
    final maxH = config.maxHeight ?? screenSize.height;

    if (width > maxW) {
      if (direction == _ResizeDirection.left ||
          direction == _ResizeDirection.topLeft ||
          direction == _ResizeDirection.bottomLeft) {
        left = _currentPosition.dx + (_currentSize.width - maxW);
      }
      width = maxW;
    }

    if (height > maxH) {
      if (direction == _ResizeDirection.top ||
          direction == _ResizeDirection.topLeft ||
          direction == _ResizeDirection.topRight) {
        top = _currentPosition.dy + (_currentSize.height - maxH);
      }
      height = maxH;
    }

    // Ensure it doesn't leave the screen
    if (left < 0) {
      width += left; // Adjust width if left position is negative
      left = 0;
    }
    if (top < 0) {
      height += top; // Adjust height if top position is negative
      top = 0;
    }

    // Ensure the right edge doesn't exceed the screen
    if (left + width > screenSize.width) {
      if (direction == _ResizeDirection.left ||
          direction == _ResizeDirection.topLeft ||
          direction == _ResizeDirection.bottomLeft) {
        // If resizing from the left, adjust left
        left = screenSize.width - width;
        if (left < 0) {
          left = 0;
          width = screenSize.width;
        }
      } else {
        // Otherwise, adjust width
        width = screenSize.width - left;
      }
    }

    // Ensure the bottom edge doesn't exceed the screen
    if (top + height > screenSize.height) {
      if (direction == _ResizeDirection.top ||
          direction == _ResizeDirection.topLeft ||
          direction == _ResizeDirection.topRight) {
        // If resizing from the top, adjust top
        top = screenSize.height - height;
        if (top < 0) {
          top = 0;
          height = screenSize.height;
        }
      } else {
        // Otherwise, adjust height
        height = screenSize.height - top;
      }
    }

    // Update state
    final newPosition = Offset(left, top);
    final newSize = Size(width, height);

    setState(() {
      _currentPosition = newPosition;
      _currentSize = newSize;
    });

    _controller.setPosition(newPosition);
    _controller.setSize(newSize);
    widget.onPositionChanged?.call(newPosition);
    widget.onSizeChanged?.call(newSize);
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isVisible) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    // Initialize position to center if requested and not yet initialized
    if (!_isPositionInitialized && widget.config.centerInitialPosition) {
      final width = _calculateWidth(context).clamp(
        widget.config.minWidth,
        widget.config.maxWidth ?? double.infinity,
      );
      final height = _calculateHeight(context).clamp(
        widget.config.minHeight,
        widget.config.maxHeight ?? double.infinity,
      );

      _currentPosition = Offset(
        (screenSize.width - width) / 2,
        (screenSize.height - height) / 2,
      );
      _controller.setInitialState(position: _currentPosition);
      _isPositionInitialized = true;
    } else if (!_isPositionInitialized) {
      // If centering is disabled and not yet initialized, use default
      _currentPosition = const Offset(50, 50);
      _controller.setInitialState(position: _currentPosition);
      _isPositionInitialized = true;
    }

    final width = _calculateWidth(context).clamp(
      widget.config.minWidth,
      widget.config.maxWidth ?? double.infinity,
    );
    final isMinimized = _controller.isMinimized;
    final isFocused = _windowManager.isOnTop(_controller.windowId);

    // When minimized, use only the header height
    // When expanded, respect minHeight and maxHeight
    final height = isMinimized
        ? widget.config.minimizedHeight
        : _calculateHeight(context).clamp(
            widget.config.minHeight,
            widget.config.maxHeight ?? double.infinity,
          );

    final theme = Theme.of(context);
    final config = widget.config;
    final borderRadius = BorderRadius.circular(config.borderRadius);

    final backgroundColor =
        config.windowBackgroundColor ?? theme.scaffoldBackgroundColor;
    final borderColor = isFocused
        ? (config.focusedBorderColor ?? theme.colorScheme.primary)
        : (config.borderColor ?? Colors.grey.shade300);
    final elevation = isFocused ? config.focusedElevation : config.elevation;

    // Use Align + Transform to avoid ParentData errors in the Stack
    // and ensure the origin is (0,0) for the offset to work correctly
    return Align(
      alignment: Alignment.topLeft,
      child: Transform.translate(
        offset: _currentPosition,
        child: GestureDetector(
          onTap: _handleTap,
          child: Material(
            elevation: elevation,
            borderRadius: borderRadius,
            shadowColor: isFocused
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : null,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
                border: Border.all(
                  color: borderColor,
                  // If focusedBorderWidth is not defined, use borderWidth
                  // If showFocusBorder is false, use borderWidth
                  width: (isFocused && config.showFocusBorder)
                      ? (config.focusedBorderWidth ?? config.borderWidth)
                      : config.borderWidth,
                  style: ((isFocused && config.showFocusBorder
                              ? (config.focusedBorderWidth ??
                                  config.borderWidth)
                              : config.borderWidth) <=
                          0)
                      ? BorderStyle.none
                      : BorderStyle.solid,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Main content
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // When minimized, the header should expand to fill the space
                      if (isMinimized)
                        Expanded(
                          child: _buildHeader(
                            context,
                            isFocused,
                            expandHeight: true,
                          ),
                        )
                      else ...[
                        if (config.showHeader) ...[
                          _buildHeader(context, isFocused, expandHeight: false),
                          if (config.showDivider)
                            Divider(
                              height: config.dividerHeight,
                              thickness: config.dividerHeight,
                              color: config.dividerColor ??
                                  borderColor.withValues(alpha: 0.5),
                            ),
                        ],
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(config.borderRadius),
                            ),
                            child: RepaintBoundary(
                              child: config.enableScrolling
                                  ? SingleChildScrollView(
                                      padding: config.contentPadding,
                                      child: widget.content,
                                    )
                                  : Padding(
                                      padding: config.contentPadding,
                                      child: widget.content,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Resize handles (only if not minimized and resizable)
                  if (!isMinimized && config.resizable)
                    ..._buildResizeHandles(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResizeHandles() {
    final handleSize = widget.config.resizeHandleSize;
    final cornerSize = handleSize * 2;

    return [
      // Edges
      // Top
      Positioned(
        top: 0,
        left: cornerSize,
        right: cornerSize,
        height: handleSize,
        child: _buildResizeHandle(
          _ResizeDirection.top,
          SystemMouseCursors.resizeUp,
        ),
      ),
      // Bottom
      Positioned(
        bottom: 0,
        left: cornerSize,
        right: cornerSize,
        height: handleSize,
        child: _buildResizeHandle(
          _ResizeDirection.bottom,
          SystemMouseCursors.resizeDown,
        ),
      ),
      // Left
      Positioned(
        left: 0,
        top: cornerSize,
        bottom: cornerSize,
        width: handleSize,
        child: _buildResizeHandle(
          _ResizeDirection.left,
          SystemMouseCursors.resizeLeft,
        ),
      ),
      // Right
      Positioned(
        right: 0,
        top: cornerSize,
        bottom: cornerSize,
        width: handleSize,
        child: _buildResizeHandle(
          _ResizeDirection.right,
          SystemMouseCursors.resizeRight,
        ),
      ),
      // Corners
      // Top-Left
      Positioned(
        top: 0,
        left: 0,
        width: cornerSize,
        height: cornerSize,
        child: _buildResizeHandle(
          _ResizeDirection.topLeft,
          SystemMouseCursors.resizeUpLeft,
        ),
      ),
      // Top-Right
      Positioned(
        top: 0,
        right: 0,
        width: cornerSize,
        height: cornerSize,
        child: _buildResizeHandle(
          _ResizeDirection.topRight,
          SystemMouseCursors.resizeUpRight,
        ),
      ),
      // Bottom-Left
      Positioned(
        bottom: 0,
        left: 0,
        width: cornerSize,
        height: cornerSize,
        child: _buildResizeHandle(
          _ResizeDirection.bottomLeft,
          SystemMouseCursors.resizeDownLeft,
        ),
      ),
      // Bottom-Right
      Positioned(
        bottom: 0,
        right: 0,
        width: cornerSize,
        height: cornerSize,
        child: _buildResizeHandle(
          _ResizeDirection.bottomRight,
          SystemMouseCursors.resizeDownRight,
        ),
      ),
    ];
  }

  Widget _buildResizeHandle(_ResizeDirection direction, MouseCursor cursor) {
    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        onPanUpdate: (details) => _handleResize(direction, details),
        onPanStart: (details) {
          // CORRECTION: Bring to front but do NOT call _handleDragStart
          // which caused conflict with resize
          _controller.bringToFront();
          widget.onFocus?.call();
        },
        onPanEnd: (_) {},
        onPanCancel: () {},
        behavior: HitTestBehavior
            .opaque, // CRITICAL CHANGE: from translucent to opaque
        // This prevents the gesture from "leaking" to the parent GestureDetector
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isFocused, {
    bool expandHeight = false,
  }) {
    final theme = Theme.of(context);
    final isMinimized = _controller.isMinimized;
    final config = widget.config;

    final headerColor = config.headerBackgroundColor ??
        (isFocused
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5));

    final padding =
        config.headerPadding ?? const EdgeInsets.symmetric(horizontal: 12);

    return GestureDetector(
      onPanStart: (details) {
        _handleDragStart(details);
      },
      onPanUpdate: _handleDrag,
      onPanEnd: (_) {},
      onPanCancel: () {},
      child: Container(
        // When expandHeight is true, do not set fixed height (let Expanded control)
        height: expandHeight ? null : config.minimizedHeight,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(config.borderRadius),
            bottom: isMinimized
                ? Radius.circular(config.borderRadius)
                : Radius.zero,
          ),
          color: headerColor,
        ),
        child: isMinimized
            ? _buildMinimizedHeader(theme, isFocused)
            : _buildExpandedHeader(theme, isFocused),
      ),
    );
  }

  Widget _buildMinimizedHeader(ThemeData theme, bool isFocused) {
    final defaultIconColor = isFocused ? theme.colorScheme.primary : null;
    final iconColor = widget.config.headerIconColor ?? defaultIconColor;
    final buttonsColor = widget.config.headerButtonsColor ?? iconColor;
    final lang = widget.config.language;

    return Row(
      children: [
        if (widget.config.showDragHandle)
          Icon(widget.config.dragHandleIcon, size: 14, color: iconColor),
        if (widget.headerLeading != null) ...[
          const SizedBox(width: 4),
          widget.headerLeading!,
        ],
        if (widget.icon != null) ...[
          const SizedBox(width: 6),
          Icon(widget.icon, size: 16, color: iconColor),
        ],
        if (widget.titleWidget != null || widget.title != null) ...[
          const SizedBox(width: 6),
          Expanded(child: _buildTitleWidget(theme, isFocused, true)),
        ] else
          const Spacer(),
        const SizedBox(width: 4),
        _buildHeaderButton(
          icon: widget.config.maximizeIcon,
          tooltip: _WindowLocalizations.get('maximize', lang),
          onTap: () {
            _controller.restore();
            widget.onRestored?.call();
          },
          color: buttonsColor,
          isFocused: isFocused,
        ),
        const SizedBox(width: 2),
        _buildHeaderButton(
          icon: widget.config.closeIcon,
          tooltip: _WindowLocalizations.get('close', lang),
          onTap: () {
            _controller.hide();
            widget.onClose?.call();
          },
          isClose: true,
          color: null,
          isFocused: isFocused,
        ),
      ],
    );
  }

  Widget _buildExpandedHeader(ThemeData theme, bool isFocused) {
    final defaultIconColor = isFocused ? theme.colorScheme.primary : null;
    final iconColor = widget.config.headerIconColor ?? defaultIconColor;
    final lang = widget.config.language;

    return Row(
      children: [
        if (widget.config.showDragHandle)
          Icon(widget.config.dragHandleIcon, size: 16, color: iconColor),
        if (widget.headerLeading != null) ...[
          const SizedBox(width: 6),
          widget.headerLeading!,
        ],
        if (widget.icon != null) ...[
          const SizedBox(width: 8),
          Icon(widget.icon, size: 20, color: iconColor),
        ],
        if (widget.titleWidget != null || widget.title != null) ...[
          const SizedBox(width: 8),
          Expanded(child: _buildTitleWidget(theme, isFocused, false)),
        ] else
          const Spacer(),
        if (widget.headerActions != null) ...[
          widget.headerActions!,
          const SizedBox(width: 4),
        ],
        if (widget.config.showMinimizeButton)
          _buildHeaderIconButton(
            icon: widget.config.minimizeIcon,
            tooltip: _WindowLocalizations.get('minimize', lang),
            onPressed: () {
              _controller.minimize();
              widget.onMinimized?.call();
            },
            color: widget.config.headerButtonsColor,
          ),
        _buildHeaderIconButton(
          icon: widget.config.closeIcon,
          tooltip: _WindowLocalizations.get('close', lang),
          onPressed: () {
            _controller.hide();
            widget.onClose?.call();
          },
          isClose: true,
        ),
      ],
    );
  }

  Widget _buildTitleWidget(ThemeData theme, bool isFocused, bool isMinimized) {
    if (widget.titleWidget != null) return widget.titleWidget!;

    return Text(
      widget.title ?? '',
      style: widget.config.headerTextStyle ??
          (isMinimized
              ? theme.textTheme.titleSmall?.copyWith(
                  fontSize: 13,
                  fontWeight: isFocused ? FontWeight.w600 : FontWeight.normal,
                )
              : theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isFocused ? FontWeight.w600 : FontWeight.normal,
                )),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isClose = false,
    bool isFocused = false,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isClose ? Colors.red.shade400 : (color),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isClose = false,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: isClose ? Colors.red.shade400 : color,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WINDOW SCOPE
// ============================================================================

/// A container widget that manages multiple windows with automatic z-index ordering.
class WindowScope extends StatefulWidget {
  final Widget child;
  final List<WindowEntry> windows;

  const WindowScope({
    super.key,
    required this.child,
    this.windows = const [],
  });

  @override
  State<WindowScope> createState() => _WindowScopeState();
}

class _WindowScopeState extends State<WindowScope> {
  final WindowManager _windowManager = WindowManager();

  @override
  void initState() {
    super.initState();
    _windowManager.addListener(_onWindowManagerChanged);
  }

  @override
  void dispose() {
    _windowManager.removeListener(_onWindowManagerChanged);
    super.dispose();
  }

  void _onWindowManagerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final stackOrder = <String, int>{};
    for (int i = 0; i < _windowManager.windowStack.length; i++) {
      stackOrder[_windowManager.windowStack[i]] = i;
    }

    final visibleWindows =
        widget.windows.where((w) => w.controller.isVisible).toList();

    visibleWindows.sort((a, b) {
      final zIndexA = stackOrder[a.controller.windowId] ?? -1;
      final zIndexB = stackOrder[b.controller.windowId] ?? -1;
      return zIndexA.compareTo(zIndexB);
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        ...visibleWindows.map((entry) => _WindowWidget(
              key: ValueKey(entry.controller.windowId),
              entry: entry,
            )),
      ],
    );
  }
}

/// Represents a window entry for use with [WindowScope].
class WindowEntry {
  final DraggableWindowController controller;
  final Widget content;
  final String? title;
  final Widget? titleWidget;
  final Widget? headerLeading;
  final Widget? headerActions;
  final IconData? icon;
  final DraggableWindowConfig config;
  final VoidCallback? onFocus;
  final VoidCallback? onClose;
  final VoidCallback? onMinimized;
  final VoidCallback? onRestored;
  final ValueChanged<Offset>? onPositionChanged;
  final ValueChanged<Size>? onSizeChanged;

  const WindowEntry({
    required this.controller,
    required this.content,
    this.title,
    this.titleWidget,
    this.headerLeading,
    this.headerActions,
    this.icon,
    this.config = const DraggableWindowConfig(),
    this.onFocus,
    this.onClose,
    this.onMinimized,
    this.onRestored,
    this.onPositionChanged,
    this.onSizeChanged,
  });
}

/// Internal widget that renders a single window from WindowScope.
class _WindowWidget extends StatefulWidget {
  final WindowEntry entry;

  const _WindowWidget({
    super.key,
    required this.entry,
  });

  @override
  State<_WindowWidget> createState() => _WindowWidgetState();
}

class _WindowWidgetState extends State<_WindowWidget> {
  final WindowManager _windowManager = WindowManager();

  DraggableWindowController get _controller => widget.entry.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _windowManager.addListener(_onWindowManagerChanged);
    _windowManager.registerWindow(_controller.windowId, tag: _controller._tag);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _windowManager.removeListener(_onWindowManagerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onWindowManagerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DraggableOverlayWindow(
      key: ValueKey(_controller.windowId),
      controller: _controller,
      title: widget.entry.title,
      titleWidget: widget.entry.titleWidget,
      headerLeading: widget.entry.headerLeading,
      headerActions: widget.entry.headerActions,
      icon: widget.entry.icon,
      content: widget.entry.content,
      config: widget.entry.config,
      onFocus: () {
        _windowManager.bringToFront(_controller.windowId);
        widget.entry.onFocus?.call();
      },
      onClose: () {
        _controller.hide();
        widget.entry.onClose?.call();
      },
      onMinimized: widget.entry.onMinimized,
      onRestored: widget.entry.onRestored,
      onPositionChanged: widget.entry.onPositionChanged,
      onSizeChanged: widget.entry.onSizeChanged,
    );
  }
}

// ============================================================================
// WINDOW CONTAINER (for managing multiple windows with correct z-index)
// ============================================================================

/// Container that manages multiple windows with automatic z-index
/// CORRECTION: Uses IndexedStack to maintain correct positions
class OverlayWindowStack extends StatefulWidget {
  /// List of windows to be displayed
  final List<DraggableOverlayWindow> windows;

  /// Main content (below windows)
  final Widget? child;

  const OverlayWindowStack({super.key, required this.windows, this.child});

  @override
  State<OverlayWindowStack> createState() => _OverlayWindowStackState();
}

class _OverlayWindowStackState extends State<OverlayWindowStack> {
  final WindowManager _windowManager = WindowManager();

  @override
  void initState() {
    super.initState();
    _windowManager.addListener(_onWindowManagerChanged);
  }

  @override
  void dispose() {
    _windowManager.removeListener(_onWindowManagerChanged);
    super.dispose();
  }

  void _onWindowManagerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // CORRECTION: Do not reorder widgets, only control visual order
    // using the windowStack order to determine which one is "above"

    // Create a map of windowId -> index in the stack
    final stackOrder = <String, int>{};
    for (int i = 0; i < _windowManager.windowStack.length; i++) {
      stackOrder[_windowManager.windowStack[i]] = i;
    }

    // Sort windows by z-index BUT keep the same key
    final sortedWindows = List<DraggableOverlayWindow>.from(widget.windows);
    sortedWindows.sort((a, b) {
      final zIndexA = stackOrder[a.controller.windowId] ?? -1;
      final zIndexB = stackOrder[b.controller.windowId] ?? -1;
      return zIndexA.compareTo(zIndexB);
    });

    return SizedBox.expand(
      child: Stack(
        children: [
          if (widget.child != null) Positioned.fill(child: widget.child!),
          // CORRECTION: Windows must have keys assigned at creation
          ...sortedWindows,
        ],
      ),
    );
  }
}