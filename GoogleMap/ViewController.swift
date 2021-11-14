//
//  ViewController.swift
//  GoogleMap
//
//  Created by MAC on 22/06/2021.
//

import UIKit
import CoreLocation
import GoogleMaps
import Alamofire
import SwiftyJSON
import GooglePlaces

/*
 1- create project
 2- close project and install cocoa pods
 3- go to termianl cd and project path
 4- pod init
 5- open pod file
 6- open the pod and write the pod file description   pod 'GoogleMaps', '5.0.0'
 
 7-  here we add the dark themee in google https://mapstyle.withgoogle.com visit this select any theme and click on finish button and copy the josn and make a file and use this file in a code
 8 - Also add the google map key in app deletgate
 9 - Also add the permison in plist for using google map
 
 **/
//var locationUpdate :((CLLocation) -> ())?
class ViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    var timer = Timer()
    let manager = CLLocationManager()
    let karachi = CLLocationCoordinate2D(latitude: 24.882752, longitude: 67.149848)
    var tandoAdam = CLLocationCoordinate2D(latitude: 25.76284, longitude: 68.66087)
    let marker = GMSMarker()


    override func viewDidLoad() {
        super.viewDidLoad()
       // self.setupMap(title: "Karachi", subtitle: "Shah Faisal", karachi)
       // self.setupMap(title: "TDM", subtitle: "AK H", tandoAdam)
      //  self.fetchData(tandoAdam, karachi)
        //self.mapView.mapStyle(name:"darkTheme", type:"json")
        //self.showingThePath(tandoAdam, karachi)
        //self.drawMap(tandoAdam, karachi)
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(moveBike), userInfo: nil, repeats: true)
        
        
    
       
    }
    
    

    @objc func moveBike(){
        
        marker.icon = #imageLiteral(resourceName: "DiceFive")
        self.tandoAdam.latitude += 0.0017
            CATransaction.begin()
            CATransaction.setValue(2.0, forKey: kCATransactionAnimationDuration)
            CATransaction.setCompletionBlock {
                self.marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            }
        mapView.animate(to: GMSCameraPosition.camera(withLatitude: tandoAdam.latitude, longitude: tandoAdam.longitude, zoom: 15))
        marker.position = CLLocationCoordinate2D(latitude: tandoAdam.latitude, longitude: tandoAdam.longitude)
            CATransaction.commit()
            marker.map = self.mapView
    }
    
