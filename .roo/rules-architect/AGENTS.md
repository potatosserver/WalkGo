# Project Architecture Rules (Non-Obvious Only)
- **Isolate Coupling**: The UI isolate and Background isolate are loosely coupled via an event-based system (`service.invoke`/`service.on`). Any new feature requiring background processing must define events for both directions.
- **State Synchronization**: Since state is not shared, `SharedPreferences` acts as the single source of truth for persistent settings, but requires explicit `reload()` calls in the background isolate to maintain consistency.
- **Health Integration Boundary**: `HealthService` acts as a bridge, but the actual `Health` SDK interaction is intentionally ephemeral (instantiated per-call) to avoid memory/context leaks across isolates.
- **L10n Flow**: Localization data flows one-way (UI $\rightarrow$ Background) via event maps, ensuring the background service remains independent of the Flutter UI framework.
