import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/shop_provider.dart';
import '../theme.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  int _pinnedShopId = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: const [
                Icon(
                  Icons.location_on,
                  color: AeroColors.aeroOrange,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Hệ thống Cửa hàng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AeroColors.aeroTextPrimaryDark,
                  ),
                ),
              ],
            ),
          ),
          // Canvas Map Container
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF334155), width: 2),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          // Cyber grid and roads drawing canvas
                          Positioned.fill(
                            child: CustomPaint(
                              painter: CyberMapPainter(),
                            ),
                          ),
                          // Pin 1: Downtown Hub
                          Positioned(
                            left: constraints.maxWidth * 0.35 - 30, // Centered on coordinate
                            top: constraints.maxHeight * 0.42 - 50,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _pinnedShopId = 1;
                                });
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: _pinnedShopId == 1
                                        ? AeroColors.aeroOrange
                                        : Colors.grey[400],
                                    size: _pinnedShopId == 1 ? 48 : 36,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Downtown Hub 🏋️‍♂️',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Pin 2: Beachside Training Bay
                          Positioned(
                            left: constraints.maxWidth * 0.65 - 30, // Centered on coordinate
                            top: constraints.maxHeight * 0.72 - 50,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _pinnedShopId = 2;
                                });
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: _pinnedShopId == 2
                                        ? AeroColors.aeroOrange
                                        : Colors.grey[400],
                                    size: _pinnedShopId == 2 ? 48 : 36,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Training Bay 🌊',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Pinned Shop detail card at the bottom
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: const Color(0xFF1E293B), // Dark card theme
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _pinnedShopId == 1
                              ? "AeroSport Downtown Hub 🏬"
                              : "AeroSport Beachside Bay 🌊",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AeroColors.aeroEmerald.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ĐANG MỞ CỬA',
                            style: TextStyle(
                              color: AeroColors.aeroEmerald,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AeroColors.aeroOrange, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _pinnedShopId == 1
                              ? "158 Nguyễn Huệ, Quận 1, HCMC"
                              : "42 Xuân Thủy, Thảo Điền, Quận 2",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.grey, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _pinnedShopId == 1
                              ? "Thời gian: 08:00 AM - 10:00 PM"
                              : "Thời gian: 06:00 AM - 09:00 PM",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.directions_run, color: Colors.grey, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _pinnedShopId == 1
                              ? "Khoảng cách: 1.2 km (Downtown)"
                              : "Khoảng cách: 4.5 km (Thảo Điền)",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          final address = _pinnedShopId == 1
                              ? "158 Nguyễn Huệ, Q.1"
                              : "42 Xuân Thủy, Thảo Điền, Q.2";
                          final notifier = ref.read(shopProvider.notifier);
                          
                          notifier.updateCheckoutAddress(address);
                          notifier.addNotification(
                            "Chọn địa chỉ 📍",
                            "Đã chọn địa chỉ của chi nhánh làm địa chỉ nhận hàng của bạn!",
                          );
                          notifier.navigateTo(ActiveScreen.cart);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AeroColors.aeroOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'CHỌN GIAO TỪ CHI NHÁNH NÀY',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
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

class CyberMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Grid
    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.3)
      ..strokeWidth = 1.0;

    const double gridStep = 80.0;
    for (double x = 0; x < size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Main Boulevard
    final roadPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.42),
      Offset(size.width, size.height * 0.42),
      roadPaint,
    );

    // 3. Dash Road (Airport route)
    final dashRoadPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round;

    // Draw dashed line manually in Flutter
    double startY = 0;
    const double dashLength = 20.0;
    const double spaceLength = 10.0;
    final double targetX = size.width * 0.35;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(targetX, startY),
        Offset(targetX, startY + dashLength),
        dashRoadPaint,
      );
      startY += dashLength + spaceLength;
    }

    // 4. River flow
    final riverPaint = Paint()
      ..color = const Color(0xFF1D4ED8).withOpacity(0.3)
      ..strokeWidth = 40.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.8),
      Offset(size.width, size.height * 0.72),
      riverPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
