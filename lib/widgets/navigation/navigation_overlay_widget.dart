import 'package:car_dashboard/services/navigation_service.dart';
import 'package:flutter/material.dart';

class NavigationOverlay extends StatelessWidget {
  final String destinationName;
  final String totalTime;
  final String totalDistance;
  final List<NavigationData> alternativeRoutes;
  final int selectedRouteIndex;
  final Function(int) onRouteSelected;
  final Function(String) onProfileChanged;
  final String currentProfile;
  final VoidCallback onCancel;

  const NavigationOverlay({
    super.key,
    required this.destinationName,
    required this.totalTime,
    required this.totalDistance,
    required this.alternativeRoutes,
    required this.selectedRouteIndex,
    required this.onRouteSelected,
    required this.onProfileChanged,
    required this.currentProfile,
    required this.onCancel,
  });

  String _formatDuration(double seconds) {
    final totalMinutes = seconds ~/ 60;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes} min';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 260,
          maxWidth: 280,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
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
              // Destination name
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  children: [
                    const Icon(Icons.place, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        destinationName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Top summary
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totalTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      totalDistance,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Colors.white24),

              // Alternative routes
              if (alternativeRoutes.length > 1)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alternative Routes',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (int i = 0; i < alternativeRoutes.length; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                  right:
                                      i < alternativeRoutes.length - 1 ? 8 : 0),
                              child: GestureDetector(
                                onTap: () => onRouteSelected(i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: selectedRouteIndex == i
                                        ? Colors.blueAccent
                                        : const Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selectedRouteIndex == i
                                          ? Colors.blueAccent
                                          : Colors.white24,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _formatDuration(
                                        alternativeRoutes[i].duration),
                                    style: TextStyle(
                                      color: selectedRouteIndex == i
                                          ? Colors.white
                                          : Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

              if (alternativeRoutes.length > 1)
                const Divider(height: 1, color: Colors.white24),

              // Transport mode buttons
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transport Mode',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildModeButton(
                          icon: Icons.traffic,
                          label: 'Traffic',
                          profile: 'driving-traffic',
                          isSelected: currentProfile == 'driving-traffic',
                          onTap: () => onProfileChanged('driving-traffic'),
                        ),
                        _buildModeButton(
                          icon: Icons.directions_car,
                          label: 'Driving',
                          profile: 'driving',
                          isSelected: currentProfile == 'driving',
                          onTap: () => onProfileChanged('driving'),
                        ),
                        _buildModeButton(
                          icon: Icons.directions_walk,
                          label: 'Walking',
                          profile: 'walking',
                          isSelected: currentProfile == 'walking',
                          onTap: () => onProfileChanged('walking'),
                        ),
                        _buildModeButton(
                          icon: Icons.directions_bike,
                          label: 'Cycling',
                          profile: 'cycling',
                          isSelected: currentProfile == 'cycling',
                          onTap: () => onProfileChanged('cycling'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Colors.white24),

              // Turn by turn placeholder
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                leading: const Icon(Icons.navigation,
                    color: Colors.white70, size: 18),
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

              // Cancel route button
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Cancel Route",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required String profile,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.white24,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
