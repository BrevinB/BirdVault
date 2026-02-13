import SwiftUI

/// BirdVault's design system conforming to Apple Human Interface Guidelines.
/// Uses a nature-inspired color palette with clean, modern typography.
enum BirdVaultTheme {

    // MARK: - Color Palette

    /// Primary brand color - Forest Green
    static let primaryGreen = Color(red: 0.20, green: 0.49, blue: 0.22)
    /// Lighter variant for backgrounds
    static let lightGreen = Color(red: 0.85, green: 0.93, blue: 0.85)
    /// Deep forest for text on light backgrounds
    static let deepForest = Color(red: 0.10, green: 0.28, blue: 0.12)

    /// Secondary - Sky Blue
    static let skyBlue = Color(red: 0.30, green: 0.65, blue: 0.90)
    static let lightSky = Color(red: 0.88, green: 0.94, blue: 0.98)

    /// Accent - Warm Amber (for highlights and CTAs)
    static let warmAmber = Color(red: 0.95, green: 0.68, blue: 0.20)
    static let softAmber = Color(red: 0.98, green: 0.92, blue: 0.80)

    /// Earth tones
    static let earthBrown = Color(red: 0.55, green: 0.38, blue: 0.24)
    static let sandstone = Color(red: 0.96, green: 0.93, blue: 0.88)

    /// Rarity colors
    static let rarityCommon = Color.gray
    static let rarityUncommon = Color(red: 0.30, green: 0.69, blue: 0.31)
    static let rarityRare = Color(red: 0.25, green: 0.47, blue: 0.85)
    static let rarityVeryRare = Color(red: 0.61, green: 0.32, blue: 0.84)
    static let rarityLegendary = Color(red: 0.95, green: 0.60, blue: 0.07)

    /// Surface colors
    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)

    // MARK: - Rarity Helpers

    static func colorForRarity(_ rarity: RarityTier) -> Color {
        switch rarity {
        case .common: return rarityCommon
        case .uncommon: return rarityUncommon
        case .rare: return rarityRare
        case .veryRare: return rarityVeryRare
        case .legendary: return rarityLegendary
        }
    }

    static func gradientForRarity(_ rarity: RarityTier) -> LinearGradient {
        let color = colorForRarity(rarity)
        return LinearGradient(
            colors: [color.opacity(0.8), color],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Conservation Colors

    static func colorForConservation(_ status: ConservationStatus) -> Color {
        switch status {
        case .leastConcern: return .green
        case .nearThreatened: return .yellow
        case .vulnerable: return .orange
        case .endangered: return .red
        case .criticallyEndangered: return .purple
        }
    }

    // MARK: - Size Category Colors

    static func emojiForSize(_ size: SizeCategory) -> String {
        switch size {
        case .tiny: return "🐝"
        case .small: return "🐦"
        case .medium: return "🕊️"
        case .large: return "🦅"
        case .veryLarge: return "🦤"
        }
    }

    // MARK: - Mascot

    static let mascotName = "Pip"
    static let mascotEmoji = "🐦‍⬛"
    static let mascotFullName = "Pip the Guide"
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

struct RarityBadgeStyle: ViewModifier {
    let rarity: RarityTier

    func body(content: Content) -> some View {
        content
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(BirdVaultTheme.colorForRarity(rarity), in: Capsule())
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardStyle(padding: padding))
    }

    func rarityBadge(_ rarity: RarityTier) -> some View {
        modifier(RarityBadgeStyle(rarity: rarity))
    }
}

// MARK: - Custom Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                BirdVaultTheme.primaryGreen
                    .opacity(configuration.isPressed ? 0.8 : 1.0),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(BirdVaultTheme.primaryGreen)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                BirdVaultTheme.lightGreen
                    .opacity(configuration.isPressed ? 0.6 : 1.0),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var birdPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var birdSecondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}
