import SwiftUI

/// Displays rarity stars for a bird species.
struct RarityStarsView: View {
    let rarity: RarityTier

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < rarity.stars ? "star.fill" : "star")
                    .font(.system(size: 12))
                    .foregroundStyle(
                        index < rarity.stars
                            ? BirdVaultTheme.colorForRarity(rarity)
                            : .gray.opacity(0.3)
                    )
            }

            Text(rarity.rawValue)
                .font(.caption2.weight(.medium))
                .foregroundStyle(BirdVaultTheme.colorForRarity(rarity))
                .padding(.leading, 4)
        }
    }
}

/// Displays a progress bar with label.
struct CollectionProgressView: View {
    let collected: Int
    let total: Int
    var label: String = "Collection Progress"

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(collected) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(collected)/\(total)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(BirdVaultTheme.primaryGreen)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [BirdVaultTheme.primaryGreen, BirdVaultTheme.skyBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 10)
                        .animation(.spring(response: 0.6), value: progress)
                }
            }
            .frame(height: 10)
        }
    }
}

/// Displays sex collection status icons.
struct SexCollectionView: View {
    let hasMale: Bool
    let hasFemale: Bool

    var body: some View {
        HStack(spacing: 8) {
            Label {
                Text("Male")
                    .font(.caption)
            } icon: {
                Image(systemName: hasMale ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(hasMale ? .blue : .gray.opacity(0.4))
            }

            Label {
                Text("Female")
                    .font(.caption)
            } icon: {
                Image(systemName: hasFemale ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(hasFemale ? .pink : .gray.opacity(0.4))
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ForEach(RarityTier.allCases, id: \.self) { rarity in
            RarityStarsView(rarity: rarity)
        }

        CollectionProgressView(collected: 15, total: 50)
            .padding()

        SexCollectionView(hasMale: true, hasFemale: false)
    }
    .padding()
}
