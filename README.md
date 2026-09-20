# BirdVault

An iOS birding journal — photograph a bird, let the app suggest what it is, and build a life list
pinned to where you saw each one.

## Features

- **On-device bird identification** from a photo using a Core ML vision model
- **Location-tagged sightings** plotted on a map
- **Photo library import** alongside in-app capture
- **Persistent life list** stored locally with SwiftData

## Tech

| Area | Stack |
|---|---|
| UI | SwiftUI |
| Identification | Core ML + Vision |
| Location & maps | CoreLocation, MapKit |
| Photos | PhotosUI |
| Persistence | SwiftData |
| Tests | XCTest |

The classifier is a `BirdClassifier.mlpackage` converted from a PyTorch image model with `coremltools`, so identification runs fully on device.

Status: personal project, not released on the App Store.
