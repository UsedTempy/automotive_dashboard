import 'package:flutter/material.dart';

class NavigationOverlay extends StatelessWidget {
  final String totalTime;
  final String totalDistance;
  final VoidCallback onCancel;

  const NavigationOverlay({
    super.key,
    required this.totalTime,
    required this.totalDistance,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(12.0), // 🔹 less padding around card
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300), // 🔹 narrower card
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12), // 🔹 smaller rounding
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Top summary (time + distance) ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 14), // 🔹 less padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16, // 🔹 smaller font
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        totalDistance,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14, // 🔹 smaller font
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.white24),

                // --- Turn by turn (placeholder for now) ---
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  leading: const Icon(Icons.navigation,
                      color: Colors.white70, size: 18), // 🔹 smaller icon
                  title: const Text(
                    "Turn right onto Example Street",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  subtitle: const Text(
                    "In 200 m",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),

                const Divider(height: 1, color: Colors.white24),

                // --- Cancel route button ---
                Padding(
                  padding: const EdgeInsets.all(12.0), // 🔹 less spacing
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(vertical: 8), // 🔹 slimmer
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "Cancel Route",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13, // 🔹 smaller text
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
