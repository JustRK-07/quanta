import 'dart:io';
import 'package:flutter/material.dart';
import '../models/scan_subject.dart';

/// 56×56 circular badge that displays the scan image when one exists, or a
/// subject-themed icon over the subject colour otherwise. Replaces the
/// generic science-beaker thumbnail used in the history list.
class SubjectBadge extends StatelessWidget {
  const SubjectBadge({
    super.key,
    required this.subject,
    this.imagePath = '',
    this.size = 56,
  });

  final ScanSubject subject;
  final String imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath.isNotEmpty && File(imagePath).existsSync();
    final color = subject.color;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: hasImage
            ? Image.file(File(imagePath), fit: BoxFit.cover)
            : Icon(subject.icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}
