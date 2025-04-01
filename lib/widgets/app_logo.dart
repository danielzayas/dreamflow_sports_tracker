import 'package:flutter/material.dart';
import '../constants/theme.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final bool showText;
  
  const AppLogo({
    Key? key,
    this.height = 40,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo mark
        SizedBox(
          height: height,
          width: height,
          child: CustomPaint(
            painter: LogoPainter(),
            size: Size(height, height),
          ),
        ),
        
        // Optional text
        if (showText) ...[  
          const SizedBox(width: 8),
          Text(
            'Sports Tracker',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: height * 0.5,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ],
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.4;
    
    // Draw circular background
    final backgroundPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), radius, backgroundPaint);
    
    // Draw sports ball elements
    // Basketball lines
    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03;
    
    // Horizontal line
    canvas.drawLine(
      Offset(centerX - radius * 0.7, centerY),
      Offset(centerX + radius * 0.7, centerY),
      linePaint,
    );
    
    // Vertical line
    canvas.drawLine(
      Offset(centerX, centerY - radius * 0.7),
      Offset(centerX, centerY + radius * 0.7),
      linePaint,
    );
    
    // Arc elements (baseball/tennis stitches)
    final arcPaint = Paint()
      ..color = AppTheme.secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round;
    
    // Draw curved lines like baseball stitches or tennis ball curves
    final rect = Rect.fromCircle(center: Offset(centerX, centerY), radius: radius * 0.6);
    canvas.drawArc(rect, 0.8, 1.5, false, arcPaint);
    canvas.drawArc(rect, 3.5, 1.5, false, arcPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}