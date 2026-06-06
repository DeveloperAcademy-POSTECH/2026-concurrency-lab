import Foundation

protocol PokemonService: Sendable {
    /// Fetches an evolution chain. Returns Pokémon ids in evolution order.
    /// e.g. chain 1 -> [1, 2, 3] (Bulbasaur -> Ivysaur -> Venusaur)
    func fetchEvolutionChain(id: Int) async throws -> [Int]

    /// Fetches detail for a specific Pokémon. (includes image & types)
    func fetchDetail(id: Int) async throws -> Pokemon
}
