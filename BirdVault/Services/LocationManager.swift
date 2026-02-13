import Foundation
import CoreLocation
import MapKit

/// Manages location services for BirdVault, including current position and region detection.
@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var currentRegion: BirdRegion = .northeast
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationName: String = "Unknown Location"
    @Published var isAuthorized: Bool = false

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 100
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    func reverseGeocode() async {
        guard let location = currentLocation else { return }
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                let city = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                if !city.isEmpty && !state.isEmpty {
                    locationName = "\(city), \(state)"
                } else if !state.isEmpty {
                    locationName = state
                }

                if let state = placemark.administrativeArea {
                    currentRegion = Self.regionForState(state)
                }
            }
        } catch {
            locationName = "Location unavailable"
        }
    }

    /// Maps a US state abbreviation or name to a BirdRegion.
    static func regionForState(_ state: String) -> BirdRegion {
        let stateUpper = state.uppercased()
        let mapping: [String: BirdRegion] = [
            // Northeast
            "ME": .northeast, "MAINE": .northeast,
            "NH": .northeast, "NEW HAMPSHIRE": .northeast,
            "VT": .northeast, "VERMONT": .northeast,
            "MA": .northeast, "MASSACHUSETTS": .northeast,
            "RI": .northeast, "RHODE ISLAND": .northeast,
            "CT": .northeast, "CONNECTICUT": .northeast,
            "NY": .northeast, "NEW YORK": .northeast,
            "NJ": .northeast, "NEW JERSEY": .northeast,
            "PA": .northeast, "PENNSYLVANIA": .northeast,
            "DE": .northeast, "DELAWARE": .northeast,
            "MD": .northeast, "MARYLAND": .northeast,
            // Southeast
            "VA": .southeast, "VIRGINIA": .southeast,
            "WV": .southeast, "WEST VIRGINIA": .southeast,
            "NC": .southeast, "NORTH CAROLINA": .southeast,
            "SC": .southeast, "SOUTH CAROLINA": .southeast,
            "GA": .southeast, "GEORGIA": .southeast,
            "AL": .southeast, "ALABAMA": .southeast,
            "MS": .southeast, "MISSISSIPPI": .southeast,
            "TN": .southeast, "TENNESSEE": .southeast,
            "KY": .southeast, "KENTUCKY": .southeast,
            "LA": .southeast, "LOUISIANA": .southeast,
            "AR": .southeast, "ARKANSAS": .southeast,
            // Florida
            "FL": .florida, "FLORIDA": .florida,
            // Texas
            "TX": .texas, "TEXAS": .texas,
            // Midwest
            "OH": .midwest, "OHIO": .midwest,
            "IN": .midwest, "INDIANA": .midwest,
            "IL": .midwest, "ILLINOIS": .midwest,
            "MI": .midwest, "MICHIGAN": .midwest,
            "WI": .midwest, "WISCONSIN": .midwest,
            "MN": .midwest, "MINNESOTA": .midwest,
            "IA": .midwest, "IOWA": .midwest,
            "MO": .midwest, "MISSOURI": .midwest,
            // Great Plains
            "ND": .greatPlains, "NORTH DAKOTA": .greatPlains,
            "SD": .greatPlains, "SOUTH DAKOTA": .greatPlains,
            "NE": .greatPlains, "NEBRASKA": .greatPlains,
            "KS": .greatPlains, "KANSAS": .greatPlains,
            "OK": .greatPlains, "OKLAHOMA": .greatPlains,
            "MT": .greatPlains, "MONTANA": .greatPlains,
            "WY": .greatPlains, "WYOMING": .greatPlains,
            // Southwest
            "AZ": .southwest, "ARIZONA": .southwest,
            "NM": .southwest, "NEW MEXICO": .southwest,
            "NV": .southwest, "NEVADA": .southwest,
            "UT": .southwest, "UTAH": .southwest,
            "CO": .southwest, "COLORADO": .southwest,
            // West / California
            "CA": .california, "CALIFORNIA": .california,
            // Northwest
            "OR": .northwest, "OREGON": .northwest,
            "WA": .northwest, "WASHINGTON": .northwest,
            "ID": .northwest, "IDAHO": .northwest,
            // Alaska & Hawaii
            "AK": .alaska, "ALASKA": .alaska,
            "HI": .hawaii, "HAWAII": .hawaii,
        ]

        return mapping[stateUpper] ?? .northeast
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = location
            await self.reverseGeocode()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.isAuthorized = true
                self.startUpdating()
            case .denied, .restricted:
                self.isAuthorized = false
            case .notDetermined:
                self.isAuthorized = false
            @unknown default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location errors are non-fatal, the app works without precise location
    }
}
