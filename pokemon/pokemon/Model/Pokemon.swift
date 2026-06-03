import Foundation

/// A fully-detailed Pokémon.
/// `Identifiable`: required by SwiftUI `List`/`ForEach` to tell items apart (uses the id property automatically).
struct Pokemon: Identifiable {
    let id: Int
    let name: String
    let imageURL: String
    let types: [String]
}

/// A single evolution chain (family). Displayed as one card.
/// e.g. [Bulbasaur, Ivysaur, Venusaur]
struct PokemonFamily: Identifiable {
    let id: Int            // evolution-chain id
    let stages: [Pokemon]  // stages in evolution order
}
