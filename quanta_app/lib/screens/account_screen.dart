import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firebase_auth_service.dart';
import '../storage/coin_store.dart';
import '../storage/history_store.dart';
import '../theme/quanta_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/google_sign_in_button.dart';
import 'history_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final authService = context.watch<FirebaseAuthService>();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Account"),
        backgroundColor: theme.cardColor,
        foregroundColor: cs.onSurface,
        elevation: 0.4,
        actions: [
          // Coin balance sits in the AppBar so it's visible from every tab.
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: QuantaCoinBalanceChip()),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: user == null
            // Firebase isn't initialised in offline / demo mode — show a
            // populated demo profile rather than the sign-in CTA.
            ? const _DemoProfileView()
            : _ProfileView(authService: authService),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}

class QuantaCoinBalanceChip extends StatelessWidget {
  const QuantaCoinBalanceChip({super.key});

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<CoinStore>().balance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: QuantaColors.amber.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: QuantaColors.amber.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.diamond_rounded,
            size: 14,
            color: QuantaColors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            '$coins',
            style: const TextStyle(
              color: QuantaColors.amber,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoggedOutView extends StatelessWidget {
  const _LoggedOutView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sign in to unlock synced history, notes, and personalised settings.",
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const GoogleSignInButton(),
      ],
    );
  }
}

class _DemoProfileView extends StatefulWidget {
  const _DemoProfileView();

  @override
  State<_DemoProfileView> createState() => _DemoProfileViewState();
}

class _DemoProfileViewState extends State<_DemoProfileView> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final cs2 = theme.colorScheme;
    final history = HistoryStore.history;
    final starredCount = history.where((h) => h.isStarred).length;
    final quizCount = history.fold<int>(
      0,
      (sum, h) => sum + h.quizResults.length,
    );
    final coins = context.watch<CoinStore>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Demo-mode pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: QuantaColors.cyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 14,
                  color: QuantaColors.cyan,
                ),
                const SizedBox(width: 4),
                const Text(
                  "Demo profile · offline",
                  style: TextStyle(
                    color: QuantaColors.cyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Avatar
          CircleAvatar(
            radius: 52,
            backgroundColor: QuantaColors.cyan,
            child: const Icon(Icons.person, size: 56, color: Colors.white),
          ),

          const SizedBox(height: 16),

          // Display Name
          Text(
            "Rushabh Kalme",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          // Email
          Text(
            "rushabh@quanta.dev",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs2.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 24),

          // Stats row — live counts from HistoryStore + CoinStore.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatTile(value: '${history.length}', label: "Scans"),
              _StatTile(value: '$starredCount', label: "Starred"),
              _StatTile(value: '$quizCount', label: "Quizzes"),
              _StatTile(
                value: '${coins.balance}',
                label: "Quanta",
                color: QuantaColors.amber,
                icon: Icons.diamond_rounded,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Demo data controls — populate history so the demo tabs have content.
          _DemoDataActions(
            onSeeded: () {
              if (mounted) setState(() {});
            },
          ),

          const SizedBox(height: 24),

          // Account info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.school_rounded,
                  label: "Plan",
                  value: "Quanta Demo",
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.devices_rounded,
                  label: "Device",
                  value: "Pixel 6 (Android 17)",
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.local_fire_department_rounded,
                  label: "Daily streak",
                  value: "${coins.streak} day${coins.streak == 1 ? '' : 's'}",
                  valueColor: QuantaColors.amber,
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.access_time_rounded,
                  label: "Member since",
                  value: "Sep 2026",
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sign-in CTA (disabled in demo mode)
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Sign-in is disabled in offline demo mode.",
                  ),
                ),
              );
            },
            icon: const Icon(Icons.login_rounded),
            label: const Text("Sign in with Google"),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "Sign in to sync history across devices and earn Quanta offline.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs2.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    this.color,
    this.icon,
  });
  final String value;
  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 2),
            ],
            Text(
              value,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.authService});

  final FirebaseAuthService authService;

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    if (user == null) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Picture
        CircleAvatar(
          radius: 48,
          backgroundImage:
              user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child: user.photoURL == null
              ? const Icon(Icons.person, size: 48)
              : null,
        ),

        const SizedBox(height: 16),

        // Display Name
        Text(
          user.displayName ?? "Unnamed Quanta Learner",
          style: textTheme.titleLarge,
        ),

        // Email
        Text(
          user.email ?? "",
          style: textTheme.bodyMedium,
        ),

        const SizedBox(height: 32),

        const Spacer(),

        // Logout Button
        ElevatedButton.icon(
          onPressed: () async => authService.signOut(),
          icon: const Icon(Icons.logout),
          label: const Text("Logout"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

/// Demo-only controls. Populates HistoryStore with a curated set of demo
/// scans, bumps the coin balance by a small amount per press, and offers a
/// shortcut to the History screen so you can see the result immediately.
class _DemoDataActions extends StatefulWidget {
  const _DemoDataActions({required this.onSeeded});

  final VoidCallback onSeeded;

  @override
  State<_DemoDataActions> createState() => _DemoDataActionsState();
}

class _DemoDataActionsState extends State<_DemoDataActions> {
  bool _busy = false;

  Future<void> _seed() async {
    if (_busy) return;
    setState(() => _busy = true);
    // Capture the coin store before any awaits so the linter doesn't worry
    // about using `context` across async gaps.
    final coins = context.read<CoinStore>();
    try {
      await HistoryStore.seedDemoData();
      // Bump coins by 10 per press; unique itemId keeps the ledger honest.
      await coins.award(
        CoinReason.scan,
        itemId: 'demo-seed-${DateTime.now().millisecondsSinceEpoch}',
      );
      widget.onSeeded();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo history seeded · +10 Quanta coins'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seed failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasHistory = HistoryStore.history.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: QuantaColors.cyan.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science_rounded, size: 20, color: cs.primary),
              const SizedBox(width: 10),
              Text(
                'Demo data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasHistory
                ? 'Replace the current history with the curated demo set (6 scans across all subjects, 2 starred, 2 with quiz results).'
                : 'Populate history, quiz results, and coins so the demo tabs have something to show.',
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _seed,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_fix_high_rounded, size: 18),
                  label: Text(
                    hasHistory ? 'Reseed demo data' : 'Seed demo data',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: QuantaColors.cyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                icon: const Icon(Icons.history_rounded, size: 18),
                label: const Text('View'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
