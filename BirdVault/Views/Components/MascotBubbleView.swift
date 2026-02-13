import SwiftUI

/// The app mascot "Pip" with a speech bubble for guiding the user.
struct MascotBubbleView: View {
    let message: String
    var mascotSize: CGFloat = 50
    var showDismiss: Bool = false
    var onDismiss: (() -> Void)? = nil

    @State private var isAnimating = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Mascot avatar
            ZStack {
                Circle()
                    .fill(BirdVaultTheme.lightGreen)
                    .frame(width: mascotSize, height: mascotSize)

                Text("🐦‍⬛")
                    .font(.system(size: mascotSize * 0.55))
                    .offset(y: isAnimating ? -2 : 2)
                    .animation(
                        .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }

            // Speech bubble
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Pip")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(BirdVaultTheme.primaryGreen)

                    Spacer()

                    if showDismiss {
                        Button {
                            onDismiss?()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(
                BirdVaultTheme.lightGreen.opacity(0.5),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
        .padding(.horizontal)
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MascotBubbleView(
            message: "Welcome to BirdVault! Let's start your birding adventure. Head outside and snap a photo of any bird you see!",
            showDismiss: true
        )

        MascotBubbleView(
            message: "Tip: Early mornings are the best time to spot birds!",
            mascotSize: 40
        )
    }
}
