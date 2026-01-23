import 'package:flutter/material.dart';

/// # DraggableOverlayWindow v2.2
///
/// Um widget de janela flutuante arrastável, redimensionável e minimizável para Flutter.
/// Pode ser usado como uma janela de overlay em qualquer aplicação Flutter.
///
/// ## Características:
/// - ✅ Arrastável (drag & drop)
/// - ✅ Redimensionável (resize handles nos cantos e bordas) - pode ser desabilitado
/// - ✅ Minimizável com callbacks onMinimized/onRestored
/// - ✅ Fechável
/// - ✅ Sistema de foco (z-index) - clique para trazer ao topo
/// - ✅ Responsivo (adapta-se a diferentes tamanhos de tela)
/// - ✅ Personalizável (título e ícone opcionais, cores, tamanhos)
/// - ✅ Mantém estado quando minimizado
/// - ✅ Key obrigatória para melhor controle do widget

// ============================================================================
// GERENCIADOR DE JANELAS (para controle de z-index/foco)
// ============================================================================

/// Gerenciador global de janelas para controlar z-index e foco
class WindowManager extends ChangeNotifier {
  static final WindowManager _instance = WindowManager._internal();
  factory WindowManager() => _instance;
  WindowManager._internal();

  final List<String> _windowStack = [];
  int _nextId = 0;

  /// Gera um ID único para uma nova janela
  String generateId() {
    return 'window_${_nextId++}';
  }

  final Map<String, String> _taggedWindows = {};

  /// Registra uma janela com uma tag opcional (para garantir unicidade)
  void registerWindow(String windowId, {String? tag}) {
    if (tag != null) {
      if (_taggedWindows.containsKey(tag)) {
        // Se a tag já existe e aponta para outro ID, atualiza
        // Mas idealmente, a UI deve verificar antes
      }
      _taggedWindows[tag] = windowId;
    }

    if (!_windowStack.contains(windowId)) {
      _windowStack.add(windowId);
      notifyListeners();
    }
  }

  /// Remove uma janela do gerenciador
  void unregisterWindow(String windowId) {
    _windowStack.remove(windowId);
    _taggedWindows.removeWhere((key, value) => value == windowId);
    notifyListeners();
  }

  /// Verifica se existe uma janela com a tag fornecida
  String? getWindowIdByTag(String tag) {
    return _taggedWindows[tag];
  }

  /// Traz uma janela para o topo (foco)
  void bringToFront(String windowId) {
    if (_windowStack.contains(windowId)) {
      _windowStack.remove(windowId);
      _windowStack.add(windowId);
      notifyListeners();
    }
  }

  /// Retorna o z-index de uma janela (maior = mais acima)
  int getZIndex(String windowId) {
    return _windowStack.indexOf(windowId);
  }

  /// Retorna se a janela está no topo
  bool isOnTop(String windowId) {
    return _windowStack.isNotEmpty && _windowStack.last == windowId;
  }

  /// Lista de todas as janelas ordenadas por z-index
  List<String> get windowStack => List.unmodifiable(_windowStack);
}

// ============================================================================
// CONFIGURAÇÕES
// ============================================================================

/// Configurações personalizáveis para o DraggableOverlayWindow
class DraggableWindowConfig {
  /// Altura da janela quando minimizada (apenas header)
  final double minimizedHeight;

  /// Raio das bordas arredondadas
  final double borderRadius;

  /// Elevação (sombra) da janela
  final double elevation;

  /// Elevação quando a janela está em foco
  final double focusedElevation;

  /// Cor de fundo do cabeçalho
  final Color? headerBackgroundColor;

  /// Cor de fundo da janela
  final Color? windowBackgroundColor;

  /// Cor da borda
  final Color? borderColor;

  /// Cor da borda quando em foco
  final Color? focusedBorderColor;

  /// Se deve habilitar rolagem automática no conteúdo
  final bool enableScrolling;

  /// Padding do conteúdo
  final EdgeInsets contentPadding;

  /// Se a janela pode ser redimensionada
  final bool resizable;

  /// Tamanho da área de arraste para redimensionar
  final double resizeHandleSize;

  /// Largura mínima da janela
  final double minWidth;

  /// Altura mínima da janela
  final double minHeight;

