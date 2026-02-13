import SwiftUI
import SwiftData
import PhotosUI

/// The capture flow for logging a new bird sighting.
struct CaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var locationManager: LocationManager
    @Query private var profiles: [UserProfile]

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var capturedImageData: Data?
    @State private var showingBirdPicker = false
    @State private var showingCamera = false
    @State private var showingSuccess = false
    @State private var selectedBird: Bird?
    @State private var isMale = true
    @State private var notes = ""
    @State private var showMascotTip = true

    private let birdService = BirdDataService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Mascot tip
                    if showMascotTip {
                        MascotBubbleView(
                            message: "Snap a photo of a bird, then tell me what species it is. I'll log it in your Pokédex with the location and everything!",
                            showDismiss: true,
                            onDismiss: { withAnimation { showMascotTip = false } }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Photo capture area
                    photoSection

                    // Bird selection
                    if capturedImageData != nil {
                        birdSelectionSection
                    }

                    // Details
                    if selectedBird != nil && capturedImageData != nil {
                        detailsSection
                        logButton
                    }
                }
                .padding()
            }
            .navigationTitle("Capture")
            .sheet(isPresented: $showingBirdPicker) {
                BirdPickerView(selectedBird: $selectedBird)
            }
            .overlay {
                if showingSuccess {
                    successOverlay
                }
            }
        }
    }

    // MARK: - Sections

    private var photoSection: some View {
        VStack(spacing: 16) {
            if let imageData = capturedImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            withAnimation {
                                capturedImageData = nil
                                selectedBird = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .black.opacity(0.5))
                        }
                        .padding(12)
                    }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 60))
                        .foregroundStyle(BirdVaultTheme.primaryGreen.opacity(0.5))

                    Text("Add a photo of your bird")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 16) {
                        Button {
                            showingCamera = true
                        } label: {
                            Label("Camera", systemImage: "camera.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.birdPrimary)

                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label("Library", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.birdSecondary)
                    }
                }
                .frame(height: 250)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraViewRepresentable(imageData: $capturedImageData)
                .ignoresSafeArea()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    withAnimation {
                        capturedImageData = data
                    }
                }
            }
        }
    }

    private var birdSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What bird is this?")
                .font(.headline)

            if let bird = selectedBird {
                HStack(spacing: 12) {
                    Text(emojiForBird(bird))
                        .font(.largeTitle)
                        .frame(width: 55, height: 55)
                        .background(
                            BirdVaultTheme.colorForRarity(bird.rarityTier).opacity(0.15),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(bird.commonName)
                            .font(.body.weight(.semibold))
                        RarityStarsView(rarity: bird.rarityTier)
                    }

                    Spacer()

                    Button("Change") {
                        showingBirdPicker = true
                    }
                    .font(.subheadline)
                }
                .cardStyle(padding: 12)
            } else {
                Button {
                    showingBirdPicker = true
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search for the bird species")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(.secondary)
                }
                .cardStyle(padding: 14)
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)

            // Male/Female toggle
            VStack(alignment: .leading, spacing: 8) {
                Text("Sex")
                    .font(.subheadline.weight(.medium))

                Picker("Sex", selection: $isMale) {
                    Label("Male", systemImage: "circle.fill")
                        .foregroundStyle(.blue)
                        .tag(true)
                    Label("Female", systemImage: "circle.fill")
                        .foregroundStyle(.pink)
                        .tag(false)
                }
                .pickerStyle(.segmented)
            }

            // Location
            VStack(alignment: .leading, spacing: 8) {
                Text("Location")
                    .font(.subheadline.weight(.medium))

                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(BirdVaultTheme.primaryGreen)
                    Text(locationManager.locationName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Notes
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes (optional)")
                    .font(.subheadline.weight(.medium))

                TextField("Any observations...", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(12)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var logButton: some View {
        Button {
            logSighting()
        } label: {
            Label("Log This Sighting", systemImage: "checkmark.circle.fill")
        }
        .buttonStyle(.birdPrimary)
    }

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(BirdVaultTheme.primaryGreen)
                    .symbolEffect(.bounce, value: showingSuccess)

                Text("Sighting Logged!")
                    .font(.title2.weight(.bold))

                if let bird = selectedBird {
                    Text("\(bird.commonName) added to your Pokédex!")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button("Continue") {
                    withAnimation {
                        showingSuccess = false
                        resetForm()
                    }
                }
                .buttonStyle(.birdPrimary)
                .padding(.horizontal, 40)
            }
            .padding(30)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(30)
        }
        .transition(.opacity)
    }

    // MARK: - Actions

    private func logSighting() {
        guard let bird = selectedBird else { return }

        let compressedData = compressImage(capturedImageData)

        let sighting = BirdSighting(
            birdSpeciesID: bird.id,
            latitude: locationManager.currentLocation?.coordinate.latitude ?? 0,
            longitude: locationManager.currentLocation?.coordinate.longitude ?? 0,
            locationName: locationManager.locationName,
            notes: notes,
            photoData: compressedData,
            isMale: isMale
        )

        modelContext.insert(sighting)

        // Update profile stats
        if let profile = profiles.first {
            profile.totalSightings += 1
            profile.lastSightingDate = Date()
        }

        withAnimation(.spring(response: 0.4)) {
            showingSuccess = true
        }
    }

    private func resetForm() {
        capturedImageData = nil
        selectedBird = nil
        isMale = true
        notes = ""
        selectedPhotoItem = nil
    }

    private func compressImage(_ data: Data?) -> Data? {
        guard let data = data, let image = UIImage(data: data) else { return nil }
        return image.jpegData(compressionQuality: 0.6)
    }
}

// MARK: - Bird Picker

struct BirdPickerView: View {
    @Binding var selectedBird: Bird?
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private let birdService = BirdDataService.shared

    private var filteredBirds: [Bird] {
        if searchText.isEmpty {
            return birdService.allBirds
        }
        return birdService.birds(matching: searchText)
    }

    var body: some View {
        NavigationStack {
            List(filteredBirds) { bird in
                Button {
                    selectedBird = bird
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(emojiForBird(bird))
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background(
                                BirdVaultTheme.colorForRarity(bird.rarityTier).opacity(0.12),
                                in: Circle()
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(bird.commonName)
                                .font(.body.weight(.medium))
                                .foregroundStyle(.primary)
                            Text(bird.scientificName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .italic()
                        }

                        Spacer()

                        RarityStarsView(rarity: bird.rarityTier)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search bird species...")
            .navigationTitle("Select Bird")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Camera Representable

struct CameraViewRepresentable: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraViewRepresentable

        init(_ parent: CameraViewRepresentable) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.imageData = image.jpegData(compressionQuality: 0.8)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    CaptureView()
        .modelContainer(for: [BirdSighting.self, UserProfile.self, SocialPost.self], inMemory: true)
        .environmentObject(LocationManager())
}
