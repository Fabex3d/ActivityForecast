# Build Instructions: Weather Activity Suitability App

## 0. Read This First — Ground Rules for the Agent

This is an **existing project**, not a greenfield build. Before writing any code:

1. **Explore the repo.** Locate and open the existing:
   - Network layer (API client, endpoints, request builders)
   - Response models (geocoding results, 7-day forecast models)
   - Scoring/ranking system (whatever computes activity suitability from weather data)
   - `SearchPlacesView` and its ViewModel (search-as-you-type location picker)
2. **Do not reimplement or duplicate** any of the above. Your job is to build the missing
   Views and ViewModels that consume these existing pieces.
3. **Check the design files** provided in this Claude Code project (Figma/design exports,
   e.g. `ActivityForecast.dc.html` and any sibling design files). Match spacing, typography,
   color tokens, and component shapes to those designs as closely as SwiftUI allows. If a design
   token system already exists in the project (colors, fonts, spacing constants), use it —
   don't invent a parallel one.
4. **If something referenced below doesn't exist yet** (e.g. no scoring output model), stop
   and summarize what you found vs. what's missing before proceeding, rather than guessing
   at an API shape.
5. Ask yourself before every file you write: *"Does this already exist somewhere in the
   project?"* If yes, import/reuse it.

---

## 1. App Summary (context for the agent)

**What it is:** A weather planning app. User searches a city, picks a location, and the app
shows a 7-day forecast translated into a suitability ranking (not raw numbers) for four
activities: **Skiing, Surfing, Indoor Sightseeing, Outdoor Sightseeing**.

**Who it's for:** Travelers deciding whether to pack for sightseeing or indoor backup plans,
outdoor enthusiasts (skiers/surfers) checking if a destination is worth the trip, and casual
users who want a quick "good week for X?" answer without parsing raw weather data.

**Core flow:**
1. User types a city name → `SearchPlacesView` (existing) queries Open-Meteo Geocoding API →
   shows list of matching places.
2. User selects a place → app has lat/lon.
3. App calls the existing network layer to fetch 7-day forecast (Open-Meteo Forecast API) for
   that lat/lon.
4. Existing scoring system converts each day's weather into a suitability score/rank per
   activity.
5. App displays this as a clear, scannable result: per-day, per-activity suitability —
   not raw temperature/wind/wave tables.

---

## 2. Screens / Components to Build

### 2.1 App Root
- `NavigationStack`-based root (iOS 17+, no `NavigationView`).
- Root shows `SearchPlacesView` (existing) as the initial screen.
- On place selection, push `ForecastView` with the selected place (pass via
  `navigationDestination(for:)` using a typed value — the existing place/location model —
  not stringly-typed identifiers).

### 2.2 `ForecastViewModel`
Responsibilities only — no view logic, no formatting decisions that belong in the view:
- Accept a selected location (lat/lon + display name) via initializer (dependency injection,
  not a shared singleton).
- Call the existing network layer to fetch the 7-day forecast for that location.
- Feed the raw forecast response into the existing scoring engine to get per-day,
  per-activity scores.
- Expose a single `enum ViewState { case loading, loaded([DayActivityForecast]), error(String) }`
  (name it to match whatever output model the scoring system already returns) as the one
  source of truth the view reads.
- Handle cancellation: if the user navigates back before the fetch completes, cancel the
  in-flight `Task`. Reuse the same `Task`-cancellation pattern already used in the search
  debounce, for consistency.
- Use `@Observable` (iOS 17 Observation framework) — **not** `ObservableObject` / `@Published`.
- Mark all mutable properties `private(set)` where the view only needs to read them. Only the
  ViewModel itself should mutate its own state.

### 2.3 `ForecastView`
- Top: location header (city, region/country from the geocoding result).
- Activity selector: segmented control or custom pill tabs for
  Ski / Surf / Indoor Sightseeing / Outdoor Sightseeing. Selection is `@State private var
  selectedActivity` local to this view (UI-only state stays in the View, not the ViewModel).
- Body: 7-day list/row for the currently selected activity, each row showing:
  - Day/date
  - Suitability tier (e.g. Great / Good / Fair / Poor) with a color + icon, not a raw number
  - One-line plain-English reason (e.g. "Strong offshore wind, clean swell")
- Handle all three `ViewState` cases explicitly (loading spinner, error view with retry,
  loaded list). No silent failure states.

