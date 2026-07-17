# Impact Map
**Project**: PharmacyChainsManagement (UC30, UC31 - Reactivate & Soft Delete Business Admin)
**Report generated from**: Plan ✓, Diffs ✓, Tests ✓
**Date**: July 18, 2026

---

## 🆕 New Features

### Reactivate Business Admin Account
- **What it does**: Allows system administrators to restore a previously deactivated or soft-deleted business admin account back to active status.
- **Data involved**: Updates the account's status flag in the database and generates an audit log entry.
- **Test status**: ✅ PASS (Backend tested successfully on LocalDB).

### Soft Delete Business Admin Account
- **What it does**: Removes a business admin account from standard lists without permanently destroying the database record. It securely flags the account as deleted and hides it globally across the application.
- **Data involved**: Sets a hidden deletion flag and updates the audit log without data loss.
- **Test status**: ✅ PASS (Backend tested successfully on LocalDB).

---

## ✏️ Modified Features

### Business Admin List View (Mobile UI)
- **Before**: Simple list with a static deactivate button.
- **After**: Includes a dynamic tab filter (All, Active, Deactivated) at the top. Incorporates a fast swipe gesture: swipe left to soft-delete, swipe right to reactivate. Includes an immediate "Undo" notification (Snackbar) that gives users 3 seconds to cancel accidental swipes before the action is finalized. The UI updates instantly without waiting for the server.
- **Reason for change**: To drastically improve system usability, reduce accidental deletions, and ensure the mobile app feels instantly responsive (zero latency).
- **Impact on other features**: Dramatically improves the manager's workflow when processing large lists of users.
- **Test status**: ⚠️ No test data provided (UI testing scripts generated but blocked by local sandbox environment constraints).

### Database Data Access Layer
- **Before**: Standard data retrieval with no built-in deletion protection.
- **After**: Implements an automatic data filter and an interception mechanism. Any delete command is silently intercepted and converted into a "soft delete" update.
- **Reason for change**: Prevents developers from accidentally deleting critical data permanently or forgetting to filter out deleted records in future queries. 
- **Impact on other features**: Strengthens data integrity and security platform-wide.
- **Test status**: ✅ PASS

---

## 🔒 Unchanged Features (Regression Status)

| Feature | Status |
|---|---|
| Admin Authentication | ✅ Regression PASS |
| Deactivate Admin (UC29) | ✅ Regression PASS |
