import 'package:flutter/material.dart';
import '../theme/quanta_theme.dart';

/// Subject classification for a scanned problem.
///
/// Detection is keyword-based (offline, deterministic). When the backend later
/// returns a subject in its response, the field on `ScanHistory` is preferred
/// — `detect()` is the fallback.
enum ScanSubject {
  physics,
  chemistry,
  math,
  biology,
  other;

  Color get color {
    switch (this) {
      case ScanSubject.physics:
        return QuantaColors.physics;
      case ScanSubject.chemistry:
        return QuantaColors.chemistry;
      case ScanSubject.math:
        return QuantaColors.violet;
      case ScanSubject.biology:
        return QuantaColors.emerald;
      case ScanSubject.other:
        return QuantaColors.slate;
    }
  }

  IconData get icon {
    switch (this) {
      case ScanSubject.physics:
        return Icons.bolt_rounded;
      case ScanSubject.chemistry:
        return Icons.science_rounded;
      case ScanSubject.math:
        return Icons.calculate_rounded;
      case ScanSubject.biology:
        return Icons.biotech_rounded;
      case ScanSubject.other:
        return Icons.school_rounded;
    }
  }

  String get label {
    switch (this) {
      case ScanSubject.physics:
        return 'Physics';
      case ScanSubject.chemistry:
        return 'Chemistry';
      case ScanSubject.math:
        return 'Math';
      case ScanSubject.biology:
        return 'Biology';
      case ScanSubject.other:
        return 'Other';
    }
  }

  /// Parse a stored name back into the enum. Returns null on unknown values so
  /// records survive an enum reordering (R12 in the plan).
  static ScanSubject? tryParse(String? name) {
    if (name == null) return null;
    for (final s in ScanSubject.values) {
      if (s.name == name) return s;
    }
    return null;
  }
}

// Order matters: chemistry/math/biology before physics — physics owns generic
// terms ("field", "energy") that also appear in the others' text.
const _kSubjectKeywords = <ScanSubject, List<String>>{
  ScanSubject.chemistry: [
    'chemis',
    'reaction',
    'molecule',
    'compound',
    'acid',
    'base',
    'bond',
    'element',
    'mole',
    'stoichio',
    'ph ',
    'ionic',
    'covalent',
  ],
  ScanSubject.math: [
    'calculus',
    'algebra',
    'geometry',
    'derivative',
    'integral',
    'polynomial',
    'quadratic',
    'matrix',
    'triangle',
    'theorem',
    'function',
    'equation',
    'sine',
    'cosine',
    'tangent',
  ],
  ScanSubject.biology: [
    'biolog',
    'cell',
    'organism',
    'gene',
    'dna',
    'protein',
    'photosynth',
    'mitosis',
    'enzyme',
  ],
  ScanSubject.physics: [
    'physic',
    'optic',
    'lens',
    'mirror',
    'refract',
    'velocity',
    'acceleration',
    'kinematic',
    'projectile',
    'force',
    'newton',
    'momentum',
    'circuit',
    'voltage',
    'magnet',
    'thermo',
    'wave',
    'oscillat',
    'gravity',
    'harmonic',
    'pendulum',
    'spring',
    'shm ',
    'free fall',
    'mass',
  ],
};

/// Classify a scan from its topic, variables, and notes. Returns
/// [ScanSubject.other] when nothing matches.
ScanSubject detectSubject({
  required String topic,
  required List<String> variables,
  required Map<String, dynamic> notesJson,
}) {
  final hay = [
    topic,
    variables.join(' '),
    notesJson['concept']?.toString() ?? '',
  ].join(' ').toLowerCase();
  for (final entry in _kSubjectKeywords.entries) {
    if (entry.value.any(hay.contains)) return entry.key;
  }
  return ScanSubject.other;
}
