import SwiftUI

/// Official-ish Pokémon type colors and helpers for styling.
enum PokemonTypeStyle {

    /// Maps a type name (e.g. "grass") to its canonical color.
    static func color(for type: String) -> Color {
        switch type.lowercased() {
        case "normal":   return Color(hex: 0xA8A77A)
        case "fire":     return Color(hex: 0xEE8130)
        case "water":    return Color(hex: 0x6390F0)
        case "electric": return Color(hex: 0xF7D02C)
        case "grass":    return Color(hex: 0x7AC74C)
        case "ice":      return Color(hex: 0x96D9D6)
        case "fighting": return Color(hex: 0xC22E28)
        case "poison":   return Color(hex: 0xA33EA1)
        case "ground":   return Color(hex: 0xE2BF65)
        case "flying":   return Color(hex: 0xA98FF3)
        case "psychic":  return Color(hex: 0xF95587)
        case "bug":      return Color(hex: 0xA6B91A)
        case "rock":     return Color(hex: 0xB6A136)
        case "ghost":    return Color(hex: 0x735797)
        case "dragon":   return Color(hex: 0x6F35FC)
        case "dark":     return Color(hex: 0x705746)
        case "steel":    return Color(hex: 0xB7B7CE)
        case "fairy":    return Color(hex: 0xD685AD)
        default:         return Color(hex: 0xA8A77A)
        }
    }

    /// Primary color of a Pokémon (from its first type), used for tinting cards.
    static func primaryColor(for pokemon: Pokemon) -> Color {
        color(for: pokemon.types.first ?? "normal")
    }
}

extension Color {
    /// Creates a color from a 0xRRGGBB hex literal.
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
