import 'package:car_dashboard/controllers/camera_controller.dart';
import 'package:car_dashboard/layouts/car_view_layout/3d_model_layout.dart';
import 'package:car_dashboard/layouts/music_player_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:provider/provider.dart';

import 'layouts/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    throw Exception('Error loading .env file: $e');
  }
  await FullScreen.ensureInitialized();

  final isPi = dotenv.env['IS_PI'] == 'true';

  if (isPi) {
    FullScreen.setFullScreen(true);
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => CameraController(),
      child: const CarDashboardApp(),
    ),
  );
}

class CarDashboardApp extends StatelessWidget {
  const CarDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard Mockup',
      theme: ThemeData.dark(useMaterial3: true),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isMusicPlayerVisible = false;
  bool _isCarModelVisible = false;

  void _toggleMusicPlayer(bool isVisible) {
    setState(() {
      _isMusicPlayerVisible = isVisible;
      if (isVisible) _isCarModelVisible = false;
    });
  }

  void _toggleCarModel(bool isVisible) {
    setState(() {
      _isCarModelVisible = isVisible;
      if (isVisible) _isMusicPlayerVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: Container(
          width: 1280,
          height: 800,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF252525)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOutCubic,
                    width: _isMusicPlayerVisible ? 300 : 0,
                    child: _isMusicPlayerVisible
                        ? ClipRect(
                            child: OverflowBox(
                              alignment: Alignment.centerLeft,
                              minWidth: 300,
                              maxWidth: 300,
                              child: const SizedBox(
                                width: 300,
                                child: MusicPlayerLayout(),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Keep the car model in the tree but control visibility with Offstage
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOutCubic,
                    width: _isCarModelVisible ? (1280 / 3) : 0,
                    child: Offstage(
                      offstage: !_isCarModelVisible,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: screenWidth / 3,
                            child: ModelLayout(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Main content area
                  Expanded(
                    child: Stack(
                      children: [
                        MainLayout(
                          onCarButtonToggle: _toggleCarModel,
                          isCarModelVisible: _isCarModelVisible,
                          onMusicButtonToggle: _toggleMusicPlayer,
                          isMusicPlayerVisible: _isMusicPlayerVisible,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
