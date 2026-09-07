# ActivityForecast

A native iOS app that uses the [Open-Meteo](https://open-meteo.com/) API to rank the best days over the next 7 days for **skiing**, **surfing**, and **sightseeing** at a location the user searches for.

## Overview

The user searches for a place, the app geocodes it, pulls a 7-day forecast, and scores each day against activity-specific criteria (temperature, precipitation, wind, snowfall, etc.) to surface which days are best suited for each activity.

## Project Structure
PS: Its Initial Project Structure, but it will change as project progresses, but overall is the same.
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

## Architecture

- **MVVM**-oriented, with a lightweight service layer (`NetworkService`) decoupled from views via protocols, allowing the API layer to be mocked in tests.
- **Networking**: `URLSession`-based, with request building (`URI`, `UrlComponents`) separated from response handling (`NetworkError`, `StatusCode`) so failure modes are explicit and typed rather than stringly-typed.
- **Search UX**: `SearchPlacesView` debounces user input using `Task` cancellation so in-flight geocoding requests are cancelled when the query changes, avoiding redundant network calls and race conditions on stale results.
- **Scoring**: `ActivityRating` centralizes the rules that turn raw forecast data (temperature, wind, precipitation, snowfall) into a per-day, per-activity suitability score (`DayActivityRating`), keeping the scoring logic testable and independent of the view layer.

## API

- Geocoding / place search: Open-Meteo Geocoding API
- 7-day forecast: Open-Meteo Forecast API
- No API key required.

## Requirements

- Xcode 26+
- iOS 17+ (SwiftUI)
- No external dependencies — networking and JSON decoding use native `URLSession` / `Codable`.

## Getting Started

1. Clone the repo.
2. Open `ActivityForecast.xcodeproj` (or `.xcworkspace`) in Xcode.
3. **(Optional) Configure Signing:** If you plan to build and run on a physical iOS device, select the `ActivityForecast` project target in Xcode, go to the **Signing & Capabilities** tab, check **Automatically manage signing**, and select your Apple Developer / Personal Team. *(This step is not required if running on an Xcode Simulator).*
4. Build and run on a simulator or device — no additional configuration or API keys needed.

## Documentation

Additional design and process notes live alongside this README:

- `REQUIREMENTS.md` — Context for AI agents
- `THOUGHT_PROCESS.md` — reasoning behind key design decisions ***[(Must Read)](https://github.com/Fabex3d/ActivityForecast/blob/main/ActivityForecast/THOUGHT_PROCESS.md)***
- `ENGINEERING.md` — architectural and technical trade-offs
- `IMPLEMENTATION.md` — implementation notes for AI agents
- `AGENTS.md` — conventions for AI-assisted contributions to this repo
