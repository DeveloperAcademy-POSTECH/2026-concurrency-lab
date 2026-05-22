import Foundation
import Combine

@MainActor
class PokemonViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    @Published var isLoading: Bool = false

    func loadPokemons() async {
    }
}
