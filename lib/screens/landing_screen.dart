import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import 'dashboard_screen.dart';

// Updated landing page - v2.0 - Chat app style

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  // Facebook-style colors from chat app
  static const Color fbBlue = Color(0xFF1877F2);
  static const Color fbDark = Color(0xFF18191A);
  static const Color fbCard = Color(0xFF242526);
  static const Color fbBorder = Color(0xFF3A3B3C);
  static const Color fbText = Color(0xFFE4E6EB);
  static const Color fbGray = Color(0xFFB0B3B8);

  String _mode = 'login';
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  String _statusMessage = '';
  Color _statusColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fbDark,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo area - similar to chat app
              _buildLogoSection(),
              
              const SizedBox(height: 20),
              
              // Card with login/register form
              _buildCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Wallet icon instead of chat icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: fbBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            size: 40,
            color: fbBlue,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // App name
        Text(
          'ExpenseTracker',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: fbBlue,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Tagline
        Text(
          'Track expenses and achieve financial freedom',
          style: TextStyle(
            fontSize: 13,
            color: fbGray,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: fbCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fbBorder),
      ),
      child: Column(
        children: [
          // Tabs for Login/Register
          _buildTabs(),
          
          // Form fields
          _buildFormFields(),
          
          // Status message
          if (_statusMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color: _statusColor,
                  fontSize: 12,
                ),
              ),
            ),
          
          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: Row(
        children: [
          // Login tab
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: _mode == 'login' ? fbBlue : fbBorder,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => _switchMode('login'),
                  child: Center(
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Register tab
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: _mode == 'register' ? fbBlue : fbBorder,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => _switchMode('register'),
                  child: Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username field
          Text(
            'Username',
            style: TextStyle(
              color: fbGray,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: _usernameController,
            style: TextStyle(
              color: fbText,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Username',
              hintStyle: TextStyle(
                color: fbGray.withOpacity(0.6),
              ),
              filled: true,
              fillColor: const Color(0xFF3A3B3C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: fbBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: fbBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: fbBlue),
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Password field
          Text(
            'Password',
            style: TextStyle(
              color: fbGray,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  style: TextStyle(
                    color: fbText,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(
                      color: fbGray.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF3A3B3C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: fbBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: fbBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: fbBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3B3C),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: fbBorder),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => setState(() => _showPassword = !_showPassword),
                    child: Center(
                      child: Text(
                        _showPassword ? '👁' : '👁‍🗨',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: fbBlue,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: _handleSubmit,
            child: Center(
              child: Text(
                _mode == 'login' ? 'Log In' : 'Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _switchMode(String mode) {
    setState(() {
      _mode = mode;
      _statusMessage = '';
      _statusColor = Colors.transparent;
    });
  }

  void _handleSubmit() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _statusMessage = '⚠ Please fill in all fields';
        _statusColor = const Color(0xFFFFA500);
      });
      return;
    }

    // Simulate login/register success
    setState(() {
      _statusMessage = '✓ Success!';
      _statusColor = const Color(0xFF42B883);
    });

    // Navigate to dashboard after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    });
  }
}
