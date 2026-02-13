import SwiftUI
import SwiftData

/// User profile view showing stats, achievements, and settings.
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @Query(sort: \BirdSighting.dateSighted, order: .reverse) private var sightings: [BirdSighting]

    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var showingEmojiPicker = false

    private let birdService = BirdDataService.shared

    private var profile: UserProfile {
        if let existing = profiles.first {
            return existing
        }
        let newProfile = UserProfile()
        modelContext.insert(newProfile)
        return newProfile
    }

    private var discoveredSpeciesIDs: Set<String> {
        Set(sightings.map { $0.birdSpeciesID })
    }

    private var completePairs: Int {
        let maleSpecies = Set(sightings.filter { $0.isMale }.map { $0.birdSpeciesID })
        let femaleSpecies = Set(sightings.filter { !$0.isMale }.map { $0.birdSpeciesID })
        return maleSpecies.intersection(femaleSpecies).count
    }

    private var rarityBreakdown: [(RarityTier, Int)] {
        RarityTier.allCases.compactMap { rarity in
            let count = discoveredSpeciesIDs.filter { id in
                birdService.bird(for: id)?.rarityTier == rarity
            }.count
            return count > 0 ? (rarity, count) : nil
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    statsGrid
                    collectionProgress
                    rarityBreakdownSection
                    achievementsSection
                    recentActivitySection
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Sections

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Button {
                showingEmojiPicker = true
            } label: {
                ZStack {
                    Circle()
                        .fill(BirdVaultTheme.lightGreen)
                        .frame(width: 80, height: 80)
                    Text(profile.avatarEmoji)
                        .font(.system(size: 40))
                }
            }

            if isEditingName {
                HStack {
                    TextField("Display Name", text: $editedName)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                    Button("Save") {
                        profile.displayName = editedName
                        isEditingName = false
                    }
                    .font(.subheadline.weight(.semibold))
                }
            } else {
                HStack(spacing: 6) {
                    Text(profile.displayName)
                        .font(.title2.weight(.bold))
                    Button {
                        editedName = profile.displayName
                        isEditingName = true
                    } label: {
                        Image(systemName: "pencil.circle")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Text("Birding since \(profile.joinDate, format: .dateTime.month(.wide).year())")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ProfileStatCard(
                title: "Species Found",
                value: "\(discoveredSpeciesIDs.count)",
                total: "\(birdService.allBirds.count)",
                icon: "bird.fill",
                color: BirdVaultTheme.primaryGreen
            )
            ProfileStatCard(
                title: "Total Sightings",
                value: "\(sightings.count)",
                total: nil,
                icon: "eye.fill",
                color: BirdVaultTheme.skyBlue
            )
            ProfileStatCard(
                title: "Complete Pairs",
                value: "\(completePairs)",
                total: nil,
                icon: "heart.fill",
                color: .pink
            )
            ProfileStatCard(
                title: "Day Streak",
                value: "\(calculateStreak())",
                total: nil,
                icon: "flame.fill",
                color: .orange
            )
        }
    }

    private var collectionProgress: some View {
        VStack(spacing: 12) {
            CollectionProgressView(
                collected: discoveredSpeciesIDs.count,
                total: birdService.allBirds.count,
                label: "Overall Pokédex"
            )
        }
        .cardStyle()
    }

    private var rarityBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rarity Breakdown")
                .font(.headline)

            ForEach(RarityTier.allCases, id: \.self) { rarity in
                let birdCount = birdService.allBirds.filter { $0.rarityTier == rarity }.count
                let found = discoveredSpeciesIDs.filter { id in
                    birdService.bird(for: id)?.rarityTier == rarity
                }.count

                HStack {
                    HStack(spacing: 4) {
                        ForEach(0..<rarity.stars, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(BirdVaultTheme.colorForRarity(rarity))
                        }
                    }
                    .frame(width: 50, alignment: .leading)

                    Text(rarity.rawValue)
                        .font(.subheadline)
                        .frame(width: 80, alignment: .leading)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(BirdVaultTheme.colorForRarity(rarity))
                                .frame(
                                    width: birdCount > 0
                                        ? geometry.size.width * CGFloat(found) / CGFloat(birdCount)
                                        : 0,
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)

                    Text("\(found)/\(birdCount)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .cardStyle()
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                ForEach(Achievement.allAchievements) { achievement in
                    let isUnlocked = isAchievementUnlocked(achievement)
                    VStack(spacing: 6) {
                        Text(achievement.icon)
                            .font(.system(size: 30))
                            .grayscale(isUnlocked ? 0 : 1)
                            .opacity(isUnlocked ? 1 : 0.3)

                        Text(achievement.name)
                            .font(.system(size: 9).weight(.medium))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .foregroundStyle(isUnlocked ? .primary : .tertiary)
                    }
                    .frame(width: 80, height: 80)
                    .background(
                        isUnlocked ? BirdVaultTheme.lightGreen : Color(.systemGray6),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                }
            }
        }
        .cardStyle()
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)

            if sightings.isEmpty {
                HStack {
                    Image(systemName: "binoculars.fill")
                        .foregroundStyle(.tertiary)
                    Text("No sightings yet. Get out there!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            } else {
                ForEach(sightings.prefix(5)) { sighting in
                    if let bird = birdService.bird(for: sighting.birdSpeciesID) {
                        HStack(spacing: 10) {
                            Text(emojiForBird(bird))
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(bird.commonName)
                                    .font(.subheadline.weight(.medium))
                                Text(sighting.dateSighted, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(sighting.isMale ? .blue : .pink)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Helpers

    private func calculateStreak() -> Int {
        guard !sightings.isEmpty else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = today

        let sightingDates = Set(sightings.map { calendar.startOfDay(for: $0.dateSighted) })

        while sightingDates.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }

        return streak
    }

    private func isAchievementUnlocked(_ achievement: Achievement) -> Bool {
        switch achievement.id {
        case "first_catch":
            return sightings.count >= 1
        case "ten_species":
            return discoveredSpeciesIDs.count >= 10
        case "twentyfive_species":
            return discoveredSpeciesIDs.count >= 25
        case "fifty_species":
            return discoveredSpeciesIDs.count >= 50
        case "hundred_species":
            return discoveredSpeciesIDs.count >= 100
        case "pair_collector":
            return completePairs >= 1
        case "ten_pairs":
            return completePairs >= 10
        case "three_day_streak":
            return calculateStreak() >= 3
        case "seven_day_streak":
            return calculateStreak() >= 7
        case "thirty_day_streak":
            return calculateStreak() >= 30
        case "rare_find":
            return discoveredSpeciesIDs.contains { id in
                birdService.bird(for: id)?.rarityTier == .rare
            }
        case "legendary_find":
            return discoveredSpeciesIDs.contains { id in
                birdService.bird(for: id)?.rarityTier == .legendary
            }
        case "share_first":
            return false // Will be implemented with real sharing
        case "five_regions":
            let regions = Set(sightings.compactMap { sighting -> BirdRegion? in
                guard let bird = birdService.bird(for: sighting.birdSpeciesID) else { return nil }
                return bird.regions.first
            })
            return regions.count >= 5
        case "early_bird":
            return sightings.contains { sighting in
                Calendar.current.component(.hour, from: sighting.dateSighted) < 6
            }
        default:
            return false
        }
    }
}

// MARK: - Supporting Views

private struct ProfileStatCard: View {
    let title: String
    let value: String
    let total: String?
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title.weight(.bold))
                if let total = total {
                    Text("/\(total)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(padding: 14)
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [BirdSighting.self, UserProfile.self, SocialPost.self], inMemory: true)
}
