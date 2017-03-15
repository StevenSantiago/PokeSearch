//
//  MainVC.swift
//  PokeSearch
//
//  Created by Steven Santiago on 3/4/17.
//  Copyright © 2017 Steven Santiago. All rights reserved.
//TODO: Add one more feature. Being able to remove sightings from App(user removal)
// DeleteKey is there but does not do anything yet

import UIKit
import GeoFire
import FirebaseDatabase

class MainVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, PokemonDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false// only used to center map on startup
    
    var geoFire: GeoFire! // used to read or write geo data to database
    var geoFireRef: FIRDatabaseReference!// reference to firebase database
    var pokemonChoosen: String = ""
    var selectedPokemon = false
    var selectedPokeLoc = CLLocation(latitude: 0,longitude: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow // map will move with user location
        geoFireRef = FIRDatabase.database().reference()// store firebase database reference
        geoFire = GeoFire(firebaseRef: geoFireRef) // intialize geofire
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Issue with this is that mapView is not centered in on user immediately
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidAppear(<#T##animated: Bool##Bool#>)
        locationAuthStatus()
    }
    
    func locationAuthStatus() { // request for location info
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true // use location
        } else {
            locationManager.requestWhenInUseAuthorization()// delivers status to didChangeAuthorization only when status was not known and is known after user input
        }
    }
    
    
    // Following functions will be called when user says yes or no to accesing location info
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    // Centers on location
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // update when userlocation update comes in
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print(mapHasCenteredOnce)
        if let loc = userLocation.location {
            if !mapHasCenteredOnce { // only center on startup
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    
    // User annotation replaced with ash image(custom annotation), called when annotation is added to mapview
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView?
        let annoIdentifier = "Pokemon"
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "ash")
        } else if let dequedAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            annotationView = dequedAnno
            annotationView?.annotation = annotation
        } else { // execute if deque fails
            let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            annoView.leftCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annoView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = annoView
        }
        
        if let annotationView = annotationView, let anno = annotation as? PokeAnnotation {
            annotationView.canShowCallout = true // before doing this title for annotation must be given
            annotationView.image = UIImage(named: "\(anno.pokemonNumber)")
            let btnr = UIButton()
            let btnl = UIButton()
            btnl.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btnr.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btnl.setImage(UIImage(named: "DeleteKey"), for: .normal)
            btnr.setImage(UIImage(named: "map"), for: .normal)
            annotationView.leftCalloutAccessoryView = btnl
            annotationView.rightCalloutAccessoryView = btnr
        }
        
        return annotationView
    }
    
    
    
    
    //Add location to firebase databas with geoFire
    func createSighting(forLocation location: CLLocation, withPokemon pokeId: Int){
        geoFire.setLocation(location, forKey: "\(pokeId)")
    }
    
    
    // creating query for user closest sightings
    func showSightingsOnMap(location: CLLocation) {
        let circleQuery = geoFire.query(at: location, withRadius: 2.5) // create query
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in // called for every pokemon found
            if let key = key, let location = location {
                let anno = PokeAnnotation(coordinate: location.coordinate, pokemonNumber: Int(key)!)
                self.mapView.addAnnotation(anno)//add custom annotation to mapview
            }
            
        })
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let anno = view.annotation as? PokeAnnotation {
            let place = MKPlacemark(coordinate: anno.coordinate)
            let destination = MKMapItem(placemark: place)
            destination.name = "\(anno.pokemonName)"
            let regionDistance : CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey : NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
    }
    
    //Updates map when user pans
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        showSightingsOnMap(location: loc)
    }
    
    
    // going to launch segue to different view controller to select pokemon
    
    
    @IBAction func spotPokemon(_ sender: UIButton) {
        selectedPokeLoc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        performSegue(withIdentifier: "SelectPokemon", sender: nil)
    }
    
    // Protocol Method to pass back selected pokemon from next view controller
    func pokemonSelected(pokemonSel: String) {
        pokemonChoosen = pokemonSel
        selectedPokemon = true
        createSighting(forLocation: selectedPokeLoc, withPokemon: pokemonDict[pokemonSel]!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectPokemon" {
            if let SelectVC = segue.destination as? SelectPokemonVC {
                SelectVC.delegate = self
            }
        }
    }
    
    
}

