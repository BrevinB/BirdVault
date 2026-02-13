import SwiftUI
import SwiftData

@main
struct BirdVaultApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var locationManager = LocationManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BirdSighting.self,
            UserProfile.self,
            SocialPost.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(locationManager)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .environmentObject(locationManager)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
