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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              undertone == 'Warm'
                  ? Icons.wb_sunny
                  : (undertone == 'Cool' ? Icons.ac_unit : Icons.balance),
              color: undertone == 'Warm'
                  ? const Color(0xFFF59E0B)
                  : (undertone == 'Cool'
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF10B981)),
            ),
            const SizedBox(width: 12),
            Text(
              'Skin Undertone Detected',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: Text(
          '$undertone\n\nWe analyzed only the square region (auto crop) in the center.',
          style: GoogleFonts.inter(height: 1.4, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _captureAndAnalyze();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _resultAnimController.dispose();
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
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Skin Tone Analysis',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.palette_rounded, color: Colors.black),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Align your face inside the square and capture',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // preview + square overlay
            // Replace the Expanded widget containing the camera preview with this:
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(
                  20.0,
                ), // Add padding around the camera
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      16,
                    ), // Optional: rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      16,
                    ), // Match the container's border radius
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _isCameraInitialized && _cameraController != null
                            ? CameraPreview(_cameraController!)
                            : const Center(child: CircularProgressIndicator()),
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF947E62),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // result card styled like forms
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _analyzedUndertone != null
                  ? Padding(
                      key: ValueKey(_analyzedUndertone),
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              if (_capturedBytes != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb
                                      ? Image.memory(
                                          _capturedBytes!,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(_capturedImagePath!),
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Detected: $_analyzedUndertone',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _undertoneColor(_analyzedUndertone),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF947E62),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
        ),
        icon: _isAnalyzing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.camera_alt),
        label: Text(
          _isAnalyzing ? 'Analyzing...' : 'Capture & Analyze',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        onPressed: _isAnalyzing ? null : _captureAndAnalyze,
      ),
    );
  }
}
