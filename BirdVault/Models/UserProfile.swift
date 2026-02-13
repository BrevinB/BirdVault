import Foundation
import SwiftData

/// The user's profile information persisted with SwiftData.
@Model
final class UserProfile {
    var id: UUID
    var displayName: String
    var bio: String
    var avatarEmoji: String
    var joinDate: Date
    var totalSightings: Int
    var uniqueSpecies: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastSightingDate: Date?
    var favoriteRegion: String
    var achievements: [String] // Achievement IDs

    init(
        displayName: String = "Birder",
        bio: String = "Just started my birding journey!",
        avatarEmoji: String = "🐦",
        joinDate: Date = .now
    ) {
        self.id = UUID()
        self.displayName = displayName
        self.bio = bio
        self.avatarEmoji = avatarEmoji
        self.joinDate = joinDate
        self.totalSightings = 0
        self.uniqueSpecies = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastSightingDate = nil
        self.favoriteRegion = ""
        self.achievements = []
    }
}

/// Achievement definitions
struct Achievement: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requirement: Int
    let category: AchievementCategory

    enum AchievementCategory: String {
        case collection = "Collection"
        case exploration = "Exploration"
        case social = "Social"
        case dedication = "Dedication"
        case rarity = "Rarity"
    }
}

extension Achievement {
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_catch", name: "First Feather", description: "Log your first bird sighting", icon: "🪶", requirement: 1, category: .collection),
        Achievement(id: "ten_species", name: "Fledgling Spotter", description: "Discover 10 unique species", icon: "🐣", requirement: 10, category: .collection),
        Achievement(id: "twentyfive_species", name: "Sharp Eyes", description: "Discover 25 unique species", icon: "👀", requirement: 25, category: .collection),
        Achievement(id: "fifty_species", name: "Avian Expert", description: "Discover 50 unique species", icon: "🦅", requirement: 50, category: .collection),
        Achievement(id: "hundred_species", name: "Master Birder", description: "Discover 100 unique species", icon: "🏆", requirement: 100, category: .collection),
        Achievement(id: "pair_collector", name: "Perfect Pair", description: "Collect both male and female of a species", icon: "💑", requirement: 1, category: .collection),
        Achievement(id: "ten_pairs", name: "Matchmaker", description: "Collect 10 male/female pairs", icon: "❤️", requirement: 10, category: .collection),
        Achievement(id: "three_day_streak", name: "Getting Hooked", description: "Log birds 3 days in a row", icon: "🔥", requirement: 3, category: .dedication),
        Achievement(id: "seven_day_streak", name: "Weekly Watcher", description: "Log birds 7 days in a row", icon: "📅", requirement: 7, category: .dedication),
        Achievement(id: "thirty_day_streak", name: "Devoted Birder", description: "Log birds 30 days in a row", icon: "⭐", requirement: 30, category: .dedication),
        Achievement(id: "rare_find", name: "Rare Discovery", description: "Spot a Rare tier bird", icon: "💎", requirement: 1, category: .rarity),
        Achievement(id: "legendary_find", name: "Legendary Encounter", description: "Spot a Legendary tier bird", icon: "👑", requirement: 1, category: .rarity),
        Achievement(id: "share_first", name: "Show and Tell", description: "Share your first sighting to the feed", icon: "📢", requirement: 1, category: .social),
        Achievement(id: "five_regions", name: "Wanderer", description: "Log birds in 5 different regions", icon: "🗺️", requirement: 5, category: .exploration),
        Achievement(id: "early_bird", name: "Early Bird", description: "Log a sighting before 6 AM", icon: "🌅", requirement: 1, category: .dedication),
    ]
}
