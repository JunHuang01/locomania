//
//  ViewController.swift
//  locomania
//
//  Created by Jun Huang on 3/31/15.
//  Copyright (c) 2015 Jun Huang. All rights reserved.
//

import UIKit

import CoreLocation

class ViewController: UIViewController , CLLocationManagerDelegate {

    @IBOutlet weak var LatValue: UILabel!
    @IBOutlet weak var LongValue: UILabel!
    @IBOutlet weak var Timer: UILabel!
    
    var locationManager: CLLocationManager!
    var currUserLocation: CLLocation!
    
    var currTimeSinceLastPush: Int!
    
    let PUSH_INTERVAL = 15;
    
    var pushCount: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view, typically from a nib.
        self.setUpLocationManager();
        
        currTimeSinceLastPush = 0;
        pushCount = 0;
        
        self.timerUpdate();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //sets up location manager, and ask user for permission to use app location.
    func setUpLocationManager(){
        locationManager = CLLocationManager();
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization();
        locationManager.startUpdatingLocation();
        println("started");

    }


    //This overrides the location manager update function, this determines what to do with new location data.
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        var location:CLLocation = locations[locations.count-1] as CLLocation;
        println("locations = \(locations)");
        LatValue.text = "\(location.coordinate.latitude)";
        LongValue.text = "\(location.coordinate.longitude)";
        currUserLocation = location;
    }
    
    func timerUpdate(){
        let delay = 1 * Double(NSEC_PER_SEC);
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay));
        dispatch_after(time, dispatch_get_main_queue()){
            self.currTimeSinceLastPush = self.currTimeSinceLastPush + 1;
            if (self.currTimeSinceLastPush > self.PUSH_INTERVAL ){
                self.currTimeSinceLastPush = 0;
                self.pushLocationToServer(self.currUserLocation);
            }
            self.Timer.text = String(self.currTimeSinceLastPush);
            self.timerUpdate();
        }
        
        
    }
    
    func pushLocationToServer(location: CLLocation){
        self.pushCount = self.pushCount + 1;
        
        //TO-DO: Change the url here for your own API call
        self.post(["":""], url: "http://192.168.1.110:8888/pushLatLong/\(self.pushCount)/\(location.coordinate.latitude)/\(location.coordinate.longitude)") { (succeeded: Bool, msg: String) -> () in
            var alert = UIAlertView(title: "Success!", message: msg, delegate: nil, cancelButtonTitle: "Okay.")
            if(succeeded) {
                alert.title = "Success!"
                alert.message = msg
            }
            else {
                alert.title = "Failed :("
                alert.message = msg
            }
            
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Show the alert
                alert.show()
            })
        }
    
    }
    
    
    
    
    /* https://github.com/jquave/SwiftPOSTTutorial */
    func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            var msg = "No message"
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: "Error")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    if let success = parseJSON["success"] as? Bool {
                        println("Succes: \(success)")
                        postCompleted(succeeded: success, msg: "Logged in.")
                    }
                    return
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, msg: "Error")
                }
            }
        })
        
        task.resume()
    }
    
}

