// lib/screens/palette_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_profile_model.dart';
import '../utils/transitions_helper.dart';

class PaletteScreen extends StatefulWidget {
  const PaletteScreen({super.key});

  @override
  State<PaletteScreen> createState() => _PaletteScreenState();
}

class _PaletteScreenState extends State<PaletteScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isAnalyzing = false;
  String? _capturedImagePath;
  Uint8List? _capturedBytes; // for web thumbnail
  String? _analyzedUndertone;

  late final AnimationController _resultAnimController;
  late final Animation<double> _resultAnim;
  late final AnimationController _buttonPulseController;
  late final Animation<double> _buttonPulseAnim;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _resultAnim = CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.easeOut,
    );

    // Pulse animation for the capture button
    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _buttonPulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _buttonPulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(front, ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (e, st) {
      debugPrint('Camera init error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Camera init error: $e')));
      }
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (!_isCameraInitialized || _cameraController == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera not ready')));
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analyzedUndertone = null;
    });

    try {
      final XFile picture = await _cameraController!.takePicture();

      // Read bytes
      final Uint8List bytes = await picture.readAsBytes();

      setState(() {
        _capturedImagePath = picture.path;
        _capturedBytes = bytes;
      });

      final undertone = await _analyzeSkinTone(bytes);

      setState(() {
        _analyzedUndertone = undertone;
        _isAnalyzing = false;
      });

      // Update global model via Provider
      Provider.of<UserProfileModel>(
        context,
        listen: false,
      ).updateSkinTone(undertone);

      _resultAnimController.forward(from: 0);
      _showResultDialog(undertone);
    } catch (e, st) {
      debugPrint('Capture/analyze error: $e\n$st');
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Analyze only the region inside the guide square (auto crop).
  Future<String> _analyzeSkinTone(Uint8List bytes) async {
    try {
      final img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) return 'Neutral';

      final int cropSize = (math.min(decoded.width, decoded.height) * 0.4)
          .toInt();
      final int xStart = (decoded.width ~/ 2 - cropSize ~/ 2).clamp(
        0,
        decoded.width - 1,
      );
      final int yStart = (decoded.height ~/ 2 - cropSize ~/ 2).clamp(
        0,
        decoded.height - 1,
      );
      final int xEnd = (xStart + cropSize).clamp(0, decoded.width - 1);
      final int yEnd = (yStart + cropSize).clamp(0, decoded.height - 1);

      final List<List<double>> hsvSamples = [];

      for (int y = yStart; y <= yEnd; y++) {
        for (int x = xStart; x <= xEnd; x++) {
          final dynamic p = decoded.getPixel(x, y);
          int r, g, b;
          if (p is int) {
            final rgb = _extractRgbFromInt(p);
            r = rgb[0];
            g = rgb[1];
            b = rgb[2];
          } else {
            r = (p as dynamic).r as int;
            g = (p as dynamic).g as int;
            b = (p as dynamic).b as int;
          }
          final hsv = _rgbToHsv(r, g, b);
          hsvSamples.add(hsv);
        }
      }

      if (hsvSamples.isEmpty) return 'Neutral';

      double avgH = 0, avgS = 0, avgV = 0;
      for (final hv in hsvSamples) {
        avgH += hv[0];
        avgS += hv[1];
        avgV += hv[2];
      }
      avgH /= hsvSamples.length;
      avgS /= hsvSamples.length;
      avgV /= hsvSamples.length;

      final undertone = _determineUndertone(avgH, avgS, avgV);

      debugPrint(
        "Auto-crop HSV avg -> H:${avgH.toStringAsFixed(2)} "
        "S:${avgS.toStringAsFixed(2)} V:${avgV.toStringAsFixed(2)} "
        "=> $undertone",
      );

      return undertone;
    } catch (e, st) {
      debugPrint('Analysis error: $e\n$st');
      return 'Neutral';
    }
  }

  List<int> _extractRgbFromInt(int pixel) {
    final int rA = (pixel >> 16) & 0xFF;
    final int gA = (pixel >> 8) & 0xFF;
    final int bA = pixel & 0xFF;

    final int rB = pixel & 0xFF;
    final int gB = (pixel >> 8) & 0xFF;
    final int bB = (pixel >> 16) & 0xFF;

    final sA = _rgbToHsv(rA, gA, bA)[1];
    final sB = _rgbToHsv(rB, gB, bB)[1];

    return sA >= sB ? [rA, gA, bA] : [rB, gB, bB];
  }

  List<double> _rgbToHsv(int r, int g, int b) {
    final double rf = r / 255.0;
    final double gf = g / 255.0;
    final double bf = b / 255.0;
    final double maxVal = math.max(rf, math.max(gf, bf));
    final double minVal = math.min(rf, math.min(gf, bf));
    final double delta = maxVal - minVal;

    double h = 0.0;
    if (delta != 0) {
      if (maxVal == rf) {
        h = 60 * (((gf - bf) / delta) % 6);
      } else if (maxVal == gf) {
        h = 60 * (((bf - rf) / delta) + 2);
      } else {
        h = 60 * (((rf - gf) / delta) + 4);
      }
    }
    if (h < 0) h += 360;

    final double s = maxVal == 0 ? 0 : delta / maxVal;
    final double v = maxVal;
    return [h, s, v];
  }

  String _determineUndertone(double h, double s, double v) {
    if ((h >= 40 && h <= 70) || (h >= 0 && h <= 30)) {
      return 'Warm';
    } else if (h >= 180 && h <= 270) {
      return 'Cool';
    }
    return 'Neutral';
  }

  void _showResultDialog(String undertone) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _resultAnimController,
          curve: Curves.elasticOut,
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(
                      undertone == 'Warm'
                          ? Icons.wb_sunny
                          : (undertone == 'Cool'
                                ? Icons.ac_unit
                                : Icons.balance),
                      color: undertone == 'Warm'
                          ? const Color(0xFFF59E0B)
                          : (undertone == 'Cool'
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF10B981)),
                      size: 32,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Skin Undertone Detected',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '$undertone\n\nWe analyzed only the square region in the center.',
            style: GoogleFonts.inter(height: 1.5, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B7355),
              ),
              child: Text(
                'Close',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _resultAnimController.dispose();
    _buttonPulseController.dispose();
    super.dispose();
  }

  Color _undertoneColor(String? u) {
    switch (u) {
      case 'Warm':
        return const Color(0xFFF59E0B);
      case 'Cool':
        return const Color(0xFF3B82F6);
      case 'Neutral':
        return const Color(0xFF10B981);
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7DFD8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7DFD8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Under Tone Analysis',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Instruction Card with slide animation
              AnimatedSlideIn(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 100),
                begin: const Offset(0, -0.2),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8B7355),
                                    Color(0xFFB5A491),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Perfect Your Shot',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Align your face inside the square for accurate analysis',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.black54,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Camera Preview with scale animation
              AnimatedSlideIn(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 200),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _isCameraInitialized && _cameraController != null
                            ? CameraPreview(_cameraController!)
                            : Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF8B7355),
                                  ),
                                ),
                              ),

                        // Animated guide square overlay
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: AnimatedPulsingBorder(
                                child: Container(
                                  width: 240,
                                  height: 240,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF8B7355),
                                      width: 4,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Result Card with smooth transition
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _analyzedUndertone != null
                    ? Container(
                        key: ValueKey(_analyzedUndertone),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            if (_capturedBytes != null)
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: kIsWeb
                                          ? Image.memory(
                                              _capturedBytes!,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(_capturedImagePath!),
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '$_analyzedUndertone Undertone',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: _undertoneColor(
                                        _analyzedUndertone,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      _analyzedUndertone == 'Warm'
                                          ? Icons.wb_sunny
                                          : (_analyzedUndertone == 'Cool'
                                                ? Icons.ac_unit
                                                : Icons.balance),
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ScaleTransition(
        scale: _isAnalyzing
            ? const AlwaysStoppedAnimation(1.0)
            : _buttonPulseAnim,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B7355),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: _isAnalyzing ? 2 : 8,
          ),
          icon: _isAnalyzing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.camera_alt, size: 24),
          label: Text(
            _isAnalyzing ? 'Analyzing...' : 'Capture & Analyze',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: _isAnalyzing ? null : _captureAndAnalyze,
        ),
      ),
    );
  }
}

// Animated pulsing border widget for the guide square
class AnimatedPulsingBorder extends StatefulWidget {
  final Widget child;

  const AnimatedPulsingBorder({super.key, required this.child});

  @override
  State<AnimatedPulsingBorder> createState() => _AnimatedPulsingBorderState();
}

class _AnimatedPulsingBorderState extends State<AnimatedPulsingBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _opacityAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacityAnim, child: widget.child);
  }
}
