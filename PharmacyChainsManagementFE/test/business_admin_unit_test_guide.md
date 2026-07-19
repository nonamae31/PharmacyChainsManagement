# Business Admin Unit Test Guide

## Scope

Unit tests for the Business Admin flow live in:

`test/features/business_admin/business_admin_bloc_test.dart`

The tests cover the BLoC layer without calling the real backend:

- Load and update Business Admin profile.
- Request forgot password and reset password.
- Load, create, and update branches.
- Create, update, reset password, and delete branch manager accounts.
- Load medicine statistics.
- Load business analysis report.
- Map API failures into `BusinessAdminLoadFailure`.

## Run

From `PharmacyChainsManagementFE`:

```powershell
flutter test test/features/business_admin/business_admin_bloc_test.dart
```

Run all Flutter tests:

```powershell
flutter test
```

If Flutter cannot find Git on Windows, prepend Git to the current shell PATH:

```powershell
$env:Path = 'C:\Program Files\Git\cmd;' + $env:Path
flutter test test/features/business_admin/business_admin_bloc_test.dart
```

## Test Style

- Keep Business Admin tests under `test/features/business_admin/`.
- Do not call Supabase, Cloudinary, Firebase, or the ASP.NET backend in unit tests.
- Use fake API clients or fake DTO data for deterministic BLoC tests.
- Add widget or integration tests separately when a screen needs rendering or browser validation.

## Git Note

The root `.gitignore` currently ignores `/PharmacyChainsManagementFE/test`, so these local test files will not appear in `git status` unless that ignore rule is changed or the files are added with `git add -f`.
