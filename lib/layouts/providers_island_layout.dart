import 'package:flutter/material.dart';

class ProvidersIslandLayout extends StatefulWidget {
  const ProvidersIslandLayout({super.key});

  @override
  State<ProvidersIslandLayout> createState() => _ProvidersIslandLayoutState();
}

class _ProvidersIslandLayoutState extends State<ProvidersIslandLayout> {
  late String currentTime;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 15,
      right: 15,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Icon(Icons.wifi_off)),
    );
  }
}
