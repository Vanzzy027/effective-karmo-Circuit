// import 'package:flutter/material.dart';
//
// class BulbSliderCard extends StatefulWidget {
//   final int bulbId;
//   final int brightness;
//   final ValueChanged<int> onBrightnessChanged;
//
//   const BulbSliderCard({
//     super.key,
//     required this.bulbId,
//     required this.brightness,
//     required this.onBrightnessChanged,
//   });
//
//   @override
//   State<BulbSliderCard> createState() => _BulbSliderCardState();
// }
//
// class _BulbSliderCardState extends State<BulbSliderCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//   late double _animatedBrightness;
//
//   @override
//   void initState() {
//     super.initState();
//     _animatedBrightness = widget.brightness.toDouble();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _animation = Tween<double>(
//       begin: _animatedBrightness,
//       end: widget.brightness.toDouble(),
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//     _animationController.forward();
//   }
//
//   @override
//   void didUpdateWidget(covariant BulbSliderCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.brightness != widget.brightness) {
//       _animation = Tween<double>(
//         begin: _animatedBrightness,
//         end: widget.brightness.toDouble(),
//       ).animate(CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeInOut,
//       ));
//       _animationController
//         ..reset()
//         ..forward();
//       _animatedBrightness = widget.brightness.toDouble();
//     }
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black87;
//
//     return Center(
//       child: Card(
//         color: isDark ? Colors.grey[900] : Colors.white,
//         margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//         elevation: 8,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           width: double.infinity,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.lightbulb,
//                 size: 48,
//                 color: widget.brightness > 0 ? Colors.amber : Colors.grey,
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Bulb ${widget.bulbId} Brightness',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: textColor,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               AnimatedBuilder(
//                 animation: _animation,
//                 builder: (context, child) {
//                   return Slider(
//                     value: _animation.value,
//                     min: 0,
//                     max: 255,
//                     divisions: 255,
//                     label: '${_animation.value.round()}',
//                     onChanged: (value) {
//                       widget.onBrightnessChanged(value.round());
//                     },
//                   );
//                 },
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 '${widget.brightness} / 255',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: isDark ? Colors.grey[300] : Colors.grey[700],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }