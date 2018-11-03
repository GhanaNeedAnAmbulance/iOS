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
    //to store values of json in custom array
    var DBList = [DataModel]()
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self as? CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
    }
    //read data from database with sample data
    func ReadDB(){
        databaseRef = Database.database().reference().child("Hospital")
        //observing the data changes
        databaseRef.observe(DataEventType.value, with: { (snapshot) in
            print(snapshot)
            //if the reference have some values
            if snapshot.childrenCount > 0 {
                for values in snapshot.children.allObjects as! [DataSnapshot] {
                    let ValueObjects = values.value as? [String:AnyObject]
                    let lat = ValueObjects?["lat"]
                    let long = ValueObjects?["lng"]
                    let name = ValueObjects?["hospitalName"]
                    let emptybeds = ValueObjects?["emptyBeds"]
                    let iD = ValueObjects?["id"]
                    
                    let list = DataModel(emptyBeds: emptybeds as? Int, hospitalName: name as? String, iD: iD as? Int, lat: lat as? Float, long: long as? Float)
                    
                    self.DBList.append(list)
                }
                print(self.DBList)
            }
        })
    }
    
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
    
    //gets the location of user and put it in an "array"
    func GetLocation() -> (CLLocationDegrees,CLLocationDegrees){
        locationManager.startUpdatingLocation()
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        locationManager.stopUpdatingLocation()
        return (latitude!,longitude!)
    }
    
    //Loads Mapview and places pointer on current location
    override func loadView() {
        print("Loading View")
        checkGoogleMaps()
        ReadDB()
        //array of the distance values
        //Jonathan
        let DistanceValues = GetMapValues(List:DBList)
        //
        //
        //Jonathan
        let arrays = Breakup(DBList: DBList)
        //
        //Cole
        let location = CalcBestHospital(value: DistanceValues, lat: arrays.1, long: arrays.2, name: arrays.0, noEmptyBeds: arrays.3)
        //
        print("The Initial Latitude is \(location.1) and the Longitude \(location.2)")
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: location.1, longitude: location.2, zoom: 14.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.1, longitude: location.2)
        marker.title = "Your Location"
        marker.snippet = "\(location.1),\(location.2)"
        marker.map = mapView
        
        //Cole
        FindDirection(lat: location.1, Long: location.2)
        //
}

    //we have to make this general so that it can take different coordinates
    func FindDirection(lat: CLLocationDegrees, Long: CLLocationDegrees){
        let InitialLocation = GetLocation()
        
    if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
        UIApplication.shared.open(URL(string:"https://www.google.de/maps/dir/\(InitialLocation.0),\(InitialLocation.1)/\(lat),\(Long)/&travelmode=driving")!, options: [:], completionHandler: nil)
    } else {
        print("Can't use comgooglemaps://");
    }
}
    

    
    //function to calculate the best hospital to go to
    // returns name, lat, long
    func CalcBestHospital(value:[Int],lat: [CLLocationDegrees], long: [CLLocationDegrees],name:[String], noEmptyBeds: [Int]) -> (String,CLLocationDegrees,CLLocationDegrees){
        var indexnum : Int = -1
        var smallest : Int
        smallest = value[0]
        for (index,element) in noEmptyBeds.enumerated(){
            print("item: \(index) in array, element is \(element)")
            while (element != 0)
        {
                if (value[index] <= smallest){
                indexnum = index
                    smallest = value[index]
            }
            
    }
    }
        return (name[indexnum], lat[indexnum], long[indexnum])
    }

    func GetMapValues(List: [DataModel]) -> ([Int]){
        //get user's location
//https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615%2C-73.9976592%7C&key=AIzaSyAOgwzUzZd78JcqcYThUsZV1wgISK-iSMY
        let user_location = GetLocation()
        var distance : [Int] = [0]
        //loop for selecting each element in the array
        for (index,element) in List.enumerated(){
            print("Item: \(index), content: \(element)")
            //element contains the custom datatype
            let path = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(user_location.0),\(user_location.1)&destinations=\(String(describing: element.lat))%2C\(String(describing: element.long))C&key=AIzaSyAOgwzUzZd78JcqcYThUsZV1wgISK-iSMY"
            let urlString = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let url = URL(string: urlString!)
            print("The URL is \(String(describing: url))")
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if(error != nil){
                 print("An error occured")
                print(error!)
                }
                else{
                    if let content = data{
                        do{
                            //to pick up data from this the Json
                            if  let myJson = try JSONSerialization.jsonObject(with: content) as? [String:AnyObject] {
                                 if(myJson.isEmpty){
                                    print("Json response is empty")
                                }
                                 else{
                                    distance[index] = myJson["distance"]?["value"] as? Int ?? -1
                                    print("The distance of \(String(describing: element.hospitalName)) is \(distance[index])")
                                }
                            }
                        }
                        catch{
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
        return distance
    }
    
    
    
    //returns arrays for , name, lat, long, number of empty beds,
    func Breakup(DBList : [DataModel]) -> ([String],[CLLocationDegrees],[CLLocationDegrees],[Int]){
        //breaks up dblist array into other arrays with specific information
        
    }
    
}

//setting up data structure for json
class DataModel{
    var emptyBeds: Int?
    var hospitalName: String?
    var iD: Int?
    var lat: Float?
    var long: Float?
    
    init(emptyBeds: Int?,hospitalName: String?,iD: Int?,lat: Float?,long: Float?){
        self.emptyBeds = emptyBeds
        self.hospitalName = hospitalName
        self.iD = iD
        self.lat = lat
        self.long = long
    }
}
