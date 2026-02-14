import Foundation
import UIKit
import Vision

/// Result of an automatic bird species detection attempt.
struct BirdDetectionResult: Identifiable {
    let id = UUID()
    let bird: Bird
    let confidence: Float
}

/// Service that uses Apple's Vision framework to automatically detect bird species from photos.
/// Maps VNClassifyImageRequest results to the BirdVault catalog.
final class BirdDetectionService {
    static let shared = BirdDetectionService()

    private let birdService = BirdDataService.shared

    /// Maps lowercased Vision classifier labels to bird catalog IDs.
    /// These labels come from Apple's VNClassifyImageRequest taxonomy.
    private let classifierLabelToBirdID: [String: String] = [
        // Cardinals & Grosbeaks
        "northern cardinal": "northern_cardinal",
        "cardinal": "northern_cardinal",
        "cardinalis cardinalis": "northern_cardinal",
        "rose-breasted grosbeak": "rose_breasted_grosbeak",
        "grosbeak": "rose_breasted_grosbeak",

        // Jays & Corvids
        "blue jay": "blue_jay",
        "jay": "blue_jay",
        "american crow": "american_crow",
        "crow": "american_crow",
        "steller's jay": "stellers_jay",

        // Woodpeckers
        "downy woodpecker": "downy_woodpecker",
        "pileated woodpecker": "pileated_woodpecker",
        "red-bellied woodpecker": "red_bellied_woodpecker",
        "woodpecker": "downy_woodpecker",

        // Raptors
        "bald eagle": "bald_eagle",
        "eagle": "bald_eagle",
        "red-tailed hawk": "red_tailed_hawk",
        "hawk": "red_tailed_hawk",
        "peregrine falcon": "peregrine_falcon",
        "falcon": "peregrine_falcon",
        "american kestrel": "american_kestrel",
        "kestrel": "american_kestrel",
        "osprey": "osprey",

        // Owls
        "great horned owl": "great_horned_owl",
        "owl": "great_horned_owl",
        "barred owl": "barred_owl",
        "snowy owl": "snowy_owl",

        // Hummingbirds
        "ruby-throated hummingbird": "ruby_throated_hummingbird",
        "anna's hummingbird": "annas_hummingbird",
        "hummingbird": "ruby_throated_hummingbird",

        // Warblers
        "yellow warbler": "yellow_warbler",
        "warbler": "yellow_warbler",
        "black-throated blue warbler": "black_throated_blue_warbler",

        // Thrushes
        "american robin": "american_robin",
        "robin": "american_robin",
        "eastern bluebird": "eastern_bluebird",
        "bluebird": "eastern_bluebird",
        "wood thrush": "wood_thrush",
        "thrush": "wood_thrush",

        // Finches
        "american goldfinch": "american_goldfinch",
        "goldfinch": "american_goldfinch",
        "house finch": "house_finch",
        "finch": "house_finch",
        "purple finch": "purple_finch",

        // Waterfowl
        "mallard": "mallard",
        "mallard duck": "mallard",
        "duck": "mallard",
        "wood duck": "wood_duck",
        "great blue heron": "great_blue_heron",
        "heron": "great_blue_heron",

        // Sparrows
        "white-throated sparrow": "white_throated_sparrow",
        "song sparrow": "song_sparrow",
        "sparrow": "song_sparrow",

        // Blackbirds & Orioles
        "red-winged blackbird": "red_winged_blackbird",
        "blackbird": "red_winged_blackbird",
        "baltimore oriole": "baltimore_oriole",
        "oriole": "baltimore_oriole",

        // Chickadees & Titmice
        "black-capped chickadee": "black_capped_chickadee",
        "chickadee": "black_capped_chickadee",
        "tufted titmouse": "tufted_titmouse",
        "titmouse": "tufted_titmouse",

        // Nuthatches & Wrens
        "white-breasted nuthatch": "white_breasted_nuthatch",
        "nuthatch": "white_breasted_nuthatch",
        "carolina wren": "carolina_wren",
        "wren": "carolina_wren",

        // Shorebirds & Swallows
        "killdeer": "killdeer",
        "barn swallow": "barn_swallow",
        "swallow": "barn_swallow",

        // Tanagers & Kingfishers
        "scarlet tanager": "scarlet_tanager",
        "tanager": "scarlet_tanager",
        "belted kingfisher": "belted_kingfisher",
        "kingfisher": "belted_kingfisher",

        // Specialty species
        "painted bunting": "painted_bunting",
        "bunting": "painted_bunting",
        "california condor": "california_condor",
        "condor": "california_condor",
        "whooping crane": "whooping_crane",
        "crane": "whooping_crane",
        "atlantic puffin": "atlantic_puffin",
        "puffin": "atlantic_puffin",

        // Additional species
        "mourning dove": "mourning_dove",
        "dove": "mourning_dove",
        "dark-eyed junco": "dark_eyed_junco",
        "junco": "dark_eyed_junco",
        "northern mockingbird": "northern_mockingbird",
        "mockingbird": "northern_mockingbird",
        "cedar waxwing": "cedar_waxwing",
        "waxwing": "cedar_waxwing",
        "indigo bunting": "indigo_bunting",
        "eastern phoebe": "eastern_phoebe",
        "phoebe": "eastern_phoebe",
        "red-eyed vireo": "red_eyed_vireo",
        "vireo": "red_eyed_vireo",
        "roseate spoonbill": "roseate_spoonbill",
        "spoonbill": "roseate_spoonbill",
        "magnificent frigatebird": "magnificent_frigatebird",
        "frigatebird": "magnificent_frigatebird",
        "nene": "nene",
        "hawaiian goose": "nene",
        "willow ptarmigan": "willow_ptarmigan",
        "ptarmigan": "willow_ptarmigan",
    ]

