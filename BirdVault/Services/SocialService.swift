import Foundation
import SwiftData

/// Service for managing social feed posts. In MVP this creates simulated community posts
/// to demonstrate the social features. In a production app, this would connect to a backend.
final class SocialService {
    static let shared = SocialService()

    private init() {}

    /// Generate sample community posts to populate the feed for MVP demonstration.
    func generateSamplePosts() -> [SocialPost] {
        let birdService = BirdDataService.shared
        let sampleUsers: [(name: String, emoji: String)] = [
            ("BirdNerd42", "🦜"),
            ("WingWatcher", "🪶"),
            ("FeatheredFriend", "🐤"),
            ("NestHunter", "🥚"),
            ("SkyTracker", "☁️"),
            ("MigrationMax", "🧭"),
            ("TalonTina", "🦅"),
            ("WarblerWiz", "🎵"),
            ("HawkEyeHank", "👁️"),
            ("PelicanPete", "🐟"),
        ]

        let captions = [
            "Just spotted this beauty in my backyard! What a morning! 🌅",
            "Finally found one after searching all week. So worth it!",
            "This one was singing its heart out at the park today.",
            "Can you believe this was just hanging out by the parking lot?",
            "My best photo yet! Patience really pays off.",
            "Nature walk delivered today. Incredible encounter!",
            "Added a new one to the collection! The hunt continues...",
            "Spotted from my kitchen window. Best breakfast companion ever.",
            "Third time this week seeing this one. I think it knows me now.",
            "Early morning session at the nature reserve. Magic hour!",
            "Found this rare beauty at the wetlands. My hands were shaking!",
            "Day 5 of my birding streak. Can't stop, won't stop!",
        ]

        let locations = [
            "Central Park, NY", "Golden Gate Park, SF", "Everglades, FL",
            "Yellowstone, WY", "Cape Cod, MA", "Point Reyes, CA",
            "Great Smoky Mtns, TN", "Boundary Waters, MN", "Big Bend, TX",
            "Olympic NP, WA", "Backyard feeder", "Local nature trail",
        ]

        var posts: [SocialPost] = []
        let selectedBirds = birdService.allBirds.shuffled().prefix(15)

        for (index, bird) in selectedBirds.enumerated() {
            let user = sampleUsers[index % sampleUsers.count]
            let post = SocialPost(
                authorName: user.name,
                authorEmoji: user.emoji,
                birdSpeciesID: bird.id,
                caption: captions[index % captions.count],
                locationName: locations[index % locations.count],
                timestamp: Date().addingTimeInterval(TimeInterval(-index * 3600 * Int.random(in: 1...8))),
                isMale: Bool.random()
            )
            post.likeCount = Int.random(in: 2...120)

            // Add some sample comments
            if index % 2 == 0 {
                let commenter = sampleUsers[(index + 3) % sampleUsers.count]
                let commentTexts = [
                    "Amazing find! So jealous! 😍",
                    "I've been looking for one of these for weeks!",
                    "Beautiful photo! What camera are you using?",
                    "Nice! I saw one of these last month too.",
                    "Welcome to the club! That's a great species to find.",
                ]
                post.comments = [
                    PostComment(
                        authorName: commenter.name,
                        authorEmoji: commenter.emoji,
                        text: commentTexts[index % commentTexts.count],
                        timestamp: post.timestamp.addingTimeInterval(TimeInterval(Int.random(in: 600...7200)))
                    )
                ]
            }

            posts.append(post)
        }

        return posts.sorted { $0.timestamp > $1.timestamp }
    }
}
