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
