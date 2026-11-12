# LifeFlow

**What should I do now?** — a daily decision assistant for university students.
LifeFlow looks at your tasks, deadlines and timetable and suggests what to do in
your next free window, including when to leave for your next event.

Built with Flutter (Android first), Supabase (Auth + Postgres), Riverpod and go_router.

## Setup

### 1. Create a Supabase project

1. Sign in at [supabase.com](https://supabase.com) and create a new project.
2. Go to **Project Settings → API** and copy the **Project URL** and the
   **anon / publishable key**.

### 2. Run the database migrations

In the Supabase dashboard open **SQL Editor** and run each file **in order**:

1. `supabase/migrations/0001_tables.sql` – tables
2. `supabase/migrations/0002_rls.sql` – Row Level Security policies
3. `supabase/migrations/0003_profile_trigger.sql` – creates a profile on sign-up

> Tip: while developing you can turn off **Authentication → Providers → Email →
> Confirm email** so new accounts can log in straight away.

### Optional: demo data

To try the Home screen before the Tasks and Events screens are built, register
an account in the app, then open `supabase/seed_demo.sql`, change `demo_email`
to that account's email and run the script in the SQL Editor. It adds 5 sample
tasks and 2 events (dev only).

### 3. Configure the app

```bash
cp .env.example .env
```

Fill in `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env`. The file is
git-ignored — never commit it. It must exist (even empty) because it is bundled
as an asset; with empty values the app shows a "Supabase is not configured" screen.

### 4. Run

```bash
flutter pub get
flutter run
```

Checks before committing:

```bash
flutter analyze
flutter test
```

## Project structure

```
lib/
  main.dart                 # loads .env, initialises Supabase, ProviderScope
  app.dart                  # MaterialApp.router
  core/
    models/                 # Profile, Task, Event, Recommendation
    router/                 # go_router + auth redirect
    theme/                  # Material 3 theme (navy / teal)
    widgets/                # bottom-nav shell
  features/
    auth/                   # login, register, AuthRepository
    home/                   # S02 Home – "What should I do now?"
    tasks/                  # S04 Tasks
    schedule/               # S07 Schedule
    settings/               # S08 Profile & settings
supabase/migrations/        # SQL to run in the Supabase SQL editor
```

## Team ownership

| Member  | Folders / areas |
|---------|-----------------|
| Dulsara | `lib/core/`, `lib/features/auth/`, `lib/features/home/`, recommendation engine |
| Esandu  | `lib/features/tasks/`, recommendation UI, `lib/features/schedule/` |
| Hirushi | `lib/features/events/`, services, `lib/features/settings/` |

Keep changes inside your own folders where possible and use small commits with
conventional messages (`feat(tasks): …`, `fix(auth): …`, `chore(db): …`).
