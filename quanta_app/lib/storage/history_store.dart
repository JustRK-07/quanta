import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/scan_history.dart';
import '../models/scan_subject.dart';

class HistoryStore {
  static List<ScanHistory> _history = [];
  static const String _key = 'quanta_history_v1';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _history = decoded
            .map((e) => ScanHistory.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // Handle corrupt data by clearing or ignoring
        print("Error loading history: $e");
      }
    }
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_history.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<void> add(ScanHistory scan) async {
    _history.insert(0, scan);
    await _save();
  }

  static Future<void> remove(ScanHistory scan) async {
    _history.remove(scan);
    await _save();
  }

  // For updates like adding quiz results or starring
  static Future<void> update() async {
    await _save();
  }

  static void setHistory(List<ScanHistory> list) {
    _history = list;
    _save();
  }

  static List<ScanHistory> get history => _history;

  // ============================================================
  // Demo seed
  // ============================================================

  /// Replace the current history with a curated set of demo scans spanning
  /// every subject. Writes small placeholder PNGs to the app's documents
  /// directory so the detail screen's `Image.file` calls have something to
  /// render. Idempotent: re-running overwrites with the same set.
  static Future<void> seedDemoData() async {
    final String? scanDirectory;
    if (kIsWeb) {
      // Web has no application documents directory. The detail screen treats
      // this marker as a demo placeholder and does not read it as a file.
      scanDirectory = null;
    } else {
      final docsDir = await getApplicationDocumentsDirectory();
      final scanDir = Directory('${docsDir.path}/demo_scans');
      if (!await scanDir.exists()) await scanDir.create(recursive: true);
      scanDirectory = scanDir.path;
    }

    final now = DateTime.now();
    final entries = <_SeedEntry>[
      _SeedEntry(
        file: 'physics_projectile.png',
        rgb: const [29, 78, 216],
        topic: 'Projectile Motion — launch angle 45°, v₀ = 20 m/s',
        variables: const ['v0 = 20 m/s', 'θ = 45°', 'g = 9.8 m/s²'],
        subject: ScanSubject.physics,
        daysAgo: 0,
        hour: 9,
        starred: true,
        quizResults: const [
          {
            'score': 5,
            'total': 5,
            'percentage': 100,
            'timestamp': null, // filled below
            'quizData': <String, dynamic>{},
            'answers': <String, dynamic>{},
          }
        ],
        notes: const {
          'concept':
              'A projectile launched from ground level follows a parabolic path. Horizontal velocity stays constant; vertical velocity changes linearly under gravity.',
          'formulas': const [
                'Range  R = v₀² · sin(2θ) / g',
                'Max height  H = v₀² · sin²(θ) / (2g)',
                'Time of flight  T = 2 · v₀ · sin(θ) / g',
              ],
          'key_points': const [
                'Range is maximised at θ = 45° on level ground.',
                'Time of flight depends only on the vertical component.',
                'Acceleration is constant (g, downward) throughout the flight.',
              ],
          'worked_example': const [
                'v₀ = 20 m/s, θ = 45°',
                'R = 400 · sin(90°) / 9.8 ≈ 40.8 m',
                'H = 400 · 0.5 / 19.6 ≈ 10.2 m',
              ],
        },
      ),
      _SeedEntry(
        file: 'math_quadratic.png',
        rgb: const [124, 58, 237],
        topic: 'Quadratic equations — roots of x² − 5x + 6 = 0',
        variables: const ['a = 1', 'b = −5', 'c = 6'],
        subject: ScanSubject.math,
        daysAgo: 1,
        hour: 14,
        starred: false,
        notes: const {
          'concept':
              'A quadratic equation ax² + bx + c = 0 has at most two real roots. The discriminant Δ = b² − 4ac tells you how many.',
          'formulas': const [
                'Roots  x = (−b ± √Δ) / (2a)',
                'Discriminant  Δ = b² − 4ac',
                'Sum of roots  = −b/a,   Product  = c/a',
              ],
          'key_points': const [
                'Δ > 0 → two distinct real roots.',
                'Δ = 0 → one repeated root.',
                'Δ < 0 → no real roots.',
              ],
          'worked_example': const [
                'x² − 5x + 6 = 0',
                'Δ = 25 − 24 = 1',
                'x = (5 ± 1) / 2  →  x = 3  or  x = 2',
              ],
        },
      ),
      _SeedEntry(
        file: 'chem_water_molecule.png',
        rgb: const [20, 184, 166],
        topic: 'Water (H2O) — bent molecular geometry',
        variables: const ['O–H bond ≈ 0.096 nm', '∠H–O–H ≈ 104.5°', 'polar'],
        subject: ScanSubject.chemistry,
        daysAgo: 2,
        hour: 11,
        starred: true,
        quizResults: const [
          {
            'score': 4,
            'total': 5,
            'percentage': 80,
            'timestamp': null,
            'quizData': <String, dynamic>{},
            'answers': <String, dynamic>{},
          }
        ],
        notes: const {
          'concept':
              'Water is a bent (angular) triatomic molecule. Two lone pairs on oxygen push the O–H bonds together, producing the famous 104.5° bond angle.',
          'formulas': const [
                'Geometry: AX₂E₂ (bent)',
                'Polarity: μ ≈ 1.85 D',
                'Specific heat: 4.18 J/(g·K)',
              ],
          'key_points': const [
                'The bent shape comes from VSEPR repulsion of the two lone pairs.',
                'Polarity makes water an excellent solvent for ionic compounds.',
                'Hydrogen bonding gives water unusually high melting and boiling points.',
              ],
          'worked_example': const [
                'Two O–H bonds at 104.5°',
                'Net dipole points toward oxygen',
                'Bond length ≈ 0.096 nm',
              ],
        },
      ),
      _SeedEntry(
        file: 'chem_atom.png',
        rgb: const [20, 184, 166],
        topic: 'Atom — Bohr model, Z = 6 (carbon)',
        variables: const ['Z = 6', 'A = 12', 'e⁻ shells = 2 / 4'],
        subject: ScanSubject.chemistry,
        daysAgo: 3,
        hour: 16,
        starred: false,
        notes: const {
          'concept':
              'Bohr\'s 1913 model puts electrons in quantised orbits around the nucleus. Each shell has a fixed energy; photons are emitted when electrons drop between shells.',
          'formulas': const [
                'Shell capacity  2n²',
                'Energy level  E_n = −13.6 eV / n²',
                'Photon  E = h · f',
              ],
          'key_points': const [
                'Shell 1 holds 2 e⁻; shell 2 holds 8 e⁻.',
                'Carbon (Z = 6) → 2 e⁻ in shell 1, 4 e⁻ in shell 2.',
                'Absorption / emission lines reveal the element.',
              ],
          'worked_example': const [
                'Z = 6 → 6 protons, 6 electrons (neutral atom).',
                'Electron configuration: 1s² 2s² 2p².',
                'Valence shell is shell 2 with 4 e⁻ → forms 4 covalent bonds.',
              ],
        },
      ),
      _SeedEntry(
        file: 'physics_shm.png',
        rgb: const [29, 78, 216],
        topic: 'Simple Harmonic Motion — mass-spring, m = 0.5 kg, k = 200 N/m',
        variables: const ['m = 0.5 kg', 'k = 200 N/m', 'A = 0.1 m'],
        subject: ScanSubject.physics,
        daysAgo: 5,
        hour: 8,
        starred: false,
        notes: const {
          'concept':
              'A mass on a frictionless spring oscillates sinusoidally. The motion is described by x(t) = A · cos(ωt + φ).',
          'formulas': const [
                'Angular frequency  ω = √(k/m)',
                'Period  T = 2π · √(m/k)',
                'Total energy  E = ½ · k · A²',
              ],
          'key_points': const [
                'ω here = √(200/0.5) = 20 rad/s → T ≈ 0.314 s.',
                'Energy swaps between kinetic and potential each quarter-cycle.',
                'Frequency is independent of amplitude (isochronous).',
              ],
          'worked_example': const [
                'ω = √(200 / 0.5) = 20 rad/s',
                'T = 2π / 20 ≈ 0.314 s',
                'E = ½ · 200 · 0.01 = 1 J',
              ],
        },
      ),
      _SeedEntry(
        file: 'other_misc.png',
        rgb: const [100, 116, 139],
        topic: 'Wave on a string — y = A sin(ωt + kx)',
        variables: const ['A = 0.05 m', 'f = 2 Hz', 'v = 4 m/s'],
        subject: ScanSubject.other,
        daysAgo: 7,
        hour: 19,
        starred: false,
        notes: const {
          'concept':
              'A travelling wave moves along the string with speed v = λ·f. Each point on the string oscillates in simple harmonic motion at the same frequency, but with a phase shift.',
          'formulas': const [
                'Displacement  y(x,t) = A · sin(ωt − kx)',
                'Wave speed  v = λ · f = ω / k',
                'Energy density  u = ½ · μ · ω² · A²',
              ],
          'key_points': const [
                'Higher tension → faster wave speed.',
                'Amplitude is independent of speed and frequency.',
                'Two waves on the same string superpose linearly.',
              ],
          'worked_example': const [
                'A = 0.05 m, f = 2 Hz, v = 4 m/s',
                'λ = v / f = 2 m',
                'ω = 2π · f ≈ 12.57 rad/s',
              ],
        },
      ),
    ];

    // Write placeholder PNGs (one per topic) and build ScanHistory entries.
    final newHistory = <ScanHistory>[];
    for (final e in entries) {
      final ts = DateTime(now.year, now.month, now.day - e.daysAgo, e.hour);
      final path = scanDirectory == null
          ? '/demo_scans/${e.file}'
          : '$scanDirectory/${e.file}';
      if (scanDirectory != null) {
        await _writeSolidPng(path, e.rgb[0], e.rgb[1], e.rgb[2]);
      }

      final quizResults = e.quizResults.map((q) {
        final m = Map<String, dynamic>.from(q);
        m['timestamp'] = ts.add(const Duration(hours: 1)).toIso8601String();
        return m;
      }).toList();

      newHistory.add(ScanHistory(
        topic: e.topic,
        variables: e.variables,
        imagePath: path,
        notesJson: Map<String, dynamic>.from(e.notes),
        isStarred: e.starred,
        timestamp: ts,
        quizResults: quizResults,
        subject: e.subject,
      ));
    }

    _history = newHistory;
    await _save();
  }

  /// Writes a tiny solid-colour PNG (1×1 pixel) to [path]. SubjectBadge and
  /// HistoryDetailScreen downscale / centre it; that's good enough for a demo.
  static Future<void> _writeSolidPng(
      String path, int r, int g, int b) async {
    final bytes = _buildSolidPng(r, g, b);
    final f = File(path);
    await f.writeAsBytes(bytes, flush: true);
  }

  /// Builds a 1×1 RGBA PNG with the given colour using a hand-rolled chunk
  /// encoder. Avoids pulling in `image` or any other decoding dependency.
  static Uint8List _buildSolidPng(int r, int g, int b) {
    final sig = <int>[137, 80, 78, 71, 13, 10, 26, 10];

    final ihdr = _chunk('IHDR', _u32(1) + _u32(1) + [8, 6, 0, 0, 0]);
    // IDAT = zlib-compressed scanline: filter byte (0) + RGBA pixel (4 bytes).
    final raw = <int>[0, r, g, b, 255];
    final idat = _chunk('IDAT', _zlibStore(raw));
    final iend = _chunk('IEND', const <int>[]);

    return Uint8List.fromList([
      ...sig,
      ...ihdr,
      ...idat,
      ...iend,
    ]);
  }

  static List<int> _chunk(String type, List<int> data) {
    final typeBytes = type.codeUnits;
    final length = _u32(data.length);
    final crcInput = [...typeBytes, ...data];
    final crc = _crc32(crcInput);
    return [...length, ...typeBytes, ...data, ...crc];
  }

  static List<int> _u32(int v) =>
      [(v >> 24) & 0xff, (v >> 16) & 0xff, (v >> 8) & 0xff, v & 0xff];

  /// zlib-wrapped stored (uncompressed) DEFLATE stream: just one block, no
  /// compression, but with proper Adler-32 checksum and zlib header.
  static List<int> _zlibStore(List<int> raw) {
    // zlib header: 0x78 0x01 (deflate, no compression, fastest).
    final header = [0x78, 0x01];

    // DEFLATE stored block: BFINAL=1, BTYPE=00. Header byte = 0x01.
    final lLen = _u16LE(raw.length);
    final lNLen = _u16LE(~raw.length & 0xffff);

    final adler = _adler32(raw);
    final aBytes = _u32(adler);

    return [
      ...header,
      0x01,
      ...lLen,
      ...lNLen,
      ...raw,
      ...aBytes,
    ];
  }

  static List<int> _u16LE(int v) => [v & 0xff, (v >> 8) & 0xff];

  static int _adler32(List<int> data) {
    int a = 1, b = 0;
    for (final byte in data) {
      a = (a + byte) % 65521;
      b = (b + a) % 65521;
    }
    return (b << 16) | a;
  }

  // CRC-32 (polynomial 0xEDB88320), used by PNG chunks.
  static List<int> _crc32(List<int> data) {
    var crc = 0xffffffff;
    for (final byte in data) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        crc = (crc & 1) != 0 ? (crc >>> 1) ^ 0xedb88320 : crc >>> 1;
      }
    }
    crc = (~crc) & 0xffffffff;
    return _u32(crc);
  }
}

class _SeedEntry {
  const _SeedEntry({
    required this.file,
    required this.rgb,
    required this.topic,
    required this.variables,
    required this.subject,
    required this.daysAgo,
    required this.hour,
    required this.starred,
    required this.notes,
    this.quizResults = const [],
  });

  final String file;
  final List<int> rgb;
  final String topic;
  final List<String> variables;
  final ScanSubject subject;
  final int daysAgo;
  final int hour;
  final bool starred;
  final Map<String, dynamic> notes;
  final List<Map<String, dynamic>> quizResults;
}
