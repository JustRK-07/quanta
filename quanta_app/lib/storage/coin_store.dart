import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Why coins were awarded. Each call to [award] is logged with the reason so
/// the same event (e.g. starring the same scan six times) only credits once.
enum CoinReason {
  scan,
  star,
  perfectQuiz,
  dailyStreak,
}

extension CoinReasonX on CoinReason {
  int get amount {
    switch (this) {
      case CoinReason.scan:
        return 10;
      case CoinReason.star:
        return 5;
      case CoinReason.perfectQuiz:
        return 25;
      case CoinReason.dailyStreak:
        return 5;
    }
  }
}

/// Owns the Quanta coin balance, daily streak, and the per-event ledger that
/// prevents farming. Backed by SharedPreferences so the balance survives
/// restarts. Constructed once in main() and provided through Provider so any
/// screen can read the current value with `context.watch<CoinStore>()`.
class CoinStore extends ChangeNotifier {
  static const String _kBalance = 'quanta_coins_balance_v1';
  static const String _kLastDate = 'quanta_coins_last_date_v1';
  static const String _kStreak = 'quanta_coins_streak_v1';
  static const String _kLedger = 'quanta_coins_ledger_v1';

  int _balance = 0;
  int _streak = 0;
  String? _lastAwardDate;
  final Set<String> _ledger = <String>{};

  int get balance => _balance;
  int get streak => _streak;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _balance = prefs.getInt(_kBalance) ?? 0;
      _streak = prefs.getInt(_kStreak) ?? 0;
      _lastAwardDate = prefs.getString(_kLastDate);
      _ledger
        ..clear()
        ..addAll(prefs.getStringList(_kLedger) ?? const []);

      // Daily streak reconciliation runs at every app start. If the user
      // opens the app on a new day, advance the streak; if they jumped more
      // than a day, reset it.
      _reconcileStreak(DateTime.now());
      await _persist();
    } catch (e) {
      // ignore: avoid_print
      print('[CoinStore] init failed: $e');
    }
  }

  /// Award coins for [reason]. If [itemId] is provided, the (reason, itemId)
  /// pair is added to the ledger and future awards with the same pair return
  /// zero — this is the farm-prevention guard for stars and perfect quizzes.
  ///
  /// For [CoinReason.scan] and [CoinReason.dailyStreak] you can omit itemId;
  /// they're guarded separately (once per calendar day for streak, latest
  /// scan replaces the previous one).
  Future<int> award(CoinReason reason, {String? itemId}) async {
    final amount = reason.amount;
    final today = _dateOnly(DateTime.now());

    // Daily streak — once per calendar day, capped at 5 days.
    if (reason == CoinReason.dailyStreak) {
      if (_lastAwardDate == _isoDate(today)) return 0;
      _streak = _streak >= 5 ? 5 : _streak + 1;
      _lastAwardDate = _isoDate(today);
      _balance += amount;
      notifyListeners();
      await _persist();
      return amount;
    }

    // Per-item ledger guard.
    if (itemId != null) {
      final key = '${reason.name}:$itemId';
      if (_ledger.contains(key)) return 0;
      _ledger.add(key);
    }

    _balance += amount;
    notifyListeners();
    await _persist();
    return amount;
  }

  /// Re-seed the demo balance the first time the user opens the app, so the
  /// Account screen has something to show. Idempotent — only fires when the
  /// ledger is empty AND the seeded-flag is unset.
  Future<void> seedIfEmpty() async {
    if (_balance > 0 || _ledger.isNotEmpty) return;
    _balance = 50; // Demo top-up
    _streak = 1;
    _lastAwardDate = _isoDate(DateTime.now());
    notifyListeners();
    await _persist();
  }

  void _reconcileStreak(DateTime now) {
    if (_lastAwardDate == null) {
      _streak = 1;
      return;
    }
    final last = DateTime.tryParse(_lastAwardDate!);
    if (last == null) {
      _streak = 1;
      return;
    }
    final today = _dateOnly(now);
    final lastDay = _dateOnly(last);
    final diff = today.difference(lastDay).inDays;
    if (diff == 0) {
      // Same day — no change.
    } else if (diff == 1) {
      // Consecutive day — streak continues (will increment on next daily award).
    } else if (diff > 1) {
      _streak = 0; // broken
    }
    // diff < 0 = clock rolled back; keep streak as-is.
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kBalance, _balance);
      await prefs.setInt(_kStreak, _streak);
      if (_lastAwardDate != null) {
        await prefs.setString(_kLastDate, _lastAwardDate!);
      }
      await prefs.setStringList(_kLedger, _ledger.toList());
    } catch (e) {
      // ignore: avoid_print
      print('[CoinStore] persist failed: $e');
    }
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
