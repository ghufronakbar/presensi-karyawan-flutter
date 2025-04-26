import 'package:flutter/material.dart';
import 'package:presensi_karyawan/utils/notification_utils.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../constants/constants.dart';
import '../../../data/providers/attendance_provider.dart';
import '../../../utils/storage_utils.dart';
import '../home/home_screen.dart';
import '../../../data/providers/overview_provider.dart';

class ScanAttendanceScreen extends StatefulWidget {
  const ScanAttendanceScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ScanAttendanceScreen> createState() => _ScanAttendanceScreenState();
}

class _ScanAttendanceScreenState extends State<ScanAttendanceScreen> {
  bool isProcessing = false;
  String? errorMessage;
  late MobileScannerController _scannerController;
  bool _hasProcessedCode = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
 
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _processQrCode(String code) async {
    if (isProcessing || _hasProcessedCode) return;

    setState(() {
      isProcessing = true;
      errorMessage = null;
      _hasProcessedCode = true;
    });

    try {
      final attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);
      final overviewProvider =
          Provider.of<OverviewProvider>(context, listen: false);
      final result = await attendanceProvider.scanAttendance(code);

      if (result['success']) {
        if (!mounted) return;

        // Refresh overview data to get updated attendance times
        await overviewProvider.getUserOverview();

        NotificationUtils.showSuccessToast(result['message']);

        // Navigate back to home screen
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = result['message'];
          isProcessing = false;
          _hasProcessedCode = false;
        });

        // Clear error after 3 seconds
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          setState(() {
            errorMessage = null;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isProcessing = false;
        _hasProcessedCode = false;
      });

      // Clear error after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          errorMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Presensi"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                );
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes[0].rawValue != null) {
                _processQrCode(barcodes[0].rawValue!);
              }
            },
          ),

          // Scanner overlay
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: Container(),
          ),

          // Loading indicator
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Error message
          if (errorMessage != null)
            Positioned(
              bottom: 100,
              left: 32,
              right: 32,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Instructions
          Positioned(
            bottom: 32,
            left: 32,
            right: 32,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Arahkan kamera ke QR Code untuk Presensi',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double scanAreaLeft = (size.width - scanAreaSize) / 2;
    final double scanAreaTop = (size.height - scanAreaSize) / 2;
    final double scanAreaRight = scanAreaLeft + scanAreaSize;
    final double scanAreaBottom = scanAreaTop + scanAreaSize;

    final Rect scanRect =
        Rect.fromLTRB(scanAreaLeft, scanAreaTop, scanAreaRight, scanAreaBottom);

    // Draw semi-transparent overlay
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);

    // Draw the background with a cutout for the scanning area
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(scanRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw scan area border
    final Paint borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRect(scanRect, borderPaint);

    // Draw corner accents
    final double cornerSize = 20.0;
    final Paint cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    // Top left corner
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + cornerSize),
      Offset(scanAreaLeft, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft + cornerSize, scanAreaTop),
      cornerPaint,
    );

    // Top right corner
    canvas.drawLine(
      Offset(scanAreaRight - cornerSize, scanAreaTop),
      Offset(scanAreaRight, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaRight, scanAreaTop),
      Offset(scanAreaRight, scanAreaTop + cornerSize),
      cornerPaint,
    );

    // Bottom left corner
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaBottom - cornerSize),
      Offset(scanAreaLeft, scanAreaBottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaBottom),
      Offset(scanAreaLeft + cornerSize, scanAreaBottom),
      cornerPaint,
    );

    // Bottom right corner
    canvas.drawLine(
      Offset(scanAreaRight - cornerSize, scanAreaBottom),
      Offset(scanAreaRight, scanAreaBottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaRight, scanAreaBottom),
      Offset(scanAreaRight, scanAreaBottom - cornerSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
