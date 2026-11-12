# UI references

These mockups are the source of truth for the app's look. Build each screen to
match its reference.

| Reference | Screen | Code |
|-----------|--------|------|
| `01_Welcome.png` | Welcome | `lib/features/auth/presentation/welcome_screen.dart` |
| `02_Login.png` | Login (Register uses the same style) | `lib/features/auth/presentation/` |
| `03_Dashboard.png` | Home – "What should I do now?" | `lib/features/home/` |
| `04_Tasks.png` | Tasks list | `lib/features/tasks/` |
| `05_Add_Task.png` | Add / edit task | `lib/features/tasks/` |
| `06_Schedule.png` | Calendar / schedule | `lib/features/schedule/` |
| `07_Add_Event.png` | Add / edit event | `lib/features/events/` |
| `08_Recommendation.png` | Recommendation details | `lib/features/recommendation/` |
| `09_Notifications.png` | Notifications | `lib/features/notifications/` |
| `10_Profile.png` | Profile and settings | `lib/features/settings/` |

## Design tokens

Colours live in `lib/core/theme/app_colors.dart` and component styles in
`lib/core/theme/app_theme.dart` (Outfit font, pill buttons and inputs, soft
rounded cards). Reuse `SoftCard`, `IconBox`, `AppLogo` and `PageHeader` from
`lib/core/widgets/` instead of styling screens by hand.
