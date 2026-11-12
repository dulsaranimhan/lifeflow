import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_providers.dart';
import '../data/home_data.dart';
import '../data/home_providers.dart';
import 'widgets/greeting_header.dart';
import 'widgets/recommendation_card.dart';

/// S02 – Home: the "What should I do now?" dashboard.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _recalculateEvery = Duration(seconds: 60);

  Timer? _timer;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Data is loaded on open by homeDataProvider. After that:
    // - every 60 s while Home is visible, recalculate with the new "now";
    // - when the app comes back to the foreground, reload everything.
    _timer = Timer.periodic(_recalculateEvery, (_) => _recalculate());
    _lifecycle = AppLifecycleListener(onResume: _refresh);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  /// Recalculates the recommendation with the current time (no network).
  void _recalculate() {
    if (!mounted) return;
    // Skip while another tab is shown; the shell keeps Home alive offstage.
    if (!(TickerMode.valuesOf(context).enabled)) return;
    ref.read(homeClockProvider.notifier).tick();
  }

  /// Reloads data from Supabase and recalculates the recommendation.
  Future<void> _refresh() async {
    ref.read(homeClockProvider.notifier).tick();
    ref.invalidate(homeDataProvider);
    try {
      await ref.read(homeRecommendationProvider.future);
    } catch (_) {
      // The error state is rendered by the build method.
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(homeDataProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: switch (data) {
            AsyncData(:final value) => _HomeContent(data: value),
            AsyncError() => _HomeError(onRetry: _refresh),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.data});

  final HomeData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(homeClockProvider);
    final user = ref.watch(currentUserProvider);
    final name = data.name.isNotEmpty
        ? data.name
        : (user?.userMetadata?['name'] as String?) ?? '';

    return ListView(
      // Always scrollable so pull-to-refresh works on short content.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        GreetingHeader(name: name, now: now),
        const SizedBox(height: 20),
        const RecommendationCard(),
        // home-sections
      ],
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.cloud_off_outlined,
          size: 56,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        const Text(
          "Couldn't load your day. Check your connection and try again.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
