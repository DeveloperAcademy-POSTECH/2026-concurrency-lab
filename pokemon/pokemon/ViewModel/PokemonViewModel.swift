import Foundation
import Combine

@MainActor
class PokemonViewModel: ObservableObject {
    @Published var families: [PokemonFamily] = []
    @Published var isLoading: Bool = false

    /// Range of evolution-chain (family) ids to display.
    private let chainIDs = Array(1...50)

    private let service: PokemonService

    init(service: PokemonService = PokemonServiceImpl()) {
        self.service = service
    }

    func loadFamilies() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let service = self.service

            // Outer TaskGroup: load multiple evolution families concurrently.
            let loaded = try await withThrowingTaskGroup(of: PokemonFamily.self) { group in
                for chainID in chainIDs {
                    group.addTask {
                        try await Self.loadFamily(chainID: chainID, service: service)
                    }
                }

                var collected: [PokemonFamily] = []
                for try await family in group {
                    collected.append(family)
                }
                return collected
            }

            // Families also arrive out of order, so sort by chain id.
            families = loaded.sorted { $0.id < $1.id }
        } catch {
            families = []
        }
    }

    /// Builds one evolution family: fetch the chain, then fetch each stage's detail concurrently.
    private static func loadFamily(chainID: Int, service: PokemonService) async throws -> PokemonFamily {
        // 1. Get the ids in evolution order from the chain.
        let speciesIDs = try await service.fetchEvolutionChain(id: chainID)

        // 2. Inner TaskGroup: fetch each stage's detail concurrently.
        let details = try await withThrowingTaskGroup(of: Pokemon.self) { group in
            for sid in speciesIDs {
                group.addTask {
                    try await service.fetchDetail(id: sid)
                }
            }
            var byID: [Int: Pokemon] = [:]
            for try await pokemon in group {
                byID[pokemon.id] = pokemon
            }
            return byID
        }

        // 3. Completion order is scrambled, so reorder by evolution order (speciesIDs).
        let orderedStages = speciesIDs.compactMap { details[$0] }
        return PokemonFamily(id: chainID, stages: orderedStages)
    }
}
