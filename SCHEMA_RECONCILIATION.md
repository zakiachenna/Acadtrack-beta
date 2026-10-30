# AcadTrack — Phase 2 Schema Reconciliation

Status: DRAFT — NOT APPROVED FOR IMPLEMENTATION

Date: 3 October 2026

## Purpose

This document records the schema differences identified during review of:

- `BLUEPRINT.md`
- `supabase/migrations/202609200001_phase1_identity_tenancy.sql`

The migration has NOT been applied to Supabase.

This document is for review and reconciliation only. It does not authorize database changes.

## Confirmed context

- `BLUEPRINT.md` is the documented platform architecture reference.
- The current migration was added in commit `88abe6b`.
- `BLUEPRINT.md` was not updated when the migration was added.
- Confirmed differences exist in `profiles`, `students`, and `teachers`.
- RLS is enabled on 10 tables in the migration.
- No `CREATE POLICY` statements are included in this migration.
- The migration remains NOT APPLIED and NOT TESTED.
- Clarification has been requested from the original developer.

## Reconciliation review

### profiles

BLUEPRINT:
- `first_name`
- `last_name`
- `display_name`
- `email`
- `phone`
- `avatar_url`
- `locale`
- `status`

Current migration:
- `full_name`
- `email`
- `phone`
- `avatar_url`
- `locale`
- `is_active`
- `created_at`
- `updated_at`

Current decision:
- `first_name` / `last_name` / `display_name` versus `full_name`: UNRESOLVED.
- `status` versus `is_active`: UNRESOLVED.
- `created_at` and `updated_at`: retain as implementation details unless later evidence shows a conflict.

### students

BLUEPRINT:
- `profile_id`
- `student_number`
- `specialty_id`
- `group_id`
- `enrollment_year`
- status: `active | repeating | suspended | graduated`

Current migration:
- `user_id` referencing `profiles(id)`
- `student_number`
- `group_id`
- `enrolled_at`
- `status` with default `active`

Current decision:
- `profile_id` instead of `user_id`: reconciliation candidate; not yet implemented.
- `specialty_id`: reconciliation candidate; not yet implemented.
- constrained student status values: reconciliation candidate; not yet implemented.
- `enrollment_year` versus `enrolled_at`: UNRESOLVED.

### teachers

BLUEPRINT:
- `profile_id`
- `grade/title`
- `department_id`
- `hire_date`

Current migration:
- `user_id` referencing `profiles(id)`
- `employee_number`
- `department_id`
- `title`
- `status`

Current decision:
- `profile_id` instead of `user_id`: reconciliation candidate; not yet implemented.
- `hire_date`: reconciliation candidate; not yet implemented.
- `grade/title` versus `title`: UNRESOLVED.
- `employee_number`: UNRESOLVED.
- `status`: UNRESOLVED.

## Safety rule

No unresolved schema decision will be implemented by assumption.

Before the migration is applied:

1. Resolve or explicitly approve remaining schema decisions.
2. Review the complete migration.
3. Test using the Supabase development environment and dummy data only.
4. Perform the relevant security/RLS checks.
5. Create a recoverable GitHub checkpoint and document the result.

## Current status

🟡 PHASE 2 — SCHEMA RECONCILIATION IN PROGRESS

No database changes have been made as part of this reconciliation.

## Original Prototype Code Evidence — 23 October 2026

Source reviewed: `student-profile.html` (existing prototype).

### Confirmed observations

- The prototype uses separate JavaScript fields `firstName` and `lastName` for student profile data.
- Other observed student fields include `id`, `email`, `phone`, `group`, `major`, and `academicYear`.
- The page uses a `defaultStudentProfile` object and browser `localStorage` for prototype data.
- The existing prototype includes a local student-record update function named `updateStudentDatabaseRecord()`.
- The prototype uses Base64 encoding/decoding (`btoa()` / `atob()`) for a demonstration password mechanism; this is not secure authentication.
- The prototype includes a demonstration session fallback. Neither this fallback nor the password mechanism should be carried into the real Pilot authentication implementation.

### Schema reconciliation implication

- Existing code evidence supports considering separate `first_name` and `last_name` database fields, consistent with `BLUEPRINT.md`, rather than assuming the migration's single `full_name` field is final.
- JavaScript field names are not automatically database column names. Compatibility with other prototype pages remains to be reviewed.
- This is evidence and a preliminary recommendation only, NOT approval to modify the migration or apply it to Supabase.

Status: REVIEW EVIDENCE ONLY — SCHEMA DECISION STILL PENDING.

## Department Admin Users Prototype Evidence — 23 October 2026

Source reviewed: `dept-admin-users.html` (existing prototype).

### Confirmed observations

- The page contains student and teacher user tables.
- Student names are displayed as complete names directly in HTML table cells.
- Searches for the exact identifiers `firstName`, `first_name`, `lastName`, and `fullName` returned zero matches in this file.
- The page also contains references to `name` and `studentName`.
- The observed name display does not establish how names must be stored in the database.

### Schema reconciliation implication

- `student-profile.html` uses separate `firstName` and `lastName` JavaScript fields, while `dept-admin-users.html` displays complete names in its HTML tables.
- These observations reflect different prototype representations and do not establish a database schema requirement.
- The choice between separate `first_name` / `last_name` columns and the migration's `full_name` column remains pending.
- No migration changes or Supabase operations are authorized by this evidence.

Status: REVIEW EVIDENCE ONLY — SCHEMA DECISION STILL PENDING.

## Preliminary Schema Decisions — 30 October 2026

Status: OWNER-APPROVED PRELIMINARY DESIGN DECISIONS — NOT APPROVED FOR IMPLEMENTATION.

### P2-001 — Profile name fields

- Preliminary decision: Prefer separate `first_name` and `last_name` fields, consistent with `BLUEPRINT.md`.
- Prototype evidence: `student-profile.html` uses separate `firstName` and `lastName` values and combines them for display.
- `assets/js/app.js` uses a combined `name` value for demo users.
- Searches for `display_name` in `student-profile.html`, `assets/js/app.js`, and `dept-admin-users.html` returned zero matches.
- `display_name` remains a proposed Blueprint field. Its purpose, required/optional status, and population rules are unresolved.
- The migration's existing `full_name` field remains unchanged.
- Compatibility review and final implementation approval remain pending.

### P2-002 — Profile account status

- Preliminary decision: Retain `profiles.status` from `BLUEPRINT.md` as the design reference.
- The existing migration uses `profiles.is_active` (boolean).
- `dept-admin-users.html` displays `Active` badges, but this does not establish a database field mapping.
- `BLUEPRINT.md` does not define the allowed values of `profiles.status`.
- The `students.status` values (`active`, `repeating`, `suspended`, `graduated`) describe academic student status and must not be assumed to define account status.
- Allowed account-status values, behavior, and security implications remain unresolved.
- The migration's `is_active` field remains unchanged.

### Implementation restriction

Both decisions are preliminary and reversible. No migration edits, SQL execution, Supabase schema changes, or deployment are authorized by this documentation. Phase 2 schema reconciliation remains in progress.
  
