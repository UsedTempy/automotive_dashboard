import 'package:car_dashboard/providers/update_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class AppUpdaterWidget extends StatelessWidget {
  const AppUpdaterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final updateProvider = context.watch<UpdateProvider>();

    return IconButton(
      onPressed: () async {
        await updateProvider.checkForUpdate();
        await updateProvider.fetchReleases();
      },
      icon: Stack(
        children: [
          Icon(Symbols.update, size: 20),
          if (updateProvider.isUpdateAvailable)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
