import Foundation

protocol PokemonService {
    func fetchList() async
    func fetchDetail(id: Int) async
}
