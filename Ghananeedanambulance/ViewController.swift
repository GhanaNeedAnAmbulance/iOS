//
//  ViewController.swift
//  Ghananeedanambulance
//
//  Created by Jonathan Lamptey & Cole Pickford on 02/11/2018.
//  Copyright © 2018 Ghananeedanambulance. All rights reserved.
//

import UIKit
import GoogleMaps
import Foundation
import FirebaseDatabase
class ViewController: UIViewController {
    //for location
    private let locationManager = CLLocationManager()
    //for firebase
    var databaseRef : DatabaseReference!
    var databasehandle : DatabaseHandle!
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self as? CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
    }
    
    //Loads Mapview and places pointer on current location
    override func loadView() {
        print("Loading View")
        checkGoogleMaps()
        let location = GetLocation()
        print("The Initial Latitude is \(location.0) and the Longitude \(location.1)")
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: location.0, longitude: location.1, zoom: 8.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.0, longitude: location.1)
        marker.title = "Your Location"
        marker.snippet = "\(location.0),\(location.1)"
        marker.map = mapView
    }
//
    func checkGoogleMaps(){
        //checks if Google maps is installed
        if(UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)){
            print("Google Maps installed")
         return
        }
        else{
         //runs in main thread
         DispatchQueue.main.async{
            //create an alert
            let alert = UIAlertController(title: "There is no Google Maps installed on your phone", message: "There is no Google Maps installed on your phone. Install Google Maps to have the best experience using this app", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Download", style: UIAlertAction.Style.default, handler: { (action) in
                //opens google maps in ios store
                UIApplication.shared.open(URL(string:"https://itunes.apple.com/gb/app/google-maps-transit-food/id585027354?mt=8")!, options: [:], completionHandler: nil)
            }))
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert,animated: true,completion: nil)
         }
        }
    }
    //get the location and put it in an "array"
    func GetLocation() -> (CLLocationDegrees,CLLocationDegrees){
        locationManager.startUpdatingLocation()
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        locationManager.stopUpdatingLocation()
        return (latitude!,longitude!)
    }
    //read data from database
    func ReadDB(){
        
    }
}

