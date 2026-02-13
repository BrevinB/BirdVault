import SwiftUI

/// Onboarding flow introducing the user to BirdVault and its mascot Pip.
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject private var locationManager: LocationManager
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var selectedEmoji = "🐦"
    @Environment(\.modelContext) private var modelContext

    private let totalPages = 5

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    backgroundColorForPage(currentPage).opacity(0.15),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    mascotPage.tag(1)
                    featuresPage.tag(2)
                    permissionsPage.tag(3)
                    profileSetupPage.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4), value: currentPage)

                // Bottom controls
                VStack(spacing: 16) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? BirdVaultTheme.primaryGreen : Color(.systemGray4))
                                .frame(width: index == currentPage ? 10 : 7, height: index == currentPage ? 10 : 7)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    // Navigation buttons
                    HStack {
                        if currentPage > 0 {
                            Button("Back") {
                                withAnimation { currentPage -= 1 }
                            }
                            .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if currentPage < totalPages - 1 {
                            Button {
                                withAnimation { currentPage += 1 }
                            } label: {
                                HStack {
                                    Text("Next")
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .buttonStyle(.birdPrimary)
                            .frame(width: 140)
                        } else {
                            Button {
                                completeOnboarding()
                            } label: {
                                HStack {
                                    Text("Let's Go!")
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .buttonStyle(.birdPrimary)
                            .frame(width: 160)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Pages

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🪺")
                .font(.system(size: 80))

            VStack(spacing: 8) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("BirdVault")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(BirdVaultTheme.primaryGreen)
            }

            Text("Your personal bird Pokédex.\nDiscover, photograph, and collect\nevery bird species near you.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Spacer()
            Spacer()
        }
        .padding()
    }

    private var mascotPage: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(BirdVaultTheme.lightGreen)
                    .frame(width: 140, height: 140)
                Text("🐦‍⬛")
                    .font(.system(size: 70))
            }

            VStack(spacing: 8) {
                Text("Meet Pip!")
                    .font(.title.weight(.bold))

                Text("Your Birding Guide")
                    .font(.title3)
                    .foregroundStyle(BirdVaultTheme.primaryGreen)
            }

            Text("Pip will help you on your birding journey — offering tips, celebrating your discoveries, and guiding you to new species!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            MascotBubbleView(
                message: "Hey there! I'm Pip, and I'll be your guide. Let's find some amazing birds together!",
                mascotSize: 45
            )

            Spacer()
            Spacer()
        }
        .padding()
    }

    private var featuresPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What You Can Do")
                .font(.title2.weight(.bold))

            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "camera.fill", color: BirdVaultTheme.primaryGreen,
                          title: "Photograph Birds", description: "Snap photos and log them in your Pokédex")
                FeatureRow(icon: "book.fill", color: BirdVaultTheme.skyBlue,
                          title: "Collect Them All", description: "Track male & female variants of each species")
                FeatureRow(icon: "location.fill", color: BirdVaultTheme.warmAmber,
                          title: "Discover Nearby", description: "See which birds are in your area right now")
                FeatureRow(icon: "map.fill", color: BirdVaultTheme.earthBrown,
                          title: "Map Your Journey", description: "See every sighting location on a map")
                FeatureRow(icon: "person.3.fill", color: .purple,
                          title: "Join the Community", description: "Share finds and see what others spotted")
            }
            .padding(.horizontal, 20)

            Spacer()
            Spacer()
        }
        .padding()
    }

    private var permissionsPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "location.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(BirdVaultTheme.primaryGreen)

            VStack(spacing: 8) {
                Text("Enable Location")
                    .font(.title2.weight(.bold))

                Text("BirdVault uses your location to suggest nearby birds and mark your sighting locations on the map.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
            }

            if locationManager.isAuthorized {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Location enabled!")
                        .font(.headline)
                }
                .padding()
            } else {
                Button {
                    locationManager.requestPermission()
                } label: {
                    Label("Enable Location", systemImage: "location.fill")
                }
                .buttonStyle(.birdSecondary)
                .padding(.horizontal, 40)

                Button("Maybe Later") {
                    withAnimation { currentPage += 1 }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            MascotBubbleView(
                message: "Location helps me figure out which birds you might spot nearby. It's like having a field guide that knows where you are!",
                mascotSize: 40
            )

            Spacer()
            Spacer()
        }
        .padding()
    }

    private var profileSetupPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Create Your Profile")
                .font(.title2.weight(.bold))

            // Emoji picker
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(BirdVaultTheme.lightGreen)
                        .frame(width: 100, height: 100)
                    Text(selectedEmoji)
                        .font(.system(size: 50))
                }

                Text("Choose your avatar")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(avatarEmojis, id: \.self) { emoji in
                            Button {
                                selectedEmoji = emoji
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 30))
                                    .frame(width: 48, height: 48)
                                    .background(
                                        selectedEmoji == emoji
                                            ? BirdVaultTheme.primaryGreen.opacity(0.15)
                                            : Color(.systemGray6),
                                        in: Circle()
                                    )
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                selectedEmoji == emoji
                                                    ? BirdVaultTheme.primaryGreen
                                                    : .clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // Name input
            VStack(alignment: .leading, spacing: 8) {
                Text("Display Name")
                    .font(.subheadline.weight(.medium))

                TextField("Enter your birder name", text: $userName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 40)
            }

            MascotBubbleView(
                message: "Pick a name and avatar that represent your birding spirit! You can always change these later.",
                mascotSize: 40
            )

            Spacer()
            Spacer()
        }
        .padding()
    }

    // MARK: - Helpers

    private let avatarEmojis = ["🐦", "🦅", "🦉", "🐧", "🦜", "🦆", "🕊️", "🦩", "🐤", "🪶", "🦚", "🐦‍⬛"]

    private func backgroundColorForPage(_ page: Int) -> Color {
        switch page {
        case 0: return BirdVaultTheme.primaryGreen
        case 1: return BirdVaultTheme.skyBlue
        case 2: return BirdVaultTheme.warmAmber
        case 3: return BirdVaultTheme.primaryGreen
        case 4: return BirdVaultTheme.skyBlue
        default: return BirdVaultTheme.primaryGreen
        }
    }

    private func completeOnboarding() {
        let profile = UserProfile(
            displayName: userName.isEmpty ? "Birder" : userName,
            avatarEmoji: selectedEmoji
        )
        modelContext.insert(profile)
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Supporting Views

private struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .modelContainer(for: [BirdSighting.self, UserProfile.self, SocialPost.self], inMemory: true)
        .environmentObject(LocationManager())
}