  /// Largura máxima da janela (null = sem limite)
  final double? maxWidth;

  /// Altura máxima da janela (null = sem limite)
  final double? maxHeight;

  /// Largura inicial da janela
  final double initialWidth;

  /// Altura inicial da janela
  final double initialHeight;

  /// Função para calcular a largura baseada na largura da tela (sobrescreve initialWidth)
  final double Function(double screenWidth)? widthCalculator;

  /// Função para calcular a altura baseada na altura da tela (sobrescreve initialHeight)
  final double Function(double screenHeight)? heightCalculator;

  /// Ícone do minimizar
  final IconData minimizeIcon;

  /// Ícone do maximizar/restaurar
  final IconData maximizeIcon;

  /// Ícone de fechar
  final IconData closeIcon;

  /// Ícone de arrastar
  final IconData dragHandleIcon;

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
  });

  /// Largura da borda
  final double borderWidth;

  /// Largura da borda quando em foco
  final double? focusedBorderWidth;

  /// Se deve mostrar a borda de foco
  final bool showFocusBorder;

  /// Altura (espessura) do divisor
  final double dividerHeight;

  /// Se deve mostrar o divisor
  final bool showDivider;

  /// Cor do divisor
  final Color? dividerColor;

  /// Padding do conteúdo do header
  final EdgeInsets? headerPadding;

  /// Cor dos ícones do header
  final Color? headerIconColor;

  /// Cor dos botões do header
  final Color? headerButtonsColor;

  /// Estilo do texto do header
  final TextStyle? headerTextStyle;

  /// Configuração padrão
  static const DraggableWindowConfig defaultConfig = DraggableWindowConfig();

  /// Configuração compacta para telas menores
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

  /// Cria uma cópia com valores alterados
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
    );
  }
}

// ============================================================================
// CONTROLLER
// ============================================================================
/// Controller para controlar o DraggableOverlayWindow programaticamente
class DraggableWindowController extends ChangeNotifier {
  static final Map<String, DraggableWindowController> _instances = {};

  bool _isVisible = false;
  bool _isMinimized = false;
  Offset _position = const Offset(80, 100);
  Size _size;
  final String _windowId;
  final String? _tag;

  /// Construtor Factory
  /// Se [tag] for fornecido e já existir uma instância, retorna a existente.
  factory DraggableWindowController({
    Size initialSize = const Size(400, 350),
    Offset initialPosition = const Offset(80, 100),
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
    Offset initialPosition = const Offset(80, 100),
    String? tag,
  })  : _size = initialSize,
        _position = initialPosition,
        _windowId = WindowManager().generateId(),
        _tag = tag;

  /// ID único da janela
  String get windowId => _windowId;

  /// Se a janela está visível
  bool get isVisible => _isVisible;

  /// Se a janela está minimizada
  bool get isMinimized => _isMinimized;

  /// Posição atual da janela
  Offset get position => _position;

  /// Tamanho atual da janela
  Size get size => _size;

  /// Se a janela está em foco (no topo)
  bool get isFocused => WindowManager().isOnTop(_windowId);

  /// Mostra a janela
  void show() {
    if (!_isVisible) {
      _isVisible = true;
      _isMinimized = false;
      WindowManager().registerWindow(_windowId, tag: _tag);
      WindowManager().bringToFront(_windowId);
      notifyListeners();
    }
  }

  /// Esconde a janela
  void hide() {
    if (_isVisible) {
      _isVisible = false;
      WindowManager().unregisterWindow(_windowId);
      notifyListeners();
    }
  }

  /// Alterna visibilidade
  void toggle() {
    if (_isVisible) {
      hide();
    } else {
      show();
    }
  }

  /// Minimiza a janela
  void minimize() {
    if (_isVisible && !_isMinimized) {
      _isMinimized = true;
      notifyListeners();
    }
  }

  /// Restaura a janela (maximiza)
  void restore() {
    if (_isVisible && _isMinimized) {
      _isMinimized = false;
      notifyListeners();
    }
  }

  /// Alterna estado minimizado
  void toggleMinimize() {
    if (_isVisible) {
      _isMinimized = !_isMinimized;
      notifyListeners();
    }
  }

  /// Traz a janela para o topo (foco)
  void bringToFront() {
    WindowManager().bringToFront(_windowId);
  }

