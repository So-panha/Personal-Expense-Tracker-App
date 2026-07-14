import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A styled social OAuth button with an icon path drawn via [CustomPaint]
/// and a label. Used for Google and Facebook sign-in on auth screens.
class SocialAuthButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final String? iconAsset;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.label,
    this.icon,
    this.iconAsset,
    this.onPressed,
    this.isLoading = false,
  }) : assert(icon != null || iconAsset != null, 'Either icon or iconAsset must be provided');

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white.withOpacity(0.04),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconAsset != null)
                  Image.asset(
                    iconAsset!,
                    height: 22,
                    width: 22,
                  )
                else if (icon != null)
                  SizedBox(height: 22, width: 22, child: icon),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Inline SVG-style icon painters so we don't need any asset files
// ────────────────────────────────────────────────────────────────

class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GooglePainter());
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = w * 0.46;

    // Draw background circle
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r + w * 0.04, bgPaint);

    // Colors
    final red = Paint()..color = const Color(0xFFEA4335);
    final blue = Paint()..color = const Color(0xFF4285F4);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final green = Paint()..color = const Color(0xFF34A853);

    // Draw G logo arcs
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Red arc (top-right)
    canvas.drawArc(rect, -0.52, 1.57, true, red);
    // Blue arc (top-left)
    canvas.drawArc(rect, -2.09, 1.57, true, blue);
    // Yellow arc (bottom-left)
    canvas.drawArc(rect, 2.62, 0.52, true, yellow);
    // Green arc (bottom-right)
    canvas.drawArc(rect, 1.05, 1.57, true, green);

    // White center
    final center = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.55, center);

    // Blue right bar
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx, cy - r * 0.2, r + w * 0.04, r * 0.4),
      Radius.circular(r * 0.1),
    );
    canvas.drawRRect(barRect, blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FacebookIcon extends StatelessWidget {
  const FacebookIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _FacebookPainter());
  }
}

class _FacebookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Blue rounded square background
    final bgPaint = Paint()..color = const Color(0xFF1877F2);
    final bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(bgRRect, bgPaint);

    // White "f" letter
    final fPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final fLeft = w * 0.42;
    final fTop = h * 0.15;
    final barW = w * 0.17;
    final crossW = w * 0.34;

    // Vertical bar of f
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(fLeft, fTop, barW, h * 0.72),
      Radius.circular(barW / 2),
    ));

    // Cross bar
    path.addRect(Rect.fromLTWH(fLeft - crossW * 0.35, h * 0.42, crossW, barW));

    canvas.drawPath(path, fPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  
}
