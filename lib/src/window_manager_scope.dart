import 'package:flutter/material.dart';
import '../draggable_overlay_window.dart';

/// A high-level widget that provides automatic window management.
///
/// Wrap your app or a section of it with this widget and use
/// `WindowManagerScope.of(context)` to open/close windows from anywhere.
///
/// This is the recommended way to use the draggable_overlay_window plugin
/// for most use cases.
///
/// ## Basic Example
///
/// ```dart
/// WindowManagerScope(
///   child: Scaffold(
///     body: Center(
///       child: ElevatedButton(
///         onPressed: () {
///           WindowManagerScope.of(context).open(
///             id: 'settings',
///             title: 'Settings',
///             content: SettingsWidget(),
///           );
///         },
///         child: Text('Open Settings'),
///       ),
///     ),
///   ),
/// )
/// ```
///
/// ## Features
///
/// - Automatic window lifecycle management (create, show, hide, dispose)
/// - Unique windows by ID (prevents duplicates)
/// - Non-unique windows (allow multiple instances)
/// - Global callbacks for window events
/// - Access controller from anywhere via context
///
/// ## Opening Windows
///
/// ```dart
/// final windows = WindowManagerScope.of(context);
///
/// // Open a unique window (clicking again brings it to front)
/// windows.open(
///   id: 'profile',
///   title: 'User Profile',
///   content: ProfileWidget(),
/// );
///
/// // Open multiple instances of the same type
/// windows.open(
///   id: 'note',
///   unique: false,
///   title: 'New Note',
///   content: NoteWidget(),
/// );
/// ```
///
/// ## Controlling Windows
///
/// ```dart
/// // Close a specific window
/// windows.close('profile');
///
/// // Close all windows
/// windows.closeAll();
///
/// // Minimize/restore
/// windows.minimize('profile');
/// windows.restore('profile');
///
/// // Bring to front
/// windows.bringToFront('profile');
///
/// // Toggle (open if closed, close if open)
/// windows.toggle(
///   id: 'calculator',
///   title: 'Calculator',
///   content: CalculatorWidget(),
/// );
/// ```
class WindowManagerScope extends StatefulWidget {
  /// The main content of the app.
  final Widget child;

  /// Default configuration applied to all windows.
  ///
  /// Individual windows can override this with their own config.
  final DraggableWindowConfig defaultConfig;

  /// Called when any window is closed.
  final void Function(String windowId)? onWindowClosed;

  /// Called when any window gains focus.
  final void Function(String windowId)? onWindowFocused;

  /// Creates a window manager scope.
  const WindowManagerScope({
    super.key,
    required this.child,
    this.defaultConfig = const DraggableWindowConfig(),
    this.onWindowClosed,
    this.onWindowFocused,
  });

  /// Gets the [WindowManagerScopeController] from the nearest ancestor.
  ///
  /// Throws a [FlutterError] if no [WindowManagerScope] is found.
  ///
  /// Example:
  /// ```dart
  /// final windows = WindowManagerScope.of(context);
  /// windows.open(id: 'settings', content: Settings());
  /// ```
  static WindowManagerScopeController of(BuildContext context) {
    final state = context.findAncestorStateOfType<_WindowManagerScopeState>();
    if (state == null) {
      throw FlutterError(
        'WindowManagerScope.of() called with a context that does not contain a WindowManagerScope.\n'
        'Ensure that your widget is wrapped with a WindowManagerScope.',
      );
    }
    return state._controller;
  }

  /// Gets the [WindowManagerScopeController] from the nearest ancestor,
  /// or returns null if not found.
  ///
  /// Example:
  /// ```dart
  /// final windows = WindowManagerScope.maybeOf(context);
  /// windows?.open(id: 'settings', content: Settings());
  /// ```
  static WindowManagerScopeController? maybeOf(BuildContext context) {
    final state = context.findAncestorStateOfType<_WindowManagerScopeState>();
    return state?._controller;
  }

  @override
  State<WindowManagerScope> createState() => _WindowManagerScopeState();
}

class _WindowManagerScopeState extends State<WindowManagerScope> {
  late final WindowManagerScopeController _controller;
  final Map<String, _ManagedWindow> _windows = {};

  @override
  void initState() {
    super.initState();
    _controller = WindowManagerScopeController._(this);
  }

  @override
  void dispose() {
    for (final window in _windows.values) {
      window.controller.dispose();
    }
    _windows.clear();
    super.dispose();
  }