  /// Define a posição da janela
  void setPosition(Offset newPosition) {
    if (_position != newPosition) {
      _position = newPosition;
      notifyListeners();
    }
  }

  /// Define o tamanho da janela
  void setSize(Size newSize) {
    if (_size != newSize) {
      _size = newSize;
      notifyListeners();
    }
  }

  /// Define posição e tamanho sem notificar (usado na inicialização)
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

/// Direção de redimensionamento
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
// WIDGET PRINCIPAL
// ============================================================================

/// Widget de janela flutuante arrastável e redimensionável
class DraggableOverlayWindow extends StatefulWidget {
  /// Controller para controle programático
  final DraggableWindowController controller;

  /// Título exibido no cabeçalho (opcional)
  final String? title;

  /// Ícone exibido no cabeçalho (opcional)
  final IconData? icon;

  /// Conteúdo da janela
  final Widget content;

  /// Configurações personalizadas
  final DraggableWindowConfig config;

  /// Callback quando a janela ganha foco
  final VoidCallback? onFocus;

  /// Callback quando a janela é fechada
  final VoidCallback? onClose;

  /// Callback quando a janela é minimizada
  final VoidCallback? onMinimized;

  /// Callback quando a janela é restaurada (maximizada)
  final VoidCallback? onRestored;

  /// Callback quando a posição muda
  final ValueChanged<Offset>? onPositionChanged;

  /// Callback quando o tamanho muda
  final ValueChanged<Size>? onSizeChanged;

