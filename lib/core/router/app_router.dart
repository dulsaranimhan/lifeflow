import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/events/presentation/event_form_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/insights/presentation/insights_screen.dart';
import '../../features/schedule/presentation/schedule_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../../features/tasks/presentation/task_form_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../models/event.dart';
import '../models/task.dart';
import '../widgets/app_shell.dart';

abstract final class AppRoutes {
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const tasks = '/tasks';
  static const newTask = '/task/new';
  static const editTask = '/task/edit';
  static const schedule = '/schedule';
  static const newEvent = '/event/new';
  static const editEvent = '/event/edit';
  static const insights = '/insights';
  static const profile = '/profile';
}

const _publicRoutes = {AppRoutes.welcome, AppRoutes.login, AppRoutes.register};

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final refresh = _StreamListenable(auth.authStateChanges());
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = auth.currentUser != null;
      final onPublicRoute = _publicRoutes.contains(state.matchedLocation);

      if (!loggedIn && !onPublicRoute) return AppRoutes.welcome;
      if (loggedIn && onPublicRoute) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.newTask,
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.editTask,
        redirect: (context, state) =>
            state.extra is Task ? null : AppRoutes.tasks,
        builder: (context, state) => TaskFormScreen(task: state.extra! as Task),
      ),
      GoRoute(
        path: AppRoutes.newEvent,
        builder: (context, state) => EventFormScreen(
          initialDate: state.extra is DateTime
              ? state.extra! as DateTime
              : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.editEvent,
        redirect: (context, state) =>
            state.extra is Event ? null : AppRoutes.schedule,
        builder: (context, state) =>
            EventFormScreen(event: state.extra! as Event),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          _branch(AppRoutes.home, const HomeScreen()),
          _branch(AppRoutes.tasks, const TasksScreen()),
          _branch(AppRoutes.schedule, const ScheduleScreen()),
          _branch(AppRoutes.insights, const InsightsScreen()),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branch(String path, Widget screen) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (context, state) => screen)],
  );
}

/// Notifies go_router whenever the auth stream emits.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
