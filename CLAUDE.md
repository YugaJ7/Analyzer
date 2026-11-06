# Analyzer: Claude working rules

Flutter habit tracker: GetX, Firebase Auth + Firestore, Hive cache, Android home-screen widget.
Layers: `lib/core`, `lib/data`, `lib/domain`, `lib/presentation`.

## Workflow
- Audit fixes live on `fix/audit-security-and-stability`, never `main`.
- Fix one issue at a time. Never batch unrelated fixes.
- Never commit. After each fix, hand over:
  1. a short summary of what changed and why
  2. a Conventional Commit message (`type(scope): subject` + concise body)
  3. the exact `git add` paths for that fix only
- Wait for the user to review and commit before starting the next fix.
- Never stage `pubspec.lock` or the generated plugin registrants (`linux/`, `macos/`, `windows/`) unless the fix needs them.
- Revert side effects of tooling (e.g. Flutter migrator edits to `android/gradle.properties`).

## Code standard
- Production quality: match the surrounding style; no drive-by refactors.
- Verify before handing over: `flutter analyze` clean, `flutter test` green.
- Add or extend tests for any new behaviour.
- The codebase is fully `dart format`ted; run it on every file you touch.
- Lints are strict (`analysis_options.yaml`): no `dynamic` leaks, no un-awaited
  futures (wrap fire-and-forget navigation in `unawaited`).

## Comments
- Short and crisp, senior-dev level. Explain *why*, never restate *what*.
- One line by default; a short `///` doc on public APIs only when the contract isn't obvious.
- No emoji, banners, step numbering, or commented-out code.

## Security
- Never log tokens, emails, raw provider messages, or habit payloads. Debug logs go through `kDebugMode` and contain codes/types only.
- All user-scoped local state goes through `UserSessionStorage`.

## Pending
- **Firestore rules must be deployed** (`firebase deploy --only firestore:rules`). Test rules expire
  2026-11-01. Any new Firestore field must also be added to the matching `hasOnly([...])` list in
  `firestore.rules`, or writes will be denied.
