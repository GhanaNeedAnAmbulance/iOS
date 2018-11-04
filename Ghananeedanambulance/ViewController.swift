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
//setting up data structure for json
class DataModel{
    var emptyBeds: String
    var hospitalName: String
    var iD: String
    var lat: String
    var long: String
    
    init(emptyBeds: String?,hospitalName: String?,iD: String?,lat: String?,long: String?){
        self.emptyBeds = emptyBeds!
        self.hospitalName = hospitalName!
        self.iD = iD!
        self.lat = lat!
        self.long = long!
    }
}


struct Swifter {
    let value: Int
    init(value: Int) {
        self.value = value
    }
}

extension Swifter:Decodable{
    enum MyStructKeys: String, CodingKey { // declaring our keys
        case value = "value"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MyStructKeys.self) // defining our (keyed) container
        let value: Int = try container.decode(Int.self, forKey: .value) // extracting the data
        
        self.init(value: value) // initializing our struct
    }
}


class ViewController: UIViewController {
    public var distance = [Int]()
    var final_lat:CLLocationDegrees = 48.68316
    var final_long: CLLocationDegrees = -86.25055
    var final_name: String = ""
    //for location
    private let locationManager = CLLocationManager()
    //for firebase
    var databaseRef : DatabaseReference!
    var databasehandle : DatabaseHandle!
    