  void _openWindow({
    required String id,
    Widget? content,
    String? title,
    Widget? titleWidget,
    Widget? headerLeading,
    Widget? headerActions,
    IconData? icon,
    Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customHeader,
    Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customContent,
    DraggableWindowConfig? config,
    Size? initialSize,
    Offset? initialPosition,
    bool unique = true,
    VoidCallback? onClose,
    VoidCallback? onMinimized,
    VoidCallback? onRestored,
  }) {
    // If unique and already exists, update and bring to front
    if (unique && _windows.containsKey(id)) {
      _updateWindow(
        id: id,
        content: content,
        title: title,
        titleWidget: titleWidget,
        headerLeading: headerLeading,
        headerActions: headerActions,
        icon: icon,
        customHeader: customHeader,
        customContent: customContent,
        config: config,
        onClose: onClose,
        onMinimized: onMinimized,
        onRestored: onRestored,
      );

      final existingWindow = _windows[id]!;
      existingWindow.controller.show();
      existingWindow.controller.bringToFront();
      if (existingWindow.controller.isMinimized) {
        existingWindow.controller.restore();
      }
      return;
    }

    // Generate unique ID for non-unique windows
    final finalId =
        unique ? id : '${id}_${DateTime.now().millisecondsSinceEpoch}';

    final controller = DraggableWindowController(
      initialSize: initialSize ??
          Size(
            config?.initialWidth ?? widget.defaultConfig.initialWidth ?? 0,
            config?.initialHeight ?? widget.defaultConfig.initialHeight ?? 0,
          ),
      initialPosition: initialPosition ?? const Offset(-9999, -9999),
      tag: unique ? id : null,
    );

    setState(() {
      _windows[finalId] = _ManagedWindow(
        id: finalId,
        controller: controller,
        content: content,
        title: title,
        titleWidget: titleWidget,
        headerLeading: headerLeading,
        headerActions: headerActions,
        icon: icon,
        config: config ?? widget.defaultConfig,
        customHeader: customHeader,
        customContent: customContent,
        onClose: onClose,
        onMinimized: onMinimized,
        onRestored: onRestored,
      );
      controller.show();
    });
  }

  void _updateWindow({
    required String id,
    Widget? content,
    String? title,
    Widget? titleWidget,
    Widget? headerLeading,
    Widget? headerActions,
    IconData? icon,
    Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customHeader,
    Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customContent,
    DraggableWindowConfig? config,
    VoidCallback? onClose,
    VoidCallback? onMinimized,
    VoidCallback? onRestored,
  }) {
    final window = _windows[id];
    if (window != null) {
      setState(() {
        _windows[id] = window.copyWith(
          content: content,
          title: title,
          titleWidget: titleWidget,
          headerLeading: headerLeading,
          headerActions: headerActions,
          icon: icon,
          customHeader: customHeader,
          customContent: customContent,
          config: config,
          onClose: onClose,
          onMinimized: onMinimized,
          onRestored: onRestored,
        );
      });
    }
  }

  void _closeWindow(String id) {
    final window = _windows[id];
    if (window != null) {
      setState(() {
        window.controller.hide();
        _windows.remove(id);
        window.controller.dispose();
      });
      window.onClose?.call();
      widget.onWindowClosed?.call(id);
    }
  }

  void _closeAll() {
    setState(() {
      for (final window in _windows.values) {
        window.controller.hide();
        window.controller.dispose();
        window.onClose?.call();
        widget.onWindowClosed?.call(window.id);
      }
      _windows.clear();
    });
  }

  void _minimizeWindow(String id) {
    final window = _windows[id];
    if (window != null) {
      window.controller.minimize();
      window.onMinimized?.call();
    }
  }

  void _restoreWindow(String id) {
    final window = _windows[id];
    if (window != null) {
      window.controller.restore();
      window.onRestored?.call();
    }
  }

  void _bringToFront(String id) {
    final window = _windows[id];
    if (window != null) {
      window.controller.bringToFront();
      widget.onWindowFocused?.call(id);
    }
  }

  bool _isOpen(String id) {
    return _windows.containsKey(id) && _windows[id]!.controller.isVisible;
  }

  DraggableWindowController? _getController(String id) {
    return _windows[id]?.controller;
  }

  String? _getWindowTitle(String id) {
    return _windows[id]?.title;
  }

  IconData? _getWindowIcon(String id) {
    return _windows[id]?.icon;
  }

  List<String> get _openWindowIds => _windows.keys.toList();

  @override
  Widget build(BuildContext context) {
    return WindowScope(
      windows: _windows.values
          .map((w) => WindowEntry(
                controller: w.controller,
                content: w.content,
                title: w.title,
                titleWidget: w.titleWidget,
                headerLeading: w.headerLeading,
                headerActions: w.headerActions,
                icon: w.icon,
                customHeader: w.customHeader,
                customContent: w.customContent,
                config: w.config,
                onClose: () => _closeWindow(w.id),
                onMinimized: w.onMinimized,
                onRestored: w.onRestored,
                onFocus: () => widget.onWindowFocused?.call(w.id),
              ))
          .toList(),
      child: widget.child,
    );
  }
}

