import 'package:draggable_overlay_window/draggable_overlay_window.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draggable Overlay Window Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class WindowItem {
  final String id;
  final DraggableWindowController controller;
  final Widget content;
  final DraggableWindowConfig config;
  final String title;
  final String? tag;

  WindowItem({
    required this.id,
    required this.controller,
    required this.content,
    required this.config,
    required this.title,
    this.tag,
  });
}

class _HomePageState extends State<HomePage> {
  final List<WindowItem> _windows = [];
  int _counter = 0;

  void _addWindow(
    String title,
    Widget content,
    DraggableWindowConfig config, {
    Size? initialSize,
    Offset? initialPosition,
    String? tag,
  }) {
    // Agora o controller gerencia a unicidade!
    final controller = DraggableWindowController(
      initialSize: initialSize ?? const Size(300, 200),
      initialPosition: initialPosition ?? const Offset(50, 50),
      tag: tag, // Passando a tag para o controller
    );

    // Se a janela já existe na lista do usuário, apenas reutiliza-la
    final existingIndex =
        _windows.indexWhere((w) => w.controller == controller);

    if (existingIndex != -1) {
      final existingWindow = _windows[existingIndex];
      existingWindow.controller.show();
      existingWindow.controller.bringToFront();
      if (existingWindow.controller.isMinimized) {
        existingWindow.controller.restore();
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'A janela "$title" já está aberta (gerenciado pelo Controller)!'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Se é uma nova janela, adiciona à lista
    setState(() {
      _counter++;
      _windows.add(WindowItem(
        id: 'win_$_counter',
        controller:
            controller, // Este pode ser um novo ou um existente que ainda nao estava na lista
        content: content,
        config: config,
        title: title,
        tag: tag,
      ));
      controller.show();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.bringToFront();
      });
    });
  }

  void _removeWindow(WindowItem item) {
    setState(() {
      _windows.remove(item);
      // Importante: Dispose agora remove a instância do cache global do plugin
      item.controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 50),
                Text(
                  'Teste de Janelas Flutuantes',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.window),
                      label: const Text('Padrão (Multi)'),
                      onPressed: () {
                        _addWindow(
                          'Simples',
                          const Center(
                            child: Text(
                              'Janela Padrão\nRedimensionável e Arrastável',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const DraggableWindowConfig(),
                          tag: null, // Múltiplas instâncias
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person),
                      label: const Text('Perfil (Único)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                      ),
                      onPressed: () {
                        _addWindow(
                          'Perfil do Usuário',
                          const UserProfileContent(),
                          DraggableWindowConfig(
                            headerBackgroundColor: Colors.blue.shade700,
                            headerIconColor: Colors.white,
                            enableScrolling: false,
                            headerTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          initialSize: const Size(350, 500),
                          tag: 'profile', // Único
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.sticky_note_2),
                      label: const Text('Nota (Multi)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade100,
                      ),
                      onPressed: () {
                        _addWindow(
                          'Lembrete',
                          Container(
                            color: Colors.yellow.shade50,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nota Rápida',
                                  style: TextStyle(
                                    fontFamily: 'cursive',
                                    fontSize: 24,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const Divider(),
                                const Text('Escreva algo...'),
                              ],
                            ),
                          ),
                          DraggableWindowConfig(
                            windowBackgroundColor: Colors.yellow.shade50,
                            headerBackgroundColor: Colors.yellow.shade700,
                            borderColor: Colors.yellow.shade900,
                            dividerColor: Colors.yellow.shade900,
                            borderRadius: 0,
                            elevation: 4,
                          ),
                          initialSize: const Size(200, 200),
                          tag: null, // Múltiplas
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.lock),
                      label: const Text('Aviso (Único)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                      ),
                      onPressed: () {
                        _addWindow(
                          'Aviso Importante',
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.warning,
                                      size: 40, color: Colors.orange),
                                  SizedBox(height: 10),
                                  Text(
                                    'Esta é uma janela de alerta fixa.\nNão pode ser redimensionada.',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DraggableWindowConfig(
                            resizable: false,
                            borderColor: Colors.red,
                            headerBackgroundColor: Colors.red,
                            headerIconColor: Colors.white,
                            headerTextStyle:
                                const TextStyle(color: Colors.white),
                          ),
                          initialSize: const Size(300, 200),
                          tag: 'alert', // Único
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.music_note),
                      label: const Text('Player (Único)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                      ),
                      onPressed: () {
                        _addWindow(
                          'Now Playing',
                          Container(
                            color: Colors.black,
                            child: Center(
                              child: Icon(Icons.play_circle_fill,
                                  size: 64,
                                  color: Colors.white.withValues(alpha: 0.8)),
                            ),
                          ),
                          const DraggableWindowConfig(
                            windowBackgroundColor: Colors.black,
                            headerBackgroundColor: Colors.black,
                            headerIconColor: Colors.white,
                            headerTextStyle: TextStyle(color: Colors.white),
                            borderColor: Colors.grey,
                            dividerColor: Colors.grey,
                          ),
                          initialSize: const Size(400, 225),
                          tag: 'player', // Único
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.code),
                      label: const Text('Calc (Único)'),
                      onPressed: () {
                        _addWindow(
                          'Meia Tela',
                          const Center(child: Text('50% da largura da tela')),
                          DraggableWindowConfig(
                            widthCalculator: (screenWidth) => screenWidth * 0.5,
                            heightCalculator: (screenHeight) => 200,
                          ),
                          initialPosition: const Offset(10, 300),
                          tag: 'calculator', // Único
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          ..._windows.map((window) {
            return DraggableOverlayWindow(
              key: ValueKey(window.id),
              controller: window.controller,
              config: window.config,
              title: window.title,
              onClose: () => _removeWindow(window),
              content: window.content,
            );
          }),
        ],
      ),
    );
  }
}

class UserProfileContent extends StatelessWidget {
  const UserProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 40,
          child: Icon(Icons.person, size: 40),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Nome',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          controller: TextEditingController(text: 'Usuário Exemplo'),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          controller: TextEditingController(text: 'email@exemplo.com'),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Notificações'),
          value: true,
          onChanged: (val) {},
        ),
        SwitchListTile(
          title: const Text('Modo Escuro'),
          value: false,
          onChanged: (val) {},
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Salvar'),
        ),
        const SizedBox(height: 200),
        const Center(child: Text("Final da lista")),
      ],
    );
  }
}
