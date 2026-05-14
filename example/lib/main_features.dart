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
      title: 'Draggable Overlay Window Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo, brightness: Brightness.light),
        useMaterial3: true,
      ),
      // Wrap the app with WindowManagerScope to provide global window management
      home: const WindowManagerScope(
        child: DemoPage(),
      ),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the window manager controller from the context
    final windows = WindowManagerScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WindowManagerScope Demo'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_fullscreen),
            tooltip: 'Close All',
            onPressed: () => windows.closeAll(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade100, Colors.grey.shade300],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.layers_outlined,
                    size: 64, color: Colors.indigo),
                const SizedBox(height: 16),
                const Text(
                  'Draggable Overlay Window v2.3',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore the new WindowManagerScope API',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildMenuButton(
                      label: 'Italian Tooltips',
                      icon: Icons.language,
                      color: Colors.green,
                      onPressed: () => windows.open(
                        id: 'italian_window',
                        title: 'Italian Window',
                        content: const Center(
                            child: Text(
                                'Hover over buttons to see Italian tooltips')),
                        config: const DraggableWindowConfig(
                          language: WindowLanguage.it,
                          headerBackgroundColor: Color(0xFFE8F5E9),
                        ),
                      ),
                    ),
                    _buildMenuButton(
                      label: 'No Minimize',
                      icon: Icons.remove_circle_outline,
                      color: Colors.orange,
                      onPressed: () => windows.open(
                        id: 'no_minimize',
                        title: 'No Minimize Button',
                        content: const Center(
                            child: Text(
                                'Minimize button is hidden in this window')),
                        config: const DraggableWindowConfig(
                          showMinimizeButton: false,
                          headerBackgroundColor: Color(0xFFFFF3E0),
                        ),
                      ),
                    ),
                    _buildMenuButton(
                      label: 'No Drag Icon',
                      icon: Icons.drag_indicator,
                      color: Colors.blueGrey,
                      onPressed: () => windows.open(
                        id: 'no_drag_icon',
                        title: 'No Drag Handle',
                        content: const Center(
                            child: Text('The drag handle icon is hidden')),
                        config: const DraggableWindowConfig(
                          showDragHandle: false,
                          headerBackgroundColor: Color(0xFFECEFF1),
                        ),
                      ),
                    ),
                    _buildMenuButton(
                      label: 'Widget Title',
                      icon: Icons.widgets,
                      color: Colors.purple,
                      onPressed: () => windows.open(
                        id: 'widget_title',
                        titleWidget: Row(
                          children: [
                            const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.purple,
                              child: Icon(Icons.star,
                                  size: 12, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            const Text('Rich Widget Title',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('PRO',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        content: const Center(
                            child: Text(
                                'This window uses a custom Widget as its title')),
                        config: const DraggableWindowConfig(
                          headerBackgroundColor: Color(0xFFF3E5F5),
                        ),
                      ),
                    ),
                    _buildMenuButton(
                      label: 'Header Extras',
                      icon: Icons.add_moderator,
                      color: Colors.blue,
                      onPressed: () => windows.open(
                        id: 'header_extras',
                        title: 'Extra Header Widgets',
                        headerLeading: const Icon(Icons.verified,
                            size: 16, color: Colors.blue),
                        headerActions: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 16),
                              onPressed: () {},
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 8),
                            const Text('Live',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                            ),
                          ],
                        ),
                        content: const Center(
                            child: Text(
                                'Custom widgets added near drag handle and before buttons')),
                        config: const DraggableWindowConfig(
                          headerBackgroundColor: Color(0xFFE3F2FD),
                        ),
                      ),
                    ),
                    _buildMenuButton(
                      label: 'All Features',
                      icon: Icons.auto_awesome,
                      color: Colors.red,
                      onPressed: () => windows.open(
                        id: 'ultimate_window',
                        titleWidget: const Text('The Ultimate Window',
                            style: TextStyle(fontStyle: FontStyle.italic)),
                        headerLeading: const Icon(Icons.rocket_launch,
                            size: 16, color: Colors.deepOrange),
                        headerActions: const Badge(
                            label: Text('3'),
                            child: Icon(Icons.notifications_none, size: 18)),
                        content: const DemoContent(),
                        config: const DraggableWindowConfig(
                          showHeader: false,
                          language: WindowLanguage.es, // Spanish
                          showMinimizeButton: true,
                          showDragHandle: true,
                          borderRadius: 16,
                          headerBackgroundColor: Color(0xFFFFEBEE),
                          centerInitialPosition: false,
                        ),
                        initialSize: const Size(400, 450),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 160,
      height: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.all(12),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class DemoContent extends StatelessWidget {
  const DemoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(
          'https://picsum.photos/seed/flutter/400/200',
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 150,
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            height: 150,
            color: Colors.grey.shade200,
            child: const Icon(Icons.image_not_supported,
                size: 48, color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Customization Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'WindowManagerScope handles window lifecycles automatically. No more manual lists!',
              ),
              const SizedBox(height: 16),
              const ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Easy open/close by ID'),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              const ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Automatic uniqueness management'),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              const ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Global control from any context'),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      WindowManagerScope.of(context).close('ultimate_window'),
                  child: const Text('Close this window via controller'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
