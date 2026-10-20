# Expense Tracker: local-first MVP architecture

Android and iOS are the initial targets. SQLite is the source of truth, not a
temporary cache. A premium subscription will add replication and collaboration;
it will not require rewriting the UI to read a remote database.

## Deliverable and scope

The local MVP now includes:

1. Profile creation/selection, with USD/EUR/GBP currencies and eight starter
   categories per profile. Currency is fixed after creation. The active selection
   is session-local; startup selects the first profile.
2. Income/expense creation, editing by tapping a transaction, confirmed deletion,
   optional notes, category selection, and date selection.
3. A reactive monthly dashboard with income, expenses, net income, month
   navigation, explicit errors/retry, and profile-isolated transaction lists.
4. An editable monthly Needs/Wants/Savings split (50/30/20 initially), expense
   category mappings, progress bars, overspending amounts, unallocated expenses,
   and a savings target. There is no bank balance or savings-transfer tracking.
5. Atomic budget storage, revisions/tombstones, and a development-only sync
   interface/mock preview.
6. Permanent profile deletion with an exact `DELETE` confirmation and atomic
   removal of that profile's transactions, categories, and budgets.
7. Per-profile category management: create, edit, archive/remove, predefined
   Material icons, and a curated color palette. Expense categories have a
   Needs/Wants default used only when setting up future budgets.

Next milestones are backup/export and restore, pagination and date-indexed
reporting for large histories, on-device lifecycle testing, and production-safe
migration testing. Real cloud sync, authentication, subscriptions,
tenant memberships, shared editing, OCR, bank integrations, transfers, and
multi-currency conversion are not implemented.

## Interface theme

The app follows the device's light/dark preference using the shared themes in
`lib/app/theme/app_theme.dart`. Palette tokens live in
`lib/app/theme/app_colors.dart`; widgets should use `Theme.of(context).colorScheme`
and `textTheme` rather than hardcoded colors. Income, expense, and information
foreground/container pairs are available through the `AppSemanticColors` theme
extension. Use those pairs for readable semantic labels; the brighter raw palette
tokens are decorative accents, not body-text colors.

The Stitch palette uses cream/white light surfaces and espresso dark surfaces,
with orange primary actions and coral secondary accents. Accessibility deviations
from the guide are intentional: orange buttons use warm charcoal text rather than
white, light secondary text and hints are darker, and semantic labels and focus
outlines use stronger foregrounds. Cards and dialogs use 24dp corners, sheets
32dp top corners, inputs 20dp corners, and primary buttons a 54dp minimum height.

Nunito is bundled locally in `assets/fonts` so typography never needs a network
request. Its SIL Open Font License is included beside the font. This foundation
does not change profile storage, navigation, or the existing screen layouts.

## Technology decisions

| Concern | Choice | Rationale |
| --- | --- | --- |
| State and dependency injection | `flutter_riverpod` | Typed providers, scoped overrides for tests, asynchronous streams, no extra DI container. Use Notifiers for future form/actions state. Bloc is also viable for a team preferring explicit event/state contracts, but do not mix both by default. |
| Local SQL | `drift` + `drift_flutter` | SQLite with generated types, reactive queries, transactions, and migration tooling. Prefer it to manually mapping `sqflite` results as the relational model grows. |
| IDs | `uuid` v7 | Generate time-ordered, globally unique IDs on-device before persistence; no dependency on server-generated IDs. |
| Charts | Flutter progress indicators | Sufficient for current budget progress; `fl_chart` remains available for future trend/ring charts. |
| Formatting | `intl` | Locale-aware grouping and dates; integer arithmetic preserves currency fractions without converting money to doubles. Input currently uses a dot decimal separator and rejects grouping separators. |
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
    money/
      decimal_input.dart            # Exact decimal -> scaled integer parsing
      money_format.dart             # Currency display without losing cents
  features/
    profiles/
      domain/profile.dart           # Profile/category models and repository
      data/local_profile_repository.dart
      presentation/profile_dialog.dart
      category_editor_dialog.dart
      category_manager_dialog.dart
    transactions/
      domain/
        entities/financial_transaction.dart
        repositories/transaction_repository.dart
      data/
        repositories/local_transaction_repository.dart
      presentation/
        providers/transaction_providers.dart
        transaction_dialog.dart
    budgets/
      domain/
        budget_calculator.dart
        entities/budget_rule.dart
        repositories/budget_repository.dart
      data/local_budget_repository.dart
      presentation/budget_dialog.dart
    sync/
      domain/sync_repository.dart
      data/mock_cloud_sync_service.dart
    dashboard/
      presentation/
        dashboard_page.dart
