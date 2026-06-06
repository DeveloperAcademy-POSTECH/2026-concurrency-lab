import Foundation

/// Real service implementation that calls the PokeAPI.
struct PokemonServiceImpl: PokemonService {

    /// Injectable for testing or configuration. (defaults to .shared)
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    private let baseURL = "https://pokeapi.co/api/v2"

    // MARK: - PokemonService

    func fetchEvolutionChain(id: Int) async throws -> [Int] {
        let url = URL(string: "\(baseURL)/evolution-chain/\(id)")!
        let (data, _) = try await session.data(from: url)
        let decoded = try JSONDecoder().decode(EvolutionChainResponse.self, from: data)

        // Flatten the tree (species + evolves_to) into evolution order.
        var ids: [Int] = []
        func walk(_ link: EvolutionChainResponse.ChainLink) {
            ids.append(link.species.extractedID)
            for next in link.evolves_to {
                walk(next)
            }
        }
        walk(decoded.chain)
        return ids
    }

    func fetchDetail(id: Int) async throws -> Pokemon {
        let url = URL(string: "\(baseURL)/pokemon/\(id)")!
        let (data, _) = try await session.data(from: url)
        let decoded = try JSONDecoder().decode(DetailResponse.self, from: data)
        return Pokemon(
            id: decoded.id,
            name: decoded.name,
            imageURL: decoded.sprites.front_default ?? "",
            types: decoded.types.map { $0.type.name }
        )
    }
}

// MARK: - DTOs for decoding PokeAPI responses (mirror the external JSON shape)

private extension PokemonServiceImpl {

    /// GET /evolution-chain/{id} response (recursive tree structure)
    struct EvolutionChainResponse: Decodable {
        let chain: ChainLink

        struct ChainLink: Decodable {
            let species: Species
            let evolves_to: [ChainLink]   // next evolution stages (can branch)
        }
        struct Species: Decodable {
            let name: String
            let url: String   // e.g. ".../pokemon-species/1/"

            /// Extracts the trailing number in the url as the id.
            var extractedID: Int {
                url.split(separator: "/").last.flatMap { Int($0) } ?? -1
            }
        }
    }

    /// GET /pokemon/{id} response
    struct DetailResponse: Decodable {
        let id: Int
        let name: String
        let sprites: Sprites
        let types: [TypeEntry]

        struct Sprites: Decodable {
            let front_default: String?
        }
        struct TypeEntry: Decodable {
            let type: TypeInfo
        }
        struct TypeInfo: Decodable {
            let name: String
        }
    }
}