    private init() {}

    // MARK: - Public API

    /// Analyzes the given image data and returns bird species suggestions ranked by confidence.
    /// - Parameter imageData: JPEG or PNG image data of the bird photo.
    /// - Returns: An array of `BirdDetectionResult` sorted by confidence (highest first).
    func detectBird(from imageData: Data) async -> [BirdDetectionResult] {
        guard let image = UIImage(data: imageData),
              let cgImage = image.cgImage else {
            return []
        }

        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { [weak self] request, error in
                guard let self = self,
                      error == nil,
                      let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let results = self.mapObservationsToBirds(observations)
                continuation.resume(returning: results)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: [])
            }
        }
    }

    // MARK: - Private Helpers

    /// Maps Vision classification observations to BirdVault catalog entries.
    private func mapObservationsToBirds(_ observations: [VNClassificationObservation]) -> [BirdDetectionResult] {
        var seen = Set<String>()
        var results: [BirdDetectionResult] = []

        // First pass: look for direct label matches in the classifier output
        for observation in observations where observation.confidence > 0.01 {
            let label = observation.identifier.lowercased()

            if let birdID = classifierLabelToBirdID[label],
               !seen.contains(birdID),
               let bird = birdService.bird(for: birdID) {
                seen.insert(birdID)
                results.append(BirdDetectionResult(bird: bird, confidence: observation.confidence))
            }
        }

        // Second pass: fuzzy match against catalog common names
        for observation in observations where observation.confidence > 0.01 {
            let label = observation.identifier.lowercased()

            for bird in birdService.allBirds where !seen.contains(bird.id) {
                let commonLower = bird.commonName.lowercased()
                let scientificLower = bird.scientificName.lowercased()

                if commonLower.contains(label) || label.contains(commonLower) ||
                   scientificLower.contains(label) || label.contains(scientificLower) {
                    seen.insert(bird.id)
                    results.append(BirdDetectionResult(bird: bird, confidence: observation.confidence))
                }
            }
        }

        // Sort by confidence descending, limit to top 5 suggestions
        return Array(results.sorted { $0.confidence > $1.confidence }.prefix(5))
    }
}
