# Expense Tracker: local-first MVP architecture

Android and iOS are the initial targets. SQLite is the source of truth, not a
temporary cache. A premium subscription will add replication and collaboration;
it will not require rewriting the UI to read a remote database.

## Deliverable and scope

This is a compiling architecture scaffold, not a finished expense tracker.
Included: the mobile database opener, version-one relational schema, transaction
repository implementation and reactive provider, budget domain validation,
dependency composition, a clearly labeled placeholder screen, and automated tests.

Next MVP milestones:

1. Profile creation/selection, currency selection, and category management.
2. Income/expense entry, edit/delete, lists, date filters, and validation feedback.
3. Dashboard totals and category charts, derived from local transaction streams.
4. Atomic budget persistence, custom bucket/category editor, and actual-vs-target UI.
5. Backup/export and restore, plus on-device persistence and migration testing.

Cloud sync, authentication, subscriptions, tenant memberships, shared editing,
bank integrations, transfers, and multi-currency conversion are not implemented.

## Technology decisions

| Concern | Choice | Rationale |
| --- | --- | --- |
| State and dependency injection | `flutter_riverpod` | Typed providers, scoped overrides for tests, asynchronous streams, no extra DI container. Use Notifiers for future form/actions state. Bloc is also viable for a team preferring explicit event/state contracts, but do not mix both by default. |
| Local SQL | `drift` + `drift_flutter` | SQLite with generated types, reactive queries, transactions, and migration tooling. Prefer it to manually mapping `sqflite` results as the relational model grows. |
| IDs | `uuid` | Generate UUID v4 on-device before persistence; no dependency on server-generated IDs. |
| Charts | `fl_chart` | Planned dashboard visualizations; not used by the placeholder yet. |
| Formatting | `intl` | Planned locale-aware currency/date presentation; not a money calculation engine. |
| Code generation | `drift_dev` + `build_runner` | Generate and statically check database bindings. Riverpod uses manual providers, with no generator required. |

Versions were checked against pub.dev when creating the scaffold. The
`build_runner` upper bound avoids version 2.17.1's `build` 5 dependency, which is
incompatible with the current Drift generator's `build <5` constraint.
Keep the application lockfile in source control when initializing Git.

Do not add `sqflite` alongside Drift. The default `drift_flutter` opener manages
native SQLite and storage paths; no direct `path_provider`, `path`, or
`sqlite3_flutter_libs` dependency is needed for this setup. If custom file paths
are later required, add the relevant path dependencies then.

## Folder structure

```text
lib/
  main.dart                         # ProviderScope and startup only
  app/
    expense_tracker_app.dart        # MaterialApp
    providers.dart                  # Composition root: concrete -> abstract
  core/
    database/
      app_database.dart             # Connection and schema lifecycle
      app_database.g.dart           # Generated; never edit manually
      schema.drift                  # Shared relational schema and indexes
  features/
    transactions/
      domain/
        entities/financial_transaction.dart
        repositories/transaction_repository.dart
      data/
        repositories/local_transaction_repository.dart
      presentation/
        providers/transaction_providers.dart
    budgets/
      domain/
        entities/budget_rule.dart
        repositories/budget_repository.dart
    dashboard/
      presentation/
        dashboard_page.dart
test/
  core/database/schema_test.dart
  features/
    transactions/data/local_transaction_repository_test.dart
    budgets/domain/budget_rule_test.dart
  widget_test.dart
```

Create additional feature layers when they have real code; avoid empty folders
or a pass-through use-case class for every repository method. Add domain use cases
for actual workflows, such as applying a budget or creating a profile with its
default categories. The budget repository is deliberately a contract only at this
stage; it has no provider or concrete implementation.

### Dependency direction

```text
Presentation -> Domain <- Data -> SQLite
                    ^
              App composition
```

Domain contains plain Dart, with no Flutter, Riverpod, Drift, or backend imports.
Presentation consumes abstract repositories via providers. Only the composition
root constructs concrete repositories. Database rows and sync flags stay in Data,
not in widgets or financial domain entities. The transaction data repository also
serves as its local data source for now; add a DAO when query reuse warrants one.
The shared database schema sits in Core because foreign keys cross features.

`transactionsProvider(profileId)` is keyed by profile, never an unscoped global
transaction list. UI code must handle its loading/error/data states explicitly.
Repository failures propagate to callers; mutation UIs must catch expected
validation/storage failures and show actionable feedback, not report success.

## Financial and schema contracts

### Money, currency, and time

- `amount_minor` is a positive signed SQLite 64-bit integer. For a currency with
  scale 2, 12345 means 123.45. Income/expense is a separate type, never a sign.
  Never parse or calculate money through `double`.
- Each profile has one currency code and minor-unit scale. Currency pickers must
  validate against supported ISO currencies. Do not change that currency after
  financial records exist; future conversion needs an explicit migration/workflow.
- UTC Unix milliseconds are stored in all timestamp fields. `occurred_at` is
  the financial date/time; `created_at`/`updated_at` are storage metadata.
- Reporting periods are half-open `[start, end)`. Future UI logic must compute
  period boundaries in the user's reporting timezone, then convert to UTC;
  a UTC midnight is not always a local midnight.

### Tables

All finance tables carry `profile_id`. Composite foreign keys prevent references
to another profile, including budget category mappings. Foreign keys are enabled
when each connection opens. Local profile isolation is not authentication or
encryption.

