Engineering Notes:
This document covers the "How it was built" side of the app: architecture, module breakdown,
where AI was used vs where I wrote things by hand, and the trade-offs I made. `ThoughtProcess.md` covers
why the app does what it does.
## 1. Architecture: MVVM + Swiftui
    I went with MVVM because its the natural fit for swiftUI and doesn't fight the framework. 

## 3. Directory Layout

```
ActivityForecast/
├── ActivityForecast/
│   ├── Models/
│   │   ├── DayActivityRating.swift          // Per-day score/rating model for each activity
│   │   ├── LocationForecastResponse.swift   // Decodable model for Open-Meteo forecast response
│   │   └── LocationSearchResponse.swift     // Decodable model for Open-Meteo geocoding/search response
│   ├── Networking/
│   │   ├── NetworkError.swift               // Typed error cases for network/decoding failures
│   │   ├── NetworkService.swift             // URLSession-based service layer for API calls
│   │   ├── StatusCode.swift                 // HTTP status code helpers
│   │   ├── URI.swift                        // Endpoint URI construction
│   │   └── UrlComponents.swift              // Query parameter / URLComponents helpers
│   ├── Utilities/
│   │   ├── ActivityRating.swift             // Scoring logic mapping weather data to activity suitability
│   │   └── ProjectConstants.swift           // Shared constants (API base URL, thresholds, etc.)
│   ├── Views/
│   │   └── SearchPlacesView/
│   │       ├── SearchPlacesView.swift               // Location search screen with debounced input
│   │       └── SearchPlacesView+LocationItemView.swift  // Row view for a single search result
│   ├── ActivityForecastApp.swift            // @main app entry point
│   └── Assets.xcassets
├── AGENTS.md              // Notes/instructions for AI coding agents working on this repo
├── ENGINEERING.md         // Engineering/architecture decisions
├── IMPLEMENTATION.md      // Implementation details and approach
├── REQUIREMENTS.md        // Take-home exercise requirements
└── THOUGHT_PROCESS.md     // Design & trade-off reasoning
```
