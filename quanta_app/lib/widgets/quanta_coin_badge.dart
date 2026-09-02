import 'package:flutter/material.dart';
import '../storage/coin_store.dart';
import '../theme/quanta_theme.dart';

/// Compact "◆ 1,240" pill with an animated count-up. Listens to CoinStore
/// so the value updates the moment any screen awards coins.
class QuantaCoinBadge extends StatelessWidget {
  const QuantaCoinBadge({super.key, this.compact = false});

  /// When true, render a small icon-only pill (for AppBar `actions:`). When
  /// false, render a wider pill with the numeric balance (for cards).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final store = CoinStoreProvider.of(context);
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: store.balance),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final formatted = _format(value);
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: QuantaColors.amber.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: QuantaColors.amber.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.diamond_rounded,
                size: 16,
                color: QuantaColors.amber,
              ),
              const SizedBox(width: 6),
              Text(
                formatted,
                style: const TextStyle(
                  color: QuantaColors.amber,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _format(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '${(n / 1000000).toStringAsFixed(1)}M';
  }
}

/// Tiny InheritedWidget so the badge can read the store without rebuilding the
/// whole tree. The provider is set up in `main.dart` via Provider; this is a
/// thin pass-through for legacy static-store ergonomics.
class CoinStoreProvider extends InheritedWidget {
  const CoinStoreProvider({
    super.key,
    required this.store,
    required super.child,
  });

  final CoinStore store;

  static CoinStore of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<CoinStoreProvider>();
    if (provider == null) {
      throw FlutterError(
        'CoinStoreProvider.of() called with a context that does not contain a CoinStoreProvider.',
      );
    }
    return provider.store;
  }

  @override
  bool updateShouldNotify(CoinStoreProvider oldWidget) =>
      store.balance != oldWidget.store.balance ||
      store.streak != oldWidget.store.streak;
}
