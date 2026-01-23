# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-23

### Added
- Initial release of Draggable Overlay Window
- Draggable windows with smooth interactions
- Resizable windows from all edges and corners
- Minimize and restore functionality
- Focus management with automatic z-index
- Programmatic control via `DraggableWindowController`
- Rich set of event callbacks (`onFocus`, `onClose`, `onMinimized`, `onRestored`, `onPositionChanged`, `onSizeChanged`)
- Highly customizable appearance (colors, borders, shadows, icons)
- Optional title and icon support
- Non-resizable window option
- Multiple window support with `OverlayWindowStack`
- Dynamic sizing with width/height calculators
- Responsive design for all platforms
- Comprehensive documentation and examples
- Full platform support (Android, iOS, Web, Windows, macOS, Linux)

### Technical Details
- No animations to prevent overflow issues
- Automatic constraint validation with `clamp`
- Optimized for web with `SizedBox.expand` in `OverlayWindowStack`
- Clean, maintainable code architecture
- Required `key` parameter for proper widget management

### Breaking Changes
- None (initial release)

## [Unreleased]

### Planned
- Animation customization (to be implemented in future version with better overflow handling)
- Window snapping to edges
- Window grouping/tabbing
- Keyboard shortcuts
- Window state persistence
