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
  Timer? _qrTimer;
  Timer? _progressTimer;
  String? _currentQRCode;
  Map<String, dynamic>? _currentQRData;
  double _progress = 1.0;
  bool _isGenerating = false;
  bool _hasGeneratedQR = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  Future<void> _generateNewQRCode() async {
    if (_isGenerating) return;
    
    setState(() {
      _isGenerating = true;
      _progress = 1.0;
    });

    try {
      final code = DateTime.now().millisecondsSinceEpoch.toString();
      final expiry = DateTime.now().add(const Duration(seconds: 30));
      
      await _apiService.saveQRCodeAttendance(
        code: code,
        purpose: 'CHECK_IN',
        expiry: expiry,
      );

      if (!mounted) return;

      setState(() {
        _currentQRData = {
          'code': code,
          'expiry': expiry.toIso8601String(),
        };
        _currentQRCode = jsonEncode(_currentQRData);
        _isGenerating = false;
        _hasGeneratedQR = true;
      });

      _animationController.reset();
      _animationController.forward();

      // Timer pour l'expiration
      _qrTimer?.cancel();
      _qrTimer = Timer(const Duration(seconds: 30), () {
        if (mounted) {
          setState(() {
            _currentQRCode = null;
            _currentQRData = null;
            _hasGeneratedQR = false;
          });
          _showExpiredDialog();
        }
      });

      // Timer pour la progression
      _progressTimer?.cancel();
      _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (mounted) {
          setState(() {
            _progress = 1 - (timer.tick / 300);
            if (_progress <= 0) {
              timer.cancel();
            }
          });
        }
      });

    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _hasGeneratedQR = false;
        });
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

  Future<void> _showExpiredDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('QR Code Expiré'),
        content: const Text('Le QR code a expiré. Veuillez en générer un nouveau.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generateNewQRCode();
            },
            child: const Text('Générer un nouveau'),
          ),
        ],
      ),
    );
  }

  Future<void> _showQRDialog() async {
    if (!_hasGeneratedQR) {
      await _generateNewQRCode();
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                'Scanner pour pointer',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (_currentQRCode != null)
                Column(
                  children: [
                    QrImageView(
                      data: _currentQRCode!,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progress > 0.3 ? Colors.blue : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expire dans ${(_progress * 30).toInt()} secondes',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                )
              else if (_isGenerating)
                const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Fermer'),
                  ),
                  ElevatedButton(
                    onPressed: _isGenerating ? null : _generateNewQRCode,
                    child: Text(_isGenerating ? 'Génération...' : 'Régénérer'),
                  ),
                ],
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 64,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Générer un QR Code',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cliquez sur le bouton ci-dessous pour\ngénérer votre QR code de pointage',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _showQRDialog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Générer QR Code'),
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