/// Controller for managing windows via [WindowManagerScope].
///
/// Obtain an instance using `WindowManagerScope.of(context)`.
///
/// ## Methods
///
/// | Method | Description |
/// |--------|-------------|
/// | [open] | Opens a new window or brings existing one to front |
/// | [close] | Closes a specific window |
/// | [closeAll] | Closes all open windows |
/// | [toggle] | Toggles window visibility |
/// | [minimize] | Minimizes a window |
/// | [restore] | Restores a minimized window |
/// | [bringToFront] | Brings a window to the front |
/// | [isOpen] | Checks if a window is open |
/// | [getController] | Gets the controller for advanced operations |
///
/// ## Properties
///
/// | Property | Description |
/// |----------|-------------|
/// | [openWindowIds] | List of IDs of currently open windows |
/// | [windowCount] | Number of currently open windows |
class WindowManagerScopeController {
  final _WindowManagerScopeState _state;

  WindowManagerScopeController._(this._state);

  /// Opens a new window or brings an existing one to front.
  ///
  /// Parameters:
  /// - [id]: Unique identifier for the window
  /// - [content]: Widget to display in the window body
  /// - [title]: Optional title displayed in the header
  /// - [icon]: Optional icon displayed in the header
  /// - [config]: Window configuration (uses default if not provided)
  /// - [initialSize]: Initial size of the window
  /// - [initialPosition]: Initial position of the window
  /// - [unique]: If true (default), prevents multiple windows with same ID
  /// - [onClose]: Callback when the window is closed
  /// - [onMinimized]: Callback when the window is minimized
  /// - [onRestored]: Callback when the window is restored
  ///
  /// Example:
  /// ```dart
  /// windows.open(
  ///   id: 'settings',
  ///   title: 'Settings',
  ///   icon: Icons.settings,
  ///   content: SettingsWidget(),
  ///   initialSize: Size(400, 300),
  ///   config: DraggableWindowConfig(resizable: false),
  /// );
  /// ```
  void open({
    required String id,
    Widget? content,
    String? title,
    Widget? titleWidget,
    Widget? headerLeading,
    Widget? headerActions,
    IconData? icon,
    DraggableWindowConfig? config,
    Size? initialSize,
    Offset? initialPosition,
    bool unique = true,
    Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customHeader,
    Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customContent,
    VoidCallback? onClose,
    VoidCallback? onMinimized,
    VoidCallback? onRestored,
  }) {
    _state._openWindow(
      id: id,
      content: content,
      title: title,
      titleWidget: titleWidget,
      headerLeading: headerLeading,
      headerActions: headerActions,
      icon: icon,
      config: config,
      initialSize: initialSize,
      initialPosition: initialPosition,
      unique: unique,
      customHeader: customHeader,
      customContent: customContent,
      onClose: onClose,
      onMinimized: onMinimized,
      onRestored: onRestored,
    );
  }

  /// Closes a window by its ID.
  ///
  /// Example:
  /// ```dart
  /// windows.close('settings');
  /// ```
  void close(String id) {
    _state._closeWindow(id);
  }

  /// Closes all open windows.
  ///
  /// Example:
  /// ```dart
  /// windows.closeAll();
  /// ```
  void closeAll() {
    _state._closeAll();
  }

  /// Minimizes a window.
  ///
  /// Example:
  /// ```dart
  /// windows.minimize('settings');
  /// ```
  void minimize(String id) {
    _state._minimizeWindow(id);
  }

  /// Restores a minimized window.
  ///
  /// Example:
  /// ```dart
  /// windows.restore('settings');
  /// ```
  void restore(String id) {
    _state._restoreWindow(id);
  }

  /// Brings a window to the front (top z-index).
  ///
  /// Example:
  /// ```dart
  /// windows.bringToFront('settings');
  /// ```
  void bringToFront(String id) {
    _state._bringToFront(id);
  }

  /// Toggles a window's visibility.
  ///
  /// Opens the window if closed, closes it if open.
  ///
  /// Example:
  /// ```dart
  /// windows.toggle(
  ///   id: 'calculator',
  ///   title: 'Calculator',
  ///   content: CalculatorWidget(),
  /// );
  /// ```
  void toggle({
    required String id,
    Widget? content,
    String? title,
    Widget? titleWidget,
    Widget? headerLeading,
    Widget? headerActions,
    IconData? icon,
    DraggableWindowConfig? config,
    Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customHeader,
    Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customContent,
    Size? initialSize,
    Offset? initialPosition,
  }) {
    if (isOpen(id)) {
      close(id);
    } else {
      open(
        id: id,
        content: content,
        title: title,
        titleWidget: titleWidget,
        headerLeading: headerLeading,
        headerActions: headerActions,
        icon: icon,
        config: config,
        customHeader: customHeader,
        customContent: customContent,
        initialSize: initialSize,
        initialPosition: initialPosition,
      );
    }
  }