func drawMap(_ sourceCordinate : CLLocationCoordinate2D, _ destinationcordinate :CLLocationCoordinate2D)
        {  let googleApiKey = "AIzaSyALjVgJKP3TZGlfDv82JbDf1QlbwTwbRDU"
            self.mapView.clear()
            let url = String(format:"https://maps.googleapis.com/maps/api/directions/json?origin=\(sourceCordinate.latitude),\(sourceCordinate.longitude)&destination=\(destinationcordinate.latitude),\(destinationcordinate.longitude)&key=\(googleApiKey)")
            print(url)
   
    AF.request(url).responseJSON { (response) in
        if response != nil{
            do {
                let json = try JSON(data: response.data!)
                let routes = json["routes"].arrayValue

                        for route in routes
                        {
                            let routeOverviewPolyline = route["overview_polyline"].dictionary
                            let points = routeOverviewPolyline?["points"]?.stringValue
                            let path = GMSPath.init(fromEncodedPath: points!)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeColor = UIColor.red
                            polyline.strokeWidth = 3
                            polyline.map = self.mapView
                        }
            }
            catch{
                print("catching an error")
            }
        }
    }
            
        } // end of drwa mamp func
    func showingThePath(_ startingPoints:CLLocationCoordinate2D,_ destination:CLLocationCoordinate2D){
        let orrigin1 = "\(String(describing: startingPoints.latitude)),\(String(describing: startingPoints.longitude))"
        let destionation2 = "\(String(describing: destination.latitude)),\(String(describing: destination.longitude))"
        //let googleApiKey = "AIzaSyD-3egs3u2kKURY-TLDBiB4Z4v0kv4dZLk"
        let googleApiKey = "AIzaSyALjVgJKP3TZGlfDv82JbDf1QlbwTwbRDU"
//        guard  let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(orrigin1)&destination=\(destionation2)&sensor=true&key=\(googleApiKey)") else {
//            print("not getting the url")
//            return
//        }
        
        guard let url = URL(string: "\("https://maps.googleapis.com/maps/api/directions/json")?origin=\(startingPoints.latitude),\(startingPoints.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&key=\(googleApiKey)") else {return}
        
            URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
                if(error != nil){
                    print("gettting an in url session")
                }else{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                        print(json)
                        if json["status"] as! String == "OK"
                        {
                            let routes = json["routes"] as! [[String:AnyObject]]
                            OperationQueue.main.addOperation({
                                for route in routes
                                {
                                    let routeOverviewPolyline = route["overview_polyline"] as! [String:String]
                                    let points = routeOverviewPolyline["points"]
                                    let path = GMSPath.init(fromEncodedPath: points!)
                                    let polyline = GMSPolyline.init(path: path)
                                    polyline.strokeWidth = 4
                                    polyline.strokeColor = UIColor.blue
                                    polyline.map = self.mapView
                                }
                            })
                        }
                    }catch let error as NSError{
                        print(error)
                    }
                }
            }).resume()
        }
    
  /*
    func fetchData(_ startingPoints:CLLocationCoordinate2D,_ destination:CLLocationCoordinate2D){
    
        
        var url1 = "http://maps.googleapis.com/maps/api/directions/json?origin=\(startingPoints.latitude),\(startingPoints.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=AIzaSyD-3egs3u2kKURY-TLDBiB4Z4v0kv4dZLk"
           url1 = url1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let headers: HTTPHeaders = [ "Accept": "application/json", "Content-Type": "application/json" ]
        
        
        AF.request(url1, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in

                                print(response.request as Any)  // original URL request
                                print(response.response as Any) // HTTP URL response
                                print(response.data as Any)     // server data
                                print(response.result as Any)   // result of response serialization
            
                                do{
                                    let json = try JSON(data: response.data!)
                                    let routes = json["routes"].arrayValue

                                    // print route using Polyline
                                    for route in routes{
                                        let routeOverviewPolyline = route["overview_polyline"].dictionary
                                        let points = routeOverviewPolyline?["points"]?.stringValue
                                        let path = GMSPath.init(fromEncodedPath: points!)
                                        let polyline = GMSPolyline.init(path: path)
                                        polyline.strokeWidth = 4
                                        polyline.strokeColor = UIColor.blue
                                        polyline.map = self.mapView
                                    }
                                }catch let error {
                                    print(error.localizedDescription)
                                }


                            }
                 
                
    }*/
    
    
    // MARK:- For fetching Route
    /*
    func fetchRoute(_ startingPoint:CLLocationCoordinate2D,_ destination:CLLocationCoordinate2D){
        let session = URLSession.shared
        guard let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(startingPoint.latitude),\(startingPoint.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving") else {return}
       
        let urlTask = session.dataTask(with: url) { (data, response, error) in
            guard error == nil,let data = data else  {
                print(error?.localizedDescription)
                return
            }
            guard let josnResult = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],let josnRespone = josnResult else{
                priit
            }
        }
    }
    */
    
    func addPolyLine(encodedString: String) {

        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5
        polyline.strokeColor = .blue
       // polyline.map = whateverYourMapViewObjectIsCalled

    }
    
    func setupMap(title:String,subtitle:String,_ coordinate:CLLocationCoordinate2D){
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude:  coordinate.longitude, zoom: 6.0)
        mapView.camera = camera
        mapView.camera = camera
        self.addMarker(title: title, subtitle: subtitle, coordinate:coordinate)
    }
    
    func moveLocation(){
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (Timer) in
            
        })
    }
    
    func addMarker(title:String,subtitle:String,coordinate:CLLocationCoordinate2D){
        let marker = GMSMarker()
        marker.icon = #imageLiteral(resourceName: "DiceFive")
//        locationUpdate = { location in
//            self.moveCar(location.coordinate)
//        }
        marker.position = coordinate
        marker.title = title
        marker.snippet = subtitle
        marker.map = mapView
    }

//    func moveCar(_ movingPosition: CLLocationCoordinate2D){
//        print(movingPosition)
//    }
    
}

extension UIViewController : CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.first != nil else{
            return
        }
    }
    
}

// for editing the theme style
extension GMSMapView{
    
    func mapStyle(name:String, type:String){
        do {
            if let styleURl =  Bundle.main.url(forResource: name, withExtension: type){
                self.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURl)
                
            }else{
                NSLog("Unable to find darkMap")
            }
        }
        catch{
            NSLog("failded to load. \(error)")
        }
    }
}
