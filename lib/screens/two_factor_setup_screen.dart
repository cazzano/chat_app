import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'backup_codes_screen.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  final String username;
  
  const TwoFactorSetupScreen({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  _TwoFactorSetupScreenState createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen>
    with TickerProviderStateMixin {
  late String _secretKey;
  late String _qrData;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _generateSecretKey();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _animationController.forward();
  }

  void _generateSecretKey() {
    // Generate random 32-character base32 secret key
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = Random();
    _secretKey = List.generate(32, (index) => chars[random.nextInt(chars.length)]).join();
    
    // Create QR data in TOTP format for Google Authenticator
    _qrData = 'otpauth://totp/ChatApp:${widget.username}?secret=$_secretKey&issuer=ChatApp';
  }

  void _copySecretKey() {
    Clipboard.setData(ClipboardData(text: _secretKey));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Secret key copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _proceedToBackupCodes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BackupCodesScreen(username: widget.username),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Two-Factor Auth'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Header Icon
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.security,
                        size: 40,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    'Secure Your Account',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    'Scan this QR code with Google Authenticator',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // QR Code Container
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          // QR Code Placeholder
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                // QR Code Pattern Simulation
                                Center(
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: CustomPaint(
                                      painter: QRPatternPainter(),
                                    ),
                                  ),
                                ),
                                // QR Icon Overlay
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.qr_code,
                                      color: theme.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // App Name
                          Text(
                            'ChatApp',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          Text(
                            widget.username,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Secret Key Section
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.key,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Secret Key',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: SelectableText(
                              _secretKey,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _copySecretKey,
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('Copy Secret Key'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Instructions
                  Card(
                    color: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'How to setup:',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInstructionStep('1', 'Download Google Authenticator'),
                          _buildInstructionStep('2', 'Tap "+" to add account'),
                          _buildInstructionStep('3', 'Scan QR code or enter secret key'),
                          _buildInstructionStep('4', 'Verify 6-digit code'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _proceedToBackupCodes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Next: Generate Backup Codes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Skip Button
                  TextButton(
                    onPressed: _proceedToBackupCodes,
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for QR Code Pattern
class QRPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent pattern
    final blockSize = size.width / 20;

    // Create random QR-like pattern
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        if (random.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(i * blockSize, j * blockSize, blockSize, blockSize),
            paint,
          );
        }
      }
    }

    // Draw corner squares (typical QR code markers)
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = blockSize;

    // Top-left corner
    canvas.drawRect(Rect.fromLTWH(0, 0, blockSize * 3, blockSize * 3), cornerPaint);
    // Top-right corner
    canvas.drawRect(Rect.fromLTWH(size.width - blockSize * 3, 0, blockSize * 3, blockSize * 3), cornerPaint);
    // Bottom-left corner
    canvas.drawRect(Rect.fromLTWH(0, size.height - blockSize * 3, blockSize * 3, blockSize * 3), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
