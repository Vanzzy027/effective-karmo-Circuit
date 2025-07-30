// lib/widgets/bulb_slider_card.dart

import 'package:flutter/material.dart';

class BulbSliderCard extends StatelessWidget {
  final int bulbId;
  final int brightness;
  final ValueChanged<int> onBrightnessChanged;

  const BulbSliderCard({
    super.key,
    required this.bulbId,
    required this.brightness,
    required this.onBrightnessChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(25),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lightbulb, size: 60, color: Colors.amber),
              const SizedBox(height: 10),
              Text(
                'Bulb $bulbId Brightness',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Slider(
                value: brightness.toDouble(),
                min: 0,
                max: 255,
                divisions: 255,
                label: '$brightness',
                onChanged: (double value) =>
                    onBrightnessChanged(value.round()),
              ),
              const SizedBox(height: 5),
              Text(
                '$brightness / 255',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