    //to store values of json in custom array
    var DBList = [DataModel]()
    //
    func run(Index:Int){
        if(Index==1){
        self.ReadDB()
        print(DBList)
        }
        if(Index == 2){
            var DistanceValues = [Int]()
            var arrays :([String],[String],[String],[String])? = nil
            let group = DispatchGroup.init()
          /*  group.wait()
            DispatchQueue.main.async {
                group.enter()
                arrays = self.Breakup(DBList: self.DBList)
                print(arrays)
                group.leave()
            }
            group.wait()
            */
            DispatchQueue.main.async{
                group.enter()
                DistanceValues = self.GetMapValues(List:self.DBList)
                
                print(DistanceValues)
                group.leave()
            }
            
            group.wait()
            /*
            DispatchQueue.main.async {
                group.enter()
                let location = self.CalcBestHospital(value: DistanceValues, lat: (arrays?.1)!, long: (arrays?.2)!, name: (arrays?.0)!, noEmptyBeds: (arrays?.3)!)
                group.leave()
            }
            group.wait()
        */
            
        }
        //let DistanceValues = self.GetMapValues(List:self.DBList)
        //let arrays = Breakup(DBList: DBList)
        //let location = CalcBestHospital(value: DistanceValues, lat: arrays.1, long: arrays.2, name: arrays.0, noEmptyBeds: arrays.3)
        //print("The Initial Latitude is \(location.1) and the Longitude \(location.2)")
        //final_lat = location.1
        //final_long = location.2
        //final_name = location.0
        //loadView()
        //FindDirection(lat: location.1, Long: location.2)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self as? CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
        //runs in main thread
       DispatchQueue.main.async{
            //self.ReadDB()
        self.run(Index: 1)
        
        }
        

        //array of the distance values
        //Jonathan
        /*
        DispatchQueue.main.async{
        let DistanceValues = self.GetMapValues(List:self.DBList)
        
        }
        */
        //
        //
        //Jonathan
        
       // let arrays = Breakup(DBList: DBList)
        /*
        //Cole
        let location = CalcBestHospital(value: DistanceValues, lat: arrays.1, long: arrays.2, name: arrays.0, noEmptyBeds: arrays.3)
        //
        print("The Initial Latitude is \(location.1) and the Longitude \(location.2)")
        final_lat = location.1
         final_long = location.2
         final_name = location.0
         loadView()
        
        
        //Cole
        FindDirection(lat: location.1, Long: location.2)
        //
        */
  
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
         var current_loc = GetLocation()
        var name = ""
        var desc = ""
        if (final_name.contains("")){
            //do nothing
            name = "You"
            desc = "Your Current Location"
        }
        else{
            current_loc.0 = final_lat
            current_loc.1 = final_long
            name = "\(final_name)"
            desc = "Nearest Hospital"
        }
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: current_loc.0, longitude: current_loc.1, zoom: 10.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 48.68316, longitude: -86.25055)
        marker.title = "\(name)"
        marker.snippet = "\(desc)"
        marker.map = mapView
}
    //read data from database with sample data
    func ReadDB(){
        print(self.DBList)
        print("reading DB")
        let path = "https://gnaa-4e1a5.firebaseio.com/.json"
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
                            print(myJson)
                            print(myJson["Hospital"]!.count! as Any)
                            if let myData = myJson["Hospital"] as? [String:AnyObject]{
                                for(index,element) in myData.enumerated(){
                                    print("For position \(index) the data is \(element)")
                                    let lat = "\(element.value["lat"])"
                                    print("Latitude: \(lat )")
                                    let long = "\(element.value["lng"])"
                                    print("Longitude: \(long )")
                                    let name = "\(element.value["hospitalName"])"
                                    print("Name: \(name )")
                                    let emptybeds = "\(element.value["emptyBeds"])"
                                    print("EmptyBeds: \(emptybeds )")
                                    let iD = "\(element.value["id"])"
                                    print("ID: \(iD )")
                                    print()
                                    let list = DataModel(emptyBeds: emptybeds, hospitalName: name, iD: iD , lat: lat , long: long )
                                    print(list)
                                    self.DBList.append(list)
                                }
                                print(self.DBList)
                            }
                    }
                        self.run(Index: 2)
                        
                }
                    catch{
                        print(error)
                    }
            }
        }
        
    }
        task.resume()

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
    func CalcBestHospital(value:[Int],lat: [String], long: [String],name:[String], noEmptyBeds: [String]) -> (String,CLLocationDegrees,CLLocationDegrees){
        var indexnum = 0
        var smallest : Int
        smallest = Int(value[0])
        for (index,element) in noEmptyBeds.enumerated(){
            print("item: \(index) in array, element is \(element)")
            while (Int(element) != 0)
        {
            if (Int(value[index]) <= smallest){
                indexnum = index
                smallest = Int(value[index])
            }
            
    }
    }
        print(indexnum)
        return (name[indexnum], CLLocationDegrees(lat[indexnum])!, CLLocationDegrees(long[indexnum])!)
    }

    func GetMapValues(List: [DataModel]) -> ([Int]){
        //get user's location
        let user_location = GetLocation()
        let group = DispatchGroup()
        //loop for selecting each element in the array
        for (index,element) in List.enumerated(){
            
            print("Item: \(index), content: \(element)")
            print(element.hospitalName)
            print(element.lat as Any)
            //
            var sample = element.lat
            var result = sample.components(separatedBy: "(")
            print(result)
            
            var result_1 = result[2].components(separatedBy: ")")
            print(result_1)
            let lat_dest = result_1[0]
            //
             sample = element.long
             result = sample.components(separatedBy: "(")
            print(result)
            
             result_1 = result[2].components(separatedBy: ")")
            print(result_1)
            let long_dest = result_1[0]
            //
            //
            sample = element.hospitalName
            result = sample.components(separatedBy: "(")
            print(result)
            
            result_1 = result[2].components(separatedBy: ")")
            print(result_1)
            let name_hospital = result_1[0]
            //

            print("using destination longitude \(long_dest) & latitude \(lat_dest) and original latitude \(user_location.0) and longitude \(user_location.1) for hospital \(name_hospital)")

            let scriptUrl = "https://maps.googleapis.com/maps/api/distancematrix/json"
            let urlWithParams = scriptUrl + "?units=imperial&origins=\(user_location.0),\(user_location.1)&destinations=\(lat_dest),\(long_dest)&key=AIzaSyAOgwzUzZd78JcqcYThUsZV1wgISK-iSMY"
            let url : NSString = urlWithParams as NSString
            let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
            let searchURL : NSURL = NSURL(string: urlStr as String)!
            print(searchURL)
            let myUrl =  searchURL;
            let request = NSMutableURLRequest(url:myUrl as URL);
            // Set request HTTP method to GET. It could be POST as well
            request.httpMethod = "GET"
            // Excute HTTP Request
             DispatchQueue.main.async {
                            group.enter()
            let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
                while data == nil {
                    print("test")
                }
                do {
                // Check for error
                if error != nil
                {
                    print("error=\(String(describing: error))")
                    return
                }
                else{
                    if let content = data{
                        do{
                            //to pick up data from this the Json
                            if  let myJson = try JSONSerialization.jsonObject(with: content, options: .mutableContainers) as? NSDictionary{
                                print("Successfully sERIALIZED")
                                 print(myJson)
                                // Access value of username, name, and email by its key
                                let newdata : NSDictionary = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                                let info : NSArray =  newdata.value(forKey: "rows") as! NSArray
                                //print((myJson[0] as! NSDictionary).object(forKey: "rows") as? String as Any)
                                print(info)
                                print("Info loaded")
                                print(info.count)
                                let word : String = self.json(from: info)!
                                print(word)
                                result = word.components(separatedBy: "{")
                                print(result)
                                let result_2 = result[4]
                                print(result_2)
                                let result_3 = result_2.components(separatedBy: ":")
                                print(result_3)
                                let result_4 = result_3[1]
                                print(result_4)
                                let final = result_4.components(separatedBy: ",")
                                print(final)
                                print("The duration value on the json is \(final[0])")
                                let value: Int = Int(final[0])!
                                self.distance.append(value)
                                //print("The distance in the array now is \(distance[index])")
                                
                                group.leave()
                            }
                        }
                        catch{
                            print(error)
                        }
                        }
                    
                    
                        
                    }
                    
                }
                }
            

            task.resume()
            }
           // dispatch_semaphore_wait(seamaphore, dispatch_time_t(DispatchTime.distantFuture))
            //group.wait(timeout: .distantFuture)
            group.wait()
        }
         print(distance)
        return distance
    }
    
    //encodes things in json
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }

    
    
    //returns arrays for , name, lat, long, number of empty beds,
    func Breakup(DBList : [DataModel]) -> ([String],[String],[String],[String]){
        //breaks up dblist array into other arrays with specific information
        var names : [String] = []
        var lat : [String] = []
        var long : [String] = []
        var NoEmptyBeds : [String] = []
        
        for (index,elements) in DBList.enumerated(){
            names.append(elements.hospitalName)
            lat.append(elements.lat)
            long.append(elements.long)
            NoEmptyBeds.append(elements.emptyBeds)
            print("Just Divided: \(names[index])")
        }
        
        return (names, lat, long, NoEmptyBeds)
    }
    
    /*
    func makerequest(path:String, user_lat: String, user_long: String, lat_dest: String, long_dest: String,name: String,index: Int) -> (Int,Bool){
     print("using destination longitude \(long_dest) & latitude \(lat_dest) and original latitude \(user_lat) and longitude \(user_long) for hospital \(name)")
     var value = 0
     let scriptUrl = "https://maps.googleapis.com/maps/api/distancematrix/json"
     let urlWithParams = scriptUrl + "?units=imperial&origins=\(user_lat),\(user_long)&destinations=\(lat_dest),\(long_dest)&key=AIzaSyAOgwzUzZd78JcqcYThUsZV1wgISK-iSMY"
     let url : NSString = urlWithParams as NSString
     let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
     let searchURL : NSURL = NSURL(string: urlStr as String)!
     print(searchURL)
     let myUrl =  searchURL;
     let request = NSMutableURLRequest(url:myUrl as URL);
     // Set request HTTP method to GET. It could be POST as well
     request.httpMethod = "GET"
     // Excute HTTP Request
     DispatchQueue.main.async {
     let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
     while data == nil {
     print("test")
     }
     do {
     // Check for error
     if error != nil
     {
     print("error=\(String(describing: error))")
     return
     }
     else{
     if let content = data{
     do{
     //to pick up data from this the Json
     if  let myJson = try JSONSerialization.jsonObject(with: content, options: .mutableContainers) as? NSDictionary{
     print("Successfully sERIALIZED")
     print(myJson)
     // Access value of username, name, and email by its key
     let newdata : NSDictionary = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
     let info : NSArray =  newdata.value(forKey: "rows") as! NSArray
     //print((myJson[0] as! NSDictionary).object(forKey: "rows") as? String as Any)
     print(info)
     print("Info loaded")
     print(info.count)
     let word : String = self.json(from: info)!
     print(word)
     let result = word.components(separatedBy: "{")
     print(result)
     let result_2 = result[4]
     print(result_2)
     let result_3 = result_2.components(separatedBy: ":")
     print(result_3)
     let result_4 = result_3[1]
     print(result_4)
     let final = result_4.components(separatedBy: ",")
     print(final)
     print("The duration value on the json is \(final[0])")
     value = Int(final[0])!
     //print("The distance in the array now is \(distance[index])")
     }
     }
     catch{
     print(error)
     }
     }
     
     
     
     }
     
     }
     }
     
     
     task.resume()
     }
        return (value,true)
    }
 */
    
}