test/
  core/database/schema_test.dart
  core/money/decimal_input_test.dart
  features/
    transactions/data/local_transaction_repository_test.dart
    budgets/domain/budget_rule_test.dart
    budgets/domain/budget_calculator_test.dart
    budgets/data/local_budget_repository_test.dart
    sync/mock_cloud_sync_service_test.dart
  widget_test.dart
```

Create additional feature layers when they have real code; avoid empty folders
or a pass-through use-case class for every repository method. Add domain use cases
for actual workflows when they grow beyond one repository operation. Profile
creation and starter category seeding are one atomic repository operation.
Budget saves update the parent, bucket matrix, and category mappings atomically;
removed children are tombstoned rather than physically deleted.

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
- Reporting periods are half-open `[start, end)`. The dashboard builds calendar
  month boundaries in the device's local timezone, then converts to UTC. Stored
  budgets retain their original UTC bounds; cross-timezone travel may require
  creating a different period, and overlapping periods are rejected. A fixed
  per-profile reporting timezone is a future extension.

### Tables

All finance tables carry `profile_id`. Composite foreign keys prevent references
to another profile, including budget category mappings. Foreign keys are enabled
when each connection opens. Local profile isolation is not authentication or
encryption.

| Table | Key | Purpose |
| --- | --- | --- |
| `profiles` | `profile_id` | Local financial workspace, name, currency, scale. A profile is not a login identity. |
| `categories` | `(profile_id, category_id)` | User-defined income/expense classifications, presentation metadata, default budget bucket, and archive state. |
| `transactions` | `(profile_id, transaction_id)` | Optional notes, positive amount, type, category, occurrence timestamp. Category type must match transaction type. Indexed by profile/date. |
| `budgets` | `(profile_id, budget_id)` | Named rule for a bounded reporting period. |
| `budget_buckets` | `(profile_id, budget_id, bucket_id)` | Arbitrary user-defined labels and allocation percentages. |
| `budget_category_allocations` | `(profile_id, budget_id, category_id)` | Assigns a category to exactly one bucket per budget; different budgets can classify it differently. |

The relational budget matrix is preferable to hardcoding Needs/Wants/Savings
columns or storing the entire rule as opaque JSON. It permits custom bucket names,
counts, and efficient joins for actual spending. Percentages use basis points:
5000/3000/2000 represents 50/30/20, and 6525 represents 65.25%.

`BudgetRule` enforces that a complete rule totals exactly 10000 basis points,
has unique buckets and category assignments, and has a valid period. The
budget repository saves the parent, buckets, and mappings in one transaction,
and reconstructs through that validator on read. SQL constrains individual rows;
it intentionally does **not** enforce a cross-row 100% total. Raw writes bypassing
the domain must not be used for application budget operations.

Budget targets use actual income in the selected period and expense-category
mappings. Overlapping active rules in one profile are rejected. There is no
rollover. Zero income means zero limits, not division by zero; spending beyond
zero is explicitly over budget. Largest-remainder rounding distributes every
minor unit exactly, with ties broken by bucket ID. Intermediate percentage
multiplication uses BigInt to avoid overflow. The dashboard shows exact monthly
rules; non-monthly rules remain supported by the repository/calculator but do
not get implicitly applied to a different dashboard period.
Aggregate totals outside the supported signed 64-bit range are explicitly
reported instead of wrapping; entries remain editable so the user can correct
the data.

The current editor exposes Needs/Wants/Savings with user-defined percentages and
Needs/Wants/unassigned mappings. The domain/database remain flexible enough for
arbitrary buckets. Savings is an allocation target, not automatically an expense. True savings
account transfers require an accounts/transfer model and must not be counted as
spending or new income.

Transaction notes are optional and do not affect financial calculations. Category
names, icons, and colors are editable; those changes also change how historical
transactions are displayed because records reference the category. Removing a
category with transaction or budget references archives it to preserve history.
An unused category can be permanently removed. A category cannot switch between
income and expense while transactions or budget mappings reference it. Changing
an expense category's Needs/Wants default affects new budget mappings only;
existing budget rules keep their saved assignments. Icons are selected from a
predefined Material icon set; user-uploaded icons are not supported.

### Change metadata

Generated profile, transaction, and budget IDs use standard UUIDv7 strings.
Their leading timestamp bytes make lexicographic ordering approximately
chronological across different generation milliseconds. The random portion
means UUIDv7 IDs produced within the same millisecond are not guaranteed to
reflect strict generation order. IDs are opaque keys, not authoritative event
timestamps; sort transactions and audit events by their explicit time fields.
Existing UUIDv4 IDs remain valid and unchanged: IDs are not regenerated on
startup, and this switch needs no schema migration.

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

### Sync preview contract

`SyncRepository` exposes `uploadUnsyncedTransactions(profileId:)` and
`downloadRemoteChanges(profileId:, cursor:)`. `MockCloudSyncService` implements
both **for development previews only**, and is deliberately not wired into
production providers or the dashboard:

- Upload reads profile-scoped `is_synced = 0` rows, including tombstones, into
  an ephemeral in-memory remote simulation.
- Download returns profile-scoped delta previews and a mock cursor. Cursors from
  another profile and malformed/out-of-range cursors are rejected.
- Divergent same-ID records are returned as explicit conflicts; client
  `updated_at` is not considered authority. There is no automatic LWW.
- Every result is labeled `isPreview = true`. The mock never sets `is_synced = 1`,
  applies remote records to SQLite, or calls a network service. Losing/recreating
  the mock loses its remote data/cursors. A preview cursor is not a durable
  acknowledgment or production sync protocol.

The production implementation still needs dependency replication (profiles and
categories before transactions), outbox/server concurrency controls, durable
cursor storage, entitlement checks, and conflict-resolution UX. Do not expose
the mock as a working Pro sync feature or ship dummy authentication returning success.
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

Regenerate bindings after changing the schema. Schema version 2 currently uses
Drift's destructive fallback to drop and recreate the database on upgrade. This
is an intentional pre-release reset because there are no consumer data or
compatibility commitments yet; existing local data is permanently lost on such
an upgrade. Before any public release, replace this with non-destructive
migrations, export schema snapshots using Drift's migration tooling, and test
upgrades from every supported released version. Never use destructive fallback
to resolve migrations after release.

Tests cover profile isolation, cross-profile foreign-key rejection, exact money
storage, category CRUD/archive/type enforcement, notes, reactive updates, revision/dirty tracking,
tombstones, atomic budget operations, percentages/category uniqueness, budget
math/rounding/boundaries, sync previews/conflicts, profile switching, and UI
creation/entry flows. A file-backed SQLite test verifies close/reopen persistence.
Host SQLite tests do not replace Android/iOS on-device persistence tests,
OS lifecycle testing, backups, or future migration tests. The native opener also
supports desktop, but desktop is not an MVP commitment. Web needs a separate
WASM/worker and browser-persistence setup; do not advertise web support yet.

## Roadmap ideas

- Local/free: recurring-entry templates, CSV export/import with validation,
  search, budget reminders, and accessibility.
- Premium: encrypted cloud backup/sync, shared household workspaces with roles,
  audit history, multiple budget scenarios, and richer trend reports.
- Later: accounts and transfers, savings goals, receipt attachments with explicit
  upload consent, multi-currency with dated exchange rates, and bank connections.

Prioritize trustworthy balances, recoverable storage, and tested sync semantics
before adding automated financial recommendations.
