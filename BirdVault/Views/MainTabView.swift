import SwiftUI
import SwiftData

/// The main tab-based navigation for BirdVault.
struct MainTabView: View {
    @State private var selectedTab: Tab = .pokedex
    @State private var showingCamera = false

    enum Tab: String {
        case pokedex = "Pokédex"
        case nearby = "Nearby"
        case camera = "Camera"
        case map = "Map"
        case social = "Community"
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            PokedexView()
                .tabItem {
                    Label("Pokédex", systemImage: "book.fill")
                }
                .tag(Tab.pokedex)

            NearbyBirdsView()
                .tabItem {
                    Label("Nearby", systemImage: "location.fill")
                }
                .tag(Tab.nearby)

            CaptureView()
                .tabItem {
                    Label("Capture", systemImage: "camera.fill")
                }
                .tag(Tab.camera)

            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(Tab.map)

            SocialFeedView()
                .tabItem {
                    Label("Community", systemImage: "person.3.fill")
                }
                .tag(Tab.social)
        }
        .tint(BirdVaultTheme.primaryGreen)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [BirdSighting.self, UserProfile.self, SocialPost.self], inMemory: true)
        .environmentObject(LocationManager())
}
