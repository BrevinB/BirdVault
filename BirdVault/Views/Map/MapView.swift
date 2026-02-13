import SwiftUI
import MapKit
import SwiftData

/// Shows a map of all the user's bird sighting locations.
struct MapView: View {
    @Query(sort: \BirdSighting.dateSighted, order: .reverse) private var sightings: [BirdSighting]
    @EnvironmentObject private var locationManager: LocationManager
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedSighting: BirdSighting?
    @State private var showMascotTip = true
    @State private var mapStyle: MapStyleOption = .standard

    private let birdService = BirdDataService.shared

    enum MapStyleOption: String, CaseIterable {
        case standard = "Standard"
        case satellite = "Satellite"
        case hybrid = "Hybrid"
    }

    /// Sightings that have valid coordinates
    private var mappableSightings: [BirdSighting] {
        sightings.filter { $0.latitude != 0 && $0.longitude != 0 }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                mapContent

                VStack(spacing: 0) {
                    // Top controls
                    HStack {
                        Spacer()
                        mapStylePicker
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Spacer()

                    // Bottom stats bar
                    if !mappableSightings.isEmpty {
                        mapStatsBar
                    }
                }
            }
            .navigationTitle("Sighting Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            cameraPosition = .automatic
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
            .overlay {
                if mappableSightings.isEmpty {
                    emptyState
                }
            }
            .sheet(item: $selectedSighting) { sighting in
                if let bird = birdService.bird(for: sighting.birdSpeciesID) {
                    BirdDetailView(
                        bird: bird,
                        sightings: sightings.filter { $0.birdSpeciesID == bird.id }
                    )
                }
            }
        }
    }

    // MARK: - Map Content

    private var mapContent: some View {
        Map(position: $cameraPosition) {
            // User location
            UserAnnotation()

            // Sighting pins
            ForEach(mappableSightings) { sighting in
                if let bird = birdService.bird(for: sighting.birdSpeciesID) {
                    Annotation(
                        bird.commonName,
                        coordinate: sighting.coordinate
                    ) {
                        Button {
                            selectedSighting = sighting
                        } label: {
                            SightingPinView(
                                bird: bird,
                                isMale: sighting.isMale
                            )
                        }
                    }
                }
            }
        }
        .mapStyle(currentMapStyle)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }

    private var currentMapStyle: MapStyle {
        switch mapStyle {
        case .standard: return .standard
        case .satellite: return .imagery
        case .hybrid: return .hybrid
        }
    }

    // MARK: - Controls

    private var mapStylePicker: some View {
        Picker("Map Style", selection: $mapStyle) {
            ForEach(MapStyleOption.allCases, id: \.self) { style in
                Text(style.rawValue).tag(style)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: 240)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private var mapStatsBar: some View {
        HStack(spacing: 16) {
            Label("\(mappableSightings.count) sightings", systemImage: "mappin.circle.fill")
                .font(.subheadline.weight(.medium))

            Spacer()

            let uniqueSpecies = Set(mappableSightings.map { $0.birdSpeciesID }).count
            Label("\(uniqueSpecies) species", systemImage: "bird.fill")
                .font(.subheadline.weight(.medium))

            Spacer()

            let uniqueLocations = Set(mappableSightings.map { $0.locationName }).count
            Label("\(uniqueLocations) locations", systemImage: "map.fill")
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.primary)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            MascotBubbleView(
                message: "Your map is empty! Once you start logging bird sightings with location enabled, they'll appear as pins here. Each species gets its own marker!",
                showDismiss: false
            )

            Image(systemName: "map.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)

            Text("No sightings on the map yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Log bird sightings with location enabled to see them here")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Sighting Pin

struct SightingPinView: View {
    let bird: Bird
    let isMale: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(BirdVaultTheme.colorForRarity(bird.rarityTier))
                    .frame(width: 36, height: 36)
                    .shadow(color: BirdVaultTheme.colorForRarity(bird.rarityTier).opacity(0.4), radius: 4, y: 2)

                Text(emojiForBird(bird))
                    .font(.system(size: 18))
            }

            // Pin stem
            Triangle()
                .fill(BirdVaultTheme.colorForRarity(bird.rarityTier))
                .frame(width: 12, height: 8)
                .offset(y: -2)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    MapView()
        .modelContainer(for: [BirdSighting.self, UserProfile.self, SocialPost.self], inMemory: true)
        .environmentObject(LocationManager())
}