  /// Updates an existing window's properties.
  ///
  /// This is useful for changing content or configuration
  /// without closing and reopening the window.
  ///
  /// Example:
  /// ```dart
  /// windows.update(
  ///   id: 'settings',
  ///   content: NewSettingsWidget(),
  ///   title: 'Advanced Settings',
  /// );
  /// ```
  void update({
    required String id,
    Widget? content,
    String? title,
    Widget? titleWidget,
    Widget? headerLeading,
    Widget? headerActions,
    IconData? icon,
    DraggableWindowConfig? config,
    Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customHeader,
    Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customContent,
    VoidCallback? onClose,
    VoidCallback? onMinimized,
    VoidCallback? onRestored,
  }) {
    _state._updateWindow(
      id: id,
      content: content,
      title: title,
      titleWidget: titleWidget,
      headerLeading: headerLeading,
      headerActions: headerActions,
      icon: icon,
      config: config,
      customHeader: customHeader,
      customContent: customContent,
      onClose: onClose,
      onMinimized: onMinimized,
      onRestored: onRestored,
    );
  }

  /// Returns whether a window with the given ID is currently open.
  ///
  /// Example:
  /// ```dart
  /// if (windows.isOpen('settings')) {
  ///   print('Settings window is open');
  /// }
  /// ```
  bool isOpen(String id) {
    return _state._isOpen(id);
  }

  /// Gets the [DraggableWindowController] for a specific window.
  ///
  /// Returns null if the window doesn't exist.
  ///
  /// Use this for advanced operations like programmatically
  /// changing position or size.
  ///
  /// Example:
  /// ```dart
  /// final controller = windows.getController('settings');
  /// controller?.setPosition(Offset(100, 100));
  /// ```
  DraggableWindowController? getController(String id) {
    return _state._getController(id);
  }

  /// Gets the current title of a specific window.
  ///
  /// Useful inside custom headers to get the most up-to-date title
  /// when the window is updated via [update].
  String? getWindowTitle(String id) {
    return _state._getWindowTitle(id);
  }

  /// Gets the current icon of a specific window.
  ///
  /// Useful inside custom headers to get the most up-to-date icon
  /// when the window is updated via [update].
  IconData? getWindowIcon(String id) {
    return _state._getWindowIcon(id);
  }

  /// List of IDs of all currently open windows.
  ///
  /// Example:
  /// ```dart
  /// print('Open windows: ${windows.openWindowIds}');
  /// ```
  List<String> get openWindowIds => _state._openWindowIds;

  /// Number of currently open windows.
  ///
  /// Example:
  /// ```dart
  /// print('${windows.windowCount} windows open');
  /// ```
  int get windowCount => _state._windows.length;
}

/// Internal class for storing managed window data.
class _ManagedWindow {
  final String id;
  final DraggableWindowController controller;
  final Widget? content;
  final String? title;
  final Widget? titleWidget;
  final Widget? headerLeading;
  final Widget? headerActions;
  final IconData? icon;
  final DraggableWindowConfig config;
  final Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customHeader;
  final Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customContent;
  final VoidCallback? onClose;
  final VoidCallback? onMinimized;
  final VoidCallback? onRestored;

  _ManagedWindow({
    required this.id,
    required this.controller,
    this.content,
    this.title,
    this.titleWidget,
    this.headerLeading,
    this.headerActions,
    this.icon,
    required this.config,
    this.customHeader,
    this.customContent,
    this.onClose,
    this.onMinimized,
    this.onRestored,
  });

  _ManagedWindow copyWith({
    Widget? content,
    String? title,
    Widget? titleWidget,
    Widget? headerLeading,
    Widget? headerActions,
    IconData? icon,
    DraggableWindowConfig? config,
    Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customHeader,
    Widget? Function(bool isMinimized, StateSetter windowStateSetter)? customContent,
    VoidCallback? onClose,
    VoidCallback? onMinimized,
    VoidCallback? onRestored,
  }) {
    return _ManagedWindow(
      id: id,
      controller: controller,
      content: content ?? this.content,
      title: title ?? this.title,
      titleWidget: titleWidget ?? this.titleWidget,
      headerLeading: headerLeading ?? this.headerLeading,
      headerActions: headerActions ?? this.headerActions,
      icon: icon ?? this.icon,
      config: config ?? this.config,
      customHeader: customHeader ?? this.customHeader,
      customContent: customContent ?? this.customContent,
      onClose: onClose ?? this.onClose,
      onMinimized: onMinimized ?? this.onMinimized,
      onRestored: onRestored ?? this.onRestored,
    );
  }
}