  const DraggableOverlayWindow({
    required Key key,
    required this.controller,
    required this.content,
    this.title,
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
  final WindowManager _windowManager = WindowManager();

  DraggableWindowController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _initializeSize();
    _currentPosition = _controller.position;
    _controller.addListener(_onControllerChanged);
    _windowManager.addListener(_onWindowManagerChanged);

    // Registra a janela se visível
    if (_controller.isVisible) {
      _windowManager.registerWindow(_controller.windowId,
          tag: _controller._tag);
    }
  }

  void _initializeSize() {
    // Usa o tamanho do controller se já definido, senão usa o config
    if (_controller.size.width > 0 && _controller.size.height > 0) {
      _currentSize = _controller.size;
    } else {
      _currentSize = Size(
        widget.config.initialWidth,
        widget.config.initialHeight,
      );
      _controller.setInitialState(size: _currentSize);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _windowManager.removeListener(_onWindowManagerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    // Evita conflitos de atualização com o controller
    if (mounted) {
      setState(() {
        _currentPosition = _controller.position;
        _currentSize = _controller.size;
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

    // Posição e tamanho atuais
    double left = _currentPosition.dx;
    double top = _currentPosition.dy;
    double width = _currentSize.width;
    double height = _currentSize.height;

    // CORREÇÃO: Aplicar deltas de acordo com a direção
    switch (direction) {
      case _ResizeDirection.left:
      case _ResizeDirection.topLeft:
      case _ResizeDirection.bottomLeft:
        // Ao redimensionar pela esquerda, mover a borda esquerda
        left += dx;
        width -=
            dx; // Diminui largura ao mover para direita, aumenta ao mover para esquerda
        break;
      case _ResizeDirection.right:
      case _ResizeDirection.topRight:
      case _ResizeDirection.bottomRight:
        // Ao redimensionar pela direita, apenas aumentar largura
        width += dx;
        break;
      default:
        break;
    }

    switch (direction) {
      case _ResizeDirection.top:
      case _ResizeDirection.topLeft:
      case _ResizeDirection.topRight:
        // Ao redimensionar pelo topo, mover a borda superior
        top += dy;
        height -=
            dy; // Diminui altura ao mover para baixo, aumenta ao mover para cima
        break;
      case _ResizeDirection.bottom:
      case _ResizeDirection.bottomLeft:
      case _ResizeDirection.bottomRight:
        // Ao redimensionar por baixo, apenas aumentar altura
        height += dy;
        break;
      default:
        break;
    }

    // Aplicar limites de tamanho mínimo
    if (width < config.minWidth) {
      if (direction == _ResizeDirection.left ||
          direction == _ResizeDirection.topLeft ||
          direction == _ResizeDirection.bottomLeft) {
        // Se estamos redimensionando pela esquerda e atingimos o mínimo,
        // ajustar a posição left para manter o tamanho mínimo
        left = _currentPosition.dx + (_currentSize.width - config.minWidth);
      }
      width = config.minWidth;
    }

    if (height < config.minHeight) {
      if (direction == _ResizeDirection.top ||
          direction == _ResizeDirection.topLeft ||
          direction == _ResizeDirection.topRight) {
        // Se estamos redimensionando pelo topo e atingimos o mínimo,
        // ajustar a posição top para manter o tamanho mínimo
        top = _currentPosition.dy + (_currentSize.height - config.minHeight);
      }
      height = config.minHeight;
    }

    // Aplicar limites de tamanho máximo
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

    // Garantir que não saia da tela
    if (left < 0) {
      width += left; // Ajusta largura se a posição left for negativa
      left = 0;
    }
    if (top < 0) {
      height += top; // Ajusta altura se a posição top for negativa
      top = 0;
    }

    // Garantir que a borda direita não ultrapasse a tela
    if (left + width > screenSize.width) {
      if (direction == _ResizeDirection.left ||
          direction == _ResizeDirection.topLeft ||
          direction == _ResizeDirection.bottomLeft) {
        // Se estamos redimensionando pela esquerda, ajustar left
        left = screenSize.width - width;
        if (left < 0) {
          left = 0;
          width = screenSize.width;
        }
      } else {
        // Senão, ajustar width
        width = screenSize.width - left;
      }
    }

    // Garantir que a borda inferior não ultrapasse a tela
    if (top + height > screenSize.height) {
      if (direction == _ResizeDirection.top ||
          direction == _ResizeDirection.topLeft ||
          direction == _ResizeDirection.topRight) {
        // Se estamos redimensionando pelo topo, ajustar top
        top = screenSize.height - height;
        if (top < 0) {
          top = 0;
          height = screenSize.height;
        }
      } else {
        // Senão, ajustar height
        height = screenSize.height - top;
      }
    }

    // Atualizar estado
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

    final width = _calculateWidth(
      context,
    ).clamp(widget.config.minWidth, double.infinity);
    final isMinimized = _controller.isMinimized;
    final isFocused = _windowManager.isOnTop(_controller.windowId);
    // Quando minimizado, usar apenas a altura do header
    // Garantir que a altura nunca seja negativa
    final height = (isMinimized
            ? widget.config.minimizedHeight
            : _calculateHeight(context))
        .clamp(widget.config.minimizedHeight, double.infinity);

    final theme = Theme.of(context);
    final config = widget.config;
    final borderRadius = BorderRadius.circular(config.borderRadius);

    final backgroundColor =
        config.windowBackgroundColor ?? theme.scaffoldBackgroundColor;
    final borderColor = isFocused
        ? (config.focusedBorderColor ?? theme.colorScheme.primary)
        : (config.borderColor ?? Colors.grey.shade300);
    final elevation = isFocused ? config.focusedElevation : config.elevation;

    // Uso de Align + Transform evita erros de ParentData no Stack
    // e garante que a origem seja (0,0) para o offset funcionar corretamente
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
            child: AnimatedContainer(
              // Sem animação para evitar problemas de overflow
              duration: Duration.zero,
              curve: Curves.linear,
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
                border: Border.all(
                  color: borderColor,
                  // Se focusedBorderWidth não for definido, usa borderWidth
                  // Se showFocusBorder for false, usa borderWidth
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
                  // Conteúdo principal
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Quando minimizado, o header deve expandir para ocupar todo o espaço
                      if (isMinimized)
                        Expanded(
                          child: _buildHeader(
                            context,
                            isFocused,
                            expandHeight: true,
                          ),
                        )
                      else ...[
                        _buildHeader(context, isFocused, expandHeight: false),
                        if (config.showDivider)
                          Divider(
                            height: config.dividerHeight,
                            thickness: config.dividerHeight,
                            color: config.dividerColor ??
                                borderColor.withValues(alpha: 0.5),
                          ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(config.borderRadius),
                            ),
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
                      ],
                    ],
                  ),

                  // Resize handles (apenas se não estiver minimizado e resizable)
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
      // Bordas
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
      // Cantos
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
          // CORREÇÃO: Trazer ao topo mas NÃO chamar _handleDragStart
          // que causava conflito com o resize
          _controller.bringToFront();
          widget.onFocus?.call();
        },
        onPanEnd: (_) {},
        onPanCancel: () {},
        behavior: HitTestBehavior
            .opaque, // MUDANÇA CRÍTICA: de translucent para opaque
        // Isso impede que o gesto "vaze" para o GestureDetector pai
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
      onDoubleTap: () {
        if (_controller.isMinimized) {
          _controller.restore();
          widget.onRestored?.call();
        } else {
          _controller.minimize();
          widget.onMinimized?.call();
        }
      },
      child: Container(
        // Quando expandHeight é true, não definir altura fixa (deixa o Expanded controlar)
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

    return Row(
      children: [
        Icon(widget.config.dragHandleIcon, size: 14, color: iconColor),
        if (widget.icon != null) ...[
          const SizedBox(width: 6),
          Icon(widget.icon, size: 16, color: iconColor),
        ],
        if (widget.title != null) ...[
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.title!,
              style: widget.config.headerTextStyle ??
                  theme.textTheme.titleSmall?.copyWith(
                    fontSize: 13,
                    fontWeight: isFocused ? FontWeight.w600 : FontWeight.normal,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else
          const Spacer(),
        const SizedBox(width: 4),
        _buildHeaderButton(
          icon: widget.config.maximizeIcon,
          tooltip: 'Restaurar',
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
          tooltip: 'Fechar',
          onTap: () {
            _controller.hide();
            widget.onClose?.call();
          },
          isClose: true,
          color: null, // Fecha sempre tem cor propria ou usa padrao
          isFocused: isFocused,
        ),
      ],
    );
  }

  Widget _buildExpandedHeader(ThemeData theme, bool isFocused) {
    final defaultIconColor = isFocused ? theme.colorScheme.primary : null;
    final iconColor = widget.config.headerIconColor ?? defaultIconColor;
    // Para Expanded, usa a cor definida

    return Row(
      children: [
        Icon(widget.config.dragHandleIcon, size: 16, color: iconColor),
        if (widget.icon != null) ...[
          const SizedBox(width: 8),
          Icon(widget.icon, size: 20, color: iconColor),
        ],
        if (widget.title != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title!,
              style: widget.config.headerTextStyle ??
                  theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isFocused ? FontWeight.w600 : FontWeight.normal,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else
          const Spacer(),
        _buildHeaderIconButton(
          icon: widget.config.minimizeIcon,
          tooltip: 'Minimizar',
          onPressed: () {
            _controller.minimize();
            widget.onMinimized?.call();
          },
          color: widget.config.headerButtonsColor,
        ),
        _buildHeaderIconButton(
          icon: widget.config.closeIcon,
          tooltip: 'Fechar',
          onPressed: () {
            _controller.hide();
            widget.onClose?.call();
          },
          isClose: true,
        ),
      ],
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(2),
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
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 20,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      color: isClose ? Colors.red.shade400 : color,
      hoverColor: isClose ? Colors.red.shade50 : null,
    );
  }
}

// ============================================================================
// WIDGET CONTAINER (para gerenciar múltiplas janelas com z-index correto)
// ============================================================================

/// Container que gerencia múltiplas janelas com z-index automático
/// CORREÇÃO: Usa IndexedStack para manter as posições corretas
class OverlayWindowStack extends StatefulWidget {
  /// Lista de janelas a serem exibidas
  final List<DraggableOverlayWindow> windows;

  /// Conteúdo principal (abaixo das janelas)
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
    // CORREÇÃO: Não reordenar os widgets, apenas controlar a ordem visual
    // usando a ordem do windowStack para determinar qual está "acima"

    // Criar um mapa de windowId -> index no stack
    final stackOrder = <String, int>{};
    for (int i = 0; i < _windowManager.windowStack.length; i++) {
      stackOrder[_windowManager.windowStack[i]] = i;
    }

    // Ordenar as janelas pelo z-index MAS manteremos a mesma key
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
          // CORREÇÃO: As janelas devem ter keys atribuídas na criação
          ...sortedWindows,
        ],
      ),
    );
  }
}
