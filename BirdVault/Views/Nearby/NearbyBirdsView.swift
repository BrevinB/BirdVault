import SwiftUI
import SwiftData

/// Shows birds that might be in the user's current area based on region and season.
struct NearbyBirdsView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @Query(sort: \BirdSighting.dateSighted, order: .reverse) private var sightings: [BirdSighting]
    @State private var selectedBird: Bird?
    @State private var showMascotTip = true

    private let birdService = BirdDataService.shared

    private var discoveredSpeciesIDs: Set<String> {
        Set(sightings.map { $0.birdSpeciesID })
    }

    private var maleSpeciesIDs: Set<String> {
        Set(sightings.filter { $0.isMale }.map { $0.birdSpeciesID })
    }

    private var femaleSpeciesIDs: Set<String> {
        Set(sightings.filter { !$0.isMale }.map { $0.birdSpeciesID })
    }

    private var nearbyBirds: [Bird] {
        birdService.birds(forRegion: locationManager.currentRegion, season: birdService.currentSeason())
    }

    private var undiscoveredNearby: [Bird] {
        nearbyBirds.filter { !discoveredSpeciesIDs.contains($0.id) }
    }

    private var discoveredNearby: [Bird] {
        nearbyBirds.filter { discoveredSpeciesIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Location header
                    locationHeader

                    // Mascot tip
                    if showMascotTip {
                        MascotBubbleView(
                            message: "These are birds you might spot in \(locationManager.currentRegion.rawValue) this \(birdService.currentSeason().rawValue.lowercased())! Keep your eyes peeled for the undiscovered ones!",
                            showDismiss: true,
                            onDismiss: { withAnimation { showMascotTip = false } }
                        )
                    }

                    // Stats bar
                    statsBar

                    // Undiscovered section
                    if !undiscoveredNearby.isEmpty {
                        sectionView(
                            title: "Undiscovered Nearby",
                            subtitle: "Birds waiting to be found!",
                            icon: "sparkles",
                            birds: undiscoveredNearby.sorted { $0.rarityTier.stars < $1.rarityTier.stars }
                        )
                    }

                    // Already found section
                    if !discoveredNearby.isEmpty {
                        sectionView(
                            title: "Already Spotted",
                            subtitle: "You've seen these here before",
                            icon: "checkmark.circle.fill",
                            birds: discoveredNearby
                        )
                    }

                    // Seasonal highlights
                    seasonalHighlights
                }
                .padding(.vertical)
            }
            .navigationTitle("Nearby")
            .sheet(item: $selectedBird) { bird in
                BirdDetailView(
                    bird: bird,
                    sightings: sightings.filter { $0.birdSpeciesID == bird.id }
                )
            }
        }
    }

    // MARK: - Sections

    private var locationHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: "location.fill")
                .font(.title3)
                .foregroundStyle(BirdVaultTheme.primaryGreen)

            VStack(alignment: .leading, spacing: 2) {
                Text(locationManager.locationName)
                    .font(.headline)
                Text("\(locationManager.currentRegion.rawValue) Region")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(birdService.currentSeason().rawValue)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(BirdVaultTheme.primaryGreen)
                Text(seasonEmoji)
                    .font(.title2)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }

    private var statsBar: some View {
        HStack(spacing: 0) {
            NearbyStatView(value: "\(nearbyBirds.count)", label: "Possible", icon: "bird.fill")
            Divider().frame(height: 35)
            NearbyStatView(value: "\(discoveredNearby.count)", label: "Found", icon: "checkmark.circle")
            Divider().frame(height: 35)
            NearbyStatView(value: "\(undiscoveredNearby.count)", label: "Missing", icon: "questionmark.circle")
        }
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }

    private func sectionView(title: String, subtitle: String, icon: String, birds: [Bird]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(BirdVaultTheme.primaryGreen)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(birds.count)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(birds) { bird in
                        Button {
                            selectedBird = bird
                        } label: {
                            NearbyBirdCard(
                                bird: bird,
                                isDiscovered: discoveredSpeciesIDs.contains(bird.id),
                                hasMale: maleSpeciesIDs.contains(bird.id),
                                hasFemale: femaleSpeciesIDs.contains(bird.id)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var seasonalHighlights: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(BirdVaultTheme.warmAmber)
                Text("Seasonal Tips")
                    .font(.headline)
            }
            .padding(.horizontal)

            VStack(spacing: 8) {
                SeasonalTipRow(
                    emoji: "🌅",
                    title: "Best Time",
                    description: "Dawn and dusk are peak activity times for most birds"
                )
                SeasonalTipRow(
                    emoji: "🔇",
                    title: "Be Quiet",
                    description: "Move slowly and keep noise to a minimum"
                )
                SeasonalTipRow(
                    emoji: "👂",
                    title: "Listen First",
                    description: "Often you'll hear birds before you see them"
                )
            }
            .padding(.horizontal)
        }
    }

    private var seasonEmoji: String {
        switch birdService.currentSeason() {
        case .spring: return "🌸"
        case .summer: return "☀️"
        case .fall: return "🍂"
        case .winter: return "❄️"
        case .yearRound: return "🗓️"
        }
    }
}

// MARK: - Supporting Views

private struct NearbyStatView: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(BirdVaultTheme.primaryGreen)
            Text(value)
                .font(.headline.weight(.bold))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct NearbyBirdCard: View {
    let bird: Bird
    let isDiscovered: Bool
    let hasMale: Bool
    let hasFemale: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        isDiscovered
                            ? BirdVaultTheme.colorForRarity(bird.rarityTier).opacity(0.12)
                            : Color(.systemGray6)
                    )
                    .frame(width: 120, height: 90)

                VStack(spacing: 4) {
                    if isDiscovered {
                        Text(emojiForBird(bird))
                            .font(.system(size: 36))
                    } else {
                        Image(systemName: "questionmark")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.gray.opacity(0.3))
                    }
                }
            }

            VStack(spacing: 2) {
                Text(bird.commonName)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)

                HStack(spacing: 2) {
                    ForEach(0..<bird.rarityTier.stars, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(BirdVaultTheme.colorForRarity(bird.rarityTier))
                    }
                }
            }
        }
        .frame(width: 130)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct SeasonalTipRow: View {
    let emoji: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NearbyBirdsView()
        .modelContainer(for: [BirdSighting.self, UserProfile.self, SocialPost.self], inMemory: true)
        .environmentObject(LocationManager())
}
