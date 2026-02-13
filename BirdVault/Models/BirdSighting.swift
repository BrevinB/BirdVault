import Foundation
import SwiftData
import CoreLocation

/// A recorded sighting of a bird by the user, persisted with SwiftData.
@Model
final class BirdSighting {
    var id: UUID
    var birdSpeciesID: String
    var dateSighted: Date
    var latitude: Double
    var longitude: Double
    var locationName: String
    var notes: String
    var photoData: Data?
    var isMale: Bool
    var weather: String
    var isSharedToFeed: Bool

    init(
        birdSpeciesID: String,
        dateSighted: Date = .now,
        latitude: Double = 0,
        longitude: Double = 0,
        locationName: String = "",
        notes: String = "",
        photoData: Data? = nil,
        isMale: Bool = true,
        weather: String = "",
        isSharedToFeed: Bool = false
    ) {
        self.id = UUID()
        self.birdSpeciesID = birdSpeciesID
        self.dateSighted = dateSighted
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
        self.notes = notes
        self.photoData = photoData
        self.isMale = isMale
        self.weather = weather
        self.isSharedToFeed = isSharedToFeed
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
