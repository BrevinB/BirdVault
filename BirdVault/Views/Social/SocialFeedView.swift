import SwiftUI
import SwiftData

/// Community feed showing shared bird sightings from all users.
struct SocialFeedView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SocialPost.timestamp, order: .reverse) private var posts: [SocialPost]
    @Query private var profiles: [UserProfile]
    @State private var showingNewPost = false
    @State private var hasLoadedSampleData = false
    @State private var showMascotTip = true

    private let birdService = BirdDataService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Mascot tip
                    if showMascotTip && posts.isEmpty {
                        MascotBubbleView(
                            message: "This is where the birding community comes together! Share your sightings and see what others have found. It's like a social network, but for birds!",
                            showDismiss: true,
                            onDismiss: { withAnimation { showMascotTip = false } }
                        )
                    }

                    // Community stats
                    communityStatsBar

                    if posts.isEmpty {
                        emptyFeedView
                    } else {
                        // Feed posts
                        LazyVStack(spacing: 16) {
                            ForEach(posts) { post in
                                SocialPostCardView(post: post)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Community")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if posts.isEmpty {
                            loadSamplePosts()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                if !hasLoadedSampleData && posts.isEmpty {
                    loadSamplePosts()
                    hasLoadedSampleData = true
                }
            }
        }
    }

    private var communityStatsBar: some View {
        HStack(spacing: 0) {
            CommunityStatView(value: "\(posts.count)", label: "Posts", icon: "text.bubble.fill")
            Divider().frame(height: 35)
            CommunityStatView(
                value: "\(Set(posts.map { $0.authorName }).count)",
                label: "Birders",
                icon: "person.2.fill"
            )
            Divider().frame(height: 35)
            CommunityStatView(
                value: "\(Set(posts.map { $0.birdSpeciesID }).count)",
                label: "Species",
                icon: "bird.fill"
            )
        }
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var emptyFeedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)

            Text("The feed is quiet...")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Pull to refresh or tap the refresh button to load community posts")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
    }

    private func loadSamplePosts() {
        let samplePosts = SocialService.shared.generateSamplePosts()
        for post in samplePosts {
            modelContext.insert(post)
        }
    }
}

// MARK: - Post Card

struct SocialPostCardView: View {
    let post: SocialPost
    @Environment(\.modelContext) private var modelContext

    private let birdService = BirdDataService.shared

    private var bird: Bird? {
        birdService.bird(for: post.birdSpeciesID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(BirdVaultTheme.lightGreen)
                        .frame(width: 40, height: 40)
                    Text(post.authorEmoji)
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(.subheadline.weight(.semibold))

                    HStack(spacing: 4) {
                        if !post.locationName.isEmpty {
                            Text(post.locationName)
                        }
                        Text("•")
                        Text(post.timestamp, style: .relative)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                if let bird = bird {
                    Text(bird.rarityTier.rawValue)
                        .rarityBadge(bird.rarityTier)
                }
            }

            // Bird info
            if let bird = bird {
                HStack(spacing: 12) {
                    Text(emojiForBird(bird))
                        .font(.system(size: 36))
                        .frame(width: 56, height: 56)
                        .background(
                            BirdVaultTheme.colorForRarity(bird.rarityTier).opacity(0.12),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(bird.commonName)
                            .font(.body.weight(.semibold))

                        HStack(spacing: 4) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundStyle(post.isMale ? .blue : .pink)
                            Text(post.isMale ? "Male" : "Female")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // Caption
            Text(post.caption)
                .font(.body)

            // Photo placeholder (using bird emoji as visual)
            if let bird = bird {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    BirdVaultTheme.colorForRarity(bird.rarityTier).opacity(0.15),
                                    BirdVaultTheme.colorForRarity(bird.rarityTier).opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 180)

                    VStack(spacing: 8) {
                        Text(emojiForBird(bird))
                            .font(.system(size: 64))
                        Text(bird.commonName)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Action bar
            HStack(spacing: 20) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        post.isLikedByUser.toggle()
                        post.likeCount += post.isLikedByUser ? 1 : -1
                    }
                } label: {
                    Label(
                        "\(post.likeCount)",
                        systemImage: post.isLikedByUser ? "heart.fill" : "heart"
                    )
                    .foregroundStyle(post.isLikedByUser ? .red : .secondary)
                }

                Label("\(post.comments.count)", systemImage: "bubble.right")
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    // Share action
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.subheadline)

            // Comments preview
            if !post.comments.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(post.comments.prefix(2)) { comment in
                        HStack(alignment: .top, spacing: 6) {
                            Text(comment.authorEmoji)
                                .font(.caption)
                            Text("**\(comment.authorName)** \(comment.text)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct CommunityStatView: View {
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

#Preview {
    SocialFeedView()
        .modelContainer(for: [BirdSighting.self, UserProfile.self, SocialPost.self], inMemory: true)
}
