import SwiftUI
import SwiftData

/// The main Pokédex view showing all bird species in a grid with collection progress.
struct PokedexView: View {
    @Query(sort: \BirdSighting.dateSighted, order: .reverse) private var sightings: [BirdSighting]
    @State private var searchText = ""
    @State private var selectedFilter: PokedexFilter = .all
    @State private var selectedBird: Bird?
    @State private var showingProfile = false
    @State private var showMascotTip = true
    @State private var viewMode: ViewMode = .grid

    private let birdService = BirdDataService.shared

    enum PokedexFilter: String, CaseIterable {
        case all = "All"
        case discovered = "Discovered"
        case undiscovered = "Missing"
        case common = "Common"
        case uncommon = "Uncommon"
        case rare = "Rare+"
    }

    enum ViewMode {
        case grid, list
    }

    private var discoveredSpeciesIDs: Set<String> {
        Set(sightings.map { $0.birdSpeciesID })
    }

    private var maleSpeciesIDs: Set<String> {
        Set(sightings.filter { $0.isMale }.map { $0.birdSpeciesID })
    }

    private var femaleSpeciesIDs: Set<String> {
        Set(sightings.filter { !$0.isMale }.map { $0.birdSpeciesID })
    }

    private var filteredBirds: [Bird] {
        var birds = birdService.allBirds

        // Apply search
        if !searchText.isEmpty {
            birds = birdService.birds(matching: searchText)
        }

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .discovered:
            birds = birds.filter { discoveredSpeciesIDs.contains($0.id) }
        case .undiscovered:
            birds = birds.filter { !discoveredSpeciesIDs.contains($0.id) }
        case .common:
            birds = birds.filter { $0.rarityTier == .common }
        case .uncommon:
            birds = birds.filter { $0.rarityTier == .uncommon }
        case .rare:
            birds = birds.filter { [.rare, .veryRare, .legendary].contains($0.rarityTier) }
        }

        return birds
    }

    private let gridColumns = [
        GridItem(.adaptive(minimum: 140), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Mascot tip
                    if showMascotTip && sightings.isEmpty {
                        MascotBubbleView(
                            message: "Welcome to your BirdVault Pokédex! Start by heading to the Capture tab to log your first bird sighting. Every birder's journey starts with a single feather!",
                            showDismiss: true,
                            onDismiss: { withAnimation { showMascotTip = false } }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Collection progress
                    CollectionProgressView(
                        collected: discoveredSpeciesIDs.count,
                        total: birdService.allBirds.count
                    )
                    .padding(.horizontal)

                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(PokedexFilter.allCases, id: \.self) { filter in
                                FilterChipView(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter,
                                    action: { selectedFilter = filter }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Bird grid
                    if viewMode == .grid {
                        LazyVGrid(columns: gridColumns, spacing: 12) {
                            ForEach(filteredBirds) { bird in
                                Button {
                                    selectedBird = bird
                                } label: {
                                    BirdCardView(
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
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredBirds) { bird in
                                Button {
                                    selectedBird = bird
                                } label: {
                                    BirdListRowView(
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
                .padding(.vertical)
            }
            .navigationTitle("Pokédex")
            .searchable(text: $searchText, prompt: "Search birds...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            viewMode = viewMode == .grid ? .list : .grid
                        }
                    } label: {
                        Image(systemName: viewMode == .grid ? "list.bullet" : "square.grid.2x2")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingProfile = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
            .sheet(item: $selectedBird) { bird in
                BirdDetailView(
                    bird: bird,
                    sightings: sightings.filter { $0.birdSpeciesID == bird.id }
                )
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
        }
    }
}

// MARK: - Supporting Views

struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected ? BirdVaultTheme.primaryGreen : Color(.systemGray5),
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
    }
}

struct BirdListRowView: View {
    let bird: Bird
    let isDiscovered: Bool
    let hasMale: Bool
    let hasFemale: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isDiscovered
                        ? BirdVaultTheme.colorForRarity(bird.rarityTier).opacity(0.15)
                        : Color(.systemGray5)
                    )
                    .frame(width: 50, height: 50)

                if isDiscovered {
                    Text(emojiForBird(bird))
                        .font(.title2)
                } else {
                    Image(systemName: "questionmark")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.gray.opacity(0.3))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(isDiscovered ? bird.commonName : "???")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isDiscovered ? .primary : .secondary)

                if isDiscovered {
                    Text(bird.scientificName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }

            Spacer()

            if isDiscovered {
                SexCollectionView(hasMale: hasMale, hasFemale: hasFemale)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    PokedexView()
        .modelContainer(for: [BirdSighting.self, UserProfile.self, SocialPost.self], inMemory: true)
        .environmentObject(LocationManager())
}
