import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PokemonViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.families) { family in
                        FamilyCard(family: family)
                    }
                }
                .padding()
            }
            .background(Color.white)
            .overlay {
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .navigationTitle("Pokédex")
            .task {
                await viewModel.loadFamilies()
            }
        }
        .preferredColorScheme(.light)
    }
}

/// A card showing one evolution family, tinted by the family's primary type.
private struct FamilyCard: View {
    let family: PokemonFamily

    /// Tint comes from the first stage's primary type.
    private var tint: Color {
        family.stages.first.map(PokemonTypeStyle.primaryColor(for:)) ?? .gray
    }

    var body: some View {
        Group {
            if family.stages.count >= 4 {
                // 4+ stages: scroll horizontally so side padding stays intact
                // instead of squeezing the line edge to edge.
                ScrollView(.horizontal, showsIndicators: false) {
                    stagesRow(fixedWidth: true)
                        .padding(16)
                }
            } else {
                // 1–3 stages: fill the card width evenly, no scrolling.
                stagesRow(fixedWidth: false)
                    .padding(16)
            }
        }
        .background(
            LinearGradient(
                colors: [tint.opacity(0.45), tint.opacity(0.9)],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: tint.opacity(0.3), radius: 8, y: 4)
    }

    @ViewBuilder
    private func stagesRow(fixedWidth: Bool) -> some View {
        HStack(spacing: 8) {
            ForEach(Array(family.stages.enumerated()), id: \.element.id) { index, stage in
                if index > 0 {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.85))
                }
                StageView(pokemon: stage)
                    .frame(maxWidth: fixedWidth ? nil : .infinity)
                    .frame(width: fixedWidth ? 104 : nil)
            }
        }
    }
}

/// A single evolution stage: Pokédex number, sprite on a frosted disc, name, type badges.
private struct StageView: View {
    let pokemon: Pokemon

    var body: some View {
        VStack(spacing: 6) {
            Text(String(format: "#%03d", pokemon.id))
                .font(.pretendard(11, weight: .bold, relativeTo: .caption2))
                .foregroundStyle(.white.opacity(0.8))

            AsyncImage(url: URL(string: pokemon.imageURL)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
                    .tint(.white)
            }
            .frame(width: 76, height: 76)
            .padding(6)
            .background(Circle().fill(.white.opacity(0.18)))

            Text(pokemon.name.capitalized)
                .font(.pretendard(15, weight: .semibold, relativeTo: .subheadline))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // Badges stack vertically so each chip stays on a single line.
            VStack(spacing: 4) {
                ForEach(pokemon.types, id: \.self) { type in
                    TypeBadge(type: type)
                }
            }
        }
    }
}

/// A colored capsule showing a single type name (always one line).
private struct TypeBadge: View {
    let type: String

    var body: some View {
        Text(type.capitalized)
            .font(.pretendard(10, weight: .bold, relativeTo: .caption2))
            .foregroundStyle(.white)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(PokemonTypeStyle.color(for: type))
                    .overlay(Capsule().stroke(.white.opacity(0.5), lineWidth: 1))
            )
    }
}

/// Pokéball-style loading indicator.
private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "circle.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.red)
                .symbolEffect(.pulse)
            Text("Loading…")
                .font(.pretendard(15, weight: .medium, relativeTo: .subheadline))
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ContentView()
}
