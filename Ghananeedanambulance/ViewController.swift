//
//  ViewController.swift
//  Ghananeedanambulance
//
//  Created by Jonathan Lamptey & Cole Pickford on 02/11/2018.
//  Copyright © 2018 Ghananeedanambulance. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    private let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self as? CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //this is just a test
    override func loadView() {
        print("Loading View")
        checkGoogleMaps()
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 48.68316, longitude: -86.25055, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 48.68316, longitude: -86.25055)
        marker.title = "Test"
        marker.snippet = "Test Address"
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
    
}

