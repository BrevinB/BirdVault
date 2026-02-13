import SwiftUI
import MapKit

/// Detailed view of a bird species showing all information and the user's sightings.
struct BirdDetailView: View {
    let bird: Bird
    let sightings: [BirdSighting]

    @Environment(\.dismiss) private var dismiss

    private var hasMale: Bool {
        sightings.contains { $0.isMale }
    }

    private var hasFemale: Bool {
        sightings.contains { !$0.isMale }
    }

    private var isDiscovered: Bool {
        !sightings.isEmpty
    }

    private var completionPercentage: Int {
        var total = 0
        if hasMale { total += 1 }
        if hasFemale { total += 1 }
        let max = bird.hasSexualDimorphism ? 2 : 1
        if !bird.hasSexualDimorphism && isDiscovered { total = 1 }
        return Int((Double(total) / Double(max)) * 100)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero section
                    heroSection

                    // Quick stats
                    quickStatsSection

                    // Male/Female collection
                    if bird.hasSexualDimorphism {
                        sexCollectionSection
                    }

                    // Description
                    descriptionSection

                    // Details
                    detailsSection

                    // Fun fact
                    funFactSection

                    // Sightings list
                    if !sightings.isEmpty {
                        sightingsSection
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Sections

    private var heroSection: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    BirdVaultTheme.colorForRarity(bird.rarityTier).opacity(0.3),
                    BirdVaultTheme.colorForRarity(bird.rarityTier).opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)

            VStack(spacing: 8) {
                Text(isDiscovered ? emojiForBird(bird) : "❓")
                    .font(.system(size: 80))

                Text(bird.commonName)
                    .font(.title2.weight(.bold))

                Text(bird.scientificName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()

                HStack(spacing: 12) {
                    RarityStarsView(rarity: bird.rarityTier)

                    Text("•")
                        .foregroundStyle(.secondary)

                    Label(bird.sizeCategory.rawValue, systemImage: bird.sizeIcon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var quickStatsSection: some View {
        HStack(spacing: 0) {
            StatBox(title: "Sightings", value: "\(sightings.count)", icon: "eye.fill")
            Divider().frame(height: 40)
            StatBox(title: "Completion", value: "\(completionPercentage)%", icon: "checkmark.circle.fill")
            Divider().frame(height: 40)
            StatBox(
                title: "Status",
                value: bird.conservationStatus == .leastConcern ? "Secure" : bird.conservationStatus.rawValue,
                icon: bird.conservationStatus.icon,
                color: BirdVaultTheme.colorForConservation(bird.conservationStatus)
            )
        }
        .cardStyle()
        .padding(.horizontal)
    }

    private var sexCollectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Collection")
                .font(.headline)

            HStack(spacing: 12) {
                // Male card
                SexCard(
                    sex: "Male",
                    symbol: "♂",
                    color: .blue,
                    isCollected: hasMale,
                    description: bird.maleDescription
                )

                // Female card
                SexCard(
                    sex: "Female",
                    symbol: "♀",
                    color: .pink,
                    isCollected: hasFemale,
                    description: bird.femaleDescription
                )
            }
        }
        .padding(.horizontal)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)

            Text(bird.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            VStack(spacing: 8) {
                DetailRow(icon: "leaf.fill", title: "Habitat", value: bird.habitat)
                DetailRow(icon: "fork.knife", title: "Diet", value: bird.diet)
                DetailRow(icon: "music.note", title: "Song", value: bird.song)
                DetailRow(icon: "ruler", title: "Size", value: "\(bird.sizeCategory.rawValue) (\(bird.sizeCategory.rangeInches))")
                DetailRow(icon: "paintpalette.fill", title: "Colors", value: bird.primaryColors.map { $0.rawValue }.joined(separator: ", "))
                DetailRow(icon: "calendar", title: "Season", value: bird.seasonalPresence.map { $0.rawValue }.joined(separator: ", "))
                DetailRow(icon: "map.fill", title: "Regions", value: bird.regions.map { $0.rawValue }.joined(separator: ", "))
                DetailRow(icon: "books.vertical.fill", title: "Family", value: bird.family)
                DetailRow(icon: "tag.fill", title: "Order", value: bird.order)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .padding(.horizontal)
    }

    private var funFactSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(BirdVaultTheme.warmAmber)
                Text("Fun Fact")
                    .font(.headline)
            }

            Text(bird.funFact)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(BirdVaultTheme.softAmber.opacity(0.5), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }

    private var sightingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Sightings")
                .font(.headline)
                .padding(.horizontal)

            ForEach(sightings.sorted(by: { $0.dateSighted > $1.dateSighted })) { sighting in
                SightingRowView(sighting: sighting, bird: bird)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Supporting Views

private struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    var color: Color = BirdVaultTheme.primaryGreen

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
            Text(value)
                .font(.subheadline.weight(.bold))
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct SexCard: View {
    let sex: String
    let symbol: String
    let color: Color
    let isCollected: Bool
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(symbol)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(color)
                Text(sex)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: isCollected ? "checkmark.circle.fill" : "circle.dashed")
                    .foregroundStyle(isCollected ? color : .gray.opacity(0.4))
            }

            Text(isCollected ? description : "Not yet discovered...")
                .font(.caption)
                .foregroundStyle(isCollected ? .secondary : .tertiary)
                .lineLimit(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            (isCollected ? color.opacity(0.08) : Color(.systemGray6)),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(isCollected ? color.opacity(0.2) : .clear, lineWidth: 1)
        )
    }
}

private struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(BirdVaultTheme.primaryGreen)
                .frame(width: 20)

            Text(title)
                .font(.subheadline.weight(.medium))
                .frame(width: 70, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

struct SightingRowView: View {
    let sighting: BirdSighting
    let bird: Bird

    var body: some View {
        HStack(spacing: 12) {
            // Photo thumbnail or placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.systemGray5))
                    .frame(width: 55, height: 55)

                if let photoData = sighting.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 55, height: 55)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                } else {
                    Image(systemName: "camera.fill")
                        .foregroundStyle(.gray.opacity(0.4))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: sighting.isMale ? "circle.fill" : "circle.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(sighting.isMale ? .blue : .pink)
                    Text(sighting.isMale ? "Male" : "Female")
                        .font(.subheadline.weight(.medium))
                }

                Text(sighting.dateSighted, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !sighting.locationName.isEmpty {
                    Label(sighting.locationName, systemImage: "mappin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if !sighting.notes.isEmpty {
                Image(systemName: "note.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    let bird = BirdDataService.shared.allBirds.first!
    BirdDetailView(bird: bird, sightings: [])
}
