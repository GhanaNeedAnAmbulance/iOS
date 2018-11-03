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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //this is just a test
    override func loadView() {
        print("Loading View")
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 48.68316, longitude: -86.25055, zoom: 8.0)
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
    
}

