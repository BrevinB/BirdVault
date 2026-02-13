import SwiftUI

/// A card displaying a bird species in the Pokédex grid.
struct BirdCardView: View {
    let bird: Bird
    let isDiscovered: Bool
    let hasMale: Bool
    let hasFemale: Bool

    var body: some View {
        VStack(spacing: 8) {
            // Bird visual representation
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isDiscovered
                        ? BirdVaultTheme.colorForRarity(bird.rarityTier).opacity(0.12)
                        : Color(.systemGray5)
                    )
                    .frame(height: 100)

                if isDiscovered {
                    VStack(spacing: 4) {
                        Text(emojiForBird(bird))
                            .font(.system(size: 44))

                        // Male/Female indicators
                        HStack(spacing: 4) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundStyle(hasMale ? .blue : .gray.opacity(0.3))
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundStyle(hasFemale ? .pink : .gray.opacity(0.3))
                        }
                    }
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: "questionmark")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.gray.opacity(0.3))
                    }
                }
            }

            // Bird info
            VStack(spacing: 2) {
                Text(isDiscovered ? bird.commonName : "???")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isDiscovered ? .primary : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                // Rarity stars
                HStack(spacing: 1) {
                    ForEach(0..<bird.rarityTier.stars, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 7))
                            .foregroundStyle(
                                isDiscovered
                                    ? BirdVaultTheme.colorForRarity(bird.rarityTier)
                                    : .gray.opacity(0.3)
                            )
                    }
                }
            }
        }
        .padding(8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    isDiscovered
                        ? BirdVaultTheme.colorForRarity(bird.rarityTier).opacity(0.3)
                        : .clear,
                    lineWidth: 1.5
                )
        )
    }
}

/// Maps a bird to a representative emoji based on its family/characteristics.
func emojiForBird(_ bird: Bird) -> String {
    switch bird.family {
    case "Accipitridae": return "🦅"
    case "Strigidae": return "🦉"
    case "Trochilidae": return "💚" // hummingbird
    case "Anatidae": return "🦆"
    case "Ardeidae": return "🪿"
    case "Corvidae": return "🐦‍⬛"
    case "Falconidae": return "🦅"
    case "Picidae": return "🪺"
    case "Columbidae": return "🕊️"
    case "Cathartidae": return "🦅"
    case "Gruidae": return "🪽"
    case "Alcidae": return "🐧"
    case "Fregatidae": return "🦅"
    case "Threskiornithidae": return "🪽"
    case "Pandionidae": return "🦅"
    case "Phasianidae": return "🐔"
    default:
        // Color-based fallback
        if bird.primaryColors.contains(.red) || bird.primaryColors.contains(.orange) {
            return "🐦"
        } else if bird.primaryColors.contains(.blue) {
            return "🐦"
        } else if bird.primaryColors.contains(.yellow) {
            return "🐤"
        }
        return "🐦"
    }
}

#Preview {
    let sampleBird = BirdDataService.shared.allBirds.first!
    HStack {
        BirdCardView(bird: sampleBird, isDiscovered: true, hasMale: true, hasFemale: false)
            .frame(width: 140)
        BirdCardView(bird: sampleBird, isDiscovered: false, hasMale: false, hasFemale: false)
            .frame(width: 140)
    }
    .padding()
}
