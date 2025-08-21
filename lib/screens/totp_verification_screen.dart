import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'backup_codes_screen.dart';

class TOTPVerificationScreen extends StatefulWidget {
  final String username;
  final String secretKey;

  const TOTPVerificationScreen({
    Key? key,
    required this.username,
    required this.secretKey,
  }) : super(key: key);

  @override
  _TOTPVerificationScreenState createState() => _TOTPVerificationScreenState();
}

class _TOTPVerificationScreenState extends State<TOTPVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  late AnimationController _animationController;
  late AnimationController _timerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;
  
  bool _isLoading = false;
  bool _isVerified = false;
  String _errorMessage = '';
  int _timeRemaining = 30;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimer();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _shakeAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );
    
    _animationController.forward();
  }

  void _startTimer() {
    _updateTimeRemaining();
    _timerAnimationController.forward();
  }

  void _updateTimeRemaining() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remaining = 30 - (now % 30);
    
    setState(() {
      _timeRemaining = remaining;
    });

    if (remaining == 30) {
      _timerAnimationController.reset();
      _timerAnimationController.forward();
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _updateTimeRemaining();
      }
    });
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyCode();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    setState(() {
      _errorMessage = '';
    });
  }

  String _getCurrentCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _clearCode() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {
      _errorMessage = '';
    });
  }

  Future<void> _verifyCode() async {
    final enteredCode = _getCurrentCode();
    if (enteredCode.length != 6) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Generate TOTP codes for current and previous time windows
      final currentCode = _generateTOTP(widget.secretKey);
      final previousCode = _generateTOTP(widget.secretKey, timeStep: -1);
      final nextCode = _generateTOTP(widget.secretKey, timeStep: 1);
      
      await Future.delayed(const Duration(milliseconds: 500)); // UI feedback

      if (enteredCode == currentCode || enteredCode == previousCode || enteredCode == nextCode) {
        setState(() {
          _isLoading = false;
          _isVerified = true;
        });
        
        _showSuccessDialog();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid code. Please check your authenticator app.';
        });
        
        _performShakeAnimation();
        _clearCode();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error verifying code. Please try again.';
      });
      
      _performShakeAnimation();
      _clearCode();
    }
  }

  void _performShakeAnimation() async {
    _animationController.reset();
    for (int i = 0; i < 3; i++) {
      await _animationController.forward();
      await _animationController.reverse();
    }
  }

  String _generateTOTP(String secretKey, {int timeStep = 0}) {
    try {
      // Convert base32 secret to bytes
      final secretBytes = _base32Decode(secretKey);
      
      // Calculate time step (30-second intervals)
      final timeStepValue = (DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ 30) + timeStep;
      
      // Convert time step to 8-byte big-endian array
      final timeBytes = ByteData(8);
      timeBytes.setUint64(0, timeStepValue);
      
      // Generate HMAC-SHA1
      final hmacSha1 = Hmac(sha1, secretBytes);
      final digest = hmacSha1.convert(timeBytes.buffer.asUint8List());
      final hmacBytes = digest.bytes;
      
      // Dynamic truncation
      final offset = hmacBytes[hmacBytes.length - 1] & 0x0F;
      final truncated = ((hmacBytes[offset] & 0x7F) << 24) |
                       ((hmacBytes[offset + 1] & 0xFF) << 16) |
                       ((hmacBytes[offset + 2] & 0xFF) << 8) |
                       (hmacBytes[offset + 3] & 0xFF);
      
      // Generate 6-digit code
      final code = truncated % 1000000;
      return code.toString().padLeft(6, '0');
    } catch (e) {
      print('Error generating TOTP: $e');
      return '000000';
    }
  }

  Uint8List _base32Decode(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final cleanInput = input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
    
    if (cleanInput.isEmpty) return Uint8List(0);
    
    final bytes = <int>[];
    int buffer = 0;
    int bits = 0;
    
    for (int i = 0; i < cleanInput.length; i++) {
      final char = cleanInput[i];
      final value = alphabet.indexOf(char);
      if (value == -1) continue;
      
      buffer = (buffer << 5) | value;
      bits += 5;
      
      if (bits >= 8) {
        bytes.add((buffer >> (bits - 8)) & 0xFF);
        bits -= 8;
      }
    }
    
    return Uint8List.fromList(bytes);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verification Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Two-factor authentication has been set up successfully for your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BackupCodesScreen(
                          username: widget.username,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Continue to Backup Codes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timerAnimationController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Authenticator Code'),
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
                  const SizedBox(height: 40),
                  
                  // Header Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isVerified 
                          ? Colors.green.withOpacity(0.1) 
                          : theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      _isVerified ? Icons.check_circle : Icons.smartphone,
                      size: 40,
                      color: _isVerified ? Colors.green : theme.primaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    'Enter Verification Code',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    'Enter the 6-digit code from\nGoogle Authenticator app',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Timer Progress
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _timeRemaining <= 10 
                          ? Colors.red.withOpacity(0.1) 
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer,
                              size: 20,
                              color: _timeRemaining <= 10 ? Colors.red : theme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Code expires in $_timeRemaining seconds',
                              style: TextStyle(
                                color: _timeRemaining <= 10 ? Colors.red : theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AnimatedBuilder(
                          animation: _timerAnimationController,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: _timeRemaining / 30.0,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _timeRemaining <= 10 ? Colors.red : theme.primaryColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Code Input Fields
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return Container(
                              width: 45,
                              height: 55,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _errorMessage.isNotEmpty 
                                      ? Colors.red 
                                      : _controllers[index].text.isNotEmpty 
                                          ? theme.primaryColor 
                                          : Colors.grey[300]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: _controllers[index].text.isNotEmpty
                                    ? [
                                        BoxShadow(
                                          color: theme.primaryColor.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _errorMessage.isNotEmpty ? Colors.red : theme.primaryColor,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) => _onDigitChanged(index, value),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading || _getCurrentCode().length != 6 ? null : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Verify Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Clear Code Button
                  TextButton.icon(
                    onPressed: _clearCode,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Clear Code'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Help Section
                  Card(
                    color: Colors.orange[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.help_outline,
                                color: Colors.orange[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Having trouble?',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '• Make sure you scanned the correct QR code\n'
                            '• Check that your device time is correct\n'
                            '• Try waiting for a new code (30 seconds)\n'
                            '• Ensure Google Authenticator is up to date',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
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
}