### 2.4 Reusable Subviews (keep every view small and single-purpose)
Break the screen down — do not build one large `body`. At minimum extract:
- `LocationHeaderView` — name/region display
- `ActivityPickerView` — the 4-way selector, takes a binding
- `DayForecastRowView` — one day's suitability tier + reason for the selected activity
- `SuitabilityBadgeView` — colored pill/icon for Great/Good/Fair/Poor, reusable across rows
- `ForecastLoadingView`, `ForecastErrorView` — dedicated small views, not inline conditionals
  buried in the main view body

Each subview should take only the plain data it needs (e.g. a single day's score + activity),
never the whole ViewModel. This keeps them previewable and testable in isolation.

### 2.5 Empty/Edge States
- No results from search: handled by existing `SearchPlacesView` — confirm it already covers
  this; if not, flag it rather than modifying that view's contract silently.
- Forecast fetch fails (no network, API error): `ForecastErrorView` with a retry button that
  re-triggers the ViewModel's fetch.
- Location has incomplete data for an activity (e.g. no wave data for an inland city): scoring
  system should already flag this — surface it as "Not applicable" rather than a low score,
  if that distinction exists upstream. If it doesn't exist upstream, do not invent a fake score.

---

## 3. Architecture & Code Quality Rules

### State Management
- Use `@Observable` macro on ViewModels (iOS 17+). Do not mix in `ObservableObject`.
- ViewModels own business/data state. Views own only transient UI state (selected tab,
  sheet presentation, animation flags) via `@State`.
- Keep ViewModel properties `private(set)` unless the view genuinely needs to mutate them
  directly (rare — prefer methods like `viewModel.retry()` over exposing setters).
- No force unwraps (`!`), no force-try. Handle optionals and errors explicitly.
- Dependency-inject the network/scoring services into ViewModels via initializer parameters
  (protocol-typed, not concrete types) so they remain mockable/testable. Do not reach for
  singletons inside a ViewModel.

### View Composition
- No view's `body` should exceed roughly 30–40 lines. If it does, extract a subview.
- Prefer separate `struct` subviews over computed `@ViewBuilder var` properties on the same
  view — real subviews are independently previewable and reusable.
- Every non-trivial subview gets a `#Preview` with representative mock data (including at
  least one edge case: long place name, "Poor" rating, error state).
- Use existing design tokens (colors/fonts/spacing) from the project if present; otherwise
  define them once in a shared location, not inline per-view.
- Respect Dynamic Type and support Dark Mode — don't hardcode fixed frame sizes for text
  containers.

### Data Flow
- One-directional: View reads ViewModel state → View sends user intents (`.onSelect`,
  `.retry()`) to ViewModel → ViewModel updates state → View re-renders.
- Views never call the network layer or scoring engine directly — always through the
  ViewModel.
- Navigation payload between `SearchPlacesView` and `ForecastView` should be the existing
  place/location model, passed by value.

### Concurrency
- All network calls via `async/await`, launched in `Task { }` owned by the ViewModel, stored
  so it can be cancelled on `.onDisappear` or when a new search supersedes it — mirror
  whatever pattern the existing search debounce already uses for consistency.

---

## 4. Suggested Build Order

1. Confirm and read existing network layer, models, scoring engine, and `SearchPlacesView`.
   Write a one-paragraph summary of each before touching new code.
2. Build `ForecastViewModel` (no UI yet) — wire it to existing network + scoring code, verify
   with a quick print/log or unit test that a real lat/lon produces scored output.
3. Build the small reusable subviews first (`SuitabilityBadgeView`, `DayForecastRowView`)
   with static preview data — no ViewModel dependency yet.
4. Assemble `ForecastView` from those subviews, wired to `ForecastViewModel`.
5. Wire navigation: `SearchPlacesView` → place selected → `ForecastView`.
6. Add loading/error/empty states.
7. Pass over accessibility (VoiceOver labels on badges/icons, Dynamic Type check) and Dark
   Mode.
8. Compare against the design files screen-by-screen and adjust spacing/typography/color.

## 5. Definition of Done
- Builds and runs on iOS 17+ simulator with no force-unwraps or warnings.
- Every new View has a `#Preview`.
- No View directly touches networking or scoring code.
- ViewModels use `@Observable`, expose a single explicit state enum, and are cancellable.
- Matches the provided design files for the forecast screen.
