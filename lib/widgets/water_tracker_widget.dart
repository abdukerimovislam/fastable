import 'package:flutter/material.dart';

class WaterTrackerWidget extends StatelessWidget {
  final String title;
  final String unit;
  final int currentIntake;
  final int goalIntake;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const WaterTrackerWidget({
    super.key,
    required this.title,
    required this.unit,
    required this.currentIntake,
    required this.goalIntake,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the fill percentage
    final double fillPercent = (currentIntake / goalIntake).clamp(0.0, 1.0);

    // --- THIS IS THE FIX ---
    // Increased height from 160 to 180 to prevent overflow
    const double cardHeight = 180.0;
    // --- END OF FIX ---

    return Card(
      color: Colors.grey.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // Important for the animation
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // --- The Animated Fill ---
          // This container sits at the bottom and grows in height
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            height: fillPercent * cardHeight, // Use the new height
            width: double.infinity,
            color: Colors.blue.withValues(alpha: 0.5),
          ),

          // --- The Content ---
          Container(
            height: cardHeight, // Use the new height
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.water_drop, color: Colors.blueAccent),
                  ],
                ),

                // Middle: The Count
                Text(
                  "$currentIntake",
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // Bottom Row: Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$currentIntake / $goalIntake $unit",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Row(
                      children: [
                        // Remove Button
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: OutlinedButton(
                            onPressed: onRemove,
                            style: OutlinedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                              side: BorderSide(color: Colors.grey.shade600),
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Add Button
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: onAdd,
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.blueAccent,
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
