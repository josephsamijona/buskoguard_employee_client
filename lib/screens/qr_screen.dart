import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'dart:convert';
import '../api.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _qrTimer;
  Timer? _progressTimer;
  String? _currentQRCode;
  Map<String, dynamic>? _currentQRData;
  double _progress = 1.0;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _generateNewQRCode();
  }

  Future<void> _generateNewQRCode() async {
    if (_isGenerating) return;
    
    setState(() {
      _isGenerating = true;
      _progress = 1.0;
    });

    try {
      // Générer les données du QR code
      final code = DateTime.now().millisecondsSinceEpoch.toString();
      final expiry = DateTime.now().add(const Duration(seconds: 30));
      
      // Sauvegarder dans l'API
      await _apiService.saveQRCodeAttendance(
        code: code,
        purpose: 'CHECK_IN',
        expiry: expiry,
      );

      // Mettre à jour l'interface
      setState(() {
        _currentQRData = {
          'code': code,
          'expiry': expiry.toIso8601String(),
        };
        _currentQRCode = jsonEncode(_currentQRData);
        _isGenerating = false;
      });

      _animationController.reset();
      _animationController.forward();

      // Démarrer le timer pour l'expiration
      _qrTimer?.cancel();
      _qrTimer = Timer(const Duration(seconds: 30), _generateNewQRCode);

      // Timer pour la barre de progression
      _progressTimer?.cancel();
      _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (mounted) {
          setState(() {
            _progress = 1 - (timer.tick / 300); // 30 secondes = 300 * 100ms
            if (_progress <= 0) {
              timer.cancel();
            }
          });
        }
      });

    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        _showError('Erreur lors de la génération du QR code');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showQRInfoDialog() async {
    if (_currentQRData == null) return;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 48,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'QR Code Généré',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ce QR code expirera dans quelques secondes.\nVeuillez le scanner rapidement.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Fermer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    _progressTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Column(
        children: [
          // Barre de progression linéaire en haut
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _progress > 0.3 ? Colors.blue : Colors.red,
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Card contenant le QR Code
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Scanner pour pointer',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_currentQRCode != null)
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: GestureDetector(
                                  onTap: _showQRInfoDialog,
                                  child: QrImageView(
                                    data: _currentQRCode!,
                                    version: QrVersions.auto,
                                    size: 250,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              )
                            else
                              const CircularProgressIndicator(),
                            const SizedBox(height: 24),
                            Text(
                              'Le QR code expire dans ${(_qrTimer?.tick ?? 30) ~/ 10} secondes',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Bouton pour régénérer
                    ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateNewQRCode,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: Text(_isGenerating ? 'Génération...' : 'Régénérer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}