| Table | Key | Purpose |
| --- | --- | --- |
| `profiles` | `profile_id` | Local financial workspace, name, currency, scale. A profile is not a login identity. |
| `categories` | `(profile_id, category_id)` | User-defined income/expense classifications. |
| `transactions` | `(profile_id, transaction_id)` | Title, positive amount, type, category, occurrence timestamp. Category type must match transaction type. Indexed by profile/date. |
| `budgets` | `(profile_id, budget_id)` | Named rule for a bounded reporting period. |
| `budget_buckets` | `(profile_id, budget_id, bucket_id)` | Arbitrary user-defined labels and allocation percentages. |
| `budget_category_allocations` | `(profile_id, budget_id, category_id)` | Assigns a category to exactly one bucket per budget; different budgets can classify it differently. |

The relational budget matrix is preferable to hardcoding Needs/Wants/Savings
columns or storing the entire rule as opaque JSON. It permits custom bucket names,
counts, and efficient joins for actual spending. Percentages use basis points:
5000/3000/2000 represents 50/30/20, and 6525 represents 65.25%.

`BudgetRule` enforces that a complete rule totals exactly 10000 basis points,
has unique buckets and category assignments, and has a valid period. The future
budget repository must save the parent, buckets, and mappings in one transaction,
and reconstruct through that validator on read. SQL constrains individual rows;
it intentionally does **not** enforce a cross-row 100% total. Raw writes bypassing
the domain must not be used for application budget operations.

Initially, budget targets should use actual income in the selected period and
expense-category mappings. Define rollover, overlapping-rule selection, zero
income behavior, and minor-unit remainder allocation before building that UI.
Savings is an allocation target, not automatically an expense. True savings
account transfers require an accounts/transfer model and must not be counted as
spending or new income.

### Change metadata

Each mutable table includes:

- `created_at`, `updated_at`, and nullable `deleted_at` (soft-delete tombstone).
- `local_revision`, incremented on local mutations.
- `is_synced INTEGER CHECK (is_synced IN (0, 1))`, default 0.

`is_synced = 0` means local-only **or pending replication**; it is not a premium
entitlement flag. `1` means the current local revision was acknowledged by a
future server. Transaction edits/deletes reset it to 0, and deletion preserves a
tombstone. An explicit save of a deleted transaction restores it. Queries exclude
deleted transactions. Future category/profile deletion workflows must decide how
to handle active children atomically; SQL foreign keys alone do not cascade
soft deletion.

## Premium evolution: replicate, do not swap away SQLite

Keep `TransactionRepository` and `BudgetRepository` stable. Evolve the local
implementation into a coordinating repository or attach a sync service. Screens
continue watching SQLite whether online or offline.

Before enabling cloud writes, add:

1. **Identity and tenancy:** authenticated users, tenants/workspaces, server-side
   memberships/roles, and an explicit local-profile-to-tenant binding. Never
   assume a client-provided `profile_id` grants access, and do not repurpose
   `profile_id` to mean a user ID. Shared households have multiple users.
2. **Transactional outbox:** record local row mutations and durable operations
   atomically. The current dirty flag is a starting point, not a complete sync
   algorithm.
3. **Idempotent push and incremental pull:** UUID operation IDs, per-tenant
   cursors, server revisions, retries with backoff, and atomic pull application.
   Only mark a row synced if the acknowledged revision still equals its current
   local revision; a concurrent local edit must remain pending.
4. **Conflict handling:** server-version concurrency checks and an explicit
   conflict policy. Do not blindly use client wall-clock last-write-wins for
   financial data. Never merge two amounts by summing them.
5. **Deletion lifecycle:** propagate tombstones, retain them until acknowledged
   by the replication protocol, and then apply a documented retention policy.
6. **Entitlements and account lifecycle:** enforce premium features on the
   backend too. Subscription expiry disables replication, not access to local
   financial records. Handle sign-out, local-data retention, and account binding
   explicitly to avoid uploading one profile into the wrong account.

Do not ship dummy authentication/sync implementations returning success.
SQLite is not encrypted by this scaffold; evaluate encryption, secure key
storage, OS backup behavior, export consent, and financial-data-safe telemetry
before production. Never log transaction titles, amounts, or account identifiers
as generic diagnostic events.

## Development and validation

```powershell
flutter pub get
dart run build_runner build
flutter analyze
flutter test
```

Regenerate bindings after changing the schema. Version 1 is the initial schema;
before releasing a schema change, increment `schemaVersion`, implement a
non-destructive migration, export schema snapshots using Drift's migration
tooling, and test upgrades from every supported released version. Do not delete
the user's database to resolve migrations.

Tests cover profile isolation, cross-profile foreign-key rejection, exact money
storage, category type enforcement, reactive updates, revision/dirty tracking,
tombstones, budget percentages/category uniqueness, and the placeholder screen.
In-memory SQLite tests do not replace on-device reopen/persistence tests,
OS lifecycle testing, backups, or future migration tests. The native opener also
supports desktop, but desktop is not an MVP commitment. Web needs a separate
WASM/worker and browser-persistence setup; do not advertise web support yet.

## Roadmap ideas

- Local/free: recurring-entry templates, CSV export/import with validation,
  search, custom categories, budget reminders, and accessibility.
- Premium: encrypted cloud backup/sync, shared household workspaces with roles,
  audit history, multiple budget scenarios, and richer trend reports.
- Later: accounts and transfers, savings goals, receipt attachments with explicit
  upload consent, multi-currency with dated exchange rates, and bank connections.

Prioritize trustworthy balances, recoverable storage, and tested sync semantics
before adding automated financial recommendations.
