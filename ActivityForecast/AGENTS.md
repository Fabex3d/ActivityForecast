Operating manual for AI agents (Claude Code, etc.) working in this repository. Read this file fully before writing code.
If a rule here conflicts with an instruction in a task, the task wins but call out the conflict explicitly in your response.

## 1. Project Snapshot

| Item | Value |
|---|---|
| Platform | iOS 17.0+ (no back-deployment) |
| UI | SwiftUI only — no UIKit unless wrapping is unavoidable |
| Language | Swift 5.9+ (Swift 6 language mode where enabled) |
| Architecture | MVVM + `@Observable`, protocol-oriented, SOLID |
| Navigation | `NavigationStack` + typed routes + `Router` |
| Concurrency | `async`/`await`, `@MainActor`, structured concurrency |
| Networking | `URLSession` behind a protocol |
| Min deployment reason | `@Observable`, `NavigationStack`, `ContentUnavailableView` |

## 2. Non-Negotiables (the short list)

If you remember nothing else, remember these:

1. **No magic numbers. No magic strings.** Every spacing, padding, corner radius, duration, size,
   opacity, animation, API path, UserDefaults key, notification name, and accessibility identifier
   comes from the design-system / constants layer. See §6.
2. **`@Observable`, never `ObservableObject`.** No `@Published`, `@StateObject`, `@ObservedObject`,
   `@EnvironmentObject` in new code.
3. **`NavigationStack` only.** `NavigationView` and `NavigationLink(isActive:)` are banned.
4. **Views stay small.** A `body` over ~50 lines or a view file over ~150 lines must be decomposed.
5. **Explicit access control on every declaration.** Default to `private`. Widen only when a caller
   proves it needs it.
6. **Depend on protocols, not concrete types.** Every ViewModel dependency is injected through an
   `init` and typed as a protocol.
7. **No force unwrap (`!`), no `try!`, no `as!`, no `fatalError` in shipping paths.**
8. **Build and lint before you claim you're done.**
9. **Write every property and constants explicitely.**

## 3. Architecture — MVVM with `@Observable`

### 3.1 The contract

| Layer | Knows about | Never knows about |
|---|---|---|
| View | ViewModel, DesignSystem | Networking, persistence, `URLSession` |
| ViewModel | Service protocols, Models, Router | SwiftUI views, `UIKit`, concrete services |
| Service | Networking/persistence, Models | ViewModels, Views |
| Model | Nothing (pure value types) | Everything else |

- ViewModels **do not** `import SwiftUI`. Import `Observation` and `Foundation`.
  (If you find yourself needing `Color` or `Image` in a ViewModel, you're leaking presentation —
  return a semantic enum instead and map it in the view.)
- Models are `struct`, `Sendable`, `Equatable`, and `Identifiable` when displayed in lists.

### 4 The constants layer — `ProjectConstants.swift`

`ProjectConstants.swift` is the **single source of truth** for spacing, padding, and corner radius.
It is already written. Do not create parallel constant enums, do not add per-feature spacing
constants, and do not redefine these values anywhere else.

```swift
public enum Spacing {
    public static let large: CGFloat = 24
    public static let standard: CGFloat = 16
    public static let medium: CGFloat = 8
    public static let small: CGFloat = 4
}

public enum CornerRadius {
    public static let large: CGFloat = 24
    public static let standard: CGFloat = 16
    public static let medium: CGFloat = 12
    public static let small: CGFloat = 8
}
```

**Rule 1 — never write a literal.** Every `padding`, `spacing`, `offset`, `inset`, and
`cornerRadius` value references a token above. A bare `16` is a defect even when it happens to equal
`Spacing.standard`.

```swift
// ✅
.padding(Spacing.standard)
VStack(spacing: Spacing.medium) { … }
.clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
.offset(y: -Spacing.small)

// ❌
.padding(16)
VStack(spacing: 8) { … }
.cornerRadius(12)
```

**Rule 2 — if the value you need isn't on the scale, use a whole multiple of a token.** Do not add a
new case, and do not inline the number.

```swift
// ✅ value above the scale
.padding(.top, Spacing.large * 2)        // 48
.frame(height: Spacing.large * 4)        // 96

// ❌
.padding(.top, 48)
.padding(.top, Spacing.large + 24)
```

- Multiples must be whole integers (`* 2`, `* 3`, `* 4`). Never `* 1.5`, never division, never
  addition of two tokens — those produce off-grid values.
- Try the existing tokens first. `Spacing.medium * 2` is wrong; that value is `Spacing.standard`.
  `Spacing.small * 4` is wrong; that value is `Spacing.standard`. Always reach for the exact token
  when one exists, and only use a multiplier when the value genuinely exceeds `large`.
- If SwiftLint's `no_magic_numbers` flags the multiplier, that's a signal the value is unusual —
  raise it rather than silencing the rule.

**Rule 3 — consistent semantic mapping.** The same kind of surface uses the same token everywhere in
the app. Follow this mapping unless a design spec says otherwise:

| Use | Token |
|---|---|
| Screen edge margin | `Spacing.standard` |
| Gap between sections | `Spacing.large` |
| Gap between rows / related items | `Spacing.medium` |
| Gap between an icon and its label, chip insets | `Spacing.small` |
| Card / container inner padding | `Spacing.standard` |
| Buttons, chips, badges, small controls | `CornerRadius.small` |
| Text fields, list rows | `CornerRadius.medium` |
| Cards, tiles | `CornerRadius.standard` |
| Sheets, modals, hero containers | `CornerRadius.large` |

Before choosing a token for a new component, find the nearest existing equivalent in `Features/` and
match it. Two cards with different corner radii is a bug.

**Rule 4 — don't extend the enums casually.** If a genuinely new semantic value is needed (not just a
number), stop and ask rather than adding a case. Every case added here is a permanent app-wide
commitment.