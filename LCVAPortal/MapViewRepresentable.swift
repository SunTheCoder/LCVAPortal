import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    let artPiece: ArtPiece

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        updateMapView(mapView)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateMapView(uiView)
    }
    
    private func updateMapView(_ mapView: MKMapView) {
        let coordinate = CLLocationCoordinate2D(latitude: artPiece.latitude, longitude: artPiece.longitude)
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)

        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = artPiece.title
        mapView.addAnnotation(annotation)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let identifier = "ArtPieceAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.markerTintColor = .blue
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
        }
    }
}
