// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../utils/auth_service.dart';
// import '../auth/login_screen.dart';
// import '../providers/theme_provider.dart';
//
// class ProfileScreen extends StatelessWidget {
//   final String username;
//   const ProfileScreen({super.key, required this.username});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDarkMode = themeProvider.isDarkMode;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("My Profile")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: CircleAvatar(
//                 radius: 40,
//                 backgroundColor: theme.colorScheme.primary,
//                 child: Text(
//                   username[0].toUpperCase(),
//                   style: const TextStyle(fontSize: 30, color: Colors.white),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Center(
//               child: Text(
//                 username,
//                 style: theme.textTheme.headlineSmall,
//               ),
//             ),
//             const SizedBox(height: 40),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Dark Mode"),
//                 Switch(
//                   value: isDarkMode,
//                   onChanged: (value) {
//                     themeProvider.toggleTheme(value);
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Center(
//               child: ElevatedButton.icon(
//                 onPressed: () async {
//                   await AuthService().logout(context);
//                   if (!context.mounted) return;
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const LoginScreen()),
//                         (route) => false,
//                   );
//                 },
//                 icon: const Icon(Icons.logout),
//                 label: const Text("Logout"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: theme.colorScheme.error,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
