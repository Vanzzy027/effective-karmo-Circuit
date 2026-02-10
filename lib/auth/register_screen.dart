import 'package:flutter/material.dart';
import '../utils/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'All parameters are required for hub setup.';
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await AuthService.registerUser(username, password).timeout(
        const Duration(seconds: 8),
        onTimeout: () => 'Network timeout. Check hub connectivity.',
      );

      if (result != null) {
        setState(() {
          _errorMessage = result;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        _showSuccessAndRedirect();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'System error during registry. Try again.';
        _isLoading = false;
      });
    }
  }

  void _showSuccessAndRedirect() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Node Registered Successfully", style: TextStyle(fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121416) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final accentColor = const Color(0xFF1E3C72);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // 1. Brand Anchor (Increased size and weight for visibility)
                _buildRegistryHeader(accentColor, isDark),
                const SizedBox(height: 40),

                // 2. Provisioning Console
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label with higher weight
                      Center(
                        child: Text(
                          "HUB INITIALIZATION",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 14, // Increased from 10
                            letterSpacing: 2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildInputField(
                        isDark: isDark,
                        controller: _usernameController,
                        label: 'Desired Username',
                        icon: Icons.person_add_alt_1_rounded,
                      ),

                      const SizedBox(height: 20),

                      _buildInputField(
                        isDark: isDark,
                        controller: _passwordController,
                        label: 'Secure Access Password',
                        icon: Icons.lock_reset_rounded,
                        obscure: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 24, // Bigger Icon
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),

                      if (_errorMessage.isNotEmpty) _buildErrorDisplay(),

                      const SizedBox(height: 35),

                      _buildSubmitButton(accentColor),

                      const SizedBox(height: 25),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                          },
                          child: Text(
                            'RETURN TO LOGIN SCREEN',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 14, // Increased
                              fontWeight: FontWeight.w900, // Thicker
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Utilized Space: Legible Technical Footer
                _buildSecurityInsight(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI SUB-COMPONENTS =================

  Widget _buildRegistryHeader(Color accentColor, bool isDark) {
    return Column(
      children: [
        Icon(Icons.add_moderator_rounded, color: accentColor, size: 60),
        const SizedBox(height: 15),
        Text(
          'INITIALIZE HUB',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 32, // Large and Bold
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Register your workspace to the Karmo network',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 15, // Highly legible
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required bool isDark,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 18, // Bigger typing text
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white60 : Colors.black54,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: isDark ? Colors.white70 : const Color(0xFF1E3C72), size: 24),
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF1E3C72), width: 2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Color accentColor) {
    return Container(
      width: double.infinity,
      height: 64, // Taller button for easier tapping
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.85)]),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: _isLoading
            ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : const Text(
          'INITIALIZE ACCESS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSecurityInsight(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.security_rounded, color: Colors.blueAccent, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "Local storage encryption active. Karmo ensures your node data remains private.",
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}