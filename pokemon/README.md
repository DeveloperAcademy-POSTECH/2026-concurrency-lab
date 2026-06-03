# Pokémon Evolution Dex

> An iOS Pokédex app built on the PokeAPI.
> A learning project for **Swift Concurrency** (parallel data loading) and **Swift Testing** (verifying async code).

A SwiftUI app that groups evolution chains (families) into a single card and lays the evolution stages out horizontally. Multiple families and the detail of each stage are **loaded in parallel using nested TaskGroups**.

---

## 1. Challenge Statement

### Concurrency Lab
> Build a Pokédex app on the PokeAPI to show how the core concepts of Swift Concurrency (`async/await`, `TaskGroup`, `@MainActor`) actually behave in a real iOS app.

### Testing Lab
> Use Swift Testing to verify that async network code behaves correctly across various situations — **success / failure / timeout / cancellation**. Apply **mock objects** and a **protocol-based dependency injection (DI)** pattern to build and document a design that is testable without a real server.

---

## 2. Features

- Displays Pokémon by evolution chain (family) as cards (e.g. Bulbasaur → Ivysaur → Venusaur)
- Loads 50 families plus each stage's detail **in parallel** (nested TaskGroups)

---

## 3. Architecture

```
ContentView ──→ PokemonViewModel ──→ «protocol» PokemonService
   (View)         (@MainActor)             ▲
                                           │ implements
                                    PokemonServiceImpl ──→ PokeAPI
                                                           (network)
```

- **The ViewModel depends only on the protocol (`PokemonService`)** — it never knows the concrete implementation, so a mock can be injected here later for testing.
- `PokemonServiceImpl` decodes the PokeAPI's messy JSON into **DTOs** and converts them into the clean domain model (`Pokemon`).

### Data models

| Model | Description |
| --- | --- |
| `Pokemon` | id, name, imageURL, types (`Identifiable`) |
| `PokemonFamily` | id (evolution-chain id) + `stages: [Pokemon]` (in evolution order) |

### Service contract

```swift
protocol PokemonService: Sendable {
    func fetchEvolutionChain(id: Int) async throws -> [Int]  // ids in evolution order
    func fetchDetail(id: Int) async throws -> Pokemon        // includes image & types
}
```

---

## 4. Concurrency

Because the data has two layers ("family → stage"), the **TaskGroups are nested two levels deep**.

```
Outer TaskGroup ─ 50 families concurrently
   └ Each family: fetchEvolutionChain (fetch the chain first)
        └ Inner TaskGroup ─ that family's stages concurrently (fetchDetail × N)
```

- **Across families: concurrent** — all 50 overlap in time
- **Within one family: sequential** — the chain must be fetched first to know the ids before calling detail (data dependency)
- ~150 concurrent requests. Sequentially this would take ~45s; in parallel it's on the order of ~0.6s.

### Preserving order
TaskGroup completion order is scrambled, so results are first collected into an `[id: Pokemon]` dictionary, then **reordered by the chain order (`speciesIDs`) via `compactMap`** to restore evolution order.

```swift
var byID: [Int: Pokemon] = [:]
for try await p in group { byID[p.id] = p }       // store regardless of arrival order
let ordered = speciesIDs.compactMap { byID[$0] }  // restore order
```

### Concurrency safety
| Keyword | Role |
| --- | --- |
| `@MainActor` | Always updates UI state (`families`, `isLoading`) on the main thread |
| `Sendable` | Safely passes the service into tasks on other threads |
| `static` + passed args | Keeps `loadFamily` from capturing `self` (the MainActor) |

---

## 5. Project Structure

```
pokemon/
├── pokemon.xcodeproj
└── pokemon/
    ├── pokemonApp.swift          # App entry point (font & nav bar setup)
    ├── Model/
    │   └── Pokemon.swift         # Pokemon, PokemonFamily
    ├── Service/
    │   ├── PokemonService.swift  # protocol
    │   └── PokemonServiceImpl.swift  # real implementation + DTOs
    ├── ViewModel/
    │   └── PokemonViewModel.swift # @MainActor, nested TaskGroups
    ├── View/
    │   ├── ContentView.swift     # card UI
    │   ├── PokemonTypeStyle.swift # type colors
    │   └── Font+Pretendard.swift # font helper
    └── Fonts/
        └── PretendardVariable.ttf
```
