import MapKit
import SwiftUI

struct MapViewExample: View {
    @State private var selectedLocation: MKPlacemark?

    var body: some View {
        VStack {
            SearchTextField(selectedLocation: $selectedLocation)

            if let location = selectedLocation {
                Text("Selected Location: \(location.name ?? ""), Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    .padding()
            }

            MapView(selectedLocation: $selectedLocation)
                .ignoresSafeArea()
        }
    }
}

struct SearchTextField: View {
    @State private var searchString: String = ""
    @Binding var selectedLocation: MKPlacemark?

    var body: some View {
        TextField("Search", text: $searchString)
            .padding()
            .cornerRadius(10)
            .onSubmit(searchLocation) // Handle "Enter" key press
    }

    private func searchLocation() {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchString

        let search = MKLocalSearch(request: searchRequest)

        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }

            self.selectedLocation = response.mapItems.first?.placemark
        }
    }
}

struct MapView: UIViewRepresentable {
    @Binding var selectedLocation: MKPlacemark?

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            print("Center Coordinate: \(mapView.centerCoordinate)")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let location = selectedLocation {
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            uiView.setRegion(coordinateRegion, animated: true)
        }
    }
}

struct MapViewExample_Previews: PreviewProvider {
    static var previews: some View {
        MapViewExample()
    }
}
