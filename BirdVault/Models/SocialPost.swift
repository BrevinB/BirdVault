import Foundation
import SwiftData

/// A social feed post representing a shared bird sighting.
@Model
final class SocialPost {
    var id: UUID
    var authorName: String
    var authorEmoji: String
    var birdSpeciesID: String
    var caption: String
    var photoData: Data?
    var locationName: String
    var timestamp: Date
    var likeCount: Int
    var isLikedByUser: Bool
    var isMale: Bool
    var comments: [PostComment]

    init(
        authorName: String,
        authorEmoji: String = "🐦",
        birdSpeciesID: String,
        caption: String,
        photoData: Data? = nil,
        locationName: String = "",
        timestamp: Date = .now,
        isMale: Bool = true
    ) {
        self.id = UUID()
        self.authorName = authorName
        self.authorEmoji = authorEmoji
        self.birdSpeciesID = birdSpeciesID
        self.caption = caption
        self.photoData = photoData
        self.locationName = locationName
        self.timestamp = timestamp
        self.likeCount = Int.random(in: 0...50)
        self.isLikedByUser = false
        self.isMale = isMale
        self.comments = []
    }
}

/// A comment on a social post.
struct PostComment: Codable, Identifiable {
    var id: UUID
    var authorName: String
    var authorEmoji: String
    var text: String
    var timestamp: Date

    init(authorName: String, authorEmoji: String = "🐦", text: String, timestamp: Date = .now) {
        self.id = UUID()
        self.authorName = authorName
        self.authorEmoji = authorEmoji
        self.text = text
        self.timestamp = timestamp
    }
}
