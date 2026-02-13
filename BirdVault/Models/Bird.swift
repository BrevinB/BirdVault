import Foundation

/// Represents a species of bird in the BirdVault database.
/// This is a reference data model - not persisted in SwiftData, loaded from the bundled catalog.
struct Bird: Identifiable, Codable, Hashable {
    let id: String // Unique species identifier (e.g., "northern_cardinal")
    let commonName: String
    let scientificName: String
    let family: String
    let order: String
    let description: String
    let habitat: String
    let diet: String
    let funFact: String
    let conservationStatus: ConservationStatus
    let regions: [BirdRegion]
    let rarityTier: RarityTier
    let hasSexualDimorphism: Bool // Whether male/female look different
    let maleDescription: String
    let femaleDescription: String
    let seasonalPresence: [Season]
    let sizeCategory: SizeCategory
    let primaryColors: [BirdColor]
    let song: String // Text description of the bird's song

    /// Pokedex-style number for display
    var pokedexNumber: String {
        String(format: "#%03d", abs(id.hashValue) % 999 + 1)
    }

    /// SF Symbol name for the bird's size category
    var sizeIcon: String {
        switch sizeCategory {
        case .tiny: return "bird"
        case .small: return "bird"
        case .medium: return "bird.fill"
        case .large: return "bird.fill"
        case .veryLarge: return "bird.fill"
        }
    }
}

enum ConservationStatus: String, Codable, CaseIterable {
    case leastConcern = "Least Concern"
    case nearThreatened = "Near Threatened"
    case vulnerable = "Vulnerable"
    case endangered = "Endangered"
    case criticallyEndangered = "Critically Endangered"

    var color: String {
        switch self {
        case .leastConcern: return "green"
        case .nearThreatened: return "yellow"
        case .vulnerable: return "orange"
        case .endangered: return "red"
        case .criticallyEndangered: return "purple"
        }
    }

    var icon: String {
        switch self {
        case .leastConcern: return "checkmark.shield.fill"
        case .nearThreatened: return "exclamationmark.shield.fill"
        case .vulnerable: return "exclamationmark.triangle.fill"
        case .endangered: return "xmark.shield.fill"
        case .criticallyEndangered: return "xmark.octagon.fill"
        }
    }
}

enum RarityTier: String, Codable, CaseIterable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case veryRare = "Very Rare"
    case legendary = "Legendary"

    var stars: Int {
        switch self {
        case .common: return 1
        case .uncommon: return 2
        case .rare: return 3
        case .veryRare: return 4
        case .legendary: return 5
        }
    }

    var color: String {
        switch self {
        case .common: return "gray"
        case .uncommon: return "green"
        case .rare: return "blue"
        case .veryRare: return "purple"
        case .legendary: return "orange"
        }
    }
}

enum BirdRegion: String, Codable, CaseIterable {
    case northeast = "Northeast"
    case southeast = "Southeast"
    case midwest = "Midwest"
    case southwest = "Southwest"
    case west = "West"
    case northwest = "Northwest"
    case greatPlains = "Great Plains"
    case florida = "Florida"
    case texas = "Texas"
    case california = "California"
    case alaska = "Alaska"
    case hawaii = "Hawaii"
    case nationwide = "Nationwide"
}

enum Season: String, Codable, CaseIterable {
    case spring = "Spring"
    case summer = "Summer"
    case fall = "Fall"
    case winter = "Winter"
    case yearRound = "Year-Round"
}

enum SizeCategory: String, Codable, CaseIterable {
    case tiny = "Tiny" // Hummingbirds
    case small = "Small" // Sparrows, Warblers
    case medium = "Medium" // Robins, Jays
    case large = "Large" // Hawks, Crows
    case veryLarge = "Very Large" // Eagles, Herons

    var rangeInches: String {
        switch self {
        case .tiny: return "2-4 in"
        case .small: return "4-7 in"
        case .medium: return "7-12 in"
        case .large: return "12-24 in"
        case .veryLarge: return "24+ in"
        }
    }
}

enum BirdColor: String, Codable, CaseIterable {
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case green = "Green"
    case blue = "Blue"
    case purple = "Purple"
    case black = "Black"
    case white = "White"
    case brown = "Brown"
    case gray = "Gray"
    case iridescent = "Iridescent"
}
