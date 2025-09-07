// backup_codes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'auth_screen.dart';

class BackupCodesScreen extends StatefulWidget {
  final String username;
  
  const BackupCodesScreen({Key? key, required this.username}) : super(key: key);

  @override
  _BackupCodesScreenState createState() => _BackupCodesScreenState();
}

class _BackupCodesScreenState extends State<BackupCodesScreen> with SingleTickerProviderStateMixin {
  late List<String> _backupCodes;
  late AnimationController _controller;
  bool _codesVisible = true;
  bool _isCompleting = false;
  
  @override
  void initState() {
    super.initState();
    _generateBackupCodes();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  void _generateBackupCodes() {
    final random = Random();
    _backupCodes = List.generate(8, (_) => 
      List.generate(8, (_) => random.nextInt(10)).join()
    );
  }

  void _copyAllCodes() {
    Clipboard.setData(ClipboardData(text: _backupCodes.join('\n')));
    _showSnackBar('All backup codes copied');
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    _showSnackBar('Code $code copied');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _toggleVisibility() => setState(() => _codesVisible = !_codesVisible);

  void _completeSetup() async {
    setState(() => _isCompleting = true);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('2FA setup completed successfully! Please login with your new account.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // Add a small delay to show the loading state
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate back to login screen
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Codes'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button since this is part of signup flow
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
            opacity: _controller,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 24),
                  _buildWarningCard(theme),
                  const SizedBox(height: 24),
                  _buildCodesCard(theme),
                  const SizedBox(height: 24),
                  _buildCompleteButton(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(Icons.backup, size: 40, color: Colors.green),
        ),
        const SizedBox(height: 16),
        Text(
          'Save Your Backup Codes',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Store these codes safely. Each can only be used once if you lose access to your authenticator.',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWarningCard(ThemeData theme) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Keep these codes private and secure. Anyone with access can enter your account.',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodesCard(ThemeData theme) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Backup Codes', style: theme.textTheme.titleLarge),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_codesVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: _toggleVisibility,
                      tooltip: _codesVisible ? 'Hide codes' : 'Show codes',
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_all),
                      onPressed: _copyAllCodes,
                      tooltip: 'Copy all codes',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _backupCodes.length,
              itemBuilder: (_, index) => _buildCodeItem(theme, _backupCodes[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeItem(ThemeData theme, String code) {
    return GestureDetector(
      onTap: () => _copyCode(code),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            _codesVisible ? code : '••••••••',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCompleting ? null : _completeSetup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isCompleting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Complete Setup & Go to Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
