# Rick & Morty Characters

A production-style SwiftUI feature for browsing Rick and Morty characters, with search, filtering, pagination, and a detail screen.

---

## How to Run

1. Open `RickAndMortyApp.xcodeproj` in Xcode 15+ (iOS 16+ deployment target).
2. Select any iPhone simulator or device.
3. Press `⌘R` to run, or `⌘U` to run all unit tests.

> **No third-party dependencies.** No `pod install`, no `swift package resolve` required.

---

## Architecture

### Clean Architecture + MVVM

The project is split into three explicit layers with one-way dependencies:

```
Presentation → Domain ← Data
```

| Layer | Contents | Depends on |
|---|---|---|
| **Domain** | `Character`, `PaginatedResponse`, `CharacterRepository` (protocol), `FetchCharactersUseCase`, `FetchCharacterDetailUseCase` | Nothing |
| **Data** | `URLSessionNetworkService`, `CharacterRepositoryImpl`, `APIEndpoint`, `NetworkError` | Domain protocols |
| **Presentation** | `CharacterListViewModel`, `CharacterDetailViewModel`, all SwiftUI views | Domain use-case protocols |

#### Why Clean Architecture?
- The Domain layer has **zero framework imports** — it's pure Swift. This maximises testability.
- Swapping the network layer (e.g. for a mock, Alamofire, or a local cache) only requires implementing `NetworkService` and `CharacterRepository`.
- Business logic lives in use cases and view models, not in views.

#### Why MVVM over VIPER?
For a feature this size, MVVM keeps the boilerplate low while still providing a clear boundary between UI and logic. The use-case layer brings the "interactor" concept from VIPER without requiring an explicit presenter or router.

---

## Dependency Injection

All dependencies are injected via **constructor injection**. No global singletons exist for core infrastructure.

```
DependencyContainer
    └─ URLSessionNetworkService   (implements NetworkService)
        └─ CharacterRepositoryImpl (implements CharacterRepository)
            ├─ FetchCharactersUseCase
            └─ FetchCharacterDetailUseCase
                ├─ CharacterListViewModel
                └─ CharacterDetailViewModel
```

`DependencyContainer` is the **composition root**: it is the only place that knows about concrete types. Views receive their `ViewModel` and a factory closure; they never import or reference `DependencyContainer` directly.

The `DependencyContainer.shared` singleton exists **only as a convenience composition root** for the app entry point. All internal dependencies it manages (`NetworkService`, repositories, use cases) are non-singleton, lazily-created, and swappable.

---

## What Was Tested and Why

### `CharacterListViewModelTests` (ViewModel behaviour)
- **Loading state** transitions correctly on `onAppear`.
- **Success**: characters are populated, `viewState` becomes `.loaded`.
- **HTTP 500 error** → `.error` state.
- **HTTP 404** → `.empty` state (API returns 404 for "no results").
- **Empty result list** → `.empty` state.
- **Pagination**: `canLoadMore` is true when `pages > 1`, false on last page.
- **Search resets to page 1**: after a search change and debounce, `lastPage == 1`.
- **Retry**: re-fetches after a failure and transitions to `.loaded`.

All tests use `MockFetchCharactersUseCase` — no real network calls.

### `CharacterRepositoryTests` (Service / API layer)
- **Successful decode** of `PaginatedResponse<Character>` and single `Character`.
- **HTTP error propagation** (404, 500).
- **Decoding error propagation**.
- **Network error propagation** (`URLError.notConnectedToInternet`).

All tests use `MockNetworkService`, which is deterministic and never hits the real network.

---

## Observability & Security

| Topic | Decision |
|---|---|
| **No analytics/logging** | Out of scope for this assignment; in production I'd inject a `Logger` protocol and integrate with OSLog or a crash reporter. |
| **No authentication** | The Rick and Morty API is public — no tokens or credentials needed. |
| **HTTPS only** | All requests use `https://rickandmortyapi.com`. App Transport Security (ATS) is enabled by default on iOS and enforces TLS. |
| **No sensitive data** | No PII is collected, stored, or cached. |
| **No local persistence** | Images are cached by `AsyncImage`/`URLSession` using the system URL cache. No custom disk writes. |

---

## What I Would Improve Next

1. **Image caching** — `AsyncImage` uses the system cache but doesn't support prefetching. A custom `CachedAsyncImage` backed by `NSCache` + `URLSession` would improve scroll performance.
2. **Pull-to-refresh** — Already included via `.refreshable`, but testing the refresh flow deserves its own test case.
3. **Accessibility** — Add `accessibilityLabel` to `StatusBadgeView` and ensure dynamic type support.
4. **Snapshot tests** — Add snapshot tests for key views (list row, detail header, empty state) to catch regressions.
5. **Episode detail screen** — Tap an episode URL to navigate to a proper episode detail view.
6. **Offline state** — Detect `URLError.notConnectedToInternet` and show a dedicated offline banner rather than the generic error screen.
7. **Dependency inversion for DependencyContainer** — Replace `DependencyContainer.shared` in the app entry point with a proper `Environment`-based injection tree, removing all singleton references from production code.
8. **CI/CD** — Add a GitHub Actions workflow to run tests on every PR.
