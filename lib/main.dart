import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:ffi' as ffi;


typedef GoFunction = ffi.Void Function();
typedef DartFunction = void Function();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Window Manager
  await windowManager.ensureInitialized();
  await SystemTheme.accentColor.load();

  // Configure the native window properties
  WindowOptions windowOptions = const WindowOptions(
    size: Size(420, 160),        // Your widget size
    center: true,                // Center on screen
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setResizable(false); 
    await windowManager.setMaximizable(false);  
    await windowManager.setMinimizable(false);
  });

  runApp(const MicrosoftCopyApp());
}

class MicrosoftCopyApp extends StatelessWidget {
  const MicrosoftCopyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AccentColor systemAccent = SystemTheme.accentColor.accent.toAccentColor();

    return FluentApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: systemAccent,
        scaffoldBackgroundColor: const Color(0xFF1c1c1c),
      ),
      home: const FileActionDialog(),
    );
  }
}

class FileActionDialog extends StatelessWidget {
  const FileActionDialog({super.key});

 Future<void> _triggerGo(String methodName) async {
  final dylib = ffi.DynamicLibrary.open('fact_logic.dll');

  final DartFunction goAction = dylib
      .lookup<ffi.NativeFunction<GoFunction>>(methodName)
      .asFunction();

  goAction();
}

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: GestureDetector(
      onDoubleTap: () {}, 
      child: ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Container(
          width: 420,
          height: 160,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2c2c2c),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Copy latest save file',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select an action below.',
                style: TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button(
                    onPressed: () => _triggerGo('CopyToClipboard'),
                    child: const Text('Copy to Clipboard'),
                  ),
                  const SizedBox(width: 8),
                  Button(
                    onPressed: () => _triggerGo('CopyToDesktop'),
                    child: const Text('Copy To Desktop'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => windowManager.close(),
                    child: const Text('Close'),
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
}