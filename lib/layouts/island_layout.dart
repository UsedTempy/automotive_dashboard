import 'package:car_dashboard/providers/update_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';

class IslandLayout extends StatefulWidget {
  const IslandLayout({super.key});

  @override
  State<IslandLayout> createState() => _IslandLayoutState();
}

class _IslandLayoutState extends State<IslandLayout> {
  late String currentTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();

    setState(() {
      currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final updateProvider = context.watch<UpdateProvider>();

    return Positioned(
      top: 15,
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
        child: Row(
          children: [
            Text(
              currentTime,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE0E0E0),
              ),
            ),
            if (updateProvider.isUpdateAvailable && !updateProvider.isChecking)
              IconButton(
                onPressed: () {
                  // TODO: Add logic to download or navigate to update page
                },
                icon: const Icon(
                  Symbols.download,
                  size: 22,
                  color: Colors.amber,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
