import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/square_back_button.dart';
import '../../home/data/home_providers.dart';
import '../../recommendation/engine/reason_text.dart';
import '../data/notice_providers.dart';
import '../domain/notice.dart';

/// 09 – Notifications.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NoticeType? _filter;

  static const _tabs = <(String, NoticeType?)>[
    ('All', null),
    ('Deadlines', NoticeType.deadline),
    ('Travel', NoticeType.travel),
    ('Events', NoticeType.event),
  ];

  void _open(Notice notice) {
    if (notice.task != null) {
      context.push(AppRoutes.editTask, extra: notice.task);
    } else if (notice.event != null) {
      context.push(AppRoutes.editEvent, extra: notice.event);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notices = ref.watch(noticesProvider);
    final now = ref.watch(homeClockProvider);
    final visible = (notices.value ?? const <Notice>[])
        .where((n) => _filter == null || n.type == _filter)
        .toList();
    final highlighted = visible.where((n) => n.isSoon(now)).firstOrNull;

    final children = <Widget>[];
    NoticeGroup? group;
    for (final notice in visible) {
      final g = groupOf(notice.time, now);
      if (g != group) {
        group = g;
        children.add(_GroupLabel(g));
      }
      children.add(
        _NoticeTile(
          notice: notice,
          now: now,
          highlighted: identical(notice, highlighted),
          onTap: () => _open(notice),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(noticesProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              const Row(
                children: [
                  SquareBackButton(color: AppColors.iconBox),
                  Spacer(),
                  UserAvatarButton(),
                ],
              ),
              const SizedBox(height: 24),
              Text('Notifications', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text(
                'Stay on top of what matters.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.muted,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const ShapeDecoration(
                  color: AppColors.field,
                  shape: StadiumBorder(),
                ),
                child: Row(
                  children: [
                    for (final (label, type) in _tabs)
                      Expanded(
                        child: Material(
                          color: _filter == type
                              ? AppColors.yellow
                              : Colors.transparent,
                          shape: const StadiumBorder(),
                          child: InkWell(
                            customBorder: const StadiumBorder(),
                            onTap: () => setState(() => _filter = type),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: _filter == type
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...switch (notices) {
                AsyncData() when visible.isEmpty => [
                  const _Empty('Nothing to show right now. Enjoy the calm! 🌿'),
                ],
                AsyncData() => children,
                AsyncError() => [
                  const _Empty("Couldn't load notifications. Pull to retry."),
                ],
                _ => [
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.group);

  final NoticeGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 0, 10),
      child: Text(
        group.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: AppColors.muted, letterSpacing: 2),
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({
    required this.notice,
    required this.now,
    required this.highlighted,
    required this.onTap,
  });

  final Notice notice;
  final DateTime now;
  final bool highlighted;
  final VoidCallback onTap;

  String get _emoji => switch (notice.type) {
    NoticeType.deadline => '✅',
    NoticeType.travel => '🚌',
    NoticeType.event => '📅',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final soon = notice.isSoon(now);
    final time = groupOf(notice.time, now) == NoticeGroup.earlier
        ? describeDeadline(notice.time, now).replaceFirst('Overdue since ', '')
        : formatClock(notice.time);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            child: soon
                ? const CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.check,
                  )
                : null,
          ),
          Expanded(
            child: Material(
              color: highlighted ? const Color(0xFFFEF3D8) : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: highlighted
                              ? AppColors.yellowTint
                              : AppColors.iconBox,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notice.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  time,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: highlighted
                                        ? AppColors.amber
                                        : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notice.body,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.muted,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 4, top: 12),
                        child: Icon(
                          Icons.chevron_right,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(color: AppColors.muted),
      ),
    );
  }
}
